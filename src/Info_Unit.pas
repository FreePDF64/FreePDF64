//
// Programmname: FreePDF64
//

unit Info_Unit;
                                                         
interface

uses             
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ShellAPI;

type
  TInfo_Form = class(TForm)
    InfoL: TLabel;
    MailL: TLabel;
    DownloadL: TLabel;
    BitBtn1: TBitBtn;
    SymbolBtn: TButton;
    Mail2: TLabel;
    Changelog: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Projektseite: TLabel;
    procedure MailLClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DownloadLClick(Sender: TObject);
    procedure SymbolBtnClick(Sender: TObject);
    procedure ChangelogClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ProjektseiteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Info_Form: TInfo_Form;

implementation

{$R *.DFM}

uses FreePDF64_Unit, Einstellungen_Unit;

procedure TInfo_Form.ChangelogClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', PChar('https://github.com/FreePDF64/FreePDF64/releases'),
                                                  NIL, NIL, SW_NORMAL);
  Close;
end;

procedure TInfo_Form.DownloadLClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', PChar('https://github.com/FreePDF64/FreePDF64/tree/main/releases/download'),
                                                  NIL, NIL, SW_NORMAL);
  Close;
end;

procedure TInfo_Form.ProjektseiteClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', PChar('https://github.com/FreePDF64'),
                                                  NIL, NIL, SW_NORMAL);
  Close;
end;

procedure TInfo_Form.SymbolBtnClick(Sender: TObject);
begin
  FreePDF64_Form.Anleitung1.Click;
  Info_Form.Close;
end;

procedure TInfo_Form.MailLClick(Sender: TObject);
begin
  ShellExecute(FreePDF64_Form.Handle, 'open', 'mailto:FreePDF64@outlook.com'+'?subject=Fragen/Anregungen/etc. zu FreePDF64',
               NIL, NIL, SW_SHOWNORMAL);
  Close;
end;

procedure TInfo_Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    Close;
end;

procedure TInfo_Form.FormShow(Sender: TObject);
var
  Datum: String;
begin
  Edit1.Text := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
  Edit2.Text := Application.ExeName;

  Datum := '05.05.2025';
  Delete(Datum, 11, 9);  // Entfernt die letzten 9 Zeichen
  InfoL.Caption := FreePDF64_Form.LMDVersionInfo1.ProductName + ' Version '
                   + FreePDF64_Form.LMDVersionInfo1.ProductVersion + ' - 64 bit (' + Datum + ')' + #13 + #13
                   + 'Copyright © 2025 by FreePDF64@outlook.com' + #13
                   + 'FreePDF64 darf sowohl im privaten als auch im kommerziellen' + #13
                   + 'Umfeld ohne Bezahlung eingesetzt werden ("Freeware")!';
end;

end.

