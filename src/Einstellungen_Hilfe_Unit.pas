//
// Programmname: FreePDF64
//

unit Einstellungen_Hilfe_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TEinstellungen_Hilfe_Form = class(TForm)
    Memo1: TMemo;
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Einstellungen_Hilfe_Form: TEinstellungen_Hilfe_Form;

implementation

{$R *.dfm}

procedure TEinstellungen_Hilfe_Form.FormShow(Sender: TObject);
begin
  Einstellungen_Hilfe_Form.Height := 860;
  Einstellungen_Hilfe_Form.Width  := 1080;
end;

procedure TEinstellungen_Hilfe_Form.Memo1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    Close;
end;

end.
