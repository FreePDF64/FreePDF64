//
// Programmname: FreePDF64
//

unit uPDFBrowserForm;

interface

{$I ..\..\WebView4Delphi-main\source\webview2.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Clipbrd, Math,
  IniFiles, uWVBrowser, uWVWinControl, uWVWindowParent, uWVTypes,
  uWVConstants, uWVTypeLibrary, uWVLibFunctions, uWVLoader,
  uWVInterfaces, uWVCoreWebView2Args, uWVBrowserBase, Menus;

type
  TPDFBrowserForm = class(TForm)
    TimerPDF: TTimer;
    WVWindowParentPDF: TWVWindowParent;
    WVBrowserPDF: TWVBrowser;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure TimerPDFTimer(Sender: TObject);
    procedure WVBrowserPDFAfterCreated(Sender: TObject);
    procedure WVBrowserPDFInitializationError(Sender: TObject;
      aErrorCode: HRESULT; const aErrorMessage: wvstring);
    procedure FormResize(Sender: TObject);

  protected
    procedure WMMove(var aMessage: TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage: TMessage); message WM_MOVING;

    function IsShortCut(var Message: TWMKey): Boolean; override;

  private
    FBrowserCreateStarted: Boolean;
    FBrowserCreated: Boolean;
    FClosing: Boolean;
    FToolbar: TPanel;
    FPageLabel: TLabel;
    FPageEdit: TEdit;
    FGoPageButton: TButton;
    FFindButton: TButton;
    FPageNavigationTimer: TTimer;
    FSearchTerm: string;
    FStartPage: Integer;
    FStandalonePDFMode: Boolean;
    FStandaloneHintShown: Boolean;

    FRotatePageEdit: TEdit;
    FRotateAngleCombo: TComboBox;
    FRotateButton: TButton;

    procedure RotatePageClick(Sender: TObject);
    function ExecuteQpdf(const ACommandLine: string; out AExitCode: DWORD): Boolean;

    procedure StartBrowser;
    procedure BuildNavigationToolbar;
    procedure GoToPageClick(Sender: TObject);
    procedure FindTermClick(Sender: TObject);
    procedure ToggleAttachmentsClick(Sender: TObject);
    procedure PageNavigationTimerTimer(Sender: TObject);
    function BuildPdfUrl(const APage: Integer): string;
    procedure UpdateAttachmentWindowPosition;

  public
    FAttachmentsButton: TButton;
    // HWND des Anlagenfensters, das zu genau dieser PDF-Ansicht gehört.
    AttachmentWindowHandle: HWND;
    PDFFileName: string;
    property SearchTerm: string read FSearchTerm write FSearchTerm;
    property StartPage: Integer read FStartPage write FStartPage;
    // True, wenn die PDF direkt per Kommandozeile/Explorer gestartet wurde.
    property StandalonePDFMode: Boolean read FStandalonePDFMode write FStandalonePDFMode;
  end;

implementation

{$R *.dfm}

function TPDFBrowserForm.ExecuteQpdf(
  const ACommandLine: string;
  out AExitCode: DWORD): Boolean;
var
  LStartupInfo: TStartupInfo;
  LProcessInfo: TProcessInformation;
  LCommandLine: string;
begin
  Result := False;
  AExitCode := DWORD(-1);

  FillChar(LStartupInfo, SizeOf(LStartupInfo), 0);
  FillChar(LProcessInfo, SizeOf(LProcessInfo), 0);

  LStartupInfo.cb := SizeOf(LStartupInfo);
  LCommandLine := ACommandLine;

  if not CreateProcess(
    nil,
    PChar(LCommandLine),
    nil,
    nil,
    False,
    CREATE_NO_WINDOW,
    nil,
    PChar(ExtractFilePath(Application.ExeName)),
    LStartupInfo,
    LProcessInfo
  ) then
    Exit;

  try
    WaitForSingleObject(LProcessInfo.hProcess, INFINITE);

