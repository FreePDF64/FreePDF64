unit uPDFTabsForm;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, Winapi.Messages,
  Vcl.Forms, Vcl.Controls, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics,
  Vcl.Dialogs, System.IniFiles, Math,
  uPDFBrowserForm;

type
  TPDFTabsForm = class(TForm)
  private
    FTabs: TPageControl;
    FCloseButton: TButton;
    FOpenButton: TButton;
    FAssociationButton: TButton;
    FLastNormalBounds: TRect;
    FRestoringWindowSettings: Boolean;
    FAddingPDF: Boolean;
    FPendingExplorerFiles: TStringList;
    FDeferredActivePDF: TPDFBrowserForm;
    FActivationTimer: TTimer;
    FActivationChecks: Integer;
    FFirstPDFInitialized: Boolean;
    FInitialWindowOffscreen: Boolean;
    FInitialWindowBounds: TRect;
    FInitialWindowMaximized: Boolean;
    procedure ActivationTimerTick(Sender: TObject);
    procedure RestoreInitialWindow;
    procedure WMOpenQueuedPDF(var Msg: TMessage); message WM_APP + 192;
    procedure WMLoadActivePDF(var Msg: TMessage); message WM_APP + 193;
    procedure OpenPDFClick(Sender: TObject);
    procedure AssociationClick(Sender: TObject);
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
    procedure DrawPDFTab(Control: TCustomTabControl; TabIndex: Integer;
      const Rect: TRect; Active: Boolean);
    procedure WindowMoved(var Msg: TWMMove); message WM_MOVE;
    procedure WindowSized(var Msg: TWMSize); message WM_SIZE;
    procedure TabMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LoadSelectedPDF;
    procedure TabMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddPDF(APDF: TPDFBrowserForm);
    procedure ActivatePDF(APDF: TPDFBrowserForm);
  end;

type
  TPDFTabAttachmentsProc = procedure(const AFileName: string;
    APDF: TPDFBrowserForm);

var
  PDFTabsWindow: TPDFTabsForm;
  PDFTabAttachmentsInitializer: TPDFTabAttachmentsProc;
  PDFTabAssociationClick: TNotifyEvent = nil;
  // True nur bei einem eigenstaendigen Explorer-Start mit PDF-Parametern.
  PDFTabsExplorerOnlyProcess: Boolean = False;

procedure ShowEmptyPDFViewer;
procedure ShowPDFInTabs(APDF: TPDFBrowserForm);
function SendPDFToExistingTabs(const AFileName: string): Boolean;

implementation

const
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
    RemoveProp(Handle, PChar(PDFTabWindowMarker));
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
  PostMessage(Handle, WM_APP + 192, 0, 0);
  Msg.Result := 1;
end;

procedure TPDFTabsForm.WMOpenQueuedPDF(var Msg: TMessage);
var
  FileName: string;
  PDF: TPDFBrowserForm;
  LastOpenedPDF: TPDFBrowserForm;
begin
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
  if not FInitialWindowOffscreen then
  begin
    if IsIconic(Handle) then ShowWindow(Handle, SW_RESTORE);
    SetForegroundWindow(Handle);
  end;
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
begin
  LastOpenedPDF := nil;
  Dialog := TFileOpenDialog.Create(Self);
  try
    Dialog.Title := 'Datei(en) öffnen';
    // Windows-Shellordner 'Dieser PC' (Laufwerke) statt letztem Verzeichnis.
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

procedure TPDFTabsForm.AssociationClick(Sender: TObject);
begin
  if Assigned(PDFTabAssociationClick) then
    PDFTabAssociationClick(Sender)
  else
    MessageDlg('PDF-Verknuepfung ist momentan nicht verfuegbar.',
      mtInformation, [mbOK], 0);
end;

constructor TPDFTabsForm.Create(AOwner: TComponent);
var
  Header: TPanel;
