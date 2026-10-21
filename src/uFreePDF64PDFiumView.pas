unit uFreePDF64PDFiumView;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.CommDlg, System.SysUtils, System.Classes, Vcl.Controls,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Graphics, Vcl.Forms, Vcl.Dialogs,
  Vcl.Printers, Vcl.Clipbrd, Vcl.ComCtrls, Vcl.Menus, System.Generics.Collections, Math, System.Types, uFreePDF64PDFiumCore;

type
  // TWinControl/VCL deklariert diese Events als protected.
  // Kleine Ableitungen machen sie fuer die programmatische Zuweisung zugaenglich.
  // Zugriff auf die geschuetzten VCL-Eigenschaften fuer den Speicherstatus.
  TPDFiumSaveButton = class(TButton)
  public
    property ParentBackground;
    property Color;
  end;

  TPDFiumScrollBox = class(TScrollBox)
  public
    property OnMouseWheel;
    property OnKeyDown;
  end;

  TPDFiumOutlineTree = class(TTreeView)
  public
    property OnMouseWheel;
  end;

  TPDFiumImage = class(TImage)
  public
    property OnMouseWheel;
  end;

  TFreePDF64PDFiumView = class(TPanel)
  private
    FCore: TFreePDF64PDFiumCore;
    FScroll: TPDFiumScrollBox;
    FOutlinePanel: TPanel;
    FOutlineSplitter: TSplitter;
    FOutlineTree: TPDFiumOutlineTree;
    FThumbScroll: TPDFiumScrollBox;
    FThumbTab, FBookmarksTab, FOutlineClose: TButton;
    FThumbTimer: TTimer;
    FThumbNext: Integer;
    FThumbImages: TList;
    FThumbSelected: TList<Integer>;
    FThumbAnchor: Integer;
    FThumbMenu: TPopupMenu;
    FOutlineHeader: TPanel;
    FOutlineTitle: TLabel;
    FOutlineButton: TButton;
    FOutlineItems: TObjectList<TPDFBookmarkItem>;
    FImage: TPDFiumImage;
    FPages: TList;
    FRendering: Boolean;
    FLoadedPages: array of Boolean;
    FRenderTimer: TTimer;
    FLastScrollPosition: Integer;
    FStrokePage: Integer;
    FBar: TPanel;
    FEditBar: TPanel;
    FEditToggle: TButton;
    FEditVisible: Boolean;
    FPrev, FNext, FMinus, FPlus, FFit, FPrint, FHelp: TButton;
    FStatus: TLabel;
    FZoomStatus: TLabel;
    FInfo: TButton;
    FPageEdit: TEdit;
    FGoPage: TButton;
    FFind: TButton;
    FFindTerm: string;
    FMatchPage, FMatchChar, FMatchCount: Integer;
    FTotalSearchMatches: Integer;
    FSearchTimer: TTimer;
    FSearchPage: Integer;
    FSearchMatches: TArray<TPDFTextMatch>;
    FSearchRunning: Boolean;
    FOnSearchCountChanged: TNotifyEvent;
    FWheelAccum: Integer;
    FMarker, FSave, FQuickSave: TButton;
    FUndoMenuItem: TMenuItem;
    FShapeSelect: TComboBox;
    FWidthSelect: TComboBox;
    FColorButton: TButton;
    FColorSwatch: TPanel;
    FMarkColor: TColor;
    FShapeStart: TPoint;
    FMarkMode: Boolean;
    FCurrentStroke: TPDFInkStroke;
    FSelecting: Boolean;
    FSelAnchorPage, FSelAnchorChar: Integer;
    FSelFocusPage, FSelFocusChar: Integer;
    FPreviewBitmap: TBitmap;
    FPage: Integer;
    FZoom: Double;
    FFitMode: Boolean;
    FViewMode: Integer; // 0 = Seitenbreite, 1 = ganze Seite, 2 = 100 %, 3 = frei
    FTwoPage: Boolean;
    FContinuous: Boolean;
    FFlowSelect: TComboBox;
    FTwoPageButton: TButton;
    FViewSelect: TComboBox;
    procedure SearchTimerTick(Sender: TObject);
    procedure ToggleEditBar(Sender: TObject);
    procedure ToggleOutline(Sender: TObject);
    procedure OutlineTabClick(Sender: TObject);
    procedure ThumbClick(Sender: TObject);
    procedure ThumbMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DeleteSelectedThumbs(Sender: TObject);
    procedure RotateSelectedThumbs(Sender: TObject);
    procedure UndoClick(Sender: TObject);
    procedure ThumbMenuPopup(Sender: TObject);
    procedure UpdateSaveState;
    procedure ThumbTimerTick(Sender: TObject);
    procedure ThumbAreaResize(Sender: TObject);
    procedure BuildThumbnails;
    procedure UpdateThumbnailSelection;
    procedure ShowOutlineTab(AThumbnails: Boolean);
    procedure OutlineChange(Sender: TObject; Node: TTreeNode);
    procedure PopulateOutline;
    procedure UpdateSecurityIcon;
    procedure LayoutToolbar(Sender: TObject);
    procedure InfoClick(Sender: TObject);
    function RequestPDFPassword(const AFileName: string; out APassword: string): Boolean;
    procedure SearchNext(ADirection: Integer);
    function FindCachedSearchMatch(AStartPage, AStartChar, ADirection: Integer;
      out APage, ACharIndex, ACharCount: Integer): Boolean;
    procedure ViewModeChange(Sender: TObject);
    procedure TwoPageClick(Sender: TObject);
    procedure FlowModeChange(Sender: TObject);
    procedure UpdateVisiblePage;
    function PageImage(AIndex: Integer): TPDFiumImage;
    procedure LayoutAllPages;
    procedure RenderVisiblePages;
    procedure RenderTimerTick(Sender: TObject);
    procedure DrawPageStrokes(APage: Integer);
    procedure DrawSearchHighlight(APage: Integer);
    procedure DrawTextSelection(APage: Integer);
    procedure RefreshSelectedPages;
    function SelectionHit(Sender: TObject; X, Y: Integer): Integer;
    procedure FindClick(Sender: TObject);
    procedure MarkerClick(Sender: TObject);
    procedure ColorClick(Sender: TObject);
    procedure SaveClick(Sender: TObject);
    procedure ImageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ImageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure AppendPoint(X, Y: Integer);
    procedure BuildEllipseStroke(X1, Y1, X2, Y2: Integer);
    procedure UpdateShapeStroke(X, Y: Integer);
    procedure DrawLivePreview;
    procedure DrawStrokes;
    procedure Navigate(Sender: TObject);
    procedure GoToPage(Sender: TObject);
    procedure PageKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure OutlineMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ScrollMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ZoomClick(Sender: TObject);
    procedure FitClick(Sender: TObject);
    procedure PrintClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure ResizeView(Sender: TObject);
    procedure PaintPage;
  public
    constructor CreateInParent(AOwner: TComponent; AParent: TWinControl);
    destructor Destroy; override;
    procedure OpenPDF(const AFileName: string);
    procedure RefreshPDFDisplay;
    procedure SetFullScreenDisplay(AEnabled: Boolean);
    procedure ReleasePDFForExternalChange;
    procedure RotatePages(AFirstPage, ALastPage, AAngle: Integer);
    procedure ShowPage(APage: Integer);
    procedure ToggleMarker;
    procedure PlaceEditButton(AParent: TWinControl; ALeft, ATop, AHeight: Integer);
    procedure ShowSearchDialog;
    procedure SearchText(const AText: string);
    procedure NextSearchMatch(ADirection: Integer);
    procedure SelectAllText;
    procedure CopySelectedText;
    function ConfirmUnsaved: Boolean;
    property SearchMatchCount: Integer read FTotalSearchMatches;
    property OnSearchCountChanged: TNotifyEvent read FOnSearchCountChanged write FOnSearchCountChanged;
    property PageIndex: Integer read FPage;
  end;

implementation

procedure TFreePDF64PDFiumView.SetFullScreenDisplay(AEnabled: Boolean);
begin
  // Nur die PDF-Seiten sichtbar lassen; den Bearbeitungszustand bewahren.
  FBar.Visible := not AEnabled;
  FEditBar.Visible := (not AEnabled) and FEditVisible;
end;

constructor TFreePDF64PDFiumView.CreateInParent(AOwner: TComponent; AParent: TWinControl);
  function Btn(const S: string; X, W: Integer; Handler: TNotifyEvent): TButton;
  begin
    Result := TButton.Create(Self);
    Result.Parent := FBar;
    Result.SetBounds(X, 4, W, 28);
    Result.Caption := S;
    Result.OnClick := Handler;
  end;
