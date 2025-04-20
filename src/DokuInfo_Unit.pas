//
// Programmname: FreePDF64
//
// [ /Title (Titel)
//   /Author (Author name)
//   /Subject (Subject description)
//   /Keywords (comma, separated, keywords)
//   /CreationDate (D:20061204092842)
//   /ModDate (D:20061204092842)
//   /Producer (PDF producer name or note)
//   /DOCINFO pdfmark

unit DokuInfo_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms,
  StdCtrls, Buttons, Controls, Dialogs;

type
  TDokuInfo_Form = class(TForm)
    Author: TLabel;
    AuthorEdit: TEdit;
    Subject: TLabel;
    SubjectEdit: TEdit;
    Keywords: TLabel;
    KeywordsEdit: TEdit;
    ModDate: TLabel;
    ModDateEdit: TEdit;
    Creator: TLabel;
    CreatorEdit: TEdit;
    CreationDate: TLabel;
    CreationDateEdit: TEdit;
    Clear: TSpeedButton;
    Titel: TLabel;
    TitelEdit: TEdit;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Info: TButton;
    CancelBitBtn1: TBitBtn;
    BitBtn1: TBitBtn;
    MetadatenCB: TCheckBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure InfoSBClick(Sender: TObject);
    procedure CancelBitBtn1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CreationDateClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ModDateClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  DokuInfo_Form: TDokuInfo_Form;

implementation

uses
  FreePDF64_Unit, Einstellungen_Unit;

{$R *.DFM}

procedure TDokuInfo_Form.FormActivate(Sender: TObject);
begin
  TitelEdit.SetFocus;
end;

procedure TDokuInfo_Form.FormShow(Sender: TObject);
begin
  CreationDate.Cursor:=crHandPoint;
  ModDate.Cursor:=crHandPoint;
end;

procedure TDokuInfo_Form.InfoSBClick(Sender: TObject);
begin
  ShowMessage('Format der PDFmarks:' + #13 +
              '===============' + #13 +
              '[ /Title (Document title)' + #13 +
              '  /Author (Author name)' + #13 +
              '  /Subject (Subject description)' + #13 +
              '  /Keywords (comma, separated, keywords)' + #13 +
              '  /CreationDate (D:20061204092842)' + #13 +
              '  /ModDate (D:20061204092842)' + #13 +
              '  /Producer (PDF producer name or note)' + #13 +
              '  /DOCINFO pdfmark' + #13 + #13 +
              'Datumsformat (GMT Time Zone) von CreationDate/ModDate: YYYYMMDDhhmmss');
end;

procedure TDokuInfo_Form.BitBtn1Click(Sender: TObject);
var
  PDFMarkT: TStringlist;
begin
  PDFMarkT:= TStringlist.create;
  try
    PDFMarkT.Add('[ /Title (' + TitelEdit.Text + ')');
    PDFMarkT.Add('  /Author (' + AuthorEdit.Text + ')');
    PDFMarkT.Add('  /Subject (' + SubjectEdit.Text + ')');
    PDFMarkT.Add('  /Keywords (' + KeywordsEdit.Text + ')');
    PDFMarkT.Add('  /CreationDate (D:' + CreationDateEdit.Text + ')');
    PDFMarkT.Add('  /ModDate (D:' + ModDateEdit.Text + ')');
    PDFMarkT.Add('  /Creator (' + CreatorEdit.Text + ')');
    PDFMarkT.Add('  /DOCINFO pdfmark');
    PDFMarkT.SaveToFile(ExtractFilePath(Application.ExeName) + 'pdfmarks');
  finally
    PDFMarkT.Free
  end; {try}
  Close;
end;

procedure TDokuInfo_Form.CancelBitBtn1Click(Sender: TObject);
begin
  if MetadatenCB.Checked = False then
    Clear.Click;
  Close;
end;

procedure TDokuInfo_Form.ClearClick(Sender: TObject);
begin
  // Inhalt leeren
  TitelEdit.Text := '';
  AuthorEdit.Text := '';
  SubjectEdit.Text := '';
  KeywordsEdit.Text := '';
  ModDateEdit.Text := '';
  CreationDateEdit.Text := '';
  CreatorEdit.Text := 'FreePDF64 (https://github.com/FreePDF64)';
  MetadatenCB.Checked := False;
end;

function NowUTC: TDateTime;
var
  SystemTime: TSystemTime;
begin
  GetSystemTime(SystemTime);
  Result := SystemTimeToDateTime (SystemTime);
end;

procedure TDokuInfo_Form.CreationDateClick(Sender: TObject);
begin
  CreationDateEdit.Text := FormatDateTime('yyyymmddhhnnss', NowUTC);
end;

procedure TDokuInfo_Form.ModDateClick(Sender: TObject);
begin
  ModDateEdit.Text := FormatDateTime('yyyymmddhhnnss', NowUTC);
end;

end.
