//
// Programmname: FreePDF64
//

unit FreePDF64_Notify_Unit;

interface

uses
  Forms, StdCtrls, Buttons, Controls, Classes, ShlObj, Windows,
  LMDShNtf, LMDCustomComponent, Dialogs, LMDShBase, ShellAPI, LMDShBrwDlg,
  LMDShDlg, LMDBrowseDlg, Vcl.Samples.Spin, IniFiles, Printers,
  Vcl.ExtCtrls, Graphics, System.Notification, FreePDF64PrinterConfig;

type
  TFreePDF64_Notify = class(TForm)
    MonitoringFolder: TEdit;
    lbObserved: TLabel;
    btnStart: TButton;
    btnStop: TButton;
    LMDShellNotify: TLMDShellNotify;
    OkBitBtn: TBitBtn;
    MonitoringBtn: TButton;
    Wartezeit: TLabel;
    SpinEditSec: TSpinEdit;
    CancelBitBtn1: TBitBtn;
    Label2: TLabel;
    ZielEdit: TEdit;
    Ziel_FestCB: TCheckBox;
    LMDShellSysBrowseDialog1: TLMDShellSysBrowseDialog;
    LMDShellRestartDialog1: TLMDShellRestartDialog;
    NotificationCenter1: TNotificationCenter;
    BenachrichtigungCB: TCheckBox;
    Label1: TLabel;
    TimerPDFUeberwachung: TTimer;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MonitoringBtnClick(Sender: TObject);
    procedure CancelBitBtn1Click(Sender: TObject);
    procedure OkBitBtnClick(Sender: TObject);
    procedure LMDShellNotifyFileCreate(aSender: TObject; aPIDL: PItemIDList);
    procedure LMDShellNotifyShellChangeNotify(aSender: TObject; aPIDL1, aPIDL2: PItemIDList;
              aEvents: TLMDShellNotifyEventTypes);
    procedure Ziel_FestCBClick(Sender: TObject);
    procedure TimerPDFUeberwachungTimer(Sender: TObject);
  private
    { Private declarations }
    procedure Abfrage(const EventName: string; aPIDL1: PItemIDList = nil;
                                                aPIDL2: PItemIDList = nil);
    procedure StarteNaechsteDatei;
  public
    { Public declarations }
  end;

var
  FreePDF64_Notify: TFreePDF64_Notify;
  PDF_UeberwachungAktiv: Boolean;
  PDF_Ueberwachung_GroesseAlt: Int64;
  PDF_Ueberwachung_StableCount: Integer;
  PDF_Ueberwachung_StartTick: Cardinal;


implementation

{$WARNINGS OFF}
uses
  SysUtils, LMDShPIDL, Einstellungen_Unit, FreePDF64_Unit, Zusatz_Unit, System.IOUtils;

{$WARNINGS ON}

{$R *.DFM}


procedure UpdateFreePDF64PrinterSourceDirectory(
  const SourceDirectory: string);
var
  Ini: TIniFile;
  Dir: string;
  ConfigDir: string;
begin
  Dir := Trim(SourceDirectory);

  if Dir = '' then
    Exit;

  Dir := IncludeTrailingPathDelimiter(Dir);

  { Das überwachte Quellverzeichnis muss vorhanden sein. }
  if not DirectoryExists(Dir) then
    if not ForceDirectories(Dir) then
      raise Exception.Create(
        'Das Quellverzeichnis konnte nicht erstellt werden:' +
        sLineBreak + Dir);

  ConfigDir := ExtractFilePath(FREEPDF64_CONFIG_FILE);

  { Dieses Verzeichnis muss einmalig durch die Installation
    angelegt und für normale Benutzer beschreibbar sein. }
  if not DirectoryExists(ConfigDir) then
    raise Exception.Create(
      'Das FreePDF64-Konfigurationsverzeichnis ist nicht vorhanden:' +
      sLineBreak +
      ConfigDir +
      sLineBreak +
      sLineBreak +
      'Bitte zuerst Set_FreePDF64_Permissions.cmd als Administrator ausführen.');

  Ini := TIniFile.Create(FREEPDF64_CONFIG_FILE);
  try
    Ini.WriteString(
      'Printer',
      'SourceDirectory',
      Dir);

    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

