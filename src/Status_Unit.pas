unit Status_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Printers, Registry, ShlObj, ShellAPI;

type
  TStatus_Form = class(TForm)
    Edit2: TEdit;
    Edit1: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    BitBtn1: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Label14: TLabel;
    Label15: TLabel;
    Edit14: TEdit;
    Label16: TLabel;
    Label17: TLabel;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Label18: TLabel;
    Edit18: TEdit;
    Label19: TLabel;
    Edit19: TEdit;
    Label20: TLabel;
    Edit20: TEdit;
    Label21: TLabel;
    Edit21: TEdit;
    Edit22: TEdit;
    Label22: TLabel;
    Label23: TLabel;
    Edit23: TEdit;
    HintEdit: TEdit;
    Label24: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Label20Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Label22Click(Sender: TObject);
    procedure Label24Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure Label8Click(Sender: TObject);
    procedure Label9Click(Sender: TObject);
    procedure Label21Click(Sender: TObject);
    procedure Label10Click(Sender: TObject);
    procedure Label11Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure Label13Click(Sender: TObject);
    procedure Label14Click(Sender: TObject);
    procedure Label15Click(Sender: TObject);
    procedure Label16Click(Sender: TObject);
    procedure Label17Click(Sender: TObject);
    procedure Label19Click(Sender: TObject);
    procedure Label18Click(Sender: TObject);
    procedure Label20MouseEnter(Sender: TObject);
    procedure Label2MouseEnter(Sender: TObject);
    procedure Label3MouseEnter(Sender: TObject);
    procedure Label22MouseEnter(Sender: TObject);
    procedure Label4MouseEnter(Sender: TObject);
    procedure Label5MouseEnter(Sender: TObject);
    procedure Label6MouseEnter(Sender: TObject);
    procedure Label7MouseEnter(Sender: TObject);
    procedure Label8MouseEnter(Sender: TObject);
    procedure Label9MouseEnter(Sender: TObject);
    procedure Label21MouseEnter(Sender: TObject);
    procedure Label10MouseEnter(Sender: TObject);
    procedure Label12MouseEnter(Sender: TObject);
    procedure Label13MouseEnter(Sender: TObject);
    procedure Label14MouseEnter(Sender: TObject);
    procedure Label18MouseEnter(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Status_Form: TStatus_Form;

implementation

{$R *.dfm}

uses FreePDF64_Notify_Unit, Einstellungen_Unit,
     Encrypt_Unit, Dateianlage_Unit, DokuInfo_Unit,
     FreePDF64_Unit;

procedure TStatus_Form.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    Close;
end;

procedure TStatus_Form.FormShow(Sender: TObject);
var
  Level, dpi, DP, PDFALevel: Integer;
  MZiel: String;
begin
  // Drucker
  Edit1.Text := Printer.Printers[Printer.Printerindex];
  // Überwachung An/Aus
  if  FreePDF64_Form.MonitorBtn.ImageIndex = 57 then
  begin
    Edit20.Text  := 'An';
    Edit20.Color := clLime;
  end else
  begin
    Edit20.Text := 'Aus';
    Edit20.Color := clRed;
  end;
  // Überwachungsverzeichnis
  Edit2.Text := IncludeTrailingBackslash(FreePDF64_Notify.MonitoringFolder.Text);
  // Zielverzeichnis
  if not FreePDF64_Notify.Ziel_FestCB.Checked then
    MZiel := IncludeTrailingBackslash(FreePDF64_Form.ZielLabel.Hint)
  else
    MZiel := IncludeTrailingBackslash(FreePDF64_Notify.ZielEdit.Text);
  Edit3.Text := MZiel;

  // Wartezeit bis zur Erstellung
  Edit4.Text := IntToStr(FreePDF64_Notify.SpinEditSec.Value) + ' sec.';
  // PDF-Level
  Level := Einstellungen_Form.PDFLevel.ItemIndex;
    case Level of
      0: Edit5.Text := 'Acrobat 5 (PDF 1.4)';
      1: Edit5.Text := 'Acrobat 6 (PDF 1.5)';
      2: Edit5.Text := 'Acrobat 7 (PDF 1.6)';
      3: Edit5.Text := 'Acrobat 8 (PDF 1.7)';
    end;
  // Formatauswahl
  if Einstellungen_Form.AuswahlRG.ItemIndex = 0 then
    Edit6.Text := 'PS (Postscript)/PDF zu PDF '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 1 then
    Edit6.Text := 'PDF zu PS '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 2 then
    Edit6.Text := 'PS/PDF zu DOCX '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 3 then
    Edit6.Text := 'PS/PDF zu TXT '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 4 then
    Edit6.Text := 'PS/PDF zu BMP '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 5 then
    Edit6.Text := 'PS/PDF zu JPEG '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 6 then
    Edit6.Text := 'PS/PDF zu PNG '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 7 then
    Edit6.Text := 'PS/PDF zu TIFF G4 - BW '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 8 then
    Edit6.Text := 'PS/PDF zu TIFF LZW - BW '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 9 then
    Edit6.Text := 'PS/PDF zu TIFF (uncompressed) '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 10 then
    Edit6.Text := 'BMP zu PDF '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 11 then
    Edit6.Text := 'JPEG zu PDF '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 12 then
    Edit6.Text := 'PNG zu PDF '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 13 then
    Edit6.Text := 'TIFF zu PDF ';
  // Schriftarten/Füllmuster-dpi?
  dpi := Einstellungen_Form.SchriftParams.ItemIndex;
  case dpi of
    0: Edit7.Text := '72 dpi';
    1: Edit7.Text := '96 dpi';
    2: Edit7.Text := '150 dpi';
    3: Edit7.Text := '300 dpi';
    4: Edit7.Text := '600 dpi';
    5: Edit7.Text := '720 dpi';
  end;
  // Welcher Distiller-Parameter?
  DP := Einstellungen_Form.DistParam.ItemIndex;
  case DP of
    0: Edit8.Text := 'Default';
    1: Edit8.Text := 'Screen Optimized';
    2: Edit8.Text := 'eBook';
    3: Edit8.Text := 'Print Optimized';
    4: Edit8.Text := 'Prepress Optimized';
  end;
  // PDF/A-Level
  if Einstellungen_Form.PDFA_CB.Checked = True then
  begin
    PDFALevel := Einstellungen_Form.PDFA.ItemIndex;
    case PDFALevel of
      0: Edit9.Text := 'PDF/A-1b';
      1: Edit9.Text := 'PDF/A-2b';
      2: Edit9.Text := 'PDF/A-3b';
    end;
    Edit9.Color := clBtnFace;
  end else
  begin
    Edit9.Text := 'Aus';
    Edit9.Color := clRed;
  end;
  // PDF/X-Level
  if Einstellungen_Form.PDFX.Checked then
  begin
    Edit21.Text := 'PDF/X-3';
    Edit21.Color := clBtnFace;
  end else
  if Einstellungen_Form.PDFX4.Checked then
  begin
    Edit21.Text := 'PDF/X-4a';
    Edit21.Color := clBtnFace;
end else
  begin
    Edit21.Text := 'Aus';
    Edit21.Color := clRed;
  end;
  // Schnelle Webanzeige
  if Einstellungen_Form.FastCB.Checked then
  begin
    Edit10.Text := 'An';
    Edit10.Color := clLime;
  end else
  begin
    Edit10.Text := 'Aus';
    Edit10.Color := clRed;
  end;
  // Verschlüsselung
  if Encrypt_Form.BerechtigungCB.Checked or Encrypt_Form.KennwortCB.Checked then
  begin
    if Encrypt_Form.EncryptCombo.ItemIndex = 0 then
      Edit11.Text :='128-Bit RC4-Verschlüsselung'
    else
    if Encrypt_Form.EncryptCombo.ItemIndex = 1 then
      Edit11.Text :='128-Bit AES-Verschlüsselung'
    else
      Edit11.Text :='256-Bit AES-Verschlüsselung';
    Edit11.Color := clBtnFace;
  end else
  begin
    Edit11.Text := 'Aus';
    Edit11.Color := clRed;
  end;
  // PDF-Dateien anzeigen
  if Einstellungen_Form.AnzeigenCB.Checked then
  begin
    Edit12.Text := 'An';
    Edit12.Color := clLime;
  end else
  begin
    Edit12.Text := 'Aus';
    Edit12.Color := clRed;
  end;
  // Systemklang
  if Einstellungen_Form.SystemklangCB.Checked then
  begin
    Edit13.Text := 'An';
    Edit13.Color := clLime;
  end else
  begin
    Edit13.Text := 'Aus';
    Edit13.Color := clRed;
  end;
  // PDF-Datei(en) komprimieren
  if Einstellungen_Form.PDF_Shrink.Checked then
    Edit14.Text := '1ste PDF-Komprimierung'
  else
  if Einstellungen_Form.PDF_Shrink2.Checked then
    Edit14.Text := '2te PDF-Komprimierung'
  else
    Edit14.Text := '-';
  // Datei vorne/hinten
  if Dateianlage_Form.Datei1.Text <> '' then
    Edit15.Text := Dateianlage_Form.Datei1.Text
  else
    Edit15.Text := '-';
  if Dateianlage_Form.Datei2.Text <> '' then
    Edit16.Text := Dateianlage_Form.Datei2.Text
  else
    Edit16.Text := '-';
  if Dateianlage_Form.DateianlageCB.Checked then
  begin
    Edit17.Text := 'An';
    Edit17.Color := clLime;
  end else
  begin
    Edit17.Text := 'Aus';
    Edit17.Color := clRed;
  end;
  // Zusatz
  if Einstellungen_Form.ZusatzAnAus.Checked then
  begin
    Edit18.Text := 'An';
    Edit18.Color := clLime;
  end else
  begin
    Edit18.Text := 'Aus';
    Edit18.Color := clRed;
  end;
  // PDF-Metadaten
  if DokuInfo_Form.MetadatenCB.Checked then
  begin
    Edit19.Text := 'An';
    Edit19.Color := clLime;
  end else
  begin
    Edit19.Text := 'Aus';
    Edit19.Color := clRed;
  end;
  // Festes Zielverzeichnis
  if FreePDF64_Notify.Ziel_FestCB.Checked then
  begin
    Edit22.Text := 'Ja';
    Edit22.Color := clLime;
  end else
  begin
    Edit22.Text := 'Nein';
    Edit22.Color := clRed;
  end;
  // Windows-Benachrichtigung
  if FreePDF64_Notify.BenachrichtigungCB.Checked then
  begin
    HintEdit.Text := 'Ja';
    HintEdit.Color := clLime;
  end else
  begin
    HintEdit.Text := 'Nein';
    HintEdit.Color := clRed;
  end;
 // Ins Unterverzeichnis beim Erstellen
  if FreePDF64_Form.Formatverz.Checked then
    Edit23.Text := 'Ohne Datum'
  else
  if FreePDF64_Form.Formatverz_Date.Checked then
    Edit23.Text := 'Mit Datum'
  else
  if FreePDF64_Form.Formatverz_OnlyDate.Checked then
    Edit23.Text := 'Nur Datum'
  else
    Edit23.Text := '-';
end;

// ==========================================================
procedure TStatus_Form.Label10Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.ConfigBtn.Click;
end;

procedure TStatus_Form.Label10MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label10.Cursor := crHandPoint
  else
    Label10.Cursor := crDefault;
end;

procedure TStatus_Form.Label11Click(Sender: TObject);
begin
  Status_Form.Close;
  Einstellungen_Form.EncryptBt.Click;
end;

procedure TStatus_Form.Label12Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.ConfigBtn.Click;
end;

procedure TStatus_Form.Label12MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label12.Cursor := crHandPoint
  else
    Label12.Cursor := crDefault;
end;

procedure TStatus_Form.Label13Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.ConfigBtn.Click;
end;

procedure TStatus_Form.Label13MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label13.Cursor := crHandPoint
  else
    Label13.Cursor := crDefault;
end;

procedure TStatus_Form.Label14Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.ConfigBtn.Click;
end;

procedure TStatus_Form.Label14MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label14.Cursor := crHandPoint
  else
    Label14.Cursor := crDefault;
end;

procedure TStatus_Form.Label15Click(Sender: TObject);
begin
  Status_Form.Close;
  Einstellungen_Form.Dateianlage.Click;
end;

procedure TStatus_Form.Label16Click(Sender: TObject);
begin
  Status_Form.Close;
  Einstellungen_Form.Dateianlage.Click;
end;

procedure TStatus_Form.Label17Click(Sender: TObject);
begin
  Status_Form.Close;
  Einstellungen_Form.Dateianlage.Click;
end;

procedure TStatus_Form.Label18Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.ConfigBtn.Click;
end;

procedure TStatus_Form.Label18MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label18.Cursor := crHandPoint
  else
    Label18.Cursor := crDefault;
end;

procedure TStatus_Form.Label19Click(Sender: TObject);
begin
  Status_Form.Close;
  Einstellungen_Form.PDFMark.Click;
end;

// Aufruf spezieller Ordner, wie z.B. die Netzwerkumgebung, „Eigene Dateien".
// Nachfolgende Procedure öffnet einen solchen virtuellen Dialog:
// CSIDL_Controls  für "Systemsteuerung",
// CSIDL_Printers  für "Drucker",
// CSIDL_Drives	   für "Arbeitsplatz",
// CSIDL_Network   für "Netzwerkumgebung".
// CSIDL_BITBUCKET für "Papierkorb"
// ....
// Weitere Konstanten stehen in der Unit ShlObj.
procedure ShowSpecialFolder(const AFolder: Integer);
var
  ItemIDList: PItemIDList;
  ShExInfo: ShellExecuteInfo;
begin
  ShGetSpecialFolderLocation(Application.Handle, AFolder, ItemIDList);
  FillChar(ShExInfo, SizeOf(ShExInfo), 0);
  with ShExInfo do
  begin
    cbSize := SizeOf(ShExInfo);
    nShow := SW_Show;
    fMask := see_Mask_IDList;
    lpIDList := ItemIDList;
  end;
  ShellExecuteEx(@ShExInfo);
end;

procedure TStatus_Form.Label1Click(Sender: TObject);
begin
  Status_Form.Close;
  ShowSpecialFolder(CSIDL_PRINTERS);
end;

procedure TStatus_Form.Label20MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label20.Cursor := crHandPoint
  else
    Label20.Cursor := crDefault;
end;

procedure TStatus_Form.Label20Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.MonitorBtn.Click;
end;

procedure TStatus_Form.Label21Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.ConfigBtn.Click;
end;

procedure TStatus_Form.Label21MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label21.Cursor := crHandPoint
  else
    Label21.Cursor := crDefault;
end;

procedure TStatus_Form.Label22Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.MonitorBtn.Click;
end;

procedure TStatus_Form.Label22MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label22.Cursor := crHandPoint
  else
    Label22.Cursor := crDefault;
end;

procedure TStatus_Form.Label24Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.MonitorBtn.Click;
end;

procedure TStatus_Form.Label2Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.MonitorBtn.Click;
end;

procedure TStatus_Form.Label2MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label2.Cursor := crHandPoint
  else
    Label2.Cursor := crDefault;
end;

procedure TStatus_Form.Label3Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.MonitorBtn.Click;
end;

procedure TStatus_Form.Label3MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label3.Cursor := crHandPoint
  else
    Label3.Cursor := crDefault;
end;

procedure TStatus_Form.Label4Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.MonitorBtn.Click;
end;

procedure TStatus_Form.Label4MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label4.Cursor := crHandPoint
  else
    Label4.Cursor := crDefault;
end;

procedure TStatus_Form.Label5Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.ConfigBtn.Click;
end;

procedure TStatus_Form.Label5MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label5.Cursor := crHandPoint
  else
    Label5.Cursor := crDefault;
end;

procedure TStatus_Form.Label6Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.ConfigBtn.Click;
end;

procedure TStatus_Form.Label6MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label6.Cursor := crHandPoint
  else
    Label6.Cursor := crDefault;
end;

procedure TStatus_Form.Label7Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.ConfigBtn.Click;
end;

procedure TStatus_Form.Label7MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label7.Cursor := crHandPoint
  else
    Label7.Cursor := crDefault;
end;

procedure TStatus_Form.Label8Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.ConfigBtn.Click;
end;

procedure TStatus_Form.Label8MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label8.Cursor := crHandPoint
  else
    Label8.Cursor := crDefault;
end;

procedure TStatus_Form.Label9Click(Sender: TObject);
begin
  Status_Form.Close;
  if not FreePDF64_Form.TrayIcon1.Visible then
    FreePDF64_Form.ConfigBtn.Click;
end;

procedure TStatus_Form.Label9MouseEnter(Sender: TObject);
begin
  if not FreePDF64_Form.TrayIcon1.Visible then
    Label9.Cursor := crHandPoint
  else
    Label9.Cursor := crDefault;
end;

end.
