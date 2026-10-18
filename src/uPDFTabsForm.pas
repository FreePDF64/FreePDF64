unit uPDFTabsForm;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, Winapi.Messages, Winapi.CommCtrl,
  Vcl.Forms, Vcl.Controls, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics,
  Vcl.Dialogs, Vcl.Menus, System.IniFiles, Math,
  uPDFBrowserForm;

type
  TPDFTabsForm = class(TForm)
  private
    FTabs: TPageControl;
    FEmptyTabStrip: TPanel;
    FOriginalTabsWindowProc: TWndMethod;
    FClosedPDFs: TStringList;
    FTabContextMenu: TPopupMenu;
    FReopenClosedItem: TMenuItem;
    FTabHintWindow: THintWindow;
    FHintTabIndex: Integer;
    FDragTabIndex: Integer;
    FDragStartPoint: TPoint;
    FDraggingTab: Boolean;
    FCloseButton: TButton;
    FOpenButton: TButton;
    FMainProgramButton: TButton;
    FTabSearchButton: TButton;
    FLocalTabSearchHotkeyRegistered: Boolean;
    FTabCountBadge: TPaintBox;
    FTabSearchForm: TForm;
    FTabSearchEdit: TEdit;
    FTabSearchList: TListBox;
    FLastNormalBounds: TRect;
    FRestoringWindowSettings: Boolean;
    FAddingPDF: Boolean;
    FPendingExplorerFiles: TStringList;
    FExplorerBatchTimer: TTimer;
    FDeferredActivePDF: TPDFBrowserForm;
    FActivationTimer: TTimer;
    FActivationChecks: Integer;
    FFirstPDFInitialized: Boolean;
    FInitialWindowOffscreen: Boolean;
    FInitialWindowBounds: TRect;
    FInitialWindowMaximized: Boolean;
    procedure TabsWindowProc(var Msg: TMessage);
    procedure WMViewerActivate(var Msg: TWMActivate); message WM_ACTIVATE;
    procedure WMViewerHotKey(var Msg: TMessage); message WM_HOTKEY;
    procedure UpdateEmptyTabStrip;
    procedure TabsResized(Sender: TObject);
    procedure EmptyTabStripMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TabContextPopup(Sender: TObject);
    procedure LoadClosedPDFs;
    procedure SaveClosedPDFs;
    procedure ReopenLastClosedPDF(Sender: TObject);
    procedure ReopenSelectedClosedPDF(Sender: TObject);
    procedure ActivationTimerTick(Sender: TObject);
    procedure ExplorerBatchTimerTick(Sender: TObject);
    procedure RestoreInitialWindow;
    procedure BringViewerToForeground;
    procedure WMOpenQueuedPDF(var Msg: TMessage); message WM_APP + 192;
    procedure WMLoadActivePDF(var Msg: TMessage); message WM_APP + 193;
    procedure OpenPDFClick(Sender: TObject);
    procedure OpenMainProgramClick(Sender: TObject);
    procedure UpdateTabCount;
    procedure PaintTabCountBadge(Sender: TObject);
    procedure TabSearchClick(Sender: TObject);
    procedure TabSearchChanged(Sender: TObject);
    procedure TabSearchChoose(Sender: TObject);
    procedure TabSearchListMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure TabSearchKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TabSearchDeactivate(Sender: TObject);
    procedure TabsFormClose(Sender: TObject; var Action: TCloseAction);
    procedure ClearAllPDFTabs;
    procedure LoadWindowSettings;
    procedure SaveWindowSettings;
    procedure RememberNormalBounds;
    procedure CloseActive(Sender: TObject);
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure RefreshAttachmentPositions;
    procedure TabsChange(Sender: TObject);
    procedure TabsMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure TabsMouseLeave(Sender: TObject);
    procedure DrawPDFTab(Control: TCustomTabControl; TabIndex: Integer;
      const Rect: TRect; Active: Boolean);
    procedure WindowMoved(var Msg: TWMMove); message WM_MOVE;
    procedure WindowSized(var Msg: TWMSize); message WM_SIZE;
    procedure TabMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LoadSelectedPDF;
    procedure TabDoubleClick(Sender: TObject);
    procedure TabMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddPDF(APDF: TPDFBrowserForm);
    procedure ActivatePDF(APDF: TPDFBrowserForm);
    procedure GetOpenPDFFileNames(AFiles: TStrings);
  end;

type
  TPDFTabAttachmentsProc = procedure(const AFileName: string;
    APDF: TPDFBrowserForm);

var
  PDFTabsWindow: TPDFTabsForm;
  PDFTabAttachmentsInitializer: TPDFTabAttachmentsProc;
  // True nur bei einem eigenstaendigen Explorer-Start mit PDF-Parametern.
  PDFTabsExplorerOnlyProcess: Boolean = False;
  // Wurde das Hauptfenster im Explorer-Prozess explizit geoeffnet?
  PDFTabsMainFormWasShown: Boolean = False;

procedure ShowEmptyPDFViewer;
procedure ShowPDFInTabs(APDF: TPDFBrowserForm);
function SendPDFToExistingTabs(const AFileName: string): Boolean;

var
  PDFTabsShowMainForm: TNotifyEvent = nil;

implementation

const
  LOCAL_TAB_SEARCH_HOTKEY_ID = $5A71;
  PDFTabWindowMarker = 'FreePDF64.PDFTabs.Window.v1';
  PDFTabMessageId = $46504446;

function FindTabsWindowCallback(Wnd: HWND; Data: LPARAM): BOOL; stdcall;
begin
  Result := True;
  if GetProp(Wnd, PChar(PDFTabWindowMarker)) <> 0 then
  begin
    PPointer(Data)^ := Pointer(Wnd);
    Result := False;
  end;
end;

function SendPDFToExistingTabs(const AFileName: string): Boolean;
var
  Wnd: HWND;
  Data: TCopyDataStruct;
  Path: string;
  Reply: DWORD_PTR;
begin
  Result := False;
  Wnd := 0;
  EnumWindows(@FindTabsWindowCallback, LPARAM(@Wnd));
  if Wnd = 0 then Exit;
  Path := ExpandFileName(AFileName);
  Data.dwData := PDFTabMessageId;
  Data.cbData := (Length(Path) + 1) * SizeOf(Char);
  Data.lpData := PChar(Path);
  Reply := 0;
  Result := SendMessageTimeout(Wnd, WM_COPYDATA, 0, LPARAM(@Data),
    SMTO_ABORTIFHUNG or SMTO_BLOCK, 4000, @Reply) <> 0;
  Result := Result and (Reply = 1);
end;

procedure TPDFTabsForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  // Kein Owner-Fenster: andernfalls bleibt das PDF-Fenster
  // vor dem FreePDF64-Hauptfenster (Windows-Z-Order).
  Params.WndParent := 0;
  Params.Style := Params.Style or WS_CLIPCHILDREN;
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.ExStyle := Params.ExStyle and not WS_EX_TOPMOST;
end;

procedure TPDFTabsForm.CreateWnd;
begin
  inherited CreateWnd;
  SetProp(Handle, PChar(PDFTabWindowMarker), THandle(1));
end;

procedure TPDFTabsForm.DestroyWnd;
begin
  if HandleAllocated then
  begin
    RemoveProp(Handle, PChar(PDFTabWindowMarker));
  end;
  inherited DestroyWnd;
end;

procedure TPDFTabsForm.WMCopyData(var Msg: TWMCopyData);
var
  FileName: string;