// Sucht nach der Verarbeitung einer Datei nach weiteren Dateien im
// Überwachungsverzeichnis. Dadurch werden auch mehrere gleichzeitig
// eingekopierte Dateien nacheinander verarbeitet, selbst wenn für
// einzelne Dateien kein weiteres Notify-Ereignis mehr ankommt.
procedure TFreePDF64_Notify.StarteNaechsteDatei;
var
  MonPath: string;
  SR: TSearchRec;
  DateiPfad: string;
begin
  if PDF_UeberwachungAktiv then
    Exit;

  MonPath := IncludeTrailingPathDelimiter(Trim(MonitoringFolder.Text));
  if MonPath = '' then
    Exit;

  if not DirectoryExists(MonPath) then
    Exit;

  if FindFirst(MonPath + '*.*', faAnyFile, SR) = 0 then
  try
    repeat
      if (SR.Name <> '.') and (SR.Name <> '..') and
         ((SR.Attr and faDirectory) = 0) then
      begin
        DateiPfad := MonPath + SR.Name;

        if FileExists(DateiPfad) then
        begin
          FreePDF64_Form.PDF_UeberwachungsDatei := DateiPfad;
          PDF_UeberwachungAktiv := True;
          PDF_Ueberwachung_GroesseAlt := -1;
          PDF_Ueberwachung_StableCount := 0;
          PDF_Ueberwachung_StartTick := GetTickCount;
          TimerPDFUeberwachung.Enabled := True;
          Exit;
        end;
      end;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

// Abfrage und Handlung, wenn ausgew�hlte Datei im ausgewählten Verzeichnis erkannt wurde...
procedure TFreePDF64_Notify.Abfrage(const EventName: string;
  aPIDL1, aPIDL2: PItemIDList);
var
  MonPath: string;
  DateiPfad: string;
  PIDLPath: array[0..MAX_PATH - 1] of WideChar;
begin
  { --------------------------------------------------------------- }
  { Keine gültige PIDL -> nichts zu tun                             }
  { --------------------------------------------------------------- }
  if not (Assigned(aPIDL1) or Assigned(aPIDL2)) then
    Exit;

  { --------------------------------------------------------------- }
  { Wenn bereits eine Datei zur Verarbeitung vorgemerkt ist,         }
  { dieses Ereignis nicht erneut übernehmen.                         }
  { --------------------------------------------------------------- }
  if PDF_UeberwachungAktiv then
    Exit;

  MonPath := IncludeTrailingPathDelimiter(
    Trim(MonitoringFolder.Text));

  if MonPath = '' then
    Exit;

  { --------------------------------------------------------------- }
  { Pfad aus PIDL1 ermitteln                                         }
  { --------------------------------------------------------------- }
  DateiPfad := '';

  if Assigned(aPIDL1) then
  begin
    FillChar(PIDLPath, SizeOf(PIDLPath), 0);

    if SHGetPathFromIDListW(aPIDL1, PIDLPath) then
      DateiPfad := PIDLPath;
  end;

  { --------------------------------------------------------------- }
  { Falls PIDL1 keinen Dateipfad liefert, PIDL2 versuchen            }
  { --------------------------------------------------------------- }
  if (DateiPfad = '') and Assigned(aPIDL2) then
  begin
    FillChar(PIDLPath, SizeOf(PIDLPath), 0);

    if SHGetPathFromIDListW(aPIDL2, PIDLPath) then
      DateiPfad := PIDLPath;
  end;

  if DateiPfad = '' then
    Exit;

  { --------------------------------------------------------------- }
  { Nur Dateien direkt im überwachten Verzeichnis verarbeiten        }
  { --------------------------------------------------------------- }
  if not SameText(
    IncludeTrailingPathDelimiter(ExtractFilePath(DateiPfad)),
    MonPath) then
    Exit;

  if not FileExists(DateiPfad) then
    Exit;

  if ExtractFileName(DateiPfad) = '' then
    Exit;

  { --------------------------------------------------------------- }
  { Datei für den Timer vormerken                                   }
  { --------------------------------------------------------------- }
  FreePDF64_Form.PDF_UeberwachungsDatei := DateiPfad;
  PDF_UeberwachungAktiv := True;
  PDF_Ueberwachung_GroesseAlt := -1;
  PDF_Ueberwachung_StableCount := 0;
  PDF_Ueberwachung_StartTick := GetTickCount;

  { --------------------------------------------------------------- }
  { Die eigentliche Verarbeitung erfolgt NICHT im Shell-Notify-      }
  { Event. Dadurch wird LMDShellNotify nicht blockiert.              }
  { --------------------------------------------------------------- }
  TimerPDFUeberwachung.Enabled := True;
