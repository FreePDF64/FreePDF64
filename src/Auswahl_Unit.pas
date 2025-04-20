//
// Programmname: FreePDF64
//

unit Auswahl_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ComCtrls, ExtCtrls, FileCtrl, System.UITypes,
  Printers, ShellAPI;

type
  TAuswahl_Form = class(TForm)
    OpenDialog1: TOpenDialog;
    FileList: TListView;
    Hinzufuegen: TBitBtn;
    UpBitBtn: TBitBtn;
    DownBitBtn: TBitBtn;
    MergeViewer: TButton;
    AufgehtsBitBtn: TBitBtn;
    EntfernenBitBtn: TBitBtn;
    CancelBtbtn: TBitBtn;
    EinstellungenBtn: TButton;
    procedure FormShow(Sender: TObject);
    procedure HinzufuegenClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure UpBitBtnClick(Sender: TObject);
    procedure DownBitBtnClick(Sender: TObject);
    procedure MergeViewerClick(Sender: TObject);
    procedure AufgehtsBitBtnClick(Sender: TObject);
    procedure EntfernenBitBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CancelBtbtnClick(Sender: TObject);
    procedure EinstellungenBtnClick(Sender: TObject);
  private
    { Private-Deklarationen }
    procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo); Message wm_GetMinMaxInfo;
  public
    { Public-Deklarationen }
  end;

var
  Auswahl_Form: TAuswahl_Form;

  // Globale Variablen
  Ausgabe: String;

implementation

uses
  FreePDF64_Unit, Einstellungen_Unit, DokuInfo_Unit, FreePDF64_Notify_Unit;

{$R *.DFM}

procedure TAuswahl_Form.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
begin
  inherited;
  with Msg.MinMaxInfo^ do
  begin
     ptMinTrackSize.x:= 531;
     ptMinTrackSize.y:= 390;
  end
end;

procedure TAuswahl_Form.EntfernenBitBtnClick(Sender: TObject);
begin
// markierte Einträge aus Liste entfernen.
  with FileList do
    while Selected <> NIL do
      Items.Delete(Items.IndexOf(Selected));
  FileList.Columns[0].Caption := 'Datei(en): ' + IntToStr(FileList.Items.Count) + AUSGABE;
end;

