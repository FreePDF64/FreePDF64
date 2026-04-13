//
// Programmname: FreePDF64
//

unit FreePDF64_Notify_Unit;

interface

uses
  Forms, StdCtrls, Buttons, Controls, Classes, ShlObj, Windows,
  LMDShNtf, LMDCustomComponent, Dialogs, LMDShBase, ShellAPI, LMDShBrwDlg,
  LMDShDlg, LMDBrowseDlg, Vcl.Samples.Spin, IniFiles, Printers, Registry,
  Vcl.ExtCtrls, LMDShLink, Graphics;

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
    SendToBtn: TSpeedButton;
    LMDShellLink1: TLMDShellLink;
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
    procedure SendToBtnClick(Sender: TObject);
  private
    { Private declarations }
    procedure Abfrage(const EventName: string; aPIDL1: PItemIDList = nil;
                                                aPIDL2: PItemIDList = nil);
  public
    { Public declarations }
  end;

var
  FreePDF64_Notify: TFreePDF64_Notify;

implementation

{$WARNINGS OFF}
uses
  SysUtils, LMDShPIDL, Einstellungen_Unit, FreePDF64_Unit, Zusatz_Unit, System.IOUtils;
{$WARNINGS ON}

{$R *.DFM}

// Abfrage und Handlung, wenn ausgewählte Datei im ausgewählten Verzeichnis erkannt wurde...
procedure TFreePDF64_Notify.Abfrage(const EventName: string; aPIDL1, aPIDL2: PItemIDList);
var
  s: String;
  i, t: Integer;
begin
  t := SpinEditSec.Value * 1000; //von ms in sec.

  // Hat ein Ereignis stattgefunden?
  if Assigned(aPIDL1) or Assigned(aPIDL2) then
  begin
    // Aktuelles Verzeichnis speichern
    s := FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName;
    // Wenn das aktive Verzeichnis nicht das Überwachungsverzeichnis ist, dann ChangeDir...
    if FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName <> IncludeTrailingBackslash(MonitoringFolder.Text) then
      FreePDF64_Form.LMDShellFolder1.ChDir(IncludeTrailingBackslash(MonitoringFolder.Text));

    if Einstellungen_Form.ZusatzAnAus.Checked = True then
    begin
      // Folgende Zeichenketten werden aus den ermittelten Dateinamen beim Drucken in eine PDF entfernt:
      try
        FreePDF64_Form.LMDShellList1.Items.Item[0].Caption :=
          StringReplace(FreePDF64_Form.LMDShellList1.Items.Item[0].Caption, Zusatz_Form.ZusatzCB.Text, '', [rfReplaceAll, rfIgnoreCase]);
      finally
        Application.ProcessMessages;
      end;
    end;

    MonitoringFile := UpperCase(FreePDF64_Form.LMDShellList1.Items.Item[0].Caption);
    // Suche nach der neuen Datei im Überwachungsverzeichnis
    for i := 0 to FreePDF64_Form.LMDShellList1.Items.Count - 1 do
      if UpperCase(FreePDF64_Form.LMDShellList1.Items.Item[i].Caption) = MonitoringFile then // und gefunden...
      begin
        // Wartezeit bis zur weiteren Verarbeitung
        Sleep(t);

        FreePDF64_Form.LMDShellList1.Selected := FreePDF64_Form.LMDShellList1.Items.Item[i];

        Überwachung_Erstellung := True;
        if Ziel_FestCB.Checked then
          Ziel := IncludeTrailingBackslash(ZielEdit.Text);
        FreePDF64_Form.PDF_Erstellung.Click;

        Sleep(t);
        // Datei nach der Erstellung in den Papierkorb löschen
        try
//          if not DeleteFile(IncludeTrailingBackslash(MonitoringFolder.Text) + FreePDF64_Form.LMDShellList1.Selected.Caption) then
          if not DeleteFile(IncludeTrailingBackslash(MonitoringFolder.Text) + FreePDF64_Form.LMDShellList1.Items.Item[i].Caption) then
            if Einstellungen_Form.SystemklangCB.Checked then
              FreePDF64_Form.PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav')
        except
//          ShowMessage(SysErrorMessage(GetLastError));
          Application.ProcessMessages;
        end;
      end;
    // Rücksprung zum aktuellen Verzeichnis
    FreePDF64_Form.LMDShellFolder1.ChDir(s);
  end;
end;

// Notify bei OnFileCreate
procedure TFreePDF64_Notify.LMDShellNotifyFileCreate(aSender: TObject;
  aPIDL: PItemIDList);
begin
//  Abfrage('OnFileCreate', aPIDL);
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

  Close;
end;

// Pfad von %APPDATA%
function GetAppDataPath: string;
begin
  Result := TPath.GetHomePath;
end;

procedure TFreePDF64_Notify.SendToBtnClick(Sender: TObject);
var
  Reg, s: String;
  F: TextFile;
  Registry: TRegistry;
