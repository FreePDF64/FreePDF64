//
// Programmname: FreePDF64
//

unit Encrypt_Unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, IniFiles;

type
  TEncrypt_Form = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    KennwortCB: TCheckBox;
    KennwortE: TEdit;
    DruckenCB: TCheckBox;
    KopEntCB: TCheckBox;
    FormularCB: TCheckBox;
    InhaltCB: TCheckBox;
    BerechtigungCB: TCheckBox;
    BerechtigungE: TEdit;
    EncryptCombo: TComboBox;
    DokuaenderCB: TCheckBox;
    HQCB: TCheckBox;
    Clear: TSpeedButton;
    Label2: TLabel;
    ZeigenBt: TSpeedButton;
    CancelBitBtn1: TBitBtn;
    BitBtn1: TBitBtn;
    Info: TButton;
    procedure KennwortCBClick(Sender: TObject);
    procedure BerechtigungCBClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EncryptComboChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure DruckenCBClick(Sender: TObject);
    procedure BerechtigungEChange(Sender: TObject);
    procedure KennwortEChange(Sender: TObject);
    procedure HQCBClick(Sender: TObject);
    procedure DokuaenderCBClick(Sender: TObject);
    procedure KopEntCBClick(Sender: TObject);
    procedure InhaltCBClick(Sender: TObject);
    procedure FormularCBClick(Sender: TObject);
    procedure ClearClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure CancelBitBtn1Click(Sender: TObject);
    procedure ZeigenBtClick(Sender: TObject);
    procedure InfoClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Encrypt_Form: TEncrypt_Form;

Const
  ENC1 = 'Dokumentensicherheit';
  ENC2 = 'Berechtigungspasswort:';
  ENC3 = 'Passwort zum Öffnen des Dokuments:';
  ENC4 = 'Nicht zulässig: Drucken';
  ENC5 = 'Nicht zulässig: Kopieren bzw. Entnehmen von Inhalt';
  ENC6 = 'Nicht zulässig: Zugriff auf Inhalt aktivieren';
  ENC7 = 'Nicht zulässig: Kommentar- u. Formularbearbeitung';
  ENC9 = 'Falsches Passwort! Bitte wiederholen.';
  ENC10 = 'Wissen Sie das Passwort?';
  ENC11 = 'Bitte Berechtigungspasswort eingeben. Passwort muss mindestens 6 Zeichen lang sein!';
  ENC12 = 'Bitte Passwort zum Öffnen des Dokuments eingeben. Passwort muss mindestens 6 Zeichen lang sein!';
  ENC14 = 'Stufe';
  ENC15 = '128-Bit AES-Verschlüsselung';
  ENC16 = 'Bitte wiederholen!';
  ENC17 = 'Nicht zulässig: Ändern des Dokuments';
  ENC18 = 'Nicht zulässig: Hohe Auflösung beim Drucken';
  ENC19 = '256-Bit AES-Verschlüsselung';
  ENC20 = '128-Bit RC4-Verschlüsselung';

implementation

uses FreePDF64_Unit, Einstellungen_Unit, Auswahl_Unit;
{$R *.DFM}

procedure TEncrypt_Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    Clear.Click;
    if BerechtigungCB.Checked = True then
      BerechtigungCB.Checked := False;
    if KennwortCB.Checked = True then
      KennwortCB.Checked := False;
    Close;
  end;
end;

