unit Splashscreen_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.jpeg;

type
  TSplashscreen_Form = class(TForm)
    Image1: TImage;
    Panel1: TPanel;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Splashscreen_Form: TSplashscreen_Form;

implementation

{$R *.dfm}

uses FreePDF64_Unit;

procedure TSplashscreen_Form.FormShow(Sender: TObject);
begin
  Panel1.Caption:= FreePDF64_Form.LMDVersionInfo1.ProductName + ' Version ' +
                   FreePDF64_Form.LMDVersionInfo1.ProductVersion + ' - 64 bit';
end;

procedure TSplashscreen_Form.Timer1Timer(Sender: TObject);
begin
  Splashscreen_Form.Close;
end;

end.