// MessageDlg zentriert
function MessageDlgCenter(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;
var
  R: TRect;
begin
  if not Assigned(Screen.ActiveForm) then
  begin
    Result := MessageDlg(Msg, DlgType, Buttons, 0);
  end else
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

procedure TAuswahl_Form.FormShow(Sender: TObject);
begin
  // Komplette FileList löschen.
  FileList.Items.Clear;
  Hinzufuegen.SetFocus;
  FileList.Columns[0].Caption := 'Datei(en): ' + IntToStr(FileList.Items.Count) + AUSGABE;
  Auswahl_Form.Caption := 'Dateien auswählen! Zielname ist: ' + MinimizeName(MERGEDATEI, Auswahl_Form.Canvas, 100);
  ABBRUCH := False;
  MergeViewer.Hint := 'Markierte Datei anzeigen...' + #10#13 +
                      '- wenn Ghostscript Image -> [ Eingabetaste ] für Weiter, [ STRG+C ] für Abbrechen' + #10#13 +
                      '- sonst mit dem eingestellten PDF-Anzeiger';
end;

procedure TAuswahl_Form.HinzufuegenClick(Sender: TObject);
var
  ifile, ilist: Integer;
  NewItem: TListItem;
begin
  OpenDialog1.FileName := '';
  OpenDialog1.InitialDir := Ziel;
  // Datei-Dialog anzeigen (MultiSelect ist True).
  with OpenDialog1 do
  if Execute then
    // alle markierten Dateien durchlaufen.
    for ifile := 0 to Files.Count - 1 do
    begin
      // zuerst nachschauen, ob bereits in der Liste.
      for ilist := 0 to FileList.Items.Count - 1 do
      begin
        if FileList.Items[ilist].Caption = Files[ifile] then
        begin
          Break;
        end;
      end;
      begin
        NewItem := FileList.Items.Add;
        // Beschriftung auf Dateinamen setzen.
        NewItem.Caption := Files[ifile];
      end;
    end;
  FileList.Columns[0].Caption := 'Datei(en): ' + IntToStr(FileList.Items.Count) + AUSGABE;
end;

// Markierte Datei soll in der Liste nach oben verschoben werden!
procedure TAuswahl_Form.UpBitBtnClick(Sender: TObject);
var
  Item1,Item2: TListItem;
  s: String;
begin
  if FileList.SelCount < 2 then
  begin
     Item1 := FileList.Selected;
    if (not Assigned(Item1)) or (Item1.Index = 0) then Exit;

    // Wenn das vorige Feld leer ist, dann...
    if FileList.Items[Item1.Index - 1] = NIL then Exit;

    Item2 := FileList.Items[Item1.Index - 1];
    s := Item2.Caption;
    Item2.Caption := Item1.Caption;
    Item1.Caption := s;

    FileList.Selected := NIL;
    Item2.Selected    := True
  end else
  begin
    FileList.Selected := NIL;
    ShowMessage('Nur eine Datei zum Verschieben auswählen!');
    ABBRUCH := True;
  end;
end;

// Markierte Datei soll in der Liste nach unten verschoben werden!
procedure TAuswahl_Form.EinstellungenBtnClick(Sender: TObject);
begin
  Einstellungen_Form.Position := poMainFormCenter;
  FreePDF64_Form.Einstellungen1.Click;

  FreePDF64_Form.StatusBar1.SimpleText := 'Drucker: ' + printer.printers[printer.printerindex];
  if FreePDF64_Form.FilterTB.ImageIndex = 69 then
    FreePDF64_Form.StatusBar1.SimpleText := FreePDF64_Form.StatusBar1.SimpleText + ' | Dateifilter: AN'
  else
    FreePDF64_Form.StatusBar1.SimpleText := FreePDF64_Form.StatusBar1.SimpleText + ' | Dateifilter: AUS';
  if FreePDF64_Notify.LMDShellNotify.Active then
    FreePDF64_Form.StatusBar1.SimpleText := FreePDF64_Form.StatusBar1.SimpleText + ' | Überwachung: AN'
  else
    FreePDF64_Form.StatusBar1.SimpleText := FreePDF64_Form.StatusBar1.SimpleText + ' | Überwachung: AUS';
  if Einstellungen_Form.AnzeigenCB.Checked then
    FreePDF64_Form.StatusBar1.SimpleText := FreePDF64_Form.StatusBar1.SimpleText + ' | Anzeigen: AN'
  else
  if Einstellungen_Form.AnzeigenCB.Checked = False then
    FreePDF64_Form.StatusBar1.SimpleText := FreePDF64_Form.StatusBar1.SimpleText + ' | Anzeigen: AUS'
  else
  if Einstellungen_Form.AnzeigenCB.Checked then
    FreePDF64_Form.StatusBar1.SimpleText := FreePDF64_Form.StatusBar1.SimpleText + ' | Anzeigen: AN'
  else
  if Einstellungen_Form.AnzeigenCB.Checked = False then
    FreePDF64_Form.StatusBar1.SimpleText := FreePDF64_Form.StatusBar1.SimpleText + ' | Anzeigen: AUS'
end;

procedure TAuswahl_Form.CancelBtbtnClick(Sender: TObject);
begin
  ABBRUCH := True;
  Exit;
//  Close;
end;

procedure TAuswahl_Form.DownBitBtnClick(Sender: TObject);
var
  Item1,Item2: TListItem;
  s: String;
begin
  if FileList.SelCount < 2 then
  begin
    Item1 := FileList.Selected;
    if (not Assigned(Item1)) or (Item1.Index = FileList.Items.Count - 1) then Exit;

    // Wenn das nächste Feld leer ist, dann...
    if FileList.Items[Item1.Index + 1] = NIL then Exit;

    Item2 := FileList.Items[Item1.Index + 1];
    s := Item2.Caption;
    Item2.Caption := Item1.Caption;
    Item1.Caption := s;

    FileList.Selected := NIL;
    Item2.Selected    := True
  end else
  begin
    FileList.Selected := NIL;
    ShowMessage('Jeweils nur eine Datei zum Verschieben auswählen!');
    ABBRUCH := True;
  end;
end;

procedure TAuswahl_Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    CancelBtbtn.Click;
end;

procedure TAuswahl_Form.AufgehtsBitBtnClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TAuswahl_Form.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Close;
end;

// Task schließen (hier Ghostscript)
procedure KillTask(ExeFileName: string);
var
  H: HWND;
begin //ExeFileName = caption or cmd path
   H := FindWindow(nil, LPCWSTR(ExeFileName));
   if H <> 0 then
    PostMessage(H, WM_CLOSE, 0, 0);
end;

// Vorschau
procedure TAuswahl_Form.MergeViewerClick(Sender: TObject);
var
  i: Integer;
begin
  // Wo liegt das Ghostscript-Programm?
  Ghostscript := Einstellungen_Form.Edit1.Text;

  for i := 0 to FileList.Items.Count - 1 do
  begin
    Auswahl := FileList.Items[i].Caption;
    if FileList.Items[i].Selected then
    begin
      if Uppercase(ExtractFileExt(Auswahl)) <> ('.PDF') then
      begin
        Application.ProcessMessages;
        // Ghostscript aufrufen...
        ShellExecute(Application.Handle, 'open', PChar(Ghostscript), PChar('-dSAFER -dBATCH -r120 "' + Auswahl + '"'),'', SW_HIDE);
        MessageDlgCenter('Anzeigen beendet!', mtInformation, [mbOk]);
        KillTask(Ghostscript);
        FileList.Items[i].Selected := False;
        if FileList.SelCount > 0 then
          if MessageDlgCenter('Abbruch?', mtInformation, [mbYes, mbNo]) = mrYes then
            Break;
      end else
      begin
        if Einstellungen_Form.Edit3.Text = '' then
          PDFReader := ExtractFilePath(Application.ExeName) + 'xpdf\xpdfreader\xpdf.exe'
        else
          PDFReader := Einstellungen_Form.Edit3.Text;
        Application.ProcessMessages;
        // PDF-Anzeiger aufrufen...
        ShellExecute(Application.Handle, 'open', PChar(PDFReader), PChar('"' + Auswahl + '"'), '', SW_NORMAL);
        KillTask(Einstellungen_Form.Edit3.Text);
        FileList.Items[i].Selected := False;
      end;
    end;
  end;
  Hinzufuegen.SetFocus;
end;

end.