end;

// Notify bei OnFileCreate
procedure TFreePDF64_Notify.LMDShellNotifyFileCreate(aSender: TObject;
  aPIDL: PItemIDList);
begin
  Abfrage('OnFileCreate', aPIDL);
end;

// Notify bei OnShellChangeNotify
procedure TFreePDF64_Notify.LMDShellNotifyShellChangeNotify(aSender: TObject; aPIDL1, aPIDL2: PItemIDList;
  aEvents: TLMDShellNotifyEventTypes);
begin
  Abfrage('OnShellChangeNotify', aPIDL1, aPIDL2);
end;

procedure TFreePDF64_Notify.MonitoringBtnClick(Sender: TObject);
var
  s: String;
begin
  // Übergabe des gewählten Verzeichnisses
  s := MonitoringFolder.Text;

  LMDShellSysBrowseDialog1.SelectedPath    := ExcludeTrailingBackslash(s);
  LMDShellSysBrowseDialog1.Caption         := 'Überwachungsverzeichnis auswählen';
  LMDShellSysBrowseDialog1.InstructionText := 'Die automatische Überwachung fragt dieses Verzeichnis nach eingehenden Dateien ab. ' +
                                              'Wenn die Überwachung aktiv ist, werden diese automatisch in das gewünschte Format ' +
                                              'umgewandelt und ins Zielverzeichnis verschoben.';

  if LMDShellSysBrowseDialog1.Execute then
    MonitoringFolder.Text := IncludeTrailingBackslash(LMDShellSysBrowseDialog1.SelectedPath)
  else
    MonitoringFolder.Text := IncludeTrailingBackslash(s);

  // Für Übernahme des Sourcedirectory für den FreePDF64 Postscript-Drucker
  If btnStart.Enabled then
  begin
    btnStart.Click;
    btnStop.Click;
  end else
  If btnStop.Enabled then
  begin
    btnStop.Click;
    btnStart.Click;
  end;

  OkBitBtn.SetFocus;
end;

