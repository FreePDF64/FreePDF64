unit Suchen;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
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
    Btn_7: TSpeedButton;
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
    SortBtn: TBitBtn;
    SucheEdit: TEdit;
    Timer2: TTimer;
    AnzeigenPanel: TPanel;
    Gehezu1: TMenuItem;
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
    procedure Allesmarkieren1Click(Sender: TObject);
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
    procedure Btn_7Click(Sender: TObject);
    procedure Btn_7MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Markieren1Click(Sender: TObject);
    procedure InfoClick(Sender: TObject);
    procedure AlterCBClick(Sender: TObject);
    procedure DateiCheckBoxClick(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure SortBtnClick(Sender: TObject);
    procedure SucheEditChange(Sender: TObject);
    procedure Panel_obenEnter(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure MoveSelectedItemsToTop(ListBox: TListBox);
    procedure AnzeigenPanelClick(Sender: TObject);
    public
      { Public-Deklarationen }
      procedure PlaySoundFile(FileName: string);
    private
      { Private-Deklarationen }
     flbHorzScrollWidth: Integer;
  end;

var
  Suche_Form: TSuche_Form;
  // Globale Variablen
  StopSuche, Links, Rechts: Boolean;
  Zaehler, SFHStart, SFHResize: Integer;
  Anzeige: String;

implementation

{$R *.dfm}

uses FreePDF64_Unit, FreePDF64_Notify_Unit, Einstellungen_Unit;

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
begin
  ListBox1.Style      := lbOwnerDrawFixed;
  ListBox1.OnDrawItem := ListBox1DrawItem;

    // Suche_Form zusätzlich in der Taskbar anzeigen lassen
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or
    WS_EX_APPWINDOW);

  ListBox1.ItemHeight := 22; // Setzt die Höhe jedes Elements
  Suche_ItemAnzeigen  := False;

  // Die Buttons werden dargestellt und ausgerichtet!
  Laenge := Suche_Form.Width div 8;
  Btn_1.Left := 1;
  Btn_1.Align := alLeft;
  Btn_1.Width := Laenge;
  Btn_2.Left := 2;
  Btn_2.Align := alLeft;
  Btn_2.Width := Laenge;
  Btn_3.Left := 3;
  Btn_3.Align := alLeft;
  Btn_3.Width := Laenge;
  Btn_4.Left := 4;
  Btn_4.Align := alLeft;
  Btn_4.Width := Laenge;
  Btn_0.Left := 5;
  Btn_0.Align := alLeft;
  Btn_0.Width := Laenge;
  Btn_6.Left := 6;
  Btn_6.Align := alLeft;
  Btn_6.Width := Laenge;
  Btn_5.Left := 7;
  Btn_5.Align := alLeft;
  Btn_5.Width := Laenge;
  Btn_7.Left := 8;
  Btn_7.Align := alClient;
  Btn_7.Width := Laenge;
end;

procedure TSuche_Form.FormResize(Sender: TObject);
var
  Laenge: Integer;
begin
  // Die Buttons werden dargestellt und ausgerichtet!
  Laenge := Suche_Form.Width div 8;
  Btn_7.Width := Laenge;
  Btn_7.Left := 1;
  Btn_5.Width := Laenge;
  Btn_5.Left := 2;
  Btn_6.Width := Laenge;
  Btn_6.Left := 3;
  Btn_0.Width := Laenge;
  Btn_0.Left := 4;
  Btn_4.Width := Laenge;
  Btn_4.Left := 5;
  Btn_3.Width := Laenge;
  Btn_3.Left := 6;
  Btn_2.Width := Laenge;
  Btn_2.Left := 7;
  Btn_1.Width := Laenge;
  Btn_1.Left := 8;

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
          IniDat.WriteString('Suche', 'SearchField' + IntToStr(i), SearchField.Items[i]);

      if FileField.Items.Count > 0 then
        for i := 0 to FileField.Items.Count do
          IniDat.WriteString('Suche', 'FileField' + IntToStr(i), FileField.Items[i]);

      // Textsuche schreiben.
      if TextCB.Items.Count > 0 then
      for i := 0 to TextCB.Items.Count do
        IniDat.WriteString('Suche', 'Textsearch' + IntToStr(i), TextCB.Items[i]);

    IniDat.WriteInteger('Suche', 'Top',    Suche_Form.Top);
    IniDat.WriteInteger('Suche', 'Left',   Suche_Form.Left);
    IniDat.WriteInteger('Suche', 'Height', Suche_Form.Height);
    IniDat.WriteInteger('Suche', 'Width',  Suche_Form.Width);
    // Speicher wird wieder freigeben
    IniDat.Free;
  except
    Showmessage('Fehler festgestellt!');
  end;
end;

// Verzeichnis auswählen zur Suche
procedure TSuche_Form.Allesmarkieren1Click(Sender: TObject);
begin
  Btn_7.Caption := 'Warte...';
  LockWindowUpdate(ListBox1.Handle);
  ListBox1.SelectAll;
  LockWindowUpdate(0);
  StatusBar1.Canvas.Font := StatusBar1.Font;
  StatusBar1.Panels[0].Width := ListBox1.Width - (Canvas.TextWidth(StatusBar1.Panels[1].Text) + 36);
  Btn_7.Caption := 'Markieren';
  // Zum obersten Eintrag gehen
  ListBox1.ItemIndex := 0;
end;

procedure TSuche_Form.Bewegen1Click(Sender: TObject);
begin
  Btn_3.Click;
end;

procedure TSuche_Form.BrowseClick(Sender: TObject);
var
  s: String;
begin
  s := SearchField.Text;

  LMDShellSysBrowseDialog1.SelectedPath := ExcludeTrailingBackslash(s);
  LMDShellSysBrowseDialog1.Caption := 'Laufwerk oder Verzeichnis auswählen';
  LMDShellSysBrowseDialog1.InstructionText :=
    'Bitte das gewünschte Laufwerk oder Verzeichnis auswählen:';

  if LMDShellSysBrowseDialog1.Execute then
    s := LMDShellSysBrowseDialog1.SelectedPath;

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

// Markieren
procedure TSuche_Form.Btn_7Click(Sender: TObject);
begin
  if ListBox1.Count < 0 then
    Exit
  else
  begin
    LockWindowUpdate(ListBox1.Handle);
    ListBox1.SelectAll;
    LockWindowUpdate(0);
    if ListBox1.SelCount > 0 then
      StatusBar1.Panels[1].Text := 'Markiert: ' + IntToStr(ListBox1.SelCount);
  end;
  StatusBar1.Canvas.Font := StatusBar1.Font;
  StatusBar1.Panels[0].Width := ListBox1.Width - (Canvas.TextWidth(StatusBar1.Panels[1].Text) + 36);
  Btn_7.Caption := 'Markieren';
  // Zum obersten Eintrag gehen
  ListBox1.ItemIndex := 0;
end;

procedure TSuche_Form.Btn_7MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Btn_7.Caption := 'Warten...';
end;

procedure TSuche_Form.Markieren1Click(Sender: TObject);
begin
  Btn_7.Click;
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
  ListBox1.ClearSelection;
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

procedure TSuche_Form.Timer2Timer(Sender: TObject);
begin
  if SucheEdit.Color = clWhite then
  begin
    SucheEdit.Color     := clGradientActiveCaption;
    AnzeigenPanel.Color := clGradientActiveCaption;
  end else
  begin
    SucheEdit.Color     := clWhite;
    AnzeigenPanel.Color := clWhite;
  end;

  if SucheEdit.Visible then
    SucheEdit.SetFocus;
end;

// Suche den SucheEdit.Text im Suchergebnis der ListBox
procedure TSuche_Form.SucheEditChange(Sender: TObject);
var
  i: Integer;
  searchText: string;
begin
  Timer2.Enabled      := False;
  SucheEdit.Color     := clWhite;
  AnzeigenPanel.Color := clWhite;
  searchText          := SucheEdit.Text;
  // Flackern verhindern
  SendMessage(ListBox1.Handle, WM_SETREDRAW, WPARAM(False), 0);
  ListBox1.Items.BeginUpdate;
  try
    ListBox1.ClearSelection;
    for i := 0 to ListBox1.Items.Count - 1 do
    begin
      if Pos(LowerCase(searchText), LowerCase(ExtractFileName(ListBox1.Items[i]))) > 0 then
      begin
        ListBox1.Selected[i] := True;
        ListBox1.TopIndex    := ListBox1.ItemIndex;
      end;
    end;
  finally
    ListBox1.Items.EndUpdate;
  end;
  SendMessage(ListBox1.Handle, WM_SETREDRAW, WPARAM(True), 0);
  StatusBar1.Panels[1].Text  := 'Markiert: ' + IntToStr(ListBox1.SelCount);
end;

// Taste drücken ruft Suche auf im Suchergebnis
procedure TSuche_Form.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #13) then
    StartSearchButton.Click
  else
  if (ListBox1.Count > 0) and ListBox1.Focused then
  begin
    SucheEdit.Visible     := True;
    AnzeigenPanel.Visible := True;
    Timer2.Enabled        := True;
  end;
end;

procedure TSuche_Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
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
      Suche_Form.Top    := ReadInteger('Suche', 'Top',    Suche_Form.Top);
      Suche_Form.Left   := ReadInteger('Suche', 'Left',   Suche_Form.Left);
      Suche_Form.Height := ReadInteger('Suche', 'Height', Suche_Form.Height);
      Suche_Form.Width  := ReadInteger('Suche', 'Width',  Suche_Form.Width);
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
  SuchergebnisBtn.Enabled := False;
  SortBtn.Enabled         := False;
  SucheEdit.Visible       := False;
  AnzeigenPanel.Visible   := False;
  SucheEdit.Text          := '';
  DTP.Date := Date;
  DTP.Time := Time;

  ListBox1.Clear;
  FilesFoldersCB.ItemIndex := 0; // Zeige Dateien und Verzeichnisse
  FileSizeCombo.ItemIndex  := 1;
  FileSize.Value           := 1;
  SizeAuswahl.ItemIndex    := 1;
  FileSizeCombo.Enabled    := False;
  FileSize.Enabled         := False;
  DateiCheckBox.Enabled    := True;
  DateiCheckBox.Checked    := False;
  Sizeauswahl.Enabled      := False;
  SizeAuswahl.ItemIndex    := 0;
  TextCB.Enabled           := False;
  TextCB.Text              := '';
  FileField.Text           := '';
  TextLabel.Enabled        := False;
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
  if MessageDlg('Hilfe zum Suchefenster' + #13 +
                '===============' + #13 +
                'Suchen nach:' + #13 +
                '- Ein Stern * für eine beliebige Anzahl Zeichen' + #13 +
                '- Beispiel: Test*.* findet u.a.: Testlauf.docx, Test1.ini, Testdatei.prn' + #13 + #13 +
                '- Ein Fragezeichen ? steht für ein beliebiges Zeichen. Mehrere Fragezeichen ? stehen für: von - bis' + #13 +
                '- Beispiel: Test?.log findet u.a.: Test1.log, Test8.log' + #13 +
                '- Beispiel: Test??.log findet u.a.: Test1.log, Test8.log, TestA3.log, Test45.log' + #13 + #13 +
                '- Mehrere Suchmasken müssen direkt durch das Pipe-Zeichen | getrennt eingegeben werden' + #13 +
                '- Beispiel: Lights at the*|Lake* findet u.a.: Lights at the Night Circus.jpg sowie Lake Mist.txt' + #13 + #13 +
                'Versteckt+System' + #13 +
                '- [✓] Zeigt auch alle Datei(en)/Verzeichnis(se) an mit dem Attribut Versteckt (H) und System (S)' + #13 +
                '- [-] Es werden zusätzlich alle Dateiattribute zum markiertem Eintrag angezeigt' + #13 + #13 +
                'Text suchen:' + #13 +
                '- Läßt sich nur bei "Zeige nur Dateien" nutzen' + #13 + #13 +
                'Suchergebnis:' + #13 +
                '- Angezeigt werden sortiert Datei(en) zuerst, Verzeichnis(se) zuletzt' + #13 +
                '- Zur Suche in das Suchergebnis klicken und dann einfaches Tippen eines Buchstabens' + #13 +
                '- Alt+linker Mausklick öffnet markierte Datei des Suchergebnisses' + #13 +
                '- Rechter Mausklick öffnet Standard-Kontextmenü der markierten Datei/Verzeichnis' + #13 +
                '- Doppelklick mit der Maus geht direkt im Hauptfenster zur markierten Datei/Verzeichnis',
                mtInformation, [mbOk], 0, mbOk) = mrCancel then
                  Exit;
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
  i: Integer;
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
    if (Einstellungen_Form.ExifToolGE.Checked = True) and Info_Anzeigen then
      // Textausgabe ausrichten
      for i := 1 to FreePDF64_Form.Memo1.Lines.Count do
        FreePDF64_Form.Memo1.Lines[i] :=
          StringReplace(FreePDF64_Form.Memo1.Lines[i], ':', #9 + ':',
          [rfIgnoreCase]);
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
  FreePDF64_Form.Memo1.Perform(EM_LineScroll, 0,
    -FreePDF64_Form.Memo1.Lines.Count - 1);
  if FreePDF64_Form.Memo1.Lines.Count > 0 then
  begin
    i := TextHoehe(FreePDF64_Form.Memo1.Font, FreePDF64_Form.Memo1.Text);
    i := (i * FreePDF64_Form.Memo1.Lines.Count) + MHA;
    if i < FreePDF64_Form.Memo1.Parent.Height then
      Exit;
    if FreePDF64_Form.Height < 400 then
      Exit;
    if i >= (FreePDF64_Form.Height - 350) then
      i := FreePDF64_Form.Height - 350;
    FreePDF64_Form.PDFPanel.Height := i;
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
  tmp: String;
begin
  if ListBox1.Count = 0 then
    Exit;

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

  s1 := IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName);
  LMDShellSysBrowseDialog1.SelectedPath := s1;
  LMDShellSysBrowseDialog1.Caption := 'In welches Verzeichnis soll kopiert werden?';
  LMDShellSysBrowseDialog1.InstructionText := 'Bitte das gewünschte Verzeichnis auswählen.';

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

