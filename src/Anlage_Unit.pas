unit Anlage_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TAnlage_Form = class(TForm)
    Author: TLabel;
    TitelEdit: TEdit;
    AuthorEdit: TEdit;
    BitBtn1: TBitBtn;
    CancelBitBtn1: TBitBtn;
    Titel: TLabel;
    procedure CancelBitBtn1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Anlage_Form: TAnlage_Form;

implementation

{$R *.dfm}

procedure TAnlage_Form.CancelBitBtn1Click(Sender: TObject);
begin
  Close;
end;

end.
