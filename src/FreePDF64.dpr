program FreePDF64;

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  LMDShConsts in 'LMDShConsts.pas',
  FreePDF64_Unit in 'FreePDF64_Unit.pas' {FreePDF64_Form},
  DokuInfo_Unit in 'DokuInfo_Unit.pas' {DokuInfo_Form},
  Einstellungen_Unit in 'Einstellungen_Unit.pas' {Einstellungen_Form},
  Encrypt_Unit in 'Encrypt_Unit.pas' {Encrypt_Form},
  Seiten_Unit in 'Seiten_Unit.pas' {Seiten_Form},
  Favoriten_Unit in 'Favoriten_Unit.pas' {Favoriten_Form},
  Info_Unit in 'Info_Unit.pas' {Info_Form},
  FreePDF64_Notify_Unit in 'FreePDF64_Notify_Unit.pas' {FreePDF64_Notify},
  Einstellungen_Hilfe_Unit in 'Einstellungen_Hilfe_Unit.pas' {Einstellungen_Hilfe_Form},
  Favoriten2_Unit in 'Favoriten2_Unit.pas' {Favoriten2_Form},
  Wasserzeichen_Unit in 'Wasserzeichen_Unit.pas' {Wasserzeichen_Form},
  Zusatz_Unit in 'Zusatz_Unit.pas' {Zusatz_Form},
  Splashscreen_Unit in 'Splashscreen_Unit.pas' {Splashscreen_Form},
  Dateianlage_Unit in 'Dateianlage_Unit.pas' {Dateianlage_Form},
  Status_Unit in 'Status_Unit.pas' {Status_Form},
  Auswahl_Unit in 'Auswahl_Unit.pas' {Auswahl_Form},
  Suchen in 'Suchen.pas' {Suche_Form},
  Anleitung_Unit in 'Anleitung_Unit.pas' {Anleitung_Form},
  Suche_Info_Unit in 'Suche_Info_Unit.pas' {Suche_Info},
  uPDFBrowserForm in 'uPDFBrowserForm.pas' {PDFBrowserForm},
  uPDFTabsForm in 'uPDFTabsForm.pas',
  FreePDF64PrinterConfig in '..\FreePDF64_PostScriptPrinter\Source\FreePDF64PrinterConfig.pas';

type
  TPDFExceptionHandler = class
    procedure HandleException(Sender: TObject; E: Exception);
  end;

procedure TPDFExceptionHandler.HandleException(Sender: TObject; E: Exception);
begin
  // Unterdrueckt ausschliesslich den VCL-Fehlerdialog fuer EAccessViolation.
  // Ein ungueltiger Speicherzugriff wird dadurch NICHT repariert.
  if E is EAccessViolation then
    Exit;
  Application.ShowException(E);
end;

var
  hMutex: THandle;
  hPDFStartMutex: THandle;
  PDFMutexWait: DWORD;
  MutexName: string;
  PDFDatei: string;
  PDFBrowserForm: TPDFBrowserForm;
  PDFTabsForm: TPDFTabsForm;
  PDFModus: Boolean;
  IndependentViewer: Boolean;
  PDFDateien: TStringList;
  I: Integer;
  ExceptionHandler: TPDFExceptionHandler;