// Abfrage auf Attribute
function GetFileAttributes(const FileName: string): TFileAttributes;
var
  srec: TSearchRec;
  faReadOnly, faHidden, faArchive: Integer;
begin
  faReadOnly := $00000001;
  faHidden   := $00000002;
  faArchive  := $00000020;

  result := [];
  if FindFirst(FileName, faAnyFile, srec) = 0 then begin
    try
      if (srec.Attr and faReadOnly)  > 0 then result := result + [ReadOnly];  //Schreibgesch. Datei
      if (srec.Attr and faHidden)    > 0 then result := result + [Hidden];    //Verborgene Datei
      if (srec.Attr and faSysFile)   > 0 then result := result + [SysFile];   //Systemdatei
      if (srec.Attr and faVolumeId)  > 0 then result := result + [VolumeId];  //Laufwerks-ID
      if (srec.Attr and faDirectory) > 0 then result := result + [Directory]; //Verzeichnis
      if (srec.Attr and faArchive)   > 0 then result := result + [Archive];   //Archivdatei
      if (srec.Attr and faAnyFile)   > 0 then result := result + [AnyFile];   //Beliebige Datei
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
  SucheEdit.Visible     := False;
  AnzeigenPanel.Visible := False;

  if ListBox1.Count = 0 then
    Exit;
  if ListBox1.SelCount > 0 then
    StatusBar1.Panels[1].Text := 'Markiert: ' + IntToStr(ListBox1.SelCount);

  for i := 0 to ListBox1.Count - 1 do
    if ListBox1.Selected[i] then
    begin
      if FileExists(ListBox1.Items.Strings[i]) then
      begin
        d  := GetFileLastWriteTime(ListBox1.Items.Strings[i]);
        // Größenausgabe formatieren
        s  := FloatToStrF(GetFileSize(ListBox1.Items.Strings[i]), ffNumber, 15, 0) + ' Bytes';
        if HiddenCheckBox.State = cbGrayed then
        begin
          fa := GetFileAttributes(ListBox1.Items.Strings[i]);
          at := '';
          if ReadOnly in fa then at := at + 'R';
          if Archive  in fa then at := at + 'A';
          if Hidden   in fa then at := at + 'H';
          if SysFile  in fa then at := at + 'S';
          StatusBar1.Panels[0].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', d) + ', ' + s + ' (Attribute: ' + at + ')';
          if at = '' then
            StatusBar1.Panels[0].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', d) + ', ' + s;
        end else
            StatusBar1.Panels[0].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', d) + ', ' + s;
      end else
      if DirectoryExists(RemoveFirstAndLastChar(ListBox1.Items.Strings[i])) then
      begin
        d  := GetFileLastWriteTime(RemoveFirstAndLastChar(ListBox1.Items.Strings[i]));
        if HiddenCheckBox.State = cbGrayed then
        begin
          fa := GetFileAttributes(RemoveFirstAndLastChar(ListBox1.Items.Strings[i]));
          at := '';
          if ReadOnly in fa then at := at + 'R';
          if Archive  in fa then at := at + 'A';
          if Hidden   in fa then at := at + 'H';
          if SysFile  in fa then at := at + 'S';
          StatusBar1.Panels[0].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', d) + ' (Attribute: ' + at + ')';
          if at = '' then
            StatusBar1.Panels[0].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', d);
        end else
          StatusBar1.Panels[0].Text := FormatDateTime('dd.mm.yyyy hh:mm:ss', d);
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

  s1 := IncludeTrailingBackslash
    (FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName);
  LMDShellSysBrowseDialog1.SelectedPath := s1;
  LMDShellSysBrowseDialog1.Caption :=
    'In welches Verzeichnis soll verschoben werden?';
  LMDShellSysBrowseDialog1.InstructionText :=
    'Bitte das gewünschte Verzeichnis auswählen.';

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
          MoveFileEx(s, IncludeTrailingBackslash(s1) +
            ExtractFileName(s), False);
        ListBox1.DeleteSelected;
        ListBox1.ClearSelection;
        if ListBox1.Count > 0 then
          ListBox1.Selected[0] := True;
        Exit;
      end
      else if UmbenennenCB.Checked then
        MoveFileEx(pchar(s), pchar(IncludeTrailingBackslash(s1) +
          ExtractFileName(s)), True)
      else
        MoveFileEx(pchar(s), pchar(IncludeTrailingBackslash(s1) +
          ExtractFileName(s)), False);
      StatusBar1.Panels[0].Text := 'Bewegenvorgang durchgeführt...';
    end;

  ListBox1.DeleteSelected;
  ListBox1.ClearSelection;
  if ListBox1.Count > 0 then
    ListBox1.Selected[0] := True;
  StatusBar1.Panels[0].Text := 'Bewegenvorgang ist fertig!';
