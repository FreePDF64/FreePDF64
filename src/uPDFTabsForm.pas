unit uPDFTabsForm;

interface

uses
  System.SysUtils, System.Classes, System.Types, Winapi.Windows, Winapi.Messages, Winapi.CommCtrl, Winapi.ShellAPI,
  Vcl.Forms, Vcl.Controls, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics,
  Vcl.Dialogs, Vcl.Menus, Vcl.Imaging.jpeg, System.IniFiles, System.Win.Registry, Math,
  uPDFBrowserForm;

type
  // Mausrad auch dann an den Hilfetext weitergeben, wenn der Schließen-Button
  // den Tastaturfokus besitzt.
  TViewerHelpForm = class(TForm)
  public
    HelpScroll: TScrollBox;
  protected
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
  end;

  TPDFTabsForm = class(TForm)
  private
    FTabs: TPageControl;
    FWelcomePanel: TPanel;
    FWelcomeImage: TImage;
    FWelcomeTitle: TLabel;
    FWelcomeHint: TLabel;
    FWelcomeOpenButton: TButton;
    FEmptyTabStrip: TPanel;
    FViewerHeader: TPanel;
    FTabActionsPanel: TPanel;
    FFileMenu: TMenuItem;
    FOptionsMenu: TMenuItem;
    FFullScreen: Boolean;
    FFullScreenBounds: TRect;
    FFullScreenWindowState: TWindowState;
    FFullScreenBorderStyle: TFormBorderStyle;
    FFullScreenTabsVisible: Boolean;
    FFullScreenEmptyStripVisible: Boolean;
    FUpdatingTabLayout: Boolean;
    FOriginalTabsWindowProc: TWndMethod;
    FClosedPDFs: TStringList;
    FSessionPDFs: TStringList;
    FRestoreSessionItem: TMenuItem;
    FTabContextMenu: TPopupMenu;
    FReopenClosedItem: TMenuItem;
    FTabHintWindow: THintWindow;
    FHintTabIndex: Integer;
    FHoverCloseTabIndex: Integer;
    FDragTabIndex: Integer;
    FDragStartPoint: TPoint;
    FDraggingTab: Boolean;
    FHelpMainMenu: TMainMenu;
    FTrayPopup: TPopupMenu;
    FTrayMenuItem: TMenuItem;
    FTrayEnabled: Boolean;
    FTrayVisible: Boolean;
    FExitFromTray: Boolean;
    FOpenButton: TButton;
    FMainProgramButton: TButton;
    FTabSearchButton: TButton;
    FLocalTabSearchHotkeyRegistered: Boolean;
    FLocalTextSearchHotkeyRegistered: Boolean;
    FTabCountBadge: TPaintBox;
    FTabSearchForm: TForm;
    FTabSearchEdit: TEdit;
    FTabSearchList: TListBox;
    FLastNormalBounds: TRect;
    FRestoringWindowSettings: Boolean;
    FAddingPDF: Boolean;
    FPendingExplorerFiles: TStringList;
    FExplorerBatchTimer: TTimer;
    FCreatedPDFForegroundTimer: TTimer;
    FDeferredActivePDF: TPDFBrowserForm;
    FActivationTimer: TTimer;
    FActivationChecks: Integer;
    FFirstPDFInitialized: Boolean;
    FInitialWindowOffscreen: Boolean;
    FInitialWindowBounds: TRect;
    FInitialWindowMaximized: Boolean;
    procedure ShowModernInfo(AAbout: Boolean);
    procedure ShowAboutViewer(Sender: TObject);
    procedure PDFVerknuepfungClick(Sender: TObject);
    procedure ToggleTrayMode(Sender: TObject);
    procedure RestoreFromTray(Sender: TObject);
    procedure ExitFromTray(Sender: TObject);
    procedure SetTrayIcon(AVisible: Boolean);
    procedure WMTrayCallback(var Msg: TMessage); message WM_APP + 195;
    procedure ShowViewerHelp(Sender: TObject);
    procedure UpdateWelcomeView;
    procedure WelcomeResize(Sender: TObject);
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure TabsWindowProc(var Msg: TMessage);
    procedure WMViewerActivate(var Msg: TWMActivate); message WM_ACTIVATE;
    procedure WMViewerHotKey(var Msg: TMessage); message WM_HOTKEY;
    procedure UpdateEmptyTabStrip;
    procedure PositionTabActions;
    procedure TabsResized(Sender: TObject);
    procedure EmptyTabStripMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TabContextPopup(Sender: TObject);
    procedure LoadClosedPDFs;
    procedure SaveClosedPDFs;
    procedure UpdateClosedPDFHistory(const AFileName: string; AAdd: Boolean);
    procedure LoadPDFSession;
    procedure SavePDFSession;
    procedure RestorePDFSession(Sender: TObject);
    procedure ReopenLastClosedPDF(Sender: TObject);
    procedure ReopenSelectedClosedPDF(Sender: TObject);
    procedure ActivationTimerTick(Sender: TObject);
    procedure ExplorerBatchTimerTick(Sender: TObject);
    procedure CreatedPDFForegroundTimerTick(Sender: TObject);
    procedure QueueCreatedPDFForeground;
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
    function ConfirmCloseUnsavedPDFs(AOnlyActive: Boolean): Boolean;
    procedure ApplyShownWindowSettings(var Msg: TMessage); message WM_APP + 194;
    procedure TabsFormShow(Sender: TObject);
    procedure LoadWindowSettings;
    procedure SaveWindowSettings;
    procedure RememberNormalBounds;
    procedure CloseActive(Sender: TObject);
    procedure CloseTabAt(AIndex: Integer);
    function TabCloseRect(AIndex: Integer): TRect;
    procedure ViewerKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ToggleFullScreen;
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
    function IsShortCut(var Message: TWMKey): Boolean; override;
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
    procedure AddAttachmentPDF(APDF: TPDFBrowserForm; ASource: TPDFBrowserForm);
    procedure ActivatePDF(APDF: TPDFBrowserForm);
    procedure ShowCreatedPDFInForeground;
    procedure HideAllAttachmentWindows;
    procedure GetOpenPDFFileNames(AFiles: TStrings);
    function ActivateExistingPDF(const AFileName: string): Boolean;
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
function SendPDFToExternalTabs(const AFileName: string): Boolean;
procedure ActivateExternalCreatedPDFViewer;
function ActivateRunningMainProgram: Boolean;
procedure MarkMainProgramWindow(Wnd: HWND);

var
  PDFTabsShowMainForm: TNotifyEvent = nil;

implementation

uses uPDFAttachmentTemp;

const
  LOCAL_TAB_SEARCH_HOTKEY_ID = $5A71;
  LOCAL_TEXT_SEARCH_HOTKEY_ID = $5A72;
  PDFTabWindowMarker = 'FreePDF64.PDFTabs.Window.v1';
  PDFTabMessageId = $46504446;
  PDFCreatedMessageId = $46504447;
  MainProgramWindowMarker = 'FreePDF64.MainProgram.Window.v1';

function FindMainWindowCallback(Wnd: HWND; Data: LPARAM): BOOL; stdcall;
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
  EnumWindows(@FindMainWindowCallback, LPARAM(@Wnd));
  Result := (Wnd <> 0) and IsWindow(Wnd);
  if not Result then
    Exit;

  // Dem Hauptprogramm die Vordergrundaktivierung gestatten.
  // Die eigentliche Aktivierung erfolgt in dessen Nachrichten-Thread.
  TargetPID := 0;
  GetWindowThreadProcessId(Wnd, @TargetPID);
  if TargetPID <> 0 then
    AllowSetForegroundWindow(TargetPID);
  PostMessage(Wnd, WM_APP + 194, 0, 0);
end;

procedure MarkMainProgramWindow(Wnd: HWND);
begin
  if Wnd <> 0 then
    SetProp(Wnd, PChar(MainProgramWindowMarker), THandle(1));
end;


function FindTabsWindowCallback(Wnd: HWND; Data: LPARAM): BOOL; stdcall;
begin
  Result := True;
  if GetProp(Wnd, PChar(PDFTabWindowMarker)) <> 0 then
  begin
    PPointer(Data)^ := Pointer(Wnd);
    Result := False;
  end;
end;

type
  PExternalPDFWindowSearch = ^TExternalPDFWindowSearch;
  TExternalPDFWindowSearch = record
    Wnd: HWND;
    CurrentPID: DWORD;
  end;

function FindExternalTabsWindowCallback(Wnd: HWND; Data: LPARAM): BOOL; stdcall;
var
  Search: PExternalPDFWindowSearch;
  PID: DWORD;
begin
  Result := True;
  Search := PExternalPDFWindowSearch(Data);
  if GetProp(Wnd, PChar(PDFTabWindowMarker)) = 0 then Exit;
  PID := 0;
  GetWindowThreadProcessId(Wnd, @PID);
  if (PID <> 0) and (PID <> Search^.CurrentPID) then
  begin
    Search^.Wnd := Wnd;
    Result := False;
  end;
end;

function SendPDFToExternalTabs(const AFileName: string): Boolean;
var
  Search: TExternalPDFWindowSearch;
  Data: TCopyDataStruct;
  Path: string;
  Reply: DWORD_PTR;
  TargetPID: DWORD;
begin
  Result := False;
  Search.Wnd := 0;
  Search.CurrentPID := GetCurrentProcessId;
  EnumWindows(@FindExternalTabsWindowCallback, LPARAM(@Search));
  if (Search.Wnd = 0) or not IsWindow(Search.Wnd) then Exit;
  Path := ExpandFileName(AFileName);
  if not FileExists(Path) then Exit;
  Data.dwData := PDFCreatedMessageId;
  Data.cbData := (Length(Path) + 1) * SizeOf(Char);
  Data.lpData := PChar(Path);
  TargetPID := 0;
  GetWindowThreadProcessId(Search.Wnd, @TargetPID);
  if TargetPID <> 0 then AllowSetForegroundWindow(TargetPID);
  // Bei der PDF-Erstellung erst NACH Abschluss aller Hauptfenster-
  // Aktualisierungen aktivieren, sonst holt FreePDF64 sich den Fokus zurueck.
  Reply := 0;
  Result := (SendMessageTimeout(Search.Wnd, WM_COPYDATA, 0,
    LPARAM(@Data), SMTO_ABORTIFHUNG or SMTO_BLOCK, 4000, @Reply) <> 0)
    and (Reply = 1);
end;

procedure ActivateExternalCreatedPDFViewer;
var
  Search: TExternalPDFWindowSearch;