begin
  Msg.Result := 0;
  if (Msg.CopyDataStruct = nil) or
     (Msg.CopyDataStruct^.dwData <> PDFTabMessageId) or
     (Msg.CopyDataStruct^.lpData = nil) or
     (Msg.CopyDataStruct^.cbData < 2 * SizeOf(Char)) or
     (Msg.CopyDataStruct^.cbData mod SizeOf(Char) <> 0) then Exit;
  SetString(FileName, PChar(Msg.CopyDataStruct^.lpData),
    Msg.CopyDataStruct^.cbData div SizeOf(Char) - 1);
  if not SameText(ExtractFileExt(FileName), '.pdf') or
     not FileExists(FileName) then Exit;
  // Niemals im synchronen WM_COPYDATA-Handler WebView2/VCL-Forms erstellen.
  FPendingExplorerFiles.Add(FileName);
  // Explorer uebergibt mehrere markierte PDFs oft als einzelne WM_COPYDATA-
  // Nachrichten. Erst nach einer kurzen Empfangspause den Stapel verarbeiten.
  FExplorerBatchTimer.Enabled := False;
  FExplorerBatchTimer.Enabled := True;
  Msg.Result := 1;
end;

procedure TPDFTabsForm.ExplorerBatchTimerTick(Sender: TObject);
begin
  FExplorerBatchTimer.Enabled := False;
  if FPendingExplorerFiles.Count > 0 then
    PostMessage(Handle, WM_APP + 192, 0, 0);
end;

procedure TPDFTabsForm.WMOpenQueuedPDF(var Msg: TMessage);
var
  FileName: string;
  PDF: TPDFBrowserForm;
  LastOpenedPDF: TPDFBrowserForm;
begin
  // Bereits wartende Explorer-Nachrichten vor dem Anlegen verarbeiten.
  // Der Timer sorgt dafuer, dass ein zusammengehoeriger Dateistapel
  // gesammelt wird, bevor die erste WebView2-Instanz starten kann.
  FExplorerBatchTimer.Enabled := False;
  LastOpenedPDF := nil;
  while FPendingExplorerFiles.Count > 0 do
  begin
    FileName := FPendingExplorerFiles[0];
    FPendingExplorerFiles.Delete(0);
    if not FileExists(FileName) then Continue;
    PDF := nil;
    try
      PDF := TPDFBrowserForm.Create(Application);
      PDF.PDFFileName := FileName;
      PDF.StandalonePDFMode := False;
      AddPDF(PDF);
      LastOpenedPDF := PDF;
    except
      on E: Exception do
      begin
        // AddPDF kann das Formular bereits einem Tab zugeordnet haben.
        if (PDF <> nil) and (PDF.Parent = nil) then PDF.Free;
        OutputDebugString(PChar('Explorer PDF: ' + E.ClassName + ': ' + E.Message));
      end;
    end;
  end;
  // Die zuletzt per Explorer empfangene PDF sichtbar machen.
  // Erst nach dem Abarbeiten der Warteschlange aktivieren.
  if LastOpenedPDF <> nil then
    ActivatePDF(LastOpenedPDF);
  if LastOpenedPDF <> nil then
    BringViewerToForeground;
end;

function TabsIniFileName: string;
var
  Folder: string;
begin
  Folder := GetEnvironmentVariable('APPDATA');
  if Folder = '' then
    Folder := ExtractFilePath(Application.ExeName);
  Folder := IncludeTrailingPathDelimiter(Folder) + 'FreePDF64';
  ForceDirectories(Folder);
  Result := IncludeTrailingPathDelimiter(Folder) + 'PDFTabs.ini';
end;

procedure TPDFTabsForm.RememberNormalBounds;
begin
  if not FRestoringWindowSettings and not FInitialWindowOffscreen and
      HandleAllocated and Visible and
     (WindowState = wsNormal) and (Width > 200) and (Height > 150) then
    FLastNormalBounds := BoundsRect;
end;

procedure TPDFTabsForm.LoadWindowSettings;
var
  Ini: TIniFile;
  L, T, W, H: Integer;
  R: TRect;
begin
  FRestoringWindowSettings := True;
  try
    Ini := TIniFile.Create(TabsIniFileName);
    try
      W := Ini.ReadInteger('Fenster', 'Breite', 1100);
      H := Ini.ReadInteger('Fenster', 'Hoehe', 800);
      L := Ini.ReadInteger('Fenster', 'Links', (Screen.Width - W) div 2);
      T := Ini.ReadInteger('Fenster', 'Oben', (Screen.Height - H) div 2);
      W := EnsureRange(W, 450, Screen.DesktopWidth);
      H := EnsureRange(H, 300, Screen.DesktopHeight);
      R := Rect(L, T, L + W, T + H);
      if not IntersectRect(R, R, Screen.DesktopRect) then
      begin
        L := (Screen.Width - W) div 2;
        T := (Screen.Height - H) div 2;
      end;
      WindowState := wsNormal;
      Position := poDesigned;
      SetBounds(L, T, W, H);
      FLastNormalBounds := BoundsRect;
      if Ini.ReadBool('Fenster', 'Maximiert', False) then
        WindowState := wsMaximized;
    finally
      Ini.Free;
    end;
  finally
    FRestoringWindowSettings := False;
  end;
end;

procedure TPDFTabsForm.SaveWindowSettings;
var
  Ini: TIniFile;
  R: TRect;
begin
  R := FLastNormalBounds;
  if (WindowState = wsNormal) and not FInitialWindowOffscreen then
    R := BoundsRect;
  if (R.Right - R.Left < 450) or (R.Bottom - R.Top < 300) then
    R := Rect(Left, Top, Left + 1100, Top + 800);
  Ini := TIniFile.Create(TabsIniFileName);
  try
    Ini.WriteInteger('Fenster', 'Links', R.Left);
    Ini.WriteInteger('Fenster', 'Oben', R.Top);
    Ini.WriteInteger('Fenster', 'Breite', R.Right - R.Left);
    Ini.WriteInteger('Fenster', 'Hoehe', R.Bottom - R.Top);
    Ini.WriteBool('Fenster', 'Maximiert', WindowState = wsMaximized);
  finally
    Ini.Free;
  end;
end;

procedure TPDFTabsForm.OpenPDFClick(Sender: TObject);
var
  Dialog: TFileOpenDialog;
  I: Integer;
  PDF: TPDFBrowserForm;
  LastOpenedPDF: TPDFBrowserForm;
  ActiveTab: TTabSheet;
  ActivePDF: TPDFBrowserForm;
  ActiveDir: string;
  J: Integer;
begin
  LastOpenedPDF := nil;
  ActivePDF := nil;
  ActiveDir := '';
  ActiveTab := FTabs.ActivePage;
  if Assigned(ActiveTab) then
    for J := 0 to ActiveTab.ControlCount - 1 do
      if ActiveTab.Controls[J] is TPDFBrowserForm then
      begin
        ActivePDF := TPDFBrowserForm(ActiveTab.Controls[J]);
        Break;
      end;
  if Assigned(ActivePDF) and (ActivePDF.PDFFileName <> '') then
  begin
    ActiveDir := ExtractFilePath(ActivePDF.PDFFileName);
    if not DirectoryExists(ActiveDir) then
      ActiveDir := '';
  end;
  Dialog := TFileOpenDialog.Create(Self);
  try
    Dialog.Title := 'Datei(en) öffnen';
    // Ordner der aktiven PDF; ohne PDF oder bei fehlendem Ordner 'Dieser PC'.
    if ActiveDir <> '' then
      Dialog.DefaultFolder := ActiveDir
    else
      Dialog.DefaultFolder := '::{20D04FE0-3AEA-1069-A2D8-08002B30309D}';
    Dialog.FileName := '';
    with Dialog.FileTypes.Add do
    begin
      DisplayName := 'PDF-Dateien (*.pdf)';
      FileMask := '*.pdf';
    end;
    with Dialog.FileTypes.Add do
    begin
      DisplayName := 'Alle Dateien (*.*)';
      FileMask := '*.*';
    end;
    Dialog.Options := Dialog.Options + [fdoFileMustExist, fdoPathMustExist, fdoAllowMultiSelect];
    if not Dialog.Execute then Exit;
    for I := 0 to Dialog.Files.Count - 1 do
    begin
      PDF := TPDFBrowserForm.Create(Application);
      try
        PDF.PDFFileName := Dialog.Files[I];
        PDF.StandalonePDFMode := False;
        AddPDF(PDF);
        LastOpenedPDF := PDF;
      except
        PDF.Free;
        raise;
      end;
    end;
    // Nur bei explizitem "PDF öffnen" zur zuletzt geöffneten PDF wechseln.
    // Stapelimporte aus Suche und Hauptfenster behalten ihre Auswahl.
    if LastOpenedPDF <> nil then
      ActivatePDF(LastOpenedPDF);
  finally
    Dialog.Free;
  end;
