//
// Programmname: FreePDF64
//
// Favoriten Rechts
//

unit Favoriten2_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TFavoriten2_Form = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    BitBtn2: TBitBtn;
    BitBtn1: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Favoriten2_Form: TFavoriten2_Form;

implementation

uses FreePDF64_Unit;

{$R *.dfm}

procedure TFavoriten2_Form.FormShow(Sender: TObject);
begin
  Edit1.Text := FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName;
  Edit1.SetFocus;
  Edit1.SelectAll;
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

// Zum Schnellzugriff hinzufügen
procedure TFavoriten2_Form.BitBtn1Click(Sender: TObject);
var
  i, j, k: Integer;
  l: String;
begin
  // Es gibt Edit1.Text schon in der Favoritenliste...
  for i := 0 to FreePDF64_Form.ListBoxR.Items.Count - 1 do
    for j := 1 to Length(FreePDF64_Form.ListBoxR.Items[i]) do
    begin
      // Suche nach '*|*'
      k := Pos('*|*', (FreePDF64_Form.ListBoxR.Items[i]));
      if k > 0 then // String wurde entdeckt. k enthält die Position.
      begin
        l := Copy((FreePDF64_Form.ListBoxR.Items[i]), 0, k - 1);
        // l: Enthält nun alles vor dem Trennzeichen...
        if Edit1.Text = l then
        begin
          MessageDlgCenter('Eintrag schon vorhanden! Bitte wähle einen anderen Namen.', mtInformation, [mbOK]);
          Exit;
        end;
      end;
    end;
  // FavLBR nun den Eintrag hinzufügen!
  // Edit1.Text ist gleich dem Ausgangsdirectory...
  if Edit1.Text = FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName then
  begin
    FreePDF64_Form.FavLbR.Items.Add(FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName);
    FreePDF64_Form.ListBoxR.Items.Add(FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName + '*|*' +
                                      FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName);
  end;
  // Edit1.Text ist nicht leer und auch nicht gleich dem Ausgangsdirectory...
  if (Edit1.Text <> '') and (Edit1.Text <> FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName) then
  begin
    FreePDF64_Form.FavLbR.Items.Add(Edit1.Text);
    FreePDF64_Form.ListBoxR.Items.Add(Edit1.Text + '*|*' + FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName);
  end;
  Close;
end;

procedure TFavoriten2_Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then Close;
end;

end.
