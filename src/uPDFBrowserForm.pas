//
// Programmname: FreePDF64
//

unit uPDFBrowserForm;

interface

{$I ..\..\WebView4Delphi-main\source\webview2.inc}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Clipbrd, Math,
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
    FToolbar: TPanel;
    FPageLabel: TLabel;
    FPageEdit: TEdit;
    FGoPageButton: TButton;
    FFindButton: TButton;
    FPageNavigationTimer: TTimer;
    FSearchTerm: string;
    FStartPage: Integer;

    procedure StartBrowser;
    procedure BuildNavigationToolbar;
    procedure GoToPageClick(Sender: TObject);
    procedure FindTermClick(Sender: TObject);
    procedure PageNavigationTimerTimer(Sender: TObject);
    function BuildPdfUrl(const APage: Integer): string;

  public
    PDFFileName: string;
    property SearchTerm: string read FSearchTerm write FSearchTerm;
    property StartPage: Integer read FStartPage write FStartPage;
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
  FStartPage := 1;
  FSearchTerm := '';
  BuildNavigationToolbar;

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


procedure TPDFBrowserForm.BuildNavigationToolbar;
begin
  // Die vorhandene PDF-Ansicht bleibt in einem eigenen Fenster.
  // Diese kleine Leiste ergänzt nur Seitensteuerung und die PDF-Suche.
  FToolbar := TPanel.Create(Self);
  FToolbar.Name := 'PDFNavigationToolbar';
  FToolbar.Caption := 'PDF-Anzeiger';
  FToolbar.Parent := Self;
  FToolbar.Align := alTop;
  FToolbar.Height := 38;
  FToolbar.BevelOuter := bvNone;

  FPageLabel := TLabel.Create(Self);
  FPageLabel.Parent := FToolbar;
  FPageLabel.Caption := 'Seite:';
  FPageLabel.Left := 8;
  FPageLabel.Top := 12;

  FPageEdit := TEdit.Create(Self);
  FPageEdit.Parent := FToolbar;
  FPageEdit.Name := 'PDFPageNumberEdit';
  FPageEdit.Left := 48;
  FPageEdit.Top := 6;
  FPageEdit.Width := 58;
  FPageEdit.Text := '1';
  FPageEdit.NumbersOnly := True;

  FGoPageButton := TButton.Create(Self);
  FGoPageButton.Parent := FToolbar;
  FGoPageButton.Caption := 'Gehe zu Seite';
  FGoPageButton.Left := 112;
  FGoPageButton.Top := 5;
  FGoPageButton.Width := 105;
  FGoPageButton.Height := 27;
  FGoPageButton.OnClick := GoToPageClick;

  FFindButton := TButton.Create(Self);
  FFindButton.Parent := FToolbar;
  FFindButton.Caption := 'Suchbegriff suchen';
  FFindButton.Left := 225;
  FFindButton.Top := 5;
  FFindButton.Width := 135;
  FFindButton.Height := 27;
  FFindButton.OnClick := FindTermClick;

  FPageNavigationTimer := TTimer.Create(Self);
  FPageNavigationTimer.Enabled := False;
  FPageNavigationTimer.Interval := 180;
  FPageNavigationTimer.OnTimer := PageNavigationTimerTimer;

  // Sicherstellen, dass die vorhandene WebView den restlichen Platz nutzt.
  WVWindowParentPDF.Align := alClient;
  WVWindowParentPDF.SendToBack;
end;


function TPDFBrowserForm.BuildPdfUrl(const APage: Integer): string;
var
  LPath: string;