end;

procedure TSuche_Form.Timer1Timer(Sender: TObject);
begin
  StatusBar1.Panels[0].Text := Anzeige;
  Timer1.Enabled := False; // Timer stoppen, um nur einmal zu aktualisieren

  if StartSearchButton.Enabled = True then
  begin
    // Nur Dateien
    if FilesFoldersCB.ItemIndex = 1 then
    begin
      if ListBox1.Count = 0 then
      begin
        if StopSuche then
          StatusBar1.Panels[0].Text := '[0 Datei(en) gefunden]' + ' - Suche abgebrochen'
        else
          StatusBar1.Panels[0].Text := '[0 Datei(en) gefunden]';
      end else
      begin
        if StopSuche then
          StatusBar1.Panels[0].Text := '[' + IntToStr(ListBox1.Count - Zaehler) + ' Datei(en) gefunden]' + ' - Suche abgebrochen'
        else
          StatusBar1.Panels[0].Text := '[' + IntToStr(ListBox1.Count - Zaehler) + ' Datei(en) gefunden]';
      end;
    end else
      // Nur Verzeichnisse
      if FilesFoldersCB.ItemIndex = 2 then
      begin
        if ListBox1.Count = 0 then
        begin
          if StopSuche then
            StatusBar1.Panels[0].Text := '[0 Verzeichnis(se) gefunden]' + ' - Suche abgebrochen'
          else
            StatusBar1.Panels[0].Text := '[0 Verzeichnis(se) gefunden]';
        end else
        begin
          if StopSuche then
            StatusBar1.Panels[0].Text := '[' + IntToStr(Zaehler) + ' Verzeichnis(se) gefunden]' + ' - Suche abgebrochen'
          else
            StatusBar1.Panels[0].Text := '[' + IntToStr(Zaehler) + ' Verzeichnis(se) gefunden]';
        end;
      end else
        // Dateien und Verzeichnisse
        if FilesFoldersCB.ItemIndex = 0 then
        begin
          if ListBox1.Count = 0 then
          begin
            if StopSuche then
              StatusBar1.Panels[0].Text := '[0 Datei(en) und 0 Verzeichnis(se) gefunden]' + ' - Suche abgebrochen'
            else
              StatusBar1.Panels[0].Text := '[0 Datei(en) und 0 Verzeichnis(se) gefunden]';
          end else
          begin
            if DateiCheckBox.Checked and StopSuche then
              StatusBar1.Panels[0].Text := '[' + IntToStr(ListBox1.Count - Zaehler) + ' Datei(en) gefunden] - Suche abgebrochen'
            else
            if DateiCheckBox.Checked and not StopSuche then
              StatusBar1.Panels[0].Text := '[' + IntToStr(ListBox1.Count - Zaehler) + ' Datei(en) gefunden]'
            else
            if (DateiCheckBox.Checked = False) and StopSuche then
              StatusBar1.Panels[0].Text := '[' + IntToStr(ListBox1.Count - Zaehler) + ' Datei(en) und ' + IntToStr(Zaehler) + ' Verzeichnis(se) gefunden]' + ' - Suche abgebrochen'
            else
            if (DateiCheckBox.Checked = False) and not StopSuche then
              StatusBar1.Panels[0].Text := '[' + IntToStr(ListBox1.Count - Zaehler) + ' Datei(en) und ' + IntToStr(Zaehler) + ' Verzeichnis(se) gefunden]'
          end;
        end;
  end;
