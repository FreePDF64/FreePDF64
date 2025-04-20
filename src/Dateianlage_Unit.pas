unit Dateianlage_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, LMDUnicodeDialogs, IniFiles;

type
  TDateianlage_Form = class(TForm)
    Hinten: TLabel;
    Vorne: TLabel;
    LMDOpenDialog1: TLMDOpenDialog;
    Datei1: TEdit;
    Datei2: TEdit;
    Datei1Btn: TButton;
    Datei2Btn: TButton;
    DateianlageCB: TCheckBox;
    Clear: TSpeedButton;
    BitBtn1: TBitBtn;
    procedure Datei1BtnClick(Sender: TObject);
    procedure Datei2BtnClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DateianlageCBClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Dateianlage_Form: TDateianlage_Form;

implementation

{$R *.dfm}

procedure TDateianlage_Form.ClearClick(Sender: TObject);
begin
  // Inhalt leeren
  Datei1.Text := '';
  Datei2.Text := '';
  DateianlageCB.Checked := False;
end;

procedure TDateianlage_Form.Datei1BtnClick(Sender: TObject);
begin
  LMDOpenDialog1.InitialDir := ExtractFilePath(Datei1.Text);
  if LMDOpenDialog1.Execute then
    Datei1.Text := LMDOpenDialog1.Filename;
end;

procedure TDateianlage_Form.Datei2BtnClick(Sender: TObject);
begin
  LMDOpenDialog1.InitialDir := ExtractFilePath(Datei2.Text);
  if LMDOpenDialog1.Execute then
    Datei2.Text := LMDOpenDialog1.Filename;
end;

procedure TDateianlage_Form.DateianlageCBClick(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile: String;
begin
  if (Datei1.Text = '') and (Datei2.Text = '') then
  begin
    DateianlageCB.Checked := False;
    Exit;
  end;

  IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
  IniDat := TIniFile.Create(IniFile);
  // Speichere die Dateianlage vorne/hinten in die 'FreePDF64.ini'
  begin
    if DateianlageCB.Checked = False then
    with IniDat do
    begin
      IniDat.DeleteKey('Files', 'Datei Vorne');
      IniDat.DeleteKey('Files', 'Datei Hinten');
    end else
    if DateianlageCB.Checked = True then
    with IniDat do
    begin
      // Dateianlage vorne/hinten schreiben
      WriteString('Files', 'Datei Vorne', Datei1.Text);
      WriteString('Files', 'Datei Hinten', Datei2.Text);
    end;
    // Speicher wird wieder freigeben
    IniDat.Free;
  end;
end;

procedure TDateianlage_Form.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
  begin  if DateianlageCB.Checked = False then
      Clear.Click;
    Close;
  end;
end;

end.
