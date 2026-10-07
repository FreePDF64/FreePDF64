//
// Programmname: FreePDF64
//

unit uPDFBrowserForm;

interface

{$I ..\..\WebView4Delphi-main\source\webview2.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Dialogs,
  IniFiles, uWVBrowser, uWVWinControl, uWVWindowParent, uWVTypes,
  uWVConstants, uWVTypeLibrary, uWVLibFunctions, uWVLoader,
  uWVInterfaces, uWVCoreWebView2Args, uWVBrowserBase, Menus;

type
  TPDFBrowserForm = class(TForm)
    TimerPDF: TTimer;
    WVWindowParentPDF: TWVWindowParent;
    WVBrowserPDF: TWVBrowser;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure TimerPDFTimer(Sender: TObject);
    procedure WVBrowserPDFAfterCreated(Sender: TObject);
    procedure WVBrowserPDFInitializationError(Sender: TObject;
      aErrorCode: HRESULT; const aErrorMessage: wvstring);

  protected
    procedure WMMove(var aMessage: TWMMove); message WM_MOVE;
    procedure WMMoving(var aMessage: TMessage); message WM_MOVING;

    function IsShortCut(var Message: TWMKey): Boolean; override;

  private
    FBrowserCreateStarted: Boolean;
    FBrowserCreated: Boolean;
    FClosing: Boolean;

    procedure StartBrowser;

  public
    PDFFileName: string;
  end;

implementation

{$R *.dfm}


procedure TPDFBrowserForm.FormCreate(Sender: TObject);
var
  IniDat: TIniFile;
begin
  Position := poDesigned;

  FBrowserCreateStarted := False;
  FBrowserCreated := False;
  FClosing := False;

  IniDat := TIniFile.Create(
    ExtractFilePath(Application.ExeName) + 'FreePDF64.ini');
  try
    Left   := IniDat.ReadInteger('Position', 'PDFBrowserForm_Left', Left);
    Top    := IniDat.ReadInteger('Position', 'PDFBrowserForm_Top', Top);
    Width  := IniDat.ReadInteger('Position', 'PDFBrowserForm_Width', Width);
    Height := IniDat.ReadInteger('Position', 'PDFBrowserForm_Height', Height);
  finally
    IniDat.Free;
  end;
end;


procedure TPDFBrowserForm.FormShow(Sender: TObject);
begin
  // Dateiname inklusive Verzeichnis in der Titelleiste anzeigen
  Caption := PDFFileName;

  // Formular wird angezeigt -> noch nicht im Schließvorgang.
  FClosing := False;

  StartBrowser;

  // PDF-Fenster aktiv nach vorne holen.
  BringToFront;
  SetForegroundWindow(Handle);
end;


procedure TPDFBrowserForm.StartBrowser;
begin
  // Formular befindet sich bereits im Schließvorgang.
  if FClosing then
    Exit;

  // Pro Formular darf CreateBrowser nur einmal gestartet werden.
  if FBrowserCreateStarted then
    Exit;

  if GlobalWebView2Loader.InitializationError then
  begin
    ShowMessage(GlobalWebView2Loader.ErrorMessage);
    Exit;
  end;

  if GlobalWebView2Loader.Initialized then
  begin
    // WICHTIG:
    // Vor CreateBrowser setzen.
    // Dadurch kann FormShow/TimerPDFTimer nicht nochmals
    // CreateBrowser für dasselbe Formular ausführen.
    FBrowserCreateStarted := True;

    WVBrowserPDF.CreateBrowser(WVWindowParentPDF.Handle);
  end
  else
  begin
    TimerPDF.Enabled := True;
  end;
end;


procedure TPDFBrowserForm.TimerPDFTimer(Sender: TObject);
begin
  TimerPDF.Enabled := False;

  // Formular wurde inzwischen geschlossen.
  if FClosing then
    Exit;

  if FBrowserCreateStarted then
    Exit;

