program FreePDF64;

uses
  Winapi.Windows,
  Winapi.Messages,
  uPortableViewerLauncher in 'uPortableViewerLauncher.pas',
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
  FreePDF64PrinterConfig in '..\FreePDF64_PostScriptPrinter\Source\FreePDF64PrinterConfig.pas';


const
  MainProgramWindowMarker = 'FreePDF64.MainProgram.Window.v1';
  WM_ACTIVATE_FREEPDF_MAIN = $8000 + 194;

function FindMainProgramWindow(Wnd: HWND; Data: LPARAM): BOOL; stdcall;
begin
  Result := True;
  if GetProp(Wnd, PChar(MainProgramWindowMarker)) <> 0 then
  begin
    PHandle(Data)^ := Wnd;
    Result := False;
  end;
end;

function ActivateRunningMainProgram: Boolean;
var
  Wnd: HWND;
  TargetPID: DWORD;
begin
  Wnd := 0;
  EnumWindows(@FindMainProgramWindow, LPARAM(@Wnd));
  Result := (Wnd <> 0) and IsWindow(Wnd);
  if not Result then Exit;
  TargetPID := 0;
  GetWindowThreadProcessId(Wnd, @TargetPID);
  if TargetPID <> 0 then
    AllowSetForegroundWindow(TargetPID);
  PostMessage(Wnd, WM_ACTIVATE_FREEPDF_MAIN, 0, 0);
end;

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
  MutexName: string;
  ForceMainMode: Boolean;
  PDFDatei: string;
  PDFModus: Boolean;
  EmptyIndependentViewer: Boolean;
  PDFDateien: TStringList;
  I: Integer;
  ExceptionHandler: TPDFExceptionHandler;
begin
  hMutex := 0;
  // Wurde FreePDF64 mit einem PDF-Dateipfad gestartet
  // (z. B. durch Doppelklick im Windows-Explorer)?
  PDFDatei := '';
  PDFModus := False;
  EmptyIndependentViewer := False;
  ForceMainMode := False;

  PDFDateien := TStringList.Create;
  try
    for I := 1 to ParamCount do
    begin
      if SameText(ParamStr(I), '--main') then
      begin
        ForceMainMode := True;
        Continue;
      end;
      if SameText(ParamStr(I), '--viewer-empty') then
      begin
        EmptyIndependentViewer := True;
        Continue;
      end;
      if SameText(ParamStr(I), '--viewer-independent') then
      begin
        Continue;
      end;
      PDFDatei := ExpandFileName(ParamStr(I));
      if SameText(ExtractFileExt(PDFDatei), '.pdf') and FileExists(PDFDatei) then
        PDFDateien.Add(PDFDatei);
    end;
    PDFModus := ((PDFDateien.Count > 0) or EmptyIndependentViewer) and
      not ForceMainMode;

    // PDF-Dateien niemals im Hauptprozess darstellen.
    if PDFModus then
    begin
      for I := 0 to PDFDateien.Count - 1 do
        OpenPDFPortable(PDFDateien[I]);
      if EmptyIndependentViewer and (PDFDateien.Count = 0) then
        OpenPortableViewer;
      Halt(0);
    end;

  begin
    MutexName := 'Local\FreePDF64_MainProgram_SingleInstance_v2';
    hMutex := CreateMutex(nil, True, PChar(MutexName));
    if hMutex = 0 then
    begin
      MessageBox(0, 'Die Instanzpruefung konnte nicht initialisiert werden.',
        'FreePDF64', MB_ICONERROR or MB_OK);
      Halt(1);
    end;
    if GetLastError = ERROR_ALREADY_EXISTS then
    begin
      CloseHandle(hMutex);
      // Bei parallelem Start kann das Hauptfenster noch im Aufbau sein.
      for I := 1 to 40 do
      begin
        if ActivateRunningMainProgram then Break;
        Sleep(100);
      end;
      Halt(0);
    end;
  end;

  try
  Application.Initialize;
  // Nur der eigenstaendige Explorer-Prozess beendet sich mit dem letzten PDF.
  // Ein regulaer gestartetes Hauptprogramm bleibt im Speicher.
  ExceptionHandler := TPDFExceptionHandler.Create;
  Application.OnException := ExceptionHandler.HandleException;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'FreePDF64';

  // PDF-Dateien werden vor der Initialisierung bereits an den externen
  // FreePDF64ViewerPortable weitergeleitet. Hier startet nur das Hauptprogramm.

  Application.CreateForm(TFreePDF64_Form, FreePDF64_Form);
  SetProp(FreePDF64_Form.Handle, PChar('FreePDF64.MainProgram.Window.v1'), THandle(1));
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
    PDFDateien.Free;
  end;
end.