end;

procedure TPDFTabsForm.LoadClosedPDFs;
var
  Ini: TIniFile;
  I, Count: Integer;
  FileName: string;
begin
  FClosedPDFs.Clear;
  Ini := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'FreePDF64.ini');
  try
    Count := Ini.ReadInteger('ClosedPDFs', 'Count', 0);
    if Count < 0 then Count := 0;
    if Count > 20 then Count := 20;
    for I := 1 to Count do
    begin
      FileName := Trim(Ini.ReadString('ClosedPDFs', 'File' + IntToStr(I), ''));
      if (FileName <> '') and (FClosedPDFs.IndexOf(FileName) < 0) then
        FClosedPDFs.Add(FileName);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TPDFTabsForm.SaveClosedPDFs;
var
  Ini: TIniFile;
  I, N: Integer;
begin
  Ini := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'FreePDF64.ini');
  try
    // Nur den eigenen Abschnitt aktualisieren; andere Einstellungen erhalten.
    Ini.EraseSection('ClosedPDFs');
    N := FClosedPDFs.Count;
    if N > 20 then N := 20;
    Ini.WriteInteger('ClosedPDFs', 'Count', N);
    for I := 0 to N - 1 do
      Ini.WriteString('ClosedPDFs', 'File' + IntToStr(I + 1),
        FClosedPDFs[FClosedPDFs.Count - 1 - I]);
  finally
    Ini.Free;
  end;
end;

constructor TPDFTabsForm.Create(AOwner: TComponent);
var
  Header: TPanel;
  SearchArea: TPanel;
  Dpi: Integer;
  ButtonHeight: Integer;
begin
  inherited CreateNew(AOwner);
  Dpi := CurrentPPI;
  if Dpi < 96 then Dpi := 96;
  ButtonHeight := Max(MulDiv(26, Dpi, 96), Canvas.TextHeight('Ag') + MulDiv(10, Dpi, 96));
  PDFTabsWindow := Self;
  FClosedPDFs := TStringList.Create;
  LoadClosedPDFs;
  FTabContextMenu := TPopupMenu.Create(Self);
  FTabContextMenu.OnPopup := TabContextPopup;
  FReopenClosedItem := TMenuItem.Create(FTabContextMenu);
  // Untermenü wird bei jedem Öffnen aus den letzten 20 PDFs aufgebaut.
  FTabContextMenu.Items.Add(FReopenClosedItem);
  // Normales Fenster, keine TopMost-Eigenschaft.
  FormStyle := fsNormal;
  BorderStyle := bsSizeable;
  Constraints.MinWidth := 450;
  Constraints.MinHeight := 300;
  PopupMode := pmNone;
  Caption := 'FreePDF64-Viewer';
  Width := 1100;
  Height := 800;
  Position := poDesigned;
  DoubleBuffered := True;
  Header := TPanel.Create(Self);
  Header.Parent := Self;
  Header.Align := alTop;
  Header.Height := ButtonHeight + MulDiv(6, Dpi, 96);
  Header.BevelOuter := bvNone;
  FCloseButton := TButton.Create(Self);
  FCloseButton.Parent := Header;
  FCloseButton.Align := alRight;
  FCloseButton.Width := Max(MulDiv(185, Dpi, 96), Canvas.TextWidth('Aktiven Tab schließen') + MulDiv(28, Dpi, 96));
  FCloseButton.Caption := 'Aktiven Tab schließen';
  FCloseButton.OnClick := CloseActive;
  FTabs := TPageControl.Create(Self);
  FTabs.Parent := Self;
  // Das native Register-Control verarbeitet den freien Streifen selbst.
  // WM_CONTEXTMENU erfasst deshalb auch Rechtsklicks neben den Tabs.
  FOriginalTabsWindowProc := FTabs.WindowProc;
  FTabs.WindowProc := TabsWindowProc;
  Header.PopupMenu := FTabContextMenu;
  FTabs.DoubleBuffered := True;
  FTabs.Align := alClient;
  FDragTabIndex := -1;
  FDraggingTab := False;
  FTabs.OnMouseDown := TabMouseDown;
  FTabs.OnMouseUp := TabMouseUp;
  FTabs.ShowHint := False; // Pfad niemals als vererbbarer VCL-Hint
  FTabHintWindow := THintWindow.Create(Self);
  FHintTabIndex := -1;
  FTabs.OnMouseMove := TabsMouseMove;
  FTabs.OnMouseLeave := TabsMouseLeave;
  FTabs.OnChange := TabsChange;
  FTabs.OnResize := TabsResized;
  FTabs.OwnerDraw := True;
  FTabs.OnDrawTab := DrawPDFTab;
  // Die freie Registerleiste ist bei TPageControl nicht in allen
  // Windows/VCL-Versionen zuverlässig über dessen Mausereignisse erreichbar.
  // Ein eigenes Steuerelement deckt ausschließlich den freien Bereich ab.
  FEmptyTabStrip := TPanel.Create(Self);
  FEmptyTabStrip.Parent := FTabs;
  FEmptyTabStrip.BevelOuter := bvNone;
  FEmptyTabStrip.Caption := '';
  FEmptyTabStrip.Color := clBtnFace;
  FEmptyTabStrip.Cursor := crDefault;
  FEmptyTabStrip.OnMouseUp := EmptyTabStripMouseUp;
  UpdateEmptyTabStrip;
  FOpenButton := TButton.Create(Self);
  FOpenButton.Parent := Header;
  FOpenButton.Align := alLeft;
  FOpenButton.Width := Max(MulDiv(180, Dpi, 96), Canvas.TextWidth('Datei(en) öffnen ...') + MulDiv(28, Dpi, 96));
  FOpenButton.Caption := 'Datei(en) öffnen ...';
  FOpenButton.Hint := '... auch alle anderen Dateitypen';
  FOpenButton.ShowHint := True;
  FOpenButton.OnClick := OpenPDFClick;
  // Hauptprogramm im selben Prozess sichtbar machen.
  FMainProgramButton := TButton.Create(Self);
  FMainProgramButton.Parent := Header;
  FMainProgramButton.Align := alLeft;
  FMainProgramButton.Width := Max(MulDiv(170, Dpi, 96),
    Canvas.TextWidth('FreePDF64 öffnen') + MulDiv(28, Dpi, 96));
  FMainProgramButton.Caption := 'FreePDF64 öffnen';
  FMainProgramButton.Hint := 'FreePDF64-Hauptprogramm öffnen';
  FMainProgramButton.ShowHint := True;
  FMainProgramButton.OnClick := OpenMainProgramClick;
  // Eigener rechter Bereich: feste Positionen unabhaengig von der
  // VCL-Ausrichtungsreihenfolge anderer Header-Steuerelemente.
  SearchArea := TPanel.Create(Self);
  SearchArea.Parent := Header;
  SearchArea.Align := alRight;
  SearchArea.Width := MulDiv(90, Dpi, 96);
  SearchArea.BevelOuter := bvNone;
  FTabCountBadge := TPaintBox.Create(Self);
  FTabCountBadge.Parent := SearchArea;
  FTabCountBadge.Align := alClient;
  FTabCountBadge.Hint := 'Anzahl geöffneter PDF-Registerkarten';
  FTabCountBadge.ShowHint := True;
  FTabCountBadge.OnPaint := PaintTabCountBadge;
  FTabSearchButton := TButton.Create(Self);
  FTabSearchButton.Parent := SearchArea;
  FTabSearchButton.Align := alRight;
  FTabSearchButton.Width := MulDiv(42, Dpi, 96);
  FTabSearchButton.Caption := '⌕';
  FTabSearchButton.Hint := 'Geöffnete PDF-Registerkarten suchen (Strg+Umsch+A)';
  FTabSearchButton.ShowHint := True;
  FTabSearchButton.OnClick := TabSearchClick;
  FTabSearchForm := TForm.CreateNew(Self);
  // Suchfenster dem PDF-Anzeiger zuordnen, nicht dem FreePDF64-Hauptfenster.
  FTabSearchForm.PopupMode := pmExplicit;
  FTabSearchForm.PopupParent := Self;
  FTabSearchForm.BorderStyle := bsToolWindow;
  FTabSearchForm.Position := poDesigned;
  FTabSearchForm.Caption := 'PDF-Registerkarten suchen';
  FTabSearchForm.ClientWidth := MulDiv(370, Dpi, 96);
  FTabSearchForm.ClientHeight := MulDiv(300, Dpi, 96);
  // Kein automatisches Ausblenden bei Fokuswechsel: sonst oeffnet der
  // Bei Fokuswechsel ausserhalb der Suche ausblenden.
  // Klick auf die Lupe wird gesondert behandelt (Toggle).
  FTabSearchForm.OnDeactivate := TabSearchDeactivate;
  FTabSearchEdit := TEdit.Create(FTabSearchForm);
  FTabSearchEdit.Parent := FTabSearchForm;
  FTabSearchEdit.Align := alTop;
  FTabSearchEdit.TextHint := 'Dateiname eingeben ...';
  FTabSearchEdit.OnChange := TabSearchChanged;
  FTabSearchEdit.OnKeyDown := TabSearchKeyDown;
  FTabSearchList := TListBox.Create(FTabSearchForm);
  FTabSearchList.Parent := FTabSearchForm;
  FTabSearchList.Align := alClient;
  FTabSearchList.OnDblClick := TabSearchChoose;
  FTabSearchList.OnMouseMove := TabSearchListMouseMove;
  FTabSearchList.OnKeyDown := TabSearchKeyDown;
  FTabSearchList.ShowHint := True;
  FPendingExplorerFiles := TStringList.Create;
  FExplorerBatchTimer := TTimer.Create(Self);
  FExplorerBatchTimer.Enabled := False;
  FExplorerBatchTimer.Interval := 350;
  FExplorerBatchTimer.OnTimer := ExplorerBatchTimerTick;
  FDeferredActivePDF := nil;
  FInitialWindowOffscreen := False;
  FActivationTimer := TTimer.Create(Self);
  FActivationTimer.Enabled := False;
  FActivationTimer.Interval := 250;
  FActivationTimer.OnTimer := ActivationTimerTick;
  LoadWindowSettings;
  OnClose := TabsFormClose;