procedure TFreePDF64_Notify.OkBitBtnClick(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile, s1: String;
begin
  FreePDF64_Form.StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers[printer.printerindex] +
    ' | Erstellte Dateien (seit Nullstellung): ' + IntToStr(Counter);
  try
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.Ini';
    IniDat := TIniFile.Create(IniFile);
    // Speichere beim Beenden des Programmes wichtige Daten in die 'FreePDF64.Ini'
    with IniDat do
    begin
      WriteString ('Monitoring', 'Folder', MonitoringFolder.Text);
      WriteBool   ('Monitoring', 'Start', LMDShellNotify.Active);
      WriteInteger('Monitoring', 'Time', SpinEditSec.Value);
      WriteBool   ('Monitoring', 'Fixed', Ziel_FestCB.Checked);
      WriteString ('Monitoring', 'Fixed Folder', ZielEdit.Text);
      WriteBool   ('Monitoring', 'Note', BenachrichtigungCB.Checked);
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

  s1 := 'Quelle - ' + MonitoringFolder.Text + '*.*';
  if (FreePDF64_Form.Quelllabel.Caption = s1) and (FreePDF64_Form.MonitorBtn.ImageIndex = 57) then
    FreePDF64_Form.QuellLabel.Font.Color := clRed
  else
    FreePDF64_Form.QuellLabel.Font.Color := clWindowText;
  s1 := 'Ziel - ' + MonitoringFolder.Text + '*.*';
  if (FreePDF64_Form.Ziellabel.Caption = s1) and (FreePDF64_Form.MonitorBtn.ImageIndex = 57) then
    FreePDF64_Form.ZielLabel.Font.Color := clRed
  else
    FreePDF64_Form.ZielLabel.Font.Color := clWindowText;

   try
     UpdateFreePDF64PrinterSourceDirectory(FreePDF64_Notify.MonitoringFolder.Text);
   except
     // Fehler ignorieren
   end;
   Close;
end;

// Pfad von %APPDATA%
function GetAppDataPath: string;
begin
  Result := TPath.GetHomePath;
end;

procedure TFreePDF64_Notify.TimerPDFUeberwachungTimer(Sender: TObject);
var
  DateiPfad: string;
  DateiName: string;
  DateiEndung: string;
  MonPath: string;
  AktuelleGroesse: Int64;
  t: Integer;
  N: TNotification;
  PDFStartOK: Boolean;
begin
  { --------------------------------------------------------------- }
  { Timer für diesen Durchlauf ausschalten                          }
  { --------------------------------------------------------------- }
  TimerPDFUeberwachung.Enabled := False;

  { --------------------------------------------------------------- }
  { Keine aktive Datei                                              }
  { --------------------------------------------------------------- }
  if not PDF_UeberwachungAktiv then
    Exit;

  DateiPfad := FreePDF64_Form.PDF_UeberwachungsDatei;

  if DateiPfad = '' then
  begin
    PDF_UeberwachungAktiv := False;
    PDF_Ueberwachung_GroesseAlt := -1;
    PDF_Ueberwachung_StableCount := 0;
    PDF_Ueberwachung_StartTick := 0;
    Exit;
  end;

  MonPath := IncludeTrailingPathDelimiter(
    Trim(MonitoringFolder.Text));

  { --------------------------------------------------------------- }
  { Datei muss weiterhin im überwachten Verzeichnis liegen          }
  { --------------------------------------------------------------- }
  if not SameText(
    IncludeTrailingPathDelimiter(ExtractFilePath(DateiPfad)),
    MonPath) then
  begin
    FreePDF64_Form.PDF_UeberwachungsDatei := '';
    PDF_UeberwachungAktiv := False;
    PDF_Ueberwachung_GroesseAlt := -1;
    PDF_Ueberwachung_StableCount := 0;
    PDF_Ueberwachung_StartTick := 0;
    Exit;
  end;

  DateiName := ExtractFileName(DateiPfad);

  if DateiName = '' then
  begin
    FreePDF64_Form.PDF_UeberwachungsDatei := '';
    PDF_UeberwachungAktiv := False;
    Exit;
  end;

  { --------------------------------------------------------------- }
  { Maximal 120 Sekunden auf eine fertige Datei warten              }
  { --------------------------------------------------------------- }
  if GetTickCount - PDF_Ueberwachung_StartTick >= 120000 then
  begin
    FreePDF64_Form.PDF_UeberwachungsDatei := '';
    PDF_UeberwachungAktiv := False;
    PDF_Ueberwachung_GroesseAlt := -1;
    PDF_Ueberwachung_StableCount := 0;
    PDF_Ueberwachung_StartTick := 0;
    Exit;
  end;

  { --------------------------------------------------------------- }
  { Datei muss vorhanden und lesbar sein                            }
  { --------------------------------------------------------------- }
  if not FileExists(DateiPfad) then
  begin
    TimerPDFUeberwachung.Enabled := True;
    Exit;
  end;

  try
    AktuelleGroesse := TFile.GetSize(DateiPfad);
  except
    AktuelleGroesse := -1;
  end;

  if AktuelleGroesse <= 0 then
  begin
    TimerPDFUeberwachung.Enabled := True;
    Exit;
  end;

  { --------------------------------------------------------------- }
  { Dateigröße überwachen                                           }
  { --------------------------------------------------------------- }
  if AktuelleGroesse = PDF_Ueberwachung_GroesseAlt then
    Inc(PDF_Ueberwachung_StableCount)
  else
    PDF_Ueberwachung_StableCount := 0;

  PDF_Ueberwachung_GroesseAlt := AktuelleGroesse;

  { --------------------------------------------------------------- }
  { Drei aufeinanderfolgende gleiche Größen = Datei fertig          }
  { --------------------------------------------------------------- }
  if PDF_Ueberwachung_StableCount < 3 then
  begin
    TimerPDFUeberwachung.Enabled := True;
    Exit;
  end;

  { --------------------------------------------------------------- }
  { Datei ist jetzt stabil                                          }
  { --------------------------------------------------------------- }
  Überwachung_Erstellung := True;

  { --------------------------------------------------------------- }
  { Zielverzeichnis                                                  }
  { --------------------------------------------------------------- }
  if Ziel_FestCB.Checked then
    Ziel := IncludeTrailingPathDelimiter(ZielEdit.Text);

  { --------------------------------------------------------------- }
  { PDF-Erstellung                                                  }
  { --------------------------------------------------------------- }
  PDFStartOK := True;

  try
    FreePDF64_Form.PDF_Erstellung.Click;
  except
    on E: Exception do
    begin
      PDFStartOK := False;

      if Einstellungen_Form.SystemklangCB.Checked then
        FreePDF64_Form.PlaySoundFile(
          ExtractFilePath(Application.ExeName) +
          'sounds\alert.wav');
    end;
  end;

  { --------------------------------------------------------------- }
  { Bei Fehler nicht löschen und Überwachungsstatus zurücksetzen     }
  { --------------------------------------------------------------- }
  if not PDFStartOK then
  begin
    FreePDF64_Form.PDF_UeberwachungsDatei := '';
    PDF_UeberwachungAktiv := False;
    PDF_Ueberwachung_GroesseAlt := -1;
    PDF_Ueberwachung_StableCount := 0;
    PDF_Ueberwachung_StartTick := 0;
    Überwachung_Erstellung := False;
    Exit;
  end;

  { --------------------------------------------------------------- }
  { Benachrichtigung                                                }
  { --------------------------------------------------------------- }
  N := NotificationCenter1.CreateNotification;
  try
    N.Title := 'Druckerstatus';
    N.AlertBody := 'FreePDF64-Drucker: Datei wurde gedruckt!';
    N.EnableSound := True;

    if BenachrichtigungCB.Checked then
      NotificationCenter1.PresentNotification(N);
  finally
    N.Free;
  end;

  { --------------------------------------------------------------- }
  { Bisherige Wartezeit nach der Verarbeitung beibehalten           }
  { --------------------------------------------------------------- }
  t := SpinEditSec.Value * 1000;

  if t > 0 then
    Sleep(t);

  { --------------------------------------------------------------- }
  { Originaldatei löschen                                           }
  { --------------------------------------------------------------- }
  try
    if not DeleteFile(DateiPfad) then
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        FreePDF64_Form.PlaySoundFile(
          ExtractFilePath(Application.ExeName) +
          'sounds\alert.wav');
    end;
  except
    if Einstellungen_Form.SystemklangCB.Checked then
      FreePDF64_Form.PlaySoundFile(
        ExtractFilePath(Application.ExeName) +
        'sounds\alert.wav');
  end;

  { --------------------------------------------------------------- }
  { Überwachungsstatus zurücksetzen                                 }
  { --------------------------------------------------------------- }
  FreePDF64_Form.PDF_UeberwachungsDatei := '';
  PDF_UeberwachungAktiv := False;
  PDF_Ueberwachung_GroesseAlt := -1;
  PDF_Ueberwachung_StableCount := 0;
  PDF_Ueberwachung_StartTick := 0;
  Überwachung_Erstellung := False;

  { ------------------------------------------------------------- }
  { Falls mehrere Dateien gleichzeitig eingegangen sind, die      }
  { nächste vorhandene Datei direkt für den Timer vormerken.      }
  { ------------------------------------------------------------- }
  StarteNaechsteDatei;
end;

procedure TFreePDF64_Notify.CancelBitBtn1Click(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile, s: String;
begin
  try
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.Ini';
    IniDat := TIniFile.Create(IniFile);
    // Speichere beim Beenden des Programmes wichtige Daten in die 'FreePDF64.Ini'
    with IniDat do
    begin
      MonitoringFolder.Text      := ReadString('Monitoring', 'Folder', MonitoringFolder.Text);
      LMDShellNotify.Active      := ReadBool('Monitoring', 'Start', LMDShellNotify.Active);
      SpinEditSec.Value          := ReadInteger('Monitoring', 'Time', SpinEditSec.Value);
      Ziel_FestCB.Checked        := ReadBool('Monitoring', 'Fixed', Ziel_FestCB.Checked);
      BenachrichtigungCB.Checked := ReadBool('Monitoring', 'Note', BenachrichtigungCB.Checked);
      s                          := ReadString('Monitoring', 'Fixed Folder', ZielEdit.Text);
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
  ZielEdit.Text := IncludeTrailingBackslash(s);

  if LMDShellNotify.Active = True then
  begin
    Einstellungen_Form.UeberwachungBtn.Caption    := 'Überwachung ist AN';
    Einstellungen_Form.UeberwachungBtn.ImageIndex := 54;
    FreePDF64_Form.MonitorBtn.ImageIndex          := 54;
    FreePDF64_Form.MonitorBtn.Caption             := '  AN';
  end else
  begin
    Einstellungen_Form.UeberwachungBtn.Caption    := 'Überwachung ist AUS';
    Einstellungen_Form.UeberwachungBtn.ImageIndex := 55;
    FreePDF64_Form.MonitorBtn.ImageIndex          := 55;
    FreePDF64_Form.MonitorBtn.Caption             := '  AUS';
  end;
  Close;
end;

// Wenn Checked auf False gestellt wird, soll ZielEdit das aktuelle Zielverzeichnis sofort erhalten
procedure TFreePDF64_Notify.Ziel_FestCBClick(Sender: TObject);
begin
  if Ziel_FestCB.Checked = False then
    ZielEdit.Text := IncludeTrailingBackslash(Ziel);
end;

procedure TFreePDF64_Notify.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    Close;
end;

// Extract Extension OHNE Punkt!
function ExtractFileExtensionWithoutDot(const Filename: string): string;
begin
  Result := Copy(ExtractFileExt(Filename), 2);
end;

procedure TFreePDF64_Notify.FormShow(Sender: TObject);
var
  Z: String;
begin
  TimerPDFUeberwachung.Enabled := False;
  TimerPDFUeberwachung.Interval := 500;

  Z := Ziel;
  if not Ziel_FestCB.Checked then
    ZielEdit.Text := IncludeTrailingBackslash(Z);

  FreePDF64_Form.MonitorBtn.Hint := 'Schnelles AN/AUS durch rechte Maustaste';
  if LMDShellNotify.Active then
  begin
    btnStart.Enabled := False;
    btnStop.Enabled  := True;
    FreePDF64_Form.MonitorBtn.ImageIndex := 54;
  end else
  begin
    btnStart.Enabled := True;
    btnStop.Enabled  := False;
    FreePDF64_Form.MonitorBtn.ImageIndex := 55;
  end;

  MonitoringBtn.SetFocus;
end;

procedure TFreePDF64_Notify.btnStartClick(Sender: TObject);
begin
  FreePDF64_Form.PDF_UeberwachungsDatei := '';
  PDF_UeberwachungAktiv := False;
  PDF_Ueberwachung_GroesseAlt := -1;
  PDF_Ueberwachung_StableCount := 0;
  PDF_Ueberwachung_StartTick := 0;
  TimerPDFUeberwachung.Enabled := False;

  btnStart.Enabled := False;
  LMDShellNotify.WatchFolder := Trim(IncludeTrailingBackslash(MonitoringFolder.Text));
  LMDShellNotify.Active := True;
  FreePDF64_Form.MonitorBtn.ImageIndex := 54;
  FreePDF64_Form.MonitorBtn.Caption := '  AN';
  btnStop.Enabled := True;
  Einstellungen_Form.UeberwachungBtn.Caption := 'Überwachung ist AN';
  Einstellungen_Form.UeberwachungBtn.ImageIndex := 54;
end;

procedure TFreePDF64_Notify.btnStopClick(Sender: TObject);
begin
  LMDShellNotify.Active := False;
  TimerPDFUeberwachung.Enabled := False;
  FreePDF64_Form.PDF_UeberwachungsDatei := '';
  PDF_UeberwachungAktiv := False;
  PDF_Ueberwachung_GroesseAlt := -1;
  PDF_Ueberwachung_StableCount := 0;
  PDF_Ueberwachung_StartTick := 0;
  FreePDF64_Form.MonitorBtn.ImageIndex := 55;
  FreePDF64_Form.MonitorBtn.Caption := '  AUS';
  btnStart.Enabled := True;
  btnStop.Enabled := False;
  Einstellungen_Form.UeberwachungBtn.Caption := 'Überwachung ist AUS';
  Einstellungen_Form.UeberwachungBtn.ImageIndex := 55;
end;

end.