begin
  inherited CreateNew(AOwner);
  PDFTabsWindow := Self;
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
  Header.Height := 36;
  Header.BevelOuter := bvNone;
  FCloseButton := TButton.Create(Self);
  FCloseButton.Parent := Header;
  FCloseButton.Align := alRight;
  FCloseButton.Width := 185;
  FCloseButton.Caption := 'Aktiven Tab schließen';
  FCloseButton.OnClick := CloseActive;
  FTabs := TPageControl.Create(Self);
  FTabs.Parent := Self;
  FTabs.DoubleBuffered := True;
  FTabs.Align := alClient;
  FTabs.OnMouseDown := TabMouseDown;
  FTabs.OnMouseUp := TabMouseUp;
  FTabs.ShowHint := True;
  FTabs.OnMouseMove := TabsMouseMove;
  FTabs.OnChange := TabsChange;
  FTabs.OwnerDraw := True;
  FTabs.OnDrawTab := DrawPDFTab;
  FOpenButton := TButton.Create(Self);
  FOpenButton.Parent := Header;
  FOpenButton.Align := alLeft;
  FOpenButton.Width := 180;
  FOpenButton.Caption := 'Datei(en) öffnen ...';
  FOpenButton.Hint := '... auch alle anderen Dateitypen';
  FOpenButton.ShowHint := True;
  FOpenButton.OnClick := OpenPDFClick;
  // Kleiner Abstand zwischen Oeffnen- und Verknuepfen-Button.
  with TPanel.Create(Self) do
  begin
    Parent := Header;
    Align := alLeft;
    Width := 16;
    BevelOuter := bvNone;
    Caption := '';
  end;
  FAssociationButton := TButton.Create(Self);
  FAssociationButton.Parent := Header;
  FAssociationButton.Align := alLeft;
  FAssociationButton.Width := 125;
  FAssociationButton.Caption := 'PDF verknüpfen';
  FAssociationButton.Hint := 'FreePDF64 als Standardprogramm für PDF-Dateien festlegen:' + #13 +
                             'Öffnet die Windows-Einstellungen, in denen Sie FreePDF64' + #13 +
                             'als Standard-PDF-Anzeigeprogramm auswählen können';
  FAssociationButton.ShowHint := True;
  FAssociationButton.OnClick := AssociationClick;
  FPendingExplorerFiles := TStringList.Create;
  FDeferredActivePDF := nil;
  FInitialWindowOffscreen := False;
  FActivationTimer := TTimer.Create(Self);
  FActivationTimer.Enabled := False;
  FActivationTimer.Interval := 250;
  FActivationTimer.OnTimer := ActivationTimerTick;
  LoadWindowSettings;
  OnClose := TabsFormClose;
end;

destructor TPDFTabsForm.Destroy;
begin
  FActivationTimer.Enabled := False;
  RestoreInitialWindow;
  FPendingExplorerFiles.Free;
  ClearAllPDFTabs;
  if PDFTabsWindow = Self then
    PDFTabsWindow := nil;
  inherited Destroy;
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
  if (FirstPDF <> nil) and (not FirstPDF.PDFNavigationStarted) and
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
        PDF.Parent := nil;
        PDF.Free;
      end;
    Tab.Free;
  end;
end;