end;

procedure TPDFTabsForm.PaintTabCountBadge(Sender: TObject);
var
  C: TCanvas;
  R: TRect;
  S: string;
  TextX, TextY, Radius, Pad: Integer;
begin
  if (FTabCountBadge = nil) or (FTabs = nil) then Exit;
  C := FTabCountBadge.Canvas;
  C.Brush.Color := FTabCountBadge.Parent.Brush.Color;
  C.FillRect(FTabCountBadge.ClientRect);

  Pad := MulDiv(6, CurrentPPI, 96);
  R := Rect(Pad, MulDiv(7, CurrentPPI, 96),
    FTabCountBadge.Width - Pad, FTabCountBadge.Height - MulDiv(7, CurrentPPI, 96));
  Radius := MulDiv(14, CurrentPPI, 96);
  C.Pen.Style := psClear;
  C.Brush.Color := RGB(225, 236, 250);
  C.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Radius, Radius);
  C.Brush.Style := bsClear;
  C.Font.Name := 'Segoe UI';
  C.Font.Size := 10;
  C.Font.Style := [fsBold];
  C.Font.Color := RGB(35, 85, 145);
  S := IntToStr(FTabs.PageCount);
  TextX := R.Left + (R.Right - R.Left - C.TextWidth(S)) div 2;
  TextY := R.Top + (R.Bottom - R.Top - C.TextHeight(S)) div 2;
  C.TextOut(TextX, TextY, S);
  C.Brush.Style := bsSolid;
  C.Pen.Style := psSolid;
end;

procedure TPDFTabsForm.UpdateTabCount;
begin
  UpdateEmptyTabStrip;
  if FTabCountBadge <> nil then
    FTabCountBadge.Invalidate;
end;

procedure TPDFTabsForm.TabSearchClick(Sender: TObject);
var
  P: TPoint;
begin
  if FTabSearchForm.Visible then
  begin
    FTabSearchForm.Hide;
    Exit;
  end;
  FTabSearchEdit.Clear;
  TabSearchChanged(nil);
  P := FTabSearchButton.ClientToScreen(Point(FTabSearchButton.Width, FTabSearchButton.Height));
  FTabSearchForm.Left := P.X - FTabSearchForm.Width;
  FTabSearchForm.Top := P.Y;
  FTabSearchForm.Show;
  FTabSearchEdit.SetFocus;
end;

procedure TPDFTabsForm.TabSearchChanged(Sender: TObject);
var
  I: Integer;
  Tab: TTabSheet;
  Filter: string;
begin
  Filter := Trim(FTabSearchEdit.Text);
  FTabSearchList.Items.BeginUpdate;
  try
    FTabSearchList.Clear;
    for I := 0 to FTabs.PageCount - 1 do
    begin
      Tab := FTabs.Pages[I];
      if (Filter = '') or (Pos(UpperCase(Filter), UpperCase(Tab.Caption)) > 0) then
        FTabSearchList.Items.AddObject(Tab.Caption, Tab);
    end;
    // Den aktiven PDF-Tab in der Suchliste vorauswaehlen.
    // Bei einem Filter ohne Treffer fuer den aktiven Tab den ersten Treffer nehmen.
    FTabSearchList.ItemIndex := -1;
    for I := 0 to FTabSearchList.Count - 1 do
      if FTabSearchList.Items.Objects[I] = FTabs.ActivePage then
      begin
        FTabSearchList.ItemIndex := I;
        Break;
      end;
    if (FTabSearchList.ItemIndex < 0) and (FTabSearchList.Count > 0) then
      FTabSearchList.ItemIndex := 0;
  finally
    FTabSearchList.Items.EndUpdate;
  end;
end;

procedure TPDFTabsForm.TabSearchListMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
  Tab: TTabSheet;
  FullName: string;
begin
  Index := FTabSearchList.ItemAtPos(Point(X, Y), True);
  if Index >= 0 then
  begin
    Tab := TTabSheet(FTabSearchList.Items.Objects[Index]);
    FullName := '';
    if Tab <> nil then
      FullName := ExtractFileName(Tab.Hint);
    if FullName = '' then
      FullName := FTabSearchList.Items[Index];
  end
  else
    FullName := '';

  if FTabSearchList.Hint <> FullName then
  begin
    FTabSearchList.Hint := FullName;
    // Bereits angezeigte Hinweise beim Wechsel auf einen anderen Eintrag aktualisieren.
    Application.CancelHint;
  end;
end;

procedure TPDFTabsForm.TabSearchChoose(Sender: TObject);
var
  Tab, PreviousTab: TTabSheet;
  J: Integer;
  PreviousPDF: TPDFBrowserForm;