    Result := GetExitCodeProcess(
      LProcessInfo.hProcess, AExitCode);
  finally
    CloseHandle(LProcessInfo.hThread);
    CloseHandle(LProcessInfo.hProcess);
  end;
end;

procedure TPDFBrowserForm.RotatePageClick(Sender: TObject);
var
  LPageRange: string;
  LPageStart: Integer;
  LPageEnd: Integer;
  LDashPos: Integer;
  LAngle: Integer;
  LRotateArg: string;
  LTempFile: string;
  LBackupFile: string;
  LQpdfExe: string;
  LParams: string;
  LStartupInfo: TStartupInfo;
  LProcessInfo: TProcessInformation;
  LExitCode: DWORD;
begin
  // --------------------------------------------------
  // Seitennummer oder Seitenbereich prüfen
  // Beispiele: 3 oder 1-5
  // --------------------------------------------------
  LPageRange := Trim(FRotatePageEdit.Text);

  if LPageRange = '' then
  begin
    MessageDlg(
      'Bitte eine Seitennummer oder einen Seitenbereich eingeben, ' +
      'z. B. 3 oder 1-5.',
      mtWarning, [mbOK], 0
    );
    FRotatePageEdit.SetFocus;
    Exit;
  end;

  LDashPos := Pos('-', LPageRange);

  if LDashPos = 0 then
  begin
    // Einzelne Seite
    if not TryStrToInt(LPageRange, LPageStart) or
       (LPageStart < 1) then
    begin
      MessageDlg(
        'Ungültige Seitennummer. Beispiel: 3 oder 1-5.',
        mtWarning, [mbOK], 0
      );
      FRotatePageEdit.SetFocus;
      Exit;
    end;
  end
  else
  begin
    // Seitenbereich
    if (LDashPos = 1) or
       (LDashPos = Length(LPageRange)) or
       (Pos('-', Copy(LPageRange, LDashPos + 1, MaxInt)) > 0) or
       not TryStrToInt(
         Trim(Copy(LPageRange, 1, LDashPos - 1)),
         LPageStart
       ) or
       not TryStrToInt(
         Trim(Copy(LPageRange, LDashPos + 1, MaxInt)),
         LPageEnd
       ) or
       (LPageStart < 1) or
       (LPageEnd < LPageStart) then
    begin
      MessageDlg(
        'Ungültiger Seitenbereich. Beispiel: 1-5.',
        mtWarning, [mbOK], 0
      );
      FRotatePageEdit.SetFocus;
      Exit;
    end;
  end;

  // --------------------------------------------------
  // Drehwinkel aus der ComboBox lesen
  // --------------------------------------------------
  if FRotateAngleCombo.ItemIndex < 0 then
  begin
    MessageDlg(
      'Bitte einen Drehwinkel auswählen.',
      mtWarning, [mbOK], 0
    );
    FRotateAngleCombo.SetFocus;
    Exit;
  end;

  if not TryStrToInt(
    StringReplace(
      FRotateAngleCombo.Text, '°', '', [rfReplaceAll]
    ),
    LAngle
  ) then
  begin
    MessageDlg(
      'Der ausgewählte Drehwinkel ist ungültig.',
      mtWarning, [mbOK], 0
    );
    FRotateAngleCombo.SetFocus;
    Exit;
  end;

  if (LAngle <> 90) and
     (LAngle <> 180) and
     (LAngle <> 270) then
  begin
    MessageDlg(
      'Erlaubte Drehwinkel sind 90°, 180° und 270°.',
      mtWarning, [mbOK], 0
    );
    Exit;
  end;

  // --------------------------------------------------
  // Prüfen, ob eine PDF-Datei geöffnet ist
  // --------------------------------------------------
  if (Trim(PDFFileName) = '') or
     not FileExists(PDFFileName) then
  begin
    MessageDlg(
      'Die PDF-Datei wurde nicht gefunden.',
      mtWarning, [mbOK], 0
    );
    Exit;
  end;

