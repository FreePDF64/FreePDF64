//
// Programmname: FreePDF64
//

unit uPDFBrowserForm;

interface

{$I ..\..\WebView4Delphi-main\source\webview2.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Dialogs, IniFiles,
  uWVBrowser, uWVWinControl, uWVWindowParent, uWVTypes, uWVConstants, uWVTypeLibrary,
  uWVLibFunctions, uWVLoader, uWVInterfaces, uWVCoreWebView2Args,
  uWVBrowserBase, Menus;

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

  private
    FBrowserCreateStarted: Boolean;
    FBrowserCreated: Boolean;

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
  // WICHTIG:
  // Hier NICHT Visible verändern.
  // Das verursacht in Delphi den Fehler:
  // "Eigenschaft Visible kann in OnShow oder OnHide nicht verändert werden."

  StartBrowser;
end;


procedure TPDFBrowserForm.StartBrowser;
begin
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
    // VOR CreateBrowser setzen.
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
  FBrowserCreated := True;

  WVWindowParentPDF.UpdateSize;

  // KEIN SetFocus hier.
  //
  // Bei mehreren gleichzeitig geöffneten PDF-Formularen wird dadurch
  // verhindert, dass jedes neu erstellte WebView2-Fenster sofort den
  // Eingabefokus an sich zieht.

  URL := 'file:///' +
    StringReplace(PDFFileName, '\', '/', [rfReplaceAll]);

  WVBrowserPDF.Navigate(URL);
end;


procedure TPDFBrowserForm.WVBrowserPDFInitializationError(Sender: TObject;
  aErrorCode: HRESULT; const aErrorMessage: wvstring);
begin
  // CreateBrowser wurde zwar gestartet, aber WebView2 konnte nicht
  // initialisiert werden. Ein erneuter automatischer CreateBrowser-
  // Versuch wird hier bewusst nicht ausgelöst.
  FBrowserCreated := False;

  ShowMessage(aErrorMessage);
end;


procedure TPDFBrowserForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  IniDat: TIniFile;
begin
  TimerPDF.Enabled := False;

  IniDat := TIniFile.Create(
    ExtractFilePath(Application.ExeName) + 'FreePDF64.ini');
  try
    IniDat.WriteInteger('Position', 'PDFBrowserForm_Left', Left);
    IniDat.WriteInteger('Position', 'PDFBrowserForm_Top', Top);
    IniDat.WriteInteger('Position', 'PDFBrowserForm_Width', Width);
    IniDat.WriteInteger('Position', 'PDFBrowserForm_Height', Height);
  finally
    IniDat.Free;
  end;

  Action := caFree;
end;


procedure TPDFBrowserForm.WMMove(var aMessage: TWMMove);
begin
  inherited;

  if WVBrowserPDF <> nil then
    WVBrowserPDF.NotifyParentWindowPositionChanged;
end;


procedure TPDFBrowserForm.WMMoving(var aMessage: TMessage);
begin
  inherited;

  if WVBrowserPDF <> nil then
    WVBrowserPDF.NotifyParentWindowPositionChanged;
end;


initialization
  GlobalWebView2Loader := TWVLoader.Create(nil);
  GlobalWebView2Loader.UserDataFolder :=
    ExtractFileDir(Application.ExeName) + '\CustomCache';
  GlobalWebView2Loader.StartWebView2;

end.