begin
  inherited Create(AOwner);
  Parent := AParent; // Vor dem Erzeugen von TPanel, TScrollBox und TEdit
  BevelOuter := bvNone;
  FCore := TFreePDF64PDFiumCore.Create;
  FPage := 0;
  FMatchPage := -1;
  FMatchChar := -1;
  FMatchCount := 0;
  FTotalSearchMatches := 0;
  FSearchPage := 0;
  FSearchRunning := False;
  FSearchTimer := TTimer.Create(Self);
  FSearchTimer.Enabled := False;
  FSearchTimer.Interval := 15;
  FSearchTimer.OnTimer := SearchTimerTick;
  FZoom := 1.0;
  FFitMode := True;
  FViewMode := 1;
  FBar := TPanel.Create(Self);
  FBar.Parent := Self;
  FBar.Align := alTop;
  FBar.Height := 36;
  FEditVisible := False;
  FBar.BevelOuter := bvNone;
  FEditBar := TPanel.Create(Self);
  FEditBar.Parent := Self;
  FEditBar.Align := alTop;
  FEditBar.Height := 0;
  FEditBar.BevelOuter := bvNone;
  FEditBar.Visible := False;
  FEditToggle := Btn('Bearbeiten ▼', 8, 110, ToggleEditBar);
  FEditToggle.Hint := 'Markierungswerkzeuge ein- oder ausblenden';
  FEditToggle.ShowHint := True;
  FOutlineButton := Btn('☷', 8, 36, ToggleOutline);
  FOutlineButton.Hint := 'Inhaltsverzeichnis / Seitenminiaturen';
  FOutlineButton.ShowHint := True;
  FPrev := Btn('Zurück', 8, 70, Navigate);
  FNext := Btn('Weiter', 84, 70, Navigate);
  FMinus := Btn('−', 387, 34, ZoomClick);
  FPlus := Btn('+', 427, 34, ZoomClick);
  FFit := Btn('Seite einpassen', 467, 124, FitClick);
  FViewSelect := TComboBox.Create(Self);
  FViewSelect.Parent := FBar;
  FViewSelect.Style := csDropDownList;
  FViewSelect.SetBounds(597, 5, 156, 26);
  FViewSelect.Items.Add('Seitenbreite');
  FViewSelect.Items.Add('Ganze Seite');
  FViewSelect.Items.Add('Originalgröße (100 %)');
  FViewSelect.Items.Add('Benutzerdefiniert');
  FViewSelect.ItemIndex := 1;
  FViewSelect.OnChange := ViewModeChange;
  FTwoPage := False;
  FTwoPageButton := Btn('2 Seiten', 770, 82, TwoPageClick);
  FTwoPageButton.Hint := 'Einzelseiten- / Doppelseitenansicht';
  FTwoPageButton.ShowHint := True;
  FContinuous := True;
  FFlowSelect := TComboBox.Create(Self);
  FFlowSelect.Parent := FBar;
  FFlowSelect.Style := csDropDownList;
  FFlowSelect.Items.Add('Durchgehend');
  FFlowSelect.Items.Add('Seitenweise');
  FFlowSelect.ItemIndex := 0;
  FFlowSelect.Hint := 'Zwischen durchgehender und seitenweiser Anzeige wechseln';
  FFlowSelect.ShowHint := True;
  FFlowSelect.OnChange := FlowModeChange;
  FPrint := Btn('Drucken', 1025, 86, PrintClick);
  FHelp := Btn('?', 1120, 34, HelpClick);
  FHelp.Hint := 'Hilfe zur PDF-Anzeige';
  FHelp.ShowHint := True;
  FInfo := Btn('ⓘ', 1120, 34, InfoClick);
  FInfo.Hint := 'Dokumenteigenschaften anzeigen';
  FInfo.ShowHint := True;
  FInfo.Font.Name := 'Segoe UI Symbol';
  FInfo.Font.Size := 12;
  FStatus := TLabel.Create(Self);
  FStatus.Parent := FBar;
  FStatus.SetBounds(160, 11, 100, 18);
  FZoomStatus := TLabel.Create(Self);
  FZoomStatus.Parent := FBar;
  FZoomStatus.AutoSize := False;
  FZoomStatus.SetBounds(460, 11, 55, 18);
  FMarker := Btn('Markieren: AUS', 766, 116, MarkerClick);
  FMarker.Hint := 'Markierungsmodus ein- oder ausschalten';
  FMarker.ShowHint := True;
  FShapeSelect := TComboBox.Create(Self);
  FShapeSelect.Parent := FBar;
  FShapeSelect.Style := csDropDownList;
  FShapeSelect.SetBounds(866, 5, 110, 26);
  FShapeSelect.Items.Add('Freihand');
  FShapeSelect.Items.Add('Linie');
  FShapeSelect.Items.Add('Rechteck');
  FShapeSelect.Items.Add('Ellipse');
  FShapeSelect.ItemIndex := 0;
  FShapeSelect.Hint := 'Markierungsform auswählen';
  FShapeSelect.ShowHint := True;
  FWidthSelect := TComboBox.Create(Self);
  FWidthSelect.Parent := FBar;
  FWidthSelect.Style := csDropDownList;
  FWidthSelect.SetBounds(982, 5, 84, 26);
  FWidthSelect.Items.Add('1 pt');
  FWidthSelect.Items.Add('2 pt');
  FWidthSelect.Items.Add('3 pt');
  FWidthSelect.Items.Add('5 pt');
  FWidthSelect.Items.Add('8 pt');
  FWidthSelect.Items.Add('12 pt');
  FWidthSelect.ItemIndex := 3;
  FWidthSelect.Hint := 'Strichstärke der neuen Markierungen';
  FWidthSelect.ShowHint := True;
  FMarkColor := RGB(255, 235, 0);
  FColorButton := Btn('Farbe ...', 1072, 108, ColorClick);
  FColorSwatch := TPanel.Create(Self);
  FColorSwatch.Parent := FBar;
  FColorSwatch.BevelOuter := bvLowered;
  FColorSwatch.Color := FMarkColor;
  FColorSwatch.Caption := '';
  FColorSwatch.ParentBackground := False;
  FColorSwatch.SetBounds(FColorButton.Left + FColorButton.Width + 5, 8, 22, 20);
  FColorSwatch.Cursor := crHandPoint;
  FColorSwatch.OnClick := ColorClick;
  FColorButton.Hint := 'Farbe der neuen Markierungen auswählen';
  FColorButton.ShowHint := True;
  FSave := Btn('Speichern unter ...', 1156, 153, SaveClick);
  FQuickSave := Btn('Speichern unter ...', 900, 135, SaveClick);
  FQuickSave.Hint := 'PDF-Kopie unter neuem Namen speichern';
  FQuickSave.ShowHint := True;
  FMarker.Visible := False; // Bearbeiten schaltet den Markierungsmodus direkt.
  FShapeSelect.Parent := FEditBar;
  FWidthSelect.Parent := FEditBar;
  FColorButton.Parent := FEditBar;
  FColorSwatch.Parent := FEditBar;
  FSave.Parent := FEditBar;
  FPageEdit := TEdit.Create(Self);
  FPageEdit.Parent := FBar;
  FPageEdit.SetBounds(163, 6, 48, 24);
  FPageEdit.Text := '1';
  FPageEdit.OnKeyDown := PageKeyDown;
  FGoPage := Btn('Gehe zu', 217, 74, GoToPage);
  // Die Textsuche befindet sich bereits in der oberen Viewer-Leiste.
  FFind := nil;
  FPages := TList.Create;
  FRenderTimer := TTimer.Create(Self);
  FRenderTimer.Interval := 80;
  FRenderTimer.OnTimer := RenderTimerTick;
  FRenderTimer.Enabled := True;
  FOutlineItems := TObjectList<TPDFBookmarkItem>.Create(True);
  FOutlinePanel := TPanel.Create(Self);
  FOutlinePanel.Parent := Self;
  FOutlinePanel.Align := alLeft;
  FOutlinePanel.Width := 300;
  FOutlinePanel.Constraints.MinWidth := 200;
  FOutlinePanel.Constraints.MaxWidth := 700;
  FOutlinePanel.Caption := '';
  FOutlinePanel.Visible := False;
  FOutlineSplitter := TSplitter.Create(Self);
  FOutlineSplitter.Parent := Self;
  FOutlineSplitter.Align := alLeft;
  FOutlineSplitter.Width := 9;
  FOutlineSplitter.Color := clSilver;
  FOutlineSplitter.Beveled := True;
  FOutlineSplitter.MinSize := 200;
  FOutlineSplitter.ResizeStyle := rsUpdate;
  FOutlineSplitter.Cursor := crHSplit;
  FOutlineSplitter.Visible := False;
  FOutlineHeader := TPanel.Create(Self);
  FOutlineHeader.Parent := FOutlinePanel;
  FOutlineHeader.Align := alTop;
  FOutlineHeader.Height := 74;
  FOutlineHeader.BevelOuter := bvNone;
  FOutlineTitle := TLabel.Create(Self);
  FOutlineTitle.Parent := FOutlineHeader;
  FOutlineTitle.Caption := 'Inhaltsverzeichnis';
  FOutlineTitle.SetBounds(12, 8, 200, 22);
  FOutlineTitle.Font.Style := [fsBold];
  FOutlineClose := TButton.Create(Self);
  FOutlineClose.Parent := FOutlineHeader;
  FOutlineClose.Caption := 'X';
  FOutlineClose.SetBounds(345, 5, 32, 28);
  FOutlineClose.Anchors := [akTop, akRight];
  FOutlineClose.OnClick := ToggleOutline;
  FThumbTab := TButton.Create(Self);
  FThumbTab.Parent := FOutlineHeader;
  FThumbTab.Caption := 'Seiten';
  FThumbTab.Tag := 1;
  FThumbTab.SetBounds(8, 40, 100, 28);
  FThumbTab.OnClick := OutlineTabClick;
  FBookmarksTab := TButton.Create(Self);
  FBookmarksTab.Parent := FOutlineHeader;
  FBookmarksTab.Caption := 'Inhalte';
  FBookmarksTab.Tag := 0;
  FBookmarksTab.SetBounds(114, 40, 100, 28);
  FBookmarksTab.OnClick := OutlineTabClick;
  FOutlineTree := TPDFiumOutlineTree.Create(Self);
  FOutlineTree.Parent := FOutlinePanel;
  FOutlineTree.Align := alClient;
  FOutlineTree.ReadOnly := True;
  FOutlineTree.HideSelection := False;
  FOutlineTree.OnChange := OutlineChange;
  FOutlineTree.OnMouseWheel := OutlineMouseWheel;
  FThumbScroll := TPDFiumScrollBox.Create(Self);
  FThumbScroll.Parent := FOutlinePanel;
  FThumbScroll.Align := alClient;
  FThumbScroll.VertScrollBar.Tracking := True;
  FThumbScroll.Color := clWhite;
  FThumbScroll.OnResize := ThumbAreaResize;
  FThumbScroll.OnMouseWheel := OutlineMouseWheel;
  FThumbImages := TList.Create;
  FThumbSelected := TList<Integer>.Create;
  FThumbAnchor := -1;
  FThumbMenu := TPopupMenu.Create(Self);
  FThumbMenu.Items.Add(TMenuItem.Create(FThumbMenu));
  with FThumbMenu.Items[FThumbMenu.Items.Count - 1] do
  begin
    Caption := 'Ausgewählte Seite(n) löschen';
    OnClick := DeleteSelectedThumbs;
  end;
  FThumbMenu.Items.Add(TMenuItem.Create(FThumbMenu));
  with FThumbMenu.Items[FThumbMenu.Items.Count - 1] do
  begin
    Caption := 'Ausgewählte Seite(n) 90° im Uhrzeigersinn drehen';
    OnClick := RotateSelectedThumbs;
  end;
  FUndoMenuItem := TMenuItem.Create(FThumbMenu);
  FUndoMenuItem.Caption := 'Letzten Schritt rückgängig machen';
  FUndoMenuItem.OnClick := UndoClick;
  FThumbMenu.Items.Add(FUndoMenuItem);
  FThumbMenu.OnPopup := ThumbMenuPopup;
  FThumbTimer := TTimer.Create(Self);
  FThumbTimer.Enabled := False;
  FThumbTimer.Interval := 35;
  FThumbTimer.OnTimer := ThumbTimerTick;
  ShowOutlineTab(True);
  FScroll := TPDFiumScrollBox.Create(Self);
  FScroll.Parent := Self;
  FScroll.Align := alClient;
  FScroll.Color := clBtnShadow;
  FScroll.OnResize := ResizeView;
  FScroll.TabStop := True;
  FScroll.OnMouseWheel := ScrollMouseWheel;
  FScroll.OnKeyDown := PageKeyDown;
  FImage := TPDFiumImage.Create(Self);
  FImage.Parent := FScroll;
  FImage.AutoSize := False;
  FImage.Stretch := False;
  FImage.Proportional := False;
  FImage.OnMouseDown := ImageMouseDown;
  FImage.OnMouseMove := ImageMouseMove;
  FImage.OnMouseUp := ImageMouseUp;
  FImage.OnMouseWheel := ScrollMouseWheel;
  FImage.Tag := 0;
  FPages.Add(FImage);
  FBar.OnResize := LayoutToolbar;
  FEditBar.OnResize := LayoutToolbar;
  LayoutToolbar(nil);
end;

destructor TFreePDF64PDFiumView.Destroy;
begin
  if Assigned(FSearchTimer) then FSearchTimer.Enabled := False;
  if Assigned(FRenderTimer) then FRenderTimer.Enabled := False;
  FPreviewBitmap.Free;
  FCurrentStroke.Free;
  FPages.Free;
  if Assigned(FThumbTimer) then FThumbTimer.Enabled := False;
  FThumbSelected.Free;
  FThumbImages.Free;
  FOutlineItems.Free;
  FCore.Free;
  inherited;
end;

procedure TFreePDF64PDFiumView.RotatePages(AFirstPage, ALastPage,
  AAngle: Integer);
var
  SourceName, TempName, BackupName: string;
  WasReleased: Boolean;
begin
  if not ConfirmUnsaved then Exit;
  SourceName := FCore.FileName;
  if (SourceName = '') or not FileExists(SourceName) then
    raise EPDFiumViewer.Create('Die PDF-Datei wurde nicht gefunden.');
  if (AFirstPage < 1) or (ALastPage > FCore.PageCount) or
     (AFirstPage > ALastPage) then
    raise EPDFiumViewer.CreateFmt('Bitte Seiten zwischen 1 und %d angeben.',
      [FCore.PageCount]);
  TempName := SourceName + '.pdfium_rotate_tmp.pdf';
  BackupName := ChangeFileExt(SourceName,
    '_BAK' + ExtractFileExt(SourceName));
  if FileExists(TempName) and not DeleteFile(TempName) then
    raise EPDFiumViewer.Create('Temporäre Datei kann nicht entfernt werden.');
  WasReleased := False;
  try
    // Zuerst vollständig in eine andere Datei speichern.
    FCore.RotatePages(AFirstPage, ALastPage, AAngle, TempName);
    if not FileExists(BackupName) then
      if not Winapi.Windows.CopyFile(PChar(SourceName), PChar(BackupName), True) then
        RaiseLastOSError;
    FCore.CloseFile;
    WasReleased := True;
    if not Winapi.Windows.MoveFileEx(PChar(TempName), PChar(SourceName),
      MOVEFILE_REPLACE_EXISTING or MOVEFILE_COPY_ALLOWED) then
      RaiseLastOSError;
  finally
    if FileExists(TempName) then DeleteFile(TempName);
    if WasReleased then
    begin
      // Auch nach einem Dateifehler die Originalansicht wieder öffnen.
      OpenPDF(SourceName);
      if FCore.PageCount > 0 then ShowPage(AFirstPage - 1);
    end;
  end;
end;

procedure TFreePDF64PDFiumView.ReleasePDFForExternalChange;
begin
  // QPDF muss die Originaldatei unter Windows ersetzen koennen.
  // Daher vorher das PDFium-Dokumenthandle freigeben.
  FCore.CloseFile;
  UpdateSecurityIcon;
end;

function TFreePDF64PDFiumView.RequestPDFPassword(const AFileName: string;
  out APassword: string): Boolean;
var
  Dialog: TForm;
  ViewerWindow: TCustomForm;
  Prompt, PasswordHint: TLabel;
  Entry: TEdit;
  OKButton, CancelButton: TButton;
begin
  APassword := '';
  ViewerWindow := GetParentForm(Self);
  if ViewerWindow <> nil then
    Dialog := TForm.CreateNew(ViewerWindow)
  else
    Dialog := TForm.CreateNew(nil);
  try
    Dialog.Caption := 'FreePDF64-Viewer – PDF-Kennwort';
    Dialog.BorderStyle := bsDialog;
    if ViewerWindow <> nil then
    begin
      Dialog.PopupMode := pmExplicit;
      Dialog.PopupParent := ViewerWindow;
      Dialog.Position := poOwnerFormCenter;
    end
    else
      Dialog.Position := poScreenCenter;
    // Einheitliche Windows-Dialogschrift, ohne zusaetzliche Vergroesserung.
    Dialog.Font.Name := 'Segoe UI';
    Dialog.Font.Size := 9;
    Dialog.Scaled := True;
    Dialog.ClientWidth := 500;

    Prompt := TLabel.Create(Dialog);
    Prompt.Parent := Dialog;
    Prompt.ParentFont := True;
    Prompt.AutoSize := True;
    Prompt.WordWrap := True;
    Prompt.Left := 20;
    Prompt.Top := 18;
    Prompt.Width := Dialog.ClientWidth - 40;
    Prompt.Caption := 'Diese PDF-Datei ist kennwortgeschützt:' + sLineBreak +
      ExtractFileName(AFileName);

    // Den Eingabehinweis als eigene Zeile mit Abstand zum Dateinamen anzeigen.
    PasswordHint := TLabel.Create(Dialog);
    PasswordHint.Parent := Dialog;
    PasswordHint.ParentFont := True;
    PasswordHint.AutoSize := True;
    PasswordHint.WordWrap := True;
    PasswordHint.Left := 20;
    PasswordHint.Top := Prompt.Top + Prompt.Height + 14;
    PasswordHint.Width := Dialog.ClientWidth - 40;
    PasswordHint.Caption := 'Bitte geben Sie das Kennwort zum Öffnen ein:';

    // Die tatsächliche Texthöhe verwenden, statt fester Pixelwerte:
    // verhindert Überlappungen bei WQHD, 4K und vergrößerter Schrift.
    Entry := TEdit.Create(Dialog);
    Entry.Parent := Dialog;
    Entry.ParentFont := True;
    Entry.SetBounds(20, PasswordHint.Top + PasswordHint.Height + 6,
      Dialog.ClientWidth - 40, 30);
    Entry.PasswordChar := '*';
    Entry.TabOrder := 0;

    OKButton := TButton.Create(Dialog);
    OKButton.Parent := Dialog;
    OKButton.ParentFont := True;
    OKButton.Caption := 'Öffnen';
    OKButton.SetBounds(Dialog.ClientWidth - 212, Entry.Top + Entry.Height + 20, 90, 32);
    OKButton.ModalResult := mrOk;
    OKButton.Default := True;
    OKButton.TabOrder := 1;

    CancelButton := TButton.Create(Dialog);
    CancelButton.Parent := Dialog;
    CancelButton.ParentFont := True;
    CancelButton.Caption := 'Abbrechen';
    CancelButton.SetBounds(Dialog.ClientWidth - 112, OKButton.Top, 92, 32);
    CancelButton.ModalResult := mrCancel;
    CancelButton.Cancel := True;
    CancelButton.TabOrder := 2;

    Dialog.ClientHeight := CancelButton.Top + CancelButton.Height + 20;

    Dialog.ActiveControl := Entry;
    Result := Dialog.ShowModal = mrOk;
    if Result then APassword := Entry.Text;
    Entry.Clear;
  finally
    Dialog.Free;
  end;