  // --------------------------------------------------
  // Drehwinkel für qpdf festlegen
  // --------------------------------------------------
  case LAngle of
    90:  LRotateArg := '+90';
    180: LRotateArg := '+180';
    270: LRotateArg := '-90';
  else
    Exit;
  end;

  // --------------------------------------------------
  // qpdf-Pfad und temporäre Ausgabedatei
  // --------------------------------------------------
  LQpdfExe := IncludeTrailingPathDelimiter(
    ExtractFilePath(Application.ExeName)
  ) + 'qpdf\bin\qpdf.exe';

  LTempFile := PDFFileName + '.qpdf_tmp.pdf';

  if not FileExists(LQpdfExe) then
  begin
    MessageDlg(
      'qpdf wurde nicht gefunden:' + sLineBreak + LQpdfExe,
      mtError, [mbOK], 0
    );
    Exit;
  end;

  if FileExists(LTempFile) then
    DeleteFile(LTempFile);

  // --------------------------------------------------
  // qpdf-Parameter: einzelne Seite oder Seitenbereich
  // --------------------------------------------------
  LParams :=
    '--rotate=' + LRotateArg + ':' + LPageRange +
    ' "' + PDFFileName + '"' +
    ' "' + LTempFile + '"';

  // --------------------------------------------------
  // qpdf starten
  // --------------------------------------------------
  FillChar(LStartupInfo, SizeOf(LStartupInfo), 0);
  FillChar(LProcessInfo, SizeOf(LProcessInfo), 0);
  LStartupInfo.cb := SizeOf(LStartupInfo);

  if not CreateProcess(
    PChar(LQpdfExe),
    PChar('"' + LQpdfExe + '" ' + LParams),
    nil,
    nil,
    False,
    CREATE_NO_WINDOW,
    nil,
    PChar(ExtractFilePath(LQpdfExe)),
    LStartupInfo,
    LProcessInfo
  ) then
  begin
    MessageDlg(
      'qpdf konnte nicht gestartet werden.',
      mtError, [mbOK], 0
    );
    Exit;
  end;

  try
    WaitForSingleObject(LProcessInfo.hProcess, INFINITE);

    LExitCode := 1;
    GetExitCodeProcess(LProcessInfo.hProcess, LExitCode);
  finally
    CloseHandle(LProcessInfo.hThread);
    CloseHandle(LProcessInfo.hProcess);
  end;

  // --------------------------------------------------
  // Ergebnis prüfen
  // --------------------------------------------------
  if (LExitCode <> 0) or not FileExists(LTempFile) then
  begin
    MessageDlg(
      'Die PDF-Seite(n) konnten nicht gedreht werden.',
      mtError, [mbOK], 0
    );

    if FileExists(LTempFile) then
      DeleteFile(LTempFile);

    Exit;
  end;

  // --------------------------------------------------
  // Originaldatei beim ersten Drehen sichern
  // Beispiel: Dokument.pdf -> Dokument_BAK.pdf
  // --------------------------------------------------
  LBackupFile := ChangeFileExt(
    PDFFileName,
    '_BAK' + ExtractFileExt(PDFFileName)
  );

  if not FileExists(LBackupFile) then
  begin
    if not CopyFile(
      PChar(PDFFileName),
      PChar(LBackupFile),
      True
    ) then
    begin
      MessageDlg(
        'Die Original-PDF konnte nicht gesichert werden.' +
        sLineBreak +
        'Die Drehung wurde nicht gespeichert.' +
        sLineBreak + LBackupFile,
        mtError, [mbOK], 0
      );

      if FileExists(LTempFile) then
        DeleteFile(LTempFile);

      Exit;
    end;
  end;

  // --------------------------------------------------
  // Bearbeitete PDF als Originaldatei speichern
  // --------------------------------------------------
  if not MoveFileEx(
    PChar(LTempFile),
    PChar(PDFFileName),
    MOVEFILE_REPLACE_EXISTING or MOVEFILE_COPY_ALLOWED
  ) then
  begin
    MessageDlg(
      'Die bearbeitete PDF konnte nicht gespeichert werden.' +
      sLineBreak +
      'Möglicherweise ist die Datei noch geöffnet oder schreibgeschützt.',
      mtError, [mbOK], 0
    );
    Exit;
  end;

