unit Suche_Info_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TSuche_Info = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Suche_Info: TSuche_Info;

implementation

{$R *.dfm}

procedure TSuche_Info.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TSuche_Info.FormCreate(Sender: TObject);
begin
  Position := poMainFormCenter;
  KeyPreview := True;

  // Scrollbares Memo
  Memo1.ScrollBars := ssBoth;
  Memo1.ReadOnly   := True;
  Memo1.WordWrap   := False;

  BorderStyle := bsSizeable;   // Höhe darf verändert werden
end;

procedure TSuche_Info.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Key := 0;   // verhindert Piepton
    Close;
  end;
end;

end.
