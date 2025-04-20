unit EineInstanz_Unit;

interface

implementation

uses Windows, Dialogs, Sysutils;

var
  mHandle: THandle;    // Mutexhandle

Initialization
  mHandle := CreateMutex(NIL, True, 'FreePDF64'); // Anwendungsname
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    Messagedlg('FreePDF64 l‰uft bereits!', mtInformation, [mbok], 0);
    Halt;
  end;

finalization   // ... und Schluﬂ
  if mHandle <> 0 then
    CloseHandle(mHandle)
end.