end;

function StrAlloc1(Size: Cardinal): PAnsiChar;
begin
  Inc(Size, SizeOf(Cardinal));        // Die Größe des zu reservierenden Platzes um 4 Bytes erhöhen
  GetMem(Result, Size);               // Speicher reservieren .. soviel wie der String lang ist + 4 Bytes um die Länges des Strings zu speichern
  Cardinal(Pointer(Result)^) := Size; // Die Größe des Speicherplatzes am Anfang des reservierten Platzes speichern
  Inc(Result, SizeOf(Cardinal));      // Den Pointer (PChar) hinter die Größenangabe verschieben
end;

// Textsuche in Datei(en)
function ScanFile(const FileName: string; const forString: string; caseSensitive: Boolean): Longint;
const
  BufferSize = $8001;  // 32K + 1 bytes
var
  pBuf, pEnd, pPos, pScan, SearchFor: PAnsiChar;
  filesize: LongInt;
  bytesRemaining: LongInt;
  bytesToRead: Integer;
  F: file;
  oldMode: Word;
begin
  // assume failure
  Result := -1;
  if (Length(forString) = 0) or (Length(FileName) = 0) then Exit;
  SearchFor := nil;
  pBuf      := nil;
  // open file as binary, 1 byte recordsize
  AssignFile(F, FileName);
  oldMode  := FileMode;
  FileMode := 0;    // read-only access
  Reset(F, 1);
  FileMode := oldMode;
  try // allocate memory for buffer and pchar search string
    SearchFor := StrAlloc1(Length(forString) + 1);
    StrPCopy(SearchFor, forString);
    if not caseSensitive then  // convert to upper case
      AnsiUpper(SearchFor);
    GetMem(pBuf, BufferSize);
    filesize       := System.Filesize(F);
    bytesRemaining := filesize;
    pPos           := nil;
    while bytesRemaining > 0 do
    begin
      // calc how many bytes to read this round
      if bytesRemaining >= BufferSize then
        bytesToRead := Pred(BufferSize)
      else
        bytesToRead := bytesRemaining;
      // read a buffer full and zero-terminate the buffer
      BlockRead(F, pBuf^, bytesToRead, bytesToRead);
      pEnd  := @pBuf[bytesToRead];
      pEnd^ := #0;
      pScan := pBuf;
      while pScan < pEnd do
      begin
        if not caseSensitive then // convert to upper case
          AnsiUpper(pScan);
        pPos := StrPos(pScan, SearchFor);  // search for substring
        if pPos <> nil then
        begin // Found it!
          Result := FileSize - bytesRemaining + Longint(pPos) - Longint(pBuf);
          Break;
        end;
        pScan := StrEnd(pScan);
        Inc(pScan);
      end;
      if pPos <> nil then Break;
      bytesRemaining := bytesRemaining - bytesToRead;
      if bytesRemaining > 0 then
      begin
        Seek(F, FilePos(F) - Length(forString));
        bytesRemaining := bytesRemaining + Length(forString);
      end;
    end; // While
  finally
    CloseFile(F);
    if SearchFor <> nil then StrDispose(SearchFor);
    if pBuf <> nil then FreeMem(pBuf, BufferSize);
  end;
end; // ScanFile

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