end;

procedure TFreePDF64PDFiumView.OpenPDF(const AFileName: string);
var
  Password: string;
  Attempts: Integer;
begin
  if not ConfirmUnsaved then Exit;
  try
    FCore.OpenFile(AFileName);
  except
    on EPDFiumPasswordRequired do
    begin
      Attempts := 0;
      repeat
        if not RequestPDFPassword(AFileName, Password) then
          Abort;
        try
          FCore.OpenFile(AFileName, UTF8Encode(Password));
          Break;
        except
          on EPDFiumPasswordRequired do
          begin
            Inc(Attempts);
            if Attempts >= 5 then
              raise EPDFiumViewer.Create('Zu viele falsche Kennworteingaben.');
            MessageDlg('Das Kennwort ist nicht korrekt. Bitte versuchen Sie es erneut.',
              mtWarning, [mbOK], 0);
          end;
        end;
      until False;
    end;
  end;
  Password := '';
  UpdateSaveState;
  FSelecting := False;
  FSelAnchorPage := -1;
  FSelFocusPage := -1;
  FThumbSelected.Clear;
  FThumbAnchor := -1;
  UpdateSecurityIcon;
  FFindTerm := '';
  FMatchPage := -1;
  FMatchChar := -1;
  FMatchCount := 0;
  FPage := 0;
  FWheelAccum := 0;
  FFitMode := True;
  FViewMode := 1;
  FViewSelect.ItemIndex := 1;
  PaintPage;
  PopulateOutline;
  BuildThumbnails;
end;

procedure TFreePDF64PDFiumView.RefreshPDFDisplay;
begin
  // Nach dem Einbetten in ein TabSheet sind die Clientmasse erst spaeter gueltig.
  if (FCore.PageCount = 0) or (FScroll.ClientWidth < 50) or
     (FScroll.ClientHeight < 50) then Exit;
  PaintPage;
  RenderVisiblePages;
  FScroll.Invalidate;
end;

procedure TFreePDF64PDFiumView.FindClick(Sender: TObject);
var Term: string;
begin
  Term := FFindTerm;
  if InputQuery('PDF-Textsuche', 'Suchbegriff:', Term) then
    SearchText(Term);
end;

procedure TFreePDF64PDFiumView.ShowSearchDialog;
begin
  FindClick(Self);
end;

procedure TFreePDF64PDFiumView.SearchTimerTick(Sender: TObject);
var
  PageMatches: TArray<TPDFTextMatch>;
  I, N, Pg: Integer;
begin
  if not FSearchRunning then Exit;
  if FSearchPage >= FCore.PageCount then
  begin
    FSearchRunning := False;
    FSearchTimer.Enabled := False;
    if Assigned(FOnSearchCountChanged) then FOnSearchCountChanged(Self);
    Exit;
  end;
  Pg := FSearchPage;
  Inc(FSearchPage);
  // PDFium bleibt ausschliesslich im UI-Thread: keine konkurrierenden
  // Dokumentzugriffe. Pro Tick nur eine Seite, daher kein 800-Seiten-Block.
  PageMatches := FCore.FindTextMatchesOnPage(FFindTerm, Pg);
  N := Length(FSearchMatches);
  SetLength(FSearchMatches, N + Length(PageMatches));
  for I := 0 to High(PageMatches) do
    FSearchMatches[N + I] := PageMatches[I];
  FTotalSearchMatches := Length(FSearchMatches);
  if Assigned(FOnSearchCountChanged) then FOnSearchCountChanged(Self);
  if (N = 0) and (Length(PageMatches) > 0) then SearchNext(1);
end;

procedure TFreePDF64PDFiumView.SearchText(const AText: string);
var Term: string; PageIndex: Integer;
begin
  Term := Trim(AText);
  FSearchTimer.Enabled := False;
  FSearchRunning := False;
  SetLength(FSearchMatches, 0);
  FSearchPage := 0;
  if Term = '' then
  begin
    FSearchTimer.Enabled := False;
    FSearchRunning := False;
    SetLength(FSearchMatches, 0);
    FFindTerm := '';
    FMatchPage := -1;
    FMatchChar := -1;
    FMatchCount := 0;
    FTotalSearchMatches := 0;
    if Assigned(FOnSearchCountChanged) then FOnSearchCountChanged(Self);
    if FCore.PageCount > 0 then
      for PageIndex := 0 to High(FLoadedPages) do
        if FLoadedPages[PageIndex] then
        begin
          FCore.RenderPage(PageIndex, PageImage(PageIndex).Picture.Bitmap,
            PageImage(PageIndex).Width, PageImage(PageIndex).Height);
          DrawPageStrokes(PageIndex);
          PageImage(PageIndex).Invalidate;
        end;
    if FCore.PageCount > 0 then UpdateVisiblePage;
    Exit;
  end;
  if FCore.PageCount = 0 then Exit;
  FMatchPage := -1;
  FMatchChar := -1;
  FMatchCount := 0;
  FFindTerm := Term;
  FTotalSearchMatches := 0;
  if Assigned(FOnSearchCountChanged) then FOnSearchCountChanged(Self);
  FSearchRunning := True;
  FSearchTimer.Enabled := True;
end;

procedure TFreePDF64PDFiumView.NextSearchMatch(ADirection: Integer);
begin
  SearchNext(ADirection);
end;

function TFreePDF64PDFiumView.FindCachedSearchMatch(
  AStartPage, AStartChar, ADirection: Integer;
  out APage, ACharIndex, ACharCount: Integer): Boolean;
var
  I, Selected: Integer;
begin
  Result := False;
  Selected := -1;
  if Length(FSearchMatches) = 0 then Exit;
  if ADirection >= 0 then
  begin
    for I := 0 to High(FSearchMatches) do
      if (FSearchMatches[I].PageIndex > AStartPage) or
         ((FSearchMatches[I].PageIndex = AStartPage) and
          (FSearchMatches[I].CharIndex >= AStartChar)) then
      begin Selected := I; Break; end;
    if Selected < 0 then Selected := 0;
  end
  else
  begin
    for I := High(FSearchMatches) downto 0 do
      if (FSearchMatches[I].PageIndex < AStartPage) or
         ((FSearchMatches[I].PageIndex = AStartPage) and
          (FSearchMatches[I].CharIndex <= AStartChar)) then
      begin Selected := I; Break; end;
    if Selected < 0 then Selected := High(FSearchMatches);
  end;
  APage := FSearchMatches[Selected].PageIndex;
  ACharIndex := FSearchMatches[Selected].CharIndex;
  ACharCount := FSearchMatches[Selected].CharCount;
  Result := True;
end;

procedure TFreePDF64PDFiumView.SearchNext(ADirection: Integer);
var Pg, Idx, Cnt, StartPg, StartChar, OldPage: Integer;
begin
  if (FFindTerm = '') or (FCore.PageCount = 0) then Exit;
  if FMatchPage < 0 then
  begin
    StartPg := FPage;
    if ADirection > 0 then StartChar := 0 else StartChar := MaxInt;
  end
  else
  begin
    StartPg := FMatchPage;
    if ADirection > 0 then StartChar := FMatchChar + Max(1, FMatchCount)
    else StartChar := FMatchChar - 1;
  end;
  if FindCachedSearchMatch(StartPg, StartChar, ADirection,
    Pg, Idx, Cnt) then
  begin
    OldPage := FMatchPage;
    FMatchPage := Pg;
    FMatchChar := Idx;
    FMatchCount := Cnt;
    // Alle sichtbaren Seiten neu rendern: jeder Treffer wird hervorgehoben.
    for OldPage := 0 to High(FLoadedPages) do
      if FLoadedPages[OldPage] and (Abs(OldPage - Pg) <= 2) then
      begin
        FCore.RenderPage(OldPage, PageImage(OldPage).Picture.Bitmap,
          PageImage(OldPage).Width, PageImage(OldPage).Height);
        DrawPageStrokes(OldPage);
        DrawSearchHighlight(OldPage);
        // TImage erkennt direkte Canvas-Änderungen nicht automatisch.
        PageImage(OldPage).Invalidate;
      end;
    ShowPage(Pg);
    UpdateVisiblePage;
  end
  else
    MessageDlg('Keine weiteren Treffer gefunden.', mtInformation, [mbOK], 0);
end;

procedure TFreePDF64PDFiumView.ShowPage(APage: Integer);
var Img: TPDFiumImage;
begin
  if (APage < 0) or (APage >= FCore.PageCount) then Exit;
  FPage := APage;
  Img := PageImage(APage);
  if Img <> nil then
    FScroll.VertScrollBar.Position := Max(0,
      FScroll.VertScrollBar.Position +
      FScroll.ScreenToClient(Img.ClientToScreen(Point(0, 0))).Y - 8);
  if not FContinuous then
  begin
    LayoutAllPages;
    FScroll.VertScrollBar.Position := 0;
  end;
  UpdateVisiblePage;
  RenderVisiblePages;
end;

procedure TFreePDF64PDFiumView.Navigate(Sender: TObject);
begin
  if Sender = FPrev then ShowPage(FPage - 1)
  else ShowPage(FPage + 1);
end;

procedure TFreePDF64PDFiumView.GoToPage(Sender: TObject);
var N: Integer;
begin
  if TryStrToInt(Trim(FPageEdit.Text), N) then ShowPage(N - 1)
  else FPageEdit.Text := IntToStr(FPage + 1);
end;

procedure TFreePDF64PDFiumView.PageKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = Ord('Z')) and (ssCtrl in Shift) then
  begin
    UndoClick(nil);
    Key := 0;
    Exit;
  end;
  case Key of
    VK_F3: begin
      if ssShift in Shift then SearchNext(-1) else SearchNext(1);
      Key := 0;
    end;
    VK_RETURN: begin GoToPage(nil); Key := 0; end;
    VK_NEXT: begin ShowPage(FPage + 1); Key := 0; end;
    VK_PRIOR: begin ShowPage(FPage - 1); Key := 0; end;
    VK_HOME: if ssCtrl in Shift then
      begin ShowPage(0); Key := 0; end;
    VK_END: if ssCtrl in Shift then
      begin ShowPage(FCore.PageCount - 1); Key := 0; end;
  end;
end;

procedure TFreePDF64PDFiumView.OutlineMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var
  Step, P: Integer;
begin
  // Das Mausrad innerhalb der Seitenleiste darf nicht die PDF-Seite scrollen.
  Handled := True;
  if (FOutlinePanel = nil) or not FOutlinePanel.Visible then Exit;
  if FOutlineTree.Visible then
  begin
    // TTreeView besitzt eine eigene vertikale Scrollverwaltung.
    if WheelDelta < 0 then
      FOutlineTree.Perform(WM_VSCROLL, SB_LINEDOWN, 0)
    else
      FOutlineTree.Perform(WM_VSCROLL, SB_LINEUP, 0);
  end
  else if FThumbScroll.Visible then
  begin
    Step := Max(32, FThumbScroll.ClientHeight div 7);
    P := FThumbScroll.VertScrollBar.Position;
    if WheelDelta < 0 then
      FThumbScroll.VertScrollBar.Position := P + Step
    else
      FThumbScroll.VertScrollBar.Position := Max(0, P - Step);
  end;
end;

procedure TFreePDF64PDFiumView.ScrollMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
var Step, P: Integer;
begin
  Handled := True;
  if FCore.PageCount = 0 then Exit;
  if ssCtrl in Shift then
  begin
    FFitMode := False;
    FViewMode := 3;
    FViewSelect.ItemIndex := 3;
    if WheelDelta > 0 then FZoom := Min(5.0, FZoom * 1.10)
    else FZoom := Max(0.1, FZoom / 1.10);
    PaintPage;
    Exit;
  end;
  if not FContinuous then
  begin
    if WheelDelta < 0 then ShowPage(Min(FCore.PageCount - 1,
      FPage + IfThen(FTwoPage, 2, 1)))
    else ShowPage(Max(0, FPage - IfThen(FTwoPage, 2, 1)));
    Exit;
  end;
  Step := Max(32, FScroll.ClientHeight div 7);
  P := FScroll.VertScrollBar.Position;
  if WheelDelta < 0 then
    FScroll.VertScrollBar.Position := P + Step
  else
    FScroll.VertScrollBar.Position := Max(0, P - Step);
  UpdateVisiblePage;
  RenderVisiblePages;
end;

procedure TFreePDF64PDFiumView.ZoomClick(Sender: TObject);
begin
  FFitMode := False;
  FViewMode := 3;
  FViewSelect.ItemIndex := 3;
  if Sender = FPlus then FZoom := Min(5.0, FZoom * 1.25)
  else FZoom := Max(0.1, FZoom / 1.25);
  PaintPage;
end;

procedure TFreePDF64PDFiumView.FitClick(Sender: TObject);
begin
  FFitMode := True;
  FViewMode := 1;
  FViewSelect.ItemIndex := 1;
  PaintPage;
end;

procedure TFreePDF64PDFiumView.ViewModeChange(Sender: TObject);
begin
  FViewMode := FViewSelect.ItemIndex;
  FFitMode := FViewMode in [0, 1];
  if FViewMode = 2 then FZoom := 1.0;
  PaintPage;
end;

procedure TFreePDF64PDFiumView.TwoPageClick(Sender: TObject);
begin
  FTwoPage := not FTwoPage;
  if FTwoPage then FTwoPageButton.Caption := '1 Seite'
  else FTwoPageButton.Caption := '2 Seiten';
  PaintPage;
end;

procedure TFreePDF64PDFiumView.FlowModeChange(Sender: TObject);
begin
  FContinuous := FFlowSelect.ItemIndex = 0;
  FScroll.VertScrollBar.Position := 0;
  PaintPage;
end;

