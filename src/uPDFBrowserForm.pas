//
// Programmname: FreePDF64
//

unit uPDFBrowserForm;

interface

{$I ..\..\WebView4Delphi-main\source\webview2.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Clipbrd, Vcl.ComCtrls, Math,
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
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMMove(var aMessage: TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage: TMessage); message WM_MOVING;

    function IsShortCut(var Message: TWMKey): Boolean; override;

  private
    FLoadRequested: Boolean;
    FBrowserCreateStarted: Boolean;
    FBrowserCreated: Boolean;
    FNavigationDone: Boolean;
    FBrowserError: string;
    FClosing: Boolean;
    FToolbar: TPanel;
    FPageLabel: TLabel;
    FPageEdit: TEdit;
    FGoPageButton: TButton;
    FFindButton: TButton;
    FPageNavigationTimer: TTimer;
    FSearchTerm: string;
    FStartPage: Integer;
    FTabbedPDFMode: Boolean;
    FStandalonePDFMode: Boolean;
    FStandaloneHintShown: Boolean;

    FRotatePageEdit: TEdit;
    FRotateAngleCombo: TComboBox;
    FRotateButton: TButton;

    procedure RotatePageClick(Sender: TObject);
    function ExecuteQpdf(const ACommandLine: string; out AExitCode: DWORD): Boolean;

    procedure WMNavigatePDF(var Msg: TMessage); message WM_APP + 191;
    procedure StartBrowser;
    procedure BuildNavigationToolbar;
    procedure NumberFieldMouseEnter(Sender: TObject);
    procedure GoToPageClick(Sender: TObject);
    procedure FindTermClick(Sender: TObject);
    procedure ToggleAttachmentsClick(Sender: TObject);
    procedure PageNavigationTimerTimer(Sender: TObject);
    function BuildPdfUrl(const APage: Integer): string;

  public
    FAttachmentsButton: TButton;
    // HWND des Anlagenfensters, das zu genau dieser PDF-Ansicht gehört.
    AttachmentWindowHandle: HWND;
    PDFFileName: string;
    procedure UpdateAttachmentWindowPosition;
    procedure RefreshActiveTabPDF;
    procedure OpenSavedPDF(const AFileName: string; AHasAttachments: Boolean);
    procedure SetAttachmentIndicator(AHasAttachments: Boolean);
    procedure RequestPDFLoad;
    property PDFNavigationStarted: Boolean read FNavigationDone;
    property TabbedPDFMode: Boolean read FTabbedPDFMode write FTabbedPDFMode;
    property SearchTerm: string read FSearchTerm write FSearchTerm;
    property StartPage: Integer read FStartPage write FStartPage;
    // True, wenn die PDF direkt per Kommandozeile/Explorer gestartet wurde.
    property StandalonePDFMode: Boolean read FStandalonePDFMode write FStandalonePDFMode;
  end;

implementation

{$R *.dfm}

procedure TPDFBrowserForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  // Beim Neuzeichnen die WebView2-Kindfenster nicht mit uebermalen.
  Params.Style := Params.Style or WS_CLIPCHILDREN;
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
  // Browser ist bereits erstellt: TimerPDF wuerde wegen
  // FBrowserCreateStarted abbrechen und die Ansicht leer lassen.
  FNavigationDone := False;
  FPageNavigationTimer.Enabled := False;
  FPageNavigationTimer.Interval := 500;
  FPageNavigationTimer.Enabled := True;
end;

procedure TPDFBrowserForm.FormCreate(Sender: TObject);
var
  IniDat: TIniFile;
begin
  Position := poDesigned;

  FLoadRequested := False;
  FBrowserCreateStarted := False;
  FBrowserCreated := False;
  FNavigationDone := False;
  FBrowserError := '';
  FClosing := False;
  FTabbedPDFMode := False;
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
const
  EdgeGap = 12;
  HeightPercent = 72;
var
  ViewRect, AttachmentRect: TRect;
  NewLeft, NewTop, NewHeight, NewWidth: Integer;
  ViewWidth, ViewHeight: Integer;
  PDFOrigin: TPoint;
begin
  if (AttachmentWindowHandle = 0) or
     not IsWindow(AttachmentWindowHandle) or
     not Assigned(WVWindowParentPDF) or
     not WVWindowParentPDF.HandleAllocated then
    Exit;