begin
  if FTabSearchList.ItemIndex < 0 then Exit;
  Tab := TTabSheet(FTabSearchList.Items.Objects[FTabSearchList.ItemIndex]);
  FTabSearchForm.Hide;
  if (Tab <> nil) and (Tab.PageControl = FTabs) then
  begin
    PreviousTab := FTabs.ActivePage;
    // Bei einem Wechsel ueber die Lupensuche die Anlagenliste der
    // bisher aktiven PDF sofort ausblenden (vor dem Registerwechsel).
    if (PreviousTab <> nil) and (PreviousTab <> Tab) then
      for J := 0 to PreviousTab.ControlCount - 1 do
        if PreviousTab.Controls[J] is TPDFBrowserForm then
        begin
          PreviousPDF := TPDFBrowserForm(PreviousTab.Controls[J]);
          if IsWindow(PreviousPDF.AttachmentWindowHandle) then
            ShowWindow(PreviousPDF.AttachmentWindowHandle, SW_HIDE);
          Break;
        end;
    FTabs.ActivePage := Tab;
    RefreshAttachmentPositions;
    LoadSelectedPDF;
    FTabs.SetFocus;
  end;
end;

procedure TPDFTabsForm.TabSearchKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        FTabSearchForm.Hide;
        Key := 0;
      end;
    VK_RETURN:
      begin
        TabSearchChoose(Sender);
        Key := 0;
      end;
    VK_DOWN:
      if Sender = FTabSearchEdit then
      begin
        if FTabSearchList.Count > 0 then FTabSearchList.SetFocus;
        Key := 0;
      end;
  end;
end;

procedure TPDFTabsForm.TabSearchDeactivate(Sender: TObject);
var
  CursorPos: TPoint;
  ButtonRect: TRect;
begin
  if (FTabSearchForm = nil) or not FTabSearchForm.Visible then
    Exit;

  // Beim Klick auf die Lupe nicht vorzeitig schliessen: Der folgende
  // OnClick-Handler soll die noch sichtbare Suche selbst ausblenden.
  GetCursorPos(CursorPos);
  ButtonRect.TopLeft := FTabSearchButton.ClientToScreen(Point(0, 0));
  ButtonRect.BottomRight := FTabSearchButton.ClientToScreen(
    Point(FTabSearchButton.Width, FTabSearchButton.Height));
  if PtInRect(ButtonRect, CursorPos) then
    Exit;

  FTabSearchForm.Hide;
end;

procedure TPDFTabsForm.WMViewerActivate(var Msg: TWMActivate);
begin
  inherited;
  if Msg.Active <> WA_INACTIVE then
  begin
    if (FTabSearchButton <> nil) and not FLocalTabSearchHotkeyRegistered then
      FLocalTabSearchHotkeyRegistered := RegisterHotKey(Handle,
        LOCAL_TAB_SEARCH_HOTKEY_ID, MOD_CONTROL or MOD_SHIFT or MOD_NOREPEAT,
        Ord('A'));
  end
  else if FLocalTabSearchHotkeyRegistered then
  begin
    UnregisterHotKey(Handle, LOCAL_TAB_SEARCH_HOTKEY_ID);
    FLocalTabSearchHotkeyRegistered := False;
  end;
end;

procedure TPDFTabsForm.WMViewerHotKey(var Msg: TMessage);
begin
  if Msg.WParam = LOCAL_TAB_SEARCH_HOTKEY_ID then
  begin
    if (GetForegroundWindow = Handle) and Visible then
      TabSearchClick(FTabSearchButton);
    Msg.Result := 0;
  end
  else
    inherited;
end;

destructor TPDFTabsForm.Destroy;
begin
  if FLocalTabSearchHotkeyRegistered then
  begin
    UnregisterHotKey(Handle, LOCAL_TAB_SEARCH_HOTKEY_ID);
    FLocalTabSearchHotkeyRegistered := False;
  end;
  FExplorerBatchTimer.Enabled := False;
  FActivationTimer.Enabled := False;
  RestoreInitialWindow;
  FPendingExplorerFiles.Free;
  ClearAllPDFTabs;
  if FTabs <> nil then
    FTabs.WindowProc := FOriginalTabsWindowProc;
  FClosedPDFs.Free;
  if PDFTabsWindow = Self then
    PDFTabsWindow := nil;
  inherited Destroy;
end;

