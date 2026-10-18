unit uPDFAttachmentTemp;

interface

procedure RegisterPDFAttachmentTemp(const AFileName: string);
procedure ReleasePDFAttachmentTemp(const AFileName: string);

implementation

uses SysUtils, Classes;

var
  TempFiles: TStringList;

procedure RegisterPDFAttachmentTemp(const AFileName: string);
begin
  if (AFileName <> '') and (TempFiles.IndexOf(AFileName) < 0) then
    TempFiles.Add(AFileName);
end;

procedure ReleasePDFAttachmentTemp(const AFileName: string);
var
  I: Integer;
begin
  I := TempFiles.IndexOf(AFileName);
  if I < 0 then Exit;
  // Nur Dateien loeschen, die dieser Prozess selbst extrahiert hat.
  if not FileExists(AFileName) or SysUtils.DeleteFile(AFileName) then
    TempFiles.Delete(I);
end;

var
  I: Integer;
initialization
  TempFiles := TStringList.Create;
  TempFiles.CaseSensitive := False;
finalization
  // Andere Anwendungen koennen Anlagen noch geoeffnet halten.
  // In diesem Fall schlaegt DeleteFile fehl, ohne sie zu beschaedigen.
  for I := TempFiles.Count - 1 downto 0 do
    SysUtils.DeleteFile(TempFiles[I]);
  TempFiles.Free;
end.