  // --------------------------------------------------
  // PDF im WebView2 neu laden
  // --------------------------------------------------
  TimerPDF.Enabled := False;
  WVBrowserPDF.Navigate('about:blank');
  TimerPDF.Interval := 500;
  TimerPDF.Enabled := True;
end;

procedure TPDFBrowserForm.FormCreate(Sender: TObject);
var
  IniDat: TIniFile;
begin
  Position := poDesigned;

  FBrowserCreateStarted := False;
  FBrowserCreated := False;
  FClosing := False;
  FStandalonePDFMode := False;
  FStandaloneHintShown := False;
  AttachmentWindowHandle := 0;
  FStartPage := 1;
  FSearchTerm := '';
  BuildNavigationToolbar;

  IniDat := TIniFile.Create(
    ExtractFilePath(Application.ExeName) + 'FreePDF64.ini');
  try
    Left   := IniDat.ReadInteger('Position', 'PDFBrowserForm_Left', Left);
    Top    := IniDat.ReadInteger('Position', 'PDFBrowserForm_Top', Top);
    Width  := IniDat.ReadInteger('Position', 'PDFBrowserForm_Width', Width);
    Height := IniDat.ReadInteger('Position', 'PDFBrowserForm_Height', Height);
  finally
    IniDat.Free;
  end;
end;

procedure TPDFBrowserForm.UpdateAttachmentWindowPosition;
var
  WorkArea: TRect;
  AttachmentRect: TRect;
  NewLeft: Integer;
begin
  if (AttachmentWindowHandle = 0) or
     not IsWindow(AttachmentWindowHandle) then
    Exit;

  if not IsWindowVisible(AttachmentWindowHandle) then
    Exit;

  if not GetWindowRect(AttachmentWindowHandle, AttachmentRect) then
    Exit;

  WorkArea := Screen.MonitorFromWindow(Handle).WorkareaRect;

  // Linken Rand der PDFForm übernehmen.
  NewLeft := Left;

  // Innerhalb des Bildschirmarbeitsbereichs bleiben.
  if NewLeft < WorkArea.Left then
    NewLeft := WorkArea.Left;

  if NewLeft + (AttachmentRect.Right - AttachmentRect.Left) >
     WorkArea.Right then
    NewLeft := WorkArea.Right -
      (AttachmentRect.Right - AttachmentRect.Left);

  // Nur horizontal verschieben; Größe und Höhe bleiben erhalten.
  SetWindowPos(
    AttachmentWindowHandle,
    0,
    NewLeft,
    AttachmentRect.Top,
    0,
    0,
    SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE
  );
end;

procedure TPDFBrowserForm.FormResize(Sender: TObject);
begin
  UpdateAttachmentWindowPosition;
end;

procedure TPDFBrowserForm.BuildNavigationToolbar;
var
  LLabel: TLabel;
begin
  FToolbar := TPanel.Create(Self);
  FToolbar.Name := 'PDFNavigationToolbar';
  FToolbar.Caption := '';
  FToolbar.Parent := Self;
  FToolbar.Align := alTop;
  FToolbar.Height := 42;
  FToolbar.BevelOuter := bvNone;

  // --------------------------------------------------
  // Seitennavigation
  // --------------------------------------------------
  FPageLabel := TLabel.Create(Self);
  FPageLabel.Parent := FToolbar;
  FPageLabel.Caption := 'Seite:';
  FPageLabel.Left := 8;
  FPageLabel.Top := 11;
  FPageLabel.AutoSize := True;

  FPageEdit := TEdit.Create(Self);
  FPageEdit.Parent := FToolbar;
  FPageEdit.Name := 'PDFPageNumberEdit';
  FPageEdit.Left := 48;
  FPageEdit.Top := 8;
  FPageEdit.Width := 42;
  FPageEdit.Text := '1';
  FPageEdit.NumbersOnly := True;