procedure TFreePDF64PDFiumView.ToggleOutline(Sender: TObject);
begin
  FOutlinePanel.Visible := not FOutlinePanel.Visible;
  FOutlineSplitter.Visible := FOutlinePanel.Visible;
  if FOutlinePanel.Visible then
  begin
    FScroll.SendToBack;
    FOutlinePanel.BringToFront;
    FOutlineSplitter.BringToFront;
    FOutlineSplitter.Left := FOutlinePanel.Left + FOutlinePanel.Width;
    ThumbAreaResize(nil);
  end;
end;

procedure TFreePDF64PDFiumView.ShowOutlineTab(AThumbnails: Boolean);
begin
  FThumbScroll.Visible := AThumbnails;
  FOutlineTree.Visible := not AThumbnails;
  if AThumbnails then FThumbScroll.BringToFront
  else FOutlineTree.BringToFront;
end;

procedure TFreePDF64PDFiumView.OutlineTabClick(Sender: TObject);
begin
  ShowOutlineTab(TButton(Sender).Tag = 1);
end;

procedure TFreePDF64PDFiumView.ThumbClick(Sender: TObject);
var
  Index, I, A, B: Integer;
  Ctrl, ShiftDown: Boolean;
begin
  if not (Sender is TControl) then Exit;
  Index := TControl(Sender).Tag;
  Ctrl := GetKeyState(VK_CONTROL) < 0;
  ShiftDown := GetKeyState(VK_SHIFT) < 0;
  if not Ctrl and not ShiftDown then FThumbSelected.Clear;
  if ShiftDown and (FThumbAnchor >= 0) then
  begin
    A := Min(FThumbAnchor, Index);
    B := Max(FThumbAnchor, Index);
    for I := A to B do
      if FThumbSelected.IndexOf(I) < 0 then FThumbSelected.Add(I);
  end
  else if Ctrl and (FThumbSelected.IndexOf(Index) >= 0) then
    FThumbSelected.Remove(Index)
  else if FThumbSelected.IndexOf(Index) < 0 then
    FThumbSelected.Add(Index);
  if not ShiftDown then FThumbAnchor := Index;
  UpdateThumbnailSelection;
  ShowPage(Index);
end;

procedure TFreePDF64PDFiumView.ThumbMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Index: Integer;
begin
  if (Button <> mbRight) or not (Sender is TControl) then Exit;
  Index := TControl(Sender).Tag;
  if FThumbSelected.IndexOf(Index) < 0 then
  begin
    FThumbSelected.Clear;
    FThumbSelected.Add(Index);
    FThumbAnchor := Index;
  end;
  UpdateThumbnailSelection;
end;

procedure TFreePDF64PDFiumView.UpdateSaveState;
  procedure SetButtonState(B: TButton);
  begin
    if B = nil then Exit;
    TPDFiumSaveButton(B).ParentBackground := False;
    if FCore.Modified then
    begin
      TPDFiumSaveButton(B).Color := RGB(255, 175, 65);
      B.Hint := 'Änderungen nicht gespeichert – Speichern unter erforderlich';
    end
    else
    begin
      TPDFiumSaveButton(B).Color := clBtnFace;
      B.Hint := 'PDF-Kopie unter neuem Namen speichern';
    end;
    B.ShowHint := True;
  end;
begin
  SetButtonState(FSave);
  SetButtonState(FQuickSave);
  if FUndoMenuItem <> nil then FUndoMenuItem.Enabled := FCore.CanUndo;
end;

procedure TFreePDF64PDFiumView.ThumbMenuPopup(Sender: TObject);
begin
  if FUndoMenuItem <> nil then
    FUndoMenuItem.Enabled := FCore.CanUndo;
end;

procedure TFreePDF64PDFiumView.UndoClick(Sender: TObject);
var
  Target: Integer;
begin
  if not FCore.CanUndo then Exit;
  Target := FPage;
  try
    FThumbTimer.Enabled := False;
    FCore.UndoLast;
    FPage := Max(0, Min(Target, FCore.PageCount - 1));
    PaintPage;
    PopulateOutline;
    BuildThumbnails;
    UpdateSaveState;
  except
    on E: Exception do MessageDlg('Rückgängig fehlgeschlagen: ' + E.Message,
      mtError, [mbOK], 0);
  end;
end;

procedure TFreePDF64PDFiumView.RotateSelectedThumbs(Sender: TObject);
var
  Pages: TArray<Integer>;
  I: Integer;
begin
  if FThumbSelected.Count = 0 then Exit;
  Pages := FThumbSelected.ToArray;
  try
    FThumbTimer.Enabled := False;
    FCore.BeginUndo;
    for I := 0 to High(Pages) do
      FCore.RotateInMemory(Pages[I] + 1, Pages[I] + 1, 90);
    PaintPage;
    PopulateOutline;
    BuildThumbnails;
    UpdateSaveState;
  except
    on E: Exception do MessageDlg('Drehen fehlgeschlagen: ' + E.Message,
      mtError, [mbOK], 0);
  end;
end;

procedure TFreePDF64PDFiumView.DeleteSelectedThumbs(Sender: TObject);
var
  Pages: TArray<Integer>;
  I, Target: Integer;
