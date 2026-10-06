unit Suchen;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Diagnostics,
  System.Classes, Vcl.Graphics, Vcl.Controls, System.IOUtils,
  Vcl.StdCtrls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Buttons, Vcl.ImgList, Vcl.FileCtrl, IniFiles, Vcl.Menus, System.DateUtils,
  ShellAPI, Vcl.WinXCtrls, ShlObj, ActiveX, StrUtils, Types, Masks,
  LMDShBase, LMDShDlg, CommCtrl, MMSystem, LMDCustomComponent, Vcl.Samples.Spin;

type
  TZeit = (zCreation, zLastAccess, zLastWrite);
  // Erstellt, letzter Zugriff, letzte Änderung
type
  TFileAttributes = set of (ReadOnly, Hidden, SysFile, VolumeId, Directory, Archive, AnyFile);

type
  TByteStringFormat = (bsfDefault, bsfBytes, bsfKB, bsfMB, bsfGB, bsfTB);

type
  TSuche_Form = class(TForm)
    Panel_oben: TPanel;
    DirCheckbox: TCheckBox;
    Suchpanel: TPanel;
    StatusBar1: TStatusBar;
    ButtonHoch: TButton;
    Browse: TButton;
    Label1: TLabel;
    Label2: TLabel;
    FileField: TComboBox;
    StopSearchButton: TBitBtn;
    StartSearchButton: TBitBtn;
    HiddenCheckbox: TCheckBox;
    SearchField: TComboBox;
    Label4: TLabel;
    SearchMaxDate: TDateTimePicker;
    SearchMinDate: TDateTimePicker;
    DatumCheckBox: TCheckBox;
    ButtonRoot: TButton;
    FilesFoldersCB: TComboBox;
    FileSizeCombo: TComboBox;
    SizeAuswahl: TComboBox;
    Splitter1: TSplitter;
    Clear: TSpeedButton;
    PanelBottom: TPanel;
    Btn_2: TSpeedButton;
    Btn_6: TSpeedButton;
    Btn_1: TSpeedButton;
    Btn_5: TSpeedButton;
    Btn_4: TSpeedButton;
    UmbenennenCB: TCheckBox;
    ListBox1: TListBox;
    Btn_3: TSpeedButton;
    LMDShellSysBrowseDialog1: TLMDShellSysBrowseDialog;
    Btn_0: TSpeedButton;
    Timer1: TTimer;
    SuchergebnisBtn: TBitBtn;
    TextLabel: TLabel;
    TextCB: TComboBox;
    LabelTextCB: TLabel;
    DateigroesseLabel: TLabel;
    MainMenu1: TMainMenu;
    Editor1: TMenuItem;
    DateiInfo1: TMenuItem;
    Kopieren1: TMenuItem;
    Bewegen1: TMenuItem;
    Lschen1: TMenuItem;
    Markieren1: TMenuItem;
    Info: TButton;
    AlterCB: TCheckBox;
    AgeAuswahl: TComboBox;
    AgeSizeEdit: TSpinEdit;
    FileSize: TSpinEdit;
    DTP: TDateTimePicker;
    DateiCheckBox: TCheckBox;
    SucheEdit: TEdit;
    AnzeigenPanel: TPanel;
    Gehezu1: TMenuItem;
    Btn_8: TSpeedButton;
    PDFViewer1: TMenuItem;
    SuchergebnisCB: TCheckBox;
    procedure ButtonHochClick(Sender: TObject);
    procedure BrowseClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FileFieldDropDown(Sender: TObject);
    procedure StopSearchButtonClick(Sender: TObject);
    procedure StartSearchButtonClick(Sender: TObject);
    procedure SearchFieldDropDown(Sender: TObject);
    procedure DateiinsQuellverzeichniskopieren1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DatumCheckBoxClick(Sender: TObject);
    procedure ButtonRootClick(Sender: TObject);
    procedure FilesFoldersCBChange(Sender: TObject);
    procedure FileSizeKeyPress(Sender: TObject; var Key: Char);
    procedure FileSizeEnter(Sender: TObject);
    procedure FileSizeClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Btn_4Click(Sender: TObject);
    procedure Btn_0Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure SuchpanelResize(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Btn_1Click(Sender: TObject);
    procedure Btn_2Click(Sender: TObject);
    procedure Btn_3Click(Sender: TObject);
    procedure SuchergebnisBtnClick(Sender: TObject);
    procedure TextCBDropDown(Sender: TObject);
    procedure Editor1Click(Sender: TObject);
    procedure DateiInfo1Click(Sender: TObject);
    procedure Kopieren1Click(Sender: TObject);
    procedure Bewegen1Click(Sender: TObject);
    procedure Lschen1Click(Sender: TObject);
    procedure Markieren1Click(Sender: TObject);
    procedure InfoClick(Sender: TObject);
    procedure AlterCBClick(Sender: TObject);
    procedure DateiCheckBoxClick(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure SucheEditChange(Sender: TObject);
    procedure Panel_obenEnter(Sender: TObject);
    procedure MoveSelectedItemsToTop(ListBox: TListBox);
    procedure AnzeigenPanelClick(Sender: TObject);
    procedure Btn_8Click(Sender: TObject);
    procedure FileFieldCloseUp(Sender: TObject);
    procedure SuchergebnisCBClick(Sender: TObject);
    public
      { Public-Deklarationen }
      procedure PlaySoundFile(FileName: string);
      procedure FileFieldChange(Sender: TObject);
    private
      { Private-Deklarationen }
      flbHorzScrollWidth: Integer;
      BrowseHook: HHOOK;
      FLastPersistent: string;
      FWaitForm: TForm;
      SearchStopwatch: TStopwatch;
      function IsShortCut(var Message: TWMKey): Boolean; override;
    end;

var
  Suche_Form: TSuche_Form;
  // Globale Variablen
  StopSuche, Links, Rechts: Boolean;
  Zaehler, SFHStart, SFHResize: Integer;
  Anzeige: String;
  AltLeftDown: Boolean;

implementation

{$R *.dfm}

uses FreePDF64_Unit, FreePDF64_Notify_Unit, Einstellungen_Unit, Suche_Info_Unit, uPDFBrowserForm;

function TSuche_Form.IsShortCut(var Message: TWMKey): Boolean;
begin
  if Message.CharCode = VK_F2 then
  begin
    SuchergebnisCB.Checked := not SuchergebnisCB.Checked;

    if SuchergebnisCB.Checked then
    begin
      SucheEdit.Text        := '';
      SucheEdit.Visible     := True;
      AnzeigenPanel.Visible := True;

      SucheEdit.Color     := $00E8F1FF;
      AnzeigenPanel.Color := $00D6E8FF;

      SucheEdit.SetFocus;
    end
    else
    begin
      SucheEdit.Visible     := False;
      AnzeigenPanel.Visible := False;

      SucheEdit.Color     := clWhite;
      AnzeigenPanel.Color := clWhite;
    end;

    Result := True;
    Exit;
  end;

  Result := inherited IsShortCut(Message);
end;

procedure TSuche_Form.Panel_obenEnter(Sender: TObject);
begin
  SucheEdit.Visible     := False;
  AnzeigenPanel.Visible := False;
end;

procedure TSuche_Form.PlaySoundFile(FileName: string);
begin
  if FileExists(FileName) then
    PlaySound(pchar(FileName), 0, SND_ASYNC or SND_FILENAME);

  { Flags are:
    SND_SYNC  =0 = Start playing, and wait for the sound to finish
    SND_ASYNC =1 = Start playing, and don't wait to return
    SND_LOOP  =8 = Keep looping the sound until another sound is played }
end;

// Explorer-Contextmenü öffnen!
procedure ContextMenuForFile(Wnd: HWND; FileName: String; X, Y: Integer);
Var
  ContextMenu: IContextMenu;
  Popup: HMENU;
  CmdInfo: TCMInvokeCommandInfo;
  PIDL: PItemIDList;
  ShellFolder: IShellFolder;
  Eaten, Attr: LongWord;
  FileDir: String;
begin
  if SHGetDesktopFolder(ShellFolder) <> NO_ERROR then
    Exit;
  FileDir := ExtractFileDir(FileName);
  FileName := ExtractFileName(FileName);
  if (FileDir <> '') and
    ((ShellFolder.ParseDisplayName(Wnd, NIL, pchar(FileDir), Eaten, PIDL,
    Attr) <> NO_ERROR) or (ShellFolder.BindToObject(PIDL, NIL, IID_IShellFolder,
    Pointer(ShellFolder)) <> NO_ERROR)) or
    (ShellFolder.ParseDisplayName(Wnd, NIL, pchar(FileName), Eaten, PIDL, Attr)
    <> NO_ERROR) or (ShellFolder.GetUIObjectOf(Wnd, 1, PIDL, IID_IContextMenu,
    NIL, Pointer(ContextMenu)) <> NO_ERROR) then
    Exit;
  Popup := CreatePopUpMenu;
  if Popup = 0 then
    Exit;
  try
    if Failed(ContextMenu.QueryContextMenu(Popup, 0, 1, $7FFF, CMF_NORMAL)) then
      Exit;
    FillChar(CmdInfo, Sizeof(TCMInvokeCommandInfo), 0);
    CmdInfo.cbSize := Sizeof(TCMInvokeCommandInfo);
    CmdInfo.lpVerb := PAnsiChar(TrackPopupMenuEx(Popup, TPM_LEFTALIGN or
      TPM_RETURNCMD or TPM_RIGHTBUTTON or TPM_HORIZONTAL or TPM_VERTICAL, X, Y,
      Wnd, NIL)) - 1;
    CmdInfo.nShow := SW_SHOWNORMAL;
    if CmdInfo.lpVerb = PAnsiChar(-1) then
      Exit;
    ContextMenu.InvokeCommand(CmdInfo);
  finally
    DestroyMenu(Popup);
  end;
end;

procedure TSuche_Form.FormCreate(Sender: TObject);
var
  Laenge: Integer;
  Scale: Single;
begin
  // Zeilenhöhe des Suchergebnisses einstellen ---------------------------------
  Scale := ListBox1.CurrentPPI / 96;
  ListBox1.ItemHeight := Round(18 * Scale);
  // ---------------------------------------------------------------------------

  ListBox1.OnDrawItem := ListBox1DrawItem;

    // Suche_Form zusätzlich in der Taskbar anzeigen lassen
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or
    WS_EX_APPWINDOW);

  Suche_ItemAnzeigen  := False;

  // Die Buttons werden dargestellt und ausgerichtet!
  Laenge := Suche_Form.Width div 9;
  Btn_8.Left := 1;
  Btn_8.Align := alLeft;
  Btn_8.Width := Laenge;
  Btn_1.Left := 2;
  Btn_1.Align := alLeft;
  Btn_1.Width := Laenge;
  Btn_2.Left := 3;
  Btn_2.Align := alLeft;
  Btn_2.Width := Laenge;
  Btn_3.Left := 4;
  Btn_3.Align := alLeft;
  Btn_3.Width := Laenge;
  Btn_4.Left := 5;
  Btn_4.Align := alLeft;
  Btn_4.Width := Laenge;
  Btn_0.Left := 6;
  Btn_0.Align := alLeft;
  Btn_0.Width := Laenge;
  Btn_6.Left := 7;
  Btn_6.Align := alLeft;
  Btn_6.Width := Laenge;
  Btn_5.Left := 8;
  Btn_5.Align := alClient;
  Btn_5.Width := Laenge;
end;

procedure TSuche_Form.FormResize(Sender: TObject);
var
  Laenge: Integer;
begin
  // Die Buttons werden dargestellt und ausgerichtet!
  Laenge := Suche_Form.Width div 8;
  Btn_5.Width := Laenge;
  Btn_5.Left := 1;
  Btn_6.Width := Laenge;
  Btn_6.Left := 2;
  Btn_0.Width := Laenge;
  Btn_0.Left := 3;
  Btn_4.Width := Laenge;
  Btn_4.Left := 4;
  Btn_3.Width := Laenge;
  Btn_3.Left := 5;
  Btn_2.Width := Laenge;
  Btn_2.Left := 6;
  Btn_1.Width := Laenge;
  Btn_1.Left := 7;
  Btn_8.Width := Laenge;
  Btn_8.Left := 8;

  SFHResize := Suche_Form.Height;
end;

procedure TSuche_Form.FormClose(Sender: TObject; var Action: TCloseAction);
var
  IniDat: TIniFile;
  IniFile: String;
  i: Integer;
begin
  SucheEdit.Visible     := False;
  AnzeigenPanel.Visible := False;
  StopSuche             := True;

  // Horizontaler Scrollbalken wird wieder entfernt
  flbHorzScrollWidth := 0;
  Listbox1.Perform(LB_SETHORIZONTALEXTENT, 0, 0);

  // Nachfolgender Abschnitt wird leider für Constraints benötigt
  Suche_Form.Constraints.MaxHeight := 0;
  Suche_Form.Visible  := False;
  PanelBottom.Visible := True;
  StatusBar1.Visible  := True;
  Suche_Form.Constraints.MinHeight := Suche_Form.Height - Suchpanel.Height + PanelBottom.Height + StatusBar1.Height;
  if (SFHResize < SFHStart) and (Suche_Form.Height = Suche_Form.Height - Suchpanel.Height) then
  begin
    Suche_Form.Height := SFHStart;
    SFHResize := SFHStart;
  end else
  begin
    if SFHResize < SFHStart then
      Suche_Form.Height := SFHResize
    else
    if SFHResize > SFHStart then
    begin
      Suche_Form.Height := SFHResize;
      SFHStart := SFHResize;
    end else
    if SFHStart > SFHResize then
      Suche_Form.Height := SFHStart
    else
    if SFHResize < Suche_Form.Height then
    begin
      Suche_Form.Height := SFHResize;
      SFHStart := SFHResize;
    end;
  end;
  // ============================================================

  for i := FileField.Items.Count downto 0 do
    if FileField.Items.Strings[i] = '' then
      FileField.Items.Delete(i);
  for i := SearchField.Items.Count downto 0 do
    if SearchField.Items.Strings[i] = '' then
      SearchField.Items.Delete(i);
  for i := TextCB.Items.Count downto 0 do
    if TextCB.Items.Strings[i] = '' then
      TextCB.Items.Delete(i);
  try
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
    IniDat := TIniFile.Create(IniFile);
    // Speichere beim Beenden des Programmes in die 'FreePDF64.ini'
    with IniDat do
      // Verlauf Suche-Form schreiben.
      IniDat.EraseSection('Suche');
      if SearchField.Items.Count > 0 then
        for i := 0 to SearchField.Items.Count do
          IniDat.WriteString('Search', 'SearchField' + IntToStr(i), SearchField.Items[i]);

      if FileField.Items.Count > 0 then
        for i := 0 to FileField.Items.Count do
          IniDat.WriteString('Search', 'FileField' + IntToStr(i), FileField.Items[i]);

      // Textsuche schreiben.
      if TextCB.Items.Count > 0 then
      for i := 0 to TextCB.Items.Count do
        IniDat.WriteString('Search', 'Textsearch' + IntToStr(i), TextCB.Items[i]);

    IniDat.WriteInteger('Search', 'Top',    Suche_Form.Top);
    IniDat.WriteInteger('Search', 'Left',   Suche_Form.Left);
    IniDat.WriteInteger('Search', 'Height', Suche_Form.Height);
    IniDat.WriteInteger('Search', 'Width',  Suche_Form.Width);
    // Speicher wird wieder freigeben
    IniDat.Free;
  except
    Showmessage('Fehler festgestellt!');
  end;
end;

procedure TSuche_Form.Bewegen1Click(Sender: TObject);
begin
  Btn_3.Click;
end;

procedure CenterDialogOverForm(DialogHandle: HWND; Owner: TForm);
var
  RDlg, ROwner: TRect;
  X, Y: Integer;
begin
  if (DialogHandle = 0) or (Owner = nil) then Exit;

  GetWindowRect(DialogHandle, RDlg);
  GetWindowRect(Owner.Handle, ROwner);

  X := ROwner.Left + ((ROwner.Right - ROwner.Left) div 2) - ((RDlg.Right - RDlg.Left) div 2);
  Y := ROwner.Top  + ((ROwner.Bottom - ROwner.Top) div 2) - ((RDlg.Bottom - RDlg.Top) div 2);

  SetWindowPos(DialogHandle, 0, X, Y, 0, 0,
    SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
end;

function BrowseHookProc(nCode: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  RDlg, RSearch: TRect;
  X, Y: Integer;
begin
  if (nCode = HCBT_ACTIVATE) and (Suche_Form <> nil) then
  begin
    // Rechteck des Dialogs
    GetWindowRect(wParam, RDlg);

    // Rechteck des Suchfeldes (SearchField)
    GetWindowRect(Suche_Form.SearchField.Handle, RSearch);

    // X = horizontale Mitte des Suchfeldes
    X := RSearch.Left + ((RSearch.Right - RSearch.Left) div 2)
         - ((RDlg.Right - RDlg.Left) div 2) + 160;   // 160 px nach rechts

    // Y = Unterkante des Suchfeldes
    Y := RSearch.Bottom;

    // Fenster verschieben
    SetWindowPos(wParam, 0, X, Y, 0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
  end;

  Result := CallNextHookEx(Suche_Form.BrowseHook, nCode, wParam, lParam);
end;

procedure TSuche_Form.BrowseClick(Sender: TObject);
var
  s: String;
begin
  s := SearchField.Text;

  LMDShellSysBrowseDialog1.SelectedPath := '';
  LMDShellSysBrowseDialog1.Caption := 'Laufwerk oder Verzeichnis auswählen';
  LMDShellSysBrowseDialog1.InstructionText := 'Bitte das gewünschte Laufwerk oder Verzeichnis auswählen:';

  // Hook setzen – fängt das nächste Fenster ab
  BrowseHook := SetWindowsHookEx(WH_CBT, @BrowseHookProc, 0, GetCurrentThreadId);

  if LMDShellSysBrowseDialog1.Execute then
    s := LMDShellSysBrowseDialog1.SelectedPath;

  // Hook entfernen
  UnhookWindowsHookEx(BrowseHook);

  SearchField.Text := s;
end;

// MessageDlg zentriert
function MessageDlgCenter(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;
var
  R: TRect;
begin
  if not Assigned(Screen.ActiveForm) then
  begin
    Result := MessageDlg(Msg, DlgType, Buttons, 0);
  end
  else
  begin
    with CreateMessageDialog(Msg, DlgType, Buttons) do
      try
        GetWindowRect(Screen.ActiveForm.Handle, R);
        Left := R.Left + ((R.Right - R.Left) div 2) - (Width div 2);
        Top := R.Top + ((R.Bottom - R.Top) div 2) - (Height div 2);
        Result := ShowModal;
      finally
        Free;
      end;
  end;
end;

// Dateien/Verzeichnisse löschen
function DeleteFiles(const AFile: string): Boolean;
var
  sh: SHFileOpStruct;
begin
  ZeroMemory(@sh, Sizeof(sh));
  with sh do
  begin
    Wnd := Application.Handle;
    wFunc := FO_DELETE;
    pFrom := pchar(AFile + #0);
    fFlags := FOF_NOCONFIRMATION or FOF_ALLOWUNDO;
  end;
  Result := SHFileOperation(sh) = 0;
end;

// Löschen (mit F8)
procedure TSuche_Form.Btn_4Click(Sender: TObject);
var
  i: Integer;
  s, Msg: String;
begin
  if ListBox1.SelCount = 0 then
    Exit;

  Msg := 'Soll(en) die Datei(en)/Verzeichnis(se) wirklich gelöscht werden?';
  if MessageDlgCenter(Msg, mtInformation, [mbYes, mbNo]) = mrNo then
    Exit;

  for i := 0 to ListBox1.Count - 1 do
    if ListBox1.Selected[i] then
    begin
      s := ListBox1.Items.Strings[i];

      // Prüfe, ob das erste Zeichen ein [ ist - und entfernen
      if Pos('[', s) <> 0 then
        Delete(s, 1, 1);
      // Prüfe, ob das letzte Zeichen ein ] ist - und entfernen
      if s[Length(s)] = ']' then
        Delete(s, Length(s), 1);

      DeleteFiles(s)
    end;
  ListBox1.DeleteSelected;
  if ListBox1.Count > 0 then
    ListBox1.Selected[0] := True;
end;

// Task schließen (hier Ghostscript)
procedure KillTask(ExeFileName: string);
var
  h: HWND;
begin // ExeFileName = caption or cmd path
  h := FindWindow(NIL, LPCWSTR(ExeFileName));
  if h <> 0 then
    PostMessage(h, WM_CLOSE, 0, 0);
end;

// Button: F3 Anzeigen
procedure TSuche_Form.Btn_8Click(Sender: TObject);
var
  i: Integer;
  s: String;
  PDFForm: TPDFBrowserForm;
  Offset: Integer;
  PDFCount: Integer;
  BaseOffset: Integer;
begin
  if ListBox1.SelCount = 0 then
    Exit;

  PDFCount := 0;

  // Grundversatz bei 100 % DPI
  BaseOffset := 20;

  // Alle markierten Dateien durchlaufen
  for i := 0 to ListBox1.Count - 1 do
  begin
    if ListBox1.Selected[i] then
    begin
      s := ListBox1.Items.Strings[i];
      // Prüfe, ob das erste Zeichen ein [ ist - und entfernen
      if (Length(s) > 0) and (s[1] = '[') then
        Delete(s, 1, 1);
      // Prüfe, ob das letzte Zeichen ein ] ist - und entfernen
      if (Length(s) > 0) and (s[Length(s)] = ']') then
        Delete(s, Length(s), 1);
      // Nur PDF-Dateien anzeigen
      if UpperCase(ExtractFileExt(s)) = '.PDF' then
      begin
        PDFForm := TPDFBrowserForm.Create(Self);
        PDFForm.PDFFileName := s;
        // DPI-skalierter Versatz
        // 100 % = 30 Pixel
        // 125 % = 38 Pixel
        // 150 % = 45 Pixel
        // 175 % = 53 Pixel
        // 200 % = 60 Pixel
        Offset := MulDiv(
                 (PDFCount mod 8) * BaseOffset,
                  PDFForm.CurrentPPI,
                  96
                 );
        PDFForm.Left := PDFForm.Left + Offset;
        PDFForm.Top := PDFForm.Top + Offset;
        PDFForm.Show;
        Application.ProcessMessages;
        Inc(PDFCount);
      end;
    end;
  end;

  // Falls keine PDF-Datei ausgewählt wurde
  if PDFCount = 0 then
    ShowMessage('Es wurden keine PDF-Dateien ausgewählt!');
end;

procedure TSuche_Form.Markieren1Click(Sender: TObject);
begin
  Suche_Form.Caption := 'Markieren gestartet. Bitte warten...';

  if ListBox1.Count = 0 then
  begin
    Suche_Form.Caption := 'Suchen nach Datei(en)/Verzeichnis(se)';
    Exit;
  end;

  LockWindowUpdate(ListBox1.Handle);
  try
    // Alle Einträge direkt über die Windows-ListBox markieren.
    // -1 bedeutet: alle Einträge.
    SendMessage(ListBox1.Handle, LB_SETSEL, 1, -1);

    // Die Anzahl ist nach Select-All bekannt:
    StatusBar1.Panels[1].Text :=
      'Markiert: ' + IntToStr(ListBox1.Count);
  finally
    LockWindowUpdate(0);
  end;

  StatusBar1.Canvas.Font := StatusBar1.Font;
  StatusBar1.Panels[0].Width :=
    ListBox1.Width -
    (StatusBar1.Canvas.TextWidth(StatusBar1.Panels[1].Text) + 36);

  // Zum obersten Eintrag gehen
  ListBox1.ItemIndex := 0;

  Suche_Form.Caption := 'Suchen nach Datei(en)/Verzeichnis(se)';
end;

procedure TSuche_Form.ButtonHochClick(Sender: TObject);
var
  SText: String;
begin
  // Item in ComboBox aufnehmen...
  SText := IncludeTrailingBackslash(SearchField.Text);

  SearchField.Text := ExcludeTrailingBackslash
    (ExtractFileDir(ExcludeTrailingBackslash(SearchField.Text)));
  if Length(SearchField.Text) = 2 then
    SearchField.Text := IncludeTrailingBackslash
      (ExtractFileDir(ExcludeTrailingBackslash(SearchField.Text)));
  if SearchField.Items.IndexOf(SearchField.Text) < 0 then
    SearchField.Items.Add(SearchField.Text);
  if SearchField.Text = '' then
    SearchField.Text := ExcludeTrailingBackslash(Ziel);
end;

// Zum Root des Laufwerks gehen
procedure TSuche_Form.ButtonRootClick(Sender: TObject);
begin
  SearchField.Text := IncludeTrailingBackslash
    (ExtractFileDrive(SearchField.Text));
end;

// Suche nach Dateigröße - zurücksetzen!
procedure TSuche_Form.ClearClick(Sender: TObject);
begin
  FileSizeCombo.ItemIndex := 1;
  FileSize.Value          := 1;
  SizeAuswahl.ItemIndex   := 1;
end;

// Kopieren: fFlags siehe Stichwort SHFILEOPSTRUCT
// Wird dem Parameter False übergeben, wird der Anwender gefragt, bevor eine Datei
// überschrieben wird. Steht der Parameter auf True wird die Datei automatisch umbenannt.
function CopyFileEx(const ASource, ADest: string;
  ARenameCheck: Boolean = False): Boolean;
var
  sh: TSHFileOpStruct;
begin
  sh.Wnd := Application.Handle;
  sh.wFunc := FO_COPY;

  // String muss mit #0#0 terminiert werden, um das Listenende zu setzen
  sh.pFrom := pchar(ASource + #0#0);
  sh.pTo := pchar(ADest + #0#0);
  sh.fFlags := fof_MultiDestFiles;
  if ARenameCheck then
    sh.fFlags := sh.fFlags or fof_RenameOnCollision;
  Result := SHFileOperation(sh) = 0;
end;

// Bewegen: fFlags siehe Stichwort SHFILEOPSTRUCT
function MoveFileEx(const ASource, ADest: string;
  ARenameCheck: Boolean = False): Boolean;
var
  sh: TSHFileOpStruct;
begin
  sh.Wnd := Application.Handle;
  sh.wFunc := FO_MOVE;

  // String muss mit #0#0 terminiert werden, um das Listenende zu setzen
  sh.pFrom := pchar(ASource + #0#0);
  sh.pTo := pchar(ADest + #0#0);
  sh.fFlags := fof_MultiDestFiles;
  if ARenameCheck then
    sh.fFlags := sh.fFlags or fof_RenameOnCollision;
  Result := SHFileOperation(sh) = 0;
end;

procedure TSuche_Form.DateiInfo1Click(Sender: TObject);
begin
  Btn_0.Click;
end;

procedure TSuche_Form.DateiinsQuellverzeichniskopieren1Click(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  if ListBox1.SelCount = 0 then
    Exit;

  for i := 0 to ListBox1.Count - 1 do
    if ListBox1.Selected[i] then
    begin
      s := ListBox1.Items.Strings[i];
      // Prüfe, ob das erste Zeichen ein [ ist - und entfernen
      if Pos('[', s) <> 0 then
        Delete(s, 1, 1);
      // Prüfe, ob das letzte Zeichen ein ] ist - und entfernen
      if s[Length(s)] = ']' then
        Delete(s, Length(s), 1);

      if DirectoryExists(s) then
      begin
        if Einstellungen_Form.SystemklangCB.Checked then
          PlaySoundFile(ExtractFilePath(Application.ExeName) +
            'sounds\standard.wav');
        MessageDlgCenter('Keine Datei(en) ausgewählt!', mtInformation, [mbOk]);
        Exit;
      end;

      if UmbenennenCB.Checked then
        CopyFileEx(pchar(s),
          pchar(IncludeTrailingBackslash(FreePDF64_Notify.MonitoringFolder.Text)
          + ExtractFileName(s)), True)
      else
        CopyFileEx(pchar(s),
          pchar(IncludeTrailingBackslash(FreePDF64_Notify.MonitoringFolder.Text)
          + ExtractFileName(s)), False);
      StatusBar1.Panels[0].Text :=
        'Datei(en) kopiert ins Überwachungs-Quellverzeichnis...'
    end;
//  ListBox1.ClearSelection;
end;

procedure TSuche_Form.DatumCheckBoxClick(Sender: TObject);
begin
  if DatumCheckBox.Checked = True then
  begin
    if AlterCB.Checked then
      AlterCB.Checked := False;
    SearchMinDate.Enabled := True;
    SearchMaxDate.Enabled := True;
  end else
  begin
    SearchMinDate.Enabled := False;
    SearchMaxDate.Enabled := False;
  end;
end;

procedure TSuche_Form.DateiCheckBoxClick(Sender: TObject);
begin
  if DateiCheckBox.Checked = True then
  begin
    FileSizeCombo.Enabled := True;
    FileSize.Enabled      := True;
    SizeAuswahl.Enabled   := True;
  end else
  begin
    FileSizeCombo.Enabled := False;
    FileSize.Enabled      := False;
    SizeAuswahl.Enabled   := False;
  end;
end;

procedure TSuche_Form.AlterCBClick(Sender: TObject);
begin
  if AlterCB.Checked = True then
  begin
    if DatumCheckBox.Checked then
      DatumCheckBox.Checked := False;
    AgeSizeEdit.Enabled   := True;
    AgeAuswahl.Enabled    := True;
  end else
  begin
    AgeSizeEdit.Enabled   := False;
    AgeAuswahl.Enabled    := False;
  end;
end;

procedure TSuche_Form.AnzeigenPanelClick(Sender: TObject);
begin
  LockWindowUpdate(ListBox1.Handle);
  MoveSelectedItemsToTop(ListBox1);
  LockWindowUpdate(0);
end;

procedure TSuche_Form.Editor1Click(Sender: TObject);
begin
  Btn_1.Click;
  Suche_Form.SetFocus;
end;

procedure TSuche_Form.MoveSelectedItemsToTop(ListBox: TListBox);
var
  i: Integer;
  SelectedItems: TStringList;
begin
  SelectedItems := TStringList.Create;
  try
    // Sammeln der ausgewählten Elemente
    for i := ListBox.Items.Count - 1 downto 0 do
    begin
      if ListBox.Selected[i] then
      begin
        SelectedItems.AddObject(ListBox.Items[i], ListBox.Items.Objects[i]);
        ListBox.Items.Delete(i);
      end;
    end;

    // Einfügen der ausgewählten Elemente an den Anfang
    for i := 0 to SelectedItems.Count - 1 do
    begin
      ListBox.Items.InsertObject(i, SelectedItems[i], SelectedItems.Objects[i]);
      ListBox.Selected[i] := True;
    end;
  finally
    SelectedItems.Free;
  end;
end;

// Suche den Inhalt von SucheEdit.Text im Suchergebnis der ListBox
procedure TSuche_Form.SucheEditChange(Sender: TObject);
var
  I: Integer;
  SearchText: string;
  FirstMatch: Integer;
begin
  SucheEdit.Color     := clWhite;
  AnzeigenPanel.Color := clWhite;

  SearchText := Trim(SucheEdit.Text);
  FirstMatch := -1;

  // Zeichnen während der Suche abschalten -> kein Flackern
  SendMessage(ListBox1.Handle, WM_SETREDRAW, WPARAM(False), 0);
  ListBox1.Items.BeginUpdate;
  try
    // Vorherige Markierungen entfernen
    ListBox1.ClearSelection;

    // Nur suchen, wenn tatsächlich ein Suchtext vorhanden ist
    if SearchText <> '' then
    begin
      SearchText := LowerCase(SearchText);

      for I := 0 to ListBox1.Items.Count - 1 do
      begin
        // Im kompletten angezeigten ListBox-Eintrag suchen
        if Pos(SearchText, LowerCase(ListBox1.Items[I])) > 0 then
        begin
          ListBox1.Selected[I] := True;

          // Position des ersten Treffers merken
          if FirstMatch = -1 then
            FirstMatch := I;
        end;
      end;
    end;

    // Nur einmal zum ersten Treffer springen
    if FirstMatch >= 0 then
      ListBox1.TopIndex := FirstMatch;

  finally
    ListBox1.Items.EndUpdate;

    // Zeichnen wieder einschalten
    SendMessage(ListBox1.Handle, WM_SETREDRAW, WPARAM(True), 0);

    // ListBox sofort neu zeichnen
    ListBox1.Invalidate;
    ListBox1.Update;
  end;

  // Anzahl der gefundenen/markierten Einträge anzeigen
  StatusBar1.Panels[1].Text := 'Markiert: ' + IntToStr(ListBox1.SelCount);
end;

procedure TSuche_Form.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
    StartSearchButton.Click;
end;

procedure TSuche_Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    StopSearchButton.Click;
end;

// Suche-Checkbox für Suchen im Suchergebnis
procedure TSuche_Form.SuchergebnisCBClick(Sender: TObject);
begin
  if SuchergebnisCB.Checked then
    if (ListBox1.Count > 0) then
    begin
      SucheEdit.Text        := '';
      SucheEdit.Visible     := True;
      AnzeigenPanel.Visible := True;

      SucheEdit.Color     := $00E8F1FF;
      AnzeigenPanel.Color := $00D6E8FF;

      SucheEdit.SetFocus;
    end else
    begin
      SucheEdit.Visible     := False;
      AnzeigenPanel.Visible := False;

      SucheEdit.Color     := clWhite;
      AnzeigenPanel.Color := clWhite;
    end;
end;

procedure TSuche_Form.FormShow(Sender: TObject);
var
  s: Integer;
  IniDat: TIniFile;
  IniFile: String;
begin
  s := Suche_Form.Height;
  try
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
    IniDat := TIniFile.Create(IniFile);
    with IniDat do
    begin
      Suche_Form.Top    := ReadInteger('Search', 'Top',    Suche_Form.Top);
      Suche_Form.Left   := ReadInteger('Search', 'Left',   Suche_Form.Left);
      Suche_Form.Height := ReadInteger('Search', 'Height', Suche_Form.Height);
      Suche_Form.Width  := ReadInteger('Search', 'Width',  Suche_Form.Width);
    end;
    // Speicher wird wieder freigeben
    IniDat.Free;
  except
    Showmessage('Fehler festgestellt!');
  end;
  SFHStart := Suche_Form.Height;

  if SFHStart = Suche_Form.Height - Suchpanel.Height - PanelBottom.Height - StatusBar1.Height then
    SFHStart := SFHStart + 200
  else
  if SFHStart < s then
    SFHStart := s
  else
    SFHStart := Suche_Form.Height;

  Suche_Form.Height := s;

  StatusBar1.Panels[0].Text := '';
  StatusBar1.Panels[1].Text := '';
  Suche_Form.Constraints.MinHeight := Suche_Form.Height - Suchpanel.Height - PanelBottom.Height - StatusBar1.Height;
  Suche_Form.Constraints.MaxHeight := Suche_Form.Constraints.MinHeight;
  Suche_Form.Constraints.MinWidth  := 800;

  Timer1.Enabled          := False;
  SuchergebnisCB.Enabled  := False;
  SuchergebnisCB.Checked  := False;
  SuchergebnisBtn.Enabled := False;
  SucheEdit.Visible       := False;
  AnzeigenPanel.Visible   := False;
  DTP.Date := Date;
  DTP.Time := Time;

  ListBox1.Clear;
  FilesFoldersCB.ItemIndex := 1; // Zeige Dateien
  FileSizeCombo.ItemIndex  := 1;
  FileSize.Value           := 1;
  SizeAuswahl.ItemIndex    := 1;
  FileSizeCombo.Enabled    := False;
  FileSize.Enabled         := False;
  DateiCheckBox.Enabled    := True;
  DateiCheckBox.Checked    := False;
  Sizeauswahl.Enabled      := False;
  SizeAuswahl.ItemIndex    := 0;
  TextCB.Enabled           := True;
  TextCB.Text              := '';
  FileField.Text           := '';
  TextLabel.Enabled        := True;
  DirCheckbox.Checked      := True;
  HiddenCheckbox.State     := cbChecked;
  DatumCheckBox.Checked    := False;
  AlterCB.Checked          := False;
  AgeSizeEdit.Value        := 1;
  AgeAuswahl.ItemIndex     := 1; // Tag(e)
  SizeAuswahl.ItemIndex    := 1; // KByte
  SearchMinDate.DateTime   := Now - 31;
  SearchMaxDate.DateTime   := Now;
  UmbenennenCB.Checked     := False;
  FileField.SetFocus;

  if FreePDF64_Form.QuellLabel.Color = clGradientActiveCaption then
  begin
    Links := True;
    Rechts := False;
    SearchField.Text := ExcludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName);
    if Length(SearchField.Text) = 2 then
      SearchField.Text := IncludeTrailingBackslash(SearchField.Text);
  end else
  begin
    Rechts := True;
    Links := False;
    SearchField.Text := ExcludeTrailingBackslash(FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName);
    if Length(SearchField.Text) = 2 then
      SearchField.Text := IncludeTrailingBackslash(SearchField.Text);
  end;

  Btn_4.Enabled := True;
  Btn_4.ShowHint := True;

  // Ist die Suche_Form nun sichtbar?
  if Self.Visible then
  begin
    PanelBottom.Visible := False;
    StatusBar1.Visible  := False;
  end;
end;

// Fragezeichen: Hilfe für die Suchfunktionen
procedure TSuche_Form.InfoClick(Sender: TObject);
begin
  Suche_Info.Position := poMainFormCenter;
  Suche_Info.Memo1.Lines.Text :=
    'Suchen nach:' + #13 +
    '- Ein Stern * für eine beliebige Anzahl Zeichen' + #13 +
    '- Beispiel: Test* findet u.a.: Testlauf.docx, Test1.ini, Testdatei.prn, testhost.dll, usw.' + #13 +
    '- Beispiel: *Test* findet u.a.: applatest.xml, Austesten.xls, TranslateString.dcu, usw.' + #13 +
    '- Beispiel: Test ohne * findet nur: Test' + #13 + #13 +
    '- Ein Fragezeichen ? steht für ein beliebiges Zeichen. Mehrere Fragezeichen ? stehen für: von - bis' + #13 +
    '- Beispiel: Test?.log findet u.a.: Test1.log, Test8.log, usw.' + #13 +
    '- Beispiel: Test??.log findet u.a.: Test1.log, Test8.log, TestA3.log, Test45.log, usw.' + #13 + #13 +
    '- Mehrere Suchmasken müssen direkt durch das Pipe-Zeichen | getrennt eingegeben werden' + #13 +
    '- Beispiel: Lights at the*|Lake* findet u.a.: Lights at the Night Circus.jpg sowie Lake Mist.txt, usw.' + #13 +
    '- Beispiel: *.pdf|*.prn findet alle Dateien mit der Endung pdf und prn.' + #13 + #13 +
    'Versteckt+System' + #13 +
    '- [✓] Zeigt auch alle Datei(en)/Verzeichnis(se) an mit dem Attribut Hidden (H) und System (S)' + #13 +
    '- [-] Es werden zusätzlich alle Dateiattribute zum markiertem Eintrag angezeigt' + #13 +
    '- Dateiattribute: Archive [A], Hidden [H], ReadOnly [R], System [S], Directory [D]' + #13 +#13 +
    'Text suchen:' + #13 +
    '- Läßt sich nur bei "Zeige nur Dateien" nutzen' + #13 + #13 +
    'Suchergebnis:' + #13 +
    '- Angezeigt werden sortiert Datei(en) zuerst, Verzeichnis(se) zuletzt' + #13 +
    '- Zur Suche die Checkbox "Suche im Suchergebnis" anklicken (oder F2) und dann einfach' + #13 +
    '  Suchbegriff in Suchfeld unten links eingeben' + #13 +
    '- Alt+linker Mausklick öffnet markierte Datei des Suchergebnisses' + #13 +
    '- Rechter Mausklick öffnet Standard-Kontextmenü der markierten Datei/Verzeichnis' + #13 +
    '- Doppelklick mit der Maus geht direkt im Hauptfenster zur markierten Datei/Verzeichnis' + #13 +
    '- Strg+A markiert alle Dateien des Suchergebnisses';

  Suche_Info.ShowModal;
end;


procedure TSuche_Form.Kopieren1Click(Sender: TObject);
begin
  Btn_2.Click;
end;

function TextHoehe(Font: TFont; Text: String): Integer;
var
  b: TBitMap;
begin
  b := TBitMap.Create;
  b.Canvas.Font := Font;
  Result := b.Canvas.TextHeight(Text);
  b.Free;
end;

// Ausgabe Consolelog -> Memofenster
procedure GetDosOutput(Output: TMemo; CommandLine: String; Work: String);
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: Array [0 .. 255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: String;
  Handle: Boolean;
begin
  // Memo-Inhalt-Schriftfarbe auf Weiss setzen
  FreePDF64_Form.Memo1.Font.Color := clWhite;
  with SA do
  begin
    nLength := Sizeof(SA);
    bInheritHandle := True;
    lpSecurityDescriptor := NIL;
  end;
  CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
  try
    with SI do
    begin
      FillChar(SI, Sizeof(SI), 0);
      cb := Sizeof(SI);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
      wShowWindow := SW_HIDE;
      hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
      hStdOutput := StdOutPipeWrite;
      hStdError := StdOutPipeWrite;
    end;
    WorkDir := Work;
    Handle := CreateProcess(NIL, pchar('cmd.exe /C ' + CommandLine), NIL, NIL,
      True, 0, NIL, pchar(WorkDir), SI, PI);
    CloseHandle(StdOutPipeWrite);
    if Handle then
      try
        repeat
          WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
          if WasOK and (BytesRead > 0) then
          begin
            Buffer[BytesRead] := #0;
            Output.SelStart := Output.GetTextLen;
            Output.SelLength := 0;
            Output.SelText := Buffer;
          end;
        until (not WasOK) or (BytesRead = 0);
        WaitForSingleObject(PI.hProcess, INFINITE);
      finally
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
      end;
  finally
    CloseHandle(StdOutPipeRead);
  end;
  // Memo-Inhalt-Schriftfarbe wieder auf Schwarz setzen
  FreePDF64_Form.Memo1.Font.Color := clBlack;
end;

// Datei-Info aufrufen
procedure TSuche_Form.Btn_0Click(Sender: TObject);
var
  i: Integer;
  Work, Befehlszeile, s: String;
begin
  Info_Anzeigen := True;

  if ListBox1.Count = 0 then
    Exit;

  FreePDF64_Form.FavClose;
  FreePDF64_Form.Memo1.Clear;

  if not FileExists(ExifTool) then
  begin
    MessageDlgCenter('Achtung: Die Datei "exiftool.exe" fehlt im Ordner "' +
      IncludeTrailingBackslash(Einstellungen_Form.Edit8.Text) + '"!',
      mtError, [mbOk]);
    Exit;
  end;

  for i := 0 to ListBox1.Count - 1 do
  begin
    if ListBox1.Selected[i] then
    begin
      s := ListBox1.Items.Strings[i];
      // Prüfe, ob das erste Zeichen ein [ ist - und entfernen
      if Pos('[', s) <> 0 then
        Delete(s, 1, 1);
      // Prüfe, ob das letzte Zeichen ein ] ist - und entfernen
      if s[Length(s)] = ']' then
        Delete(s, Length(s), 1);

      Work := SearchField.Text;
      FreePDF64_Form.PanelOverPrgB.Visible := True;
      FreePDF64_Form.PanelOverPrgB.Caption := s;
      Befehlszeile := ExifTool + ' -L ' + GE + ' -g1 -charset filename=cp1252 -a -All:All -e "' + s + '"';
    end;
  end;
  if ListBox1.SelCount = 0 then
  begin
    MessageDlgCenter('Datei-Informationen anzeigen: Bitte EINE Datei auswählen!', mtInformation, [mbOk]);
    Exit;
  end;

  FreePDF64_Form.Show;
  FreePDF64_Form.BringToFront;
  Suche_Form.WindowState := wsMinimized;

  // DOS-Ausgabe nach Memo1
  GetDosOutput(FreePDF64_Form.Memo1, Befehlszeile, Work);
  // Zur ersten Memo-Zeile gehen...
  FreePDF64_Form.Memo1.Perform(EM_LineScroll, 0, -FreePDF64_Form.Memo1.Lines.Count - 1);

  if FreePDF64_Form.Memo1.Lines.Count > 0 then
  begin
    FreePDF64_Form.PDFPanel.Left   := 0;
    FreePDF64_Form.PDFPanel.Top    := 0;
    FreePDF64_Form.PDFPanel.Width  := FreePDF64_Form.ClientWidth;
    FreePDF64_Form.PDFPanel.Height := FreePDF64_Form.ClientHeight - FreePDF64_Form.ToolBar1.Height;
    FreePDF64_Form.PDFPanel.BringToFront;
    // Buttons unsichtbar machen...
    FreePDF64_Form.PDF_Erstellung.Visible := False;
    FreePDF64_Form.FormatBtn.Visible := False;
    FreePDF64_Form.PanelBottom.Visible := False;
  end;

  FreePDF64_Form.MemoBtn.Visible := True;
  Info_Anzeigen := False;
end;

// Im Editor öffnen
procedure TSuche_Form.Btn_1Click(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  if ListBox1.SelCount = 0 then
    Exit;

  try
    for i := 0 to ListBox1.Count - 1 do
    begin
      if ListBox1.Selected[i] then
      begin
        s := ListBox1.Items.Strings[i];
        // Prüfe, ob das erste Zeichen ein [ ist - und entfernen
        if Pos('[', s) <> 0 then
          Delete(s, 1, 1);
        // Prüfe, ob das letzte Zeichen ein ] ist - und entfernen
        if s[Length(s)] = ']' then
          Delete(s, Length(s), 1);

        if DirectoryExists(s) then
        begin
          if Einstellungen_Form.SystemklangCB.Checked then
            PlaySoundFile(ExtractFilePath(Application.ExeName) +
              'sounds\standard.wav');
          MessageDlgCenter('Keine Datei(en) ausgewählt!',
            mtInformation, [mbOk]);
          Exit;
        end;
        // Der interne Editor (Notepad) oder der in die FreePDF64.ini eingetragene wird aufgerufen...
        if Einstellungen_Form.Edit2.Text = '' then
          Einstellungen_Form.Edit2.Text := 'notepad.exe';
        ShellExecute(Application.Handle, 'open',
          pchar(Einstellungen_Form.Edit2.Text), pchar(' "' + s + '"'), NIL,
          SW_SHOWNORMAL)
      end;
    end;
  except
    MessageBox(0, 'Anzeigefehler', 'Problem', 16);
    Exit;
  end;
end;

// Anzeigen des Änderungsdatums und Änderungsuhrzeit einer Datei
function DateSizeOfFile(FileName: String): String;
var
  Rec: TSearchRec;
begin
  if FindFirst(FileName, faAnyFile and not faDirectory, Rec) = 0 then
  begin
    FindClose(Rec);
    Result := DateTimeToStr(Rec.TimeStamp);
  end else
    Result := '';
end;

// Suchefenster-Inhalt speichern in neue Textdatei...
procedure TSuche_Form.SuchergebnisBtnClick(Sender: TObject);
var
  f: TextFile;
  i: Integer;
  tmp, s: String;
begin
  if ListBox1.Count = 0 then
    Exit;

  s := StatusBar1.Panels[0].Text;

  StatusBar1.Panels[0].Text := '';
  StatusBar1.Panels[1].Text := '';

  AssignFile(f, ExtractFilePath(Application.ExeName) +
    'FreePDF64-Suchergebnis.txt');
  Rewrite(f);
  // Überschriftszeilen
  WriteLn(f, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss - ', Now) + 'Ergebnis der FreePDF64-Suche'));
  WriteLn(f, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss - ', Now) + 'Suchen nach: ' + FileField.Text));
  if TextCB.Text <> '' then
    WriteLn(f, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss - ', Now) + 'Textsuche  : ' + TextCB.Text));
  if DirCheckbox.Checked then
    WriteLn(f, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss - ', Now) + 'Suchen in: ' + SearchField.Text + ' (inkl. Unterverzeichnisse)'))
  else
    WriteLn(f, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss - ', Now) + 'Suchen in: ' + SearchField.Text + ' (ohne Unterverzeichnisse)'));

  WriteLn(f, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss - ', Now) + s));

  for i := 0 to ListBox1.Count - 1 do
  begin
    tmp := ListBox1.Items.Strings[i];
    WriteLn(f, tmp);
  end;

  WriteLn(f, '');
  CloseFile(f);
  StatusBar1.Panels[0].Text := 'Datei "FreePDF64-Suchergebnis.txt" liegt nun unter: ' + ExtractFilePath(Application.ExeName);

  if Einstellungen_Form.Edit2.Text = '' then
    Einstellungen_Form.Edit2.Text := 'notepad.exe';
  ShellExecute(Application.Handle, 'open', PChar(Einstellungen_Form.Edit2.Text), PChar(' "' + ExtractFilePath(Application.ExeName) +
               'FreePDF64-Suchergebnis.txt' + '"'), NIL, SW_SHOWNORMAL);
end;

procedure TSuche_Form.SuchpanelResize(Sender: TObject);
begin
  StatusBar1.Canvas.Font := StatusBar1.Font;
  StatusBar1.Panels[0].Width := ListBox1.Width - (Canvas.TextWidth(StatusBar1.Panels[1].Text) + 36);
end;

// Markierte Datei(en)/Verzeichnis(se) kopieren
procedure TSuche_Form.Btn_2Click(Sender: TObject);
var
  i: Integer;
  s, s1: String;
begin
  if ListBox1.SelCount = 0 then
    Exit;

  StatusBar1.Panels[0].Text := '';
  StatusBar1.Panels[1].Text := '';

  LMDShellSysBrowseDialog1.SelectedPath := '';
  LMDShellSysBrowseDialog1.Caption := 'In welches Verzeichnis soll kopiert werden?';
  LMDShellSysBrowseDialog1.InstructionText := 'Bitte das gewünschte Verzeichnis auswählen:';

  if LMDShellSysBrowseDialog1.Execute then
    s1 := LMDShellSysBrowseDialog1.SelectedPath
  else
    Exit;

  for i := 0 to ListBox1.Count - 1 do
    if ListBox1.Selected[i] then
    begin
      s := ListBox1.Items.Strings[i];
      // Prüfe, ob das erste Zeichen ein [ ist - und entfernen
      if Pos('[', s) <> 0 then
        Delete(s, 1, 1);
      // Prüfe, ob das letzte Zeichen ein ] ist - und entfernen
      if s[Length(s)] = ']' then
        Delete(s, Length(s), 1);

      if DirectoryExists(s) then
        if UmbenennenCB.Checked then
          CopyFileEx(s, IncludeTrailingBackslash(s1) + ExtractFileName(s), True)
        else
          CopyFileEx(s, IncludeTrailingBackslash(s1) + ExtractFileName(s), False)
      else if UmbenennenCB.Checked then
        CopyFileEx(pchar(s), pchar(IncludeTrailingBackslash(s1) + ExtractFileName(s)), True)
      else
        CopyFileEx(pchar(s), pchar(IncludeTrailingBackslash(s1) + ExtractFileName(s)), False);
      StatusBar1.Panels[0].Text := 'Kopiervorgang wird durchgeführt...'
    end;
  ListBox1.ClearSelection;
  if ListBox1.Count > 0 then
    ListBox1.Selected[0] := True;
  StatusBar1.Panels[0].Text := 'Kopiervorgang ist fertig!'
end;

// Erstes und letztes Zeichen entfernen
function RemoveFirstAndLastChar(const s: string): string;
begin
  if Length(s) > 1 then
    Result := Copy(s, 2, Length(s) - 2)
  else
    Result := '';
  // Wenn der String nur ein Zeichen oder leer ist, gibt es nichts zu entfernen
end;

// Größe der Datei ermitteln
function GetFileSize(const FileName: string): Int64; // auch Hidden
var
  SearchRec: TSearchRec;
begin
  Result := -1; // Initialisiere mit -1, falls Datei nicht gefunden wird
  if FindFirst(FileName, faAnyFile, SearchRec) = 0 then
  begin
    try
      Result := SearchRec.Size;
    finally
      FindClose(SearchRec);
    end;
  end;
end;

// Abfrage auf Attribute (Dateien und Verzeichnisse)
function GetFileAttributes(const FileName: string): TFileAttributes;
var
  srec: TSearchRec;
  faReadOnly, faHidden, faArchive: Integer;
begin
  faReadOnly := $00000001;
  faHidden   := $00000002;
  faArchive  := $00000020;

  Result := [];

  if FindFirst(FileName, faAnyFile, srec) = 0 then
  begin
    try
      // allgemeine Attribute
      if (srec.Attr and faReadOnly)  <> 0 then Result := Result + [ReadOnly];
      if (srec.Attr and faHidden)    <> 0 then Result := Result + [Hidden];
      if (srec.Attr and faSysFile)   <> 0 then Result := Result + [SysFile];
      if (srec.Attr and faVolumeID)  <> 0 then Result := Result + [VolumeId];
      if (srec.Attr and faArchive)   <> 0 then Result := Result + [Archive];

      // Verzeichnisattribut
      if (srec.Attr and faDirectory) <> 0 then
        Result := Result + [Directory];

      // Kennzeichnung: beliebige Datei / Objekt
      if (srec.Attr and faAnyFile) <> 0 then
        Result := Result + [AnyFile];
    finally
      FindClose(srec);
    end;
  end;
end;

// Datum der Datei/Verzeichnis ermitteln
function GetFileLastWriteTime(const FileName: string): TDateTime;
var
  FileInfo: TShFileInfo;
  FileHandle: THandle;
  FileData: TWin32FindData;
  SystemTime: TSystemTime;
  LocalFileTime: TFileTime;
begin
  // Initialize the TShFileInfo structure
  ZeroMemory(@FileInfo, SizeOf(FileInfo));

  // Get the file handle
  FileHandle := FindFirstFile(PChar(FileName), FileData);
  if FileHandle <> INVALID_HANDLE_VALUE then
  begin
    try
      // Convert the file time to local file time
      FileTimeToLocalFileTime(FileData.ftLastWriteTime, LocalFileTime);
      // Convert the local file time to system time
      FileTimeToSystemTime(LocalFileTime, SystemTime);
      // Convert the system time to TDateTime
      Result := SystemTimeToDateTime(SystemTime);
    finally
      // Close the file handle
      CloseHandle(FileHandle);
//      Windows.FindClose(FileHandle);
    end;
  end
  else
    raise Exception.CreateFmt('File not found: %s', [FileName]);
end;

procedure TSuche_Form.ListBox1Click(Sender: TObject);
var
  i: Integer;
  s: String;
  d: TDateTime;
  at: String;
  fa: TFileAttributes;
begin
  SucheEdit.Visible      := False;
  AnzeigenPanel.Visible  := False;
  SuchergebnisCB.Checked := False;

  if ListBox1.Count = 0 then
    Exit;

  if ListBox1.SelCount > 0 then
    StatusBar1.Panels[1].Text := 'Markiert: ' + IntToStr(ListBox1.SelCount);

  for i := 0 to ListBox1.Count - 1 do
    if ListBox1.Selected[i] then
    begin
      if FileExists(ListBox1.Items.Strings[i]) then
      begin
        d := GetFileLastWriteTime(ListBox1.Items.Strings[i]);

        // Größenausgabe formatieren
        s := FloatToStrF(GetFileSize(ListBox1.Items.Strings[i]),
                         ffNumber, 15, 0) + ' Bytes';

        if HiddenCheckBox.State = cbGrayed then
        begin
          fa := GetFileAttributes(ListBox1.Items.Strings[i]);

          at := '';
          if ReadOnly  in fa then at := at + 'R';
          if Archive   in fa then at := at + 'A';
          if Hidden    in fa then at := at + 'H';
          if SysFile   in fa then at := at + 'S';
          if Directory in fa then at := at + 'D';

          StatusBar1.Panels[0].Text :=
            FormatDateTime('dd.mm.yyyy hh:mm:ss', d) +
            ', ' + s +
            ' (Attribute: ' + at + ')';

          if at = '' then
            StatusBar1.Panels[0].Text :=
              FormatDateTime('dd.mm.yyyy hh:mm:ss', d) +
              ', ' + s;
        end
        else
          StatusBar1.Panels[0].Text :=
            FormatDateTime('dd.mm.yyyy hh:mm:ss', d) +
            ', ' + s;
      end
      else if DirectoryExists(RemoveFirstAndLastChar(ListBox1.Items.Strings[i])) then
      begin
        d := GetFileLastWriteTime(
               RemoveFirstAndLastChar(ListBox1.Items.Strings[i]));

        if HiddenCheckBox.State = cbGrayed then
        begin
          fa := GetFileAttributes(
                  RemoveFirstAndLastChar(ListBox1.Items.Strings[i]));

          at := '';
          if ReadOnly  in fa then at := at + 'R';
          if Archive   in fa then at := at + 'A';
          if Hidden    in fa then at := at + 'H';
          if SysFile   in fa then at := at + 'S';
          if Directory in fa then at := at + 'D';

          StatusBar1.Panels[0].Text :=
            FormatDateTime('dd.mm.yyyy hh:mm:ss', d) +
            ' (Attribute: ' + at + ')';

          if at = '' then
            StatusBar1.Panels[0].Text :=
              FormatDateTime('dd.mm.yyyy hh:mm:ss', d);
        end
        else
          StatusBar1.Panels[0].Text :=
            FormatDateTime('dd.mm.yyyy hh:mm:ss', d);
      end;
    end;
end;

// Markierte Datei(en)/Verzeichnis(se) verschieben
procedure TSuche_Form.Btn_3Click(Sender: TObject);
var
  i: Integer;
  s, s1: String;
begin
  if ListBox1.SelCount = 0 then
    Exit;

  StatusBar1.Panels[0].Text := '';
  StatusBar1.Panels[1].Text := '';

  LMDShellSysBrowseDialog1.SelectedPath := '';
  LMDShellSysBrowseDialog1.Caption := 'In welches Verzeichnis soll verschoben werden?';
  LMDShellSysBrowseDialog1.InstructionText := 'Bitte das gewünschte Verzeichnis auswählen:';

  if LMDShellSysBrowseDialog1.Execute then
    s1 := LMDShellSysBrowseDialog1.SelectedPath
  else
    Exit;

  for i := 0 to ListBox1.Count - 1 do
    if ListBox1.Selected[i] then
    begin
      s := ListBox1.Items.Strings[i];
      // Prüfe, ob das erste Zeichen ein [ ist - und entfernen
      if Pos('[', s) <> 0 then
        Delete(s, 1, 1);
      // Prüfe, ob das letzte Zeichen ein ] ist - und entfernen
      if s[Length(s)] = ']' then
        Delete(s, Length(s), 1);

      if DirectoryExists(s) then
      begin
        if UmbenennenCB.Checked then
          MoveFileEx(s, IncludeTrailingBackslash(s1) + ExtractFileName(s), True)
        else
          MoveFileEx(s, IncludeTrailingBackslash(s1) + ExtractFileName(s), False);
        ListBox1.DeleteSelected;
        ListBox1.ClearSelection;
        if ListBox1.Count > 0 then
          ListBox1.Selected[0] := True;
        Exit;
      end
      else if UmbenennenCB.Checked then
        MoveFileEx(pchar(s), pchar(IncludeTrailingBackslash(s1) + ExtractFileName(s)), True)
      else
        MoveFileEx(pchar(s), pchar(IncludeTrailingBackslash(s1) + ExtractFileName(s)), False);
      StatusBar1.Panels[0].Text := 'Bewegenvorgang durchgeführt...';
    end;

  ListBox1.DeleteSelected;
  ListBox1.ClearSelection;
  if ListBox1.Count > 0 then
    ListBox1.Selected[0] := True;
  StatusBar1.Panels[0].Text := 'Bewegenvorgang ist fertig!';
end;

procedure TSuche_Form.Timer1Timer(Sender: TObject);
var
  DateiAnzahl: Integer;
  VerzeichnisAnzahl: Integer;
  StatusText: string;
begin
  // Timer zunächst ausschalten.
  Timer1.Enabled := False;

  // =========================================================
  // SUCHE LÄUFT NOCH
  //
  // Der Start-Button ist während der Suche deaktiviert.
  // In diesem Fall nur den aktuellen Pfad anzeigen.
  // =========================================================
  if not StartSearchButton.Enabled then
  begin
    StatusBar1.Panels[0].Text := Anzeige;

    // Timer wieder aktivieren, damit der nächste
    // aktuelle Suchpfad angezeigt werden kann.
    Timer1.Enabled := True;

    Exit;
  end;

  // =========================================================
  // SUCHE IST BEENDET ODER WURDE ABGEBROCHEN
  // =========================================================

  // ---------------------------------------------------------
  // Anzahl Verzeichnisse
  // ---------------------------------------------------------
  VerzeichnisAnzahl := Zaehler;

  // ---------------------------------------------------------
  // Anzahl Dateien
  //
  // ListBox1 enthält am Ende:
  //
  //   Verzeichnisse + Dateien
  //
  // Zaehler enthält:
  //
  //   Verzeichnisse
  //
  // Deshalb:
  //
  //   Dateien = ListBox1.Count - Zaehler
  // ---------------------------------------------------------
  DateiAnzahl :=
    ListBox1.Count - VerzeichnisAnzahl;

  // Sicherheit gegen negative Werte
  if VerzeichnisAnzahl < 0 then
    VerzeichnisAnzahl := 0;

  if DateiAnzahl < 0 then
    DateiAnzahl := 0;

  // =========================================================
  // STATUS-TEXT ERSTELLEN
  // =========================================================
  case FilesFoldersCB.ItemIndex of

    // =======================================================
    // Dateien und Verzeichnisse
    // =======================================================
    0:
      begin
        if DateiCheckBox.Checked then
        begin
          // Nur Dateien
          StatusText :=
            '[' +
            IntToStr(DateiAnzahl) +
            ' Datei(en) gefunden]';
        end
        else
        begin
          // Dateien und Verzeichnisse
          StatusText :=
            '[' +
            IntToStr(DateiAnzahl) +
            ' Datei(en) und ' +
            IntToStr(VerzeichnisAnzahl) +
            ' Verzeichnis(se) gefunden]';
        end;
      end;

    // =======================================================
    // Nur Dateien
    // =======================================================
    1:
      begin
        StatusText :=
          '[' +
          IntToStr(DateiAnzahl) +
          ' Datei(en) gefunden]';
      end;

    // =======================================================
    // Nur Verzeichnisse
    // =======================================================
    2:
      begin
        StatusText :=
          '[' +
          IntToStr(VerzeichnisAnzahl) +
          ' Verzeichnis(se) gefunden]';
      end;

  else
    begin
      StatusBar1.Panels[0].Text := '';
      Exit;
    end;

  end;

  // =========================================================
  // ABGEBROCHEN?
  // =========================================================
  if StopSuche then
    StatusText :=
      StatusText +
      ' - Suche abgebrochen';

  // =========================================================
  // GESAMTE SUCHDAUER STOPPEN
  //
  // Die Stoppuhr wurde beim Klick auf den Start-Button
  // gestartet.
  // =========================================================
  if SearchStopwatch.IsRunning then
    SearchStopwatch.Stop;

  // =========================================================
  // GESAMTE SUCHDAUER ANZEIGEN
  // =========================================================
  StatusText :=
    StatusText + Format('   |  Suchdauer: %.2f s', [SearchStopwatch.Elapsed.TotalSeconds]);

  // =========================================================
  // ENDGÜLTIGE STATUSANZEIGE
  // =========================================================
  StatusBar1.Panels[0].Text := StatusText;
end;

function StrAlloc1(Size: Cardinal): PAnsiChar;
begin
  Inc(Size, SizeOf(Cardinal));        // Die Größe des zu reservierenden Platzes um 4 Bytes erhöhen
  GetMem(Result, Size);               // Speicher reservieren .. soviel wie der String lang ist + 4 Bytes um die Länges des Strings zu speichern
  Cardinal(Pointer(Result)^) := Size; // Die Größe des Speicherplatzes am Anfang des reservierten Platzes speichern
  Inc(Result, SizeOf(Cardinal));      // Den Pointer (PChar) hinter die Größenangabe verschieben
end;

// Textsuche in Datei(en)
function ScanFile(const FileName, forString: string; caseSensitive: Boolean): Longint;
const
  BufferSize = 32768; // 32 KB
var
  F: TFileStream;
  Buffer: TBytes;
  ReadBytes: Integer;
  SearchFor: string;
  Haystack: string;
  PosFound: Integer;
  Overlap: Integer;
begin
  Result := -1;

  if (forString = '') or (FileName = '') then
    Exit;

  // Suchstring vorbereiten
  if caseSensitive then
    SearchFor := forString
  else
    SearchFor := UpperCase(forString);

  // Datei öffnen (ReadOnly, aber löschbar!)
  F := nil;
  try
    try
      F := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      SetLength(Buffer, BufferSize);
      Overlap := Length(SearchFor);

      while True do
      begin
        ReadBytes := F.Read(Buffer[0], BufferSize);
        if ReadBytes = 0 then
          Break;

        // Puffer in String konvertieren
        SetString(Haystack, PAnsiChar(@Buffer[0]), ReadBytes);

        if not caseSensitive then
          Haystack := UpperCase(Haystack);

        PosFound := Pos(SearchFor, Haystack);

        if PosFound > 0 then
        begin
          Result := F.Position - ReadBytes + PosFound - 1;
          Break;
        end;

        // Überlappung für Suchstring am Blockende
        if ReadBytes = BufferSize then
          F.Position := F.Position - Overlap;
      end;
    except
      // Datei kann nicht gelesen werden (z.B. Zugriff verweigert,
      // Datei inzwischen gelöscht/gesperrt oder Lesefehler):
      // Datei einfach überspringen und Suche fortsetzen.
      Result := -1;
    end;
  finally
    F.Free;
  end;
end;

// Rekursiv suchen mit FindFirst...
// Der 2te Parameter sind die Dateiattribute:
// faReadOnly      Schreibgeschützte Datei
// faHidden        Versteckte Datei
// faSysFile       Systemdatei
// faVolumeID      Laufwerks-ID-Datei
// faDirectory     Verzeichnis
// faArchive       Archivdatei
// faAnyFile       Beliebige Datei
// Der Parameter gibt an, welche Dateien mit welchem Dateiattribut gesucht werden sollen.
// Auch kann auf diese Weise nach Verzeichnissen gesucht werden können.

// Dem dritten Parameter werden letztendlich bei einem Sucherfolg die Dateiinformationen übergeben:
// type
// TSearchRec = record
// Time: Integer;
// Size: Integer;
// Attr: Integer;
// Name: TFileName;
// ExcludeAttr: Integer;
// FindHandle: THandle;
// FindData: TWin32FindData; z.B. SR.FindData.cFileName
// end;

// ============================================================================
// SUCHE OHNE DATUMS- UND GRÖSSENABFRAGE
// ============================================================================
// ============================================================================
// SUCHE OHNE DATUMS- UND GRÖSSENABFRAGE
// ============================================================================
procedure GetFilesInDirectory(Directory: string; const Mask: string;
  List: TStrings; WithSubDirs, ClearList: Boolean);
var
  DirectoryResults: TStringList;
  FileResults: TStringList;

  FirstResultsShown: Integer;
  ResultsPublishedOnStop: Boolean;

  LastStatusUpdate: UInt64;
  MaskArray: TStringDynArray;

  procedure PublishResults;
  var
    I: Integer;
  begin
    List.BeginUpdate;
    try
      List.Clear;

      for I := 0 to DirectoryResults.Count - 1 do
        List.Add(DirectoryResults[I]);

      for I := 0 to FileResults.Count - 1 do
        List.Add(FileResults[I]);
    finally
      List.EndUpdate;
    end;

    Application.ProcessMessages;
  end;

  procedure PublishResultsOnStop;
  begin
    if ResultsPublishedOnStop then
      Exit;

    ResultsPublishedOnStop := True;
    PublishResults;
  end;

  procedure UpdateSearchStatus(const CurrentDirectory: string);
  var
    NowTick: UInt64;
  begin
    NowTick := GetTickCount64;

    if (LastStatusUpdate = 0) or
       (NowTick - LastStatusUpdate >= 100) then
    begin
      LastStatusUpdate := NowTick;
      Anzeige := CurrentDirectory;
      Suche_Form.Timer1.Enabled := True;
    end;
  end;

  function SearchShouldStop(const CurrentDirectory: string): Boolean;
  begin
    UpdateSearchStatus(CurrentDirectory);

    Application.ProcessMessages;

    Result := StopSuche;

    if Result then
      PublishResultsOnStop;
  end;

  function FindFirstExW(const Path: string;
    var Data: WIN32_FIND_DATAW): THandle;
  begin
    Result :=
      FindFirstFileExW(
        PChar(Path),
        FindExInfoBasic,
        @Data,
        FindExSearchNameMatch,
        nil,
        0
      );
  end;

  function FormatSearchResult(const FullPath: string;
    IsDirectory: Boolean): string;
  begin
    if IsDirectory then
      Result := '[' + FullPath + ']'
    else
      Result := FullPath;
  end;

  procedure ShowSearchResult(const S: string);
  begin
    if FirstResultsShown >= 100 then
      Exit;

    Inc(FirstResultsShown);

    List.Add(S);

    Application.ProcessMessages;

    if StopSuche then
      PublishResultsOnStop;
  end;

  procedure AddDirectoryResult(const FullPath: string);
  var
    S: string;
  begin
    if StopSuche then
      Exit;

    S := FormatSearchResult(FullPath, True);

    DirectoryResults.Add(S);

    ShowSearchResult(S);

    Inc(Zaehler);
  end;

  procedure AddFileResult(const FullPath: string);
  var
    S: string;
  begin
    if StopSuche then
      Exit;

    S := FormatSearchResult(FullPath, False);

    FileResults.Add(S);

    ShowSearchResult(S);
  end;

  procedure ScanDir(const Dir: string);
  var
    h: THandle;
    fd: WIN32_FIND_DATAW;

    ShowDirs: Boolean;
    ShowFiles: Boolean;

    SearchText: string;
    SearchTextUpper: string;
    HasSearchText: Boolean;

    NameStr: string;
    FullPath: string;

    IsDir: Boolean;
    Maske: string;

    SubDirs: TStringList;
    I: Integer;

    DirectoryMatchesMask: Boolean;

    ScanResult: Longint;

    HiddenAndSystem: Boolean;
  begin
    if SearchShouldStop(Dir) then
      Exit;

    SearchText := Suche_Form.TextCB.Text;
    HasSearchText := SearchText <> '';
    if HasSearchText then
      SearchTextUpper := UpperCase(SearchText)
    else
      SearchTextUpper := '';

    ShowDirs :=
      (Suche_Form.FilesFoldersCB.ItemIndex = 0) or
      (Suche_Form.FilesFoldersCB.ItemIndex = 2);

    ShowFiles :=
      (Suche_Form.FilesFoldersCB.ItemIndex = 0) or
      (Suche_Form.FilesFoldersCB.ItemIndex = 1);

    h := FindFirstExW(Dir + '*.*', fd);

    if h <> INVALID_HANDLE_VALUE then
    try
      repeat
        if SearchShouldStop(Dir) then
          Break;

        NameStr := fd.cFileName;

        if (NameStr <> '.') and
           (NameStr <> '..') then
        begin
          IsDir :=
            (fd.dwFileAttributes and
             FILE_ATTRIBUTE_DIRECTORY) <> 0;

          FullPath := Dir + NameStr;

          // --------------------------------------------------------------
          // HIDDEN + SYSTEM
          //
          // cbUnchecked:
          //   HIDDEN + SYSTEM gleichzeitig -> nicht anzeigen
          //
          // cbChecked:
          //   alles anzeigen
          //
          // cbGrayed:
          //   wie im Original ebenfalls alles anzeigen
          // --------------------------------------------------------------
          HiddenAndSystem :=
            ((fd.dwFileAttributes and FILE_ATTRIBUTE_HIDDEN) <> 0) and
            ((fd.dwFileAttributes and FILE_ATTRIBUTE_SYSTEM) <> 0);

          if (Suche_Form.HiddenCheckbox.State = cbUnchecked) and
             HiddenAndSystem then
          begin
            // HIDDEN + SYSTEM wird nur bei cbUnchecked übersprungen.
          end
          else if IsDir and ShowDirs then
          begin
            DirectoryMatchesMask := False;

            for Maske in MaskArray do
            begin
              if SearchShouldStop(Dir) then
                Break;

              if MatchesMask(NameStr, Maske) then
              begin
                DirectoryMatchesMask := True;
                Break;
              end;
            end;

            if DirectoryMatchesMask and
               not StopSuche then
            begin
              if (not HasSearchText) or
                 (Pos(
                    SearchTextUpper,
                    UpperCase(NameStr)
                  ) > 0) then
              begin
                AddDirectoryResult(FullPath);
              end;
            end;
          end
          else if (not IsDir) and ShowFiles then
          begin
            for Maske in MaskArray do
            begin
              if SearchShouldStop(Dir) then
                Break;

              if MatchesMask(NameStr, Maske) then
              begin
                if not HasSearchText then
                begin
                  AddFileResult(FullPath);
                end
                else
                begin
                  if StopSuche then
                    Break;

                  ScanResult :=
                    ScanFile(
                      FullPath,
                      SearchText,
                      False
                    );

                  if ScanResult = -2 then
                  begin
                    StopSuche := True;
                    PublishResultsOnStop;
                    Exit;
                  end;

                  if ScanResult >= 0 then
                  begin
                    if not StopSuche then
                      AddFileResult(FullPath);
                  end;
                end;

                Break;
              end;
            end;
          end;
        end;

      until StopSuche or
            not FindNextFileW(h, fd);

    finally
      CloseHandle(h);
    end;

    // ================================================================
    // UNTERVERZEICHNISSE
    // ================================================================
    if WithSubDirs and
       not StopSuche then
    begin
      SubDirs := TStringList.Create;
      try
        SubDirs.CaseSensitive := False;
        SubDirs.Sorted := True;

        h := FindFirstExW(Dir + '*.*', fd);

        if h <> INVALID_HANDLE_VALUE then
        try
          repeat
            if SearchShouldStop(Dir) then
              Break;

            NameStr := fd.cFileName;

            if ((fd.dwFileAttributes and
                 FILE_ATTRIBUTE_DIRECTORY) <> 0) and
               (NameStr <> '.') and
               (NameStr <> '..') then
            begin
              // ----------------------------------------------------------
              // Auch hier ausschließlich HIDDEN + SYSTEM prüfen.
              //
              // cbUnchecked -> H+S-Verzeichnis nicht durchsuchen
              // cbChecked    -> H+S-Verzeichnis durchsuchen
              // cbGrayed    -> H+S-Verzeichnis durchsuchen
              // ----------------------------------------------------------
              HiddenAndSystem :=
                ((fd.dwFileAttributes and FILE_ATTRIBUTE_HIDDEN) <> 0) and
                ((fd.dwFileAttributes and FILE_ATTRIBUTE_SYSTEM) <> 0);

              if (Suche_Form.HiddenCheckbox.State <> cbUnchecked) or
                 not HiddenAndSystem then
              begin
                SubDirs.Add(NameStr);
              end;
            end;

          until StopSuche or
                not FindNextFileW(h, fd);

        finally
          CloseHandle(h);
        end;

        for I := 0 to SubDirs.Count - 1 do
        begin
          if SearchShouldStop(Dir) then
            Break;

          ScanDir(
            IncludeTrailingPathDelimiter(
              Dir + SubDirs[I]
            )
          );

          if StopSuche then
            Break;
        end;

      finally
        SubDirs.Free;
      end;
    end;

    UpdateSearchStatus(Dir);
  end;

var
  RootDirectory: string;
begin
  Zaehler := 0;

  FirstResultsShown := 0;
  ResultsPublishedOnStop := False;
  LastStatusUpdate := 0;
  MaskArray := SplitString(Mask, '|');

  DirectoryResults := TStringList.Create;
  FileResults := TStringList.Create;

  try
    FileResults.CaseSensitive := False;
    FileResults.Sorted := True;
    FileResults.Duplicates := dupIgnore;

    DirectoryResults.CaseSensitive := False;
    DirectoryResults.Duplicates := dupIgnore;

    if ClearList then
      List.Clear;

    if Directory = '\' then
      Exit;

    RootDirectory :=
      IncludeTrailingPathDelimiter(Directory);

    ScanDir(RootDirectory);

    // Falls noch kein sofortiger Abbruch-Publish erfolgt ist:
    PublishResults;

  finally
    DirectoryResults.Free;
    FileResults.Free;
  end;
end;

// ============================================================================
// DATE / SIZE
// ============================================================================
procedure GetFilesInDirectory_DateSize(Directory: string; const Mask: string;
  List: TStrings; MinMaxFileSize: Int64; WithSubDirs, ClearList: Boolean);
var
  DirectoryResults: TStringList;
  FileResults: TStringList;

  FirstResultsShown: Integer;
  ResultsPublishedOnStop: Boolean;

  LastStatusUpdate: UInt64;
  MaskArray: TStringDynArray;

  procedure PublishResults;
  var
    I: Integer;
  begin
    List.BeginUpdate;
    try
      List.Clear;

      for I := 0 to DirectoryResults.Count - 1 do
        List.Add(DirectoryResults[I]);

      for I := 0 to FileResults.Count - 1 do
        List.Add(FileResults[I]);
    finally
      List.EndUpdate;
    end;

    Application.ProcessMessages;
  end;

  procedure PublishResultsOnStop;
  begin
    if ResultsPublishedOnStop then
      Exit;

    ResultsPublishedOnStop := True;
    PublishResults;
  end;

  procedure UpdateSearchStatus(const CurrentDirectory: string);
  var
    NowTick: UInt64;
  begin
    NowTick := GetTickCount64;

    if (LastStatusUpdate = 0) or
       (NowTick - LastStatusUpdate >= 100) then
    begin
      LastStatusUpdate := NowTick;
      Anzeige := CurrentDirectory;
      Suche_Form.Timer1.Enabled := True;
    end;
  end;

  function SearchShouldStop(const CurrentDirectory: string): Boolean;
  begin
    UpdateSearchStatus(CurrentDirectory);

    Application.ProcessMessages;

    Result := StopSuche;

    if Result then
      PublishResultsOnStop;
  end;

  function FindFirstExW(const Path: string;
    var Data: WIN32_FIND_DATAW): THandle;
  begin
    Result :=
      FindFirstFileExW(
        PChar(Path),
        FindExInfoBasic,
        @Data,
        FindExSearchNameMatch,
        nil,
        0
      );
  end;

  function FormatSearchResult(const FullPath: string;
    IsDirectory: Boolean): string;
  begin
    if IsDirectory then
      Result := '[' + FullPath + ']'
    else
      Result := FullPath;
  end;

  function FileTimeToDateTimeValue(
    const FileTime: TFileTime): TDateTime;
  var
    LocalFileTime: TFileTime;
    SystemTime: TSystemTime;
  begin
    Result := 0;

    if FileTimeToLocalFileTime(
      FileTime,
      LocalFileTime
    ) then
    begin
      if FileTimeToSystemTime(
        LocalFileTime,
        SystemTime
      ) then
      begin
        Result := SystemTimeToDateTime(SystemTime);
      end;
    end;
  end;

  function GetFileSize64(
    const Data: WIN32_FIND_DATAW): Int64;
  begin
    Result :=
      (Int64(Data.nFileSizeHigh) shl 32) or
      Int64(Data.nFileSizeLow);
  end;

  procedure ShowSearchResult(const S: string);
  begin
    if FirstResultsShown >= 100 then
      Exit;

    Inc(FirstResultsShown);

    List.Add(S);

    Application.ProcessMessages;

    if StopSuche then
      PublishResultsOnStop;
  end;

  procedure AddDirectoryResult(const FullPath: string);
  var
    S: string;
  begin
    if StopSuche then
      Exit;

    S := FormatSearchResult(FullPath, True);

    DirectoryResults.Add(S);

    ShowSearchResult(S);

    Inc(Zaehler);
  end;

  procedure AddFileResult(const FullPath: string);
  var
    S: string;
  begin
    if StopSuche then
      Exit;

    S := FormatSearchResult(FullPath, False);

    FileResults.Add(S);

    ShowSearchResult(S);
  end;

  procedure ScanDir(const Dir: string);
  var
    h: THandle;
    fd: WIN32_FIND_DATAW;

    SearchTextUpper: string;

    ShowDirs: Boolean;
    ShowFiles: Boolean;

    CheckDate: Boolean;
    CheckSize: Boolean;
    CheckText: Boolean;

    SearchText: string;
    MinDate: TDateTime;
    MaxDate: TDateTime;

    FileSizeMode: Integer;
    CurrentFileSize: Int64;
    CurrentFileDate: TDateTime;

    NameStr: string;
    FullPath: string;
    Maske: string;

    IsDir: Boolean;
    DirectoryMatchesMask: Boolean;

    SubDirs: TStringList;
    I: Integer;

    DateOK: Boolean;
    SizeOK: Boolean;
    MaskOK: Boolean;

    ScanResult: Longint;

    HiddenAndSystem: Boolean;
  begin
    if SearchShouldStop(Dir) then
      Exit;

    SearchText := Suche_Form.TextCB.Text;
    CheckText := SearchText <> '';
    if CheckText then
      SearchTextUpper := UpperCase(SearchText)
    else
      SearchTextUpper := '';

    CheckDate := Suche_Form.DatumCheckBox.Checked;
    CheckSize := Suche_Form.DateiCheckBox.Checked;

    MinDate := Suche_Form.SearchMinDate.DateTime;
    MaxDate := Suche_Form.SearchMaxDate.DateTime;

    FileSizeMode := Suche_Form.FileSizeCombo.ItemIndex;

    ShowDirs :=
      (Suche_Form.FilesFoldersCB.ItemIndex = 0) or
      (Suche_Form.FilesFoldersCB.ItemIndex = 2);

    ShowFiles :=
      (Suche_Form.FilesFoldersCB.ItemIndex = 0) or
      (Suche_Form.FilesFoldersCB.ItemIndex = 1);

    h := FindFirstExW(Dir + '*.*', fd);

    if h <> INVALID_HANDLE_VALUE then
    try
      repeat
        if SearchShouldStop(Dir) then
          Break;

        NameStr := fd.cFileName;

        if (NameStr = '.') or
           (NameStr = '..') then
          Continue;

        IsDir :=
          (fd.dwFileAttributes and
           FILE_ATTRIBUTE_DIRECTORY) <> 0;

        FullPath := Dir + NameStr;

        // --------------------------------------------------------------
        // HIDDEN + SYSTEM
        // --------------------------------------------------------------
        HiddenAndSystem :=
          ((fd.dwFileAttributes and FILE_ATTRIBUTE_HIDDEN) <> 0) and
          ((fd.dwFileAttributes and FILE_ATTRIBUTE_SYSTEM) <> 0);

        // Nur cbUnchecked blendet H+S aus.
        // cbChecked und cbGrayed zeigen alles.
        if (Suche_Form.HiddenCheckbox.State = cbUnchecked) and
           HiddenAndSystem then
        begin
          Continue;
        end;

        // ===================================================
        // VERZEICHNIS
        // ===================================================
        if IsDir then
        begin
          if ShowDirs then
          begin
            DateOK := True;

            if CheckDate then
            begin
              CurrentFileDate :=
                FileTimeToDateTimeValue(
                  fd.ftLastWriteTime
                );

              DateOK :=
                (CompareDateTime(
                   CurrentFileDate,
                   MinDate
                 ) >= 0) and
                (CompareDateTime(
                   CurrentFileDate,
                   MaxDate
                 ) <= 0);
            end;

            if DateOK and
               not SearchShouldStop(Dir) then
            begin
              DirectoryMatchesMask := False;

              for Maske in MaskArray do
              begin
                if SearchShouldStop(Dir) then
                  Break;

                if MatchesMask(NameStr, Maske) then
                begin
                  DirectoryMatchesMask := True;
                  Break;
                end;
              end;

              if DirectoryMatchesMask and
                 not StopSuche then
              begin
                if (not CheckText) or
                   (Pos(
                      SearchTextUpper,
                       UpperCase(NameStr)
                    ) > 0) then
                begin
                  AddDirectoryResult(FullPath);
                end;
              end;
            end;
          end;
        end

        // ===================================================
        // DATEI
        // ===================================================
        else if ShowFiles then
        begin
          if CheckDate then
          begin
            CurrentFileDate :=
              FileTimeToDateTimeValue(
                fd.ftLastWriteTime
              );

            DateOK :=
              (CompareDateTime(
                 CurrentFileDate,
                 MinDate
               ) >= 0) and
              (CompareDateTime(
                 CurrentFileDate,
                 MaxDate
               ) <= 0);

            if not DateOK then
              Continue;
          end;

          if CheckSize then
          begin
            CurrentFileSize :=
              GetFileSize64(fd);

            case FileSizeMode of
              0:
                SizeOK :=
                  CurrentFileSize = MinMaxFileSize;

              1:
                SizeOK :=
                  CurrentFileSize > MinMaxFileSize;

              2:
                SizeOK :=
                  CurrentFileSize < MinMaxFileSize;
            else
              SizeOK := True;
            end;

            if not SizeOK then
              Continue;
          end;

          if SearchShouldStop(Dir) then
            Break;

          MaskOK := False;

          for Maske in MaskArray do
          begin
            if SearchShouldStop(Dir) then
              Break;

            if MatchesMask(NameStr, Maske) then
            begin
              MaskOK := True;
              Break;
            end;
          end;

          if StopSuche then
            Break;

          if not MaskOK then
            Continue;

          if CheckText then
          begin
            if StopSuche then
              Break;

            ScanResult :=
              ScanFile(
                FullPath,
                SearchText,
                False
              );

            if ScanResult = -2 then
            begin
              StopSuche := True;
              PublishResultsOnStop;
              Exit;
            end;

            if ScanResult < 0 then
              Continue;

            if StopSuche then
              Break;
          end;

          if not StopSuche then
            AddFileResult(FullPath);
        end;

      until StopSuche or
            not FindNextFileW(h, fd);

    finally
      CloseHandle(h);
    end;

    // ===================================================
    // UNTERVERZEICHNISSE
    // ===================================================
    if WithSubDirs and
       not StopSuche then
    begin
      SubDirs := TStringList.Create;
      try
        SubDirs.CaseSensitive := False;
        SubDirs.Sorted := True;

        h := FindFirstExW(Dir + '*.*', fd);

        if h <> INVALID_HANDLE_VALUE then
        try
          repeat
            if SearchShouldStop(Dir) then
              Break;

            NameStr := fd.cFileName;

            if ((fd.dwFileAttributes and
                 FILE_ATTRIBUTE_DIRECTORY) <> 0) and
               (NameStr <> '.') and
               (NameStr <> '..') then
            begin
              // Nur HIDDEN + SYSTEM gemeinsam wird bei cbUnchecked
              // vom rekursiven Durchsuchen ausgeschlossen.
              HiddenAndSystem :=
                ((fd.dwFileAttributes and FILE_ATTRIBUTE_HIDDEN) <> 0) and
                ((fd.dwFileAttributes and FILE_ATTRIBUTE_SYSTEM) <> 0);

              if (Suche_Form.HiddenCheckbox.State <> cbUnchecked) or
                 not HiddenAndSystem then
              begin
                SubDirs.Add(NameStr);
              end;
            end;

          until StopSuche or
                not FindNextFileW(h, fd);

        finally
          CloseHandle(h);
        end;

        for I := 0 to SubDirs.Count - 1 do
        begin
          if SearchShouldStop(Dir) then
            Break;

          ScanDir(
            IncludeTrailingPathDelimiter(
              Dir + SubDirs[I]
            )
          );

          if StopSuche then
            Break;
        end;

      finally
        SubDirs.Free;
      end;
    end;

    UpdateSearchStatus(Dir);
  end;

var
  RootDirectory: string;
begin
  Zaehler := 0;

  FirstResultsShown := 0;
  ResultsPublishedOnStop := False;
  LastStatusUpdate := 0;
  MaskArray := SplitString(Mask, '|');

  DirectoryResults := TStringList.Create;
  FileResults := TStringList.Create;

  try
    FileResults.CaseSensitive := False;
    FileResults.Sorted := True;
    FileResults.Duplicates := dupIgnore;

    DirectoryResults.CaseSensitive := False;
    DirectoryResults.Duplicates := dupIgnore;

    if ClearList then
      List.Clear;

    if Directory = '\' then
      Exit;

    RootDirectory :=
      IncludeTrailingPathDelimiter(Directory);

    ScanDir(RootDirectory);

    PublishResults;

  finally
    DirectoryResults.Free;
    FileResults.Free;
  end;
end;

// ============================================================================
// AGE
// ============================================================================
procedure GetFilesInDirectory_Age(Directory: string; const Mask: string;
  List: TStrings; MinMaxFileSize: Int64; WithSubDirs, ClearList: Boolean);
var
  DirectoryResults: TStringList;
  FileResults: TStringList;

  FirstResultsShown: Integer;
  ResultsPublishedOnStop: Boolean;

  LastStatusUpdate: UInt64;
  MaskArray: TStringDynArray;

  procedure PublishResults;
  var
    I: Integer;
  begin
    List.BeginUpdate;
    try
      List.Clear;

      for I := 0 to DirectoryResults.Count - 1 do
        List.Add(DirectoryResults[I]);

      for I := 0 to FileResults.Count - 1 do
        List.Add(FileResults[I]);
    finally
      List.EndUpdate;
    end;

    Application.ProcessMessages;
  end;

  procedure PublishResultsOnStop;
  begin
    if ResultsPublishedOnStop then
      Exit;

    ResultsPublishedOnStop := True;
    PublishResults;
  end;

  procedure UpdateSearchStatus(const CurrentDirectory: string);
  var
    NowTick: UInt64;
  begin
    NowTick := GetTickCount64;

    if (LastStatusUpdate = 0) or
       (NowTick - LastStatusUpdate >= 100) then
    begin
      LastStatusUpdate := NowTick;
      Anzeige := CurrentDirectory;
      Suche_Form.Timer1.Enabled := True;
    end;
  end;

  function SearchShouldStop(const CurrentDirectory: string): Boolean;
  begin
    UpdateSearchStatus(CurrentDirectory);

    Application.ProcessMessages;

    Result := StopSuche;

    if Result then
      PublishResultsOnStop;
  end;

  function FormatSearchResult(const FullPath: string;
    IsDirectory: Boolean): string;
  begin
    if IsDirectory then
      Result := '[' + FullPath + ']'
    else
      Result := FullPath;
  end;

  procedure ShowSearchResult(const S: string);
  begin
    if FirstResultsShown >= 100 then
      Exit;

    Inc(FirstResultsShown);

    List.Add(S);

    Application.ProcessMessages;

    if StopSuche then
      PublishResultsOnStop;
  end;

  procedure AddDirectoryResult(const FullPath: string);
  var
    S: string;
  begin
    if StopSuche then
      Exit;

    S := FormatSearchResult(FullPath, True);

    DirectoryResults.Add(S);

    ShowSearchResult(S);

    Inc(Zaehler);
  end;

  procedure AddFileResult(const FullPath: string);
  var
    S: string;
  begin
    if StopSuche then
      Exit;

    S := FormatSearchResult(FullPath, False);

    FileResults.Add(S);

    ShowSearchResult(S);
  end;

  procedure ScanDir(const CurrentDirectory: string);
  var
    SR: TSearchRec;

    Maske: string;

    FilesFoldersIdx: Integer;

    UseAge: Boolean;
    UseText: Boolean;
    UseSize: Boolean;

    TextSearch: string;
    FileSizeMode: Integer;

    AgeDateTime: TDateTime;
    AgeDateOnly: TDate;

    r1: Integer;

    MaskOK: Boolean;
    SizeOK: Boolean;

    FullPath: string;

    SubDirs: TStringList;
    I: Integer;

    ScanResult: Longint;

    HiddenAndSystem: Boolean;
const
  faHidden: Byte = 2;
  begin
    if SearchShouldStop(CurrentDirectory) then
      Exit;

    FilesFoldersIdx :=
      Suche_Form.FilesFoldersCB.ItemIndex;

    UseAge :=
      Suche_Form.AlterCB.Checked;

    UseText :=
      Suche_Form.TextCB.Text <> '';

    UseSize :=
      Suche_Form.DateiCheckBox.Checked;

    TextSearch :=
      Suche_Form.TextCB.Text;

    FileSizeMode :=
      Suche_Form.FileSizeCombo.ItemIndex;

    AgeDateTime :=
      Suche_Form.DTP.DateTime;

    AgeDateOnly :=
      Suche_Form.DTP.Date;

    // ===================================================
    // AKTUELLES VERZEICHNIS
    // ===================================================
    for Maske in MaskArray do
    begin
      if SearchShouldStop(CurrentDirectory) then
        Exit;

      // Immer mit faAnyFile suchen.
      // Die HIDDEN+SYSTEM-Entscheidung erfolgt anschließend
      // ausdrücklich über HiddenCheckbox.State.
      if FindFirst(
        CurrentDirectory + Maske,
        faAnyFile,
        SR
      ) = 0 then
      try
        repeat
          if SearchShouldStop(CurrentDirectory) then
            Break;

          if (SR.Name = '.') or
             (SR.Name = '..') then
            Continue;

          FullPath :=
            CurrentDirectory +
            SR.FindData.cFileName;

          // --------------------------------------------------------------
          // HIDDEN + SYSTEM
          //
          // cbUnchecked -> nur H+S ausblenden
          // cbChecked    -> alles anzeigen
          // cbGrayed    -> alles anzeigen
          // --------------------------------------------------------------
          HiddenAndSystem :=
            ((SR.Attr and faHidden) <> 0) and
            ((SR.Attr and faSysFile) <> 0);

          if (Suche_Form.HiddenCheckbox.State = cbUnchecked) and
             HiddenAndSystem then
          begin
            Continue;
          end;

          // =================================================
          // VERZEICHNIS
          // =================================================
          if ((SR.Attr and faDirectory) <> 0) then
          begin
            if (FilesFoldersIdx = 0) or
               (FilesFoldersIdx = 2) then
            begin
              if UseAge then
              begin
                r1 :=
                  CompareDate(
                    SR.TimeStamp,
                    AgeDateOnly
                  );

                if (r1 = 0) or
                   (r1 = 1) then
                begin
                  MaskOK :=
                    MatchesMask(
                      String(SR.FindData.cFileName),
                      Maske
                    );

                  if MaskOK and
                     not StopSuche then
                  begin
                    AddDirectoryResult(FullPath);
                  end;
                end;
              end;
            end;
          end

          // =================================================
          // DATEI
          // =================================================
          else if (FilesFoldersIdx = 0) or
                  (FilesFoldersIdx = 1) then
          begin
            if UseAge then
            begin
              r1 :=
                CompareDateTime(
                  SR.TimeStamp,
                  AgeDateTime
                );

              if (r1 <> 0) and
                 (r1 <> 1) then
                Continue;
            end;

            if SearchShouldStop(CurrentDirectory) then
              Break;

            if UseSize then
            begin
              case FileSizeMode of
                0:
                  SizeOK :=
                    SR.Size = MinMaxFileSize;

                1:
                  SizeOK :=
                    SR.Size > MinMaxFileSize;

                2:
                  SizeOK :=
                    SR.Size < MinMaxFileSize;
              else
                SizeOK := True;
              end;

              if not SizeOK then
                Continue;
            end;

            if SearchShouldStop(CurrentDirectory) then
              Break;

            MaskOK :=
              MatchesMask(
                String(SR.FindData.cFileName),
                Maske
              );

            if not MaskOK then
              Continue;

            if UseText then
            begin
              if StopSuche then
                Break;

              ScanResult :=
                ScanFile(
                  FullPath,
                  TextSearch,
                  False
                );

              if ScanResult = -2 then
              begin
                StopSuche := True;
                PublishResultsOnStop;
                Exit;
              end;

              if ScanResult < 0 then
                Continue;

              if StopSuche then
                Break;
            end;

            if not StopSuche then
              AddFileResult(FullPath);
          end;

        until StopSuche or
              (FindNext(SR) <> 0);

      finally
        FindClose(SR);
      end;
    end;

    // ===================================================
    // UNTERVERZEICHNISSE
    // ===================================================
    if WithSubDirs and
       not StopSuche then
    begin
      SubDirs := TStringList.Create;
      try
        SubDirs.CaseSensitive := False;
        SubDirs.Sorted := True;

        if FindFirst(
          CurrentDirectory + '*.*',
          faAnyFile,
          SR
        ) = 0 then
        try
          repeat
            if SearchShouldStop(CurrentDirectory) then
              Break;

            if ((SR.Attr and faDirectory) = faDirectory) and
               (SR.Name <> '.') and
               (SR.Name <> '..') then
            begin
              // ----------------------------------------------------------
              // Auch hier nur HIDDEN + SYSTEM gemeinsam ausschließen.
              //
              // cbUnchecked -> H+S-Verzeichnis nicht durchsuchen
              // cbChecked    -> durchsuchen
              // cbGrayed    -> durchsuchen
              // ----------------------------------------------------------
              HiddenAndSystem :=
                ((SR.Attr and faHidden) <> 0) and
                ((SR.Attr and faSysFile) <> 0);

              if (Suche_Form.HiddenCheckbox.State <> cbUnchecked) or
                 not HiddenAndSystem then
              begin
                SubDirs.Add(SR.Name);
              end;
            end;

          until StopSuche or
                (FindNext(SR) <> 0);

        finally
          FindClose(SR);
        end;

        for I := 0 to SubDirs.Count - 1 do
        begin
          if SearchShouldStop(CurrentDirectory) then
            Break;

          ScanDir(
            IncludeTrailingPathDelimiter(
              CurrentDirectory + SubDirs[I]
            )
          );

          if StopSuche then
            Break;
        end;

      finally
        SubDirs.Free;
      end;
    end;

    UpdateSearchStatus(CurrentDirectory);
  end;

var
  RootDirectory: string;
begin
  Zaehler := 0;

  FirstResultsShown := 0;
  ResultsPublishedOnStop := False;
  LastStatusUpdate := 0;
  MaskArray := SplitString(Mask, '|');

  DirectoryResults := TStringList.Create;
  FileResults := TStringList.Create;

  try
    FileResults.CaseSensitive := False;
    FileResults.Sorted := True;
    FileResults.Duplicates := dupIgnore;

    DirectoryResults.CaseSensitive := False;
    DirectoryResults.Duplicates := dupIgnore;

    if ClearList then
      List.Clear;

    if Directory = '\' then
      Exit;

    RootDirectory :=
      IncludeTrailingPathDelimiter(
        Directory
      );

    ScanDir(RootDirectory);

    PublishResults;

  finally
    DirectoryResults.Free;
    FileResults.Free;
  end;
end;

// Start der Suche durch Klick auf den Suche-Button1
procedure TSuche_Form.StartSearchButtonClick(Sender: TObject);
var
  Path, Mask: String;
  MinMaxFileSize: Int64;
begin
  // =========================================================
  // GESAMTE SUCHZEIT MESSEN
  //
  // Start: direkt beim Klick auf den Start-Button
  // Ende: wird später im Timer1Timer behandelt
  // =========================================================
  SearchStopwatch := TStopwatch.StartNew;

  // Horizontaler Scrollbalken wird entfernt...
  flbHorzScrollWidth := 0;
  Listbox1.Perform(LB_SETHORIZONTALEXTENT, 0, 0);
  MinMaxFileSize := 0;

  if not System.SysUtils.DirectoryExists(SearchField.Text) then
  begin
    MessageDlgCenter(
      'Suchpfad nicht gefunden!' + #13 + SearchField.Text,
      mtwarning,
      [mbOk]
    );

    if Einstellungen_Form.SystemklangCB.Checked then
      PlaySoundFile(
        ExtractFilePath(Application.ExeName) + 'sounds\alert.wav'
      );

    // Suche wurde wegen ungültigem Pfad nicht gestartet.
    // Stopwatch stoppen, damit keine laufende Zeit bestehen bleibt.
    SearchStopwatch.Stop;

    Exit;
  end;

  // Aufhebung der Größenbeschränkung
  Suche_Form.Constraints.MinHeight := Suche_Form.Height - Suchpanel.Height + PanelBottom.Height + StatusBar1.Height;

  Suche_Form.Constraints.MaxHeight := 0;

  PanelBottom.Visible   := True;
  StatusBar1.Visible    := True;
  SucheEdit.Visible     := False;
  AnzeigenPanel.Visible := False;

  // PanelBottom mit den Buttons soll immer über der StatusBar erscheinen
  StatusBar1.Top := PanelBottom.Top + PanelBottom.Height + 1;

  StatusBar1.Panels[0].Text := '...';
  StatusBar1.Panels[1].Text := 'Markiert: ';

  StatusBar1.Canvas.Font := StatusBar1.Font;

  StatusBar1.Panels[0].Width := ListBox1.Width - (Canvas.TextWidth(StatusBar1.Panels[1].Text) + 36);

  Zaehler := 0;
  ListBox1.Clear;
  FreePDF64_Form.Memo1.Clear;
  StatusBar1.Panels[1].Text := '';

  FileField.Text   := Trim(FileField.Text);
  SearchField.Text := Trim(SearchField.Text);

  Application.ProcessMessages;

  Mask := FileField.Text;
  Path := IncludeTrailingBackslash(SearchField.Text);

  StopSuche := False;
  StartSearchButton.Enabled := False;

  // Der Stop-Button bekommt den Fokus nach Start der Suche
  StopSearchButton.SetFocus;

  if (SFHResize < SFHStart) and
     (Suche_Form.Height = Suche_Form.Height - Suchpanel.Height) then
  begin
    Suche_Form.Height := SFHStart;
    SFHResize := SFHStart;
  end
  else
  begin
    if SFHResize < SFHStart then
      Suche_Form.Height := SFHResize
    else
    if SFHResize > SFHStart then
    begin
      Suche_Form.Height := SFHResize;
      SFHStart := SFHResize;
    end
    else
    if SFHStart > SFHResize then
      Suche_Form.Height := SFHStart
    else
    if SFHResize < Suche_Form.Height then
    begin
      Suche_Form.Height := SFHResize;
      SFHStart := SFHResize;
    end;
  end;

  // Reset time, so that all files of the current day can be found
  SearchMinDate.Time := Time;
  SearchMaxDate.Time := StrToTime('23:59:59');

  // =========================================================
  // SUCHE NACH GRÖSSE
  // =========================================================
  if Length(FileSize.Text) > 0 then
  begin
    if SizeAuswahl.ItemIndex = 0 then // Byte
    begin
      try
        MinMaxFileSize := StrToInt(FileSize.Text);
      except
        on EConvertError do
          MinMaxFileSize := 0;
      end;
    end;

    if SizeAuswahl.ItemIndex = 1 then // KB
    begin
      try
        MinMaxFileSize := StrToInt(FileSize.Text) * 1024;
      except
        on EConvertError do
          MinMaxFileSize := 0;
      end;
    end;

    if SizeAuswahl.ItemIndex = 2 then // MB
    begin
      try
        MinMaxFileSize := StrToInt(FileSize.Text) * (1024 * 1024);
      except
        on EConvertError do
          MinMaxFileSize := 0;
      end;
    end;

    if SizeAuswahl.ItemIndex = 3 then // GB
    begin
      try
        MinMaxFileSize :=
          StrToInt64(FileSize.Text) * (1024 * 1024 * 1024);
      except
        on EConvertError do
          MinMaxFileSize := 0;
      end;
    end;
  end;

  // =========================================================
  // SUCHFELDER-EINTRÄGE HINZUFÜGEN
  // =========================================================
  if SearchField.Items.IndexOf(SearchField.Text) < 0 then
    SearchField.Items.Insert(0, SearchField.Text);

  if FileField.Items.IndexOf(FileField.Text) < 0 then
    FileField.Items.Insert(0, FileField.Text);

  if TextCB.Items.IndexOf(TextCB.Text) < 0 then
    TextCB.Items.Insert(0, TextCB.Text);

  // =========================================================
  // SUCHE STARTEN
  // =========================================================
  if Path <> '' then
  begin
    if Mask = '' then
      Mask := '*.*';

    if Mask = '*.*' then
      Mask := '*';

    Zaehler := 0;

    try
      // -------------------------------------------------------
      // Suche nach Alter
      // -------------------------------------------------------
      if AlterCB.Checked then
      begin
        DTP.Date := Date;
        DTP.Time := Time;

        if AgeAuswahl.ItemIndex = 0 then // Stunden
          DTP.DateTime := IncHour(
            DTP.DateTime,
            -AgeSizeEdit.Value
          );

        if AgeAuswahl.ItemIndex = 1 then // Tage
          DTP.DateTime := IncDay(
            DTP.Date,
            -AgeSizeEdit.Value
          );

        if AgeAuswahl.ItemIndex = 2 then // Wochen
          DTP.DateTime := IncWeek(
            DTP.Date,
            -AgeSizeEdit.Value
          );

        if AgeAuswahl.ItemIndex = 3 then // Monate
          DTP.DateTime := IncMonth(
            DTP.DateTime,
            -AgeSizeEdit.Value
          );

        if AgeAuswahl.ItemIndex = 4 then // Jahre
          DTP.DateTime := IncYear(
            DTP.DateTime,
            -AgeSizeEdit.Value
          );

        GetFilesInDirectory_Age(
          Path,
          Mask,
          ListBox1.Items,
          MinMaxFileSize,
          DirCheckbox.Checked,
          True
        );
      end

      // -------------------------------------------------------
      // Suche nach Datum und/oder Größe
      // -------------------------------------------------------
      else
      if DatumCheckBox.Checked or DateiCheckBox.Checked then
      begin
        GetFilesInDirectory_DateSize(
          Path,
          Mask,
          ListBox1.Items,
          MinMaxFileSize,
          DirCheckbox.Checked,
          True
        );
      end

      // -------------------------------------------------------
      // Normale Suche
      // -------------------------------------------------------
      else
      begin
        GetFilesInDirectory(
          Path,
          Mask,
          ListBox1.Items,
          DirCheckbox.Checked,
          True
        );
      end;

    finally
      // -------------------------------------------------------
      // Suche beendet
      // -------------------------------------------------------
      StartSearchButton.Enabled := True;
      StopSearchButton.Caption  := 'Abbrechen';

      if Assigned(FWaitForm) then
      begin
        FWaitForm.Close;
        FreeAndNil(FWaitForm);
      end;
    end;
  end
  else
    Showmessage('Bitte geben Sie einen gültigen Suchpfad ein.');

  // =========================================================
  // SUCHENDE-SOUND
  // =========================================================
  if Einstellungen_Form.SystemklangCB.Checked then
    PlaySoundFile(
      ExtractFilePath(Application.ExeName) + 'sounds\standard.wav'
    );

  // =========================================================
  // ABGEBROCHEN
  // =========================================================
  if StopSuche then
    Suche_Form.StatusBar1.Panels[0].Text :=
      Suche_Form.StatusBar1.Panels[0].Text +
      ' - Suche abgebrochen';

  // =========================================================
  // KEINE ERGEBNISSE
  // =========================================================
  if ListBox1.Count = 0 then
  begin
    StatusBar1.Panels[0].Text := '';
    StatusBar1.Panels[1].Text := '';
  end;

  // =========================================================
  // ERGEBNISSE VORHANDEN
  // =========================================================
  if ListBox1.Count > 1 then
  begin
    SuchergebnisCB.Enabled  := True;
    SuchergebnisBtn.Enabled := True;

    StatusBar1.Panels[1].Text :=
      'Markiert: ' + IntToStr(ListBox1.SelCount);

    StatusBar1.Canvas.Font := StatusBar1.Font;

    StatusBar1.Panels[0].Width :=
      ListBox1.Width -
      (Canvas.TextWidth(StatusBar1.Panels[1].Text) + 36);
  end
  else begin
    SuchergebnisCB.Enabled  := False;
    SuchergebnisBtn.Enabled := False;
  end;

  // =========================================================
  // FOKUS NACH ENDE DER SUCHE
  // =========================================================
  if ListBox1.Count = 0 then
    FileField.SetFocus
  else
  begin
    ListBox1.Selected[0] := True;
    ListBox1.SetFocus;
  end;

  if ListBox1.SelCount > 0 then
    StatusBar1.Panels[1].Text :=
      'Markiert: ' + IntToStr(ListBox1.SelCount);
end;

procedure TSuche_Form.StopSearchButtonClick(Sender: TObject);
var
  WaitLabel: TLabel;
begin
  if StartSearchButton.Enabled then
  begin
    SucheEdit.Visible     := False;
    AnzeigenPanel.Visible := False;
    Close;
    Exit;
  end;

  // Abbruch anfordern
  StopSuche := True;

  StopSearchButton.Caption := 'Warten...';

  // Wartefenster nur einmal erzeugen
  if not Assigned(FWaitForm) then
  begin
    FWaitForm := TForm.Create(Self);

    FWaitForm.BorderStyle := bsDialog;
    FWaitForm.BorderIcons := [];
    FWaitForm.Position    := poScreenCenter;
    FWaitForm.Width       := 480;
    FWaitForm.Height      := 80;
    FWaitForm.Caption     := 'Suchergebnis wird vorbereitet...';

    WaitLabel := TLabel.Create(FWaitForm);
    WaitLabel.Parent    := FWaitForm;
    WaitLabel.Align     := alClient;
    WaitLabel.Alignment := taCenter;
    WaitLabel.Layout    := tlCenter;
    WaitLabel.Caption   := 'Bitte warten...';
  end;

  // Nicht modal anzeigen!
  FWaitForm.Show;
  FWaitForm.Update;

  // Nur Nachrichten verarbeiten und sofort zurückkehren.
  // KEINE while-Schleife!
  Application.ProcessMessages;
end;

procedure TSuche_Form.SearchFieldDropDown(Sender: TObject);
var
  Last: string;
  i: Integer;
begin
  Last := SearchField.Text;

  // Leere Einträge entfernen (korrekter Bereich!)
  for i := SearchField.Items.Count - 1 downto 0 do
    if SearchField.Items[i] = '' then
      SearchField.Items.Delete(i);

  // Letzten Eintrag oben einfügen, wenn er noch nicht existiert
  if (Last <> '') and (SearchField.Items.IndexOf(Last) < 0) then
    SearchField.Items.Insert(0, Last)
  else
  begin
    // Falls vorhanden → nach oben verschieben
    i := SearchField.Items.IndexOf(Last);
    if i > 0 then
    begin
      SearchField.Items.Delete(i);
      SearchField.Items.Insert(0, Last);
    end;
  end;

  // Immer den obersten Eintrag auswählen
  if SearchField.Items.Count > 0 then
    SearchField.ItemIndex := 0;
end;

procedure TSuche_Form.FileFieldChange(Sender: TObject);
begin
  FLastPersistent := FileField.Text;
end;

procedure TSuche_Form.FileFieldCloseUp(Sender: TObject);
var
  idx: Integer;
  S: string;
begin
  S := TrimRight(FileField.Text);

  if S = '' then
    Exit;

  FileField.Text := S;

  idx := FileField.Items.IndexOf(S);

  if idx > 0 then
  begin
    FileField.Items.Delete(idx);
    FileField.Items.Insert(0, S);
  end
  else if idx < 0 then
    FileField.Items.Insert(0, S);

  FLastPersistent := S;
end;

procedure TSuche_Form.FileFieldDropDown(Sender: TObject);
var
  i: Integer;
begin
  for i := FileField.Items.Count - 1 downto 0 do
    if Trim(FileField.Items[i]) = '' then
      FileField.Items.Delete(i);
end;

procedure TSuche_Form.TextCBDropDown(Sender: TObject);
var
  i: Integer;
begin
  if TextCB.Items.IndexOf(TextCB.Text) < 0 then
    TextCB.Items.Insert(0, TextCB.Text);

  for i := TextCB.Items.Count downto 0 do
    if TextCB.Items.Strings[i] = '' then
      TextCB.Items.Delete(i);
end;

procedure TSuche_Form.FilesFoldersCBChange(Sender: TObject);
begin
  if FilesFoldersCB.ItemIndex <> 1 then
  begin
    FileSizeCombo.Enabled := False;
    FileSize.Enabled      := False;
    SizeAuswahl.Enabled   := False;
    TextCB.Enabled        := False;
    TextCB.Text           := '';
    TextLabel.Enabled     := False;
  end else
  begin
    DateiCheckBox.Enabled := True;
    if not DatumCheckBox.Checked then
    begin
      TextCB.Enabled    := True;
      TextCB.Text       := '';
      TextLabel.Enabled := True;
    end;
  end;

  if FilesFoldersCB.ItemIndex = 0 then
    DateiCheckBox.Enabled := True;
end;

procedure TSuche_Form.FileSizeClick(Sender: TObject);
begin
  FileSize.SelectAll;
end;

procedure TSuche_Form.FileSizeEnter(Sender: TObject);
begin
  FileSize.SelectAll;
end;

procedure TSuche_Form.FileSizeKeyPress(Sender: TObject; var Key: Char);
begin
  if Key in [Chr(Ord('0')) .. Chr(Ord('9')), Chr(Ord(8)), Chr(Ord(115))] then
  begin
    //
  end
  else
    Key := #0;
end;

// Contextmenü des ausgewählten Items anzeigen
procedure TSuche_Form.ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  s: String;
begin
  if ListBox1.SelCount = 0 then
    Exit;

  if Button = MBRight then
  begin
    s := ListBox1.Items[ListBox1.ItemIndex];
    // Prüfe, ob das erste Zeichen ein [ ist - und entfernen
    if Pos('[', s) <> 0 then
      Delete(s, 1, 1);
    // Prüfe, ob das letzte Zeichen ein ] ist - und entfernen
    if s[Length(s)] = ']' then
      Delete(s, Length(s), 1);

    ContextMenuForFile(Application.Handle, s, Mouse.CursorPos.X, Mouse.CursorPos.Y);
  end;

  // Abfrage auf Alt + linke Maustaste...
  AltLeftDown := (Button = mbLeft) and (ssAlt in Shift);
end;

// Gehe zum Verzeichnis des Eintrags in der Listbox
procedure TSuche_Form.ListBox1DblClick(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  // Keine Auswahl → Hinweis
  if (ListBox1.SelCount = 0) or (ListBox1.Count = 0) then
  begin
    MessageDlgCenter('Kein Eintrag gewählt!', mtInformation, [mbOk]);
    Exit;
  end;

  // ALT + Linksklick → Datei direkt öffnen
  if AltLeftDown then
  begin
    s := ListBox1.Items[ListBox1.ItemIndex];

    if FileExists(s) then
      ShellExecute(Handle, 'open', PChar(s), nil, nil, SW_SHOWNORMAL);

    Exit;
  end;

  // Normale Suche
  Suche_ItemAnzeigen := True;

  // Markierten Eintrag holen
  s := '';

  for i := 0 to ListBox1.Count - 1 do
    if ListBox1.Selected[i] then
    begin
      s := ListBox1.Items[i];
      Break;
    end;

  if s = '' then
    Exit;

  // Klammern entfernen: [Pfad] → Pfad
  if (Length(s) > 0) and (s[1] = '[') then
    Delete(s, 1, 1);

  if (Length(s) > 0) and (s[Length(s)] = ']') then
    Delete(s, Length(s), 1);

  FreePDF64_Form.BringToFront;

  // ============================================================
  // LINKS
  // ============================================================
  if Links then
  begin
    // ----------------------------------------------------------
    // Verzeichnis:
    // Direkt in das angeklickte Verzeichnis wechseln.
    // Dadurch nur EIN ChDir.
    // ----------------------------------------------------------
    if DirectoryExists(s) then
    begin
      FreePDF64_Form.LMDShellFolder1.ChDir(s);

      // Das Verzeichnis ist jetzt geöffnet.
      // Eine erneute Suche/Markierung des Ordners ist nicht
      // notwendig, da wir uns bereits darin befinden.
    end
    else
    begin
      // --------------------------------------------------------
      // Datei:
      // Übergeordnetes Verzeichnis öffnen und Datei markieren.
      // --------------------------------------------------------
      FreePDF64_Form.LMDShellFolder1.ChDir(ExtractFilePath(s));

      for i := 0 to FreePDF64_Form.LMDShellList1.Items.Count - 1 do
        if SameText(
          FreePDF64_Form.LMDShellList1.Items[i].Caption,
          ExtractFileName(s)
        ) then
        begin
          FreePDF64_Form.LMDShellList1.ItemFocused :=
            FreePDF64_Form.LMDShellList1.Items[i];

          FreePDF64_Form.LMDShellList1.Selected :=
            FreePDF64_Form.LMDShellList1.Items[i];

          FreePDF64_Form.LMDShellList1.SetFocus;

          FreePDF64_Form.LMDShellList1.Items[i].MakeVisible(False);

          Break;
        end;
    end;
  end

  // ============================================================
  // RECHTS
  // ============================================================
  else
  begin
    // ----------------------------------------------------------
    // Verzeichnis:
    // Direkt in das angeklickte Verzeichnis wechseln.
    // Dadurch nur EIN ChDir.
    // ----------------------------------------------------------
    if DirectoryExists(s) then
    begin
      FreePDF64_Form.LMDShellFolder2.ChDir(s);

      // Das Verzeichnis ist jetzt geöffnet.
    end
    else
    begin
      // --------------------------------------------------------
      // Datei:
      // Übergeordnetes Verzeichnis öffnen und Datei markieren.
      // --------------------------------------------------------
      FreePDF64_Form.LMDShellFolder2.ChDir(ExtractFilePath(s));

      for i := 0 to FreePDF64_Form.LMDShellList2.Items.Count - 1 do
        if SameText(
          FreePDF64_Form.LMDShellList2.Items[i].Caption,
          ExtractFileName(s)
        ) then
        begin
          FreePDF64_Form.LMDShellList2.ItemFocused :=
            FreePDF64_Form.LMDShellList2.Items[i];

          FreePDF64_Form.LMDShellList2.Selected :=
            FreePDF64_Form.LMDShellList2.Items[i];

          FreePDF64_Form.LMDShellList2.SetFocus;

          FreePDF64_Form.LMDShellList2.Items[i].MakeVisible(False);

          Break;
        end;
    end;
  end;

  // ============================================================
  // Autosize
  // ============================================================
  //
  // Wie im Original, aber nur die tatsächlich verwendete
  // LMDShellList wird angepasst.
  // ============================================================
  if Links then
    FreePDF64_Form.LMDShellList1.Column[0].AutoSize := True
  else
    FreePDF64_Form.LMDShellList2.Column[0].AutoSize := True;

  // Wenn im Tray → nach vorne holen
  if FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.TrayIcon1Click(Sender);

  Close;
end;

procedure TSuche_Form.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  S: string;
  Scale: Single;
  TextLeft: Integer;
  TextTop: Integer;
  TextPx: Integer;
  Len: Integer;
begin
  S := ListBox1.Items[Index];
  Scale := ListBox1.CurrentPPI / 96;

  with ListBox1.Canvas do
  begin
    // Hintergrund und Schriftfarbe
    if odSelected in State then
    begin
      // Blau wie die Textauswahl im FileField
      Brush.Color := $00D77800;
      Font.Color := clWhite;
    end
    else if odHotLight in State then
    begin
      Brush.Color := $00F5F5F5;
      Font.Color := clBlack;
    end
    else
    begin
      Brush.Color := clWindow;
      Font.Color := clWindowText;
    end;

    FillRect(Rect);

    // Tatsächliche Texthöhe der aktuellen Schrift
    TextPx := TextHeight('Hg');

    // Text exakt vertikal in der Zeile zentrieren
    TextTop := Rect.Top + ((Rect.Bottom - Rect.Top) - TextPx) div 2;

    // Linker Innenabstand
    TextLeft := Rect.Left + Round(8 * Scale);
    TextOut(TextLeft, TextTop, S);

    // Horizontale Scrollbreite
    Len := TextWidth(S) + Round(20 * Scale);

    if Len > flbHorzScrollWidth then
    begin
      flbHorzScrollWidth := Len;

      ListBox1.Perform(
        LB_SETHORIZONTALEXTENT,
        Round(flbHorzScrollWidth / Scale),
        0
      );
    end;

    if FreePDF64_Form.Gitternetzlinien1.Checked then
    begin
      // Die horizontale Trennlinie zwischen den ListBox-Einträgen
      Pen.Color := $00DDDDDD;
      MoveTo(Rect.Left, Rect.Bottom - 1);
      LineTo(Rect.Right, Rect.Bottom - 1);
    end;
  end;
end;

procedure TSuche_Form.Lschen1Click(Sender: TObject);
begin
  Btn_4.Click;
end;

end.