begin
  FreePDF64_Form.Memo1.Clear;

  // Link zu SendTo hinzufügen
  LMDShellLink1.Path     := MonitoringFolder.Text;
  LMDShellLink1.FileName := GetAppDataPath +'\Microsoft\Windows\SendTo\FreePDF64-Quellverzeichnis.lnk';
  LMDShellLink1.Save(LMDShellLink1.FileName);

  // Definitions-Datei "mfilemon.reg" mit dem richtigen Pfad anpassen!
  s := ExcludeTrailingBackslash(ExtractFilePath(MonitoringFolder.Text));
  s := StringReplace(s, '\', '\\', [rfReplaceAll]);
  with TStringList.Create do
  try
    LoadFromFile(IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) + 'Definition files\mfilemon.reg');
    Delete(3);
    // Zum Beispiel "OutputPath"="C:\\FreePDF64\\Quellverzeichnis"
    Insert(3, '"OutputPath"="' + s + '"');
    SaveToFile(ExtractFilePath(Application.ExeName) + 'Definition files\mfilemon.reg');
  finally
    Free;
  end;
  Reg := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName) + 'Definition files');
  Reg := Reg + 'mfilemon.reg';

  Registry := TRegistry.Create(KEY_READ);
  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;
    if Registry.OpenKeyReadOnly('SYSTEM\CurrentControlSet\Control\Print\Monitors\Multi File Port Monitor\Multi File Port') then
    begin
      // Starte die Erstellung...
      if ShellExecute(Handle, NIL, PChar(Reg), NIL, NIL, SW_SHOWNORMAL) <= 32 then
      begin
        ShowMessage('Es ist ein Fehler aufgetreten!');
        Exit;
      end;
      MessageDlg('Der FreePDF64-Drucker wurde auf das neue Überwachungsverzeichnis angepasst. Dies erfordert nun einen Windows-Neustart!', mtInformation, mbOKCancel, 0);
      OkBitBtn.Click;

      if (FreePDF64_Form.Logdatei.Checked) then
      begin
        // Logdatei (FreePDF64Log.txt) öffnen/beschreiben etc.
        AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
        try
          Append(F);
        except
          Rewrite(F)
        end;
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' - Das Überwachungsverzeichnis "' + ExcludeTrailingBackslash(MonitoringFolder.Text) +
                         '" wurde dem "Senden an"-Menü hinzugefügt.'));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' - Der FreePDF64-Drucker wurde auf das neue Überwachungsverzeichnis angepasst.'));
        Closefile(F);
      end;

      LMDShellRestartDialog1.Execute;
    end else
    begin
      MessageDlg('Der FreePDF64-Drucker wurde noch nicht installiert - siehe FreePDF64-HowTo.', mtInformation, mbOKCancel, 0);
      Exit;
    end;
  finally
    Registry.Free;
  end;
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
      MonitoringFolder.Text := ReadString('Monitoring', 'Folder', MonitoringFolder.Text);
      LMDShellNotify.Active := ReadBool('Monitoring', 'Start', LMDShellNotify.Active);
      SpinEditSec.Value     := ReadInteger('Monitoring', 'Time', SpinEditSec.Value);
      Ziel_FestCB.Checked   := ReadBool('Monitoring', 'Fixed', Ziel_FestCB.Checked);
      s                     := ReadString('Monitoring', 'Fixed Folder', ZielEdit.Text);
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
    Einstellungen_Form.UeberwachungBtn.ImageIndex := 57;
    FreePDF64_Form.MonitorBtn.ImageIndex          := 57;
    FreePDF64_Form.MonitorBtn.Caption             := '  AN';
  end else
  begin
    Einstellungen_Form.UeberwachungBtn.Caption    := 'Überwachung ist AUS';
    Einstellungen_Form.UeberwachungBtn.ImageIndex := 58;
    FreePDF64_Form.MonitorBtn.ImageIndex          := 58;
    FreePDF64_Form.MonitorBtn.Caption             := '  AUS';
  end;
  Close;
end;

// Wenn Checked auf False gestellt wird, soll ZielEdit das aktuelle Zielverzeichnis sofort erhalten
procedure TFreePDF64_Notify.Ziel_FestCBClick(Sender: TObject);
begin
  if Ziel_FestCB.Checked = False then
  begin
    ZielEdit.Text := IncludeTrailingBackslash(Ziel);
  end;
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
  Z := Ziel;
  if not Ziel_FestCB.Checked then
    ZielEdit.Text := IncludeTrailingBackslash(Z);

  FreePDF64_Form.MonitorBtn.Hint := 'Schnelles AN/AUS durch rechte Maustaste';
  if LMDShellNotify.Active then
  begin
    btnStart.Enabled := False;
    btnStop.Enabled  := True;
    FreePDF64_Form.MonitorBtn.ImageIndex := 57;
  end else
  begin
    btnStart.Enabled := True;
    btnStop.Enabled  := False;
    FreePDF64_Form.MonitorBtn.ImageIndex := 58;
  end;

  SendToBtn.Hint := '1. Das Überwachungsverzeichnis wird dem "Senden an"-Menü von Windows hinzugefügt.' + #13 +
                    '2. Dem FreePDF64-Drucker wird dieses neue Überwachungsverzeichnis mitgeteilt. Dies erfordert danach einen Windows-Neustart!';
  MonitoringBtn.SetFocus;
end;

procedure TFreePDF64_Notify.btnStartClick(Sender: TObject);
begin
  btnStart.Enabled := False;
  LMDShellNotify.WatchFolder := Trim(IncludeTrailingBackslash(MonitoringFolder.Text));
  LMDShellNotify.Active := True;
  FreePDF64_Form.MonitorBtn.ImageIndex := 57;
  FreePDF64_Form.MonitorBtn.Caption := '  AN';
  btnStop.Enabled := True;
  Einstellungen_Form.UeberwachungBtn.Caption := 'Überwachung ist AN';
  Einstellungen_Form.UeberwachungBtn.ImageIndex := 57;
end;

procedure TFreePDF64_Notify.btnStopClick(Sender: TObject);
begin
  LMDShellNotify.Active := False;
  FreePDF64_Form.MonitorBtn.ImageIndex := 58;
  FreePDF64_Form.MonitorBtn.Caption := '  AUS';
  btnStart.Enabled := True;
  btnStop.Enabled := False;
  Einstellungen_Form.UeberwachungBtn.Caption := 'Überwachung ist AUS';
  Einstellungen_Form.UeberwachungBtn.ImageIndex := 58;
end;

end.
