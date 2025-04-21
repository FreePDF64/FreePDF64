//
// Programmname: FreePDF64
//

unit Einstellungen_Unit;

interface

uses
  Vcl.Dialogs, LMDUnicodeDialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  Vcl.Buttons, Vcl.Controls, Vcl.ExtCtrls, System.Classes,
  Windows, Winapi.Messages, SysUtils, Variants, Forms, IniFiles, MMSystem,
  System.UITypes, ShellAPI, FileCtrl, shlobj, ActiveX, LMDCustomComponent,
  LMDShBase, LMDShDlg;

type
  TEinstellungen_Form = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    MonitoringBtn: TButton;
    Label2: TLabel;
    Edit2: TEdit;
    Button2: TButton;
    DistParam: TRadioGroup;
    SchriftParams: TRadioGroup;
    PDFLevel: TRadioGroup;
    OKBitBtn1: TBitBtn;
    AuswahlRG: TRadioGroup;
    AusgabeRG: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit2: TSpinEdit;
    AnzeigenCB: TCheckBox;
    Edit3: TEdit;
    Button3: TButton;
    PDFAnzeiger: TLabel;
    EncryptBt: TBitBtn;
    AutoRP: TRadioGroup;
    PDFMark: TBitBtn;
    LMDOpenDialog1: TLMDOpenDialog;
    CancelBitBtn1: TBitBtn;
    SeitenBt: TBitBtn;
    PDFA: TRadioGroup;
    PDFA_CB: TCheckBox;
    Info: TButton;
    FastCB: TCheckBox;
    UeberwachungBtn: TBitBtn;
    Label3: TLabel;
    Edit4: TEdit;
    Button1: TButton;
    Label6: TLabel;
    Edit5: TEdit;
    Button4: TButton;
    PDF_Shrink: TCheckBox;
    Label7: TLabel;
    Edit6: TEdit;
    Button5: TButton;
    Zusatz: TBitBtn;
    ZusatzAnAus: TCheckBox;
    SystemklangCB: TCheckBox;
    Dateianlage: TBitBtn;
    PDFX: TCheckBox;
    HintLabel: TLabel;
    Edit7: TEdit;
    Button6: TButton;
    ImageMagick: TLabel;
    HeightSpin: TSpinEdit;
    Label8: TLabel;
    SoundSpin: TSpinEdit;
    Label9: TLabel;
    PDF_Shrink2: TCheckBox;
    LMDShellSysBrowseDialog1: TLMDShellSysBrowseDialog;
    ExifTool: TLabel;
    Edit8: TEdit;
    Button7: TButton;
    ExifToolGE: TCheckBox;
    FontCB: TCheckBox;
    PDFX4: TCheckBox;
    procedure MonitoringBtnClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure OKBitBtn1Click(Sender: TObject);
    procedure AuswahlRGClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure EncryptBtClick(Sender: TObject);
    procedure AutoRPClick(Sender: TObject);
    procedure PDFMarkClick(Sender: TObject);
    procedure CancelBitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SeitenBtClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure PDFAnzeigerClick(Sender: TObject);
    procedure PDFA_CBClick(Sender: TObject);
    procedure InfoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure UeberwachungBtnClick(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure ZusatzClick(Sender: TObject);
    procedure ZusatzAnAusClick(Sender: TObject);
    procedure DateianlageClick(Sender: TObject);
    procedure PDFXClick(Sender: TObject);
    procedure ImageMagickClick(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure PDF_ShrinkClick(Sender: TObject);
    procedure PDF_Shrink2Click(Sender: TObject);
    procedure ExifToolClick(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure ExifToolGEClick(Sender: TObject);
    procedure FontCBClick(Sender: TObject);
    procedure PDFX4Click(Sender: TObject);
    procedure Edit3Exit(Sender: TObject);
    private
      { Private-Deklarationen }
    public
      { Public-Deklarationen }
  end;

var
  Einstellungen_Form: TEinstellungen_Form;

implementation

uses
  FreePDF64_Unit, Encrypt_Unit, DokuInfo_Unit, Seiten_Unit, Auswahl_Unit,
  FreePDF64_Notify_Unit, Einstellungen_Hilfe_Unit, Zusatz_Unit,
  Dateianlage_Unit;
{$R *.dfm}

const
  SELDIRHELP = 1000;

procedure TEinstellungen_Form.AuswahlRGClick(Sender: TObject);
begin
  // PDF und JPEG zu PDF
  if (AuswahlRG.ItemIndex = 0) or (AuswahlRG.ItemIndex = 11) then
  begin
    SpinEdit1.Enabled := False;
    Label4.Enabled := False;
    SpinEdit2.Enabled := False;
    Label5.Enabled := False;
    AnzeigenCB.Enabled := True;
    PDF_Shrink.Enabled := True;
    PDF_Shrink2.Enabled := True;
    FastCB.Enabled := True;
    AutoRP.Enabled := True;
    PDFMark.Enabled := True;
    SchriftParams.Enabled := True;
    DistParam.Enabled := True;
    PDFLevel.Enabled := True;
    ZusatzAnAus.Enabled := True;
    Zusatz.Enabled := True;

    PDFA_CB.Checked := False;
    PDFX.Checked    := False;
    PDFX4.Checked   := False;
    if PDFA_CB.Checked then
      PDFA.Enabled := True
    else
      PDFA.Enabled  := False;
    PDFA_CB.Enabled := True;
    PDFX.Enabled    := True;
    PDFX4.Enabled   := True;

    EncryptBt.Enabled := True;
    SeitenBt.Enabled := True;
    if AuswahlRG.ItemIndex = 11 then
    begin
      PDFMark.Enabled := False;
      SeitenBt.Enabled := False;
      AutoRP.Enabled := False;
      SchriftParams.Enabled := False;
    end;
  end
  else
    // PS
    if AuswahlRG.ItemIndex = 1 then
    begin
      SpinEdit1.Enabled := False;
      Label4.Enabled := False;
      SpinEdit2.Enabled := False;
      Label5.Enabled := False;
      AnzeigenCB.Enabled := True;
      PDF_Shrink.Enabled := False;
      PDF_Shrink2.Enabled := False;
      PDF_Shrink.Checked := False;
      PDF_Shrink2.Checked := False;
      FastCB.Enabled := False;
      AutoRP.Enabled := False;
      PDFMark.Enabled := False;
      SchriftParams.Enabled := True;
      DistParam.Enabled := True;
      PDFLevel.Enabled := True;
      PDFA_CB.Checked := False;
      PDFA_CB.Enabled := False;
      PDFA.Enabled  := False;
      PDFX.Enabled  := False;
      PDFX4.Enabled := False;
      EncryptBt.Enabled := False;
      SeitenBt.Enabled := False;
      Dateianlage.Enabled := False;
      ZusatzAnAus.Enabled := False;
      Zusatz.Enabled := False;
    end
    else
      // DOCX
      if AuswahlRG.ItemIndex = 2 then
      begin
        SpinEdit1.Enabled := False;
        Label4.Enabled := False;
        SpinEdit2.Enabled := False;
        Label5.Enabled := False;
        AnzeigenCB.Enabled := False;
        PDF_Shrink.Enabled := False;
        PDF_Shrink2.Enabled := False;
        PDF_Shrink.Checked := False;
        PDF_Shrink2.Checked := False;
        FastCB.Enabled := False;
        AutoRP.Enabled := False;
        PDFMark.Enabled := False;
        SchriftParams.Enabled := False;
        DistParam.Enabled := False;
        PDFLevel.Enabled := False;
        PDFA_CB.Checked := False;
        PDFA_CB.Enabled := False;
        PDFA.Enabled  := False;
        PDFX.Enabled  := False;
        PDFX4.Enabled := False;
        EncryptBt.Enabled := False;
        SeitenBt.Enabled := False;
        Dateianlage.Enabled := False;
        ZusatzAnAus.Enabled := False;
        Zusatz.Enabled := False;
      end
      else
        // TXT
        if AuswahlRG.ItemIndex = 3 then
        begin
          SpinEdit1.Enabled := False;
          Label4.Enabled := False;
          SpinEdit2.Enabled := False;
          Label5.Enabled := False;
          AnzeigenCB.Enabled := True;
          PDF_Shrink.Enabled := False;
          PDF_Shrink2.Enabled := False;
          PDF_Shrink.Checked := False;
          PDF_Shrink2.Checked := False;
          FastCB.Enabled := False;
          AutoRP.Enabled := False;
          PDFMark.Enabled := False;
          SchriftParams.Enabled := False;
          DistParam.Enabled := False;
          PDFLevel.Enabled := False;
          PDFA_CB.Checked := False;
          PDFA_CB.Enabled := False;
          PDFA.Enabled := False;
          PDFX.Enabled := False;
          PDFX4.Enabled := False;
          EncryptBt.Enabled := False;
          SeitenBt.Enabled := False;
          Dateianlage.Enabled := False;
          ZusatzAnAus.Enabled := False;
          Zusatz.Enabled := False;
        end
        else
          // BMP
          if AuswahlRG.ItemIndex = 4 then
          begin
            SpinEdit1.Enabled := True;
            Label4.Enabled := True;
            SpinEdit2.Enabled := False;
            Label5.Enabled := False;
            AnzeigenCB.Enabled := False;
            PDF_Shrink.Enabled := False;
            PDF_Shrink2.Enabled := False;
            PDF_Shrink.Checked := False;
            PDF_Shrink2.Checked := False;
            FastCB.Enabled := False;
            AutoRP.Enabled := False;
            PDFMark.Enabled := False;
            SchriftParams.Enabled := False;
            DistParam.Enabled := False;
            PDFLevel.Enabled := False;
            PDFA_CB.Checked := False;
            PDFA_CB.Enabled := False;
            PDFA.Enabled := False;
            PDFX.Enabled := False;
            PDFX4.Enabled := False;
            EncryptBt.Enabled := False;
            SeitenBt.Enabled := False;
            Dateianlage.Enabled := False;
            ZusatzAnAus.Enabled := False;
            Zusatz.Enabled := False;
          end
          else
            // JPEG
            if AuswahlRG.ItemIndex = 5 then
            begin
              SpinEdit1.Enabled := True;
              Label4.Enabled := True;
              SpinEdit2.Enabled := True;
              Label5.Enabled := True;
              AnzeigenCB.Enabled := False;
              PDF_Shrink.Enabled := False;
              PDF_Shrink2.Enabled := False;
              PDF_Shrink.Checked := False;
              PDF_Shrink2.Checked := False;
              FastCB.Enabled := False;
              AutoRP.Enabled := False;
              PDFMark.Enabled := False;
              SchriftParams.Enabled := False;
              DistParam.Enabled := False;
              PDFLevel.Enabled := False;
              PDFA_CB.Checked := False;
              PDFA_CB.Enabled := False;
              PDFA.Enabled := False;
              PDFX.Enabled := False;
              PDFX4.Enabled := False;
              EncryptBt.Enabled := False;
              SeitenBt.Enabled := False;
              Dateianlage.Enabled := False;
              ZusatzAnAus.Enabled := False;
              Zusatz.Enabled := False;
            end
            else
              // PNG
              if AuswahlRG.ItemIndex = 6 then
              begin
                SpinEdit1.Enabled := True;
                Label4.Enabled := True;
                SpinEdit2.Enabled := False;
                Label5.Enabled := False;
                AnzeigenCB.Enabled := False;
                PDF_Shrink.Enabled := False;
                PDF_Shrink2.Enabled := False;
                PDF_Shrink.Checked := False;
                PDF_Shrink2.Checked := False;
                FastCB.Enabled := False;
                AutoRP.Enabled := False;
                PDFMark.Enabled := False;
                SchriftParams.Enabled := False;
                DistParam.Enabled := False;
                PDFLevel.Enabled := False;
                PDFA_CB.Checked := False;
                PDFA_CB.Enabled := False;
                PDFA.Enabled := False;
                PDFX.Enabled := False;
                PDFX4.Enabled := False;
                EncryptBt.Enabled := False;
                SeitenBt.Enabled := False;
                Dateianlage.Enabled := False;
                ZusatzAnAus.Enabled := False;
                Zusatz.Enabled := False;
              end;
  // TIFF
  if (AuswahlRG.ItemIndex > 6) and (AuswahlRG.ItemIndex < 10) then
  begin
    SpinEdit1.Enabled := True;
    Label4.Enabled := True;
    SpinEdit2.Enabled := False;
    Label5.Enabled := False;
    AnzeigenCB.Enabled := True;
    PDF_Shrink.Enabled := False;
    PDF_Shrink2.Enabled := False;
    PDF_Shrink.Checked := False;
    PDF_Shrink2.Checked := False;
    FastCB.Enabled := False;
    AutoRP.Enabled := False;
    PDFMark.Enabled := False;
    SchriftParams.Enabled := False;
    DistParam.Enabled := False;
    PDFLevel.Enabled := False;
    PDFA_CB.Checked := False;
    PDFA_CB.Enabled := False;
    PDFA.Enabled := False;
    PDFX.Enabled := False;
    PDFX4.Enabled := False;
    EncryptBt.Enabled := False;
    SeitenBt.Enabled := False;
    Dateianlage.Enabled := False;
  end;
  // BMP/PNG/TIFF zu PDF
  if (AuswahlRG.ItemIndex = 10) or (AuswahlRG.ItemIndex = 12) or
    (AuswahlRG.ItemIndex = 13) then
  begin
    SpinEdit1.Enabled := False;
    Label4.Enabled := False;
    SpinEdit2.Enabled := False;
    Label5.Enabled := False;
    AnzeigenCB.Enabled := True;
    PDF_Shrink.Enabled := False;
    PDF_Shrink2.Enabled := False;
    PDF_Shrink.Checked := False;
    PDF_Shrink2.Checked := False;
    FastCB.Enabled := False;
    AutoRP.Enabled := False;
    PDFMark.Enabled := False;
    SchriftParams.Enabled := False;
    DistParam.Enabled := False;
    PDFLevel.Enabled := False;
    PDFA_CB.Checked := False;
    PDFA_CB.Enabled := False;
    PDFA.Enabled := False;
    PDFX.Enabled := False;
    PDFX4.Enabled := False;
    EncryptBt.Enabled := False;
    SeitenBt.Enabled := False;
    Dateianlage.Enabled := False;
    ZusatzAnAus.Enabled := False;
    Zusatz.Enabled := False;
  end;
  if AuswahlRG.ItemIndex = 0 then
    Dateianlage.Enabled := True;
end;

procedure TEinstellungen_Form.AutoRPClick(Sender: TObject);
begin
  if AutoRP.ItemIndex = 0 then
    AP4 := '-dAutoRotatePages=/None '
  else if AutoRP.ItemIndex = 1 then
    AP4 := '-dAutoRotatePages=/All '
  else if AutoRP.ItemIndex = 2 then
    AP4 := '-dAutoRotatePages=/PagebyPage ';
end;

procedure TEinstellungen_Form.SeitenBtClick(Sender: TObject);
begin
  // Form soll mittig angezeigt werden.
  Seiten_Form.Position := poMainFormCenter;
  Seiten_Form.ShowModal;
end;

procedure TEinstellungen_Form.UeberwachungBtnClick(Sender: TObject);
begin
  // Form soll mittig angezeigt werden.
  FreePDF64_Notify.Position := poMainFormCenter;
  FreePDF64_Notify.ShowModal;
end;

procedure TEinstellungen_Form.ZusatzAnAusClick(Sender: TObject);
begin
  if ZusatzAnAus.Checked = False then
    Zusatz.Enabled := False
  else
    Zusatz.Enabled := True;
end;

procedure TEinstellungen_Form.ZusatzClick(Sender: TObject);
begin
  // Form soll mittig angezeigt werden
  Zusatz_Form.Position := poMainFormCenter;
  Zusatz_Form.ShowModal;
end;

// Pfad zu gswin64c.exe
procedure TEinstellungen_Form.MonitoringBtnClick(Sender: TObject);
begin
  LMDOpenDialog1.InitialDir := ExtractFilePath(Edit1.Text);
  if LMDOpenDialog1.Execute then
    Edit1.Text := LMDOpenDialog1.Filename;
end;

// Pfad zu QPDF
procedure TEinstellungen_Form.Button1Click(Sender: TObject);
begin
  LMDOpenDialog1.InitialDir := ExtractFilePath(Edit4.Text);
  if LMDOpenDialog1.Execute then
    Edit4.Text := LMDOpenDialog1.Filename;
end;

// Pfad zu PDFtk
procedure TEinstellungen_Form.Button4Click(Sender: TObject);
begin
  LMDOpenDialog1.InitialDir := ExtractFilePath(Edit5.Text);
  if LMDOpenDialog1.Execute then
    Edit5.Text := LMDOpenDialog1.Filename;
end;

// Pfad zu den XPDF-Tools
procedure TEinstellungen_Form.Button5Click(Sender: TObject);
var
  s: String;
begin
  s := Edit6.Text;

  LMDShellSysBrowseDialog1.SelectedPath := ExcludeTrailingBackslash(s);
  LMDShellSysBrowseDialog1.Caption :=
    'Bitte das \FreePDF64\xpdf\bin64-Verzeichnis auswählen';
  LMDShellSysBrowseDialog1.InstructionText :=
    'Die Tools aus diesem Verzeichnis führen verschiedene Funktionen für PDF-Dateien aus.';

  if LMDShellSysBrowseDialog1.Execute then
    s := LMDShellSysBrowseDialog1.SelectedPath;
  Edit6.Text := IncludeTrailingBackslash(s);

  OKBitBtn1.SetFocus;
end;

// Pfad zu den ImageMagick-Tools
procedure TEinstellungen_Form.Button6Click(Sender: TObject);
var
  s: String;
begin
  s := Edit7.Text;

  LMDShellSysBrowseDialog1.SelectedPath := ExcludeTrailingBackslash(s);
  LMDShellSysBrowseDialog1.Caption :=
    'Bitte das \FreePDF64\ImageMagick-Verzeichnis auswählen';
  LMDShellSysBrowseDialog1.InstructionText :=
    'Die Tools aus diesem Verzeichnis sind für die Grafikumwandlungen zuständig.';

  if LMDShellSysBrowseDialog1.Execute then
    s := LMDShellSysBrowseDialog1.SelectedPath;
  Edit7.Text := IncludeTrailingBackslash(s);

  OKBitBtn1.SetFocus;
end;

// Pfad zu den ExifTool-Tools
procedure TEinstellungen_Form.Button7Click(Sender: TObject);
var
  s: String;
begin
  s := Edit8.Text;

  LMDShellSysBrowseDialog1.SelectedPath := ExcludeTrailingBackslash(s);
  LMDShellSysBrowseDialog1.Caption :=
    'Bitte das \FreePDF64\ExifTool-Verzeichnis auswählen';
  LMDShellSysBrowseDialog1.InstructionText :=
    'ExifTool ist für die Anzeige der Datei-Informationen zuständig.';

  if LMDShellSysBrowseDialog1.Execute then
    s := LMDShellSysBrowseDialog1.SelectedPath;
  Edit8.Text := IncludeTrailingBackslash(s);

  OKBitBtn1.SetFocus;
end;

// Pfad zum Editor
procedure TEinstellungen_Form.Button2Click(Sender: TObject);
begin
  LMDOpenDialog1.InitialDir := ExtractFilePath(Edit2.Text);
  if LMDOpenDialog1.Execute then
    Edit2.Text := LMDOpenDialog1.Filename;
end;

// Pfad zur PDF-Readerauswahl
procedure TEinstellungen_Form.Button3Click(Sender: TObject);
begin
  LMDOpenDialog1.InitialDir := ExtractFilePath(Edit3.Text);
  if LMDOpenDialog1.Execute then
    PDFReader := LMDOpenDialog1.Filename;
  Edit3.Text := PDFReader;
end;

procedure TEinstellungen_Form.CancelBitBtn1Click(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile, s: String;
  i: Integer;
  b: boolean;
begin
  try
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.Ini';
    IniDat := TIniFile.Create(IniFile);
    // Speichere beim Beenden des Programmes wichtige Daten in die 'FreePDF64.Ini'
    with IniDat do
    begin
      Edit1.Text := ReadString('Files', 'Ghostscript', Edit1.Text);
      Edit4.Text := ReadString('Files', 'QPDF', Edit4.Text);
      Edit5.Text := ReadString('Files', 'PDFtk', Edit5.Text);
      Edit6.Text := ReadString('Files', 'XPDF-Tools', Edit6.Text);
      Edit2.Text := ReadString('Files', 'Editor', Edit2.Text);
      Edit7.Text := ReadString('Files', 'ImageMagick', Edit7.Text);
      Edit8.Text := ReadString('Files', 'ExifTool', Edit8.Text);
      Edit3.Text := ReadString('Files', 'PDF-Reader', PDFReader);
      PDFLevel.ItemIndex := ReadInteger('Compatibility', 'Level',
        PDFLevel.ItemIndex);
      DistParam.ItemIndex := ReadInteger('Distiller', 'Parameter',
        DistParam.ItemIndex);
      AutoRP.ItemIndex := ReadInteger('Distiller', 'AutoRotatePages',
        AutoRP.ItemIndex);
      SchriftParams.ItemIndex := ReadInteger('Resolution', 'dpi',
        SchriftParams.ItemIndex);
      SpinEdit1.Value := ReadInteger('Resolution', 'dpi2', SpinEdit1.Value);
      SpinEdit2.Value := ReadInteger('Resolution', 'Qualität', SpinEdit2.Value);
      AuswahlRG.ItemIndex := ReadInteger('Format', 'Choice',
        AuswahlRG.ItemIndex);
      FastCB.Checked := ReadBool('Format', 'FastWebView', FastCB.Checked);
      AnzeigenCB.Checked := ReadBool('Format', 'View File', AnzeigenCB.Checked);
      SystemklangCB.Checked := ReadBool('Format', 'System Sound',
        SystemklangCB.Checked);
      PDF_Shrink.Checked := ReadBool('Format', 'Shrink PDF',
        PDF_Shrink.Checked);
      PDF_Shrink2.Checked := ReadBool('Format', 'Shrink PDF2',
        PDF_Shrink2.Checked);
      HeightSpin.Value := ReadInteger('Start', 'Memo Height Addition',
        HeightSpin.Value);
      SoundSpin.Value := ReadInteger('Format', 'System Sound Volume 0-65535',
        SoundSpin.Value);
      ZusatzAnAus.Checked := ReadBool('Zusatz', 'On/Off', ZusatzAnAus.Checked);
      ExifToolGE.Checked := ReadBool('Zusatz', 'German/English',
        ExifToolGE.Checked);
      FontCB.Checked := ReadBool('Zusatz', 'Memo Font', FontCB.Checked);
      FreePDF64_Notify.MonitoringFolder.Text :=
        ReadString('Monitoring', 'Folder', s);
      FreePDF64_Notify.LMDShellNotify.Active :=
        ReadBool('Monitoring', 'Start', b);
      FreePDF64_Notify.SpinEditSec.Value := ReadInteger('Monitoring',
        'Time', i);
      FreePDF64_Notify.Ziel_FestCB.Checked :=
        ReadBool('Monitoring', 'Fixed', b);
      FreePDF64_Notify.ZielEdit.Text := ReadString('Monitoring',
        'Fixed Folder', s);
    end;
    // Speicher wird wieder freigeben
    IniDat.Free;
  except
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        FreePDF64_Form.PlaySoundFile(ExtractFilePath(Application.ExeName) +
          'sounds\alert.wav');
      ShowMessage('Error');
    end;
  end;
  PDFA_CB.Checked := False;
  PDFX.Checked    := False;
  PDFX4.Checked   := False;
  Close;
end;

procedure TEinstellungen_Form.DateianlageClick(Sender: TObject);
begin
  // Form soll mittig angezeigt werden
  Dateianlage_Form.Position := poMainFormCenter;
  Dateianlage_Form.ShowModal;
end;

procedure TEinstellungen_Form.Edit3Exit(Sender: TObject);
begin
  if Einstellungen_Form.Edit3.Text = '' then
    Einstellungen_Form.Edit3.Text := ExtractFilePath(Application.ExeName) + 'SumatraPDF\SumatraPDF-3.5.2-64.exe';
  PDFReader := Einstellungen_Form.Edit3.Text;
end;

procedure TEinstellungen_Form.EncryptBtClick(Sender: TObject);
begin
  // Form soll mittig angezeigt werden
  Encrypt_Form.Position := poMainFormCenter;
  // Aufruf der Verschlüsselungs-Form
  Encrypt_Form.ShowModal;
end;

procedure TEinstellungen_Form.FormCreate(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile: String;
begin
  // Form soll mittig angezeigt werden.
  Einstellungen_Form.Position := poMainFormCenter;
  Edit1.Text := Ghostscript;
  try
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.Ini';
    IniDat := TIniFile.Create(IniFile);
    with IniDat do
    begin
      Edit1.Text := ReadString('Files', 'Ghostscript', Edit1.Text);
      Edit4.Text := ReadString('Files', 'QPDF', Edit4.Text);
      Edit5.Text := ReadString('Files', 'PDFtk', Edit5.Text);
      // Pfad zu den XPDF-Tools
      Edit6.Text := ReadString('Files', 'XPDF-Tools', Edit6.Text);
      Edit2.Text := ReadString('Files', 'Editor', Edit2.Text);
      Edit7.Text := ReadString('Files', 'ImageMagick', Edit7.Text);
      Edit8.Text := ReadString('Files', 'ExifTool', Edit8.Text);
      PDFLevel.ItemIndex := ReadInteger('Compatibility', 'Level',
        PDFLevel.ItemIndex);
      DistParam.ItemIndex := ReadInteger('Distiller', 'Parameter',
        DistParam.ItemIndex);
      AutoRP.ItemIndex := ReadInteger('Distiller', 'AutoRotatePages',
        AutoRP.ItemIndex);
      SchriftParams.ItemIndex := ReadInteger('Resolution', 'dpi',
        SchriftParams.ItemIndex);
      SpinEdit1.Value := ReadInteger('Resolution', 'dpi2', SpinEdit1.Value);
      SpinEdit2.Value := ReadInteger('Resolution', 'Qualität', SpinEdit2.Value);
      AuswahlRG.ItemIndex := ReadInteger('Format', 'Choice',
        AuswahlRG.ItemIndex);
      FastCB.Checked := ReadBool('Format', 'FastWebView', FastCB.Checked);
      AnzeigenCB.Checked := ReadBool('Format', 'View File', AnzeigenCB.Checked);
      SystemklangCB.Checked := ReadBool('Format', 'System Sound',
        SystemklangCB.Checked);
      PDF_Shrink.Checked := ReadBool('Format', 'Shrink PDF',
        PDF_Shrink.Checked);
      PDF_Shrink2.Checked := ReadBool('Format', 'Shrink PDF',
        PDF_Shrink2.Checked);
    end;
    // Speicher wird wieder freigeben
    IniDat.Free;
  except
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        FreePDF64_Form.PlaySoundFile(ExtractFilePath(Application.ExeName) +
          'sounds\alert.wav');
      ShowMessage('Error');
    end;
  end;

  if AuswahlRG.ItemIndex > 0 then
    Dateianlage.Enabled := False;
  // PDF und JPEG zu PDF
  if (AuswahlRG.ItemIndex = 0) or (AuswahlRG.ItemIndex = 11) then
  begin
    SpinEdit1.Enabled := False;
    Label4.Enabled := False;
    SpinEdit2.Enabled := False;
    Label5.Enabled := False;
    AnzeigenCB.Enabled := True;
    PDF_Shrink.Enabled := True;
    PDF_Shrink2.Enabled := True;
    FastCB.Enabled := True;
    AutoRP.Enabled := True;
    PDFMark.Enabled := True;
    SchriftParams.Enabled := True;
    DistParam.Enabled := True;
    PDFLevel.Enabled := True;
    PDFA_CB.Enabled := True;
    PDFX.Enabled := True;
    PDFX4.Enabled := True;
    EncryptBt.Enabled := True;
    SeitenBt.Enabled := True;
    if AuswahlRG.ItemIndex = 11 then
    begin
      PDFMark.Enabled := False;
      SeitenBt.Enabled := False;
      AutoRP.Enabled := False;
      SchriftParams.Enabled := False;
    end;
  end
  else
    // PS
    if AuswahlRG.ItemIndex = 1 then
    begin
      SpinEdit1.Enabled := False;
      Label4.Enabled := False;
      SpinEdit2.Enabled := False;
      Label5.Enabled := False;
      AnzeigenCB.Enabled := True;
      PDF_Shrink.Enabled := False;
      PDF_Shrink2.Enabled := False;
      FastCB.Enabled := False;
      AutoRP.Enabled := False;
      PDFMark.Enabled := False;
      SchriftParams.Enabled := True;
      DistParam.Enabled := True;
      PDFLevel.Enabled := True;
      PDFA_CB.Enabled := False;
      PDFX.Enabled := False;
      PDFX4.Enabled := False;
      EncryptBt.Enabled := False;
      SeitenBt.Enabled := False;
    end
    else
      // DOCX
      if AuswahlRG.ItemIndex = 2 then
      begin
        SpinEdit1.Enabled := False;
        Label4.Enabled := False;
        SpinEdit2.Enabled := False;
        Label5.Enabled := False;
        AnzeigenCB.Enabled := False;
        PDF_Shrink.Enabled := False;
        PDF_Shrink2.Enabled := False;
        FastCB.Enabled := False;
        AutoRP.Enabled := False;
        PDFMark.Enabled := False;
        SchriftParams.Enabled := False;
        DistParam.Enabled := False;
        PDFLevel.Enabled := False;
        PDFA_CB.Enabled := False;
        PDFX.Enabled := False;
        PDFX4.Enabled := False;
        EncryptBt.Enabled := False;
        SeitenBt.Enabled := False;
      end
      else
        // TXT
        if AuswahlRG.ItemIndex = 3 then
        begin
          SpinEdit1.Enabled := False;
          Label4.Enabled := False;
          SpinEdit2.Enabled := False;
          Label5.Enabled := False;
          AnzeigenCB.Enabled := True;
          PDF_Shrink.Enabled := False;
          PDF_Shrink2.Enabled := False;
          FastCB.Enabled := False;
          AutoRP.Enabled := False;
          PDFMark.Enabled := False;
          SchriftParams.Enabled := False;
          DistParam.Enabled := False;
          PDFLevel.Enabled := False;
          PDFA_CB.Enabled := False;
          PDFX.Enabled := False;
          PDFX4.Enabled := False;
          EncryptBt.Enabled := False;
          SeitenBt.Enabled := False;
        end
        else
          // BMP
          if AuswahlRG.ItemIndex = 4 then
          begin
            SpinEdit1.Enabled := True;
            Label4.Enabled := False;
            SpinEdit2.Enabled := False;
            Label5.Enabled := False;
            AnzeigenCB.Enabled := False;
            PDF_Shrink.Enabled := False;
            PDF_Shrink2.Enabled := False;
            FastCB.Enabled := False;
            AutoRP.Enabled := False;
            PDFMark.Enabled := False;
            SchriftParams.Enabled := False;
            DistParam.Enabled := False;
            PDFLevel.Enabled := False;
            PDFA_CB.Enabled := False;
            PDFX.Enabled := False;
            PDFX4.Enabled := False;
            EncryptBt.Enabled := False;
            SeitenBt.Enabled := False;
          end
          else
            // JPG
            if AuswahlRG.ItemIndex = 5 then
            begin
              SpinEdit1.Enabled := True;
              Label4.Enabled := True;
              SpinEdit2.Enabled := True;
              Label5.Enabled := True;
              AnzeigenCB.Enabled := False;
              PDF_Shrink.Enabled := False;
              PDF_Shrink2.Enabled := False;
              FastCB.Enabled := False;
              AutoRP.Enabled := False;
              PDFMark.Enabled := False;
              SchriftParams.Enabled := False;
              DistParam.Enabled := False;
              PDFLevel.Enabled := False;
              PDFA_CB.Enabled := False;
              PDFX.Enabled := False;
              PDFX4.Enabled := False;
              EncryptBt.Enabled := False;
              SeitenBt.Enabled := False;
            end
            else
              // PNG
              if AuswahlRG.ItemIndex = 6 then
              begin
                SpinEdit1.Enabled := True;
                Label4.Enabled := True;
                SpinEdit2.Enabled := False;
                Label5.Enabled := False;
                AnzeigenCB.Enabled := False;
                PDF_Shrink.Enabled := False;
                PDF_Shrink2.Enabled := False;
                FastCB.Enabled := False;
                AutoRP.Enabled := False;
                PDFMark.Enabled := False;
                SchriftParams.Enabled := False;
                DistParam.Enabled := False;
                PDFLevel.Enabled := False;
                PDFA_CB.Enabled := False;
                PDFX.Enabled := False;
                PDFX4.Enabled := False;
                EncryptBt.Enabled := False;
                SeitenBt.Enabled := False;
              end;
  // TIFF
  if (AuswahlRG.ItemIndex > 6) and (AuswahlRG.ItemIndex < 10) then
  begin
    SpinEdit1.Enabled := True;
    Label4.Enabled := True;
    SpinEdit2.Enabled := False;
    Label5.Enabled := False;
    AnzeigenCB.Enabled := True;
    PDF_Shrink.Enabled := False;
    PDF_Shrink2.Enabled := False;
    FastCB.Enabled := False;
    AutoRP.Enabled := False;
    PDFMark.Enabled := False;
    SchriftParams.Enabled := False;
    DistParam.Enabled := False;
    PDFLevel.Enabled := False;
    PDFA_CB.Checked := False;
    PDFA_CB.Enabled := False;
    PDFA.Enabled := False;
    PDFX.Enabled := False;
    PDFX4.Enabled := False;
    EncryptBt.Enabled := False;
    SeitenBt.Enabled := False;
    Dateianlage.Enabled := False;
  end;
  // BMP/PNG/TIFF zu PDF
  if (AuswahlRG.ItemIndex = 10) or (AuswahlRG.ItemIndex = 12) or
    (AuswahlRG.ItemIndex = 13) then
  begin
    SpinEdit1.Enabled := False;
    Label4.Enabled := False;
    SpinEdit2.Enabled := False;
    Label5.Enabled := False;
    AnzeigenCB.Enabled := True;
    PDF_Shrink.Enabled := False;
    PDF_Shrink2.Enabled := False;
    FastCB.Enabled := False;
    AutoRP.Enabled := False;
    PDFMark.Enabled := False;
    SchriftParams.Enabled := False;
    DistParam.Enabled := False;
    PDFLevel.Enabled := False;
    PDFA_CB.Checked := False;
    PDFA_CB.Enabled := False;
    PDFA.Enabled := False;
    PDFX.Enabled := False;
    PDFX4.Enabled := False;
    EncryptBt.Enabled := False;
    SeitenBt.Enabled := False;
    Dateianlage.Enabled := False;
    ZusatzAnAus.Enabled := False;
    Zusatz.Enabled := False;
  end;
  if PDFA_CB.Checked = False then
    PDFA.Enabled := False;
end;

procedure TEinstellungen_Form.FormShow(Sender: TObject);
var
  s: string;
begin
  Edit3.Text := PDFReader;

  s := 'Überwachung';
  if FreePDF64_Notify.LMDShellNotify.Active = True then
  begin
    UeberwachungBtn.Caption := s + ' ist AN';
    UeberwachungBtn.ImageIndex := 57;
  end
  else
  begin
    UeberwachungBtn.Caption := s + ' ist AUS';
    UeberwachungBtn.ImageIndex := 58;
  end;
  PDFAnzeiger.Cursor := crHandPoint;
  ImageMagick.Cursor := crHandPoint;
  ExifTool.Cursor := crHandPoint;
  Label1.Cursor := crHandPoint;
  Label2.Cursor := crHandPoint;
  Label3.Cursor := crHandPoint;
  Label6.Cursor := crHandPoint;
  Label7.Cursor := crHandPoint;

  PDFAnzeiger.Hint := 'Homepage von SumatraPDF aufrufen';

  if ZusatzAnAus.Checked = False then
    Zusatz.Enabled := False
  else
    Zusatz.Enabled := True;
end;

procedure TEinstellungen_Form.InfoClick(Sender: TObject);
begin
  // Form soll mittig angezeigt werden.
  Einstellungen_Hilfe_Form.Position := poMainFormCenter;
  Einstellungen_Hilfe_Form.ShowModal;
end;

procedure TEinstellungen_Form.Label1Click(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open',
    PChar('https://www.ghostscript.com/'), NIL, NIL, SW_NORMAL);
end;

procedure TEinstellungen_Form.Label2Click(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open',
    PChar('https://notepad-plus-plus.org/'), NIL, NIL, SW_NORMAL);
end;

procedure TEinstellungen_Form.Label3Click(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open',
    PChar('https://qpdf.sourceforge.io/'), NIL, NIL, SW_NORMAL);
end;

procedure TEinstellungen_Form.Label6Click(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open',
    PChar('https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/'), NIL, NIL,
    SW_NORMAL);
end;

procedure TEinstellungen_Form.Label7Click(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', PChar('https://www.xpdfreader.com/index.html'), NIL, NIL, SW_NORMAL);
end;

procedure TEinstellungen_Form.PDFAnzeigerClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', PChar('https://www.sumatrapdfreader.org/'), NIL, NIL,
    SW_NORMAL);
end;

procedure TEinstellungen_Form.ImageMagickClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', PChar('https://imagemagick.org/'),
    NIL, NIL, SW_NORMAL);
end;

procedure TEinstellungen_Form.ExifToolClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', PChar('https://exiftool.org/'), NIL,
    NIL, SW_NORMAL);
end;

// Umschalten zwischen deutscher/englischer Datei-Informationen
procedure TEinstellungen_Form.ExifToolGEClick(Sender: TObject);
begin
  if ExifToolGE.Checked = True then
    GE := '-lang de' // deutsch
  else
    GE := ''; // englisch
end;

procedure TEinstellungen_Form.FontCBClick(Sender: TObject);
begin
  if FontCB.Checked = True then
  begin
    FreePDF64_Form.Memo1.Font.Name := 'Consolas';
    FreePDF64_Form.Memo1.Font.Size := 10;
  end
  else
  begin
    FreePDF64_Form.Memo1.Font.Name := 'Courier New';
    FreePDF64_Form.Memo1.Font.Size := 10;
  end;
end;

// Word: 0 - 65535, wobei 65535 die lauteste Stärke ist
procedure SetVolume(const volL, volR: Word);
var
  hWO: HWAVEOUT;
  waveF: TWAVEFORMATEX;
  vol: DWORD;
begin
  // init TWAVEFORMATEX
  FillChar(waveF, SizeOf(waveF), 0);
  // open WaveMapper = std output of playsound
  waveOutOpen(@hWO, WAVE_MAPPER, @waveF, 0, 0, 0);
  vol := volL + volR shl 16;
  // set volume
  waveOutSetVolume(hWO, vol);
  waveOutClose(hWO);
end;

procedure TEinstellungen_Form.OKBitBtn1Click(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile: String;
  i: Integer;
begin
  try
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.Ini';
    IniDat := TIniFile.Create(IniFile);
    // Speichere beim Beenden des Programmes wichtige Daten in die 'FreePDF64.Ini'
    with IniDat do
    begin
      WriteString('Files', 'Ghostscript', Edit1.Text);
      WriteString('Files', 'QPDF', Edit4.Text);
      WriteString('Files', 'PDFtk', Edit5.Text);
      WriteString('Files', 'XPDF-Tools', Edit6.Text);
      WriteString('Files', 'Editor', Edit2.Text);
      WriteString('Files', 'PDF-Reader', Edit3.Text);
      WriteString('Files', 'ImageMagick', Edit7.Text);
      WriteString('Files', 'ExifTool', Edit8.Text);
      WriteInteger('Compatibility', 'Level', PDFLevel.ItemIndex);
      WriteInteger('Distiller', 'Parameter', DistParam.ItemIndex);
      WriteInteger('Distiller', 'AutoRotatePages', AutoRP.ItemIndex);
      WriteInteger('Resolution', 'dpi', SchriftParams.ItemIndex);
      WriteInteger('Resolution', 'dpi2', SpinEdit1.Value);
      WriteInteger('Resolution', 'Quality', SpinEdit2.Value);
      WriteInteger('Format', 'Choice', AuswahlRG.ItemIndex);
      WriteInteger('Start', 'Memo Height Addition', HeightSpin.Value);
      WriteInteger('Format', 'System Sound Volume 0-65535', SoundSpin.Value);
      WriteBool('Format', 'FastWebView', FastCB.Checked);
      WriteBool('Format', 'View File', AnzeigenCB.Checked);
      WriteBool('Format', 'System Sound', SystemklangCB.Checked);
      WriteBool('Format', 'Shrink PDF', PDF_Shrink.Checked);
      WriteBool('Format', 'Shrink PDF2', PDF_Shrink2.Checked);

      // Zusatz schreiben
      IniDat.EraseSection('Zusatz');
      if Zusatz_Form.ZusatzCB.Items.Count > 0 then
        for i := 1 to Zusatz_Form.ZusatzCB.Items.Count do
          if Zusatz_Form.ZusatzCB.Items[i] <> '"' then
            WriteString('Zusatz', 'Zeichenketten' + IntToStr(i - 1),
              '"' + Zusatz_Form.ZusatzCB.Items[i - 1] + '"');

      WriteBool('Zusatz', 'On/Off', ZusatzAnAus.Checked);
      WriteBool('Zusatz', 'German/English', ExifToolGE.Checked);
      WriteBool('Zusatz', 'Memo Font', FontCB.Checked);
    end;
    // Speicher wird wieder freigeben
    IniDat.Free;
  except
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        FreePDF64_Form.PlaySoundFile(ExtractFilePath(Application.ExeName) +
          'sounds\alert.wav');
      ShowMessage('Error');
    end;
  end;
  Vol1 := SoundSpin.Value;
  if (Vol1 < 0) or (Vol1 > 65535) then
    Vol1 := 65535;
  Vol2 := Vol1;
  // Word: 0 - 65535, wobei 65535 die lauteste Stärke ist
  SetVolume(Vol1, Vol2);
  // Memo Height Addition
  MHA := HeightSpin.Value;

  if AuswahlRG.ItemIndex = 0 then
    Text_FormatBtn := ' PS/PDF zu PDF '
  else if AuswahlRG.ItemIndex = 1 then
    Text_FormatBtn := ' PDF zu PS '
  else if AuswahlRG.ItemIndex = 2 then
    Text_FormatBtn := ' PDF zu DOCX '
  else if AuswahlRG.ItemIndex = 3 then
    Text_FormatBtn := ' PS/PDF zu TXT '
  else if AuswahlRG.ItemIndex = 4 then
    Text_FormatBtn := ' PS/PDF zu BMP '
  else if AuswahlRG.ItemIndex = 5 then
    Text_FormatBtn := ' PS/PDF zu JPEG '
  else if AuswahlRG.ItemIndex = 6 then
    Text_FormatBtn := ' PS/PDF zu PNG '
  else if AuswahlRG.ItemIndex = 7 then
    Text_FormatBtn := ' PS/PDF zu TIFF G4 - BW '
  else if AuswahlRG.ItemIndex = 8 then
    Text_FormatBtn := ' PS/PDF zu TIFF LZW - BW '
  else if AuswahlRG.ItemIndex = 9 then
    Text_FormatBtn := ' PS/PDF zu TIFF (uncompressed) '
  else if AuswahlRG.ItemIndex = 10 then
    Text_FormatBtn := ' BMP zu PDF '
  else if AuswahlRG.ItemIndex = 11 then
    Text_FormatBtn := ' JPEG zu PDF '
  else if AuswahlRG.ItemIndex = 12 then
    Text_FormatBtn := ' PNG zu PDF '
  else if AuswahlRG.ItemIndex = 13 then
    Text_FormatBtn := ' TIFF zu PDF ';
  FreePDF64_Form.FormatBtn.Caption := 'Formatauswahl:' + Text_FormatBtn;

  if ((Encrypt_Form.BerechtigungCB.Checked) or (Encrypt_Form.KennwortCB.Checked)
    ) and (AuswahlRG.ItemIndex = 0) then
  begin
    if Encrypt_Form.EncryptCombo.ItemIndex = 0 then
      FreePDF64_Form.FormatBtn.Caption := 'Formatauswahl:' + Text_FormatBtn +
        '- (128 RC4)'
    else if Encrypt_Form.EncryptCombo.ItemIndex = 1 then
      FreePDF64_Form.FormatBtn.Caption := 'Formatauswahl:' + Text_FormatBtn +
        '- (128 AES)'
    else if Encrypt_Form.EncryptCombo.ItemIndex = 2 then
      FreePDF64_Form.FormatBtn.Caption := 'Formatauswahl:' + Text_FormatBtn +
        '- (256 AES)';
  end;
  // Abfrage auf Hinweis bzgl. der Extension
  FreePDF64_Form.ExtAbfrage;
end;

procedure TEinstellungen_Form.PDFA_CBClick(Sender: TObject);
begin
  if PDFA_CB.Checked = True then
  begin
    PDFA.Enabled := True;
    PDFX.Checked := False;
    PDFX4.Checked := False;
    EncryptBt.Enabled := False;
    Encrypt_Form.Clear.Click;
  end
  else
  begin
    PDFA.Enabled := False;
    EncryptBt.Enabled := True;
  end;
end;

procedure TEinstellungen_Form.PDFXClick(Sender: TObject);
begin
  if PDFX.Checked = True then
  begin
    PDFX4.Checked     := False;
    PDFA_CB.Checked   := False;
    EncryptBt.Enabled := False;
    Encrypt_Form.Clear.Click;
  end
  else
    EncryptBt.Enabled := True;
end;

procedure TEinstellungen_Form.PDFX4Click(Sender: TObject);
begin
  if PDFX4.Checked = True then
  begin
    PDFX.Checked      := False;
    PDFA_CB.Checked   := False;
    EncryptBt.Enabled := False;
    Encrypt_Form.Clear.Click;
  end
  else
    EncryptBt.Enabled := True;
end;

procedure TEinstellungen_Form.PDF_ShrinkClick(Sender: TObject);
begin
  if PDF_Shrink.Checked then
    PDF_Shrink2.Checked := False
end;

procedure TEinstellungen_Form.PDF_Shrink2Click(Sender: TObject);
begin
  if PDF_Shrink2.Checked then
    PDF_Shrink.Checked := False
end;

procedure TEinstellungen_Form.PDFMarkClick(Sender: TObject);
begin
  // Form soll mittig angezeigt werden
  DokuInfo_Form.Position := poMainFormCenter;
  DokuInfo_Form.ShowModal;
end;

end.