begin
  hMutex := 0;
  hPDFStartMutex := 0;
  // Wurde FreePDF64 mit einem PDF-Dateipfad gestartet
  // (z. B. durch Doppelklick im Windows-Explorer)?
  PDFDatei := '';
  PDFModus := False;
  IndependentViewer := False;

  PDFDateien := TStringList.Create;
  try
    for I := 1 to ParamCount do
    begin
      if SameText(ParamStr(I), '--viewer-independent') then
      begin
        IndependentViewer := True;
        Continue;
      end;
      PDFDatei := ExpandFileName(ParamStr(I));
      if SameText(ExtractFileExt(PDFDatei), '.pdf') and FileExists(PDFDatei) then
        PDFDateien.Add(PDFDatei);
    end;
    PDFModus := PDFDateien.Count > 0;

    // Explorer startet bei Mehrfachauswahl oft mehrere Prozesse gleichzeitig.
    // Der Mutex serialisiert die Entscheidung "an bestehende Tabs senden
    // oder selbst ein Tabfenster erstellen".
    if PDFModus and not IndependentViewer then
    begin
      hPDFStartMutex := CreateMutex(nil, False,
        'Local\FreePDF64_PDFTabs_Explorer_Start');
      if hPDFStartMutex <> 0 then
      begin
        PDFMutexWait := WaitForSingleObject(hPDFStartMutex, 10000);
        if not (PDFMutexWait in [WAIT_OBJECT_0, WAIT_ABANDONED]) then
        begin
          CloseHandle(hPDFStartMutex);
          hPDFStartMutex := 0;
        end;
      end;
    end;

    // Alle Explorer-Dateien uebergeben, nicht nur ParamStr(1).
    // Wenn nicht alle angenommen werden, bleiben sie fuer den lokalen Start.
    if PDFModus and not IndependentViewer then
    begin
      I := 0;
      while I < PDFDateien.Count do
        if SendPDFToExistingTabs(PDFDateien[I]) then
          PDFDateien.Delete(I)
        else
          Inc(I);
      if PDFDateien.Count = 0 then
      begin
        if hPDFStartMutex <> 0 then
        begin
          ReleaseMutex(hPDFStartMutex);
          CloseHandle(hPDFStartMutex);
          hPDFStartMutex := 0;
        end;
        Halt(0);
      end;
    end;

  if not PDFModus then
  begin
    MutexName := 'Mutex_' + ExtractFileName(ParamStr(0));
    hMutex := CreateMutex(nil, True, PChar(MutexName));

    if (hMutex = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
    begin
      if hMutex <> 0 then
        CloseHandle(hMutex);

      MessageBox(0,
        'FreePDF64 läuft bereits!',
        'Hinweis',
        MB_ICONINFORMATION or MB_OK);
      Halt;
    end;
  end;

  try
  Application.Initialize;
  // Nur der eigenstaendige Explorer-Prozess beendet sich mit dem letzten PDF.
  // Ein regulaer gestartetes Hauptprogramm bleibt im Speicher.
  PDFTabsExplorerOnlyProcess := PDFModus;
  ExceptionHandler := TPDFExceptionHandler.Create;
  Application.OnException := ExceptionHandler.HandleException;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'FreePDF64';

  // Beide Startarten verwenden denselben Initialisierungsweg.
  // Bei Explorer-Aufruf ist das Hauptformular nur der unsichtbare VCL-Host;
  // die PDF wird im Registerkartenfenster angezeigt.
  if PDFModus then
    Application.ShowMainForm := False;

  Application.CreateForm(TFreePDF64_Form, FreePDF64_Form);
  Application.CreateForm(TEinstellungen_Form, Einstellungen_Form);
  Application.CreateForm(TAuswahl_Form, Auswahl_Form);
  Application.CreateForm(TEncrypt_Form, Encrypt_Form);
  Application.CreateForm(TDokuInfo_Form, DokuInfo_Form);
  Application.CreateForm(TSeiten_Form, Seiten_Form);
  Application.CreateForm(TFavoriten_Form, Favoriten_Form);
  Application.CreateForm(TInfo_Form, Info_Form);
  Application.CreateForm(TFreePDF64_Notify, FreePDF64_Notify);
  Application.CreateForm(TEinstellungen_Hilfe_Form, Einstellungen_Hilfe_Form);
  Application.CreateForm(TFavoriten2_Form, Favoriten2_Form);
  Application.CreateForm(TWasserzeichen_Form, Wasserzeichen_Form);
  Application.CreateForm(TZusatz_Form, Zusatz_Form);
  Application.CreateForm(TSplashscreen_Form, Splashscreen_Form);
  Application.CreateForm(TDateianlage_Form, Dateianlage_Form);
  Application.CreateForm(TStatus_Form, Status_Form);
  Application.CreateForm(TSuche_Form, Suche_Form);
  Application.CreateForm(TAnleitung_Form, Anleitung_Form);
  Application.CreateForm(TSuche_Info, Suche_Info);

  if PDFTabsWindow = nil then
    PDFTabsWindow := TPDFTabsForm.Create(Application);
  PDFTabsWindow.HandleNeeded;

  if PDFModus then
  begin
    // Zuerst den regulaeren Hauptprogramm-Kontext initialisieren,
    // erst danach den ersten PDF-Tab erzeugen.
    PDFBrowserForm := nil;
    for I := 0 to PDFDateien.Count - 1 do
    begin
      PDFBrowserForm := TPDFBrowserForm.Create(Application);
      PDFBrowserForm.PDFFileName := PDFDateien[I];
      PDFBrowserForm.StandalonePDFMode := False;
      PDFTabsWindow.AddPDF(PDFBrowserForm);
    end;
    if PDFBrowserForm <> nil then
      PDFTabsWindow.ActivatePDF(PDFBrowserForm);
    PDFTabsWindow.Show;
  end;

  if hPDFStartMutex <> 0 then
  begin
    ReleaseMutex(hPDFStartMutex);
    CloseHandle(hPDFStartMutex);
    hPDFStartMutex := 0;
  end;

  try
    Application.Run;
  finally
    Application.OnException := nil;
    ExceptionHandler.Free;
  end;

  if hMutex <> 0 then
    CloseHandle(hMutex);
  except
    // Auch Exceptions waehrend der Formularinitialisierung abfangen.
    // Der betroffene Startvorgang wird dann ohne Fehlerdialog beendet.
    on E: EAccessViolation do
      ;
  end;
  finally
    // Auch beim vorzeitigen Abbruch der Initialisierung freigeben.
    if hPDFStartMutex <> 0 then
    begin
      ReleaseMutex(hPDFStartMutex);
      CloseHandle(hPDFStartMutex);
    end;
    PDFDateien.Free;
  end;
end.
