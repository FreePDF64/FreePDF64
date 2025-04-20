//
// Programmname: FreePDF64
//

unit Beenden_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons;

type
  TBeenden_Form = class(TForm)
    BeendenL: TLabel;
    JaBitBtn: TBitBtn;
    NeinBitBtn: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure NeinBitBtnClick(Sender: TObject);
    procedure JaBitBtnClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Beenden_Form: TBeenden_Form;

implementation

{$R *.DFM}

uses FreePDF64_Unit;

procedure TBeenden_Form.FormShow(Sender: TObject);
begin
  JaBitBtn.SetFocus;
end;

procedure TBeenden_Form.JaBitBtnClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TBeenden_Form.NeinBitBtnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