// Jetzt kommen die Suche-Routinen! -> OHNE Datumsabfrage und Größe
procedure GetFilesInDirectory(Directory: string; const Mask: string; List: TStrings; WithSubDirs, ClearList: Boolean);
  procedure ScanDir(const Directory: string);
  var
    faHidden: Byte;
    SR: TSearchRec;
    MaskArray: TStringDynArray;
    Maske: String;
    FileAttrs: Integer;
  begin
    FileAttrs := 0;
    faHidden  := 2;
    MaskArray := SplitString(Mask, '|');

    if Suche_Form.HiddenCheckbox.State = cbUnchecked then
      FileAttrs := faAnyFile - faHidden - faSysfile
    else
      FileAttrs := faAnyFile; // faDirectory + faHidden + faSysfile;

    // Im MaskArray sind alle Suchmasken zu finden...
    for Maske in MaskArray do
      if FindFirst(Directory + Maske, FileAttrs, SR) = 0 then
        try
          repeat
            // Auch Verzeichnisse anzeigen
            if (SR.Name <> '.') and (SR.Name <> '..') then
            begin
              // Anzeige der Dateien und Verzeichnisse
              if (((SR.Attr and faDirectory) <> 0) and ((Suche_Form.FilesFoldersCB.ItemIndex = 0) or (Suche_Form.FilesFoldersCB.ItemIndex = 2))) then
              begin
                List.Add('[' + Directory + SR.FindData.cFileName + ']');
                Inc(Zaehler);
              end else
                // Nur Anzeige der Dateien
                if Suche_Form.TextCB.Text = '' then
                begin
                  if (((SR.Attr and faDirectory) = 0) and ((Suche_Form.FilesFoldersCB.ItemIndex = 0) or (Suche_Form.FilesFoldersCB.ItemIndex = 1))) then
                    // Prüfung auf die Suchmaske
                    if MatchesMask(String(SR.FindData.cFileName), Maske) then
                      List.Add(Directory + SR.FindData.cFileName);
                end else
                begin
                  if ((SR.Attr and faDirectory) = 0) and ((Suche_Form.FilesFoldersCB.ItemIndex = 0) or (Suche_Form.FilesFoldersCB.ItemIndex = 1)) and
                      (ScanFile(Directory + SR.FindData.cFileName, Suche_Form.TextCB.Text, False) >= 0) then
                    if MatchesMask(String(SR.FindData.cFileName), Maske) then // Prüfung auf die Suchmaske
                      List.Add(Directory + SR.FindData.cFileName);
                end;
            end;
          until FindNext(SR) <> 0;
        finally
          FindClose(SR);
        end;
    if WithSubDirs then
    begin
      if FindFirst(Directory + '*.*', faAnyFile, SR) = 0 then
        try
          repeat
            if ((SR.Attr and faDirectory) = faDirectory) and (SR.Name <> '.') and (SR.Name <> '..') then
              ScanDir(Directory + SR.FindData.cFileName + '\');
            if StopSuche then
              Break;
          until FindNext(SR) <> 0;
        finally
          FindClose(SR);
        end;
      Application.ProcessMessages;
    end;
    Anzeige := Directory;
    Suche_Form.Timer1.Enabled := True;
    List.EndUpdate;
  end;

begin
  List.BeginUpdate;
  try
    if ClearList then
      List.Clear;
    if Directory = '\' then
      Exit;
    ScanDir(IncludeTrailingBackslash(Directory));
  finally
    // List.EndUpdate;
  end;
end;

// Jetzt kommen die Suche-Routinen!  -> MIT Datumsabfrage und/oder Größe
procedure GetFilesInDirectory_DateSize(Directory: string; const Mask: string;
  List: TStrings; MinMaxFileSize: Int64; WithSubDirs, ClearList: Boolean);
  procedure ScanDir(const Directory: string);
  var
    faHidden: Byte;
    FileAttrs, r1, r2: Integer;
    SR: TSearchRec;
    MaskArray: TStringDynArray;
    Maske: String;
  begin
    FileAttrs := 0;
    faHidden  := 2;
    MaskArray := SplitString(Mask, '|');

    if Suche_Form.HiddenCheckbox.State = cbUnchecked then
      FileAttrs := faAnyFile - faHidden - faSysfile
    else
      FileAttrs := faAnyFile; // faDirectory + faHidden + faSysfile;

    // Im MaskArray sind alle Suchmasken zu finden...
    for Maske in MaskArray do
      if FindFirst(Directory + Maske, FileAttrs, SR) = 0 then
        try
          repeat
            if (SR.Name <> '.') and (SR.Name <> '..') then
            begin
              // Anzeige Dateien/Verzeichnisse und Verzeichnisse (faDirectory <> 0)
              if (((SR.Attr and faDirectory) <> 0) and ((Suche_Form.FilesFoldersCB.ItemIndex = 0) or (Suche_Form.FilesFoldersCB.ItemIndex = 2))) then
              begin
                if Suche_Form.DatumCheckBox.Checked then
                begin
                  r1 := CompareDateTime(SR.TimeStamp, Suche_Form.SearchMinDate.DateTime);
                  r2 := CompareDateTime(SR.TimeStamp, Suche_Form.SearchMaxDate.DateTime);
                  if ((r1 = 0) or (r1 = 1)) and ((r2 = 0) or (r2 = -1)) then
                  begin
                    if (Suche_Form.FilesFoldersCB.ItemIndex = 1) then // Anzeige Dateien
                      List.Add(Directory + SR.FindData.cFileName)
                    else
                      List.Add('[' + Directory + SR.FindData.cFileName + ']');
                    Inc(Zaehler);
                  end;
                end else
                begin
                  if (Suche_Form.FilesFoldersCB.ItemIndex = 1) then // Anzeige Dateien
                    List.Add(Directory + SR.FindData.cFileName)
                  else
                    List.Add('[' + Directory + SR.FindData.cFileName + ']');
                  Inc(Zaehler);
                end;
              end else
              // Nur Anzeige Dateien (faDirectory = 0)
              if (((SR.Attr and faDirectory) = 0) and ((Suche_Form.FilesFoldersCB.ItemIndex = 0) or (Suche_Form.FilesFoldersCB.ItemIndex = 1))) then
              begin
                if Suche_Form.DatumCheckBox.Checked then
                begin
                  r1 := CompareDateTime(SR.TimeStamp, Suche_Form.SearchMinDate.DateTime);
                  r2 := CompareDateTime(SR.TimeStamp, Suche_Form.SearchMaxDate.DateTime);
                  if ((r1 = 0) or (r1 = 1)) and ((r2 = 0) or (r2 = -1)) then
                  if Suche_Form.TextCB.Text = '' then // Datei(en) anzeigen, keine Verzeichnisse, Textsuche ist leer
                  begin
                    if not Suche_Form.DateiCheckBox.Checked then
                    begin
                      if MatchesMask(String(SR.FindData.cFileName), Maske) then // Prüfung auf die Suchmaske
                        List.Add(Directory + SR.FindData.cFileName)
                    end else
                    // Dateigröße nun soll mitgesucht werden
                    if Suche_Form.DateiCheckBox.Checked then
                    begin
                    if ((Suche_Form.FileSizeCombo.ItemIndex = 0) and (SR.Size = MinMaxFileSize)) or
                       ((Suche_Form.FileSizeCombo.ItemIndex = 1) and (SR.Size > MinMaxFileSize)) or
                       ((Suche_Form.FileSizeCombo.ItemIndex = 2) and (SR.Size < MinMaxFileSize)) then
                      if MatchesMask(String(SR.FindData.cFileName), Maske) then // Prüfung auf die Suchmaske
                        List.Add(Directory + SR.FindData.cFileName);
                    end;
                  end else
                  if Suche_Form.TextCB.Text <> '' then // Datei(en) anzeigen, keine Verzeichnisse, mit Textsuche
                  begin
                    if not Suche_Form.DateiCheckBox.Checked then
                    begin
                      if ScanFile(Directory + SR.FindData.cFileName, Suche_Form.TextCB.Text, False) >= 0 then
                        if MatchesMask(String(SR.FindData.cFileName), Maske) then // Prüfung auf die Suchmaske
                          List.Add(Directory + SR.FindData.cFileName)
                    end else
                    // Dateigröße nun soll mitgesucht werden
                    if Suche_Form.DateiCheckBox.Checked then
                    begin
                      if ((Suche_Form.FileSizeCombo.ItemIndex = 0) and (SR.Size = MinMaxFileSize)) or
                         ((Suche_Form.FileSizeCombo.ItemIndex = 1) and (SR.Size > MinMaxFileSize)) or
                         ((Suche_Form.FileSizeCombo.ItemIndex = 2) and (SR.Size < MinMaxFileSize)) and
                          (ScanFile(Directory + SR.Name, Suche_Form.TextCB.Text, False) >= 0) then
                      if MatchesMask(String(SR.FindData.cFileName), Maske) then // Prüfung auf die Suchmaske
                        List.Add(Directory + SR.FindData.cFileName);
                    end;
                  end;
                end else
                // NUR die Dateigröße soll mitgesucht werden
                if Suche_Form.DateiCheckBox.Checked then
                begin
                if ((Suche_Form.FileSizeCombo.ItemIndex = 0) and (SR.Size = MinMaxFileSize)) or
                   ((Suche_Form.FileSizeCombo.ItemIndex = 1) and (SR.Size > MinMaxFileSize)) or
                   ((Suche_Form.FileSizeCombo.ItemIndex = 2) and (SR.Size < MinMaxFileSize)) then
                  if MatchesMask(String(SR.FindData.cFileName), Maske) then // Prüfung auf die Suchmaske
                    List.Add(Directory + SR.FindData.cFileName);
                end;
              end;
            end;
          until FindNext(SR) <> 0;
        finally
          FindClose(SR);
        end;
    if WithSubDirs then
    begin
      if FindFirst(Directory + '*.*', faAnyFile, SR) = 0 then
        try
          repeat
            if ((SR.Attr and faDirectory) = faDirectory) and (SR.Name <> '.') and (SR.Name <> '..') then
              ScanDir(Directory + SR.FindData.cFileName + '\');
            if StopSuche then
            begin
              Suche_Form.StatusBar1.Panels[0].Text := 'Suche abgebrochen...';
              Break;
            end;
          until FindNext(SR) <> 0;
        finally
          FindClose(SR);
        end;
      Application.ProcessMessages;
    end;
    Anzeige := Directory;
    Suche_Form.Timer1.Enabled := True;
    List.EndUpdate;
  end;

begin
  List.BeginUpdate;
  try
    if ClearList then
      List.Clear;
    if Directory = '\' then
      Exit;
    ScanDir(IncludeTrailingBackslash(Directory));
  finally
    // List.EndUpdate;
  end;
end;

// Jetzt kommen die Suche-Routinen!  -> MIT Altersabfrage und Größe
procedure GetFilesInDirectory_Age(Directory: string; const Mask: string; List: TStrings; MinMaxFileSize: Int64; WithSubDirs, ClearList: Boolean);
  procedure ScanDir(const Directory: string);
  var
    faHidden: Byte;
    FileAttrs, r1: Integer;
    SR: TSearchRec;
    MaskArray: TStringDynArray;
    Maske: String;
  begin
    FileAttrs := 0;
    faHidden  := 2;
    MaskArray := SplitString(Mask, '|');

    if Suche_Form.HiddenCheckbox.State = cbUnchecked then
      FileAttrs := faAnyFile - faHidden - faSysfile
    else
      FileAttrs := faAnyFile; // faDirectory + faHidden + faSysfile;

    // Im MaskArray sind alle Suchmasken zu finden...
    for Maske in MaskArray do
      if FindFirst(Directory + Maske, FileAttrs, SR) = 0 then
        try
          repeat
            if (SR.Name <> '.') and (SR.Name <> '..') then
            begin
              // Anzeige Dateien/Verzeichnisse und Verzeichnisse (faDirectory <> 0)
              if (((SR.Attr and faDirectory) <> 0) and ((Suche_Form.FilesFoldersCB.ItemIndex = 0) or (Suche_Form.FilesFoldersCB.ItemIndex = 2))) then
              begin
                if Suche_Form.AlterCB.Checked then
                begin
                  // Stunden, Tage, Wochen, Monate, Jahre
                  r1 := CompareDate(SR.TimeStamp, Suche_Form.DTP.Date);
                  if (r1 = 0) or (r1 = 1) then
                  begin
                    if (Suche_Form.FilesFoldersCB.ItemIndex = 1) then // Anzeige Dateien
                      List.Add(Directory + SR.FindData.cFileName)
                    else
                      List.Add('[' + Directory + SR.FindData.cFileName + ']');
                    Inc(Zaehler);
                  end;
                end
              end else
              // Nur Anzeige Dateien (faDirectory = 0)
              if (((SR.Attr and faDirectory) = 0) and ((Suche_Form.FilesFoldersCB.ItemIndex = 0) or (Suche_Form.FilesFoldersCB.ItemIndex = 1))) then
              begin
                if Suche_Form.AlterCB.Checked then
                begin
                  r1 := CompareDateTime(SR.TimeStamp, Suche_Form.DTP.DateTime);
                  if (r1 = 0) or (r1 = 1) then
                  if Suche_Form.TextCB.Text = '' then // Datei(en) anzeigen, keine Verzeichnisse, Textsuche ist leer
                  begin
                    if not Suche_Form.DateiCheckBox.Checked then
                    begin
                      if MatchesMask(String(SR.FindData.cFileName), Maske) then // Prüfung auf die Suchmaske
                        List.Add(Directory + SR.FindData.cFileName)
                    end else
                    // Dateigröße nun soll mitgesucht werden
                    if Suche_Form.DateiCheckBox.Checked then
                    begin
                    if ((Suche_Form.FileSizeCombo.ItemIndex = 0) and (SR.Size = MinMaxFileSize)) or
                       ((Suche_Form.FileSizeCombo.ItemIndex = 1) and (SR.Size > MinMaxFileSize)) or
                       ((Suche_Form.FileSizeCombo.ItemIndex = 2) and (SR.Size < MinMaxFileSize)) then
                      if MatchesMask(String(SR.FindData.cFileName), Maske) then // Prüfung auf die Suchmaske
                        List.Add(Directory + SR.FindData.cFileName);
                    end;
                  end else
                  if Suche_Form.TextCB.Text <> '' then // Datei(en) anzeigen, keine Verzeichnisse, mit Textsuche
                  begin
                    if not Suche_Form.DateiCheckBox.Checked then
                    begin
                      if ScanFile(Directory + SR.FindData.cFileName, Suche_Form.TextCB.Text, False) >= 0 then
                        if MatchesMask(String(SR.FindData.cFileName), Maske) then // Prüfung auf die Suchmaske
                          List.Add(Directory + SR.FindData.cFileName)
                    end else
                    // Dateigröße nun soll mitgesucht werden
                    if Suche_Form.DateiCheckBox.Checked then
                    begin
                    if ((Suche_Form.FileSizeCombo.ItemIndex = 0) and (SR.Size = MinMaxFileSize)) or
                       ((Suche_Form.FileSizeCombo.ItemIndex = 1) and (SR.Size > MinMaxFileSize)) or
                       ((Suche_Form.FileSizeCombo.ItemIndex = 2) and (SR.Size < MinMaxFileSize)) and
                        (ScanFile(Directory + SR.FindData.cFileName, Suche_Form.TextCB.Text, False) >= 0) then
                      if MatchesMask(String(SR.FindData.cFileName), Maske) then // Prüfung auf die Suchmaske
                        List.Add(Directory + SR.FindData.cFileName);
                    end;
                  end;
                end;
              end;
            end;
          until FindNext(SR) <> 0;
        finally
          FindClose(SR);
        end;
    if WithSubDirs then
    begin
      if FindFirst(Directory + '*.*', faAnyFile, SR) = 0 then
        try
          repeat
            if ((SR.Attr and faDirectory) = faDirectory) and (SR.Name <> '.') and (SR.Name <> '..') then
              ScanDir(Directory + SR.FindData.cFileName + '\');
            if StopSuche then
            begin
              Suche_Form.StatusBar1.Panels[0].Text := 'Suche abgebrochen...';
              Break;
            end;
          until FindNext(SR) <> 0;
        finally
          FindClose(SR);
        end;
      Application.ProcessMessages;
    end;
    Anzeige := Directory;
    Suche_Form.Timer1.Enabled := True;
    List.EndUpdate;
  end;

begin
  List.BeginUpdate;
  try
    if ClearList then
      List.Clear;
    if Directory = '\' then
      Exit;
    ScanDir(IncludeTrailingBackslash(Directory));
  finally
    // List.EndUpdate;
  end;
end;

// Start der Suche durch Klick auf den Suche-Button1
procedure TSuche_Form.StartSearchButtonClick(Sender: TObject);
var
  Path, Mask: String;
  MinMaxFileSize: Int64;
begin
  // Horizontaler Scrollbalken wird entfernt...
  flbHorzScrollWidth := 0;
  Listbox1.Perform(LB_SETHORIZONTALEXTENT, 0, 0);

  if not System.SysUtils.DirectoryExists(SearchField.Text) then
  begin
    MessageDlgCenter('Suchpfad nicht gefunden!' + #13 + SearchField.Text, mtwarning, [mbOk]);
    if Einstellungen_Form.SystemklangCB.Checked then
      PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
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
  ListBox1.Sorted := True;
  FreePDF64_Form.Memo1.Clear;
  StatusBar1.Panels[1].Text := '';
  Path := IncludeTrailingBackslash(SearchField.Text);
  Mask := FileField.Text;
  StopSuche := False;
  StartSearchButton.Enabled := False;
  StopSearchButton.Caption := 'Suche abbrechen';

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

  // Reset time, so that all files of the current day can be found
  SearchMinDate.Time := Time;
  SearchMaxDate.Time := StrToTime('23:59:59');

  // Suche nach Größe...
  if Length(FileSize.Text) > 0 then
  begin
    if SizeAuswahl.ItemIndex = 0 then // Byte
    begin
      try
        MinMaxFileSize := StrToInt(FileSize.Text)
      except
        on EConvertError do
          MinMaxFileSize := 0;
      end;
    end;
    if SizeAuswahl.ItemIndex = 1 then // KB
    begin
      try
        MinMaxFileSize := StrToInt(FileSize.Text) * 1024
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
        MinMaxFileSize := StrToInt64(FileSize.Text) * (1024 * 1024 * 1024);
      except
        on EConvertError do
          MinMaxFileSize := 0;
      end;
    end;
  end;

  // Suchfelder-Einträge hinzufügen
  if SearchField.Items.IndexOf(SearchField.Text) < 0 then
    SearchField.Items.Insert(0, SearchField.Text);
  if FileField.Items.IndexOf(FileField.Text) < 0 then
    FileField.Items.Insert(0, FileField.Text);
  if TextCB.Items.IndexOf(TextCB.Text) < 0 then
    TextCB.Items.Insert(0, TextCB.Text);

  if Path <> '' then
  begin
    if Mask = ''  then
      Mask := '*.*';
    if Mask = '*.*' then
      Mask := '*';

    try
      // Wenn "Nicht älter als" angekreuzt ist und/oder auch nach einer bestimmten Größe damit gesucht wird...
      if AlterCB.Checked then
      begin
        // Get the current date and time and write into DTP
        DTP.Date := Date;
        DTP.Time := Time;
        if AgeAuswahl.ItemIndex = 0 then // Stunden
          DTP.DateTime := IncHour(DTP.DateTime, - AgeSizeEdit.Value);
        if AgeAuswahl.ItemIndex = 1 then // Tage
          DTP.DateTime := IncDay(DTP.Date, - AgeSizeEdit.Value);
        if AgeAuswahl.ItemIndex = 2 then // Wochen
          DTP.DateTime := IncWeek(DTP.Date, - AgeSizeEdit.Value);
        if AgeAuswahl.ItemIndex = 3 then // Monate
          DTP.DateTime := IncMonth(DTP.Date, - AgeSizeEdit.Value);
        if AgeAuswahl.ItemIndex = 4 then // Jahre
          DTP.DateTime := IncYear(DTP.Date, - AgeSizeEdit.Value);
        // In DTP.DateTime steht nun das gewünschte Datum/Uhrzeit!
        GetFilesInDirectory_Age(Path, Mask, ListBox1.Items, MinMaxFileSize, DirCheckbox.Checked, True)
      end else
      // Wenn "Datum zwischen" angekreuzt ist oder nach einer bestimmten Größe gesucht wird...
      if DatumCheckBox.Checked or DateiCheckBox.Checked then
        GetFilesInDirectory_DateSize(Path, Mask, ListBox1.Items, MinMaxFileSize, DirCheckbox.Checked, True)
      else
        // Rufe die Suchefunktion zum Durchsuchen des Ordners auf
        GetFilesInDirectory(Path, Mask, ListBox1.Items, DirCheckbox.Checked, True);
    finally
      // Search has terminated, updates buttons and mouse cursor accordingly
      StartSearchButton.Enabled := True;
      StopSearchButton.Caption  := 'Abbrechen';
    end;
  end else
    // Wenn der Suchpfad leer ist
    Showmessage('Bitte geben Sie einen gültigen Suchpfad ein.');

  if Einstellungen_Form.SystemklangCB.Checked then
    PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\standard.wav');

  if StopSuche then
    Suche_Form.StatusBar1.Panels[0].Text := Suche_Form.StatusBar1.Panels[0].Text + ' - Suche abgebrochen';

  if ListBox1.Count = 0 then
  begin
    StatusBar1.Panels[0].Text := '';
    StatusBar1.Panels[1].Text := '';
  end;

  if ListBox1.Count > 1 then
  begin
    SuchergebnisBtn.Enabled    := True;
    SortBtn.Enabled            := True;
    StatusBar1.Panels[1].Text  := 'Markiert: ' + IntToStr(ListBox1.SelCount);
    StatusBar1.Canvas.Font     := StatusBar1.Font;
    StatusBar1.Panels[0].Width := ListBox1.Width - (Canvas.TextWidth(StatusBar1.Panels[1].Text) + 36);
  end else
  begin
    SuchergebnisBtn.Enabled := False;
    SortBtn.Enabled         := False;
  end;

  // Nach Ende der Suche - wo ist der Fokus?
  if ListBox1.Count = 0 then
    FileField.SetFocus
  else
  begin
    ListBox1.Selected[0] := True;
    ListBox1.SetFocus;
  end;

  if ListBox1.SelCount > 0 then
    StatusBar1.Panels[1].Text := 'Markiert: ' + IntToStr(ListBox1.SelCount);
end;

procedure TSuche_Form.StopSearchButtonClick(Sender: TObject);
begin
  if StartSearchButton.Enabled then
  begin
    SucheEdit.Visible     := False;
    AnzeigenPanel.Visible := False;
    Close;
  end else
  begin
    StopSuche := True;
    StopSearchButton.Caption := 'Abbrechen';
  end;
end;

procedure TSuche_Form.SearchFieldDropDown(Sender: TObject);
var
  i: Integer;
begin
  if SearchField.Items.IndexOf(SearchField.Text) < 0 then
    SearchField.Items.Insert(0, SearchField.Text);

  for i := SearchField.Items.Count downto 0 do
    if SearchField.Items.Strings[i] = '' then
      SearchField.Items.Delete(i);
end;

// Sortiert die Verzeichnis(se) nach oben
procedure MoveItemsWithBracketToTop(ListBox: TListBox);
var
  i, j: Integer;
  TempList: TStringList;
begin
  TempList := TStringList.Create;
  try
    // Zuerst die Items, die mit '[' beginnen, in TempList verschieben
    for i := 0 to ListBox.Items.Count - 1 do
    begin
      if ListBox.Items[i].StartsWith('[') then
        TempList.Add(ListBox.Items[i]);
    end;
    // Die Items, die mit '[' beginnen, aus der ListBox entfernen
    for i := ListBox.Items.Count - 1 downto 0 do
    begin
      if ListBox.Items[i].StartsWith('[') then
        ListBox.Items.Delete(i);
    end;
    // Die Items aus TempList wieder oben in die ListBox einfügen
    for j := 0 to TempList.Count - 1 do
    begin
      ListBox.Items.Insert(j, TempList[j]);
    end;
  finally
    TempList.Free;
  end;
end;

// ListBox sortieren
procedure TSuche_Form.SortBtnClick(Sender: TObject);
begin
//  LockWindowUpdate(ListBox1.Handle);
  SortBtn.Caption := 'Sortierung läuft...';
  MoveItemsWithBracketToTop(ListBox1);
  SortBtn.Caption := 'Ergebnis umsortieren';
//  LockWindowUpdate(0);

  if ListBox1.Count > 0 then
  begin
    ListBox1.ClearSelection;
    ListBox1.Selected[0] := True;
  end;
end;

procedure TSuche_Form.FileFieldDropDown(Sender: TObject);
var
  i: Integer;
begin
  if FileField.Items.IndexOf(FileField.Text) < 0 then
    FileField.Items.Insert(0, FileField.Text);

  for i := FileField.Items.Count downto 0 do
    if FileField.Items.Strings[i] = '' then
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

// Gehe zum Verzeichnis des Eintrags in der Listbox
procedure TSuche_Form.ListBox1DblClick(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  if (ListBox1.SelCount = 0) or (ListBox1.Count = 0) then
  begin
    MessageDlgCenter('Kein Eintrag gewählt!', mtInformation, [mbOk]);
    Exit;
  end;

  Suche_ItemAnzeigen := True;

  for i := 0 to ListBox1.Count - 1 do
    if ListBox1.Selected[i] then
      s := ListBox1.Items.Strings[i];

  // Prüfe, ob das erste Zeichen ein [ ist - und entfernen
  if Pos('[', s) <> 0 then
    Delete(s, 1, 1);
  // Prüfe, ob das letzte Zeichen ein ] ist - und entfernen
  if s[Length(s)] = ']' then
    Delete(s, Length(s), 1);

  FreePDF64_Form.BringToFront;
  if Links then
  begin
    FreePDF64_Form.LMDShellFolder1.ChDir(ExtractFilePath(s));
    for i := 0 to FreePDF64_Form.LMDShellList1.Items.Count - 1 do
    begin
      if FreePDF64_Form.LMDShellList1.Items[i].Caption = ExtractFileName(s) then
      begin
        FreePDF64_Form.LMDShellList1.ItemFocused := FreePDF64_Form.LMDShellList1.Items.Item[i];
        FreePDF64_Form.LMDShellList1.Selected    := FreePDF64_Form.LMDShellList1.Items.Item[i];

        FreePDF64_Form.LMDShellList1.SetFocus;
        FreePDF64_Form.LMDShellList1.Items.Item[i].MakeVisible(False);
        If DirectoryExists(s) then
          FreePDF64_Form.LMDShellFolder1.ChDir(s);
      end;
    end;
  end else
  begin
    FreePDF64_Form.LMDShellFolder2.ChDir(ExtractFilePath(s));
    for i := 0 to FreePDF64_Form.LMDShellList2.Items.Count - 1 do
    begin
      if FreePDF64_Form.LMDShellList2.Items[i].Caption = ExtractFileName(s) then
      begin
        FreePDF64_Form.LMDShellList2.ItemFocused := FreePDF64_Form.LMDShellList2.Items.Item[i];
        FreePDF64_Form.LMDShellList2.Selected    := FreePDF64_Form.LMDShellList2.Items.Item[i];
        FreePDF64_Form.LMDShellList2.SetFocus;
        FreePDF64_Form.LMDShellList2.Items.Item[i].MakeVisible(False);
        If DirectoryExists(s) then
          FreePDF64_Form.LMDShellFolder2.ChDir(s);
      end;
    end;
  end;

  FreePDF64_Form.LMDShellList1.Column[0].AutoSize := True;
  FreePDF64_Form.LMDShellList2.Column[0].AutoSize := True;

  // Wenn im Tray, dann hole Form nach vorne
  if FreePDF64_Form.TrayIcon1.Visible = True then
    FreePDF64_Form.TrayIcon1Click(Sender);

  Close;
end;

// Horizontaler Scrollbalken
procedure TSuche_Form.ListBox1DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
 Len: Integer;
 NewText: String;
begin
  NewText := Listbox1.Items[Index];
  with Listbox1.Canvas do
  begin
    FillRect(Rect);
    TextOut(Rect.Left + 1, Rect.Top, NewText);
    Len:=TextWidth(NewText) + Rect.Left + 10;
    if Len>flbHorzScrollWidth then
    begin
      flbHorzScrollWidth:=Len;
      Listbox1.Perform(LB_SETHORIZONTALEXTENT, flbHorzScrollWidth, 0 );
    end;
  end;

  with (Control as TListBox).Canvas do
  begin
    // Standard Hintergrundfarbe
    Brush.Color := clWindow;
    Font.Color  := clWindowText;
    // Wenn das Element ausgewählt ist
    if (odSelected in State) then
    begin
      // Setze die gewünschte Hintergrundfarbe
      Brush.Color := clGradientActiveCaption;
      // Setze die gewünschte Schriftfarbe
      Font.Color  := clBlack;
    end;
    FillRect(Rect);
    TextOut(Rect.Left + 2, Rect.Top, (Control as TListBox).Items[Index]);
  end
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

  // Alt + linke Maustaste soll markierte Datei öffnen
  if (Button = MBLeft) and (ssAlt in Shift) then
    if FileExists(ListBox1.Items[ListBox1.ItemIndex]) then
      ShellExecute(Handle, 'open', PChar(ListBox1.Items[ListBox1.ItemIndex]), NIL, NIL, SW_SHOWNORMAL);
end;

procedure TSuche_Form.Lschen1Click(Sender: TObject);
begin
  Btn_4.Click;
end;

end.