  FGoPageButton := TButton.Create(Self);
  FGoPageButton.Parent := FToolbar;
  FGoPageButton.Caption := 'Gehe zu';
  FGoPageButton.Left := 96;
  FGoPageButton.Top := 6;
  FGoPageButton.Width := 76;
  FGoPageButton.Height := 28;
  FGoPageButton.OnClick := GoToPageClick;

  // --------------------------------------------------
  // Textsuche
  // --------------------------------------------------
  FFindButton := TButton.Create(Self);
  FFindButton.Parent := FToolbar;
  FFindButton.Caption := 'Text suchen';
  FFindButton.ShowHint := True;
  FFindButton.Hint := 'Siehe Suchmaske [Text suchen] im Suchefenster von FreePDF64';
  FFindButton.Left := 178;
  FFindButton.Top := 6;
  FFindButton.Width := 94;
  FFindButton.Height := 28;
  FFindButton.OnClick := FindTermClick;

  // --------------------------------------------------
  // PDF-Anlagen
  // --------------------------------------------------
  FAttachmentsButton := TButton.Create(Self);
  FAttachmentsButton.Parent := FToolbar;
  FAttachmentsButton.Caption := 'PDF-Anlagen';
  FAttachmentsButton.ShowHint := True;
  FAttachmentsButton.Hint := 'Öffnen/Schließen der Anlagenliste zur PDF-Datei:' + #13 + 'Ein "->" bedeutet Anlage(n) vorhanden';
  FAttachmentsButton.Left := 278;
  FAttachmentsButton.Top := 6;
  FAttachmentsButton.Width := 112;
  FAttachmentsButton.Height := 28;
  FAttachmentsButton.OnClick := ToggleAttachmentsClick;

  // --------------------------------------------------
  // Seitennummer für die Drehung
  // --------------------------------------------------
  LLabel := TLabel.Create(Self);
  LLabel.Parent := FToolbar;
  LLabel.Caption := 'Drehe Seite:';
  LLabel.ShowHint := True;
  LLabel.Hint := 'Eine Seite oder einen Bereich eingeben:' + #13 + '1-3 oder 5-20 oder...';
  LLabel.Left := 408;
  LLabel.Top := 11;
  LLabel.AutoSize := True;

  FRotatePageEdit := TEdit.Create(Self);
  FRotatePageEdit.Parent := FToolbar;
  FRotatePageEdit.Name := 'PDFRotatePageEdit';
  FRotatePageEdit.Left := 493;
  FRotatePageEdit.Top := 8;
  FRotatePageEdit.Width := 42;
  FRotatePageEdit.Text := '1';
  FRotatePageEdit.NumbersOnly := False;
  FRotatePageEdit.Text := '1';

  // --------------------------------------------------
  // Drehwinkel als feste Auswahl
  // --------------------------------------------------
  LLabel := TLabel.Create(Self);
  LLabel.Parent := FToolbar;
  LLabel.Caption := 'Winkel:';
  LLabel.ShowHint := True;
  LLabel.Hint := 'Um wieviel Grad man die Seite(n) drehen möchte';
  LLabel.Left := 540;
  LLabel.Top := 11;
  LLabel.AutoSize := True;

  FRotateAngleCombo := TComboBox.Create(Self);
  FRotateAngleCombo.Parent := FToolbar;
  FRotateAngleCombo.Name := 'PDFRotateAngleCombo';
  FRotateAngleCombo.Left := 590;
  FRotateAngleCombo.Top := 7;
  FRotateAngleCombo.Width := 68;
  FRotateAngleCombo.Height := 28;
  FRotateAngleCombo.Style := csDropDownList;
  FRotateAngleCombo.Items.Add('90°');
  FRotateAngleCombo.Items.Add('180°');
  FRotateAngleCombo.Items.Add('270°');
  FRotateAngleCombo.ItemIndex := 0;