procedure TPDFTabsForm.TabsFormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  // Wichtig: auch bei caHide speichern und die Tabs entfernen.
  SaveWindowSettings;
  ClearAllPDFTabs;
  if PDFTabsExplorerOnlyProcess then
  begin
    Action := caHide;
    Application.Terminate;
  end
  else
    Action := caHide;
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
  Tab.DoubleBuffered := True;
  Tab.Caption := ExtractFileName(APDF.PDFFileName);
  Tab.Hint := APDF.PDFFileName;
  Tab.ShowHint := True;
  APDF.TabbedPDFMode := True;
  APDF.BorderStyle := bsNone;
  APDF.Parent := Tab;
  APDF.Align := alClient;
  // Die erste Seite bleibt aktiv. Weitere Tabs nicht automatisch aktivieren.
  FAddingPDF := True;
  try
    if FTabs.PageCount = 1 then
      FTabs.ActivePage := Tab;
  finally
    FAddingPDF := False;
  end;
  if not Visible then
  begin
    LoadWindowSettings;
    // Nur beim erstmaligen Anzeigen: Fenster ausserhalb des virtuellen
    // Desktops positionieren, aber sichtbar lassen. WebView2 braucht
    // einen sichtbaren Host mit echter Groesse.
    if FTabs.PageCount = 1 then
    begin
      FInitialWindowBounds := FLastNormalBounds;
      FInitialWindowMaximized := WindowState = wsMaximized;
      FInitialWindowOffscreen := True;
      WindowState := wsNormal;
      SetBounds(GetSystemMetrics(SM_XVIRTUALSCREEN) +
        GetSystemMetrics(SM_CXVIRTUALSCREEN) + 100,
        FInitialWindowBounds.Top,
        FInitialWindowBounds.Right - FInitialWindowBounds.Left,
        FInitialWindowBounds.Bottom - FInitialWindowBounds.Top);
    end;
    Show;
  end;
  // Bereits sichtbares Registerkartenfenster nicht erneut anzeigen:
  // das verhindert Aktivierungs- und Z-Order-Flackern beim Nachladen.
  APDF.Show;
  // Die aktive Seite nach dem Einbetten vermessen und erst dann starten.
  FTabs.Realign;
  APDF.Realign;
  // Diagnose: Die erste Registerkarte auch bei weiteren PDFs aktiv lassen.
  if (FTabs.PageCount > 0) and (not FFirstPDFInitialized) then
  begin
    if FInitialWindowOffscreen and not FActivationTimer.Enabled then
    begin
      FActivationChecks := 0;
      FActivationTimer.Enabled := True;
    end;
    FAddingPDF := True;
    try
      FTabs.ActivePage := FTabs.Pages[0];
    finally
      FAddingPDF := False;
    end;
    PostMessage(Handle, WM_APP + 193, 0, 0);
  end;
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
  // Der erste Tab bleibt waehrend seiner WebView2-Initialisierung aktiv.
  // Das zuletzt angeforderte PDF wird danach automatisch aktiviert.
  // Falls die erste PDF schon navigiert hat, ist die einmalige
  // Initialisierung abgeschlossen; kein Zurueckspringen zum ersten Tab.
  if (not FFirstPDFInitialized) and (FTabs.PageCount > 0) then
  begin
    if FTabs.Pages[0].ControlCount > 0 then
      if FTabs.Pages[0].Controls[0] is TPDFBrowserForm then
        FFirstPDFInitialized :=
          TPDFBrowserForm(FTabs.Pages[0].Controls[0]).PDFNavigationStarted;
  end;
  if (not FFirstPDFInitialized) and (FTabs.PageCount > 1) and
     (FTabs.ActivePage = FTabs.Pages[0]) then
  begin
    FDeferredActivePDF := APDF;
    FTabs.Invalidate; // Zielregister optisch hervorheben, bevor der Wechsel erfolgt.
    FActivationChecks := 0;
    FActivationTimer.Enabled := True;
    PostMessage(Handle, WM_APP + 193, 0, 0);
    Exit;
  end;
  FDeferredActivePDF := nil;
  FTabs.Invalidate;
  FActivationTimer.Enabled := False;
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
    if Tab <> FTabs.ActivePage then Continue;
    for J := 0 to Tab.ControlCount - 1 do
      if Tab.Controls[J] is TPDFBrowserForm then
      begin
        TPDFBrowserForm(Tab.Controls[J]).RefreshActiveTabPDF;
        TPDFBrowserForm(Tab.Controls[J]).UpdateAttachmentWindowPosition;
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
    PostMessage(Handle, WM_APP + 193, 0, 0); // Auch bereits aktiver erster Tab.
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
  NewHint: string;
begin
  // TPageControl empfaengt die Mausereignisse auf den Registerreitern.
  // TTabSheet.Hint allein wird dort von Windows nicht angezeigt.
  TabIndex := FTabs.IndexOfTabAt(X, Y);
  if (TabIndex >= 0) and (TabIndex < FTabs.PageCount) then
    NewHint := FTabs.Pages[TabIndex].Hint
  else
    NewHint := '';
  if FTabs.Hint <> NewHint then
  begin
    FTabs.Hint := NewHint;
    Application.CancelHint;
  end;
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
    // Vor dem Entfernen des Parent unsichtbar machen. Sonst wird
    // das eingebettete Formular kurz ein eigenstaendiges Fenster
    // und kann das Registerkartenfenster nach hinten verdraengen.
    PDF.Hide;
    PDF.Parent := nil;
    PDF.Close;
  end;
  Tab.Free;
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
      Close
    else if Application.MainForm = Self then
      Close
    else
      Hide;
  end;
end;

procedure TPDFTabsForm.TabMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
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
begin
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
end;

end.