  if GlobalWebView2Loader.InitializationError then
  begin
    ShowMessage(GlobalWebView2Loader.ErrorMessage);
    Exit;
  end;

  if GlobalWebView2Loader.Initialized then
    StartBrowser
  else
    TimerPDF.Enabled := True;
end;


procedure TPDFBrowserForm.WVBrowserPDFAfterCreated(Sender: TObject);
var
  URL: string;
begin
  // Sehr wichtig:
  // Falls CreateBrowser noch abgeschlossen wurde, nachdem
  // der Benutzer das PDF-Fenster bereits geschlossen hat,
  // darf hier nichts mehr mit dem Formular gemacht werden.
  if FClosing then
    Exit;

  FBrowserCreated := True;

  WVWindowParentPDF.UpdateSize;

  URL := 'file:///' +
    StringReplace(PDFFileName, '\', '/', [rfReplaceAll]);

  WVBrowserPDF.Navigate(URL);

  // Das PDF-Fenster soll aktiv sein.
  BringToFront;
  SetForegroundWindow(Handle);

  // Tastaturfokus auf das WebView2-Parent-Fenster.
  if WVWindowParentPDF.HandleAllocated then
    Winapi.Windows.SetFocus(WVWindowParentPDF.Handle);
end;


function TPDFBrowserForm.IsShortCut(var Message: TWMKey): Boolean;
begin
  // Solange die PDFForm aktiv ist, dürfen Shortcuts der Hauptform
  // nicht von der Anwendung verarbeitet werden.
  //
  // Die Tastatur wird anschließend von WebView2 verarbeitet.
  Result := True;
end;


procedure TPDFBrowserForm.WVBrowserPDFInitializationError(
  Sender: TObject; aErrorCode: HRESULT;
  const aErrorMessage: wvstring);
begin
  // Formular befindet sich bereits im Schließvorgang.
  if FClosing then
    Exit;

  FBrowserCreated := False;

  ShowMessage(aErrorMessage);
end;


procedure TPDFBrowserForm.FormClose(
  Sender: TObject; var Action: TCloseAction);
var
  IniDat: TIniFile;
begin
  // Ab jetzt dürfen keine weiteren Timer-/AfterCreated-Aktionen
  // mehr mit diesem Formular arbeiten.
  FClosing := True;

  TimerPDF.Enabled := False;

  IniDat := TIniFile.Create(
    ExtractFilePath(Application.ExeName) + 'FreePDF64.ini');
  try
    IniDat.WriteInteger(
      'Position',
      'PDFBrowserForm_Left',
      Left);

    IniDat.WriteInteger(
      'Position',
      'PDFBrowserForm_Top',
      Top);

    IniDat.WriteInteger(
      'Position',
      'PDFBrowserForm_Width',
      Width);

    IniDat.WriteInteger(
      'Position',
      'PDFBrowserForm_Height',
      Height);
  finally
    IniDat.Free;
  end;

  // Die Form selbst wird freigegeben.
  //
  // Dabei werden die darin enthaltenen VCL-Komponenten
  // einschließlich WVBrowserPDF und WVWindowParentPDF
  // über den normalen Delphi-Komponenten-Lebenszyklus
  // ebenfalls freigegeben.
  Action := caFree;
end;


procedure TPDFBrowserForm.WMMove(var aMessage: TWMMove);
begin
  inherited;

  if (WVBrowserPDF <> nil) and not FClosing then
    WVBrowserPDF.NotifyParentWindowPositionChanged;
end;


procedure TPDFBrowserForm.WMMoving(var aMessage: TMessage);
begin
  inherited;

  if (WVBrowserPDF <> nil) and not FClosing then
    WVBrowserPDF.NotifyParentWindowPositionChanged;
end;


initialization
  GlobalWebView2Loader := TWVLoader.Create(nil);

  GlobalWebView2Loader.UserDataFolder :=
    ExtractFileDir(Application.ExeName) + '\CustomCache';

  GlobalWebView2Loader.StartWebView2;

end.

