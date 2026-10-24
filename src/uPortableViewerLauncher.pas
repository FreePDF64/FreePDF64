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

type
  PViewerWindowSearch = ^TViewerWindowSearch;
  TViewerWindowSearch = record
    PID: DWORD;
    Wnd: HWND;
  end;

function FindViewerWindow(Wnd: HWND; Param: LPARAM): BOOL; stdcall;
var
  PID: DWORD;
  Search: PViewerWindowSearch;
begin
  Result := True;
  Search := PViewerWindowSearch(Param);
  PID := 0;
  GetWindowThreadProcessId(Wnd, @PID);
  if (PID = Search^.PID) and IsWindowVisible(Wnd) and
     (GetWindow(Wnd, GW_OWNER) = 0) then
  begin
    Search^.Wnd := Wnd;
    Result := False;
  end;
end;

procedure ActivateNewViewer(const APID: DWORD; const AProcess: THandle);
var
  Search: TViewerWindowSearch;
  I: Integer;
  ExitCode: DWORD;
begin
  Search.PID := APID;
  Search.Wnd := 0;
  // Das Fenster frueh aktivieren, sobald es sichtbar ist. Nicht auf
  // WaitForInputIdle warten, da der Viewer dabei bereits die PDF laden kann.
  // Ein kurzlebiger Zweitprozess leitet die Datei an die laufende Instanz
  // weiter und beendet sich; in diesem Fall nicht unnoetig weiter warten.
  for I := 1 to 35 do
  begin
    EnumWindows(@FindViewerWindow, LPARAM(@Search));
    if Search.Wnd <> 0 then Break;
    if not GetExitCodeProcess(AProcess, ExitCode) or (ExitCode <> STILL_ACTIVE) then
      Exit;
    Sleep(50);
  end;
  if Search.Wnd = 0 then Exit;
  AllowSetForegroundWindow(APID);
  if IsIconic(Search.Wnd) then ShowWindow(Search.Wnd, SW_RESTORE);
  SetWindowPos(Search.Wnd, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
  SetWindowPos(Search.Wnd, HWND_NOTOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
  SetForegroundWindow(Search.Wnd);
end;

procedure LaunchPortable(const AArgument: string);
var
  Exe, Params: string;
  ExecInfo: TShellExecuteInfo;
begin
  Exe := PortableViewerExe;
  if not FileExists(Exe) then
  begin
    MessageDlg('Der portable PDF-Viewer fehlt:' + sLineBreak + Exe +
      sLineBreak + 'Bitte FreePDF64ViewerPortable.exe in das FreePDF64-Programmverzeichnis kopieren.',
      mtError, [mbOK], 0);
    Exit;
  end;
  Params := AArgument;
  if (Params <> '') and (Params[1] <> '"') then Params := '"' + Params + '"';
  // Den gestarteten Viewer zur Vordergrundaktivierung berechtigen.
  // Bei einer bereits laufenden Instanz leitet der neue Prozess die
  // PDF-Datei weiter; diese Instanz aktiviert ihr Fenster selbst.
  ZeroMemory(@ExecInfo, SizeOf(ExecInfo));
  ExecInfo.cbSize := SizeOf(ExecInfo);
  ExecInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  ExecInfo.Wnd := 0;
  ExecInfo.lpVerb := 'open';
  ExecInfo.lpFile := PChar(Exe);
  ExecInfo.lpParameters := PChar(Params);
  ExecInfo.lpDirectory := PChar(ExtractFilePath(Exe));
  ExecInfo.nShow := SW_SHOWNORMAL;
  if ShellExecuteEx(@ExecInfo) then
  begin
    if ExecInfo.hProcess <> 0 then
    begin
      AllowSetForegroundWindow(GetProcessId(ExecInfo.hProcess));
      // Ohne blockierendes WaitForInputIdle sofort nach dem sichtbaren
      // Hauptfenster suchen. Die PDF kann dadurch parallel geladen werden.
      ActivateNewViewer(GetProcessId(ExecInfo.hProcess), ExecInfo.hProcess);
      CloseHandle(ExecInfo.hProcess);
    end;
  end
  else
    MessageDlg('Der portable PDF-Viewer konnte nicht gestartet werden: ' + Exe,
      mtError, [mbOK], 0);
end;

procedure OpenPDFPortable(const AFileName: string);
begin
  if SameText(ExtractFileExt(AFileName), '.pdf') and FileExists(AFileName) then
    LaunchPortable(ExpandFileName(AFileName));
end;

procedure OpenPDFsPortable(const AFiles: TStrings);
var
  I: Integer;
  FileName, Params: string;
begin
  if AFiles = nil then Exit;
  Params := '';
  for I := 0 to AFiles.Count - 1 do
  begin
    FileName := ExpandFileName(AFiles[I]);
    if SameText(ExtractFileExt(FileName), '.pdf') and FileExists(FileName) then
    begin
      if Params <> '' then Params := Params + ' ';
      Params := Params + '"' + FileName + '"';
    end;
  end;
  if Params <> '' then LaunchPortable(Params);
end;

procedure OpenPortableViewer;
begin
  LaunchPortable('');
end;

end.