// MessageDlg zentriert
function MessageDlgCenter(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;
var
  R: TRect;
begin
  if not Assigned(Screen.ActiveForm) then
  begin
    Result := MessageDlg(Msg, DlgType, Buttons, 0);
  end else
  begin
    with CreateMessageDialog(Msg, DlgType, Buttons) do
    try
      GetWindowRect(Screen.ActiveForm.Handle, R);
      Left := R.Left + ((R.Right - R.Left) div 2) - (Width div 2);
      Top := R.Top + ((R.Bottom - R.Top) div 2) - (Height div 2);
      Result := ShowModal;
    finally
      Free;
    end;
  end;
end;

procedure TEncrypt_Form.BerechtigungCBClick(Sender: TObject);
begin
  if BerechtigungCB.Checked then
  begin
    BerechtigungE.Enabled := True;
    BerechtigungE.SetFocus;
    DruckenCB.Enabled := True;
    KopEntCB.Enabled := True;
    FormularCB.Enabled := True;
    DokuaenderCB.Enabled := True;
    HQCB.Enabled := True;
    InhaltCB.Enabled := True;
    Einstellungen_Form.FastCB.Checked := False;
    Einstellungen_Form.FastCB.Enabled := False;
  end else
  if not KennwortCB.Checked then
  begin
    BerechtigungE.Enabled := False;
    BerechtigungE.Text := '';
    KennwortE.Text := '';
    DruckenCB.Enabled := False;
    DruckenCB.Checked := False;
    DokuaenderCB.Checked := False;
    DokuaenderCB.Enabled := False;
    HQCB.Enabled := False;
    HQCB.Checked := False;
    KopEntCB.Enabled := False;
    KopEntCB.Checked := False;
    FormularCB.Enabled := False;
    FormularCB.Checked := False;
    InhaltCB.Checked := False;
    InhaltCB.Enabled := False;
    Einstellungen_Form.FastCB.Enabled := True;
  end;
  if not BerechtigungCB.Checked then
  begin
    BerechtigungE.Text := '';
    BerechtigungE.Enabled := False;
  end;
end;

procedure TEncrypt_Form.KennwortCBClick(Sender: TObject);
begin
  if KennwortCB.Checked then
  begin
    KennwortE.Enabled := True;
    KennwortE.SetFocus;
    DruckenCB.Enabled := True;
    KopEntCB.Enabled := True;
    FormularCB.Enabled := True;
    DokuaenderCB.Enabled := True;
    HQCB.Enabled := True;
    InhaltCB.Enabled := True;
    Einstellungen_Form.FastCB.Checked := False;
    Einstellungen_Form.FastCB.Enabled := False;
  end else
  if not BerechtigungCB.Checked then
  begin
    KennwortE.Enabled := False;
    KennwortE.Text := '';
    BerechtigungE.Text := '';
    DruckenCB.Enabled := False;
    DruckenCB.Checked := False;
    DokuaenderCB.Checked := False;
    DokuaenderCB.Enabled := False;
    HQCB.Enabled := False;
    HQCB.Checked := False;
    KopEntCB.Enabled := False;
    KopEntCB.Checked := False;
    FormularCB.Enabled := False;
    FormularCB.Checked := False;
    InhaltCB.Checked := False;
    InhaltCB.Enabled := False;
    Einstellungen_Form.FastCB.Enabled := True;
  end;
  if not KennwortCB.Checked then
  begin
    KennwortE.Text := '';
    KennwortE.Enabled := False;
  end;
end;

procedure TEncrypt_Form.CancelBitBtn1Click(Sender: TObject);
begin
  Clear.Click;
  if BerechtigungCB.Checked = True then
    BerechtigungCB.Checked := False;
  if KennwortCB.Checked = True then
    KennwortCB.Checked := False;
  Close;
end;

procedure TEncrypt_Form.ClearClick(Sender: TObject);
begin
  BerechtigungCB.Checked := False;
  KennwortCB.Checked     := False;
  BerechtigungE.PasswordChar := '*';
  KennwortE.PasswordChar     := '*';
  EncryptCombo.Items[2] := ENC19; // 256-AES Bit
  EncryptCombo.ItemIndex := Versch1;
end;

procedure TEncrypt_Form.FormShow(Sender: TObject);
begin
  if (not BerechtigungCB.Checked) and (not KennwortCB.Checked) then
  begin
    EncryptCombo.Items[2] := ENC19; // 256-AES Bit
    EncryptCombo.ItemIndex := Versch1;
  end;
  ActiveControl := BitBtn1;
  GroupBox1.Caption := ENC1;
  BerechtigungCB.Caption := ENC2;
  KennwortCB.Caption := ENC3;
  DruckenCB.Caption := ENC4;
  KopEntCB.Caption := ENC5;
  InhaltCB.Caption := ENC6;
  FormularCB.Caption := ENC7;
  Label1.Caption := ENC14;
  DokuaenderCB.Caption := ENC17;
  HQCB.Caption := ENC18;
    // Variablenzuweisung
  Do1 := DokuaenderCB.Checked;
  In1 := InhaltCB.Checked;

  if BerechtigungCB.Checked and (not KennwortCB.Checked) then
  begin
    BerechtigungE.Enabled := True;
    DruckenCB.Enabled := True;
    if DruckenCB.Checked then
    begin
      HQCB.Enabled := False;
      HQCB.Checked := False;
    end else
      HQCB.Enabled := True;
    KopEntCB.Enabled := True;
    FormularCB.Enabled := True;
    DokuaenderCB.Enabled := True;
    InhaltCB.Enabled := True;
    Einstellungen_Form.FastCB.Checked := False;
    Einstellungen_Form.FastCB.Enabled := False;
  end;
  if KennwortCB.Checked and (not BerechtigungCB.Checked) then
  begin
    KennwortE.Enabled := True;
    DruckenCB.Enabled := True;
    if DruckenCB.Checked then
    begin
      HQCB.Enabled := False;
      HQCB.Checked := False;
    end else
      HQCB.Enabled := True;
    KopEntCB.Enabled := True;
    FormularCB.Enabled := True;
    DokuaenderCB.Enabled := True;
    InhaltCB.Enabled := True;
    Einstellungen_Form.FastCB.Checked := False;
    Einstellungen_Form.FastCB.Enabled := False;
  end;

  // 128-Bit oder 256-AES
  if (EncryptCombo.ItemIndex = 0) or (EncryptCombo.ItemIndex = 1) or (EncryptCombo.ItemIndex = 2) then
  begin
    if DruckenCB.Checked then
    begin
      HQCB.Enabled := False;
      HQCB.Checked := False;
    end;
    if Do1 then
      DokuaenderCB.Checked := True;
    if In1 then
    begin
      InhaltCB.Enabled := True;
      InhaltCB.Checked := True;
    end;
  end;
  BerechtigungE.PasswordChar := '*';
  KennwortE.PasswordChar     := '*';
end;

procedure TEncrypt_Form.BitBtn1Click(Sender: TObject);
begin
  if (not BerechtigungCB.Checked) and (not KennwortCB.Checked) then
    Exit;

  if BerechtigungCB.Checked and ((BerechtigungE.Text = '') or (Length(BerechtigungE.Text) < 6)) then
      MessageDlgCenter(ENC11, mtError, [mbOk])
  else if KennwortCB.Checked and ((KennwortE.Text = '') or (Length(KennwortE.Text) < 6)) then
      MessageDlgCenter(ENC12, mtError, [mbOk])
  else if BerechtigungE.Text = KennwortE.Text then
    MessageDlgCenter('Passwörter müssen sich unterscheiden!', mtWarning, [mbOk]);
end;

procedure TEncrypt_Form.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Do1 := DokuaenderCB.Checked;
  In1 := InhaltCB.Checked;
end;

procedure TEncrypt_Form.EncryptComboChange(Sender: TObject);
begin
  if (EncryptCombo.ItemIndex = 0) or (EncryptCombo.ItemIndex = 1) or (EncryptCombo.ItemIndex = 2) then // 128-/256-Bit
  begin
    Einstellungen_Form.FastCB.Checked := False;
    Einstellungen_Form.FastCB.Enabled := False;
  end;
end;

procedure TEncrypt_Form.FormActivate(Sender: TObject);
begin
  BitBtn1.SetFocus;
end;

procedure TEncrypt_Form.DruckenCBClick(Sender: TObject);
begin
  if (EncryptCombo.ItemIndex = 0) or (EncryptCombo.ItemIndex = 1) or (EncryptCombo.ItemIndex = 2) then
    if HQCB.Enabled then
    begin
      HQCB.Enabled := False;
      HQCB.Checked := False
    end
    else
      HQCB.Enabled := True;
  Versch6 := DruckenCB.Checked;
end;

procedure TEncrypt_Form.BerechtigungEChange(Sender: TObject);
begin
  Versch3 := BerechtigungE.Text;
end;

procedure TEncrypt_Form.KennwortEChange(Sender: TObject);
begin
  Versch5 := KennwortE.Text;
end;

procedure TEncrypt_Form.HQCBClick(Sender: TObject);
begin
  Versch11 := HQCB.Checked;
end;

procedure TEncrypt_Form.DokuaenderCBClick(Sender: TObject);
begin
  Versch7 := DokuaenderCB.Checked;
end;

procedure TEncrypt_Form.KopEntCBClick(Sender: TObject);
begin
  Versch8 := KopEntCB.Checked;
end;

procedure TEncrypt_Form.ZeigenBtClick(Sender: TObject);
begin
  if BerechtigungE.PasswordChar = '*' then
  begin
    BerechtigungE.PasswordChar := #0
  end else
    BerechtigungE.PasswordChar := '*';
  if KennwortE.PasswordChar = '*' then
  begin
    KennwortE.PasswordChar := #0
  end else
    KennwortE.PasswordChar := '*';
end;

procedure TEncrypt_Form.InfoClick(Sender: TObject);
begin
  ShowMessage('Berechtigungspasswort:' + #13 +
              '================' + #13 +
              'Durch Verwendung eines Berechtigungspassworts kannst Du das' + #13 +
              'Drucken, Bearbeiten und Kopieren von Inhalten in der PDF-Datei' + #13 +
              'einschränken. Es wird kein Passwort benötigt, um das Dokument' + #13 +
              'in Acrobat oder in einem PDF-Reader zu öffnen. Du benötigst ein' + #13 +
              'Passwort, um die von Dir definierten Einschränkungen zu ändern.' + #13 + #13 +
              'Passwort zum Öffnen des Dokuments:' + #13 +
              '=========================' + #13 +
              'Bei einem Passwort zum Öffnen des Dokuments muss ein Passwort' + #13 +
              'eingeben werden, um die PDF-Datei zu öffnen.' + #13 + #13 +
              'Wurde eine PDF-Datei mit beiden Passwörtern versehen, ist das' + #13 +
              'Öffnen mit jedem der Passwörter möglich. Zum Ändern der einge-' + #13 +
              'schränkten Funktionen muss jedoch das Berechtigungspasswort' + #13 +
              'verwendet werden.');
end;

procedure TEncrypt_Form.InhaltCBClick(Sender: TObject);
  begin
    Versch9 := InhaltCB.Checked;
  end;

  procedure TEncrypt_Form.FormularCBClick(Sender: TObject);
  begin
    Versch10 := FormularCB.Checked;
  end;

end.
