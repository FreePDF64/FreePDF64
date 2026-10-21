// FreePDF64 - PDFium-only PDF-Anzeige (ohne WebView4Delphi)
unit uPDFBrowserForm;
interface
uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ComCtrls, Math, IniFiles, uFreePDF64PDFiumView, Menus;
type
  TPDFBrowserForm = class(TForm)
    TimerPDF: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TimerPDFTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMMove(var aMessage: TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage: TMessage); message WM_MOVING;
  private
    FPDFiumView: TFreePDF64PDFiumView;
    FLoadingHintWnd: HWND;
    FLoadingHintFont: HFONT;
    FLoadRequested: Boolean;
    FPDFLoadInProgress: Boolean;
    FNavigationDone: Boolean;
    FNavigationSucceeded: Boolean;
    FPendingFirstDisplay: Boolean;
    FClosing: Boolean;
    FToolbar: TPanel;
    FFindButton: TButton;
    FSearchCountLabel: TLabel;
    FPageNavigationTimer: TTimer;
    FSearchTerm: string;
    FStartPage: Integer;
    FTabbedPDFMode: Boolean;
    FStandalonePDFMode: Boolean;
    FStandaloneHintShown: Boolean;
    FRotatePageEdit: TEdit;
    FRotateAngleCombo: TComboBox;
    FRotateButton: TButton;
    procedure SetLoadingHint(AVisible: Boolean);
    procedure RotatePageClick(Sender: TObject);
    procedure MarkerClick(Sender: TObject);
    function ExecuteQpdf(const ACommandLine: string; out AExitCode: DWORD): Boolean;
    procedure BuildNavigationToolbar;
    procedure NumberFieldMouseEnter(Sender: TObject);
    procedure FindTermClick(Sender: TObject);
    procedure UpdateSearchCount(Sender: TObject);
    procedure SetSearchTerm(const AValue: string);
    procedure ToggleAttachmentsClick(Sender: TObject);
    procedure PageNavigationTimerTimer(Sender: TObject);
  public
    FAttachmentsButton: TButton;
    AttachmentWindowHandle: HWND;
    PDFFileName: string;
    function IsShortCut(var Message: TWMKey): Boolean; override;
    procedure UpdateAttachmentWindowPosition;
    procedure RefreshActiveTabPDF;
    procedure OpenSavedPDF(const AFileName: string; AHasAttachments: Boolean);
    procedure SetAttachmentIndicator(AHasAttachments: Boolean);
    procedure RequestPDFLoad;
    procedure ShowPDFSearch;
    procedure NextPDFSearchMatch(ADirection: Integer);
    procedure SelectAllPDFText;
    procedure CopyPDFText;
    procedure SetFullScreenDisplay(AEnabled: Boolean);
    property PDFNavigationStarted: Boolean read FNavigationDone;
    property PDFNavigationSucceeded: Boolean read FNavigationSucceeded;
    property TabbedPDFMode: Boolean read FTabbedPDFMode write FTabbedPDFMode;
    property SearchTerm: string read FSearchTerm write SetSearchTerm;
    property StartPage: Integer read FStartPage write FStartPage;
    property StandalonePDFMode: Boolean read FStandalonePDFMode write FStandalonePDFMode;
  end;
implementation
{$R *.dfm}
procedure TPDFBrowserForm.SetFullScreenDisplay(AEnabled: Boolean);
begin
  if FToolbar <> nil then
    FToolbar.Visible := not AEnabled;
  if FPDFiumView <> nil then
    FPDFiumView.SetFullScreenDisplay(AEnabled);
