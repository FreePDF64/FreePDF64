unit Seiten_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Spin;

type
  TSeiten_Form = class(TForm)
    AusgabeRG: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    VonSE: TSpinEdit;
    BisSE: TSpinEdit;
    Clear: TSpeedButton;
    CancelBitBtn: TBitBtn;
    OkBitBtn: TBitBtn;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure VonSEChange(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure CancelBitBtnClick(Sender: TObject);
    procedure BisSEExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Seiten_Form: TSeiten_Form;

implementation

{$R *.dfm}

procedure TSeiten_Form.ClearClick(Sender: TObject);
begin
  VonSE.Value := 0;
  BisSe.Value := 0;
end;

procedure TSeiten_Form.CancelBitBtnClick(Sender: TObject);
begin
  Seiten_Form.Clear.Click;
  Clear.Click;
end;

procedure TSeiten_Form.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if BisSE.Value <= VonSE.Value then
    VonSE.Value := BisSE.Value;

  Close;
end;

procedure TSeiten_Form.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    Close;
end;

procedure TSeiten_Form.FormShow(Sender: TObject);
begin
  VonSE.SetFocus;
end;

procedure TSeiten_Form.VonSEChange(Sender: TObject);
begin
  if BisSE.Value <= VonSE.Value then
    BisSE.Value := VonSE.Value;
end;

procedure TSeiten_Form.BisSEExit(Sender: TObject);
begin
  if BisSE.Value <= VonSE.Value then
    VonSE.Value := BisSE.Value;
end;

end.