  // Die Geometrie richtet sich ausschliesslich nach dem PDF-Anzeigebereich,
  // nicht nach dem Monitor oder dem Hauptformular.
  PDFOrigin := WVWindowParentPDF.ClientToScreen(Point(0, 0));
  ViewRect := Rect(PDFOrigin.X, PDFOrigin.Y,
    PDFOrigin.X + WVWindowParentPDF.ClientWidth,
    PDFOrigin.Y + WVWindowParentPDF.ClientHeight);
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

procedure TPDFBrowserForm.WMNavigatePDF(var Msg: TMessage);
begin
  if FClosing or (csDestroying in ComponentState) or
     not FBrowserCreated or FNavigationDone then Exit;
  if FTabbedPDFMode and
     ((not (Parent is TTabSheet)) or
      (TTabSheet(Parent).PageControl.ActivePage <> TTabSheet(Parent))) then Exit;
  if not Visible or (WVWindowParentPDF.ClientWidth <= 0) or
     (WVWindowParentPDF.ClientHeight <= 0) then Exit;
  try
    WVWindowParentPDF.UpdateSize;
    WVBrowserPDF.Navigate(BuildPdfUrl(FStartPage));
    FNavigationDone := True;

  except
    on E: Exception do
      Exit;
  end;
end;

procedure TPDFBrowserForm.RequestPDFLoad;
begin
  if FClosing or (csDestroying in ComponentState) then Exit;
  FLoadRequested := True;
  RefreshActiveTabPDF;
  if FBrowserCreated and not FNavigationDone and HandleAllocated then
    PostMessage(Handle, WM_APP + 191, 0, 0);
end;

procedure TPDFBrowserForm.RefreshActiveTabPDF;
begin

  if FClosing then
    Exit;
  // Beim ersten Tab kann der Ladeauftrag vor dem ersten Anzeigen eintreffen.
  // In diesem Fall nach dem Anzeigen erneut versuchen.
  if not HandleAllocated or not Visible then
  begin
    if FTabbedPDFMode and FLoadRequested and not FBrowserCreateStarted then
      TimerPDF.Enabled := True;
    Exit;
  end;
  if (Parent is TTabSheet) and
     (TTabSheet(Parent).PageControl.ActivePage <> TTabSheet(Parent)) then
    Exit;

  // Ein eingebetteter WebView2-Browser benoetigt einen gueltigen Host.
  if (WVWindowParentPDF.ClientWidth <= 0) or
     (WVWindowParentPDF.ClientHeight <= 0) then
  begin
    if not FBrowserCreateStarted then
      TimerPDF.Enabled := True;
    Exit;
  end;

  WVWindowParentPDF.UpdateSize;
  if FBrowserCreated then
  begin
    WVBrowserPDF.NotifyParentWindowPositionChanged;
    if not FNavigationDone and HandleAllocated then
      PostMessage(Handle, WM_APP + 191, 0, 0);
  end
  else if FLoadRequested and not FBrowserCreateStarted then
    StartBrowser;
end;

procedure TPDFBrowserForm.FormResize(Sender: TObject);
begin
  UpdateAttachmentWindowPosition;
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
    if (C = FPageLabel) or (C = RotateLabel) or (C = AngleLabel) then
      H := TLabel(C).Height;
    // Nur die vier Aktionsbuttons etwas flacher gestalten.
    // Eingabefelder, Beschriftungen und Auswahlliste bleiben unveraendert.
    if (C = FGoPageButton) or (C = FFindButton) or
       (C = FAttachmentsButton) or (C = FRotateButton) then
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
  FPageEdit.ParentShowHint := False;
  FPageEdit.ShowHint := False;
  FPageEdit.Hint := '';
  FPageEdit.OnMouseEnter := NumberFieldMouseEnter;
  FPageEdit.Name := 'PDFPageNumberEdit';
  FPageEdit.Left := 48;
  FPageEdit.Top := 8;
  FPageEdit.Width := 42;
  FPageEdit.Text := '1';
  FPageEdit.NumbersOnly := True;

  FGoPageButton := TButton.Create(Self);
  FGoPageButton.Parent := FToolbar;
  FGoPageButton.Caption := 'Gehe zu';
  // Eigenen Hinweis setzen, damit nicht der Dateipfad des Tabs geerbt wird.
  FGoPageButton.ShowHint := True;
  FGoPageButton.Hint := 'Zur angegebenen PDF-Seite wechseln';
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

  PlaceControl(FPageLabel, Canvas.TextWidth(FPageLabel.Caption) + ScalePx(5));
  PlaceControl(FPageEdit, Max(ScalePx(36), Canvas.TextWidth('999') + ScalePx(12)));
  PlaceControl(FGoPageButton, Max(ScalePx(70),
    Canvas.TextWidth(FGoPageButton.Caption) + ScalePx(18)));
  PlaceControl(FFindButton, Max(ScalePx(86),
    Canvas.TextWidth(FFindButton.Caption) + ScalePx(18)));
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

