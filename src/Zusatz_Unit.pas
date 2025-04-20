unit Zusatz_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TZusatz_Form = class(TForm)
    BitBtn1: TBitBtn;
    ZusatzCB: TComboBox;
    Label1: TLabel;
    Clear: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BitBtn1Click(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    private
      { Private-Deklarationen }
    public
      { Public-Deklarationen }
  end;

var
  Zusatz_Form: TZusatz_Form;

implementation

{$R *.dfm}

uses FreePDF64_Unit;

procedure TZusatz_Form.BitBtn1Click(Sender: TObject);
begin
  // Keine doppelten Einträge zulassen...
  if ZusatzCB.Items.IndexOf(ZusatzCB.Text) = -1 then
    ZusatzCB.Items.Insert(0, ZusatzCB.Text);
end;

procedure TZusatz_Form.ClearClick(Sender: TObject);
begin
  ZusatzCB.Clear;
end;

procedure TZusatz_Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    Close;
end;

procedure TZusatz_Form.FormShow(Sender: TObject);
begin
  ZusatzCB.ItemIndex := 0;
  ZusatzCB.SetFocus;
end;

end.