begin
  if FThumbSelected.Count = 0 then Exit;
  if FThumbSelected.Count >= FCore.PageCount then
  begin
    MessageDlg('Mindestens eine Seite muss erhalten bleiben.', mtWarning, [mbOK], 0);
    Exit;
  end;
  if MessageDlg(Format('%d ausgewählte PDF-Seite(n) entfernen?'+sLineBreak+
     'Das Original bleibt unverändert. Dauerhaft wird die Änderung erst mit "Speichern unter ...".',
     [FThumbSelected.Count]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  Pages := FThumbSelected.ToArray;
  Target := FPage;
  for I := 0 to High(Pages) do
    if Pages[I] <= Target then Dec(Target);
  FThumbTimer.Enabled := False;
  try
    FCore.BeginUndo;
    FCore.DeletePages(Pages);
    FThumbSelected.Clear;
    FThumbAnchor := -1;
    FPage := Max(0, Min(FCore.PageCount - 1, Target));
    FSelecting := False;
    FSelAnchorPage := -1;
    FSelFocusPage := -1;
    FSearchTimer.Enabled := False;
    FSearchRunning := False;
    SetLength(FSearchMatches, 0);
    FFindTerm := '';
    FMatchPage := -1;
    FMatchChar := -1;
    FMatchCount := 0;
    FTotalSearchMatches := 0;
    if Assigned(FOnSearchCountChanged) then FOnSearchCountChanged(Self);
    PaintPage;
    PopulateOutline;
    BuildThumbnails;
    UpdateSaveState;
  except
    on E: Exception do
      MessageDlg('Seiten konnten nicht entfernt werden: ' + E.Message,
        mtError, [mbOK], 0);
  end;
end;

procedure TFreePDF64PDFiumView.ThumbAreaResize(Sender: TObject);
var
  I, LeftX: Integer;
  Img: TImage;
  Lab: TLabel;
begin
  if (FThumbScroll = nil) or (FThumbImages = nil) then Exit;
  LeftX := (FThumbScroll.ClientWidth - 190 - 18) div 2;
  if LeftX < 8 then LeftX := 8;
  for I := 0 to FThumbScroll.ControlCount - 1 do
  begin
    if FThumbScroll.Controls[I] is TShape then
    begin
      TShape(FThumbScroll.Controls[I]).Left := LeftX - 4;
    end
    else if FThumbScroll.Controls[I] is TImage then
    begin
      Img := TImage(FThumbScroll.Controls[I]);
      Img.Left := LeftX;
    end
    else if FThumbScroll.Controls[I] is TLabel then
    begin
      Lab := TLabel(FThumbScroll.Controls[I]);
      Lab.Left := LeftX + 85;
    end;
  end;
end;

procedure TFreePDF64PDFiumView.BuildThumbnails;
var
  I, Y, H: Integer;
  Border: TShape;
  Img: TImage;
  Lab: TLabel;
  W, PH: Single;
begin
  FThumbTimer.Enabled := False;
  FThumbSelected.Clear;
  FThumbAnchor := -1;
  FThumbImages.Clear;
  while FThumbScroll.ControlCount > 0 do
    FThumbScroll.Controls[0].Free;
  Y := 12;
  for I := 0 to FCore.PageCount - 1 do
  begin
    H := 155;
    if FCore.PageSize(I, W, PH) and (W > 0) and (PH > 0) then
      H := Round(190 * PH / W);
    if H < 70 then H := 70;
    if H > 240 then H := 240;
    Border := TShape.Create(FThumbScroll);
    Border.Parent := FThumbScroll;
    Border.SetBounds(4, Y - 4, 198, H + 8);
    Border.Shape := stRectangle;
    Border.Brush.Style := bsClear;
    Border.Pen.Width := 3;
    Border.Pen.Color := clWhite;
    Border.Tag := I;
    Img := TImage.Create(FThumbScroll);
    Img.Parent := FThumbScroll;
    Img.SetBounds(8, Y, 190, H);
    Img.Stretch := True;
    Img.Proportional := True;
    Img.Center := True;
    Img.Tag := I;
    Img.OnClick := ThumbClick;
    Img.OnMouseDown := ThumbMouseDown;
    Img.PopupMenu := FThumbMenu;
    FThumbImages.Add(Img);
    Inc(Y, H + 5);
    Lab := TLabel.Create(FThumbScroll);
    Lab.Parent := FThumbScroll;
    Lab.Caption := IntToStr(I + 1);
    Lab.SetBounds(93, Y, 70, 18);
    Lab.Tag := I;
    Lab.OnClick := ThumbClick;
    Lab.OnMouseDown := ThumbMouseDown;
    Lab.PopupMenu := FThumbMenu;
    Inc(Y, 29);
  end;
  ThumbAreaResize(nil);
  UpdateThumbnailSelection;
  FThumbNext := 0;
  FThumbTimer.Interval := 120;
  FThumbTimer.Enabled := FThumbImages.Count > 0;
end;

procedure TFreePDF64PDFiumView.UpdateThumbnailSelection;
var
  I: Integer;
  Border: TShape;
begin
  if FThumbScroll = nil then Exit;
  for I := 0 to FThumbScroll.ControlCount - 1 do
    if FThumbScroll.Controls[I] is TShape then
    begin
      Border := TShape(FThumbScroll.Controls[I]);
      if FThumbSelected.IndexOf(Border.Tag) >= 0 then
        Border.Pen.Color := clRed
      else if Border.Tag = FPage then
        Border.Pen.Color := clHighlight
      else
        Border.Pen.Color := clWhite;
    end;
end;

procedure TFreePDF64PDFiumView.ThumbTimerTick(Sender: TObject);
var
  Img: TImage;
  Bmp: TBitmap;
  I, TopY, BottomY: Integer;
  Pt: TPoint;
begin
  if (FThumbScroll = nil) or not FThumbScroll.Visible then Exit;
  // Nur Miniaturen im sichtbaren Bereich rendern, statt 800 Seiten
  // unnoetig im Hintergrund zu erzeugen.
  for I := 0 to FThumbImages.Count - 1 do
  begin
    Img := TImage(FThumbImages[I]);
    if not Img.Picture.Bitmap.Empty then Continue;
    Pt := FThumbScroll.ScreenToClient(Img.ClientToScreen(Point(0, 0)));
    TopY := Pt.Y;
    BottomY := TopY + Img.Height;
    if (BottomY < -200) or (TopY > FThumbScroll.ClientHeight + 200) then
      Continue;
    Bmp := TBitmap.Create;
    try
      FCore.RenderPage(Img.Tag, Bmp, Img.Width, Img.Height);
      Img.Picture.Bitmap.Assign(Bmp);
    finally Bmp.Free; end;
    Break; // Eine Miniatur je Tick, damit die VCL reagiert.
  end;
end;

procedure TFreePDF64PDFiumView.OutlineChange(Sender: TObject; Node: TTreeNode);
var
  Item: TPDFBookmarkItem;
begin
  if Node = nil then Exit;
  Item := TPDFBookmarkItem(Node.Data);
  if (Item <> nil) and (Item.PageIndex >= 0) and
     (Item.PageIndex < FCore.PageCount) then
    ShowPage(Item.PageIndex);
end;

procedure TFreePDF64PDFiumView.PopulateOutline;
  procedure AddNodes(AParent: TTreeNode; AList: TObjectList<TPDFBookmarkItem>);
  var
    I: Integer;
    Node: TTreeNode;
  begin
    for I := 0 to AList.Count - 1 do
    begin
      Node := FOutlineTree.Items.AddChildObject(AParent, AList[I].Title, AList[I]);
      AddNodes(Node, AList[I].Children);
    end;
  end;
begin
  FOutlineTree.Items.BeginUpdate;
  try
    FOutlineTree.Items.Clear;
    FOutlineItems.Clear;
    FCore.ReadBookmarks(FOutlineItems);
    if FOutlineItems.Count = 0 then
      FOutlineTree.Items.Add(nil, 'Keine PDF-Lesezeichen vorhanden')
    else
      AddNodes(nil, FOutlineItems);
  finally
    FOutlineTree.Items.EndUpdate;
  end;
end;

procedure TFreePDF64PDFiumView.UpdateSecurityIcon;
begin
  if FInfo = nil then Exit;
  if (FCore <> nil) and (FCore.PageCount > 0) and
     (FCore.SecurityRevision >= 0) then
  begin
    FInfo.Caption := '🔒';
    FInfo.Hint := 'Verschlüsseltes PDF – Dokumenteigenschaften anzeigen';
  end
  else
  begin
    FInfo.Caption := 'ⓘ';
    FInfo.Hint := 'Dokumenteigenschaften anzeigen';
  end;
end;

procedure TFreePDF64PDFiumView.ToggleEditBar(Sender: TObject);
begin
  FEditVisible := not FEditVisible;
  FMarkMode := FEditVisible;
  FEditBar.Visible := FEditVisible;
  if FEditVisible then FEditBar.Height := 36
  else FEditBar.Height := 0;
  if FEditVisible then FEditToggle.Caption := 'Bearbeiten ▲'
  else FEditToggle.Caption := 'Bearbeiten ▼';
  LayoutToolbar(nil);
end;

procedure TFreePDF64PDFiumView.HelpClick(Sender: TObject);
var
  Dlg: TForm;
begin
  Dlg := CreateMessageDialog(
    'Hilfe zum FreePDF64-Viewer' + sLineBreak + sLineBreak +
    'NAVIGATION' + sLineBreak +
    'Inhaltsverzeichnis: Lesezeichen und Seitenminiaturen einblenden.' + sLineBreak +
    'Zurück / Weiter: Zur vorherigen oder nächsten PDF-Seite.' + sLineBreak +
    'Seitenzahl / Gehe zu: Direkt zu einer Seite springen.' + sLineBreak + sLineBreak +
    'ZOOM UND ANSICHT' + sLineBreak +
    '- / +: Ansicht verkleinern oder vergrößern.' + sLineBreak +
    'Seite einpassen: Die PDF-Seite in den Anzeigebereich einpassen.' + sLineBreak +
    'Ansichtsauswahl: Seitenbreite, ganze Seite, 100 % oder frei.' + sLineBreak +
    '1 Seite / 2 Seiten: Einzel- oder Doppelseitenansicht.' + sLineBreak +
    'Durchgehend / Seitenweise: Scrollen oder seitenweise blättern.' + sLineBreak + sLineBreak +
    'SUCHE UND TEXT' + sLineBreak +
    'Text suchen / Strg+F: Begriff im PDF suchen.' + sLineBreak +
    'F3 / Umschalt+F3: Nächster / vorheriger Treffer.' + sLineBreak +
    'Ohne Bearbeitungsmodus: Text mit der Maus auswählen.' + sLineBreak +
    'Strg+C: Ausgewählten Text kopieren.' + sLineBreak +
    'Strg+A: Gesamten PDF-Text auswählen.' + sLineBreak + sLineBreak +
    'BEARBEITEN' + sLineBreak +
    'Bearbeiten: Zeichenwerkzeuge ein- oder ausblenden.' + sLineBreak +
    'Freihand, Linie, Rechteck oder Ellipse auswählen.' + sLineBreak +
    'Strichstärke und Farbe festlegen; mit der Maus zeichnen.' + sLineBreak + sLineBreak +
    'DOKUMENT UND DATEI' + sLineBreak +
    'Anlagen: Eingebettete Dateien anzeigen.' + sLineBreak +
    'Drehen: PDF-Seiten drehen.' + sLineBreak +
    'Dokumentinfo (i/Schloss): Eigenschaften und Sicherheit.' + sLineBreak +
    'Seitenminiaturen: Rechtsklick zum Löschen ausgewählter Seiten.' + sLineBreak +
    'Strg-Klick / Umschalt-Klick: Mehrere Seiten auswählen.' + sLineBreak +
    'Gelöschte Seiten werden erst mit Speichern unter dauerhaft entfernt.' + sLineBreak +
    'Speichern unter: PDF als neue Datei speichern.' + sLineBreak +
    'Drucken: PDF ausdrucken.' + sLineBreak + sLineBreak +
    'TASTATUR' + sLineBreak +
    'Strg+Umschalt+A: Registerkartensuche.' + sLineBreak +
    'F11: Vollbildmodus ein- oder ausschalten.' + sLineBreak +
    'ESC im Vollbild: Zur normalen Fensteransicht zurückkehren.' + sLineBreak +
    'ESC sonst: Anlagenfenster oder aktiven PDF-Tab schließen.',
    mtInformation, [mbOK]);
  try
    Dlg.Caption := 'FreePDF64-Viewer - Hilfe';
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

procedure TFreePDF64PDFiumView.LayoutToolbar(Sender: TObject);
var
  X, Y, W, H, ButtonH, EditH, Gap, Margin, RowGap, RowH: Integer;
  EditButtonW: Integer;
  MeasureBitmap: TBitmap;
  function Px(AValue: Integer): Integer;
  begin
    Result := MulDiv(AValue, CurrentPPI, 96);
  end;
  procedure NextRow;
  begin
    X := Margin;
    Inc(Y, RowH + RowGap);
  end;
  procedure EnsureRoom(AWidth: Integer);
  begin
    if (X > Margin) and (X + AWidth > W - Margin) then
      NextRow;
  end;
  procedure PlaceControl(AControl: TControl; AWidth: Integer;
    AHeight: Integer);
  begin
    EnsureRoom(AWidth);
    AControl.SetBounds(X, Y + (RowH - AHeight) div 2, AWidth, AHeight);
    AControl.Visible := True;
    Inc(X, AWidth + Gap);
  end;
  procedure PlaceButton(AButton: TButton; AWidth: Integer);
  begin
    PlaceControl(AButton, Px(AWidth), ButtonH);
  end;
  procedure PlaceGroup(AGroupWidth: Integer);
  begin
    EnsureRoom(AGroupWidth);
  end;
begin
  if (FBar = nil) or (FInfo = nil) or (FEditBar = nil) then Exit;
  W := FBar.ClientWidth;
  if W < 1 then Exit;

  // Native Combobox-Hoehe beibehalten, damit High-DPI/VCL-Themes stimmen.
  ButtonH := Max(FFlowSelect.Height, Px(24));
  EditH := ButtonH;
  RowH := Max(ButtonH, EditH);
  Gap := Px(7);
  RowGap := Px(6);
  Margin := Px(8);
  X := Margin;
  Y := Px(5);

  MeasureBitmap := TBitmap.Create;
  try
    MeasureBitmap.Canvas.Font.Assign(FEditToggle.Font);
    EditButtonW := Max(Px(110),
      MeasureBitmap.Canvas.TextWidth('Bearbeiten ▼') + Px(30));
  finally
    MeasureBitmap.Free;
  end;

  // Gruppen moeglichst zusammenhalten, bei sehr schmalem Fenster
  // einzelne Controls dennoch umbrechen lassen.
  PlaceGroup(Px(36 + 60 + 60) + 3 * Gap);
  PlaceButton(FOutlineButton, 36);
  PlaceButton(FPrev, 60);
  PlaceButton(FNext, 60);
  PlaceGroup(Px(145 + 44 + 72) + 3 * Gap);
  PlaceControl(FStatus, Px(145), Px(22));
  PlaceControl(FPageEdit, Px(44), EditH);
  PlaceButton(FGoPage, 72);
  PlaceGroup(Px(32 + 32 + 50 + 116) + 4 * Gap);
  PlaceButton(FMinus, 32);
  PlaceButton(FPlus, 32);
  PlaceControl(FZoomStatus, Px(50), Px(22));
  PlaceButton(FFit, 116);
  PlaceGroup(Px(156 + 82 + 122) + 3 * Gap);
  PlaceControl(FViewSelect, Px(156), EditH);
  PlaceButton(FTwoPageButton, 82);
  PlaceControl(FFlowSelect, Px(122), EditH);
  if FEditToggle.Parent = FBar then
    PlaceControl(FEditToggle, EditButtonW, ButtonH);
  PlaceGroup(Px(34 + 135 + 86 + 34) + 4 * Gap);
  PlaceButton(FInfo, 34);
  PlaceButton(FQuickSave, 135);
  PlaceButton(FPrint, 86);
  PlaceButton(FHelp, 34);

  // Panelhoehe erst nach der Anordnung bestimmen. Dadurch wird beim
  // Verkleinern eine weitere Zeile frei, beim Vergroessern wieder entfernt.
  H := Y + RowH + Px(5);
  if FBar.Height <> H then FBar.Height := H;

  // Bestehende Bearbeitungsleiste unveraendert belassen.
  if FEditBar.Visible then
  begin
    H := RowH + Px(10);
    if FEditBar.Height <> H then FEditBar.Height := H;
    X := Margin;
    Y := Px(5);
    PlaceControl(FShapeSelect, Px(116), EditH);
    PlaceControl(FWidthSelect, Px(84), EditH);
    PlaceButton(FColorButton, 108);
    PlaceControl(FColorSwatch, Px(22), Px(20));
    PlaceButton(FSave, 153);
    H := Y + RowH + Px(5);
    if FEditBar.Height <> H then FEditBar.Height := H;
  end;
end;

function DetectPDFEncryptionQPDF(const APDFFile: string): string;
var
  ExePath, TempPath, Cmd, Output, Line, Method: string;
  Startup: TStartupInfo;
  ProcInfo: TProcessInformation;
  OutHandle: THandle;
  Lines: TStringList;
  I, Bits: Integer;
  R: DWORD;
  Buffer: array[0..MAX_PATH] of Char;
begin
  Result := 'Nicht verfügbar';
  ExePath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'qpdf\bin\qpdf.exe';
  if not FileExists(ExePath) then Exit;
  if GetTempPath(MAX_PATH, Buffer) = 0 then Exit;
  TempPath := IncludeTrailingPathDelimiter(string(Buffer)) +
    'FreePDF64_qpdf_' + IntToStr(GetCurrentProcessId) + '_' +
    IntToStr(GetTickCount) + '.txt';
  OutHandle := CreateFile(PChar(TempPath), GENERIC_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE, nil, CREATE_ALWAYS,
    FILE_ATTRIBUTE_TEMPORARY, 0);
  if OutHandle = INVALID_HANDLE_VALUE then Exit;
  try
    FillChar(Startup, SizeOf(Startup), 0);
    Startup.cb := SizeOf(Startup);
    Startup.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    Startup.wShowWindow := SW_HIDE;
    Startup.hStdOutput := OutHandle;
    Startup.hStdError := OutHandle;
    Startup.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
    FillChar(ProcInfo, SizeOf(ProcInfo), 0);
    Cmd := '"' + ExePath + '" --show-encryption --password= "' + APDFFile + '"';
    if not CreateProcess(nil, PChar(Cmd), nil, nil, True,
      CREATE_NO_WINDOW, nil, nil, Startup, ProcInfo) then Exit;
    try
      R := WaitForSingleObject(ProcInfo.hProcess, 5000);
      if R = WAIT_TIMEOUT then TerminateProcess(ProcInfo.hProcess, 1);
    finally
      CloseHandle(ProcInfo.hThread);
      CloseHandle(ProcInfo.hProcess);
    end;
  finally
    CloseHandle(OutHandle);
  end;
  Lines := TStringList.Create;
  try
    if not FileExists(TempPath) then Exit;
    Lines.LoadFromFile(TempPath);
    Bits := 0;
    Method := '';
    for I := 0 to Lines.Count - 1 do
    begin
      Line := LowerCase(Trim(Lines[I]));
      // QPDF gibt beispielsweise "encryption key length = 128" aus.
      // Sowohl '=' als auch ':' sind erlaubt.
      if (Pos('encryption key length', Line) > 0) or
         (Pos('key length', Line) > 0) then
      begin
        if Pos('=', Line) > 0 then
          Line := Trim(Copy(Line, Pos('=', Line) + 1, MaxInt))
        else if Pos(':', Line) > 0 then
          Line := Trim(Copy(Line, Pos(':', Line) + 1, MaxInt))
        else
          Line := '';
        // Ziffern am Anfang extrahieren, z.B. "128 bits".
        while (Length(Line) > 0) and (Line[1] in ['0'..'9']) do
        begin
          Bits := Bits * 10 + Ord(Line[1]) - Ord('0');
          Delete(Line, 1, 1);
        end;
        Continue;
      end;
      // Bei PDF-Verschluesselung sind Stream- und String-Verfahren
      // ausschlaggebend. "AESv2" bedeutet AES-128, "AESv3" AES-256.
      if (Pos('aesv3', Line) > 0) or (Pos('aes-256', Line) > 0) then Method := 'AES-256'
      else if ((Pos('aesv2', Line) > 0) or (Pos('aes-128', Line) > 0)) and (Method <> 'AES-256') then
        Method := 'AES-128'
      else if (Pos('rc4', Line) > 0) and (Method = '') then
        Method := 'RC4';
    end;
    if Method = 'AES-256' then Result := 'AES-256 (256 Bit)'
    else if Method = 'AES-128' then Result := 'AES-128 (128 Bit)'
    else if (Method = 'RC4') and (Bits = 128) then Result := 'RC4-128 (128 Bit)'
    else if (Method = 'RC4') and (Bits = 40) then Result := 'RC4-40 (40 Bit)'
    else if Bits in [40, 128] then Result := IntToStr(Bits) + ' Bit (Verfahren unbekannt)'
    else if Bits = 256 then Result := '256 Bit (Verfahren unbekannt)';
  finally
    Lines.Free;
    DeleteFile(TempPath);
  end;
end;

procedure TFreePDF64PDFiumView.InfoClick(Sender: TObject);
var
  EncryptionText: string;
  Dlg: TForm;
  Header, SectionTitle, Lab, Val: TLabel;
  CloseBtn: TButton;
  Stream: TFileStream;
  Bytes: Int64;
  RowY, RowStep, FieldHeight, DialogW, DialogH: Integer;
  PW, PH: Single;
  PageSizeText, VersionText, FilePath, OrientationText: string;
  PDFWindow: TCustomForm;
  function P(N: Integer): Integer;
  begin
    Result := MulDiv(N, Screen.PixelsPerInch, 96);
  end;
  function DisplayValue(const S: string): string;
  begin
    Result := Trim(S);
    if Result = '' then Result := 'Nicht verfügbar';
  end;
  function PDFDate(const S: string): string;
  var T: string;
  begin
    Result := DisplayValue(S);
    T := S;
    if Copy(T, 1, 2) = 'D:' then Delete(T, 1, 2);
    if Length(T) >= 14 then
      Result := Copy(T, 7, 2) + '.' + Copy(T, 5, 2) + '.' +
        Copy(T, 1, 4) + ', ' + Copy(T, 9, 2) + ':' +
        Copy(T, 11, 2) + ':' + Copy(T, 13, 2);
  end;
  procedure AddSection(const ACaption: string);
  var Sep: TBevel;
  begin
    if RowY > P(100) then
    begin
      Sep := TBevel.Create(Dlg);
      Sep.Parent := Dlg;
      Sep.Shape := bsTopLine;
      Sep.SetBounds(P(26), RowY + P(3), P(430), P(2));
      Inc(RowY, P(15));
    end;
    SectionTitle := TLabel.Create(Dlg);
    SectionTitle.Parent := Dlg;
    SectionTitle.Caption := ACaption;
    SectionTitle.Font.Style := [fsBold];
    SectionTitle.SetBounds(P(26), RowY, P(420), FieldHeight);
    Inc(RowY, RowStep + P(2));
  end;
  procedure AddField(const ACaption, AValue: string);
  begin
    Lab := TLabel.Create(Dlg);
    Lab.Parent := Dlg;
    Lab.Caption := ACaption;
    Lab.AutoSize := False;
    Lab.SetBounds(P(26), RowY, P(150), FieldHeight);
    Val := TLabel.Create(Dlg);
    Val.Parent := Dlg;
    Val.AutoSize := False;
    Val.EllipsisPosition := epEndEllipsis;
    Val.Caption := DisplayValue(AValue);
    Val.Hint := AValue;
    Val.ShowHint := True;
    Val.SetBounds(P(180), RowY, P(275), FieldHeight);
    Inc(RowY, RowStep);
  end;
begin
  if FCore.PageCount <= 0 then Exit;
  FilePath := FCore.FileName;
  Bytes := 0;
  if FileExists(FilePath) then
  begin
    Stream := TFileStream.Create(FilePath, fmOpenRead or fmShareDenyNone);
    try Bytes := Stream.Size; finally Stream.Free; end;
  end;
  PageSizeText := 'Nicht verfügbar';
  if FCore.PageSize(0, PW, PH) then
  begin
    if PW > PH then OrientationText := 'Querformat'
    else OrientationText := 'Hochformat';
    PageSizeText := Format('%d × %d mm (%s)',
      [Round(PW * 25.4 / 72), Round(PH * 25.4 / 72),
       OrientationText]);
  end;
  VersionText := FCore.PDFVersion;

  // Den Dialog dem tatsaechlichen PDF-Fenster zuordnen,
  // nicht dem Application.MainForm von FreePDF64.
  PDFWindow := GetParentForm(Self);
  if PDFWindow = nil then Exit;
  Dlg := TForm.CreateNew(PDFWindow);
  try
    Dlg.PopupMode := pmExplicit;
    Dlg.PopupParent := PDFWindow;
    Dlg.Caption := 'Dokumenteigenschaften';
    Dlg.BorderStyle := bsDialog;
    Dlg.Position := poDesigned;
    DialogW := P(485);
    DialogH := P(920);
    Dlg.Left := PDFWindow.Left + (PDFWindow.Width - DialogW) div 2;
    Dlg.Top := PDFWindow.Top + (PDFWindow.Height - DialogH) div 2;
    if Dlg.Left < Screen.WorkAreaLeft then Dlg.Left := Screen.WorkAreaLeft;
    if Dlg.Top < Screen.WorkAreaTop then Dlg.Top := Screen.WorkAreaTop;
    Dlg.ClientWidth := DialogW;
    Dlg.ClientHeight := DialogH;
    Dlg.Font.Name := 'Segoe UI';
    Dlg.Font.Size := 9;
    // Die Schrift ist bereits durch VCL/Windows DPI-skaliert.
    // Keine zweite DPI-Multiplikation auf die Zeilenhoehe anwenden.
    FieldHeight := Dlg.Canvas.TextHeight('Ag') + 4;
    RowStep := FieldHeight + 5;
    Header := TLabel.Create(Dlg);
    Header.Parent := Dlg;
    Header.Caption := 'Dokumenteigenschaften';
    Header.Font.Size := 16;
    Header.SetBounds(P(26), P(22), P(430), P(36));
    RowY := P(85);
    AddSection('Beschreibung');
    AddField('Dateiname:', ExtractFileName(FilePath));
    AddField('Dateigröße:', FormatFloat('#,##0', Bytes / 1024) + ' KB');
    AddField('Titel:', FCore.MetaText('Title'));
    AddField('Autor:', FCore.MetaText('Author'));
    AddField('Antragsteller:', FCore.MetaText('Subject'));
    AddField('Schlüsselwörter:', FCore.MetaText('Keywords'));
    AddField('Erstellt am:', PDFDate(FCore.MetaText('CreationDate')));
    AddField('Geändert am:', PDFDate(FCore.MetaText('ModDate')));
    AddField('Ersteller:', FCore.MetaText('Creator'));
    AddSection('Erweitert');
    AddField('PDF-Produzent:', FCore.MetaText('Producer'));
    AddField('PDF-Version:', VersionText);
    AddField('Standort:', ExtractFilePath(FilePath));
    AddField('Anzahl der Seiten:', IntToStr(FCore.PageCount));
    AddField('Seitengröße:', PageSizeText);
    AddField('Schnelle Webansicht:', 'Nicht verfügbar');
    AddSection('Sicherheit');
    if FCore.SecurityRevision < 0 then
    begin
      AddField('Verschlüsselt:', 'Nein');
      AddField('Verschlüsselung:', 'Keine');
    end
    else
    begin
      AddField('Verschlüsselt:', 'Ja');
      EncryptionText := DetectPDFEncryptionQPDF(FilePath);
      if EncryptionText = 'Nicht verfügbar' then
      begin
        // PDFium kennt die Sicherheitsrevision. Sie bestimmt die
        // Schluessellaenge, aber nicht immer den konkreten Algorithmus.
        case FCore.SecurityRevision of
          2: EncryptionText := '40 Bit (PDF-Sicherheitsrevision 2)';
          3, 4: EncryptionText := '128 Bit (PDF-Sicherheitsrevision ' +
            IntToStr(FCore.SecurityRevision) + ')';
          5, 6: EncryptionText := '256 Bit (PDF-Sicherheitsrevision ' +
            IntToStr(FCore.SecurityRevision) + ')';
        end;
      end;
      AddField('Verschlüsselung:', EncryptionText);
      if (FCore.SecurityPermissions and UInt64(4)) <> 0 then
        AddField('Drucken erlaubt:', 'Ja')
      else
        AddField('Drucken erlaubt:', 'Nein');
      if (FCore.SecurityPermissions and UInt64(16)) <> 0 then
        AddField('Kopieren erlaubt:', 'Ja')
      else
        AddField('Kopieren erlaubt:', 'Nein');
      if (FCore.SecurityPermissions and UInt64(8)) <> 0 then
        AddField('Ändern erlaubt:', 'Ja')
      else
        AddField('Ändern erlaubt:', 'Nein');
    end;
    CloseBtn := TButton.Create(Dlg);
    CloseBtn.Parent := Dlg;
    CloseBtn.Caption := 'Schließen';
    CloseBtn.ModalResult := mrCancel;
    CloseBtn.Default := True;
    CloseBtn.Cancel := True;  // ESC schliesst den modalen Dialog
    CloseBtn.SetBounds(P(260), RowY + P(15), P(195), P(35));
    // Keine feste Mindesthoehe: der Dialog endet knapp unter dem Schliessen-Button.
    Dlg.ClientHeight := CloseBtn.Top + CloseBtn.Height + P(16);
    // Nach der endgueltigen Groessenberechnung erneut am PDF-Fenster ausrichten.
    Dlg.Left := PDFWindow.Left + (PDFWindow.Width - Dlg.Width) div 2;
    Dlg.Top := PDFWindow.Top + (PDFWindow.Height - Dlg.Height) div 2;
    if Dlg.Left < Screen.WorkAreaLeft then Dlg.Left := Screen.WorkAreaLeft;
    if Dlg.Top < Screen.WorkAreaTop then Dlg.Top := Screen.WorkAreaTop;
    Dlg.ShowModal;
  finally
    Dlg.Free;
  end;
end;

procedure TFreePDF64PDFiumView.ResizeView(Sender: TObject);
begin
  if FFitMode and not FRendering and (FCore.PageCount > 0) then PaintPage;
end;

function TFreePDF64PDFiumView.PageImage(AIndex: Integer): TPDFiumImage;
begin
  Result := nil;
  if (AIndex >= 0) and (AIndex < FPages.Count) then
    Result := TPDFiumImage(FPages[AIndex]);
end;

procedure TFreePDF64PDFiumView.UpdateVisiblePage;
var I, Y, Best, Dist, D: Integer; Img: TPDFiumImage;
begin
  if FRendering or (FCore.PageCount = 0) then Exit;
  Y := FScroll.ClientHeight div 3;
  Best := FPage;
  Dist := MaxInt;
  if not FContinuous then
  begin
    FPageEdit.Text := IntToStr(FPage + 1);
    FPrev.Enabled := FPage > 0;
    FNext.Enabled := FPage < FCore.PageCount - 1;
    FStatus.Caption := Format('Seite %d / %d', [FPage + 1, FCore.PageCount]);
    FZoomStatus.Caption := Format('%d%%', [Round(FZoom * 100)]);
    UpdateThumbnailSelection;
    Exit;
  end;
  for I := 0 to FPages.Count - 1 do
  begin
    Img := PageImage(I);
    D := Abs((FScroll.ScreenToClient(Img.ClientToScreen(Point(0, 0))).Y + Img.Height div 2) - Y);
    if D < Dist then begin Dist := D; Best := I; end;
  end;
  FPage := Best;
  FPageEdit.Text := IntToStr(FPage + 1);
  FPrev.Enabled := FPage > 0;
  FNext.Enabled := FPage < FCore.PageCount - 1;
  FStatus.Caption := Format('Seite %d / %d',
    [FPage + 1, FCore.PageCount]);
  FZoomStatus.Caption := Format('%d%%', [Round(FZoom * 100)]);
  UpdateThumbnailSelection;
end;

procedure TFreePDF64PDFiumView.RenderTimerTick(Sender: TObject);
var PositionNow: Integer;
begin
  if FRendering or (FCore.PageCount = 0) then Exit;
  PositionNow := FScroll.VertScrollBar.Position;
  if PositionNow <> FLastScrollPosition then
  begin
    FLastScrollPosition := PositionNow;
    RenderVisiblePages;
    UpdateVisiblePage;
  end;
end;

procedure TFreePDF64PDFiumView.RenderVisiblePages;
var
  I, TopOnScreen, BottomOnScreen, Margin: Integer;
  Img: TPDFiumImage;
  P: TPoint;
begin
  if FRendering or (FCore.PageCount = 0) then Exit;
  FRendering := True;
  try
    Margin := Max(128, FScroll.ClientHeight div 2);
    for I := 0 to FPages.Count - 1 do
    begin
      Img := PageImage(I);
      if (Img = nil) or not Img.Visible then Continue;
      // Tatsächliche Client-Koordinaten statt ScrollBar.Position + Img.Top.
      // Das vermeidet doppelte Scrolloffsets bei VCL-TScrollBox.
      P := FScroll.ScreenToClient(Img.ClientToScreen(Point(0, 0)));
      TopOnScreen := P.Y;
      BottomOnScreen := TopOnScreen + Img.Height;
      if (I = FPage) or ((BottomOnScreen >= -Margin) and
         (TopOnScreen <= FScroll.ClientHeight + Margin)) then
      begin
        if not FLoadedPages[I] then
        begin
          FCore.RenderPage(I, Img.Picture.Bitmap, Img.Width, Img.Height);
          FLoadedPages[I] := True;
          DrawPageStrokes(I);
          DrawSearchHighlight(I);
          DrawTextSelection(I);
          // Die Suchfarbe wird direkt in die Bitmap gezeichnet.
          Img.Invalidate;
        end;
      end
      else if FLoadedPages[I] then
      begin
        Img.Picture.Assign(nil);
        FLoadedPages[I] := False;
      end;
    end;
  finally
    FRendering := False;
  end;
end;

procedure TFreePDF64PDFiumView.LayoutAllPages;
var
  I, W, H, TopY, MaxW, LeftX, PairWidth, PairHeight, GapPages, RowStart, RowEnd, K: Integer;
  PW, PH: Single;
  Img: TPDFiumImage;
  S: Double;
  PairPW, PairPH, MaxPairWidth, MaxPairHeight, QW, QH: Single;
begin
  if FRendering or (FCore.PageCount = 0) then Exit;
  FRendering := True;
  FScroll.DisableAlign;
  try
    for I := FPages.Count - 1 downto 1 do
      TObject(FPages[I]).Free;
    FPages.Clear;
    FPages.Add(FImage);
    FImage.Tag := 0;
    if FFitMode then
    begin
      MaxW := 1;
      for I := 0 to FCore.PageCount - 1 do
        if FCore.PageSize(I, PW, PH) then
          MaxW := Max(MaxW, Ceil(PW));
      if FTwoPage then
      begin
        MaxPairWidth := 1;
        MaxPairHeight := 1;
        I := 0;
        while I < FCore.PageCount do
        begin
          PairPW := 0;
          PairPH := 0;
          for K := I to Min(I + 1, FCore.PageCount - 1) do
            if FCore.PageSize(K, QW, QH) then
            begin
              PairPW := PairPW + QW;
              PairPH := Max(PairPH, QH);
            end;
          MaxPairWidth := Max(MaxPairWidth, PairPW);
          if (FPage >= I) and (FPage <= I + 1) then
            MaxPairHeight := Max(1, PairPH);
          Inc(I, 2);
        end;
        S := (FScroll.ClientWidth - 56) / MaxPairWidth;
        // Bei "Ganze Seite" muss das gesamte Seitenpaar sowohl in der
        // Breite als auch in der Hoehe in den sichtbaren Bereich passen.
        // Vorher wurde die Hoehenbegrenzung bei FTwoPage ausgeschlossen.
        if FViewMode = 1 then
          S := Min(S, (FScroll.ClientHeight - 32) / MaxPairHeight);
      end
      else
        S := (FScroll.ClientWidth - 36) / MaxW;
      if (FViewMode = 1) and not FTwoPage then
      begin
        // Ganze Seite: Hoehe und Breite der aktuellen Seite beachten.
        if FCore.PageSize(FPage, PW, PH) and (PH > 0) then
          S := Min(S, (FScroll.ClientHeight - 32) / PH);
      end;
      FZoom := Max(0.1, Min(5.0, S));
    end;
    SetLength(FLoadedPages, FCore.PageCount);
    TopY := 12;
    PairWidth := 0;
    PairHeight := 0;
    GapPages := 12;
    for I := 0 to FCore.PageCount - 1 do
    begin
      if not FCore.PageSize(I, PW, PH) then
      begin
        PW := 595;
        PH := 842;
      end;
      W := Max(1, Round(PW * FZoom));
      H := Max(1, Round(PH * FZoom));
      if (W > 12000) or (H > 12000) then
        raise EPDFiumViewer.Create('Die gewählte Vergrößerung ist zu groß.');
      if I = 0 then Img := FImage
      else
      begin
        Img := TPDFiumImage.Create(Self);
        Img.Parent := FScroll;
        Img.Stretch := False;
        Img.Proportional := False;
        Img.OnMouseDown := ImageMouseDown;
        Img.OnMouseMove := ImageMouseMove;
        Img.OnMouseUp := ImageMouseUp;
        Img.OnMouseWheel := ScrollMouseWheel;
        FPages.Add(Img);
      end;
      Img.Picture.Assign(nil);
      Img.Tag := I;
      if not FContinuous then
      begin
        // Seitenweise: nur die aktuelle Seite bzw. das aktuelle Paar zeigen.
        RowStart := FPage;
        if FTwoPage then RowStart := (FPage div 2) * 2;
        RowEnd := RowStart;
        if FTwoPage then RowEnd := Min(RowStart + 1, FCore.PageCount - 1);
        Img.Visible := (I >= RowStart) and (I <= RowEnd);
        if Img.Visible then
        begin
          if FTwoPage then
          begin
            PairWidth := W;
            if FCore.PageSize(RowStart, QW, QH) then
              PairWidth := Max(1, Round(QW * FZoom));
            if RowEnd > RowStart then
            begin
              if FCore.PageSize(RowEnd, QW, QH) then
                PairWidth := PairWidth + GapPages + Max(1, Round(QW * FZoom));
            end;
            LeftX := Max(12, (FScroll.ClientWidth - PairWidth) div 2);
            if I = RowEnd then LeftX := LeftX + PairWidth - W;
          end
          else
            LeftX := Max(12, (FScroll.ClientWidth - W) div 2);
          Img.SetBounds(LeftX, 12, W, H);
        end
        else
          Img.SetBounds(0, 0, 1, 1);
      end
      else if FTwoPage then
      begin
        Img.Visible := True;
        // Jede Zeile besteht aus zwei nebeneinander angeordneten PDF-Seiten.
        if (I mod 2) = 0 then
        begin
          PairWidth := W;
          PairHeight := H;
          if I + 1 < FCore.PageCount then
          begin
            if FCore.PageSize(I + 1, QW, QH) then
            begin
              PairWidth := PairWidth + GapPages + Max(1, Round(QW * FZoom));
              PairHeight := Max(PairHeight, Max(1, Round(QH * FZoom)));
            end;
          end;
        end;
        LeftX := Max(12, (FScroll.ClientWidth - PairWidth) div 2);
        if (I mod 2) = 1 then
          LeftX := LeftX + PairWidth - W;
        Img.SetBounds(LeftX, TopY, W, H);
        if (I mod 2 = 1) or (I = FCore.PageCount - 1) then
          TopY := TopY + PairHeight + 16;
      end
      else
      begin
        Img.Visible := True;
        LeftX := Max(12, (FScroll.ClientWidth - W) div 2);
        Img.SetBounds(LeftX, TopY, W, H);
        TopY := TopY + H + 16;
      end;
      FLoadedPages[I] := False;
    end;
  finally
    FScroll.EnableAlign;
    FRendering := False;
  end;
  RenderVisiblePages;
  FLastScrollPosition := FScroll.VertScrollBar.Position;
  UpdateVisiblePage;
end;

procedure TFreePDF64PDFiumView.PaintPage;
var OldPage: Integer;
begin
  OldPage := FPage;
  LayoutAllPages;
  if FContinuous and (OldPage >= 0) and (OldPage < FPages.Count) then
    ShowPage(OldPage);
end;

procedure TFreePDF64PDFiumView.PlaceEditButton(AParent: TWinControl; ALeft, ATop, AHeight: Integer);
var
  MeasureBitmap: TBitmap;
  ButtonWidth: Integer;
begin
  FEditToggle.Parent := AParent;
  MeasureBitmap := TBitmap.Create;
  try
    MeasureBitmap.Canvas.Font.Assign(FEditToggle.Font);
    ButtonWidth := Max(MulDiv(110, FEditToggle.CurrentPPI, 96),
      MeasureBitmap.Canvas.TextWidth('Bearbeiten ▼') +
      MulDiv(30, FEditToggle.CurrentPPI, 96));
  finally
    MeasureBitmap.Free;
  end;
  FEditToggle.SetBounds(ALeft, ATop, ButtonWidth, AHeight);
  FEditToggle.BringToFront;
end;

procedure TFreePDF64PDFiumView.ToggleMarker;
begin
  MarkerClick(nil);
end;

procedure TFreePDF64PDFiumView.MarkerClick(Sender: TObject);
begin
  // Kompatibilitaet fuer vorhandene Aufrufer: Bearbeiten und Markieren sind gekoppelt.
  ToggleEditBar(nil);
end;

procedure TFreePDF64PDFiumView.AppendPoint(X, Y: Integer);
var P: TPDFInkPoint; DX, DY: Double;
begin
  if FCurrentStroke = nil then Exit;
  if not FCore.DevicePointToPage(FStrokePage, PageImage(FStrokePage).Width, PageImage(FStrokePage).Height,
    X, Y, DX, DY) then Exit;
  P.X := DX; P.Y := DY;
  FCurrentStroke.Add(P);
end;

procedure TFreePDF64PDFiumView.BuildEllipseStroke(X1, Y1, X2, Y2: Integer);
var
  I: Integer;
  A, CX, CY, RX, RY: Double;
begin
  CX := (X1 + X2) / 2;
  CY := (Y1 + Y2) / 2;
  RX := Abs(X2 - X1) / 2;
  RY := Abs(Y2 - Y1) / 2;
  for I := 0 to 48 do
  begin
    A := 2 * Pi * I / 48;
    AppendPoint(Round(CX + RX * Cos(A)), Round(CY + RY * Sin(A)));
  end;
end;

procedure TFreePDF64PDFiumView.UpdateShapeStroke(X, Y: Integer);
begin
  if FCurrentStroke = nil then Exit;
  FCurrentStroke.Clear;
  case FShapeSelect.ItemIndex of
    1: begin
         AppendPoint(FShapeStart.X, FShapeStart.Y);
         AppendPoint(X, Y);
       end;
    2: begin
         AppendPoint(FShapeStart.X, FShapeStart.Y);
         AppendPoint(X, FShapeStart.Y);
         AppendPoint(X, Y);
         AppendPoint(FShapeStart.X, Y);
         AppendPoint(FShapeStart.X, FShapeStart.Y);
       end;
    3: BuildEllipseStroke(FShapeStart.X, FShapeStart.Y, X, Y);
  end;
end;

function PDFiumColorDialogHook(hDlg: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): UINT_PTR; stdcall;
var
  DialogChoice: PChooseColor;
  Desired: PPoint;
  R: TRect;
  Work: TRect;
  W, H, X, Y: Integer;
begin
  Result := 0;
  if uMsg <> WM_INITDIALOG then Exit;
  DialogChoice := PChooseColor(lParam);
  if (DialogChoice = nil) or (DialogChoice^.lCustData = 0) then Exit;
  Desired := PPoint(DialogChoice^.lCustData);
  GetWindowRect(hDlg, R);
  W := R.Right - R.Left;
  H := R.Bottom - R.Top;
  // VCL-Monitorermittlung vermeidet SDK-abhängige WinAPI-Deklarationen.
  Work := Screen.MonitorFromPoint(Desired^).WorkareaRect;
  X := Max(Work.Left, Min(Desired^.X, Work.Right - W));
  Y := Desired^.Y;
  if Y + H > Work.Bottom then
    Y := Work.Bottom - H;
  Y := Max(Work.Top, Y);
  SetWindowPos(hDlg, 0, X, Y, 0, 0,
    SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure TFreePDF64PDFiumView.ColorClick(Sender: TObject);
var
  Choice: TChooseColor;
  CustomColors: array[0..15] of COLORREF;
  PDFWindow: TCustomForm;
  I: Integer;
  ButtonOrigin: TPoint;
begin
  // Direkter Windows-Dialog mit dem PDF-Fenster als HWND-Owner.
  // VCL-TColorDialog kann bei mehreren Formularen die Hauptform aktivieren.
  PDFWindow := GetParentForm(Self);
  if PDFWindow = nil then Exit;
  for I := Low(CustomColors) to High(CustomColors) do
    CustomColors[I] := RGB(255, 255, 255);
  ZeroMemory(@Choice, SizeOf(Choice));
  Choice.lStructSize := SizeOf(Choice);
  Choice.hwndOwner := PDFWindow.Handle;
  Choice.rgbResult := ColorToRGB(FMarkColor);
  Choice.lpCustColors := @CustomColors[0];
  // Position unmittelbar unter dem Farbbutton, nicht oben links auf der PDF.
  ButtonOrigin := FColorButton.ClientToScreen(Point(0, FColorButton.Height + 4));
  Choice.lCustData := LPARAM(@ButtonOrigin);
  Choice.lpfnHook := @PDFiumColorDialogHook;
  Choice.Flags := CC_RGBINIT or CC_FULLOPEN or CC_ENABLEHOOK;
  if ChooseColor(Choice) then
  begin
    FMarkColor := TColor(Choice.rgbResult);
    FColorSwatch.Color := FMarkColor;
    FColorSwatch.Invalidate;
  end;
end;

procedure TFreePDF64PDFiumView.DrawLivePreview;
var
  Img: TPDFiumImage;
  B: TBitmap;
  J, PX, PY: Integer;
  P: TPDFInkPoint;
  First: Boolean;
begin
  if (FCurrentStroke = nil) or (FPreviewBitmap = nil) then Exit;
  if (FStrokePage < 0) or (FStrokePage >= FPages.Count) then Exit;
  Img := PageImage(FStrokePage);
  B := Img.Picture.Bitmap;
  B.Assign(FPreviewBitmap);
  B.Canvas.Brush.Style := bsClear;
  B.Canvas.Pen.Color := FCurrentStroke.StrokeColor;
  B.Canvas.Pen.Width := Max(1, Round(FCurrentStroke.LineWidth * FZoom));
  B.Canvas.Pen.Style := psSolid;
  First := True;
  for J := 0 to FCurrentStroke.Count - 1 do
  begin
    P := FCurrentStroke[J];
    if not FCore.PagePointToDevice(FStrokePage, Img.Width, Img.Height,
      P.X, P.Y, PX, PY) then Continue;
    if First then
    begin
      B.Canvas.MoveTo(PX, PY);
      First := False;
    end
    else
      B.Canvas.LineTo(PX, PY);
  end;
  Img.Invalidate;
  Img.Update;
end;

function TFreePDF64PDFiumView.SelectionHit(Sender: TObject; X, Y: Integer): Integer;
var Img: TPDFiumImage; PX, PY: Double;
begin
  Result := -1;
  if not (Sender is TPDFiumImage) then Exit;
  Img := TPDFiumImage(Sender);
  if not FCore.DevicePointToPage(Img.Tag, Img.Width, Img.Height, X, Y, PX, PY) then Exit;
  Result := FCore.TextCharAt(Img.Tag, PX, PY);
end;

procedure TFreePDF64PDFiumView.RefreshSelectedPages;
var I: Integer; Img: TPDFiumImage;
begin
  for I := 0 to FPages.Count - 1 do
  begin
    if (I >= Length(FLoadedPages)) or not FLoadedPages[I] then Continue;
    Img := PageImage(I);
    if Img = nil then Continue;
    FCore.RenderPage(I, Img.Picture.Bitmap, Img.Width, Img.Height);
    DrawPageStrokes(I);
    DrawSearchHighlight(I);
    DrawTextSelection(I);
    Img.Invalidate;
  end;
end;

procedure TFreePDF64PDFiumView.DrawTextSelection(APage: Integer);
var
  A, B, StartChar, EndChar, I, X1, Y1, X2, Y2: Integer;
  Img: TPDFiumImage;
  Boxes: TArray<TPDFInkRect>;
  Box: TPDFInkRect;
  Overlay: TBitmap;
  Blend: TBlendFunction;
begin
  if (FSelAnchorPage < 0) or (FSelFocusPage < 0) then Exit;
  A := Min(FSelAnchorPage, FSelFocusPage);
  B := Max(FSelAnchorPage, FSelFocusPage);
  if (APage < A) or (APage > B) then Exit;
  Img := PageImage(APage);
  if (Img = nil) or Img.Picture.Bitmap.Empty then Exit;
  if FSelAnchorPage = FSelFocusPage then
  begin
    StartChar := Min(FSelAnchorChar, FSelFocusChar);
    EndChar := Max(FSelAnchorChar, FSelFocusChar) + 1;
  end
  else if FSelAnchorPage < FSelFocusPage then
  begin
    if APage = A then StartChar := FSelAnchorChar else StartChar := 0;
    if APage = B then EndChar := FSelFocusChar + 1 else EndChar := FCore.TextCharCount(APage);
  end
  else
  begin
    if APage = A then StartChar := FSelFocusChar else StartChar := 0;
    if APage = B then EndChar := FSelAnchorChar + 1 else EndChar := FCore.TextCharCount(APage);
  end;
  if EndChar <= StartChar then Exit;
  Boxes := FCore.MatchCharRects(APage, StartChar, EndChar - StartChar);
  Overlay := TBitmap.Create;
  try
    Overlay.PixelFormat := pf24bit;
    Overlay.SetSize(1, 1);
    Overlay.Canvas.Pixels[0, 0] := RGB(80, 155, 255);
    FillChar(Blend, SizeOf(Blend), 0);
    Blend.BlendOp := AC_SRC_OVER;
    Blend.SourceConstantAlpha := 100;
    for Box in Boxes do
      if FCore.PagePointToDevice(APage, Img.Width, Img.Height, Box.Left, Box.Top, X1, Y1) and
         FCore.PagePointToDevice(APage, Img.Width, Img.Height, Box.Right, Box.Bottom, X2, Y2) then
        if (X1 <> X2) and (Y1 <> Y2) then
          Winapi.Windows.AlphaBlend(Img.Picture.Bitmap.Canvas.Handle,
            Min(X1, X2), Min(Y1, Y2), Abs(X2-X1), Abs(Y2-Y1),
            Overlay.Canvas.Handle, 0, 0, 1, 1, Blend);
  finally Overlay.Free; end;
end;

procedure TFreePDF64PDFiumView.SelectAllText;
var I: Integer;
begin
  if FCore.PageCount = 0 then Exit;
  FSelAnchorPage := 0;
  FSelAnchorChar := 0;
  FSelFocusPage := FCore.PageCount - 1;
  FSelFocusChar := Max(0, FCore.TextCharCount(FSelFocusPage) - 1);
  RefreshSelectedPages;
end;

procedure TFreePDF64PDFiumView.CopySelectedText;
var A, B, I, StartChar, EndChar: Integer; S, Part: string;
begin
  if (FSelAnchorPage < 0) or (FSelFocusPage < 0) then Exit;
  A := Min(FSelAnchorPage, FSelFocusPage);
  B := Max(FSelAnchorPage, FSelFocusPage);
  S := '';
  for I := A to B do
  begin
    if FSelAnchorPage = FSelFocusPage then
    begin
      StartChar := Min(FSelAnchorChar, FSelFocusChar);
      EndChar := Max(FSelAnchorChar, FSelFocusChar) + 1;
    end
    else if FSelAnchorPage < FSelFocusPage then
    begin
      if I = A then StartChar := FSelAnchorChar else StartChar := 0;
      if I = B then EndChar := FSelFocusChar + 1 else EndChar := FCore.TextCharCount(I);
    end
    else
    begin
      if I = A then StartChar := FSelFocusChar else StartChar := 0;
      if I = B then EndChar := FSelAnchorChar + 1 else EndChar := FCore.TextCharCount(I);
    end;
    Part := FCore.TextRange(I, StartChar, EndChar - StartChar);
    if I > A then S := S + sLineBreak;
    S := S + Part;
  end;
  Clipboard.AsText := S;
end;

procedure TFreePDF64PDFiumView.ImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button <> mbLeft) or (FCore.PageCount = 0) then Exit;
  if not FMarkMode then
  begin
    FSelAnchorChar := SelectionHit(Sender, X, Y);
    if FSelAnchorChar < 0 then Exit;
    FSelAnchorPage := TPDFiumImage(Sender).Tag;
    FSelFocusPage := FSelAnchorPage;
    FSelFocusChar := FSelAnchorChar;
    FSelecting := True;
    TPDFiumImage(Sender).MouseCapture := True;
    RefreshSelectedPages;
    Exit;
  end;
  FreeAndNil(FCurrentStroke);
  FStrokePage := TPDFiumImage(Sender).Tag;
  FPage := FStrokePage;
  UpdateVisiblePage;
  FCurrentStroke := TPDFInkStroke.Create;
  FCurrentStroke.StrokeColor := FMarkColor;
  case FWidthSelect.ItemIndex of
    0: FCurrentStroke.LineWidth := 1;
    1: FCurrentStroke.LineWidth := 2;
    2: FCurrentStroke.LineWidth := 3;
    3: FCurrentStroke.LineWidth := 5;
    4: FCurrentStroke.LineWidth := 8;
    5: FCurrentStroke.LineWidth := 12;
  else
    FCurrentStroke.LineWidth := 5;
  end;
  FShapeStart := Point(X, Y);
  FreeAndNil(FPreviewBitmap);
  FPreviewBitmap := TBitmap.Create;
  FPreviewBitmap.Assign(TPDFiumImage(Sender).Picture.Bitmap);
  AppendPoint(X, Y);
  // Mausereignisse auch beim Ziehen ausserhalb des Bildes erhalten.
  TPDFiumImage(Sender).MouseCapture := True;
  DrawLivePreview;
end;

procedure TFreePDF64PDFiumView.ImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if FSelecting then
  begin
    if not (ssLeft in Shift) then Exit;
    // Bei gedrueckter Maustaste bleibt die Auswahl auch ausserhalb des Bildes aktiv.
    if SelectionHit(Sender, X, Y) >= 0 then
    begin
      FSelFocusPage := TPDFiumImage(Sender).Tag;
      if FSelFocusChar <> SelectionHit(Sender, X, Y) then
      begin
        FSelFocusChar := SelectionHit(Sender, X, Y);
        RefreshSelectedPages;
      end;
    end;
    Exit;
  end;
  if (FCurrentStroke = nil) or not (ssLeft in Shift) then Exit;
  if FShapeSelect.ItemIndex = 0 then
    AppendPoint(X, Y)
  else
    UpdateShapeStroke(X, Y);
  DrawLivePreview;
end;

procedure TFreePDF64PDFiumView.ImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FSelecting then
  begin
    FSelecting := False;
    TPDFiumImage(Sender).MouseCapture := False;
    Exit;
  end;
  if FCurrentStroke = nil then Exit;
  TPDFiumImage(Sender).MouseCapture := False;
  if FShapeSelect.ItemIndex <> 0 then
    UpdateShapeStroke(X, Y)
  else
    AppendPoint(X, Y);
  FreeAndNil(FPreviewBitmap);
  if FCurrentStroke.Count >= 2 then
  begin
    FCore.AddStroke(FStrokePage, FCurrentStroke);
    FCurrentStroke := nil;
  end
  else FreeAndNil(FCurrentStroke);
  if (FStrokePage >= 0) and (FStrokePage < Length(FLoadedPages)) and
     FLoadedPages[FStrokePage] then
  begin
    FCore.RenderPage(FStrokePage, PageImage(FStrokePage).Picture.Bitmap,
      PageImage(FStrokePage).Width, PageImage(FStrokePage).Height);
    DrawPageStrokes(FStrokePage);
  end;
end;

procedure TFreePDF64PDFiumView.DrawPageStrokes(APage: Integer);
var
  I: Integer;
  PW, PH: Single;
  Img: TPDFiumImage;
  procedure DrawOne(AStroke: TPDFInkStroke);
  var J, X, Y: Integer; P: TPDFInkPoint;
  begin
    if AStroke.Count < 2 then Exit;
    Img.Picture.Bitmap.Canvas.Pen.Color := AStroke.StrokeColor; // gespeicherte Annotation mit Alpha 115
    Img.Picture.Bitmap.Canvas.Pen.Width := Max(1, Round(AStroke.LineWidth * FZoom));
    for J := 0 to AStroke.Count - 1 do
    begin
      P := AStroke[J];
      if not FCore.PagePointToDevice(APage, Img.Width, Img.Height,
        P.X, P.Y, X, Y) then Continue;
      if J = 0 then Img.Picture.Bitmap.Canvas.MoveTo(X, Y)
      else Img.Picture.Bitmap.Canvas.LineTo(X, Y);
    end;
  end;
begin
  if (APage < 0) or (APage >= FPages.Count) then Exit;
  if (APage >= Length(FLoadedPages)) or not FLoadedPages[APage] then Exit;
  Img := PageImage(APage);
  if not FCore.PageSize(APage, PW, PH) or (PW <= 0) or (PH <= 0) then Exit;
  for I := 0 to FCore.Strokes.Count - 1 do
    if FCore.StrokePages[I] = APage then DrawOne(FCore.Strokes[I]);
  if (FCurrentStroke <> nil) and (FStrokePage = APage) then
    DrawOne(FCurrentStroke);
end;

procedure TFreePDF64PDFiumView.DrawSearchHighlight(APage: Integer);
var
  Img: TPDFiumImage;
  Matches: TArray<TPDFTextMatch>;
  Boxes: TArray<TPDFInkRect>;
  Box: TPDFInkRect;
  M: TPDFTextMatch;
  X1, Y1, X2, Y2, W, H: Integer;
  R: TRect;
  Overlay: TBitmap;
  Blend: TBlendFunction;
  IsCurrent: Boolean;
begin
  if (FFindTerm = '') or (APage < 0) then Exit;
  Img := PageImage(APage);
  if (Img = nil) or Img.Picture.Bitmap.Empty then Exit;
  Matches := FSearchMatches;
  if Length(Matches) = 0 then Exit;
  Overlay := TBitmap.Create;
  try
    Overlay.PixelFormat := pf24bit;
    Overlay.SetSize(1, 1);
    FillChar(Blend, SizeOf(Blend), 0);
    Blend.BlendOp := AC_SRC_OVER;
    Blend.AlphaFormat := 0;
    for M in Matches do
    begin
      if M.PageIndex <> APage then Continue;
      // Alle Treffer gelb; der mit F3 aktive Treffer orange und umrandet.
      IsCurrent := (M.PageIndex = FMatchPage) and
        (M.CharIndex = FMatchChar) and (M.CharCount = FMatchCount);
      if IsCurrent then
      begin
        Overlay.Canvas.Pixels[0, 0] := RGB(255, 150, 35);
        Blend.SourceConstantAlpha := 145;
      end
      else
      begin
        Overlay.Canvas.Pixels[0, 0] := RGB(255, 225, 60);
        Blend.SourceConstantAlpha := 110;
      end;
      Boxes := FCore.MatchCharRects(APage, M.CharIndex, M.CharCount);
      for Box in Boxes do
      begin
        if not FCore.PagePointToDevice(APage, Img.Width, Img.Height,
          Box.Left, Box.Top, X1, Y1) then Continue;
        if not FCore.PagePointToDevice(APage, Img.Width, Img.Height,
          Box.Right, Box.Bottom, X2, Y2) then Continue;
        R := Rect(Min(X1, X2), Min(Y1, Y2), Max(X1, X2), Max(Y1, Y2));
        W := R.Right - R.Left;
        H := R.Bottom - R.Top;
        if (W <= 0) or (H <= 0) then Continue;
        Winapi.Windows.AlphaBlend(Img.Picture.Bitmap.Canvas.Handle,
          R.Left, R.Top, W, H, Overlay.Canvas.Handle,
          0, 0, 1, 1, Blend);
        if IsCurrent then
        begin
          Img.Picture.Bitmap.Canvas.Brush.Style := bsClear;
          Img.Picture.Bitmap.Canvas.Pen.Color := RGB(210, 95, 0);
          Img.Picture.Bitmap.Canvas.Pen.Width := 2;
          Img.Picture.Bitmap.Canvas.Rectangle(R.Left, R.Top, R.Right, R.Bottom);
          Img.Picture.Bitmap.Canvas.Brush.Style := bsSolid;
        end;
      end;
    end;
  finally
    Overlay.Free;
  end;
end;

procedure TFreePDF64PDFiumView.DrawStrokes;
var I: Integer;
begin
  for I := 0 to FPages.Count - 1 do
    DrawPageStrokes(I);
end;

procedure TFreePDF64PDFiumView.SaveClick(Sender: TObject);
var D: TSaveDialog;
begin
  if FCore.PageCount = 0 then Exit;
  D := TSaveDialog.Create(nil);
  try
    D.Filter := 'PDF-Dateien|*.pdf';
    D.DefaultExt := 'pdf';
    D.FileName := ExtractFileName(FCore.FileName);
    if D.Execute then
    begin
      try
        if SameText(ExpandFileName(D.FileName), ExpandFileName(FCore.FileName)) then
          raise EPDFiumViewer.Create('Bitte einen anderen Dateinamen wählen.');
        if FCore.Modified then
          FCore.SaveAs(D.FileName)
        else if not CopyFile(PChar(FCore.FileName), PChar(D.FileName), False) then
          RaiseLastOSError;
        FCore.ClearUndo;
        UpdateSaveState;
        MessageDlg('PDF gespeichert: ' + D.FileName, mtInformation, [mbOK], 0);
      except
        on E: Exception do MessageDlg('Speichern fehlgeschlagen: ' + E.Message,
          mtError, [mbOK], 0);
      end;
    end;
  finally D.Free; end;
end;

function TFreePDF64PDFiumView.ConfirmUnsaved: Boolean;
var A: Integer;
begin
  Result := True;
  if not FCore.Modified then Exit;
  A := MessageDlg('Die PDF wurde geändert. Vor dem Wechsel speichern?',
    mtConfirmation, [mbYes, mbNo, mbCancel], 0);
  if A = mrCancel then Exit(False);
  if A = mrYes then
  begin
    SaveClick(nil);
    Result := not FCore.Modified;
  end;
end;

procedure TFreePDF64PDFiumView.PrintClick(Sender: TObject);
var
  B: TBitmap;
  Dlg: TPrintDialog;
  I, W, H, FirstPage, LastPage: Integer;
  PW, PH: Single;
  Scale: Double;
begin
  if FCore.PageCount = 0 then Exit;
  Dlg := TPrintDialog.Create(Self);
  try
    Dlg.Options := [poPageNums];
    Dlg.MinPage := 1;
    Dlg.MaxPage := FCore.PageCount;
    Dlg.FromPage := 1;
    Dlg.ToPage := FCore.PageCount;
    if not Dlg.Execute then Exit;
    FirstPage := 0;
    LastPage := FCore.PageCount - 1;
    if Dlg.PrintRange = prPageNums then
    begin
      FirstPage := Max(0, Dlg.FromPage - 1);
      LastPage := Min(FCore.PageCount - 1, Dlg.ToPage - 1);
    end;
    if LastPage < FirstPage then Exit;
    B := TBitmap.Create;
    try
      Printer.BeginDoc;
    try
      for I := FirstPage to LastPage do
      begin
        if I > FirstPage then Printer.NewPage;
        if not FCore.PageSize(I, PW, PH) then Continue;
        if (PW <= 0) or (PH <= 0) then Continue;
        Scale := Min(Printer.PageWidth / PW, Printer.PageHeight / PH);
        W := Round(PW * Scale);
        H := Round(PH * Scale);
        FCore.RenderPage(I, B, W, H);
        Printer.Canvas.StretchDraw(Rect((Printer.PageWidth - W) div 2,
          (Printer.PageHeight - H) div 2,
          (Printer.PageWidth + W) div 2,
          (Printer.PageHeight + H) div 2), B);
      end;
      Printer.EndDoc;
    except
      Printer.Abort;
      raise;
    end;
    finally
      B.Free;
    end;
  finally
    Dlg.Free;
  end;
end;

end.