  // FreePDF64-Viewer füllt den verbleibenden Platz
  DoubleBuffered := True;
  WVWindowParentPDF.Align := alClient;
  WVWindowParentPDF.SendToBack;
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

function TPDFBrowserForm.BuildPdfUrl(const APage: Integer): string;
var
  LPath: string;
begin
  LPath := StringReplace(ExpandFileName(PDFFileName), '\', '/', [rfReplaceAll]);
  // URL-Kodierung der Leerzeichen verhindert fehlerhafte file-URLs.
  LPath := StringReplace(LPath, ' ', '%20', [rfReplaceAll]);
  Result := 'file:///' + LPath + '?freepdf64_refresh=' +
    IntToStr(GetTickCount64) + '#page=' + IntToStr(Max(1, APage));
end;

procedure TPDFBrowserForm.OpenSavedPDF(const AFileName: string;
  AHasAttachments: Boolean);
begin
  if FClosing or not FileExists(AFileName) then Exit;
  PDFFileName := AFileName;
  Caption := AFileName;
  FStartPage := 1;
  if Assigned(FPageEdit) then FPageEdit.Text := '1';
  if Assigned(FAttachmentsButton) then
  begin
    if AHasAttachments then
      FAttachmentsButton.Caption := '-> Anlagen'
    else
      FAttachmentsButton.Caption := 'Anlagen';
  end;
  FNavigationDone := False;
  if FBrowserCreated then
  begin
    FPageNavigationTimer.Enabled := False;
    FPageNavigationTimer.Enabled := True;
  end
  else
    RequestPDFLoad;
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
    FNavigationDone := False;
    FPageNavigationTimer.Enabled := True;
  end;
end;


procedure TPDFBrowserForm.PageNavigationTimerTimer(Sender: TObject);
begin
  FPageNavigationTimer.Enabled := False;
  if FBrowserCreated and not FClosing then
    // Erst nach Rueckkehr aus dem WebView2-Callback navigieren.
  // Das TabSheet hat dann seine endgueltige Groesse.
  if HandleAllocated then
    PostMessage(Handle, WM_APP + 191, 0, 0);
end;


procedure TPDFBrowserForm.FindTermClick(Sender: TObject);
begin
  if Trim(FSearchTerm) = '' then
  begin
    MessageDlg('In der Suchmaske [Text suchen] ist kein Suchbegriff eingetragen.', mtInformation, [mbOK], 0);
    Exit;
  end;

  // Der FreePDF64-Viewer besitzt eine eigene Suche (Strg+F).
  // WebView2 bietet keine stabile öffentliche API, um interne PDF-Treffer
  // direkt zu markieren. Deshalb wird die integrierte Suchoberfläche geöffnet.
  Clipboard.AsText := FSearchTerm;

  // Den Fokus möglichst direkt an die WebView geben, nicht nur an
  // deren Parent-Window. Die Suche selbst wird vom FreePDF64-Viewer
  // über Strg+F bereitgestellt.
  BringToFront;
  if not FTabbedPDFMode then
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
  Caption := PDFFileName;
  FClosing := False;
  if FTabbedPDFMode then
  begin
    // Der aktive Tab wird nach dem Einbetten automatisch gestartet.
    // Laden wird vom Tab-Fenster nach dem Stapelaufbau angefordert.
    // Falls die Anforderung bereits vor dem ersten FormShow kam,
    // die Initialisierung jetzt erneut anstossen.
    if FLoadRequested then
      RefreshActiveTabPDF;
  end
  else
  begin
    // Explorer/Einzelfenster bleibt unveraendert sofort nutzbar.
    FLoadRequested := True;
    StartBrowser;
    BringToFront;
    SetForegroundWindow(Handle);
    if Assigned(FPageEdit) and FPageEdit.CanFocus then
      FPageEdit.SetFocus;
  end;
end;

procedure TPDFBrowserForm.StartBrowser;
begin

  if FClosing or FBrowserCreateStarted or
     (csDestroying in ComponentState) or
     (FTabbedPDFMode and not FLoadRequested) then Exit;

  // Bei Tabs niemals in einem unsichtbaren/noch nicht vermessenen
  // TabSheet einen WebView2-Controller erzeugen.
  if FTabbedPDFMode then
  begin
    if (not (Parent is TTabSheet)) or
       (TTabSheet(Parent).PageControl.ActivePage <> TTabSheet(Parent)) or
       (not Visible) or
       (WVWindowParentPDF.ClientWidth <= 0) or
       (WVWindowParentPDF.ClientHeight <= 0) then
      Exit;
  end;

  if GlobalWebView2Loader.InitializationError then
  begin
    ShowMessage(GlobalWebView2Loader.ErrorMessage);
    Exit;
  end;

  if GlobalWebView2Loader.Initialized then
  begin
    FBrowserCreateStarted := True;

    WVBrowserPDF.CreateBrowser(WVWindowParentPDF.Handle);
  end
  else
    TimerPDF.Enabled := True;
end;

procedure TPDFBrowserForm.TimerPDFTimer(Sender: TObject);
begin
  try

  TimerPDF.Enabled := False;
  if FClosing or FBrowserCreateStarted or
     (csDestroying in ComponentState) or
     (FTabbedPDFMode and not FLoadRequested) then Exit;

  if FTabbedPDFMode and
     ((not (Parent is TTabSheet)) or
      (TTabSheet(Parent).PageControl.ActivePage <> TTabSheet(Parent))) then
    Exit;

  if GlobalWebView2Loader.InitializationError then
  begin
    ShowMessage(GlobalWebView2Loader.ErrorMessage);
    Exit;
  end;

  StartBrowser;
  // Falls das erste Tab beim ersten Versuch noch nicht sichtbar oder
  // noch nicht vermessen war, weiter versuchen statt dauerhaft aufzugeben.
  if FTabbedPDFMode and FLoadRequested and not FBrowserCreateStarted and
     (Parent is TTabSheet) and
     (TTabSheet(Parent).PageControl.ActivePage = TTabSheet(Parent)) then
    TimerPDF.Enabled := True;
  except
    on E: Exception do
    begin

      if Assigned(TimerPDF) then TimerPDF.Enabled := False;
    end;
  end;
end;

procedure TPDFBrowserForm.WVBrowserPDFAfterCreated(Sender: TObject);
begin
  try

  // Sehr wichtig:
  // Falls CreateBrowser noch abgeschlossen wurde, nachdem
  // der Benutzer das PDF-Fenster bereits geschlossen hat,
  // darf hier nichts mehr mit dem Formular gemacht werden.
  if FClosing then
    Exit;

  FBrowserCreated := True;

  // Inaktive TabSheets koennen momentan 0x0 Pixel gross sein.
  // Die Groesse erst beim Aktivieren aktualisieren; Navigation
  // dennoch sofort im Hintergrund starten.
  if (not FTabbedPDFMode) or
     ((Parent is TTabSheet) and
      (TTabSheet(Parent).PageControl.ActivePage = TTabSheet(Parent))) then
    WVWindowParentPDF.UpdateSize;

  if FStartPage < 1 then
    FStartPage := 1;
  FPageEdit.Text := IntToStr(FStartPage);
  // Nicht im asynchronen WebView2-Callback navigieren.
  // Nur der aktive Tab navigiert; der erste Tab wird genauso behandelt.
  if HandleAllocated and ((not FTabbedPDFMode) or
     ((Parent is TTabSheet) and
      (TTabSheet(Parent).PageControl.ActivePage = TTabSheet(Parent)))) then
    PostMessage(Handle, WM_APP + 191, 0, 0);

  // Asynchrone WebView2-Initialisierung darf NICHT den aktiven Tab
  // wechseln oder den Fokus von einer anderen PDF-Registerkarte stehlen.
  if not FTabbedPDFMode then
  begin
    BringToFront;
    SetForegroundWindow(Handle);
  end;
  if WVWindowParentPDF.HandleAllocated and
     ((not FTabbedPDFMode) or
      ((Parent is TTabSheet) and
       (TTabSheet(Parent).PageControl.ActivePage = TTabSheet(Parent)))) then
    Winapi.Windows.SetFocus(WVWindowParentPDF.Handle);
  except
    on E: Exception do
    begin

      if Assigned(TimerPDF) then TimerPDF.Enabled := False;
    end;
  end;
end;

function TPDFBrowserForm.IsShortCut(var Message: TWMKey): Boolean;
begin
  // Keine Tastenkombinationen pauschal verschlucken.
  // Insbesondere muss Strg+F an den FreePDF64-Viewer gelangen können.
  Result := inherited IsShortCut(Message);
end;

procedure TPDFBrowserForm.WVBrowserPDFInitializationError(
  Sender: TObject; aErrorCode: HRESULT;
  const aErrorMessage: wvstring);
begin
  try
  // Formular befindet sich bereits im Schließvorgang.
  if FClosing then
    Exit;

  FBrowserCreated := False;
  FBrowserError := aErrorMessage;

  ShowMessage(aErrorMessage);
  except
    on E: Exception do
    begin

      if Assigned(TimerPDF) then TimerPDF.Enabled := False;
    end;
  end;
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

  if not FTabbedPDFMode then
  begin
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