  // --------------------------------------------------
  // Drehfunktion
  // --------------------------------------------------
  FRotateButton := TButton.Create(Self);
  FRotateButton.Parent := FToolbar;
  FRotateButton.Name := 'PDFRotateButton';
  FRotateButton.ShowHint := True;
  FRotateButton.Hint := 'Dreht die Seite(n) und speichert danach. Vorher wird eine BAK-Datei erstellt';
  FRotateButton.Caption := 'Drehen';
  FRotateButton.Left := 667;
  FRotateButton.Top := 6;
  FRotateButton.Width := 80;
  FRotateButton.Height := 28;
  FRotateButton.OnClick := RotatePageClick;

  // --------------------------------------------------
  // Navigationstimer - nur einmal erstellen
  // --------------------------------------------------
  FPageNavigationTimer := TTimer.Create(Self);
  FPageNavigationTimer.Enabled := False;
  FPageNavigationTimer.Interval := 180;
  FPageNavigationTimer.OnTimer := PageNavigationTimerTimer;

  // PDF-Viewer füllt den verbleibenden Platz
  WVWindowParentPDF.Align := alClient;
  WVWindowParentPDF.SendToBack;
end;

procedure TPDFBrowserForm.ToggleAttachmentsClick(Sender: TObject);
begin
  if FStandalonePDFMode then
  begin
    MessageDlg(
      'Die Anlagenliste kann über das Hauptprogramm FreePDF64 geöffnet werden.' +
      sLineBreak + sLineBreak +
      'Bitte starten Sie FreePDF64 und öffnen Sie die PDF dort, um Anlagen ' +
      'anzuzeigen, zu extrahieren, hinzuzufügen oder zu entfernen.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  // Nicht per Fenstertitel suchen: bei mehreren geöffneten PDFs würde
  // FindWindow sonst leicht das Anlagenfenster einer anderen PDF treffen.
  if (AttachmentWindowHandle = 0) or
     not IsWindow(AttachmentWindowHandle) then
  begin
    MessageDlg(
      'Das Anlagenfenster für diese PDF-Datei wurde noch nicht erstellt.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if IsWindowVisible(AttachmentWindowHandle) then
    ShowWindow(AttachmentWindowHandle, SW_HIDE)
  else
  begin
    ShowWindow(AttachmentWindowHandle, SW_SHOWNORMAL);
    SetForegroundWindow(AttachmentWindowHandle);
  end;
end;

function TPDFBrowserForm.BuildPdfUrl(const APage: Integer): string;
var
  LPath: string;
begin
  LPath := StringReplace(ExpandFileName(PDFFileName), '\', '/', [rfReplaceAll]);
  // URL-Kodierung der Leerzeichen verhindert fehlerhafte file-URLs.
  LPath := StringReplace(LPath, ' ', '%20', [rfReplaceAll]);
  Result := 'file:///' + LPath + '#page=' + IntToStr(Max(1, APage));
end;

procedure TPDFBrowserForm.GoToPageClick(Sender: TObject);
var
  LPage: Integer;
begin
  if not TryStrToInt(Trim(FPageEdit.Text), LPage) or (LPage < 1) then
  begin
    MessageDlg('Bitte eine gültige Seitenzahl ab 1 eingeben.', mtInformation, [mbOK], 0);
    FPageEdit.SetFocus;
    Exit;
  end;

  FStartPage := LPage;
  if FBrowserCreated and not FClosing then
  begin
    // Ein Zwischenaufruf verhindert, dass WebView2 eine reine Fragment-
    // Änderung bei derselben PDF-Datei ignoriert.
    FPageNavigationTimer.Enabled := False;
    WVBrowserPDF.Navigate('about:blank');
    FPageNavigationTimer.Enabled := True;
  end;
end;


procedure TPDFBrowserForm.PageNavigationTimerTimer(Sender: TObject);
begin
  FPageNavigationTimer.Enabled := False;
  if FBrowserCreated and not FClosing then
    WVBrowserPDF.Navigate(BuildPdfUrl(FStartPage));
end;


procedure TPDFBrowserForm.FindTermClick(Sender: TObject);
begin
  if Trim(FSearchTerm) = '' then
  begin
    MessageDlg('In der Suchmaske [Text suchen] ist kein Suchbegriff eingetragen.', mtInformation, [mbOK], 0);
    Exit;
  end;

  // Der Edge-PDF-Viewer besitzt eine eigene Suche (Strg+F).
  // WebView2 bietet keine stabile öffentliche API, um interne PDF-Treffer
  // direkt zu markieren. Deshalb wird die integrierte Suchoberfläche geöffnet.
  Clipboard.AsText := FSearchTerm;

  // Den Fokus möglichst direkt an die WebView geben, nicht nur an
  // deren Parent-Window. Die Suche selbst wird vom Edge-PDF-Viewer
  // über Strg+F bereitgestellt.
  BringToFront;
  SetForegroundWindow(Handle);
  if WVWindowParentPDF.HandleAllocated then
    Winapi.Windows.SetFocus(WVWindowParentPDF.Handle)
  else
    WVBrowserPDF.SetFocus;

  // Erst die Edge-Suchleiste öffnen. Die verzögerte Eingabe verhindert,
  // dass Strg+V gesendet wird, bevor die Suchleiste bereit ist.
  keybd_event(VK_CONTROL, 0, 0, 0);
  keybd_event(Ord('F'), 0, 0, 0);
  keybd_event(Ord('F'), 0, KEYEVENTF_KEYUP, 0);
  keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);

  Sleep(250);

  keybd_event(VK_CONTROL, 0, 0, 0);
  keybd_event(Ord('V'), 0, 0, 0);
  keybd_event(Ord('V'), 0, KEYEVENTF_KEYUP, 0);
  keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);
end;


procedure TPDFBrowserForm.FormShow(Sender: TObject);
begin
  // Dateiname inklusive Verzeichnis in der Titelleiste anzeigen
  Caption := PDFFileName;

  // Formular wird angezeigt -> noch nicht im Schließvorgang.
  FClosing := False;

  StartBrowser;

  // PDF-Fenster aktiv nach vorne holen.
  BringToFront;
  SetForegroundWindow(Handle);

  // Fokus auf das Formular selbst setzen
  Self.ActiveControl := FPageEdit;
  FPageEdit.SetFocus;
end;


procedure TPDFBrowserForm.StartBrowser;
begin
  // Formular befindet sich bereits im Schließvorgang.
  if FClosing then
    Exit;

  // Pro Formular darf CreateBrowser nur einmal gestartet werden.
  if FBrowserCreateStarted then
    Exit;

  if GlobalWebView2Loader.InitializationError then
  begin
    ShowMessage(GlobalWebView2Loader.ErrorMessage);
    Exit;
  end;

  if GlobalWebView2Loader.Initialized then
  begin
    // WICHTIG:
    // Vor CreateBrowser setzen.
    // Dadurch kann FormShow/TimerPDFTimer nicht nochmals
    // CreateBrowser für dasselbe Formular ausführen.
    FBrowserCreateStarted := True;

    WVBrowserPDF.CreateBrowser(WVWindowParentPDF.Handle);

  end
  else
  begin
    TimerPDF.Enabled := True;
  end;
end;

procedure TPDFBrowserForm.TimerPDFTimer(Sender: TObject);
begin
  TimerPDF.Enabled := False;

  // Formular wurde inzwischen geschlossen.
  if FClosing then
    Exit;

  // WebView2-Initialisierung prüfen.
  if GlobalWebView2Loader.InitializationError then
  begin
    ShowMessage(GlobalWebView2Loader.ErrorMessage);
    Exit;
  end;

  // Browser wurde bereits erstellt:
  // PDF erneut laden, statt StartBrowser erneut aufzurufen.
  if FBrowserCreateStarted then
  begin
    if Assigned(WVBrowserPDF) and (PDFFileName <> '') and FileExists(PDFFileName) then
       WVBrowserPDF.Navigate('file:///' + StringReplace(ExpandFileName(PDFFileName), '\', '/', [rfReplaceAll]));
    Exit;
  end;

  // Browser noch nicht erstellt: Initialisierung abwarten.
  if GlobalWebView2Loader.Initialized then
    StartBrowser
  else
    TimerPDF.Enabled := True;
end;

procedure TPDFBrowserForm.WVBrowserPDFAfterCreated(Sender: TObject);
begin
  // Sehr wichtig:
  // Falls CreateBrowser noch abgeschlossen wurde, nachdem
  // der Benutzer das PDF-Fenster bereits geschlossen hat,
  // darf hier nichts mehr mit dem Formular gemacht werden.
  if FClosing then
    Exit;

  FBrowserCreated := True;

  WVWindowParentPDF.UpdateSize;

  if FStartPage < 1 then
    FStartPage := 1;
  FPageEdit.Text := IntToStr(FStartPage);
  WVBrowserPDF.Navigate(BuildPdfUrl(FStartPage));

  // Das PDF-Fenster soll aktiv sein.
  BringToFront;
  SetForegroundWindow(Handle);

  // Tastaturfokus auf das WebView2-Parent-Fenster.
  if WVWindowParentPDF.HandleAllocated then
    Winapi.Windows.SetFocus(WVWindowParentPDF.Handle);
end;

function TPDFBrowserForm.IsShortCut(var Message: TWMKey): Boolean;
begin
  // Keine Tastenkombinationen pauschal verschlucken.
  // Insbesondere muss Strg+F an den Edge-PDF-Viewer gelangen können.
  Result := inherited IsShortCut(Message);
end;

procedure TPDFBrowserForm.WVBrowserPDFInitializationError(
  Sender: TObject; aErrorCode: HRESULT;
  const aErrorMessage: wvstring);
begin
  // Formular befindet sich bereits im Schließvorgang.
  if FClosing then
    Exit;

  FBrowserCreated := False;

  ShowMessage(aErrorMessage);
end;


procedure TPDFBrowserForm.FormClose(
  Sender: TObject; var Action: TCloseAction);
var
  IniDat: TIniFile;
begin
  // Ab jetzt dürfen keine weiteren Timer-/AfterCreated-Aktionen
  // mehr mit diesem Formular arbeiten.
  FClosing := True;

  TimerPDF.Enabled := False;
  if Assigned(FPageNavigationTimer) then
    FPageNavigationTimer.Enabled := False;

  IniDat := TIniFile.Create(
    ExtractFilePath(Application.ExeName) + 'FreePDF64.ini');
  try
    IniDat.WriteInteger(
      'Position',
      'PDFBrowserForm_Left',
      Left);

    IniDat.WriteInteger(
      'Position',
      'PDFBrowserForm_Top',
      Top);

    IniDat.WriteInteger(
      'Position',
      'PDFBrowserForm_Width',
      Width);

    IniDat.WriteInteger(
      'Position',
      'PDFBrowserForm_Height',
      Height);
  finally
    IniDat.Free;
  end;

  // Die Form selbst wird freigegeben.
  //
  // Dabei werden die darin enthaltenen VCL-Komponenten
  // einschließlich WVBrowserPDF und WVWindowParentPDF
  // über den normalen Delphi-Komponenten-Lebenszyklus
  // ebenfalls freigegeben.
  Action := caFree;
end;

procedure TPDFBrowserForm.WMMove(var aMessage: TWMMove);
begin
  inherited;

  if (WVBrowserPDF <> nil) and not FClosing then
    WVBrowserPDF.NotifyParentWindowPositionChanged;

  UpdateAttachmentWindowPosition;
end;

procedure TPDFBrowserForm.WMMoving(var aMessage: TMessage);
begin
  inherited;

  if (WVBrowserPDF <> nil) and not FClosing then
    WVBrowserPDF.NotifyParentWindowPositionChanged;
end;

initialization
  GlobalWebView2Loader := TWVLoader.Create(nil);

  GlobalWebView2Loader.UserDataFolder :=
    ExtractFileDir(Application.ExeName) + '\CustomCache';

  GlobalWebView2Loader.StartWebView2;

end.