begin
  Search.Wnd := 0;
  Search.CurrentPID := GetCurrentProcessId;
  EnumWindows(@FindExternalTabsWindowCallback, LPARAM(@Search));
  if (Search.Wnd = 0) or not IsWindow(Search.Wnd) then Exit;
  if IsIconic(Search.Wnd) then ShowWindow(Search.Wnd, SW_RESTORE);
  SetWindowPos(Search.Wnd, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
  SetWindowPos(Search.Wnd, HWND_NOTOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
  SetForegroundWindow(Search.Wnd);
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
     ((Msg.CopyDataStruct^.dwData <> PDFTabMessageId) and
      (Msg.CopyDataStruct^.dwData <> PDFCreatedMessageId)) or
     (Msg.CopyDataStruct^.lpData = nil) or
     (Msg.CopyDataStruct^.cbData < 2 * SizeOf(Char)) or
     (Msg.CopyDataStruct^.cbData mod SizeOf(Char) <> 0) then Exit;
  SetString(FileName, PChar(Msg.CopyDataStruct^.lpData),
    Msg.CopyDataStruct^.cbData div SizeOf(Char) - 1);
  if not SameText(ExtractFileExt(FileName), '.pdf') or
     not FileExists(FileName) then Exit;
  // Niemals im synchronen WM_COPYDATA-Handler PDFium-Forms erstellen.
  FPendingExplorerFiles.Add(FileName);
  // Explorer uebergibt mehrere markierte PDFs oft als einzelne WM_COPYDATA-
  // Nachrichten. Erst nach einer kurzen Empfangspause den Stapel verarbeiten.
  FExplorerBatchTimer.Enabled := False;
  FExplorerBatchTimer.Enabled := True;
  // Nur bei normalen Oeffnungen sofort aktivieren. Bei erstellten
  // PDFs aktiviert das Hauptprogramm erst ganz am Ende den Viewer.
  if Msg.CopyDataStruct^.dwData = PDFTabMessageId then
    BringViewerToForeground;
  Msg.Result := 1;
end;

procedure TPDFTabsForm.QueueCreatedPDFForeground;
begin
  // Keine verzoegerte Aktivierung: vermeidet sichtbares Nach-vorne-Springen.
  FCreatedPDFForegroundTimer.Enabled := False;
end;

procedure TPDFTabsForm.CreatedPDFForegroundTimerTick(Sender: TObject);
begin
  FCreatedPDFForegroundTimer.Enabled := False;
  if (FTabs <> nil) and (FTabs.PageCount > 0) then
    BringViewerToForeground;
end;

procedure TPDFTabsForm.ExplorerBatchTimerTick(Sender: TObject);
begin
  FExplorerBatchTimer.Enabled := False;
  if FPendingExplorerFiles.Count > 0 then
    PostMessage(Handle, WM_APP + 192, 0, 0);
end;

function TPDFTabsForm.ActivateExistingPDF(const AFileName: string): Boolean;
var
  I: Integer;
  Tab: TTabSheet;
  FullName: string;
begin
  Result := False;
  if FTabs = nil then Exit;
  FullName := ExpandFileName(AFileName);
  for I := 0 to FTabs.PageCount - 1 do
  begin
    Tab := FTabs.Pages[I];
    if SameText(ExpandFileName(Tab.Hint), FullName) then
    begin
      FTabs.ActivePage := Tab;
      if not Visible then Show;
      if IsIconic(Handle) then ShowWindow(Handle, SW_RESTORE);
      PostMessage(Handle, WM_APP + 193, 0, 0);
      BringViewerToForeground;
      Result := True;
      Exit;
    end;
  end;
end;

procedure TPDFTabsForm.WMOpenQueuedPDF(var Msg: TMessage);
var
  FileName: string;
  PDF: TPDFBrowserForm;
  LastOpenedPDF: TPDFBrowserForm;
begin
  // Bereits wartende Explorer-Nachrichten vor dem Anlegen verarbeiten.
  // Der Timer sorgt dafuer, dass ein zusammengehoeriger Dateistapel
  // gesammelt wird, bevor die erste PDFium-Instanz starten kann.
  FExplorerBatchTimer.Enabled := False;
  LastOpenedPDF := nil;
  while FPendingExplorerFiles.Count > 0 do
  begin
    FileName := FPendingExplorerFiles[0];
    FPendingExplorerFiles.Delete(0);
    if not FileExists(FileName) then Continue;
    if ActivateExistingPDF(FileName) then Continue;
    PDF := nil;
    try
      PDF := TPDFBrowserForm.Create(nil);
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
  begin
    BringViewerToForeground;
  end;
end;

function TabsIniFileName: string;
begin
  // Alle Viewer-Einstellungen in der gemeinsamen INI im Programmverzeichnis.
  Result := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
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
      W := Ini.ReadInteger('PDFTabsFenster', 'Breite', 1100);
      H := Ini.ReadInteger('PDFTabsFenster', 'Hoehe', 800);
      L := Ini.ReadInteger('PDFTabsFenster', 'Links', (Screen.Width - W) div 2);
      T := Ini.ReadInteger('PDFTabsFenster', 'Oben', (Screen.Height - H) div 2);
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
      if Ini.ReadBool('PDFTabsFenster', 'Maximiert', False) then
        WindowState := wsMaximized;
    finally
      Ini.Free;
    end;
  finally
    FRestoringWindowSettings := False;
  end;
end;

procedure TPDFTabsForm.TabsFormShow(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
  UpdateWelcomeView;
  // Erst nach der VCL-Anzeige wiederherstellen: Explorer und F1 verwenden
  // unterschiedliche Startwege, aber beide durchlaufen OnShow.
  PostMessage(Handle, WM_APP + 194, 0, 0);
end;

procedure TPDFTabsForm.ApplyShownWindowSettings(var Msg: TMessage);
begin
  if not Visible or FInitialWindowOffscreen then Exit;
  LoadWindowSettings;
  // Nach der VCL-Initialisierung die tatsächliche Fenstergeometrie setzen.
  if WindowState = wsMaximized then
    ShowWindow(Handle, SW_SHOWMAXIMIZED)
  else
    SetWindowPos(Handle, 0, Left, Top, Width, Height,
      SWP_NOZORDER or SWP_NOACTIVATE);
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
    Ini.WriteInteger('PDFTabsFenster', 'Links', R.Left);
    Ini.WriteInteger('PDFTabsFenster', 'Oben', R.Top);
    Ini.WriteInteger('PDFTabsFenster', 'Breite', R.Right - R.Left);
    Ini.WriteInteger('PDFTabsFenster', 'Hoehe', R.Bottom - R.Top);
    Ini.WriteBool('PDFTabsFenster', 'Maximiert', WindowState = wsMaximized);
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
      PDF := TPDFBrowserForm.Create(nil);
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
    for I := Count downto 1 do
    begin
      FileName := Trim(Ini.ReadString('ClosedPDFs', 'File' + IntToStr(I), ''));
      if (FileName <> '') and (FClosedPDFs.IndexOf(FileName) < 0) then
        FClosedPDFs.Add(FileName);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TPDFTabsForm.LoadPDFSession;
var
  Ini: TIniFile;
  I, N: Integer;
  S: string;
begin
  FSessionPDFs.Clear;
  Ini := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'FreePDF64.ini');
  try
    N := Ini.ReadInteger('PDFSession', 'Count', 0);
    if N < 0 then N := 0;
    if N > 200 then N := 200;
    for I := 1 to N do
    begin
      S := Trim(Ini.ReadString('PDFSession', 'File' + IntToStr(I), ''));
      if (S <> '') and (FSessionPDFs.IndexOf(S) < 0) then
        FSessionPDFs.Add(S);
    end;
  finally
    Ini.Free;
  end;
end;

function IsFreePDFTempAttachment(const AFileName: string): Boolean;
begin
  Result := Pos('FreePDF64_Attachment_', ExtractFileName(AFileName)) = 1;
end;

procedure TPDFTabsForm.SavePDFSession;
var
  Ini: TIniFile;
  Files: TStringList;
  I: Integer;
  S: string;
begin
  Files := TStringList.Create;
  try
    // Registerkarten in ihrer Reihenfolge sichern, auch bei Netzlaufwerken.
    // Keine FileExists-Pruefung: kurzzeitig unerreichbare NAS-Pfade behalten.
    for I := 0 to FTabs.PageCount - 1 do
    begin
      S := Trim(FTabs.Pages[I].Hint);
      if (S <> '') and not IsFreePDFTempAttachment(S) and (Files.IndexOf(S) < 0) then
        Files.Add(S);
    end;
    Ini := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'FreePDF64.ini');
    try
      Ini.EraseSection('PDFSession');
      Ini.WriteInteger('PDFSession', 'Count', Files.Count);
      for I := 0 to Files.Count - 1 do
        Ini.WriteString('PDFSession', 'File' + IntToStr(I + 1), Files[I]);
    finally
      Ini.Free;
    end;
    FSessionPDFs.Assign(Files);
  finally
    Files.Free;
  end;
end;

procedure TPDFTabsForm.RestorePDFSession(Sender: TObject);
var
  I: Integer;
  S: string;
  PDF: TPDFBrowserForm;
  Missing: TStringList;
  OpenFiles: TStringList;
begin
  Missing := TStringList.Create;
  OpenFiles := TStringList.Create;
  try
    // Keine Datei zweimal oeffnen.
    for I := 0 to FTabs.PageCount - 1 do
      if FTabs.Pages[I].Hint <> '' then
        OpenFiles.Add(FTabs.Pages[I].Hint);
    for I := 0 to FSessionPDFs.Count - 1 do
    begin
      S := FSessionPDFs[I];
      if OpenFiles.IndexOf(S) >= 0 then Continue;
      if not FileExists(S) then
      begin
        Missing.Add(S);
        Continue;
      end;
      PDF := TPDFBrowserForm.Create(nil);
      try
        PDF.PDFFileName := S;
        PDF.StandalonePDFMode := False;
        AddPDF(PDF);
        OpenFiles.Add(S);
      except
        PDF.Free;
        raise;
      end;
    end;
    if Missing.Count > 0 then
      MessageDlg(IntToStr(Missing.Count) +
        ' PDF-Datei(en) der letzten Sitzung sind derzeit nicht erreichbar.' +
        sLineBreak + 'Die gespeicherten Pfade bleiben erhalten.',
        mtWarning, [mbOK], 0);
  finally
    OpenFiles.Free;
    Missing.Free;
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

procedure TPDFTabsForm.UpdateClosedPDFHistory(const AFileName: string;
  AAdd: Boolean);
var
  Mutex: THandle;
  WaitResult: DWORD;
  I: Integer;
begin
  if Trim(AFileName) = '' then Exit;
  // Alle Viewer-Prozesse lesen/aendern/schreiben den Verlauf atomar.
  Mutex := CreateMutex(nil, False, 'Local\FreePDF64_ClosedPDFs_Lock');
  if Mutex = 0 then
    RaiseLastOSError;
  try
    WaitResult := WaitForSingleObject(Mutex, INFINITE);
    if (WaitResult <> WAIT_OBJECT_0) and
       (WaitResult <> WAIT_ABANDONED) then
      raise Exception.Create('ClosedPDFs-Sperre konnte nicht erworben werden.');
    try
      LoadClosedPDFs;
      // Windows-Dateipfade ohne Beachtung der Gross-/Kleinschreibung vergleichen.
      for I := FClosedPDFs.Count - 1 downto 0 do
        if SameText(FClosedPDFs[I], AFileName) then
          FClosedPDFs.Delete(I);
      if AAdd then
      begin
        FClosedPDFs.Add(AFileName);
        while FClosedPDFs.Count > 20 do
          FClosedPDFs.Delete(0);
      end;
      SaveClosedPDFs;
    finally
      ReleaseMutex(Mutex);
    end;
  finally
    CloseHandle(Mutex);
  end;
end;

function ViewerExeVersion: string;
var
  InfoSize, Dummy: DWORD;
  Info: TBytes;
  FixedInfo: PVSFixedFileInfo;
  FixedLen: UINT;
begin
  Result := 'nicht verfügbar';
  InfoSize := GetFileVersionInfoSize(PChar(Application.ExeName), Dummy);
  if InfoSize = 0 then Exit;
  SetLength(Info, InfoSize);
  if not GetFileVersionInfo(PChar(Application.ExeName), 0, InfoSize, @Info[0]) then Exit;
  FixedInfo := nil;
  FixedLen := 0;
  if VerQueryValue(@Info[0], '\', Pointer(FixedInfo), FixedLen) and
     (FixedInfo <> nil) and (FixedLen >= SizeOf(TVSFixedFileInfo)) and
     (FixedInfo^.dwSignature = $FEEF04BD) then
    Result := Format('%d.%d.%d.%d',
      [HiWord(FixedInfo^.dwFileVersionMS), LoWord(FixedInfo^.dwFileVersionMS),
       HiWord(FixedInfo^.dwFileVersionLS), LoWord(FixedInfo^.dwFileVersionLS)]);
end;

function TViewerHelpForm.DoMouseWheel(Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint): Boolean;
var
  NewPos, Step: Integer;
begin
  if HelpScroll = nil then
  begin
    Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
    Exit;
  end;
  Step := MulDiv(60, HelpScroll.CurrentPPI, 96);
  NewPos := HelpScroll.VertScrollBar.Position - MulDiv(WheelDelta, Step, WHEEL_DELTA);
  HelpScroll.VertScrollBar.Position := EnsureRange(NewPos, 0,
    Max(0, HelpScroll.VertScrollBar.Range - HelpScroll.ClientHeight));
  Result := True;
end;

procedure TPDFTabsForm.ShowModernInfo(AAbout: Boolean);
var
  D: TForm;
  TopPanel, BottomPanel, BodyPanel: TPanel;
  Scroll: TScrollBox;
  TitleLabel, SubLabel: TLabel;
  Btn: TButton;
  Img: TImage;
  Y, Scale: Integer;
  function Px(V: Integer): Integer;
  begin
    Result := MulDiv(V, Scale, 96);
  end;
  procedure AddSection(const ATitle, ABody: string);
  var
    Card: TPanel;
    Head, Body: TLabel;
    BodyHeight, CardHeight, ContentWidth: Integer;
  begin
    ContentWidth := Max(Px(320), Scroll.ClientWidth - Px(62));
    Card := TPanel.Create(D);
    Card.Parent := Scroll;
    Card.BevelOuter := bvNone;
    Card.ParentBackground := False;
    Card.Color := RGB(244, 248, 253);
    Card.SetBounds(Px(22), Y + Px(12), ContentWidth, Px(90));

    Head := TLabel.Create(D);
    Head.Parent := Card;
    Head.SetBounds(Px(18), Px(13), ContentWidth - Px(36), Px(24));
    Head.Font.Name := 'Segoe UI';
    Head.Font.Size := 11;
    Head.Font.Style := [fsBold];
    Head.Font.Color := RGB(24, 83, 150);
    Head.ShowAccelChar := False;
    Head.Caption := ATitle;

    Body := TLabel.Create(D);
    Body.Parent := Card;
    Body.AutoSize := False;
    Body.WordWrap := True;
    Body.ShowAccelChar := False; // & ist Text, kein Zugriffstasten-Marker.
    Body.Font.Name := 'Segoe UI';
    Body.Font.Size := 10;
    Body.Font.Color := RGB(44, 55, 70);
    Body.SetBounds(Px(18), Px(43), ContentWidth - Px(36), Px(40));
    Body.Caption := ABody;
    // Calculate text wrapping using the label's preferred height.
    Body.AutoSize := True;
    Body.Width := ContentWidth - Px(36);
    BodyHeight := Max(Px(30), Body.Height);
    Body.AutoSize := False;
    Body.Height := BodyHeight;
    CardHeight := Px(51) + BodyHeight + Px(12);
    Card.Height := CardHeight;
    Inc(Y, CardHeight + Px(12));
  end;
begin
  D := TViewerHelpForm.CreateNew(Self);
  try
    Scale := CurrentPPI;
    if Scale < 96 then Scale := 96;
    D.Font.Name := 'Segoe UI';
    D.Font.Size := 10;
    D.Color := clWhite;
    D.Position := poOwnerFormCenter;
    D.BorderStyle := bsSizeable;
    D.Caption := 'FreePDF64-Viewer - ' + 'Hilfe';
    if AAbout then D.Caption := 'Über FreePDF64-Viewer';
    D.ClientWidth := Px(750);
    D.ClientHeight := Px(620);
    D.Constraints.MinWidth := Px(600);
    D.Constraints.MinHeight := Px(400);
    D.KeyPreview := True;

    TopPanel := TPanel.Create(D);
    TopPanel.Parent := D;
    TopPanel.Align := alTop;
    TopPanel.Height := Px(112);
    TopPanel.BevelOuter := bvNone;
    TopPanel.ParentBackground := False;
    TopPanel.Color := RGB(19, 93, 169);

    Img := TImage.Create(D);
    Img.Parent := TopPanel;
    Img.SetBounds(Px(24), Px(24), Px(54), Px(54));
    Img.Picture.Icon.Assign(Application.Icon);
    Img.Stretch := True;

    TitleLabel := TLabel.Create(D);
    TitleLabel.Parent := TopPanel;
    TitleLabel.SetBounds(Px(95), Px(26), Px(555), Px(35));
    TitleLabel.Font.Name := 'Segoe UI';
    TitleLabel.Font.Size := 19;
    TitleLabel.Font.Style := [fsBold];
    TitleLabel.Font.Color := clWhite;
    if AAbout then TitleLabel.Caption := 'FreePDF64-Viewer'
    else TitleLabel.Caption := 'Funktionsübersicht';

    SubLabel := TLabel.Create(D);
    SubLabel.Parent := TopPanel;
    SubLabel.SetBounds(Px(97), Px(68), Px(540), Px(24));
    SubLabel.Font.Size := 10;
    SubLabel.Font.Color := RGB(224, 237, 250);
    if AAbout then SubLabel.Caption := 'Version ' + ViewerExeVersion + ' · Portable PDF-Anwendung für Windows 64-Bit'
    else SubLabel.Caption := 'Alles Wichtige auf einen Blick';

    BottomPanel := TPanel.Create(D);
    BottomPanel.Parent := D;
    BottomPanel.Align := alBottom;
    BottomPanel.Height := Px(66);
    BottomPanel.BevelOuter := bvNone;
    BottomPanel.ParentBackground := False;
    BottomPanel.Color := RGB(230, 239, 249);

    Btn := TButton.Create(D);
    Btn.Parent := BottomPanel;
    Btn.Caption := 'Schließen';
    Btn.ModalResult := mrOk;
    Btn.Default := True;
    Btn.Cancel := True; // ESC schließt beide Dialoge.
    Btn.SetBounds(D.ClientWidth - Px(156), Px(15), Px(125), Px(35));
    Btn.Anchors := [akRight, akTop];

    BodyPanel := TPanel.Create(D);
    BodyPanel.Parent := D;
    BodyPanel.Align := alClient;
    BodyPanel.BevelOuter := bvNone;
    BodyPanel.Color := clWhite;
    BodyPanel.ParentBackground := False;

    Scroll := TScrollBox.Create(D);
    TViewerHelpForm(D).HelpScroll := Scroll;
    Scroll.Parent := BodyPanel;
    Scroll.Align := alClient;
    Scroll.BorderStyle := bsNone;
    Scroll.Color := RGB(250, 252, 255);
    Scroll.ParentBackground := False;
    Scroll.VertScrollBar.Tracking := True;
    Y := Px(6);
    if AAbout then
    begin
      AddSection('Version', ViewerExeVersion);
      AddSection('Über das Programm',
        'Eigenständiger PDF-Viewer mit Registerkarten, Dokumenteigenschaften, Anlagenverwaltung und PDF-Werkzeugen.');
      AddSection('Copyright und Kontakt',
        'Copyright © 2026 FreePDF64' + sLineBreak + 'FreePDF64@outlook.com');
      AddSection('Projektseite', 'https://github.com/FreePDF64');
      AddSection('Zusatzprogramme und Bibliotheken',
        'PDFium, qpdf und Xpdf (pdfdetach). Für diese Komponenten gelten die jeweiligen Lizenzbedingungen.');
      AddSection('Einstellungsdatei',
        IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'FreePDF64.ini');
      AddSection('Programmdatei', Application.ExeName);
    end
    else
    begin
      AddSection('PDF-Dateien öffnen',
        'Über „Datei → PDF öffnen …“, Strg+O oder per Drag&Drop. Mehrere PDFs werden in eigenen Tabs geöffnet.');
      AddSection('Geschlossene PDFs und Sitzung wiederherstellen',
        'Klicken Sie auf der leeren Startseite mit der rechten Maustaste. '
        + 'Unter „Geschlossene PDFs wieder öffnen“ finden Sie zuletzt geschlossene Dokumente. '
        + '„Letzte PDF-Sitzung wiederherstellen“ öffnet die zuvor gespeicherte Sitzung. '
        + 'Nicht verfügbare Einträge sind ausgegraut.');
      AddSection('Tabs verwalten',
        'Das × im Tab, die mittlere Maustaste oder Strg+W schließen ein PDF. Bei ungespeicherten Änderungen erscheint eine Rückfrage.');
      AddSection('Anzeige und Navigation',
        'Mit der PDF-Werkzeugleiste Seiten wechseln, zoomen, Seiten einpassen, zwei Seiten oder die durchgehende Anzeige wählen.');
      AddSection('Text suchen',
        'Die Suchfunktion durchsucht das PDF. F3 springt zum nächsten Treffer.');
      AddSection('Bearbeiten und Speichern',
        '„Bearbeiten“ öffnet die Markierungs- und Zeichenwerkzeuge. Änderungen mit „Speichern unter ...“ sichern.');
      AddSection('Anlagen und Dokumenteigenschaften',
        'Die Viewer-Schaltflächen zeigen eingebettete Anlagen sowie Eigenschaften und Sicherheitsinformationen. Für das Extrahieren wird xpdf\bin64\pdfdetach.exe verwendet.');
      AddSection('Drucken und Zusatzwerkzeuge',
        'Drucken erfolgt über die PDF-Werkzeugleiste. Weitere Funktionen benötigen pdfium.dll und qpdf\bin\qpdf.exe.');
      AddSection('Protokolldatei',
        'Der Viewer protokolliert Aktionen der Anlagenverwaltung in der Datei FreePDF64ViewerLog.txt. '
        + 'Sie liegt im selben Ordner wie die EXE und wird bei Bedarf angelegt oder ergänzt. '
        + 'Der Ordner muss dafür beschreibbar sein.');
      AddSection('Portable Einstellungen',
        'FreePDF64.ini liegt neben der EXE. Unter „Optionen“ können Sie festlegen, ob der Viewer beim Schließen in den Infobereich wechseln soll. „Datei → Exit“ beendet den Viewer nach einer Sicherheitsabfrage vollständig.');
    end;
    Scroll.VertScrollBar.Range := Y + Px(35);
    D.ShowModal;
  finally
    D.Free;
  end;
end;

procedure TPDFTabsForm.ShowAboutViewer(Sender: TObject);
begin
  ShowModernInfo(True);
end;

procedure TPDFTabsForm.ShowViewerHelp(Sender: TObject);
begin
  ShowModernInfo(False);
end;

procedure TPDFTabsForm.SetTrayIcon(AVisible: Boolean);
var
  Data: TNotifyIconDataW;
begin
  if AVisible = FTrayVisible then Exit;
  FillChar(Data, SizeOf(Data), 0);
  Data.cbSize := SizeOf(Data);
  Data.Wnd := Handle;
  Data.uID := 1;
  if AVisible then
  begin
    Data.uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
    Data.uCallbackMessage := WM_APP + 195;
    Data.hIcon := Application.Icon.Handle;
    StringToWideChar('FreePDF64-Viewer', @Data.szTip[0], Length(Data.szTip));
    FTrayVisible := Shell_NotifyIconW(NIM_ADD, @Data);
  end
  else
  begin
    Shell_NotifyIconW(NIM_DELETE, @Data);
    FTrayVisible := False;
  end;
end;

procedure TPDFTabsForm.RestoreFromTray(Sender: TObject);
begin
  SetTrayIcon(False);
  Show;
  if WindowState = wsMinimized then WindowState := wsNormal;
  BringToFront;
  SetForegroundWindow(Handle);
end;

procedure TPDFTabsForm.ExitFromTray(Sender: TObject);
begin
  // Bewusstes Beenden: anders als beim Fenster-X nicht in den Tray wechseln.
  FExitFromTray := True;
  try
    Close; // TabsFormClose führt die Sicherheitsabfragen aus.
  finally
    // Bei Abbrechen bleibt die Anwendung samt Tray-Funktion benutzbar.
    FExitFromTray := False;
  end;
end;

function ConfirmPDFViewerAssociation(AOwner: TCustomForm): Boolean;
var
  D: TViewerHelpForm;
  Header, Footer, InfoCard: TPanel;
  Content: TScrollBox;
  IconImage: TImage;
  L: TLabel;
  YesButton, NoButton: TButton;
  Scale: Integer;
  function Px(V: Integer): Integer;
  begin
    Result := MulDiv(V, Scale, 96);
  end;
  procedure TextLine(AParent: TWinControl; const AText: string;
    AX, AY, AWidth, AHeight, ASize: Integer; ABold: Boolean; AColor: TColor);
  begin
    L := TLabel.Create(D);
    L.Parent := AParent;
    L.SetBounds(Px(AX), Px(AY), Px(AWidth), Px(AHeight));
    L.AutoSize := False;
    L.WordWrap := True;
    L.ShowAccelChar := False;
    L.Caption := AText;
    L.Font.Name := 'Segoe UI';
    L.Font.Size := ASize;
    L.Font.Color := AColor;
    if ABold then L.Font.Style := [fsBold];
  end;
begin
  Result := False;
  D := TViewerHelpForm.CreateNew(AOwner);
  try
    Scale := AOwner.CurrentPPI;
    if Scale < 96 then Scale := 96;
    D.Caption := 'PDF-Dateien verknüpfen';
    D.Position := poOwnerFormCenter;
    D.BorderStyle := bsDialog;
    D.Font.Name := 'Segoe UI';
    D.Font.Size := 10;
    D.Color := clWhite;
    D.ClientWidth := Px(630);
    D.ClientHeight := Px(460);
    D.Constraints.MinWidth := Px(510);
    D.Constraints.MinHeight := Px(300);
    D.KeyPreview := True;

    Header := TPanel.Create(D);
    Header.Parent := D;
    Header.Align := alTop;
    Header.Height := Px(105);
    Header.BevelOuter := bvNone;
    Header.ParentBackground := False;
    Header.Color := RGB(19, 93, 169);

    IconImage := TImage.Create(D);
    IconImage.Parent := Header;
    IconImage.SetBounds(Px(24), Px(24), Px(54), Px(54));
    IconImage.Picture.Icon.Assign(Application.Icon);
    IconImage.Stretch := True;

    TextLine(Header, 'PDF-Dateien verknüpfen', 95, 24, 505, 36,
      19, True, clWhite);
    TextLine(Header, 'FreePDF64-Viewer als Standard-App einrichten',
      97, 67, 500, 23, 10, False, RGB(224, 237, 250));

    Footer := TPanel.Create(D);
    Footer.Parent := D;
    Footer.Align := alBottom;
    Footer.Height := Px(68);
    Footer.BevelOuter := bvNone;
    Footer.ParentBackground := False;
    Footer.Color := RGB(230, 239, 249);

    NoButton := TButton.Create(D);
    NoButton.Parent := Footer;
    NoButton.Caption := 'Abbrechen';
    NoButton.ModalResult := mrCancel;
    NoButton.Cancel := True;
    NoButton.SetBounds(Px(475), Px(16), Px(130), Px(36));
    NoButton.Anchors := [akRight, akTop];

    YesButton := TButton.Create(D);
    YesButton.Parent := Footer;
    YesButton.Caption := 'Weiter';
    YesButton.ModalResult := mrYes;
    YesButton.Default := True;
    YesButton.SetBounds(Px(325), Px(16), Px(135), Px(36));
    YesButton.Anchors := [akRight, akTop];

    Content := TScrollBox.Create(D);
    Content.Parent := D;
    Content.Align := alClient;
    Content.BorderStyle := bsNone;
    Content.ParentBackground := False;
    Content.Color := RGB(250, 252, 255);
    Content.VertScrollBar.Visible := True;
    Content.VertScrollBar.Tracking := True;
    Content.HorzScrollBar.Visible := False;
    Content.AutoScroll := True;
    D.HelpScroll := Content;

    TextLine(Content, 'PDF-Dateien direkt im Viewer öffnen',
      28, 22, 565, 29, 13, True, RGB(24, 83, 150));
    TextLine(Content,
      'Der FreePDF64-Viewer wird für Ihr Windows-Benutzerkonto als PDF-Anwendung registriert.',
      28, 65, 560, 48, 10, False, RGB(44, 55, 70));

    InfoCard := TPanel.Create(D);
    InfoCard.Parent := Content;
    InfoCard.SetBounds(Px(25), Px(127), Px(580), Px(112));
    InfoCard.BevelOuter := bvNone;
    InfoCard.ParentBackground := False;
    InfoCard.Color := RGB(233, 243, 253);
    TextLine(InfoCard, 'So geht es weiter', 18, 13, 530, 26,
      11, True, RGB(24, 83, 150));
    TextLine(InfoCard,
      '1. Der Viewer wird in Windows registriert.' + sLineBreak +
      '2. Die Windows-Einstellungen für Standard-Apps werden geöffnet.' + sLineBreak +
      '3. Dort wählen Sie den FreePDF64-Viewer für PDF-Dateien aus.',
      18, 43, 540, 65, 10, False, RGB(44, 55, 70));

    TextLine(Content, 'Hinweis zur portablen Version',
      28, 260, 555, 27, 11, True, RGB(24, 83, 150));
    TextLine(Content,
      'Wenn Sie die EXE-Datei verschieben oder den Laufwerksbuchstaben ändern, müssen Sie die Verknüpfung erneut einrichten.',
      28, 292, 560, 56, 10, False, RGB(44, 55, 70));

    // Inhalt reicht über die sichtbare Fläche hinaus und kann mit
    // Scrollleiste, Mausrad oder Tastatur vollständig gelesen werden.
    Content.VertScrollBar.Range := Px(390);
    Result := D.ShowModal = mrYes;
  finally
    D.Free;
  end;
end;

procedure ShowRegistrationInfoDialog(AOwner: TForm; ASettingsOpened: Boolean); forward;

procedure TPDFTabsForm.PDFVerknuepfungClick(Sender: TObject);
const
  // Eigenstaendige Registrierung: keine Kollision mit FreePDF64.PDF.
  ProgId = 'FreePDF64ViewerPortable.PDF';
  Capabilities = 'Software\FreePDF64ViewerPortable\Capabilities';
var
  Reg: TRegistry;
  ExePath, ExeName, CommandLine: string;

  procedure WriteValue(const KeyName, ValueName, Value: string);
  begin
    if not Reg.OpenKey(KeyName, True) then
      raise Exception.Create('Registry-Schlüssel kann nicht angelegt werden: ' + KeyName);
    try
      Reg.WriteString(ValueName, Value);
    finally
      Reg.CloseKey;
    end;
  end;
begin
  if not ConfirmPDFViewerAssociation(Self) then Exit;

  ExePath := ExpandFileName(Application.ExeName);
  ExeName := ExtractFileName(ExePath);
  CommandLine := '"' + ExePath + '" "%1"';
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    try
      WriteValue('Software\Classes\' + ProgId, '', 'FreePDF64-Viewer PDF-Dokument');
      WriteValue('Software\Classes\' + ProgId + '\DefaultIcon', '', '"' + ExePath + '",0');
      WriteValue('Software\Classes\' + ProgId + '\shell\open\command', '', CommandLine);
      WriteValue('Software\Classes\Applications\' + ExeName + '\SupportedTypes', '.pdf', '');
      WriteValue('Software\Classes\Applications\' + ExeName + '\shell\open\command', '', CommandLine);
      WriteValue(Capabilities, 'ApplicationName', 'FreePDF64-Viewer');
      WriteValue(Capabilities, 'ApplicationDescription', 'Portabler PDF-Viewer von FreePDF64');
      WriteValue(Capabilities, 'ApplicationIcon', '"' + ExePath + '",0');
      WriteValue(Capabilities + '\FileAssociations', '.pdf', ProgId);
      WriteValue('Software\RegisteredApplications', 'FreePDF64-Viewer', Capabilities);
    except
      on E: Exception do
      begin
        MessageDlg('Die Registrierung des PDF-Viewers ist fehlgeschlagen:' +
          sLineBreak + E.Message, mtError, [mbOK], 0);
        Exit;
      end;
    end;
  finally
    Reg.Free;
  end;

  // Keine direkte Manipulation der geschuetzten Windows-UserChoice-Zuordnung.
  // Windows 10/11 verlangen eine bewusste Auswahl durch den Benutzer.
  ShowRegistrationInfoDialog(Self,
    ShellExecute(Handle, 'open', 'ms-settings:defaultapps', nil, nil,
      SW_SHOWNORMAL) > 32);
end;

procedure ShowRegistrationInfoDialog(AOwner: TForm; ASettingsOpened: Boolean);
var
  D: TViewerHelpForm;
  Header, Footer: TPanel;
  Content: TScrollBox;
  TitleLabel, SubTitle, Heading, BodyText, NoteText: TLabel;
  IconImage: TImage;
  CloseButton: TButton;
  Scale: Integer;

  function Px(V: Integer): Integer;
  begin
    Result := MulDiv(V, Scale, 96);
  end;

  function AddText(AParent: TWinControl; const AText: string;
    AX, AY, AW, AH, ASize: Integer; ABold: Boolean; AColor: TColor): TLabel;
  begin
    Result := TLabel.Create(D);
    Result.Parent := AParent;
    Result.SetBounds(Px(AX), Px(AY), Px(AW), Px(AH));
    Result.AutoSize := False;
    Result.WordWrap := True;
    Result.ShowAccelChar := False;
    Result.Caption := AText;
    Result.Font.Name := 'Segoe UI';
    Result.Font.Size := ASize;
    Result.Font.Color := AColor;
    if ABold then
      Result.Font.Style := [fsBold];
  end;

begin
  D := TViewerHelpForm.CreateNew(AOwner);
  try
    Scale := AOwner.CurrentPPI;
    if Scale < 96 then Scale := 96;
    D.Caption := 'PDF-Verknüpfung eingerichtet';
    D.Position := poOwnerFormCenter;
    D.BorderStyle := bsDialog;
    D.Font.Name := 'Segoe UI';
    D.Font.Size := 10;
    D.Color := clWhite;
    D.ClientWidth := Px(610);
    D.ClientHeight := Px(340);
    D.KeyPreview := True;

    Header := TPanel.Create(D);
    Header.Parent := D;
    Header.Align := alTop;
    Header.Height := Px(105);
    Header.BevelOuter := bvNone;
    Header.ParentBackground := False;
    Header.Color := RGB(19, 93, 169);

    IconImage := TImage.Create(D);
    IconImage.Parent := Header;
    IconImage.SetBounds(Px(24), Px(25), Px(54), Px(54));
    IconImage.Picture.Icon.Assign(Application.Icon);
    IconImage.Proportional := True;
    IconImage.Stretch := True;

    TitleLabel := AddText(Header, 'Registrierung erfolgreich',
      100, 28, 475, 38, 18, True, clWhite);
    SubTitle := AddText(Header, 'FreePDF64-Viewer',
      102, 69, 465, 25, 10, False, RGB(223, 238, 255));

    Footer := TPanel.Create(D);
    Footer.Parent := D;
    Footer.Align := alBottom;
    Footer.Height := Px(67);
    Footer.BevelOuter := bvNone;
    Footer.ParentBackground := False;
    Footer.Color := RGB(232, 241, 251);

    CloseButton := TButton.Create(D);
    CloseButton.Parent := Footer;
    CloseButton.SetBounds(Px(453), Px(15), Px(130), Px(37));
    CloseButton.Caption := 'OK';
    CloseButton.ModalResult := mrOk;
    CloseButton.Default := True;
    CloseButton.Cancel := True;

    Content := TScrollBox.Create(D);
    Content.Parent := D;
    Content.Align := alClient;
    Content.BorderStyle := bsNone;
    Content.Color := clWhite;
    Content.ParentBackground := False;
    Content.HorzScrollBar.Visible := False;
    Content.AutoScroll := True;
    D.HelpScroll := Content;

    Heading := AddText(Content, 'Der Viewer wurde in Windows registriert.',
      27, 17, 550, 30, 13, True, RGB(24, 83, 150));
    if ASettingsOpened then
      BodyText := AddText(Content,
        'Die Windows-Einstellungen für Standard-Apps wurden geöffnet.' +
        sLineBreak + 'Wählen Sie dort den FreePDF64-Viewer für den Dateityp .pdf aus.',
        27, 57, 545, 63, 11, False, RGB(44, 55, 70))
    else
      BodyText := AddText(Content,
        'Öffnen Sie Windows-Einstellungen > Apps > Standard-Apps.' +
        sLineBreak + 'Wählen Sie dort den FreePDF64-Viewer für den Dateityp .pdf aus.',
        27, 57, 545, 63, 11, False, RGB(44, 55, 70));

    NoteText := AddText(Content,
      'Wichtig: Erst nach Ihrer Bestätigung in Windows wird die Zuordnung wirksam.',
      27, 130, 545, 46, 11, True, RGB(24, 83, 150));
    AddText(Content,
      'Bei einer portablen Version muss die Verknüpfung nach dem Verschieben der EXE erneut eingerichtet werden.',
      27, 187, 545, 48, 10, False, RGB(44, 55, 70));
    Content.VertScrollBar.Range := Px(255);
    D.ShowModal;
  finally
    D.Free;
  end;
end;

procedure TPDFTabsForm.ToggleTrayMode(Sender: TObject);
var
  Ini: TIniFile;
begin
  FTrayEnabled := not FTrayEnabled;
  if FTrayMenuItem <> nil then FTrayMenuItem.Checked := FTrayEnabled;
  Ini := TIniFile.Create(TabsIniFileName);
  try
    Ini.WriteBool('Viewer', 'BeimSchliessenInTray', FTrayEnabled);
  finally
    Ini.Free;
  end;
end;

procedure TPDFTabsForm.WMTrayCallback(var Msg: TMessage);
var
  P: TPoint;
begin
  case Msg.LParam of
    WM_LBUTTONDBLCLK, WM_LBUTTONUP: RestoreFromTray(nil);
    WM_RBUTTONUP, WM_CONTEXTMENU:
      begin
        GetCursorPos(P);
        SetForegroundWindow(Handle);
        FTrayPopup.Popup(P.X, P.Y);
        PostMessage(Handle, WM_NULL, 0, 0);
      end;
  end;
  Msg.Result := 0;
end;

constructor TPDFTabsForm.Create(AOwner: TComponent);
var
  Header: TPanel;
  HelpRoot, HelpItem: TMenuItem;
  Ini: TIniFile;
  MenuInfo: TMenuItemInfo;
  SearchArea: TPanel;
  Dpi: Integer;
  ButtonHeight: Integer;
begin
  inherited CreateNew(AOwner);
  KeyPreview := True;
  OnKeyDown := ViewerKeyDown;
  Dpi := CurrentPPI;
  if Dpi < 96 then Dpi := 96;
  ButtonHeight := Max(MulDiv(26, Dpi, 96), Canvas.TextHeight('Ag') + MulDiv(10, Dpi, 96));
  PDFTabsWindow := Self;
  FClosedPDFs := TStringList.Create;
  FSessionPDFs := TStringList.Create;
  LoadClosedPDFs;
  LoadPDFSession;
  // Eigenstaendiges Hilfe-Menue des portablen Viewers.
  FHelpMainMenu := TMainMenu.Create(Self);
  Menu := FHelpMainMenu;
  FFileMenu := TMenuItem.Create(FHelpMainMenu);
  FFileMenu.Caption := 'Datei';
  FHelpMainMenu.Items.Add(FFileMenu);
  HelpItem := TMenuItem.Create(FHelpMainMenu);
  HelpItem.Caption := 'PDF öffnen ...';
  HelpItem.ShortCut := ShortCut(Ord('O'), [ssCtrl]);
  HelpItem.OnClick := OpenPDFClick;
  FFileMenu.Add(HelpItem);
  HelpItem := TMenuItem.Create(FHelpMainMenu);
  HelpItem.Caption := '-';
  FFileMenu.Add(HelpItem);
  HelpItem := TMenuItem.Create(FHelpMainMenu);
  HelpItem.Caption := 'Exit';
  HelpItem.ShortCut := ShortCut(VK_F4, [ssAlt]);
  HelpItem.OnClick := ExitFromTray;
  FFileMenu.Add(HelpItem);
  // Einstellungen in einem eigenen Hauptmenü bündeln.
  FOptionsMenu := TMenuItem.Create(FHelpMainMenu);
  FOptionsMenu.Caption := 'Optionen';
  FHelpMainMenu.Items.Add(FOptionsMenu);
  FTrayMenuItem := TMenuItem.Create(FHelpMainMenu);
  FTrayMenuItem.Caption := 'Beim Schließen in den Infobereich';
  FTrayMenuItem.AutoCheck := False;
  FTrayMenuItem.OnClick := ToggleTrayMode;
  FOptionsMenu.Add(FTrayMenuItem);
  HelpItem := TMenuItem.Create(FHelpMainMenu);
  HelpItem.Caption := 'FreePDF64 öffnen';
  HelpItem.OnClick := OpenMainProgramClick;
  FOptionsMenu.Add(HelpItem);
  HelpRoot := TMenuItem.Create(FHelpMainMenu);
  HelpRoot.Caption := 'Hilfe';
  FHelpMainMenu.Items.Add(HelpRoot);
  HelpItem := TMenuItem.Create(FHelpMainMenu);
  HelpItem.Caption := 'Funktionsübersicht';
  HelpItem.OnClick := ShowViewerHelp;
  HelpRoot.Add(HelpItem);
  HelpItem := TMenuItem.Create(FHelpMainMenu);
  HelpItem.Caption := '-';
  HelpRoot.Add(HelpItem);
  HelpItem := TMenuItem.Create(FHelpMainMenu);
  HelpItem.Caption := 'Über FreePDF64-Viewer ...';
  HelpItem.OnClick := ShowAboutViewer;
  HelpRoot.Add(HelpItem);
  Ini := TIniFile.Create(TabsIniFileName);
  try
    FTrayEnabled := Ini.ReadBool('Viewer', 'BeimSchliessenInTray', False);
  finally
    Ini.Free;
  end;
  FTrayMenuItem.Checked := FTrayEnabled;
  // Hilfe bleibt als dritter Hauptmenüpunkt rechtsbündig.
  FillChar(MenuInfo, SizeOf(MenuInfo), 0);
  MenuInfo.cbSize := SizeOf(MenuInfo);
  MenuInfo.fMask := MIIM_FTYPE;
  MenuInfo.fType := MFT_STRING or MFT_RIGHTJUSTIFY;
  SetMenuItemInfo(FHelpMainMenu.Handle, 2, True, MenuInfo);
  DrawMenuBar(Handle);

  FTrayPopup := TPopupMenu.Create(Self);
  HelpItem := TMenuItem.Create(FTrayPopup);
  HelpItem.Caption := 'FreePDF64-Viewer anzeigen';
  HelpItem.Default := True;
  HelpItem.OnClick := RestoreFromTray;
  FTrayPopup.Items.Add(HelpItem);
  HelpItem := TMenuItem.Create(FTrayPopup);
  HelpItem.Caption := '-';
  FTrayPopup.Items.Add(HelpItem);
  HelpItem := TMenuItem.Create(FTrayPopup);
  HelpItem.Caption := 'FreePDF64-Viewer beenden';
  HelpItem.OnClick := ExitFromTray;
  FTrayPopup.Items.Add(HelpItem);
  FTabContextMenu := TPopupMenu.Create(Self);
  FTabContextMenu.OnPopup := TabContextPopup;
  FReopenClosedItem := TMenuItem.Create(FTabContextMenu);
  // Untermenü wird bei jedem Öffnen aus den letzten 20 PDFs aufgebaut.
  FTabContextMenu.Items.Add(FReopenClosedItem);
  FRestoreSessionItem := TMenuItem.Create(FTabContextMenu);
  FRestoreSessionItem.Caption := 'Letzte PDF-Sitzung wiederherstellen';
  FRestoreSessionItem.OnClick := RestorePDFSession;
  FTabContextMenu.Items.Add(FRestoreSessionItem);
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
  FViewerHeader := Header;
  Header.Parent := Self;
  Header.Align := alTop;
  Header.Height := 0;
  Header.Visible := False;
  Header.BevelOuter := bvNone;
  FWelcomePanel := TPanel.Create(Self);
  FWelcomePanel.Parent := Self;
  FWelcomePanel.Align := alClient;
  FWelcomePanel.BevelOuter := bvNone;
  FWelcomePanel.Color := clWindow;
  FWelcomePanel.ParentBackground := False;
  // Auch ohne geöffnete PDF steht der vorhandene Wiederherstellungsverlauf
  // über das Kontextmenü zur Verfügung.
  FWelcomePanel.PopupMenu := FTabContextMenu;

  // Das Startbild liegt portabel neben der EXE.
  FWelcomeImage := TImage.Create(Self);
  FWelcomeImage.Parent := FWelcomePanel;
  FWelcomeImage.PopupMenu := FTabContextMenu;
  FWelcomeImage.Proportional := True;
  FWelcomeImage.Stretch := True;
  FWelcomeImage.Center := True;
  FWelcomeImage.Transparent := True;
  if FileExists(ExtractFilePath(ParamStr(0)) + 'FreePDF64Viewer_Startbild.jpg') then
    try
      FWelcomeImage.Picture.LoadFromFile(
        ExtractFilePath(ParamStr(0)) + 'FreePDF64Viewer_Startbild.jpg');
    except
      FWelcomeImage.Visible := False;
    end
  else
    FWelcomeImage.Visible := False;

  FWelcomeTitle := TLabel.Create(Self);
  FWelcomeTitle.Parent := FWelcomePanel;
  FWelcomeTitle.PopupMenu := FTabContextMenu;
  FWelcomeTitle.AutoSize := True;
  FWelcomeTitle.Font.Size := 19;
  FWelcomeTitle.Font.Style := [fsBold];
  FWelcomeTitle.Caption := 'Willkommen beim FreePDF64-Viewer';

  FWelcomeHint := TLabel.Create(Self);
  FWelcomeHint.Parent := FWelcomePanel;
  FWelcomeHint.PopupMenu := FTabContextMenu;
  FWelcomeHint.AutoSize := True;
  FWelcomeHint.Font.Size := 11;
  FWelcomeHint.Caption := 'PDF öffnen oder eine PDF-Datei hierher ziehen (Strg+O)';

  FWelcomeOpenButton := TButton.Create(Self);
  FWelcomeOpenButton.Parent := FWelcomePanel;
  FWelcomeOpenButton.PopupMenu := FTabContextMenu;
  FWelcomeOpenButton.Caption := 'PDF öffnen ...';
  FWelcomeOpenButton.Width := MulDiv(190, Dpi, 96);
  FWelcomeOpenButton.Height := MulDiv(38, Dpi, 96);
  FWelcomeOpenButton.OnClick := OpenPDFClick;
  FWelcomePanel.OnResize := WelcomeResize;

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
  FHoverCloseTabIndex := -1;
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
  FMainProgramButton.Visible := False; // Im Menü Optionen verfügbar
  // Eigener rechter Bereich: feste Positionen unabhaengig von der
  // VCL-Ausrichtungsreihenfolge anderer Header-Steuerelemente.
  SearchArea := TPanel.Create(Self);
  SearchArea.Parent := FTabs;
  SearchArea.Align := alNone;
  SearchArea.Width := MulDiv(90, Dpi, 96);
  SearchArea.Height := MulDiv(28, Dpi, 96);
  FTabActionsPanel := SearchArea;
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
  FCreatedPDFForegroundTimer := TTimer.Create(Self);
  FCreatedPDFForegroundTimer.Enabled := False;
  FCreatedPDFForegroundTimer.Interval := 450;
  FCreatedPDFForegroundTimer.OnTimer := CreatedPDFForegroundTimerTick;
  FDeferredActivePDF := nil;
  FInitialWindowOffscreen := False;
  FActivationTimer := TTimer.Create(Self);
  FActivationTimer.Enabled := False;
  FActivationTimer.Interval := 250;
  FActivationTimer.OnTimer := ActivationTimerTick;
  LoadWindowSettings;
  OnClose := TabsFormClose;
  OnShow := TabsFormShow;
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

procedure TPDFTabsForm.WelcomeResize(Sender: TObject);
var
  C, Y, LogoSize, ContentHeight, Gap: Integer;
begin
  if FWelcomePanel = nil then Exit;
  C := FWelcomePanel.ClientWidth div 2;
  Gap := MulDiv(16, CurrentPPI, 96);
  LogoSize := MulDiv(220, CurrentPPI, 96);
  // Bei kleineren Fenstern das Bild verkleinern, ohne die Bedienelemente
  // aus dem sichtbaren Bereich zu schieben.
  LogoSize := Min(LogoSize, Max(0, FWelcomePanel.ClientHeight - MulDiv(180, CurrentPPI, 96)));
  LogoSize := Min(LogoSize, Max(0, FWelcomePanel.ClientWidth - MulDiv(40, CurrentPPI, 96)));
  if not FWelcomeImage.Visible then LogoSize := 0;
  ContentHeight := LogoSize + MulDiv(150, CurrentPPI, 96);
  Y := Max(MulDiv(12, CurrentPPI, 96),
    (FWelcomePanel.ClientHeight - ContentHeight) div 2);

  FWelcomeImage.SetBounds(C - LogoSize div 2, Y, LogoSize, LogoSize);
  FWelcomeTitle.Left := C - FWelcomeTitle.Width div 2;
  FWelcomeTitle.Top := Y + LogoSize + Gap;
  FWelcomeHint.Left := C - FWelcomeHint.Width div 2;
  FWelcomeHint.Top := FWelcomeTitle.Top + FWelcomeTitle.Height + Gap;
  FWelcomeOpenButton.Left := C - FWelcomeOpenButton.Width div 2;
  FWelcomeOpenButton.Top := FWelcomeHint.Top + FWelcomeHint.Height + Gap;
end;

procedure TPDFTabsForm.UpdateWelcomeView;
var
  Empty: Boolean;
begin
  if (FTabs = nil) or (FWelcomePanel = nil) then Exit;
  Empty := FTabs.PageCount = 0;
  FWelcomePanel.Visible := Empty;
  FTabs.Visible := not Empty;
  if FTabSearchButton <> nil then FTabSearchButton.Enabled := not Empty;
  if Empty then
  begin
    FWelcomePanel.BringToFront;
    WelcomeResize(nil);
  end;
end;

procedure TPDFTabsForm.WMDropFiles(var Msg: TWMDropFiles);
var
  I, Count, Len: UINT;
  FileName: string;
  PDF: TPDFBrowserForm;
begin
  Count := DragQueryFile(Msg.Drop, $FFFFFFFF, nil, 0);
  try
    for I := 0 to Count - 1 do
    begin
      Len := DragQueryFile(Msg.Drop, I, nil, 0);
      SetLength(FileName, Len + 1);
      if Len > 0 then
        DragQueryFile(Msg.Drop, I, PChar(FileName), Len + 1);
      SetLength(FileName, Len);
      if SameText(ExtractFileExt(FileName), '.pdf') and FileExists(FileName) then
      begin
        PDF := TPDFBrowserForm.Create(nil);
        try
          PDF.PDFFileName := FileName;
          PDF.StandalonePDFMode := False;
          AddPDF(PDF);
        except
          PDF.Free;
          raise;
        end;
      end;
    end;
  finally
    DragFinish(Msg.Drop);
  end;
end;

procedure TPDFTabsForm.UpdateTabCount;
begin
  UpdateWelcomeView;
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
    if not FLocalTextSearchHotkeyRegistered then
      FLocalTextSearchHotkeyRegistered := RegisterHotKey(Handle,
        LOCAL_TEXT_SEARCH_HOTKEY_ID, MOD_CONTROL or MOD_NOREPEAT, Ord('F'));
  end
  else
  begin
    if FLocalTabSearchHotkeyRegistered then
    begin
      UnregisterHotKey(Handle, LOCAL_TAB_SEARCH_HOTKEY_ID);
      FLocalTabSearchHotkeyRegistered := False;
    end;
    if FLocalTextSearchHotkeyRegistered then
    begin
      UnregisterHotKey(Handle, LOCAL_TEXT_SEARCH_HOTKEY_ID);
      FLocalTextSearchHotkeyRegistered := False;
    end;
  end;
end;

procedure TPDFTabsForm.WMViewerHotKey(var Msg: TMessage);
var
  Tab: TTabSheet;
  I: Integer;
begin
  if (Msg.WParam = LOCAL_TAB_SEARCH_HOTKEY_ID) or
     (Msg.WParam = LOCAL_TEXT_SEARCH_HOTKEY_ID) then
  begin
    if (GetForegroundWindow = Handle) and Visible then
    begin
      if Msg.WParam = LOCAL_TAB_SEARCH_HOTKEY_ID then
        TabSearchClick(FTabSearchButton)
      else
      begin
        Tab := FTabs.ActivePage;
        if Tab <> nil then
          for I := 0 to Tab.ControlCount - 1 do
            if Tab.Controls[I] is TPDFBrowserForm then
            begin
              TPDFBrowserForm(Tab.Controls[I]).ShowPDFSearch;
              Break;
            end;
      end;
    end;
    Msg.Result := 0;
  end
  else
    inherited;
end;

destructor TPDFTabsForm.Destroy;
begin
  SetTrayIcon(False);
  if FLocalTextSearchHotkeyRegistered then
  begin
    UnregisterHotKey(Handle, LOCAL_TEXT_SEARCH_HOTKEY_ID);
    FLocalTextSearchHotkeyRegistered := False;
  end;
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
  FSessionPDFs.Free;
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

procedure TPDFTabsForm.ShowCreatedPDFInForeground;
begin
  // Nach der PDF-Erstellung das Registerfenster auch dann sichtbar machen,
  // wenn FreePDF64 inzwischen wieder den Vordergrund erhalten hat.
  BringViewerToForeground;
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
  // Die erste PDF muss mindestens ihren ersten PDFium-Navigationsaufruf
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
  TempPDFFile: string;
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
        TempPDFFile := PDF.PDFFileName;
        PDF.Free;
        if IsFreePDFTempAttachment(TempPDFFile) then
          ReleasePDFAttachmentTemp(TempPDFFile);
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
var
  SI: TStartupInfo;
  PI: TProcessInformation;
  CmdLine: string;
begin
  // Der Viewer ist kein Hauptprogramm und darf dessen Mutex nicht besitzen.
  if ActivateRunningMainProgram then Exit;
  CmdLine := '"' + ParamStr(0) + '" --main';
  FillChar(SI, SizeOf(SI), 0);
  SI.cb := SizeOf(SI);
  FillChar(PI, SizeOf(PI), 0);
  if CreateProcess(PChar(ParamStr(0)), PChar(CmdLine), nil, nil,
    False, 0, nil, nil, SI, PI) then
  begin
    CloseHandle(PI.hThread);
    CloseHandle(PI.hProcess);
  end
  else
    MessageDlg('Das FreePDF64-Hauptprogramm konnte nicht gestartet werden.',
      mtError, [mbOK], 0);
end;

function TPDFTabsForm.ConfirmCloseUnsavedPDFs(AOnlyActive: Boolean): Boolean;
var
  I, J, Count, Choice: Integer;
  Tab: TTabSheet;
  PDF: TPDFBrowserForm;
begin
  Result := True;
  if FTabs = nil then Exit;
  Count := 0;
  for I := 0 to FTabs.PageCount - 1 do
  begin
    Tab := FTabs.Pages[I];
    if AOnlyActive and (Tab <> FTabs.ActivePage) then Continue;
    for J := 0 to Tab.ControlCount - 1 do
      if (Tab.Controls[J] is TPDFBrowserForm) and
        TPDFBrowserForm(Tab.Controls[J]).HasUnsavedPDFChanges then
        Inc(Count);
  end;
  if Count = 0 then Exit;
  Choice := MessageDlg(Format(
    '%d PDF-Datei(en) enthalten ungespeicherte Änderungen.' + sLineBreak +
    'Möchten Sie die Änderungen vor dem Schließen speichern?' + sLineBreak +
    'Ja = Alle speichern, Nein = Ohne Speichern schließen, Abbrechen = Zurück',
    [Count]), mtConfirmation, [mbYes, mbNo, mbCancel], 0);
  if Choice = mrCancel then Exit(False);
  if Choice = mrNo then Exit(True);
  if Choice <> mrYes then Exit(False);
  for I := 0 to FTabs.PageCount - 1 do
  begin
    Tab := FTabs.Pages[I];
    if AOnlyActive and (Tab <> FTabs.ActivePage) then Continue;
    for J := 0 to Tab.ControlCount - 1 do
      if Tab.Controls[J] is TPDFBrowserForm then
      begin
        PDF := TPDFBrowserForm(Tab.Controls[J]);
        if PDF.HasUnsavedPDFChanges and not PDF.SaveUnsavedPDFChanges then
          Exit(False);
      end;
  end;
end;

procedure TPDFTabsForm.TabsFormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if FTrayEnabled and not FExitFromTray then
  begin
    SetTrayIcon(True);
    if FTrayVisible then
    begin
      SaveWindowSettings;
      HideAllAttachmentWindows;
      Hide;
      Action := caNone;
      Exit;
    end;
  end;
  if not ConfirmCloseUnsavedPDFs(False) then
  begin
    Action := caNone;
    Exit;
  end;
  // Fenster zuerst ausblenden, dann die PDFium-Registerkarten
  // unsichtbar abbauen. Sonst flackert der Viewer bei vielen PDFs.
  SaveWindowSettings;
  SavePDFSession;
  HideAllAttachmentWindows;
  Action := caHide;
  if FTabSearchForm <> nil then
    FTabSearchForm.Hide;
  Hide;
  ClearAllPDFTabs;
  if FExitFromTray or
     (PDFTabsExplorerOnlyProcess and not PDFTabsMainFormWasShown) then
  begin
    SetTrayIcon(False);
    Application.Terminate;
  end;
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
  UpdateEmptyTabStrip;
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
    Show;
  APDF.Show;
  FTabs.Realign;
  APDF.Realign;
  // Das erste PDF explizit anfordern: ein Tabwechsel-Ereignis
  // wird beim erstmaligen Anlegen nicht immer ausgeloest.
  APDF.RequestPDFLoad;
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

procedure TPDFTabsForm.AddAttachmentPDF(APDF: TPDFBrowserForm; ASource: TPDFBrowserForm);
var
  SourceIndex: Integer;
begin
  SourceIndex := -1;
  if (ASource <> nil) and (ASource.Parent is TTabSheet) then
    if TTabSheet(ASource.Parent).PageControl = FTabs then
      SourceIndex := TTabSheet(ASource.Parent).PageIndex;
  AddPDF(APDF);
  if (SourceIndex >= 0) and (APDF.Parent is TTabSheet) then
  begin
    TTabSheet(APDF.Parent).PageIndex := SourceIndex + 1;
    UpdateEmptyTabStrip;
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

procedure TPDFTabsForm.HideAllAttachmentWindows;
var
  I, J: Integer;
  Tab: TTabSheet;
  Wnd: HWND;
begin
  if FTabs = nil then Exit;
  for I := 0 to FTabs.PageCount - 1 do
  begin
    Tab := FTabs.Pages[I];
    for J := 0 to Tab.ControlCount - 1 do
      if Tab.Controls[J] is TPDFBrowserForm then
      begin
        Wnd := TPDFBrowserForm(Tab.Controls[J]).AttachmentWindowHandle;
        if IsWindow(Wnd) then
        begin
          ShowWindow(Wnd, SW_HIDE);
          SetWindowPos(Wnd, HWND_NOTOPMOST, 0, 0, 0, 0,
            SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
        end;
      end;
  end;
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

function TPDFTabsForm.TabCloseRect(AIndex: Integer): TRect;
var
  R: TRect;
  Size, Padding: Integer;
begin
  Result := System.Types.Rect(0, 0, 0, 0);
  if (FTabs = nil) or (AIndex < 0) or (AIndex >= FTabs.PageCount) then Exit;
  R := FTabs.TabRect(AIndex);
  // Chrome-aehnliche 18px Klickflaeche, skaliert mit Monitor-DPI.
  Size := Max(18, MulDiv(18, CurrentPPI, 96));
  Padding := Max(5, MulDiv(6, CurrentPPI, 96));
  Result := System.Types.Rect(R.Right - Padding - Size,
    R.Top + (R.Bottom - R.Top - Size) div 2,
    R.Right - Padding,
    R.Top + (R.Bottom - R.Top - Size) div 2 + Size);
end;

procedure TPDFTabsForm.CloseTabAt(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= FTabs.PageCount) then Exit;
  FTabs.ActivePageIndex := AIndex;
  CloseActive(Self); // vorhandene Sicherheitsabfrage beibehalten
end;

procedure TPDFTabsForm.TabMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    // Nur bei einem echten Klick auf das X schliessen, nicht nach Tab-Drag.
    if not FDraggingTab then
    begin
      var CloseIndex: Integer;
      CloseIndex := FTabs.IndexOfTabAt(X, Y);
      if (CloseIndex >= 0) and PtInRect(TabCloseRect(CloseIndex), Point(X, Y)) then
      begin
        FDragTabIndex := -1;
        FDraggingTab := False;
        FHoverCloseTabIndex := -1;
        CloseTabAt(CloseIndex);
        Exit;
      end;
    end;
    FDragTabIndex := -1;
    FDraggingTab := False;
    PostMessage(Handle, WM_APP + 193, 0, 0);
  end;
end;

procedure TPDFTabsForm.TabsResized(Sender: TObject);
begin
  UpdateEmptyTabStrip;
  PositionTabActions;
end;

procedure TPDFTabsForm.PositionTabActions;
var
  H: Integer;
begin
  if (FTabs = nil) or (FTabActionsPanel = nil) then Exit;
  // Innerhalb der Reiterhoehe bleiben; nicht die gesamte TabRect-Hoehe
  // als Schaltflaechenhoehe uebernehmen (sonst unten abgeschnitten).
  H := MulDiv(26, CurrentPPI, 96);
  if (FTabs.PageCount > 0) and FTabs.HandleAllocated then
    H := Min(H, Max(MulDiv(20, CurrentPPI, 96),
      FTabs.TabRect(0).Bottom - MulDiv(4, CurrentPPI, 96)));
  // Suchschaltfläche und PDF-Anzahl rechtsbündig in der Tab-Leiste.
  // Nur 2 DPI-skalierte Pixel Abstand zum rechten Rand.
  FTabActionsPanel.SetBounds(
    Max(0, FTabs.ClientWidth - FTabActionsPanel.Width - MulDiv(2, CurrentPPI, 96)),
    MulDiv(2, CurrentPPI, 96), FTabActionsPanel.Width, H);
  FTabActionsPanel.BringToFront;
end;

procedure TPDFTabsForm.UpdateEmptyTabStrip;
var
  R: TRect;
  LeftEdge, StripHeight: Integer;
  AvailableWidth, MinTabWidth, MaxTabWidth, NewTabWidth: Integer;
begin
  if (FTabs = nil) or (FEmptyTabStrip = nil) or FUpdatingTabLayout then Exit;
  FUpdatingTabLayout := True;
  try
    // Browser-aehnlich: alle Tabs gleich breit, bei vielen Tabs schmaler.
    // Unterhalb der Mindestbreite verwendet Windows die nativen Scrollpfeile.
    MinTabWidth := MulDiv(120, CurrentPPI, 96);
    MaxTabWidth := MulDiv(260, CurrentPPI, 96);
    AvailableWidth := Max(1, FTabs.ClientWidth - MulDiv(112, CurrentPPI, 96));
    if FTabs.PageCount > 0 then
    begin
      NewTabWidth := Max(MinTabWidth,
        Min(MaxTabWidth, AvailableWidth div FTabs.PageCount));
      if FTabs.TabWidth <> NewTabWidth then
        FTabs.TabWidth := NewTabWidth;
    end;
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

  // Bei zu vielen Registerkarten blendet Windows rechts die beiden
  // Navigationspfeile ein. Das Overlay darf diese nicht ueberdecken.
  // Sobald die letzte Registerkarte den rechten Rand erreicht oder
  // darueber hinausreicht, den freien Streifen ganz ausblenden.
  if (FTabs.PageCount > 0) and
     (LeftEdge >= FTabs.ClientWidth - MulDiv(140, CurrentPPI, 96)) then
  begin
    FEmptyTabStrip.Visible := False;
    Exit;
  end;

  FEmptyTabStrip.SetBounds(LeftEdge, 0,
    Max(0, FTabs.ClientWidth - LeftEdge - MulDiv(104, CurrentPPI, 96)), StripHeight);
  FEmptyTabStrip.Visible := FEmptyTabStrip.Width > 0;
  if FEmptyTabStrip.Visible then
    FEmptyTabStrip.BringToFront;
  PositionTabActions;
  finally
    FUpdatingTabLayout := False;
  end;
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
  CloseR, TextR: TRect;
  CX, CY, Arm: Integer;
  Hovered: Boolean;
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
  CloseR := TabCloseRect(TabIndex);
  TextR := R;
  Inc(TextR.Left, MulDiv(9, CurrentPPI, 96));
  TextR.Right := CloseR.Left - MulDiv(5, CurrentPPI, 96);
  DrawText(FTabs.Canvas.Handle, PChar(S), Length(S), TextR,
    DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_END_ELLIPSIS);
  // Chrome-aehnliches Schliessen-X: dezentes X, bei Hover runder
  // Hintergrund und Hand-Cursor. Der gesamte Bereich ist klickbar.
  Hovered := TabIndex = FHoverCloseTabIndex;
  if Hovered then
  begin
    FTabs.Canvas.Brush.Color := RGB(204, 210, 218);
    FTabs.Canvas.Pen.Style := psClear;
    FTabs.Canvas.RoundRect(CloseR.Left, CloseR.Top, CloseR.Right,
      CloseR.Bottom, MulDiv(7, CurrentPPI, 96), MulDiv(7, CurrentPPI, 96));
    FTabs.Canvas.Pen.Style := psSolid;
  end;
  CX := (CloseR.Left + CloseR.Right) div 2;
  CY := (CloseR.Top + CloseR.Bottom) div 2;
  Arm := Max(4, MulDiv(5, CurrentPPI, 96));
  if Hovered then
    FTabs.Canvas.Pen.Color := RGB(35, 42, 50)
  else
    FTabs.Canvas.Pen.Color := RGB(93, 101, 111);
  FTabs.Canvas.Pen.Width := Max(1, MulDiv(1, CurrentPPI, 96));
  FTabs.Canvas.MoveTo(CX - Arm, CY - Arm);
  FTabs.Canvas.LineTo(CX + Arm, CY + Arm);
  FTabs.Canvas.MoveTo(CX + Arm, CY - Arm);
  FTabs.Canvas.LineTo(CX - Arm, CY + Arm);
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

  // Hover nur beim Ueberfahren der X-Klickflaeche aktualisieren.
  var NewHoverCloseTabIndex: Integer;
  NewHoverCloseTabIndex := -1;
  if PtInRect(TabCloseRect(TabIndex), Point(X, Y)) then
    NewHoverCloseTabIndex := TabIndex;
  if NewHoverCloseTabIndex <> FHoverCloseTabIndex then
  begin
    FHoverCloseTabIndex := NewHoverCloseTabIndex;
    FTabs.Invalidate;
  end;
  if FHoverCloseTabIndex >= 0 then
  begin
    FTabs.Cursor := crHandPoint;
    if Assigned(FTabHintWindow) then FTabHintWindow.ReleaseHandle;
    FHintTabIndex := -1;
    Exit;
  end;
  FTabs.Cursor := crDefault;

  if TabIndex = FHintTabIndex then
    Exit;

  FTabHintWindow.ReleaseHandle;
  FHintTabIndex := TabIndex;
  // Zwei Zeilen wie bei Browser-Tabs: Dateiname und Verzeichnispfad.
  // Der vollstaendige Dateipfad ist bereits im Tab.Hint hinterlegt;
  // es ist kein Dateizugriff (auch nicht auf Netzlaufwerke) noetig.
  HintText := FTabs.Pages[TabIndex].Hint;
  if HintText = '' then
    Exit;
  HintText := ExtractFileName(HintText) + sLineBreak +
    ExtractFilePath(FTabs.Pages[TabIndex].Hint);

  P := FTabs.ClientToScreen(Point(X, Y + MulDiv(20, CurrentPPI, 96)));
  R := FTabHintWindow.CalcHintRect(700, HintText, nil);
  OffsetRect(R, P.X, P.Y);
  FTabHintWindow.ActivateHint(R, HintText);
end;

procedure TPDFTabsForm.TabsMouseLeave(Sender: TObject);
begin
  if FHoverCloseTabIndex <> -1 then
  begin
    FHoverCloseTabIndex := -1;
    FTabs.Invalidate;
  end;
  FTabs.Cursor := crDefault;
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
  UpdateWelcomeView;
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
  if Msg.SizeType = SIZE_MINIMIZED then
    HideAllAttachmentWindows
  else
    RefreshAttachmentPositions;
end;

procedure TPDFTabsForm.TabContextPopup(Sender: TObject);
var
  I: Integer;
  Item: TMenuItem;
begin
  // Gemeinsamen Verlauf vor jeder Anzeige neu einlesen.
  LoadClosedPDFs;
  FReopenClosedItem.Clear;
  FRestoreSessionItem.Enabled := FSessionPDFs.Count > 0;
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
    // Fehlenden Eintrag auch dauerhaft aus der Wiederherstellungsliste entfernen.
    UpdateClosedPDFHistory(FileName, False);
    MessageDlg('Die PDF-Datei existiert nicht mehr und wurde aus der Liste entfernt:' +
      sLineBreak + FileName, mtWarning, [mbOK], 0);
    Exit;
  end;
  PDF := TPDFBrowserForm.Create(nil);
  try
    PDF.PDFFileName := FileName;
    PDF.StandalonePDFMode := False;
    AddPDF(PDF);
    UpdateClosedPDFHistory(FileName, False);
    BringViewerToForeground;
  except
    PDF.Free;
    raise;
  end;
end;

function TPDFTabsForm.IsShortCut(var Message: TWMKey): Boolean;
var
  Tab: TTabSheet;
  I: Integer;
  PDF: TPDFBrowserForm;
begin
  if (Message.CharCode = Ord('W')) and (GetForegroundWindow = Handle) and
     (GetKeyState(VK_CONTROL) < 0) and (GetKeyState(VK_MENU) >= 0) and
     (GetKeyState(VK_SHIFT) >= 0) then
  begin
    CloseActive(Self);
    Exit(True);
  end;
  // F11 auch dann erfassen, wenn eine Schaltfläche oder PDF-Seite den Fokus hat.
  if (Message.CharCode = VK_F11) and (GetForegroundWindow = Handle) then
  begin
    ToggleFullScreen;
    Exit(True);
  end;
  // ESC verlässt im Vollbild zuerst den Vollbildmodus, statt den Tab zu schließen.
  if (Message.CharCode = VK_ESCAPE) and FFullScreen and
     (GetForegroundWindow = Handle) then
  begin
    ToggleFullScreen;
    Exit(True);
  end;
  // F3/Shift+F3 zentral behandeln, auch wenn eine Toolbar-Schaltfläche
  // oder die Registerkarte den Tastaturfokus hat.
  if (Message.CharCode = VK_F3) and (GetForegroundWindow = Handle) and
     (GetKeyState(VK_CONTROL) >= 0) and (GetKeyState(VK_MENU) >= 0) then
  begin
    Tab := FTabs.ActivePage;
    if Tab <> nil then
      for I := 0 to Tab.ControlCount - 1 do
        if Tab.Controls[I] is TPDFBrowserForm then
        begin
          PDF := TPDFBrowserForm(Tab.Controls[I]);
          if GetKeyState(VK_SHIFT) < 0 then
            PDF.NextPDFSearchMatch(-1)
          else
            PDF.NextPDFSearchMatch(1);
          Exit(True);
        end;
  end;
  // Nur die aktive PDF-Anzeige darf diese Kürzel behandeln.
  // Keine globale Registrierung für Strg+A: so bleibt das Hauptprogramm unabhängig.
  if (GetForegroundWindow = Handle) and
     (GetKeyState(VK_CONTROL) < 0) and
     (GetKeyState(VK_MENU) >= 0) and
     (Message.CharCode in [Ord('A'), Ord('C'), Ord('F')]) then
  begin
    // In Eingabefeldern haben Strg+A/Strg+C die normalen Windows-Funktionen.
    if (Message.CharCode in [Ord('A'), Ord('C')]) and
       (Screen.ActiveControl is TCustomEdit) then
      Exit(inherited IsShortCut(Message));
    // Strg+A bleibt für die übliche Funktion "Alles auswählen" reserviert.
    // Nur Strg+Umschalt+A öffnet die Registerkartensuche.
    if Message.CharCode = Ord('A') then
    begin
      if GetKeyState(VK_SHIFT) < 0 then
      begin
        TabSearchClick(FTabSearchButton);
        Exit(True);
      end;
      Tab := FTabs.ActivePage;
      if Tab <> nil then
        for I := 0 to Tab.ControlCount - 1 do
          if Tab.Controls[I] is TPDFBrowserForm then
          begin
            TPDFBrowserForm(Tab.Controls[I]).SelectAllPDFText;
            Exit(True);
          end;
      Exit(True);
    end;
    if Message.CharCode = Ord('C') then
    begin
      Tab := FTabs.ActivePage;
      if Tab <> nil then
        for I := 0 to Tab.ControlCount - 1 do
          if Tab.Controls[I] is TPDFBrowserForm then
          begin
            TPDFBrowserForm(Tab.Controls[I]).CopyPDFText;
            Exit(True);
          end;
      Exit(True);
    end;
    if GetKeyState(VK_SHIFT) < 0 then
      Exit(inherited IsShortCut(Message));
    Tab := FTabs.ActivePage;
    if Tab <> nil then
      for I := 0 to Tab.ControlCount - 1 do
        if Tab.Controls[I] is TPDFBrowserForm then
        begin
          PDF := TPDFBrowserForm(Tab.Controls[I]);
          PDF.ShowPDFSearch;
          Exit(True);
        end;
  end;
  Result := inherited IsShortCut(Message);
end;

procedure TPDFTabsForm.ToggleFullScreen;
var
  M: TMonitor;
  I, J: Integer;
  PDF: TPDFBrowserForm;
begin
  if not FFullScreen then
  begin
    FFullScreenBounds := BoundsRect;
    FFullScreenWindowState := WindowState;
    FFullScreenBorderStyle := BorderStyle;
    FFullScreenTabsVisible := FTabs.Visible;
    FFullScreenEmptyStripVisible := FEmptyTabStrip.Visible;
    M := Screen.MonitorFromWindow(Handle);
    if M = nil then M := Screen.PrimaryMonitor;
    FFullScreen := True;
    // Zuerst alle Leisten ausblenden, dann auf Monitorgröße umschalten.
    for I := 0 to FTabs.PageCount - 1 do
      for J := 0 to FTabs.Pages[I].ControlCount - 1 do
        if FTabs.Pages[I].Controls[J] is TPDFBrowserForm then
        begin
          PDF := TPDFBrowserForm(FTabs.Pages[I].Controls[J]);
          PDF.SetFullScreenDisplay(True);
        end;
    FViewerHeader.Visible := False;
    FEmptyTabStrip.Visible := False;
    // Die Tab-Reiter verschwinden, der Seiteninhalt bleibt erhalten.
    FTabs.Style := tsButtons;
    FTabs.TabHeight := 1;
    WindowState := wsNormal;
    BorderStyle := bsNone;
    SetBounds(M.BoundsRect.Left, M.BoundsRect.Top,
      M.BoundsRect.Right - M.BoundsRect.Left,
      M.BoundsRect.Bottom - M.BoundsRect.Top);
  end
  else
  begin
    FFullScreen := False;
    BorderStyle := FFullScreenBorderStyle;
    FTabs.Style := tsTabs;
    FTabs.TabHeight := 0;
    FViewerHeader.Visible := True;
    FEmptyTabStrip.Visible := FFullScreenEmptyStripVisible;
    for I := 0 to FTabs.PageCount - 1 do
      for J := 0 to FTabs.Pages[I].ControlCount - 1 do
        if FTabs.Pages[I].Controls[J] is TPDFBrowserForm then
        begin
          PDF := TPDFBrowserForm(FTabs.Pages[I].Controls[J]);
          PDF.SetFullScreenDisplay(False);
        end;
    BoundsRect := FFullScreenBounds;
    WindowState := FFullScreenWindowState;
  end;
end;

procedure TPDFTabsForm.ViewerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Tab: TTabSheet;
  I: Integer;
  PDF: TPDFBrowserForm;
begin
  if (Key = Ord('W')) and (Shift = [ssCtrl]) then
  begin
    CloseActive(Self);
    Key := 0;
    Exit;
  end;
  if (Key = Ord('O')) and (Shift = [ssCtrl]) then
  begin
    OpenPDFClick(Self);
    Key := 0;
    Exit;
  end;
  if (Key = VK_F11) and (Shift = []) then
  begin
    ToggleFullScreen;
    Key := 0;
    Exit;
  end;
  if (Key = VK_ESCAPE) and FFullScreen then
  begin
    ToggleFullScreen;
    Key := 0;
    Exit;
  end;
  if (Key <> VK_ESCAPE) or (Shift <> []) then Exit;
  // Erst eine sichtbare Anlagenliste schließen, danach den PDF-Tab.
  Tab := FTabs.ActivePage;
  if Tab = nil then Exit;
  for I := 0 to Tab.ControlCount - 1 do
    if Tab.Controls[I] is TPDFBrowserForm then
    begin
      PDF := TPDFBrowserForm(Tab.Controls[I]);
      if (PDF.AttachmentWindowHandle <> 0) and
         IsWindow(PDF.AttachmentWindowHandle) and
         IsWindowVisible(PDF.AttachmentWindowHandle) then
      begin
        ShowWindow(PDF.AttachmentWindowHandle, SW_HIDE);
        SetWindowPos(PDF.AttachmentWindowHandle, HWND_NOTOPMOST,
          0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
        Key := 0;
        Exit;
      end;
      Break;
    end;
  CloseActive(Self);
  Key := 0;
end;

procedure TPDFTabsForm.CloseActive(Sender: TObject);
var
  Tab: TTabSheet;
  PDF: TPDFBrowserForm;
  I: Integer;
  ClosedIndex, NextIndex: Integer;
  TempPDFFile: string;
begin
  Tab := FTabs.ActivePage;
  if Tab = nil then Exit;
  if not ConfirmCloseUnsavedPDFs(True) then Exit;
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
    if (PDF.PDFFileName <> '') and not IsFreePDFTempAttachment(PDF.PDFFileName) then
    begin
      UpdateClosedPDFHistory(PDF.PDFFileName, True);
    end;
    // Vor dem Entfernen des Parent unsichtbar machen. Sonst wird
    // das eingebettete Formular kurz ein eigenstaendiges Fenster
    // und kann das Registerkartenfenster nach hinten verdraengen.
    TempPDFFile := PDF.PDFFileName;
    PDF.Hide;
    PDF.Free;
    if IsFreePDFTempAttachment(TempPDFFile) then
      ReleasePDFAttachmentTemp(TempPDFFile);
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
      UpdateWelcomeView
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
    if (FDragTabIndex >= 0) and
       PtInRect(TabCloseRect(FDragTabIndex), Point(X, Y)) then
      FDragTabIndex := -1;
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
    MessageDlg('Der eigenständige PDF-Anzeiger konnte nicht gestartet werden.',
      mtError, [mbOK], 0);
    Exit;
  end;
  if PDFTabsWindow = nil then
    PDFTabsWindow := TPDFTabsForm.Create(Application);
  if not PDFTabsWindow.Visible then
  begin
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
var
  I, J: Integer;
  Existing: TPDFBrowserForm;
  Tab: TTabSheet;
  RequestedFile, RequestedSearch: string;
begin
  if APDF = nil then Exit;
  if PDFTabsWindow = nil then
    PDFTabsWindow := TPDFTabsForm.Create(Application);

  // Zentraler Einstieg fuer ALLE Aufrufer: vorhandenes Viewerfenster
  // wiederverwenden und bereits geoeffnete PDF-Dateien aktivieren.
  RequestedFile := ExpandFileName(APDF.PDFFileName);
  RequestedSearch := APDF.SearchTerm;
  Existing := nil;
  if PDFTabsWindow.FTabs <> nil then
    for I := 0 to PDFTabsWindow.FTabs.PageCount - 1 do
    begin
      Tab := PDFTabsWindow.FTabs.Pages[I];
      if SameText(ExpandFileName(Tab.Hint), RequestedFile) then
      begin
        for J := 0 to Tab.ControlCount - 1 do
          if Tab.Controls[J] is TPDFBrowserForm then
          begin
            Existing := TPDFBrowserForm(Tab.Controls[J]);
            Break;
          end;
        if Existing <> nil then Break;
      end;
    end;

  if Existing <> nil then
  begin
    PDFTabsWindow.ActivatePDF(Existing);
    if RequestedSearch <> '' then
      Existing.SearchTerm := RequestedSearch;
    // Der uebergebene Formularentwurf wird nicht mehr benoetigt.
    APDF.Free;
  end
  else
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