begin
  LPath := StringReplace(ExpandFileName(PDFFileName), '\', '/', [rfReplaceAll]);
  // URL-Kodierung der Leerzeichen verhindert fehlerhafte file-URLs.
  LPath := StringReplace(LPath, ' ', '%20', [rfReplaceAll]);
  Result := 'file:///' + LPath + '#page=' + IntToStr(Max(1, APage));
end;


procedure TPDFBrowserForm.GoToPageClick(Sender: TObject);
var
  LPage: Integer;
begin
  if not TryStrToInt(Trim(FPageEdit.Text), LPage) or (LPage < 1) then
  begin
    MessageDlg('Bitte eine gültige Seitenzahl ab 1 eingeben.', mtInformation, [mbOK], 0);
    FPageEdit.SetFocus;
    Exit;
  end;

  FStartPage := LPage;
  if FBrowserCreated and not FClosing then
  begin
    // Ein Zwischenaufruf verhindert, dass WebView2 eine reine Fragment-
    // Änderung bei derselben PDF-Datei ignoriert.
    FPageNavigationTimer.Enabled := False;
    WVBrowserPDF.Navigate('about:blank');
    FPageNavigationTimer.Enabled := True;
  end;
end;


procedure TPDFBrowserForm.PageNavigationTimerTimer(Sender: TObject);
begin
  FPageNavigationTimer.Enabled := False;
  if FBrowserCreated and not FClosing then
    WVBrowserPDF.Navigate(BuildPdfUrl(FStartPage));
end;


procedure TPDFBrowserForm.FindTermClick(Sender: TObject);
begin
  if Trim(FSearchTerm) = '' then
  begin
    MessageDlg('In der Suchmaske [Text suchen] ist kein Suchbegriff eingetragen.', mtInformation, [mbOK], 0);
    Exit;
  end;

  // Der Edge-PDF-Viewer besitzt eine eigene Suche (Strg+F).
  // WebView2 bietet keine stabile öffentliche API, um interne PDF-Treffer
  // direkt zu markieren. Deshalb wird die integrierte Suchoberfläche geöffnet.
  Clipboard.AsText := FSearchTerm;

  // Den Fokus möglichst direkt an die WebView geben, nicht nur an
  // deren Parent-Window. Die Suche selbst wird vom Edge-PDF-Viewer
  // über Strg+F bereitgestellt.
  BringToFront;
  SetForegroundWindow(Handle);
  if WVWindowParentPDF.HandleAllocated then
    Winapi.Windows.SetFocus(WVWindowParentPDF.Handle)
  else
    WVBrowserPDF.SetFocus;

  // Erst die Edge-Suchleiste öffnen. Die verzögerte Eingabe verhindert,
  // dass Strg+V gesendet wird, bevor die Suchleiste bereit ist.
  keybd_event(VK_CONTROL, 0, 0, 0);
  keybd_event(Ord('F'), 0, 0, 0);
  keybd_event(Ord('F'), 0, KEYEVENTF_KEYUP, 0);
  keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);

  Sleep(250);

  keybd_event(VK_CONTROL, 0, 0, 0);
  keybd_event(Ord('V'), 0, 0, 0);
  keybd_event(Ord('V'), 0, KEYEVENTF_KEYUP, 0);
  keybd_event(VK_CONTROL, 0, KEYEVENTF_KEYUP, 0);
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
begin
  // Sehr wichtig:
  // Falls CreateBrowser noch abgeschlossen wurde, nachdem
  // der Benutzer das PDF-Fenster bereits geschlossen hat,
  // darf hier nichts mehr mit dem Formular gemacht werden.
  if FClosing then
    Exit;

  FBrowserCreated := True;

  WVWindowParentPDF.UpdateSize;

  if FStartPage < 1 then
    FStartPage := 1;
  FPageEdit.Text := IntToStr(FStartPage);
  WVBrowserPDF.Navigate(BuildPdfUrl(FStartPage));

  // Das PDF-Fenster soll aktiv sein.
  BringToFront;
  SetForegroundWindow(Handle);

  // Tastaturfokus auf das WebView2-Parent-Fenster.
  if WVWindowParentPDF.HandleAllocated then
    Winapi.Windows.SetFocus(WVWindowParentPDF.Handle);
end;


function TPDFBrowserForm.IsShortCut(var Message: TWMKey): Boolean;
begin
  // Keine Tastenkombinationen pauschal verschlucken.
  // Insbesondere muss Strg+F an den Edge-PDF-Viewer gelangen können.
  Result := inherited IsShortCut(Message);
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
  if Assigned(FPageNavigationTimer) then
    FPageNavigationTimer.Enabled := False;

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