procedure TPDFTabsForm.BringViewerToForeground;
begin
  // Explorer-Aufruf: Fenster sichtbar machen, ohne dauerhaft TopMost zu sein.
  if FInitialWindowOffscreen then
    RestoreInitialWindow;
  if IsIconic(Handle) then
    ShowWindow(Handle, SW_RESTORE)
  else if not Visible then
    Show;
  // Windows kann SetForegroundWindow bei fremden Prozessen verweigern.
  // Kurzes Anheben in der Z-Reihenfolge stellt die Sichtbarkeit sicher.
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
  SetWindowPos(Handle, HWND_NOTOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
  BringToFront;
  SetForegroundWindow(Handle);
end;

procedure TPDFTabsForm.RestoreInitialWindow;
begin
  if not FInitialWindowOffscreen then Exit;
  FInitialWindowOffscreen := False;
  FRestoringWindowSettings := True;
  try
    WindowState := wsNormal;
    SetBounds(FInitialWindowBounds.Left, FInitialWindowBounds.Top,
      FInitialWindowBounds.Right - FInitialWindowBounds.Left,
      FInitialWindowBounds.Bottom - FInitialWindowBounds.Top);
    if FInitialWindowMaximized then WindowState := wsMaximized;
  finally
    FRestoringWindowSettings := False;
  end;
  ShowWindow(Handle, SW_SHOWNORMAL);
  if FInitialWindowMaximized then ShowWindow(Handle, SW_SHOWMAXIMIZED);
  SetForegroundWindow(Handle);
end;

procedure TPDFTabsForm.ActivationTimerTick(Sender: TObject);
var
  FirstPDF: TPDFBrowserForm;
  FirstTab: TTabSheet;
  I: Integer;
begin
  if (FTabs = nil) or (FTabs.PageCount = 0) then
  begin
    FActivationTimer.Enabled := False;
    FDeferredActivePDF := nil;
    RestoreInitialWindow;
    Exit;
  end;
  FirstPDF := nil;
  FirstTab := FTabs.Pages[0];
  for I := 0 to FirstTab.ControlCount - 1 do
    if FirstTab.Controls[I] is TPDFBrowserForm then
    begin
      FirstPDF := TPDFBrowserForm(FirstTab.Controls[I]);
      Break;
    end;
  Inc(FActivationChecks);
  // Die erste PDF muss mindestens ihren ersten WebView2-Navigationsaufruf
  // erhalten haben, bevor wir zu einer anderen Registerkarte wechseln.
  if (FirstPDF <> nil) and (not FirstPDF.PDFNavigationSucceeded) and
     (FActivationChecks < 80) then
  begin
    FirstPDF.RequestPDFLoad;
    Exit;
  end;
  FActivationTimer.Enabled := False;
  // Die Startinitialisierung gilt nur fuer das erste PDF dieses Fensters.
  FFirstPDFInitialized := True;
  if (FDeferredActivePDF <> nil) and
     (FDeferredActivePDF.Parent is TTabSheet) and
     (TTabSheet(FDeferredActivePDF.Parent).PageControl = FTabs) then
  begin
    FAddingPDF := True;
    try
      FTabs.ActivePage := TTabSheet(FDeferredActivePDF.Parent);
    finally
      FAddingPDF := False;
    end;
    PostMessage(Handle, WM_APP + 193, 0, 0);
  end;
  FDeferredActivePDF := nil;
  FTabs.Invalidate;
  RestoreInitialWindow;
end;

procedure TPDFTabsForm.ClearAllPDFTabs;
var
  Tab: TTabSheet;
  I: Integer;
  PDF: TPDFBrowserForm;
begin
  if FTabs = nil then Exit;
  FActivationTimer.Enabled := False;
  FDeferredActivePDF := nil;
  while FTabs.PageCount > 0 do
  begin
    Tab := FTabs.Pages[FTabs.PageCount - 1];
    for I := Tab.ControlCount - 1 downto 0 do
      if Tab.Controls[I] is TPDFBrowserForm then
      begin
        PDF := TPDFBrowserForm(Tab.Controls[I]);
        // Eingebettetes Fenster nicht vorher abkoppeln: kein kurzzeitig
        // sichtbares eigenstaendiges Fenster beim Aufraeumen.
        PDF.Free;
      end;
    Tab.Free;
  end;
  UpdateTabCount;
end;

procedure TPDFTabsForm.GetOpenPDFFileNames(AFiles: TStrings);
var
  I: Integer;
  FileName: string;
begin
  if AFiles = nil then Exit;
  for I := 0 to FTabs.PageCount - 1 do
  begin
    FileName := FTabs.Pages[I].Hint;
    if (FileName <> '') and FileExists(FileName) then
      AFiles.Add(FileName);
  end;
end;

procedure TPDFTabsForm.OpenMainProgramClick(Sender: TObject);
begin
  // Der vorhandene Callback setzt PDFTabsMainFormWasShown und aktiviert
  // das bereits initialisierte Hauptformular. Kein zweiter Prozess.
  if Assigned(PDFTabsShowMainForm) then
    PDFTabsShowMainForm(Self);
end;

procedure TPDFTabsForm.TabsFormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  // Fenster zuerst ausblenden, dann die WebView2-Registerkarten
  // unsichtbar abbauen. Sonst flackert der Viewer bei vielen PDFs.
  SaveWindowSettings;
  Action := caHide;
  if FTabSearchForm <> nil then
    FTabSearchForm.Hide;
  Hide;
  ClearAllPDFTabs;
  if PDFTabsExplorerOnlyProcess and not PDFTabsMainFormWasShown then
    Application.Terminate;
end;

procedure TPDFTabsForm.WMLoadActivePDF(var Msg: TMessage);
begin
  // Erst nach dem aktuellen Stapel von AddPDF-Aufrufen laden.
  // Dadurch wird nicht fuer jede kurzzeitig aktive Seite ein Browser gestartet.
  if not (csDestroying in ComponentState) then
    LoadSelectedPDF;
end;

procedure TPDFTabsForm.AddPDF(APDF: TPDFBrowserForm);
var
  Tab: TTabSheet;
begin
  Tab := TTabSheet.Create(FTabs);
  Tab.PageControl := FTabs;
  UpdateTabCount;
  Tab.DoubleBuffered := True;
  Tab.Caption := ExtractFileName(APDF.PDFFileName);
  Tab.Hint := APDF.PDFFileName;
  Tab.ShowHint := False; // Kein geerbter Dateipfad-Hint im PDF-Inhaltsbereich
  APDF.TabbedPDFMode := True;
  APDF.BorderStyle := bsNone;
  APDF.Parent := Tab;
  APDF.Align := alClient;
  // Lazy Loading: Alle Register anlegen, aber ausschliesslich das
  // jeweils aktive PDF initialisieren. Kein unsichtbarer Erst-Tab-Start.
  FAddingPDF := True;
  try
    FTabs.ActivePage := Tab;
  finally
    FAddingPDF := False;
  end;
  if not Visible then
  begin
    LoadWindowSettings;
    Show;
  end;
  APDF.Show;
  FTabs.Realign;
  APDF.Realign;
  FFirstPDFInitialized := True;
  FDeferredActivePDF := nil;
  FActivationTimer.Enabled := False;
  PostMessage(Handle, WM_APP + 193, 0, 0);
  if Assigned(PDFTabAttachmentsInitializer) then
    PDFTabAttachmentsInitializer(APDF.PDFFileName, APDF);
  APDF.UpdateAttachmentWindowPosition;
  // Bei nur einer PDF darf das Fenster nicht ausserhalb des Monitors
  // verbleiben. Die erste Registerkarte ist bereits eingebettet und
  // sichtbar; fuer sie ist kein Registerwechsel abzuwarten.
  if (FTabs.PageCount = 1) and FInitialWindowOffscreen then
  begin
    FActivationTimer.Enabled := False;
    FDeferredActivePDF := nil;
    RestoreInitialWindow;
  end;
end;

procedure TPDFTabsForm.ActivatePDF(APDF: TPDFBrowserForm);
begin
  if (APDF = nil) or not (APDF.Parent is TTabSheet) or
     (TTabSheet(APDF.Parent).PageControl <> FTabs) then Exit;
  FActivationTimer.Enabled := False;
  FDeferredActivePDF := nil;
  FFirstPDFInitialized := True;
  FAddingPDF := True;
  try
    FTabs.ActivePage := TTabSheet(APDF.Parent);
  finally
    FAddingPDF := False;
  end;
  PostMessage(Handle, WM_APP + 193, 0, 0);
end;

procedure TPDFTabsForm.RefreshAttachmentPositions;
var
  I, J: Integer;
  Tab: TTabSheet;
begin
  if FTabs = nil then Exit;
  for I := 0 to FTabs.PageCount - 1 do
  begin
    Tab := FTabs.Pages[I];
    for J := 0 to Tab.ControlCount - 1 do
      if Tab.Controls[J] is TPDFBrowserForm then
      begin
        if Tab <> FTabs.ActivePage then
        begin
          // Die Anlagenliste gehoert zur vorherigen PDF und darf nicht
          // ueber der neu aktivierten Registerkarte sichtbar bleiben.
          if IsWindow(TPDFBrowserForm(Tab.Controls[J]).AttachmentWindowHandle) then
          begin
            ShowWindow(TPDFBrowserForm(Tab.Controls[J]).AttachmentWindowHandle,
              SW_HIDE);
            SetWindowPos(
              TPDFBrowserForm(Tab.Controls[J]).AttachmentWindowHandle,
              HWND_NOTOPMOST, 0, 0, 0, 0,
              SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
          end;
        end
        else
        begin
          TPDFBrowserForm(Tab.Controls[J]).RefreshActiveTabPDF;
          TPDFBrowserForm(Tab.Controls[J]).UpdateAttachmentWindowPosition;
        end;
      end;
  end;
end;

procedure TPDFTabsForm.LoadSelectedPDF;
var
  I: Integer;
  Tab: TTabSheet;
begin
  if FAddingPDF or (FTabs = nil) then Exit;
  Tab := FTabs.ActivePage;
  if Tab = nil then Exit;
  for I := 0 to Tab.ControlCount - 1 do
    if Tab.Controls[I] is TPDFBrowserForm then
    begin
      TPDFBrowserForm(Tab.Controls[I]).RequestPDFLoad;
      Break;
    end;
end;

procedure TPDFTabsForm.TabMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    FDragTabIndex := -1;
    FDraggingTab := False;
    PostMessage(Handle, WM_APP + 193, 0, 0);
  end;
end;

procedure TPDFTabsForm.TabsResized(Sender: TObject);
begin
  UpdateEmptyTabStrip;
end;

procedure TPDFTabsForm.UpdateEmptyTabStrip;
var
  R: TRect;
  LeftEdge, StripHeight: Integer;
begin
  if (FTabs = nil) or (FEmptyTabStrip = nil) then Exit;
  StripHeight := MulDiv(28, CurrentPPI, 96);
  LeftEdge := 0;
  if FTabs.PageCount > 0 then
  begin
    if SendMessage(FTabs.Handle, TCM_GETITEMRECT,
      WPARAM(FTabs.PageCount - 1), LPARAM(@R)) <> 0 then
    begin
      LeftEdge := R.Right + 1;
      StripHeight := R.Bottom;
    end;
  end;
  if StripHeight < 1 then Exit;
  FEmptyTabStrip.SetBounds(LeftEdge, 0,
    Max(0, FTabs.ClientWidth - LeftEdge), StripHeight);
  FEmptyTabStrip.Visible := FEmptyTabStrip.Width > 0;
  if FEmptyTabStrip.Visible then
    FEmptyTabStrip.BringToFront;
end;

procedure TPDFTabsForm.EmptyTabStripMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  if Button <> mbRight then Exit;
  P := FEmptyTabStrip.ClientToScreen(Point(X, Y));
  FTabContextMenu.Popup(P.X, P.Y);
end;

procedure TPDFTabsForm.TabsWindowProc(var Msg: TMessage);
var
  P: TPoint;
  LocalP: TPoint;
  TabStripBottom: Integer;
  TabRect: TRect;
begin
  // TPageControl.OnDblClick ist protected. Den Doppelklick daher
  // direkt im bereits vorhandenen WindowProc-Hook behandeln.
  if Msg.Msg = WM_LBUTTONDBLCLK then
  begin
    LocalP := Point(SmallInt(LOWORD(Msg.LParam)),
                    SmallInt(HIWORD(Msg.LParam)));
    if FTabs.IndexOfTabAt(LocalP.X, LocalP.Y) >= 0 then
    begin
      TabDoubleClick(FTabs);
      Msg.Result := 0;
      Exit;
    end;
  end;
  if (Msg.Msg = WM_CONTEXTMENU) or (Msg.Msg = WM_RBUTTONUP) then
  begin
    // WM_CONTEXTMENU kommt vom nativen Windows-Tabcontrol auch dann,
    // wenn der Mauszeiger rechts von der letzten Registerkarte steht.
    if Msg.Msg = WM_RBUTTONUP then
    begin
      LocalP := Point(SmallInt(LOWORD(Msg.LParam)),
                      SmallInt(HIWORD(Msg.LParam)));
      P := FTabs.ClientToScreen(LocalP);
    end
    else
    begin
      GetCursorPos(P);
      LocalP := FTabs.ScreenToClient(P);
    end;
    // Nur der obere Registerstreifen, nicht die PDF-Anzeigeflaeche.
    // Die native Tab-Steuerung liefert die untere Kante des ersten Reiters.
    // Kein Zugriff auf die protected Eigenschaft DisplayRect.
    TabStripBottom := MulDiv(30, Screen.PixelsPerInch, 96);
    if (FTabs.PageCount > 0) and
       (SendMessage(FTabs.Handle, TCM_GETITEMRECT, 0, LPARAM(@TabRect)) <> 0) then
      TabStripBottom := TabRect.Bottom;
    if (LocalP.X >= 0) and (LocalP.X < FTabs.ClientWidth) and
       (LocalP.Y >= 0) and (LocalP.Y < TabStripBottom) then
    begin
      FTabContextMenu.Popup(P.X, P.Y);
      Msg.Result := 0;
      Exit;
    end;
  end;
  FOriginalTabsWindowProc(Msg);
end;

procedure TPDFTabsForm.DrawPDFTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  R: TRect;
  S: string;
  VisualActive: Boolean;
begin
  if (TabIndex < 0) or (TabIndex >= FTabs.PageCount) then Exit;
  R := Rect;
  VisualActive := Active;
  // Während die erste PDF technisch aktiv bleibt, zeigen die Reiter
  // bereits den später vorgesehenen aktiven Tab an. Nur Darstellung.
  if (FDeferredActivePDF <> nil) and
     (FDeferredActivePDF.Parent is TTabSheet) and
     (FTabs.PageCount > 1) then
    VisualActive := FTabs.Pages[TabIndex] = TTabSheet(FDeferredActivePDF.Parent);
  if VisualActive then
  begin
    FTabs.Canvas.Brush.Color := RGB(211, 231, 249);
    FTabs.Canvas.Font.Color := RGB(25, 63, 99);
    FTabs.Canvas.Font.Style := [fsBold];
  end
  else
  begin
    FTabs.Canvas.Brush.Color := RGB(229, 233, 238);
    FTabs.Canvas.Font.Color := RGB(69, 78, 88);
    FTabs.Canvas.Font.Style := [];
  end;
  FTabs.Canvas.FillRect(R);
  S := FTabs.Pages[TabIndex].Caption;
  InflateRect(R, -7, -2);
  DrawText(FTabs.Canvas.Handle, PChar(S), Length(S), R,
    DT_SINGLELINE or DT_VCENTER or DT_CENTER or DT_END_ELLIPSIS);
end;

procedure TPDFTabsForm.TabsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  TabIndex: Integer;
  HintText: string;
  P: TPoint;
  R: TRect;
begin
  // Registerkarten mit linker Maustaste verschieben (erst nach Ziehschwelle).
  if (FDragTabIndex >= 0) and (ssLeft in Shift) then
  begin
    if not FDraggingTab then
      FDraggingTab :=
        (Abs(X - FDragStartPoint.X) >= GetSystemMetrics(SM_CXDRAG)) or
        (Abs(Y - FDragStartPoint.Y) >= GetSystemMetrics(SM_CYDRAG));

    if FDraggingTab then
    begin
      TabsMouseLeave(Sender);
      TabIndex := FTabs.IndexOfTabAt(X, Y);
      if (TabIndex >= 0) and (TabIndex < FTabs.PageCount) and
         (TabIndex <> FDragTabIndex) then
      begin
        // Das TabSheet (und damit die zugehoerige PDF) bleibt erhalten.
        FTabs.Pages[FDragTabIndex].PageIndex := TabIndex;
        FDragTabIndex := TabIndex;
        FTabs.Invalidate;
      end;
      Exit;
    end;
  end;

  // Kein FTabs.Hint: Dieser wuerde auf die PDF-Navigationsleiste vererbt.
  TabIndex := FTabs.IndexOfTabAt(X, Y);
  if (TabIndex < 0) or (TabIndex >= FTabs.PageCount) then
  begin
    TabsMouseLeave(Sender);
    Exit;
  end;

  if TabIndex = FHintTabIndex then
    Exit;

  FTabHintWindow.ReleaseHandle;
  FHintTabIndex := TabIndex;
  HintText := FTabs.Pages[TabIndex].Hint;
  if HintText = '' then
    Exit;

  P := FTabs.ClientToScreen(Point(X, Y + MulDiv(20, CurrentPPI, 96)));
  R := FTabHintWindow.CalcHintRect(700, HintText, nil);
  OffsetRect(R, P.X, P.Y);
  FTabHintWindow.ActivateHint(R, HintText);
end;

procedure TPDFTabsForm.TabsMouseLeave(Sender: TObject);
begin
  FHintTabIndex := -1;
  if Assigned(FTabHintWindow) then
    FTabHintWindow.ReleaseHandle;
end;

procedure TPDFTabsForm.TabsChange(Sender: TObject);
begin
  if not FAddingPDF then
  begin
    FActivationTimer.Enabled := False;
    FDeferredActivePDF := nil;
  end;
  RefreshAttachmentPositions;
  PostMessage(Handle, WM_APP + 193, 0, 0); // Tastaturwechsel.
end;

procedure TPDFTabsForm.WindowMoved(var Msg: TWMMove);
begin
  inherited;
  RememberNormalBounds;
  RefreshAttachmentPositions;
end;

procedure TPDFTabsForm.WindowSized(var Msg: TWMSize);
begin
  inherited;
  RememberNormalBounds;
  RefreshAttachmentPositions;
end;

procedure TPDFTabsForm.TabContextPopup(Sender: TObject);
var
  I: Integer;
  Item: TMenuItem;
begin
  // Liste bei jedem Rechtsklick frisch aufbauen, neueste PDF zuerst.
  FReopenClosedItem.Clear;
  FReopenClosedItem.Caption := 'Geschlossene PDFs wieder öffnen';
  FReopenClosedItem.Enabled := FClosedPDFs.Count > 0;
  for I := FClosedPDFs.Count - 1 downto 0 do
  begin
    Item := TMenuItem.Create(FReopenClosedItem);
    Item.Caption := ExtractFileName(FClosedPDFs[I]);
    Item.Hint := FClosedPDFs[I];
    Item.Tag := I;
    Item.OnClick := ReopenSelectedClosedPDF;
    FReopenClosedItem.Add(Item);
  end;
end;

procedure TPDFTabsForm.ReopenSelectedClosedPDF(Sender: TObject);
var
  Index: Integer;
  FileName: string;
begin
  if not (Sender is TMenuItem) then Exit;
  Index := TMenuItem(Sender).Tag;
  if (Index < 0) or (Index >= FClosedPDFs.Count) then Exit;
  // Bestehende Wiederherstellungsroutine weiterverwenden.
  // Erst nach erfolgreichem Öffnen wird der Eintrag entfernt.
  FileName := FClosedPDFs[Index];
  FClosedPDFs.Delete(Index);
  FClosedPDFs.Add(FileName);
  ReopenLastClosedPDF(Sender);
end;

procedure TPDFTabsForm.ReopenLastClosedPDF(Sender: TObject);
var
  FileName: string;
  PDF: TPDFBrowserForm;
begin
  if FClosedPDFs.Count = 0 then Exit;
  FileName := FClosedPDFs[FClosedPDFs.Count - 1];
  if not FileExists(FileName) then
  begin
    MessageDlg('Die PDF-Datei existiert nicht mehr:' + sLineBreak + FileName,
      mtWarning, [mbOK], 0);
    Exit;
  end;
  PDF := TPDFBrowserForm.Create(Application);
  try
    PDF.PDFFileName := FileName;
    PDF.StandalonePDFMode := False;
    AddPDF(PDF);
    FClosedPDFs.Delete(FClosedPDFs.Count - 1);
    SaveClosedPDFs;
    BringViewerToForeground;
  except
    PDF.Free;
    raise;
  end;
end;

procedure TPDFTabsForm.CloseActive(Sender: TObject);
var
  Tab: TTabSheet;
  PDF: TPDFBrowserForm;
  I: Integer;
  ClosedIndex, NextIndex: Integer;
begin
  Tab := FTabs.ActivePage;
  if Tab = nil then Exit;
  ClosedIndex := Tab.PageIndex;
  // Ein noch ausstehender Wechsel darf nicht auf ein geschlossenes PDF zeigen.
  FActivationTimer.Enabled := False;
  FDeferredActivePDF := nil;
  PDF := nil;
  for I := 0 to Tab.ControlCount - 1 do
    if Tab.Controls[I] is TPDFBrowserForm then
    begin
      PDF := TPDFBrowserForm(Tab.Controls[I]);
      Break;
    end;
  if PDF <> nil then
  begin
    if PDF.PDFFileName <> '' then
    begin
      // Bereits bekannte Datei entfernen, damit sie nur einmal erscheint.
      I := FClosedPDFs.IndexOf(PDF.PDFFileName);
      if I >= 0 then FClosedPDFs.Delete(I);
      FClosedPDFs.Add(PDF.PDFFileName);
      if FClosedPDFs.Count > 20 then
        FClosedPDFs.Delete(0);
      SaveClosedPDFs;
    end;
    // Vor dem Entfernen des Parent unsichtbar machen. Sonst wird
    // das eingebettete Formular kurz ein eigenstaendiges Fenster
    // und kann das Registerkartenfenster nach hinten verdraengen.
    PDF.Hide;
    PDF.Parent := nil;
    PDF.Close;
  end;
  Tab.Free;
  UpdateTabCount;
  if FTabs.PageCount > 0 then
  begin
    // Rechten Nachbarn bevorzugen. Nach Tab.Free rueckt er auf
    // den bisherigen Index nach. Nur beim letzten Tab nach links.
    if ClosedIndex < FTabs.PageCount then
      NextIndex := ClosedIndex
    else
      NextIndex := FTabs.PageCount - 1;
    FAddingPDF := True;
    try
      FTabs.ActivePageIndex := NextIndex;
    finally
      FAddingPDF := False;
    end;
    PostMessage(Handle, WM_APP + 193, 0, 0);
    // Nach dem Schliessen die verbleibende PDF wieder aktivieren.
    RefreshAttachmentPositions;
    if Visible and HandleAllocated then
    begin
      BringToFront;
      SetForegroundWindow(Handle);
    end;
  end;
  if FTabs.PageCount = 0 then
  begin
    FFirstPDFInitialized := False;
    if PDFTabsExplorerOnlyProcess then
    begin
      if PDFTabsMainFormWasShown then
        Hide
      else
        Close;
    end
    else if Application.MainForm = Self then
      Close
    else
      Hide;
  end;
end;

procedure TPDFTabsForm.TabDoubleClick(Sender: TObject);
var
  P: TPoint;
  TabIndex: Integer;
begin
  // Nur Doppelklick direkt auf einem Register, nicht auf der freien Leiste.
  GetCursorPos(P);
  P := FTabs.ScreenToClient(P);
  TabIndex := FTabs.IndexOfTabAt(P.X, P.Y);
  if (TabIndex < 0) or (TabIndex >= FTabs.PageCount) then Exit;
  FTabs.ActivePageIndex := TabIndex;
  CloseActive(Sender);
end;

procedure TPDFTabsForm.TabMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  if Button = mbLeft then
  begin
    FDragTabIndex := FTabs.IndexOfTabAt(X, Y);
    FDragStartPoint := Point(X, Y);
    FDraggingTab := False;
    Exit;
  end;
  if Button <> mbMiddle then Exit;
  for I := 0 to FTabs.PageCount - 1 do
    if PtInRect(FTabs.TabRect(I), Point(X, Y)) then
    begin
      FTabs.ActivePageIndex := I;
      CloseActive(Sender);
      Break;
    end;
end;

procedure ShowEmptyPDFViewer;
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  CmdLine: string;
begin
  // Vom Hauptprogramm aus einen unabhaengigen Viewer starten. Dieser
  // ueberlebt das Beenden des Hauptprogramms (auch ohne geoeffnete PDF).
  if not PDFTabsExplorerOnlyProcess and
     ((PDFTabsWindow = nil) or not PDFTabsWindow.Visible) then
  begin
    CmdLine := '"' + ParamStr(0) + '" --viewer-empty';
    FillChar(SI, SizeOf(SI), 0);
    SI.cb := SizeOf(SI);
    FillChar(PI, SizeOf(PI), 0);
    if CreateProcess(PChar(ParamStr(0)), PChar(CmdLine), nil, nil,
      False, 0, nil, nil, SI, PI) then
    begin
      CloseHandle(PI.hThread);
      CloseHandle(PI.hProcess);
      Exit;
    end;
    MessageDlg('Der eigenstaendige PDF-Anzeiger konnte nicht gestartet werden.',
      mtError, [mbOK], 0);
    Exit;
  end;
  if PDFTabsWindow = nil then
    PDFTabsWindow := TPDFTabsForm.Create(Application);
  if not PDFTabsWindow.Visible then
  begin
    PDFTabsWindow.LoadWindowSettings;
    PDFTabsWindow.Show;
  end
  else
  begin
    if PDFTabsWindow.WindowState = wsMinimized then
      PDFTabsWindow.WindowState := wsNormal;
    PDFTabsWindow.BringToFront;
  end;
end;

procedure ShowPDFInTabs(APDF: TPDFBrowserForm);
begin
  if PDFTabsWindow = nil then
    PDFTabsWindow := TPDFTabsForm.Create(Application);
  PDFTabsWindow.AddPDF(APDF);
  // Auch beim Aufruf aus Hauptprogramm/Suche den PDF-Anzeiger aktivieren.
  // Keine dauerhafte TopMost-Einstellung: andere Fenster bleiben nutzbar.
  if not PDFTabsWindow.FInitialWindowOffscreen then
  begin
    if IsIconic(PDFTabsWindow.Handle) then
      ShowWindow(PDFTabsWindow.Handle, SW_RESTORE);
    PDFTabsWindow.BringToFront;
    SetForegroundWindow(PDFTabsWindow.Handle);
  end;
end;

end.