end;

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

  // PDFium: direkt drehen und mit PDFium speichern, ohne qpdf.
  if FPDFiumView <> nil then
  begin
    if LDashPos = 0 then LPageEnd := LPageStart;
    try
      FPDFiumView.RotatePages(LPageStart, LPageEnd, LAngle);
    except
      on E: Exception do
        MessageDlg('Die PDF-Seiten konnten nicht gedreht werden:' +
          sLineBreak + E.Message, mtError, [mbOK], 0);
    end;
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

  // PDFium haelt die Quelldatei ggf. noch offen. Vor dem Ersetzen
  // Dokumenthandle freigeben; danach die neue Datei laden.
  if FPDFiumView <> nil then
  begin
    if not FPDFiumView.ConfirmUnsaved then
    begin
      DeleteFile(LTempFile);
      Exit;
    end;
    FPDFiumView.ReleasePDFForExternalChange;
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
    if FPDFiumView <> nil then
      FPDFiumView.OpenPDF(PDFFileName);
    Exit;
  end;

  // Bei PDFium sofort die gedrehte Datei laden und die bisherige
  // Seite beibehalten. WebView2-Fallback bleibt darunter unveraendert.
  if FPDFiumView <> nil then
  begin
    try
      FPDFiumView.OpenPDF(PDFFileName);
      FPDFiumView.ShowPage(LPageStart - 1);
    except
      on E: Exception do
        MessageDlg('Die Drehung wurde gespeichert, aber die PDF-Anzeige ' +
          'konnte nicht aktualisiert werden:' + sLineBreak + E.Message,
          mtError, [mbOK], 0);
    end;
    Exit;
  end;

end;

procedure TPDFBrowserForm.UpdateAttachmentWindowPosition;
const
  EdgeGap = 12;
  HeightPercent = 72;
var
  ViewRect, AttachmentRect: TRect;
  NewLeft, NewTop, NewHeight, NewWidth: Integer;
  ViewWidth, ViewHeight: Integer;
  PDFOrigin: TPoint;
