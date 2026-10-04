unit Anleitung_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TAnleitung_Form = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Anleitung_Form: TAnleitung_Form;

implementation

{$R *.dfm}

procedure TAnleitung_Form.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TAnleitung_Form.FormCreate(Sender: TObject);
begin
  Position := poMainFormCenter;
  KeyPreview := True;

  // Scrollbares Memo
  Memo1.ScrollBars := ssBoth;
  Memo1.ReadOnly   := True;
  Memo1.WordWrap   := False;

  BorderStyle := bsSizeable;   // Höhe darf verändert werden
end;

procedure TAnleitung_Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;   // verhindert Piepton
    Close;
  end;
end;

end.
