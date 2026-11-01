unit uPortableViewerLauncher;

interface

uses System.Classes;

procedure OpenPDFPortable(const AFileName: string);
procedure OpenPDFsPortable(const AFiles: TStrings);
procedure OpenPortableViewer;
function PortableViewerExe: string;

implementation

uses Winapi.Windows, Winapi.ShellAPI, System.SysUtils, Vcl.Dialogs;

function PortableViewerExe: string;
begin
  Result := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) +
    'FreePDF64ViewerPortable.exe';
end;

// PDFs exakt wie beim Explorer per Dateizuordnung oeffnen.
// Keine direkte EXE-Startlogik, keine Fensteraktivierung, kein TOPMOST.
procedure OpenPDFPortable(const AFileName: string);
var
  PDF: string;
  ExecInfo: TShellExecuteInfo;
begin
  PDF := ExpandFileName(AFileName);
  if not SameText(ExtractFileExt(PDF), '.pdf') or not FileExists(PDF) then
    Exit;

  ZeroMemory(@ExecInfo, SizeOf(ExecInfo));
  ExecInfo.cbSize := SizeOf(ExecInfo);
  ExecInfo.Wnd := 0;
  ExecInfo.lpVerb := 'open';
  ExecInfo.lpFile := PChar(PDF); // Dateizuordnung, wie Explorer-Doppelklick
  ExecInfo.lpParameters := nil;
  ExecInfo.lpDirectory := PChar(ExtractFilePath(PDF));
  ExecInfo.nShow := SW_SHOWNORMAL;
  if not ShellExecuteEx(@ExecInfo) then
    MessageDlg('Die PDF-Datei konnte ueber die Windows-Dateizuordnung nicht geoeffnet werden:' +
      sLineBreak + PDF + sLineBreak + SysErrorMessage(GetLastError),
      mtError, [mbOK], 0);
end;

procedure OpenPDFsPortable(const AFiles: TStrings);
var
  I: Integer;
begin
  if AFiles = nil then Exit;
  // Wie bei mehreren Explorer-Dateien: jede Datei einzeln per 'open'.
  // Die Einzelinstanz-Logik des Viewers sammelt weitere PDFs selbst ein.
  for I := 0 to AFiles.Count - 1 do
    OpenPDFPortable(AFiles[I]);
end;

procedure LaunchPortable(const AArgument: string);
var
  Exe: string;
  ExecInfo: TShellExecuteInfo;
begin
  Exe := PortableViewerExe;
  if not FileExists(Exe) then
  begin
    MessageDlg('Der portable PDF-Viewer fehlt:' + sLineBreak + Exe,
      mtError, [mbOK], 0);
    Exit;
  end;
  ZeroMemory(@ExecInfo, SizeOf(ExecInfo));
  ExecInfo.cbSize := SizeOf(ExecInfo);
  ExecInfo.lpVerb := 'open';
  ExecInfo.lpFile := PChar(Exe);
  ExecInfo.lpParameters := PChar(AArgument);
  ExecInfo.lpDirectory := PChar(ExtractFilePath(Exe));
  ExecInfo.nShow := SW_SHOWNORMAL;
  if not ShellExecuteEx(@ExecInfo) then
    MessageDlg('Der portable PDF-Viewer konnte nicht gestartet werden: ' + Exe,
      mtError, [mbOK], 0);
end;

procedure OpenPortableViewer;
begin
  LaunchPortable('');
end;

end.
