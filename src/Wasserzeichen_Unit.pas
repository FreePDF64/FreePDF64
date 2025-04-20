// Wasserzeichen/Stempel einer PDF-Datei hinzufügen
unit Wasserzeichen_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, LMDUnicodeDialogs, Vcl.StdCtrls,
  Vcl.Buttons, FileCtrl, IniFiles;

type
  TWasserzeichen_Form = class(TForm)
    LMDOpenDialog1: TLMDOpenDialog;
    Label1: TLabel;
    Edit1: TEdit;
    WZBtn: TButton;
    AufgehtsBitBtn: TBitBtn;
    Edit2: TEdit;
    Label2: TLabel;
    CancelBtbtn: TBitBtn;
    bgWatermark: TCheckBox;
    vgStamp: TCheckBox;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure WZBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CancelBtbtnClick(Sender: TObject);
    procedure bgWatermarkClick(Sender: TObject);
    procedure vgStampClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Wasserzeichen_Form: TWasserzeichen_Form;

implementation

{$R *.dfm}

uses FreePDF64_Unit, Einstellungen_Unit;

procedure TWasserzeichen_Form.bgWatermarkClick(Sender: TObject);
begin
  if bgWatermark.Checked then
  begin
    bgWatermark.Checked := True;
    vgStamp.Checked := False;
  end else
  begin
    bgWatermark.Checked := False;
    vgStamp.Checked := True;
  end;
end;

procedure TWasserzeichen_Form.vgStampClick(Sender: TObject);
begin
  if vgStamp.Checked then
  begin
    vgStamp.Checked := True;
    bgWatermark.Checked := False;
  end else
  begin
    vgStamp.Checked := False;
    bgWatermark.Checked := True;
  end;
end;


procedure TWasserzeichen_Form.CancelBtbtnClick(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile: String;
begin
  try
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.Ini';
    IniDat := TIniFile.Create(IniFile);
    // Speichere beim Beenden des Programmes wichtige Daten in die 'FreePDF64.Ini'
    with IniDat do
    begin
      Wasserzeichen_Form.Edit1.Text := ReadString('Start', 'Watermark/Stamp', Wasserzeichen_Form.Edit1.Text);
      Wasserzeichen_Form.bgWatermark.Checked := ReadBool('Start', 'Watermark bg', Wasserzeichen_Form.bgWatermark.Checked);
      Wasserzeichen_Form.vgStamp.Checked := ReadBool('Start', 'Stamp fg', Wasserzeichen_Form.vgStamp.Checked);
     end;
    // Speicher wird wieder freigeben
    IniDat.Free;
  except
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        FreePDF64_Form.PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
      ShowMessage('Error');
    end;
  end;

  ABBRUCH := True;
  Close;
end;

procedure TWasserzeichen_Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    Close;
end;

procedure TWasserzeichen_Form.FormShow(Sender: TObject);
var
  p: String;
begin
  if FreePDF64_Form.FormatVerz.Checked then
    p := MinimizeName(Ziel, FreePDF64_Form.Canvas, 800) + 'PDF'
  else
    p := MinimizeName(Ziel, FreePDF64_Form.Canvas, 800);

  Edit2.Text := P;
end;

procedure TWasserzeichen_Form.WZBtnClick(Sender: TObject);
begin
  LMDOpenDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  if LMDOpenDialog1.Execute then
    Edit1.Text := LMDOpenDialog1.Filename;
end;

end.