begin
  if (AttachmentWindowHandle = 0) or not IsWindow(AttachmentWindowHandle) or
     not Assigned(FPDFiumView) then Exit;
  PDFOrigin := FPDFiumView.ClientToScreen(Point(0, 0));
  ViewRect := Rect(PDFOrigin.X, PDFOrigin.Y,
    PDFOrigin.X + FPDFiumView.ClientWidth,
    PDFOrigin.Y + FPDFiumView.ClientHeight);
  ViewWidth := ViewRect.Right - ViewRect.Left;
  ViewHeight := ViewRect.Bottom - ViewRect.Top;
  if (ViewWidth <= 2 * EdgeGap) or (ViewHeight <= 2 * EdgeGap) then
    Exit;

  if not GetWindowRect(AttachmentWindowHandle, AttachmentRect) then
    Exit;

  NewWidth := Min(AttachmentRect.Right - AttachmentRect.Left,
    ViewWidth - 2 * EdgeGap);
  NewHeight := Min((ViewHeight * HeightPercent) div 100,
    ViewHeight - 2 * EdgeGap);
  // Bei kleinen PDF-Fenstern darf das Anlagenfenster nicht hinausragen.
  NewWidth := Max(1, NewWidth);
  NewHeight := Max(1, NewHeight);
  NewLeft := ViewRect.Left + EdgeGap;
  NewTop := ViewRect.Top + EdgeGap;

  SetWindowPos(AttachmentWindowHandle, 0,
    NewLeft, NewTop, NewWidth, NewHeight,
    SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure TPDFBrowserForm.BuildNavigationToolbar;
var
  LLabel: TLabel;
  RotateLabel, AngleLabel: TLabel;
  Dpi, Gap, XPos, ControlHeight, ToolbarHeight: Integer;
  function ScalePx(Value: Integer): Integer;
  begin
    Result := MulDiv(Value, Dpi, 96);
  end;
  procedure PlaceControl(C: TControl; DesiredWidth: Integer);
  var
    H: Integer;
  begin
    H := ControlHeight;
    // Beschriftungen auf die vertikale Mitte der Eingabefelder setzen.
    // TLabel.AutoSize laesst die Hoehe nicht wie bei einem TEdit strecken.
    if (C = RotateLabel) or (C = AngleLabel) then
      H := TLabel(C).Height;
    // Eingabefelder und Auswahlliste an die Hoehe der Buttons angleichen.
    // Die Mindesthoehe wird mit der DPI skaliert.
    if (C = FFindButton) or
       (C = FAttachmentsButton) or (C = FRotateButton) or

       (C = FRotatePageEdit) or
       (C = FRotateAngleCombo) then
      H := Max(ScalePx(22), ControlHeight - ScalePx(4));
    C.SetBounds(XPos, (ToolbarHeight - H) div 2, DesiredWidth, H);
    Inc(XPos, DesiredWidth + Gap);
  end;
begin
  Dpi := CurrentPPI;
  if Dpi < 96 then Dpi := 96;
  FToolbar := TPanel.Create(Self);
  FToolbar.Name := 'PDFNavigationToolbar';
  FToolbar.Caption := '';
  FToolbar.Parent := Self;
  FToolbar.Align := alTop;
  FToolbar.Height := 42;
  FToolbar.BevelOuter := bvNone;

  // --------------------------------------------------
  // Textsuche
  // --------------------------------------------------
  FFindButton := TButton.Create(Self);
  FFindButton.Parent := FToolbar;
  FFindButton.Caption := 'Text suchen (F3: weiter)';
  FFindButton.ShowHint := True;
  FFindButton.Hint := 'Strg+F: PDF-Text suchen | F3: nächster Treffer | Umschalt+F3: vorheriger Treffer';
  FFindButton.Left := 178;
  FFindButton.Top := 6;
  FFindButton.Width := 94;
  FFindButton.Height := 28;
  FFindButton.OnClick := FindTermClick;

  FSearchCountLabel := TLabel.Create(Self);
  FSearchCountLabel.Parent := FToolbar;
  FSearchCountLabel.AutoSize := True;
  FSearchCountLabel.Caption := '';
  FSearchCountLabel.Visible := False;
  FSearchCountLabel.Font.Style := [fsBold];
  FSearchCountLabel.Font.Color := clWindowText;

  // --------------------------------------------------
  // PDF-Anlagen
  // --------------------------------------------------
  FAttachmentsButton := TButton.Create(Self);
  FAttachmentsButton.Parent := FToolbar;
  FAttachmentsButton.Caption := 'PDF-Anlagen';
  FAttachmentsButton.ShowHint := True;
  FAttachmentsButton.Hint := 'Ein-/Ausblenden der Anlagenliste zur PDF-Datei:' + #13 + 'Ein "->" bedeutet Anlage(n) vorhanden';
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
  RotateLabel := LLabel;
  LLabel.ShowHint := True;
  LLabel.Hint := 'Eine Seite oder einen Bereich eingeben:' + #13 + '1-3 oder 5-20 oder...';
  LLabel.Left := 408;
  LLabel.Top := 11;
  LLabel.AutoSize := True;

  FRotatePageEdit := TEdit.Create(Self);
  FRotatePageEdit.Parent := FToolbar;
  FRotatePageEdit.AutoSize := False;
  FRotatePageEdit.ParentShowHint := False;
  FRotatePageEdit.ShowHint := False;
  FRotatePageEdit.Hint := '';
  FRotatePageEdit.OnMouseEnter := NumberFieldMouseEnter;
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
  AngleLabel := LLabel;
  LLabel.ShowHint := True;
  LLabel.Hint := 'Um wieviel Grad man die Seite(n) drehen möchte';
  LLabel.Left := 540;
  LLabel.Top := 11;
  LLabel.AutoSize := True;

  FRotateAngleCombo := TComboBox.Create(Self);
  FRotateAngleCombo.Parent := FToolbar;
  FRotateAngleCombo.ParentShowHint := False;
  FRotateAngleCombo.ShowHint := False;
  FRotateAngleCombo.Hint := '';
  FRotateAngleCombo.OnMouseEnter := NumberFieldMouseEnter;
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
  FRotateButton.Hint := 'Dreht die PDF-Seite(n) und speichert danach. Vorher wird eine BAK-Datei erstellt';
  FRotateButton.Caption := 'Drehen';
  FRotateButton.Left := 667;
  FRotateButton.Top := 6;
  FRotateButton.Width := 80;
  FRotateButton.Height := 28;
  FRotateButton.OnClick := RotatePageClick;

  // DPI-feste Anordnung: keine 96-DPI-Koordinaten fuer 4K/Skalierung.
  // Alle Breiten orientieren sich am tatsaechlich verwendeten Schriftbild.
  Gap := ScalePx(7);
  ControlHeight := Max(ScalePx(25), Canvas.TextHeight('Ag') + ScalePx(10));
  ToolbarHeight := ControlHeight + ScalePx(8);
  FToolbar.Height := ToolbarHeight;
  XPos := ScalePx(8);

  // Nur eine Textsuche in der oberen Viewer-Leiste.
  PlaceControl(FFindButton, Max(ScalePx(86),
    Canvas.TextWidth(FFindButton.Caption) + ScalePx(18)));
  // Trefferanzeige direkt rechts neben 'Text suchen'.
  // Die Breite bleibt auch bei 0 Treffern reserviert, damit die
  // nachfolgenden Bedienelemente nicht hin- und herspringen.
  FSearchCountLabel.SetBounds(XPos,
    (ToolbarHeight - FSearchCountLabel.Height) div 2,
    Max(ScalePx(75), Canvas.TextWidth('9999 Treffer') + ScalePx(8)),
    FSearchCountLabel.Height);
  Inc(XPos, FSearchCountLabel.Width + Gap);
  PlaceControl(FAttachmentsButton, Max(ScalePx(104),
    Canvas.TextWidth(FAttachmentsButton.Caption) + ScalePx(18)));

  Inc(XPos, ScalePx(8));
  PlaceControl(RotateLabel, Canvas.TextWidth(RotateLabel.Caption) + ScalePx(5));
  PlaceControl(FRotatePageEdit, Max(ScalePx(36),
    Canvas.TextWidth('999') + ScalePx(12)));
  PlaceControl(AngleLabel, Canvas.TextWidth(AngleLabel.Caption) + ScalePx(5));
  PlaceControl(FRotateAngleCombo, Max(ScalePx(60),
    Canvas.TextWidth('270°') + ScalePx(24)));
  PlaceControl(FRotateButton, Max(ScalePx(74),
    Canvas.TextWidth(FRotateButton.Caption) + ScalePx(18)));

  // --------------------------------------------------
  // Navigationstimer - nur einmal erstellen
  // --------------------------------------------------
  FPageNavigationTimer := TTimer.Create(Self);
  FPageNavigationTimer.Enabled := False;
  FPageNavigationTimer.Interval := 180;
  FPageNavigationTimer.OnTimer := PageNavigationTimerTimer;

  // PDFium fuellt den verbleibenden Platz
  DoubleBuffered := True;

end;

procedure TPDFBrowserForm.NumberFieldMouseEnter(Sender: TObject);
var
  C: TWinControl;
begin
  // Der Pfad-Hint der Registerkarte darf nicht ueber den Zahlenfeldern
  // stehen bleiben. Er wird beim Ueberfahren des Tabs neu gesetzt.
  Application.CancelHint;
  C := Parent;
  while Assigned(C) do
  begin
    if C is TPageControl then
    begin
      C.Hint := '';
      Break;
    end;
    C := C.Parent;
  end;
end;

procedure TPDFBrowserForm.SetAttachmentIndicator(AHasAttachments: Boolean);
begin
  if not Assigned(FAttachmentsButton) then Exit;
  if AHasAttachments then
    FAttachmentsButton.Caption := '-> Anlagen'
  else
    FAttachmentsButton.Caption := 'Anlagen';
end;

procedure TPDFBrowserForm.ToggleAttachmentsClick(Sender: TObject);
begin
  if (AttachmentWindowHandle = 0) or
     not IsWindow(AttachmentWindowHandle) then
  begin
    MessageDlg('Das Anlagenfenster wurde noch nicht erstellt.',
      mtInformation, [mbOK], 0);
    Exit;
  end;

  if IsWindowVisible(AttachmentWindowHandle) then
  begin
    // Beim Ausblenden den temporaeren Topmost-Status entfernen.
    ShowWindow(AttachmentWindowHandle, SW_HIDE);
    SetWindowPos(AttachmentWindowHandle, HWND_NOTOPMOST,
      0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
  end
  else
  begin
    // Das Fenster bleibt ein eigenes VCL-Formular, liegt aber
    // beim Anzeigen garantiert ueber dem PDF/WebView2-Fenster.
    // SWP_NOACTIVATE verhindert einen Fokuswechsel.
    SetWindowPos(AttachmentWindowHandle, HWND_TOPMOST,
      0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or
      SWP_NOACTIVATE or SWP_SHOWWINDOW);
    UpdateAttachmentWindowPosition;
  end;
end;


procedure TPDFBrowserForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or WS_CLIPCHILDREN;
end;

procedure TPDFBrowserForm.FormCreate(Sender: TObject);
var IniDat: TIniFile;
begin
  Position := poDesigned;
  FLoadRequested := False;
  FNavigationDone := False;
  FNavigationSucceeded := False;
  FPendingFirstDisplay := False;
  FClosing := False;
  FLoadingHintWnd := 0;
  FLoadingHintFont := 0;
  FTabbedPDFMode := False;
  FStandalonePDFMode := False;
  FStandaloneHintShown := False;
  AttachmentWindowHandle := 0;
  FStartPage := 1;
  FSearchTerm := '';
  BuildNavigationToolbar;
  TimerPDF.Interval := 150;
  TimerPDF.Enabled := False;
  FPDFiumView := TFreePDF64PDFiumView.CreateInParent(Self, Self);
  FPDFiumView.Align := alClient;
  FPDFiumView.OnSearchCountChanged := UpdateSearchCount;
  UpdateSearchCount(FPDFiumView);
  FPDFiumView.BringToFront;
  FPDFiumView.PlaceEditButton(FToolbar,
    FRotateButton.Left + FRotateButton.Width + MulDiv(8, CurrentPPI, 96),
    FRotateButton.Top, FRotateButton.Height);
  IniDat := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'FreePDF64.ini');
  try
    Left := IniDat.ReadInteger('Position', 'PDFBrowserForm_Left', Left);
    Top := IniDat.ReadInteger('Position', 'PDFBrowserForm_Top', Top);
    Width := IniDat.ReadInteger('Position', 'PDFBrowserForm_Width', Width);
    Height := IniDat.ReadInteger('Position', 'PDFBrowserForm_Height', Height);
  finally IniDat.Free; end;
end;

procedure TPDFBrowserForm.SetLoadingHint(AVisible: Boolean);
var
  HintW, HintH, PPI: Integer;
  Pt: TPoint;
  OwnerWnd: HWND;
begin
  if not AVisible then
  begin
    if FLoadingHintWnd <> 0 then
    begin
      DestroyWindow(FLoadingHintWnd);
      FLoadingHintWnd := 0;
    end;
    if FLoadingHintFont <> 0 then
    begin
      DeleteObject(FLoadingHintFont);
      FLoadingHintFont := 0;
    end;
    Exit;
  end;
  if FClosing or (csDestroying in ComponentState) or not HandleAllocated then Exit;
  if FLoadingHintWnd <> 0 then Exit;

  PPI := CurrentPPI;
  HintW := MulDiv(230, PPI, 96);
  HintH := MulDiv(54, PPI, 96);
  Pt := ClientToScreen(Point((ClientWidth - HintW) div 2,
    (ClientHeight - HintH) div 2));
  // Eigenes, nicht aktivierendes Popup-Fenster. Es ist kein Kindfenster
  // des PDF-Viewers und kann daher nicht von diesem verdeckt werden.
  OwnerWnd := GetAncestor(Handle, GA_ROOT);
  FLoadingHintWnd := CreateWindowEx(WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE,
    'STATIC', 'PDF wird geöffnet ...', WS_POPUP or WS_BORDER or
    SS_CENTER or SS_CENTERIMAGE, Pt.X, Pt.Y, HintW, HintH,
    OwnerWnd, 0, HInstance, nil);
  if FLoadingHintWnd = 0 then Exit;
  FLoadingHintFont := CreateFont(-MulDiv(10, PPI, 72), 0, 0, 0,
    FW_NORMAL, 0, 0, 0, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
    CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH or FF_DONTCARE,
    'Segoe UI');
  if FLoadingHintFont <> 0 then
    SendMessage(FLoadingHintWnd, WM_SETFONT, WPARAM(FLoadingHintFont), 0);
  SetWindowPos(FLoadingHintWnd, HWND_TOPMOST, Pt.X, Pt.Y, HintW, HintH,
    SWP_NOACTIVATE or SWP_SHOWWINDOW);
  UpdateWindow(FLoadingHintWnd);
end;

procedure TPDFBrowserForm.RequestPDFLoad;
begin
  if FClosing or (csDestroying in ComponentState) then Exit;
  // Nach Abbruch/Fehler nicht durch Tabwechsel oder Timer erneut laden.
  // Ein explizites OpenSavedPDF setzt FNavigationDone wieder zurueck.
  if FNavigationDone and not FNavigationSucceeded then Exit;
  FLoadRequested := True;
  TimerPDF.Enabled := True;
  RefreshActiveTabPDF;
end;

procedure TPDFBrowserForm.RefreshActiveTabPDF;
begin
  if FClosing or not FLoadRequested or (FPDFiumView = nil) or
     FPDFLoadInProgress then Exit;
  if FNavigationDone and FNavigationSucceeded then
  begin
    // Erste Darstellung nach dem endgueltigen Layout des TabSheets.
    if FPendingFirstDisplay and Visible and (ClientWidth >= 50) and
       (ClientHeight >= 50) then
    begin
      FPDFiumView.RefreshPDFDisplay;
      FPendingFirstDisplay := False;
    end;
    TimerPDF.Enabled := FPendingFirstDisplay;
    Exit;
  end;
  if not Visible or (ClientWidth < 50) or (ClientHeight < 50) then Exit;
  // Sicherstellen, dass der PDFium-Bereich nicht durch das Einbetten
  // unsichtbar oder mit veralteten Abmessungen zurueckbleibt.
  if (FPDFiumView.Parent <> Self) then FPDFiumView.Parent := Self;
  FPDFiumView.Align := alClient;
  FPDFiumView.Visible := True;
  FPDFiumView.BringToFront;
  if (Parent is TTabSheet) and
     (TTabSheet(Parent).PageControl.ActivePage <> TTabSheet(Parent)) then Exit;
  // Hinweis sofort zeichnen, ohne zusaetzlichen Timer-Tick.
  // Keine Application.ProcessMessages: keine rekursiven Ladeaufrufe.
  // Ein modaler Kennwortdialog verarbeitet weiterhin Windows-Nachrichten.
  // Den Ladetimer deshalb vor dem Oeffnen deaktivieren und Rekursion sperren.
  FPDFLoadInProgress := True;
  TimerPDF.Enabled := False;
  SetLoadingHint(True);
  try
    try
      FPDFiumView.OpenPDF(PDFFileName);
    if FStartPage > 1 then FPDFiumView.ShowPage(FStartPage - 1);
    // Den Suchbegriff aus Suchen.pas erst nach dem Laden an PDFium geben.
    // Vor OpenPDF ist noch kein PDF-Textindex vorhanden.
    if Trim(FSearchTerm) <> '' then
      FPDFiumView.SearchText(FSearchTerm);
    FNavigationDone := True;
    FNavigationSucceeded := True;
    FPendingFirstDisplay := True;
    TimerPDF.Enabled := True;
  except
    on E: EAbort do
    begin
      FLoadRequested := False;
      FNavigationDone := True;
      FNavigationSucceeded := False;
      FPendingFirstDisplay := False;
      TimerPDF.Enabled := False;
    end;
    on E: Exception do
    begin
      FLoadRequested := False;
      FNavigationDone := True;
      FNavigationSucceeded := False;
      FPendingFirstDisplay := False;
      TimerPDF.Enabled := False;
      MessageDlg('PDFium konnte die PDF nicht öffnen: ' + E.Message,
        mtError, [mbOK], 0);
    end;
    end;
  finally
    SetLoadingHint(False);
      FPDFLoadInProgress := False;
  end;
end;

procedure TPDFBrowserForm.OpenSavedPDF(const AFileName: string;
  AHasAttachments: Boolean);
begin
  if FClosing or not FileExists(AFileName) then Exit;
  PDFFileName := AFileName;
  Caption := AFileName;
  FStartPage := 1;
  FNavigationDone := False;
  FNavigationSucceeded := False;
  FLoadRequested := True;
  SetAttachmentIndicator(AHasAttachments);
  RequestPDFLoad;
end;

procedure TPDFBrowserForm.PageNavigationTimerTimer(Sender: TObject);
begin
  FPageNavigationTimer.Enabled := False;
  RefreshActiveTabPDF;
end;

procedure TPDFBrowserForm.SetSearchTerm(const AValue: string);
begin
  FSearchTerm := AValue;
  // Auch bei bereits geoeffneten PDFs die Suche sofort aktualisieren.
  if (FPDFiumView <> nil) and FNavigationSucceeded then
    FPDFiumView.SearchText(FSearchTerm);
end;

procedure TPDFBrowserForm.NextPDFSearchMatch(ADirection: Integer);
begin
  if (FPDFiumView <> nil) and FNavigationSucceeded then
    FPDFiumView.NextSearchMatch(ADirection);
end;

procedure TPDFBrowserForm.ShowPDFSearch;
begin
  FindTermClick(nil);
end;

procedure TPDFBrowserForm.UpdateSearchCount(Sender: TObject);
begin
  if (FSearchCountLabel = nil) or (FPDFiumView = nil) then Exit;
  FSearchCountLabel.Visible := FPDFiumView.SearchMatchCount > 0;
  if FSearchCountLabel.Visible then
    FSearchCountLabel.Caption := Format('%d Treffer',
      [FPDFiumView.SearchMatchCount])
  else
    FSearchCountLabel.Caption := '';
end;

procedure TPDFBrowserForm.FindTermClick(Sender: TObject);
begin
  if FPDFiumView <> nil then FPDFiumView.ShowSearchDialog;
end;

procedure TPDFBrowserForm.MarkerClick(Sender: TObject);
begin
  if FPDFiumView <> nil then FPDFiumView.ToggleMarker;
end;

procedure TPDFBrowserForm.FormShow(Sender: TObject);
begin
  Caption := PDFFileName;
  // Auch eingebettete PDF-Formulare muessen beim ersten Anzeigen laden.
  // Der Tab-Manager darf nicht der einzige Ausloeser sein.
  FLoadRequested := True;
  if FPDFiumView <> nil then
  begin
    FPDFiumView.Align := alClient;
    FPDFiumView.Visible := True;
    FPDFiumView.BringToFront;
  end;
  TimerPDF.Enabled := True;
  RefreshActiveTabPDF;
end;

procedure TPDFBrowserForm.TimerPDFTimer(Sender: TObject);
begin
  RefreshActiveTabPDF;
end;

procedure TPDFBrowserForm.FormResize(Sender: TObject);
begin
  UpdateAttachmentWindowPosition;
end;

procedure TPDFBrowserForm.FormClose(Sender: TObject; var Action: TCloseAction);
var IniDat: TIniFile;
begin
  FClosing := True;
  SetLoadingHint(False);
  TimerPDF.Enabled := False;
  if Assigned(FPageNavigationTimer) then FPageNavigationTimer.Enabled := False;
  if not FTabbedPDFMode then
  begin
    IniDat := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'FreePDF64.ini');
    try
      IniDat.WriteInteger('Position', 'PDFBrowserForm_Left', Left);
      IniDat.WriteInteger('Position', 'PDFBrowserForm_Top', Top);
      IniDat.WriteInteger('Position', 'PDFBrowserForm_Width', Width);
      IniDat.WriteInteger('Position', 'PDFBrowserForm_Height', Height);
    finally IniDat.Free; end;
  end;
  Action := caFree;
end;

procedure TPDFBrowserForm.WMMove(var aMessage: TWMMove);
begin
  inherited;
  UpdateAttachmentWindowPosition;
end;

procedure TPDFBrowserForm.WMMoving(var aMessage: TMessage);
begin
  inherited;
  UpdateAttachmentWindowPosition;
end;


procedure TPDFBrowserForm.SelectAllPDFText;
begin
  if FPDFiumView <> nil then FPDFiumView.SelectAllText;
end;

procedure TPDFBrowserForm.CopyPDFText;
begin
  if FPDFiumView <> nil then FPDFiumView.CopySelectedText;
end;

function TPDFBrowserForm.IsShortCut(var Message: TWMKey): Boolean;
begin
  // Keine Tastenkombinationen pauschal verschlucken.
  // Insbesondere muss Strg+F an den FreePDF64-Viewer gelangen können.
  Result := inherited IsShortCut(Message);
end;
end.
