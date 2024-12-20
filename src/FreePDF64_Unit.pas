//
// Programmname: FreePDF64
//
// Zweck dieses Programms:
// Erstellung von PDF/PS/JPEG/TIFF/TXT-Dateien aus u.a. Postscript-Dateien.
// Goodie: Die zu erzeugenden Dateien werden in das Eingabeverzeichnis
// gedruckt (�ber Mfilemon) oder kopiert und sind nach Erstellung als
// PDF-Datei(en) oder im anderen gew�nschten Format im Zielverzeichnis!
//
// Was braucht man au�er 'FreePDF64' noch:
// - GhostScript
// - ImageMagick
// - QPDF
// - PDFtk
// - XpdfReader und die Xpdf-Tools
// - Ein postscriptf�higen Farbdruckertreiber (mit Mfilemon)
//
// Angefangen im:    Dezember 2021
// Programmiert mit: Embarcadero Delphi 12.1 Community Edition
//
// Hinweis: Wenn ein Formular erzeugt wird und seine Eigenschaft
// Visible auf True gesetzt ist, werden die folgenden
// Ereignisse in der angegebenen Reihenfolge ausgel�st:
// 1. OnCreate
// 2. OnShow        -> Form erscheint
// 3. OnPaint
// 4. OnActivate
// 5. OnResize
// 6. ARBEITEN MIT DEM PROGRAMM
// 7. PROGRAMM BEENDEN
// 8. OnCloseQuery
// 9. OnClose
// 10. OnHide        -> Form verschwindet
// 11. OnDestroy
//

unit FreePDF64_Unit;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Types,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Samples.Gauges,
  Vcl.ComCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls,
  LMDControl,
  LMDShList,
  LMDShMisc,
  IniFiles,
  LMDCustomComponent,
  LMDShBase,
  LMDShController,
  LMDShFolder,
  Vcl.ToolWin,
  LMDShTree,
  LMDShActions,
  System.Actions,
  Vcl.ActnList,
  System.ImageList,
  Vcl.ImgList,
  LMDShConsoleView,
  LMDShDlg,
  LMDShCombo,
  LMDShDriveListBox,
  Vcl.Menus, LMDShListDlg,
  LMDShConsts,
  ShellAPI,
  FileCtrl,
  System.UITypes,
  TlHelp32,
  Printers,
  Registry,
  WinSpool,
  ShlObj,
  LMDUnicodeDialogs,
  ActiveX,
  ComObj, MMSystem, JPEG, GDIPAPI, GDIPOBJ,
  Vcl.VirtualImageList, Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.AppEvnts, System.Win.TaskbarCore, Vcl.Taskbar;

const
  WM_TASKBAREVENT = WM_USER + 1; // Taskbar message
  OneKB = 1024;
  OneMB = OneKB * OneKB;
  OneGB = OneKB * OneMB;
  OneTB = Int64(OneKB) * OneGB;
type
  TExecuteWaitEvent = procedure(const ProcessInfo: TProcessInformation;
    var ATerminate: Boolean) of object;

type
  TByteStringFormat = (bsfDefault, bsfBytes, bsfKB, bsfMB, bsfGB, bsfTB);

type
  TAutorunKind = (akUserRun, akRun);

type
  TClickSplitter = class(TSplitter)
end;

  TFreePDF64_Form = class(TForm)
    TopPanel: TPanel;
    PanelBottom: TPanel;
    Btn_View: TSpeedButton;
    Btn_NewFolder: TSpeedButton;
    Btn_Move: TSpeedButton;
    Btn_Delete: TSpeedButton;
    PDFPanel: TPanel;
    StatusBar1: TStatusBar;
    Memo1: TMemo;
    BottomPanel: TPanel;
    ToolBar1: TToolBar;
    Splitter1: TSplitter;
    BackBtn: TToolButton;
    FwdBtn: TToolButton;
    ActionList1: TActionList;
    LMDShellFolderBackward1: TLMDShellFolderBackward;
    LMDShellFolderCreateFolder1: TLMDShellFolderCreateFolder;
    LMDShellFolderForward1: TLMDShellFolderForward;
    LMDShellFolderUpLevel1: TLMDShellFolderUpLevel;
    LMDShellListCopy1: TLMDShellEditCopy;
    LMDShellListCopyFileNameAsText1: TLMDShellEditCopyFileNameAsText;
    LMDShellListCopyPathNameAsText1: TLMDShellEditCopyPathNameAsText;
    LMDShellListCut1: TLMDShellEditCut;
    LMDShellListDelete1: TLMDShellEditDelete;
    LMDShellListInvertSelection1: TLMDShellEditInvertSelection;
    LMDShellListPaste1: TLMDShellEditPaste;
    LMDShellListReName1: TLMDShellEditRename;
    LMDShellListSelectAll1: TLMDShellEditSelectAll;
    LMDShellListShowProperties1: TLMDShellEditShowProperties;
    LMDShellOpenDosWindow1: TLMDShellOpenDosWindow;
    LMDShellMapDrive1: TLMDShellMapDrive;
    LMDShellUnMapDrive1: TLMDShellUnMapDrive;
    LMDShellEditOpen1: TLMDShellEditOpen;
    LMDShellEditOpen2: TLMDShellEditOpen;
    LMDShellDiskCopy1: TLMDShellDiskCopy;
    LMDShellDiskFormat1: TLMDShellDiskFormat;
    LMDShellDiskLabelEdit1: TLMDShellDiskLabelEdit;
    LMDShellFindComputer1: TLMDShellFindComputer;
    LMDShellFindFiles1: TLMDShellFindFiles;
    LMDShellRun1: TLMDShellRun;
    LMDShellMailTo1: TLMDShellMailTo;
    LMDShellEditCopyFiles1: TLMDShellEditCopyFiles;
    LMDShellEditMoveFiles1: TLMDShellEditMoveFiles;
    MainMenu1: TMainMenu;
    Dateien1: TMenuItem;
    Speichern1: TMenuItem;
    Exit1: TMenuItem;
    LMDShellFolder1: TLMDShellFolder;
    Hilfe1: TMenuItem;
    ber1: TMenuItem;
    PDFPRNPSanzeigen1: TMenuItem;
    Editor1: TMenuItem;
    NeuerOrdner1: TMenuItem;
    Loeschen1: TMenuItem;
    Optionen1: TMenuItem;
    Allemarkieren1: TMenuItem;
    Aktualisieren1: TMenuItem;
    Ansicht1: TMenuItem;
    N2: TMenuItem;
    Filter1: TMenuItem;
    ShowFolders1: TMenuItem;
    Btn_Rename: TSpeedButton;
    Umbenennen1: TMenuItem;
    Gitternetzlinien1: TMenuItem;
    N4: TMenuItem;
    Bewegen1: TMenuItem;
    Btn_Copy: TSpeedButton;
    VersteckteDateienanzeigen1: TMenuItem;
    Einstellungen1: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Editoraufrufen1: TMenuItem;
    Logdatei: TMenuItem;
    Logdateiansehen1: TMenuItem;
    N8: TMenuItem;
    PropertiesBtn: TToolButton;
    FilterTB: TToolButton;
    FavPopUp: TPopupMenu;
    MarkEntf: TMenuItem;
    Allelschen1: TMenuItem;
    Anleitung1: TMenuItem;
    Start1: TMenuItem;
    Anderes1: TMenuItem;
    Systemsteuerungaufrufen1: TMenuItem;
    LMDShellAppletLoader1: TLMDShellAppletLoader;
    PrinterSetupDialog1: TPrinterSetupDialog;
    ConfigBtn: TButton;
    Netzwerk1: TMenuItem;
    N7: TMenuItem;
    PfadimExplorerffnen1: TMenuItem;
    Splitter2: TSplitter;
    LMDShellFolder2: TLMDShellFolder;
    PanelL: TPanel;
    LMDShellList1: TLMDShellList;
    PanelR: TPanel;
    Zielverzeichnisanzeigen1: TMenuItem;
    Splitter3: TSplitter;
    Merge: TMenuItem;
    N1: TMenuItem;
    Drucker1: TMenuItem;
    Papierkorb1: TMenuItem;
    NLtrennen: TMenuItem;
    NLverbinden: TMenuItem;
    PopupMenu3: TPopupMenu;
    Wiederherstellen2: TMenuItem;
    N12: TMenuItem;
    Einstellungenndern2: TMenuItem;
    Beenden2: TMenuItem;
    FreePDFHowTo1: TMenuItem;
    HilfezudenEinstellungen1: TMenuItem;
    VerbindenBt: TToolButton;
    Quelllabel: TPanel;
    FavSpL: TSpeedButton;
    FavLinks: TSpeedButton;
    BtnEditor: TSpeedButton;
    Kopieren1: TMenuItem;
    ParentFolderL: TSpeedButton;
    Favoritenspeichern1: TMenuItem;
    Panel_Left: TPanel;
    LMDShellTree1: TLMDShellTree;
    ListBoxL: TListBox;
    Panel2: TPanel;
    FavLbL: TListBox;
    DoppelK: TMenuItem;
    AngleichenTB: TToolButton;
    TauschenTB: TToolButton;
    ComboBoxL: TComboBox;
    Logdateilschen1: TMenuItem;
    History1: TMenuItem;
    N3: TMenuItem;
    N9: TMenuItem;
    Positionspeichern1: TMenuItem;
    Formatverz: TMenuItem;
    LogBt: TToolButton;
    Action1: TAction;
    PDF_Erstellung: TButton;
    FormatBtn: TSpeedButton;
    N10: TMenuItem;
    Autostart: TMenuItem;
    Linker_FolderBtn: TToolButton;
    Panel_Right: TPanel;
    Panel3: TPanel;
    LMDShellTree2: TLMDShellTree;
    Splitter4: TSplitter;
    PanelLMDShellList2: TPanel;
    LMDShellList2: TLMDShellList;
    ListBoxR: TListBox;
    FavLbR: TListBox;
    Ziellabel: TPanel;
    FavSpR: TSpeedButton;
    FavRechts: TSpeedButton;
    ParentFolderR: TSpeedButton;
    ComboBoxR: TComboBox;
    RefreshBt: TToolButton;
    ProgressBar1: TProgressBar;
    StatusBar_Left: TStatusBar;
    StatusBar_Right: TStatusBar;
    AutoSpalte: TMenuItem;
    N11: TMenuItem;
    WZSTTB: TToolButton;
    Wasserzeichen1: TMenuItem;
    CopyTo: TMenuItem;
    MoveTo: TMenuItem;
    N14: TMenuItem;
    Logdateiansehen2: TMenuItem;
    Verbinden1: TMenuItem;
    TaskManager1: TMenuItem;
    AbbrechenPn: TPanel;
    ExtractBtn: TToolButton;
    Sendenan1: TMenuItem;
    MailBtn: TToolButton;
    ShowFolders_Left: TMenuItem;
    Beide_FolderBtn: TToolButton;
    QuellBtn: TSpeedButton;
    ZielBtn: TSpeedButton;
    ImageCollection1: TImageCollection;
    VirtualImageList1: TVirtualImageList;
    ZielverzeichnisimExplorerffnen1: TMenuItem;
    N15: TMenuItem;
    Timer1: TTimer;
    Formatverz_Date: TMenuItem;
    InsUnterverzeichnisbeimErstellen1: TMenuItem;
    Splash1: TMenuItem;
    TrayIcon1: TTrayIcon;
    Timer2: TTimer;
    InDenTray: TMenuItem;
    berFreePDF641: TMenuItem;
    N13: TMenuItem;
    N16: TMenuItem;
    KlickaufX: TMenuItem;
    ToolButton1: TToolButton;
    Feedback: TToolButton;
    Status1: TMenuItem;
    PDFdecrypt: TToolButton;
    LMDOpenDialog1: TLMDOpenDialog;
    N17: TMenuItem;
    Installation1: TMenuItem;
    MonitorBtn: TBitBtn;
    StatusBitBtn: TBitBtn;
    HTMLBtn: TToolButton;
    ExtrahiereBilder1: TMenuItem;
    KonvertierezuHTML1: TMenuItem;
    Passwortschutzentfernen1: TMenuItem;
    PDFInfoBtn: TToolButton;
    PDFInfoanzeigen1: TMenuItem;
    PDFAttachment: TToolButton;
    PDFAnlagenanzeigenextrahieren1: TMenuItem;
    AnlagenBtn: TToolButton;
    AnlageeinerPDFDateihinzufgen1: TMenuItem;
    LMDOpenDialog2: TLMDOpenDialog;
    Kommandozeilenfensterffnen1: TMenuItem;
    ToolButton2: TToolButton;
    PDFRemove: TToolButton;
    Anlageentfernen1: TMenuItem;
    PDFFontsBtn: TToolButton;
    N18: TMenuItem;
    est1: TMenuItem;
    N19: TMenuItem;
    N31: TMenuItem;
    Image1: TImage;
    Image2: TImage;
    SearchBtn: TToolButton;
    Suche2: TMenuItem;
    Suche3: TMenuItem;
    SuchemitAltF71: TMenuItem;
    SuchennachSucheninHistorylschen1: TMenuItem;
    ImageList1: TImageList;
    Formatverz_OnlyDate: TMenuItem;
    ResizeEqual: TMenuItem;
    Nullstellung: TMenuItem;
    procedure BackBtnClick(Sender: TObject);
    procedure FwdBtnClick(Sender: TObject);
    procedure Speichern1Click(Sender: TObject);
    procedure ber1Click(Sender: TObject);
    procedure Aktualisieren1Click(Sender: TObject);
    procedure ShowFolders1Click(Sender: TObject);
    procedure Gitternetzlinien1Click(Sender: TObject);
    procedure VersteckteDateienanzeigen1Click(Sender: TObject);
    procedure Einstellungen1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PDF_ErstellungClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Editor1Click(Sender: TObject);
    procedure Seitenextrahieren1Click(Sender: TObject);
    procedure FreePDF64inibearbeiten1Click(Sender: TObject);
    procedure Editoraufrufen1Click(Sender: TObject);
    procedure LogdateiClick(Sender: TObject);
    procedure Logdateiansehen1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FilterTBClick(Sender: TObject);
    procedure EditorClick(Sender: TObject);
    procedure FavSpLClick(Sender: TObject);
    procedure FavLinksClick(Sender: TObject);
    procedure MarkEntfClick(Sender: TObject);
    procedure Allelschen1Click(Sender: TObject);
    procedure Anleitung1Click(Sender: TObject);
    procedure LMDShellTree1Change(Sender: TObject; Node: TTreeNode);
    procedure BtnEditorClick(Sender: TObject);
    procedure FormatBtnClick(Sender: TObject);
    procedure Favoritenspeichern1Click(Sender: TObject);
    procedure Systemsteuerungaufrufen1Click(Sender: TObject);
    procedure ConfigBtnClick(Sender: TObject);
    procedure Netzwerk1Click(Sender: TObject);
    procedure PfadimExplorerffnen1Click(Sender: TObject);
    procedure Zielverzeichnisanzeigen1Click(Sender: TObject);
    procedure MergeClick(Sender: TObject);
    procedure LMDShellFolder1Change(Sender: TObject);
    procedure MonitoringBtnClick(Sender: TObject);
    procedure Drucker1Click(Sender: TObject);
    procedure Papierkorb1Click(Sender: TObject);
    procedure Info2Click(Sender: TObject);
    procedure FreePDFHowTo1Click(Sender: TObject);
    procedure HilfezudenEinstellungen1Click(Sender: TObject);
    procedure Beenden2Click(Sender: TObject);
    procedure FavLbLClick(Sender: TObject);
    procedure VerbindenBtClick(Sender: TObject);
    procedure FavSpRClick(Sender: TObject);
    procedure FavRechtsClick(Sender: TObject);
    procedure FavLbRClick(Sender: TObject);
    procedure FavLbLMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FavLbRMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LMDShellFolder2Change(Sender: TObject);
    procedure Bewegen1Click(Sender: TObject);
    procedure NeuerOrdner1Click(Sender: TObject);
    procedure Loeschen1Click(Sender: TObject);
    procedure Kopieren1Click(Sender: TObject);
    procedure ParentFolderRClick(Sender: TObject);
    procedure ParentFolderLClick(Sender: TObject);
    procedure Btn_CopyClick(Sender: TObject);
    procedure Btn_MoveClick(Sender: TObject);
    procedure FavLbLMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure FavLbRMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure LMDShellTree2Change(Sender: TObject; Node: TTreeNode);
    procedure DoppelKClick(Sender: TObject);
    procedure LMDShellList1DblClick(Sender: TObject);
    procedure LMDShellList1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure LMDShellList2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure AngleichenTBClick(Sender: TObject);
    procedure TauschenTBClick(Sender: TObject);
    procedure ComboBoxLDropDown(Sender: TObject);
    procedure ComboBoxRDropDown(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Filter1Click(Sender: TObject);
    procedure LMDShellList1Enter(Sender: TObject);
    procedure LMDShellList2Enter(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Logdateilschen1Click(Sender: TObject);
    procedure History1Click(Sender: TObject);
    procedure Positionspeichern1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormatverzClick(Sender: TObject);
    procedure LogBtClick(Sender: TObject);
    procedure AutostartClick(Sender: TObject);
    procedure Linker_FolderBtnClick(Sender: TObject);
    procedure SplDblClick(Sender: TObject);
    procedure SplDblClick3(Sender: TObject);
    procedure PropertiesBtnClick(Sender: TObject);
    procedure berwachung1Click(Sender: TObject);
    procedure ZiellabelMouseEnter(Sender: TObject);
    procedure QuelllabelMouseEnter(Sender: TObject);
    procedure RefreshBtClick(Sender: TObject);
    procedure LMDShellList2SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure LMDShellList1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure Btn_DeleteClick(Sender: TObject);
    procedure AutoSpalteClick(Sender: TObject);
    procedure PanelRResize(Sender: TObject);
    procedure PanelLResize(Sender: TObject);
    procedure WZSTTBClick(Sender: TObject);
    procedure Wasserzeichen1Click(Sender: TObject);
    procedure MonitoringBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Logdateiansehen2Click(Sender: TObject);
    procedure Verbinden1Click(Sender: TObject);
    procedure Allemarkieren1Click(Sender: TObject);
    procedure LMDShellList1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure TaskManager1Click(Sender: TObject);
    procedure AbbrechenPnClick(Sender: TObject);
    procedure ExtractBtnClick(Sender: TObject);
    procedure Btn_ViewClick(Sender: TObject);
    procedure Sendenan1Click(Sender: TObject);
    procedure ShowFolders_LeftClick(Sender: TObject);
    procedure Beide_FolderBtnClick(Sender: TObject);
    procedure QuellBtnClick(Sender: TObject);
    procedure ZielBtnClick(Sender: TObject);
    procedure QuellBtnMouseEnter(Sender: TObject);
    procedure ZielBtnMouseEnter(Sender: TObject);
    procedure ZielverzeichnisimExplorerffnen1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure PDF_ErstellungMouseEnter(Sender: TObject);
    procedure PDF_ErstellungMouseLeave(Sender: TObject);
    procedure FeedbackClick(Sender: TObject);
    procedure Formatverz_DateClick(Sender: TObject);
    procedure Btn_RenameClick(Sender: TObject);
    procedure Splash1Click(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure InDenTrayClick(Sender: TObject);
    procedure berFreePDF641Click(Sender: TObject);
    procedure Einstellungenndern2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure KlickaufXClick(Sender: TObject);
    procedure PDFdecryptClick(Sender: TObject);
    procedure Installation1Click(Sender: TObject);
    procedure MonitorBtnClick(Sender: TObject);
    procedure MonitorBtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure StatusBitBtnClick(Sender: TObject);
    procedure Status1Click(Sender: TObject);
    procedure Statusinformationen1Click(Sender: TObject);
    procedure LMDShellList1Click(Sender: TObject);
    procedure LMDShellTree1Click(Sender: TObject);
    procedure LMDShellTree2Click(Sender: TObject);
    procedure LMDShellList2Click(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure Memo1Click(Sender: TObject);
    procedure MainMenu1Change(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);
    procedure HTMLBtnClick(Sender: TObject);
    procedure PDFInfoBtnClick(Sender: TObject);
    procedure Memo1DblClick(Sender: TObject);
    procedure PDFAttachmentClick(Sender: TObject);
    procedure AnlagenBtnClick(Sender: TObject);
    procedure PDFRemoveClick(Sender: TObject);
    procedure PDFFontsBtnClick(Sender: TObject);
    procedure MonitorBtnMouseEnter(Sender: TObject);
    procedure TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ComboBoxLCloseUp(Sender: TObject);
    procedure ComboBoxRCloseUp(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure Image2ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure Image2Click(Sender: TObject);
    procedure SearchBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SuchennachSucheninHistorylschen1Click(Sender: TObject);
    procedure LMDShellList2Change(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure Formatverz_OnlyDateClick(Sender: TObject);
    procedure ResizeEqualClick(Sender: TObject);
    procedure NullstellungClick(Sender: TObject);
    procedure LMDShellList2ColumnClick(Sender: TObject; Column: TListColumn);
    procedure LMDShellList1ColumnClick(Sender: TObject; Column: TListColumn);
  public
    { Public-Deklarationen }
    procedure ExtAbfrage;
    procedure AllesSpeichern;
    procedure FavClose;
    procedure PlaySoundFile(FileName: string);
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMSettingChange(var Message: TMessage); message WM_SETTINGCHANGE;
    procedure ActiveControlChanged(Sender: TObject) ;
  private
    { Private-Deklarationen }
    wcActive, wcPrevious : TWinControl;
    FSortColumn, FSortColumn2: Integer;
    FSortAscending, FSortAscending2: Boolean;
  published
    { Doppelclick auf Splitter }
    property OnDblClick;
  end;

var
  FreePDF64_Form: TFreePDF64_Form;
  // Globale Variablen
  Left, Top, Width, Height: Integer;
  AP4, AP5, AP6, Editor, Ghostscript, ViewJPEG, QPDF, STA1, STA2, Auswahl,
  PDFReader, ImageMagick, Versch3, Versch5, A_S, B_Z, Ziel, AP3, MERGEDATEI,
  Ziel2, MonitoringFile, StartFolder, Text_FormatBtn, PDFA_1, PDFX_1,
  XPDF_Images, XPDF_ToHTML, XPDF_Info, XPDF_Detach, XPDF_Fonts: String;
  ParaJN, Versch1, Vol1, Vol2, PDFPanelH, MHA, Counter: Integer;
  ABBRUCH, LI, RE, LF, RF, Versch6, Versch7, Versch8, Versch9,
  Versch10, Versch11, Do1, In1, �berwachung_Erstellung, Links, Rechts,
  Windows_Session_End, FAbbrechen, Splash, Tray1, Popup_Aufruf,
  AutospalteJN, ShowVomTray, Suche_ItemAnzeigen: Boolean;
  Hochkommata: String[1];

implementation

uses
  Einstellungen_Unit, Encrypt_Unit, DokuInfo_Unit,
  Seiten_Unit, Favoriten_Unit, Favoriten2_Unit, Auswahl_Unit,
  Info_Unit, FreePDF64_Notify_Unit, Einstellungen_Hilfe_Unit, EineInstanz_Unit,
  Filter_Unit, Wasserzeichen_Unit, Zusatz_Unit, Splashscreen_Unit, Dateianlage_Unit, Status_Unit, Suchen;

{$R *.DFM}
{$R FreePDF64.res}

// Klick auf Splitter2 registrieren
procedure Register;
begin
  RegisterComponents('Samples', [TClickSplitter]);
end;

procedure TFreePDF64_Form.ActiveControlChanged(Sender: TObject);
begin
  wcPrevious := wcActive;
  wcActive   := FreePDF64_Form.ActiveControl;
end;

// Doppelklick auf Splitter2
procedure TFreePDF64_Form.SplDblClick(Sender: TObject);
var
  a: Boolean;
begin
  // JPEG-Fenster schlie�en
  if Image1.Visible then
  begin
    Image1.Visible := False;
    Image1.Picture := NIL;
    LMDShellList2.Visible := True;
  end else
  if Image2.Visible then
  begin
    Image2.Visible := False;
    Image2.Picture := NIL;
    LMDShellList1.Visible := True;
  end;

  a := LMDShellList1.Column[0].AutoSize;
  // AutoSize Spalte "Name"
//  FreePDF64_Form.Height := FreePDF64_Form.Height + 1;
//  FreePDF64_Form.Height := FreePDF64_Form.Height - 1;
  LMDShellList1.Column[0].AutoSize := True;
  LMDShellList2.Column[0].AutoSize := True;

  // Splitter soll sich in der Mitte befinden.
  if Panel_Right.Visible then
    PanelR.Width := (PanelL.Width + Panel_Right.Width + PanelR.Width) div 2
  else
    PanelR.Width := (PanelL.Width + PanelR.Width) div 2;

  LMDShellList1.Column[0].AutoSize := a;
  LMDShellList2.Column[0].AutoSize := a;

  Sleep(100);
  RefreshBt.Click
end;

// Doppelklick auf Splitter3
procedure TFreePDF64_Form.SplDblClick3(Sender: TObject);
begin
  if not FileExists(IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) + 'FreePDF64.ini') then
    Exit;

  PDFPanel.Height := PDFPanelH;

  Sleep(100);
  RefreshBt.Click
end;

procedure TFreePDF64_Form.Status1Click(Sender: TObject);
begin
  // Form soll mittig angezeigt werden.
  Status_Form.Position := poMainFormCenter;
  Status_Form.ShowModal;
end;

procedure TFreePDF64_Form.StatusBitBtnClick(Sender: TObject);
begin
  FavClose;
  // Form soll mittig angezeigt werden.
  Status_Form.Position := poMainFormCenter;
  Status_Form.ShowModal;
end;

procedure TFreePDF64_Form.Statusinformationen1Click(Sender: TObject);
begin
  // Form soll mittig angezeigt werden.
  Status_Form.Position := poScreenCenter;
  Status_Form.ShowModal;
end;

// Dieser Code positioniert die Input Box in die
// Mitte der Form und nicht in die Mitte des Bildschirms
function GetAveCharSize(Canvas: TCanvas): TPoint;
var
  I: Integer;
  Buffer: array [0..51] of Char;
begin
  for I := 0 to 25 do
    Buffer[I] := Chr(I + Ord('A'));
  for I := 0 to 25 do
    Buffer[I + 26] := Chr(I + Ord('a'));
  GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
  Result.X := Result.X div 52;
end;

function MyInputQuery_Verbinden(const ACaption, APrompt, AHint: string; var Value: string): Boolean; overload;
const
  SMsgDlgOK     = 'OK';
  SMsgDlgCancel = 'Abbrechen';
var
  x, y, w, h: Integer;
  Form: TForm;
  Prompt: TLabel;
  Edit: TEdit;
  DialogUnits: TPoint;
  ButtonTop, ButtonWidth, ButtonHeight: Integer;
begin
  Result := False;
  Form := TForm.Create(Application);
  with Form do
  try
    Canvas.Font  := Font;
    DialogUnits  := GetAveCharSize(Canvas);
    BorderStyle  := bsDialog;
    Caption      := ACaption;
    ClientWidth  := MulDiv(193, DialogUnits.X, 4);
    ClientHeight := MulDiv(74, DialogUnits.Y, 8);

    // Horizontal zentrieren
    w := (Application.MainForm.Width - Form.Width) div 2;
    X := Application.MainForm.Left + W;
    if x < 0 then
      x := 0
    else if x + w > Screen.Width then
      x := Screen.Width - Form.Width;
    Form.Left := X;

    // Vertikal zentrieren
    h := (Application.MainForm.Height - Form.Height) div 2;
    // Top-Position des Inputquery-Eingabedialogs
    y := Application.MainForm.Top + h;

    if y < 0 then
      y := 0
    else if y + h > Screen.Height then
      y := Screen.Height - Form.Height;
    Form.Left := X;
    Form.Top  := Y;

    Prompt := TLabel.Create(Form);
    with Prompt do
    begin
      Parent   := Form;
      ShowHint := True;
      Cursor   := crHandPoint;
      Left     := MulDiv(8, DialogUnits.X, 4);
      Top      := MulDiv(8, DialogUnits.Y, 8);
      Caption  := APrompt;
      Hint     := AHint;
      Width    := 325;
    end;

    Edit := TEdit.Create(Form);
    with Edit do
    begin
      Parent    := Form;
      Left      := Prompt.Left;
      Top       := MulDiv(35, DialogUnits.Y, 8);
      Width     := MulDiv(176, DialogUnits.X, 4);
      MaxLength := 255;
      Text      := Value;
      SelectAll;
    end;

    ButtonTop    := MulDiv(52, DialogUnits.Y, 8); // MulDiv(41, DialogUnits.Y, 8);
    ButtonWidth  := 132; // MulDiv(50, DialogUnits.X, 4);
    ButtonHeight := 44;  // MulDiv(14, DialogUnits.Y, 8);

    with TButton.Create(Form) do
    begin
      Parent      := Form;
      Caption     := SMsgDlgOK;
      ModalResult := mrOk;
      Default     := True;
      SetBounds(MulDiv(24, DialogUnits.X, 4), ButtonTop, ButtonWidth, ButtonHeight);
    end;

    with TButton.Create(Form) do
    begin
      Parent      := Form;
      Caption     := SMsgDlgCancel;
      ModalResult := mrCancel;
      Cancel      := True;
      SetBounds(MulDiv(102, DialogUnits.X, 4), ButtonTop, ButtonWidth, ButtonHeight);
    end;

    if ShowModal = mrOk then
    begin
      Value  := Edit.Text;
      Result := True;
    end;
  finally
    Form.Free;
  end;
end;

function MyInputQuery(const ACaption, APrompt: string; var Value: string): Boolean; overload;
const
  SMsgDlgOK     = 'OK';
  SMsgDlgCancel = 'Abbrechen';
var
  x, y, w, h: Integer;
  Form: TForm;
  Prompt: TLabel;
  Edit: TEdit;
  DialogUnits: TPoint;
  ButtonTop, ButtonWidth, ButtonHeight: Integer;
begin
  Result := False;
  Form := TForm.Create(Application);
  with Form do
  try
    Canvas.Font  := Font;
    DialogUnits  := GetAveCharSize(Canvas);
    BorderStyle  := bsDialog;
    Caption      := ACaption;
    ClientWidth  := MulDiv(193, DialogUnits.X, 4);
    ClientHeight := MulDiv(58, DialogUnits.Y, 8);

    // Horizontal zentrieren
    w := (Application.MainForm.Width - Form.Width) div 2;
    X := Application.MainForm.Left + W;
    if x < 0 then
      x := 0
    else if x + w > Screen.Width then
      x := Screen.Width - Form.Width;
    Form.Left := X;

    // Vertikal zentrieren
//    h := (Application.MainForm.Height + Form.Height) div 2;
    h := (Application.MainForm.Height - Form.Height) div 2;
    // Top-Position des Inputquery-Eingabedialogs
//    y := Application.MainForm.Top + (h DIV 2);
    y := Application.MainForm.Top + h;

    if y < 0 then
      y := 0
    else if y + h > Screen.Height then
      y := Screen.Height - Form.Height;
    Form.Left := X;
    Form.Top  := Y;

    Prompt := TLabel.Create(Form);
    with Prompt do
    begin
      Parent   := Form;
      AutoSize := True;
      Left     := MulDiv(8, DialogUnits.X, 4);
      Top      := MulDiv(8, DialogUnits.Y, 8);
      Caption  := APrompt;
    end;

    Edit := TEdit.Create(Form);
    with Edit do
    begin
      Parent    := Form;
      Left      := Prompt.Left;
      Top       := MulDiv(19, DialogUnits.Y, 8);
      Width     := MulDiv(176, DialogUnits.X, 4);
      MaxLength := 255;
      Text      := Value;
      SelectAll;
    end;

    ButtonTop    := MulDiv(36, DialogUnits.Y, 8); // MulDiv(41, DialogUnits.Y, 8);
    ButtonWidth  := 132; // MulDiv(50, DialogUnits.X, 4);
    ButtonHeight := 44;  // MulDiv(14, DialogUnits.Y, 8);

    with TButton.Create(Form) do
    begin
      Parent      := Form;
      Caption     := SMsgDlgOK;
      ModalResult := mrOk;
      Default     := True;
      SetBounds(MulDiv(24, DialogUnits.X, 4), ButtonTop, ButtonWidth, ButtonHeight);
//      SetBounds(MulDiv(38, DialogUnits.X, 4), ButtonTop, ButtonWidth, ButtonHeight);
    end;

    with TButton.Create(Form) do
    begin
      Parent      := Form;
      Caption     := SMsgDlgCancel;
      ModalResult := mrCancel;
      Cancel      := True;
      SetBounds(MulDiv(102, DialogUnits.X, 4), ButtonTop, ButtonWidth, ButtonHeight);
//      SetBounds(MulDiv(92, DialogUnits.X, 4), ButtonTop, ButtonWidth, ButtonHeight);
    end;

    if ShowModal = mrOk then
    begin
      Value  := Edit.Text;
      Result := True;
    end;
  finally
    Form.Free;
  end;
end;

// Gr��e der Datei angeben
function MyFileSize(FileName: String): Integer;
var
  SR: TSearchRec;
begin
  if FindFirst(FileName, faAnyFile, SR) = 0 then
  begin
    Result := SR.Size;
    FindClose(SR);
  end
  else
    Result := -1;
end; { MyFileSize }

// MessageDlg zentriert
function MessageDlgCenter(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons): Integer;
var
  R: TRect;
begin
  if not Assigned(Screen.ActiveForm) then
  begin
    Result := MessageDlg(Msg, DlgType, Buttons, 0);
  end
  else
  begin
    with CreateMessageDialog(Msg, DlgType, Buttons) do
      try
        GetWindowRect(Screen.ActiveForm.Handle, R);
        Left := R.Left + ((R.Right - R.Left) div 2) - (Width div 2);
        Top := R.Top + ((R.Bottom - R.Top) div 2) - (Height div 2);
        Result := ShowModal;
      finally
        Free;
      end;
  end;
end;

// Way to convert size in bytes to KB, MB, GB
function FormatByteString(Bytes: UInt64; Format: TByteStringFormat = bsfDefault): string;
begin
  if Format = bsfDefault then
  begin
    if Bytes < OneKB then
    begin
      Format := bsfBytes;
    end
    else if Bytes < OneMB then
    begin
      Format := bsfKB;
    end
    else if Bytes < OneGB then
    begin
      Format := bsfMB;
    end
    else if Bytes < OneTB then
    begin
      Format := bsfGB;
    end
    else
    begin
      Format := bsfTB;
    end;
  end;

  case Format of
    bsfBytes:
      Result := System.SysUtils.Format('%d Bytes', [Bytes]);
    bsfKB:
      Result := System.SysUtils.Format('%.2n KB', [Bytes / OneKB]);
    bsfMB:
      Result := System.SysUtils.Format('%.2n MB', [Bytes / OneMB]);
    bsfGB:
      Result := System.SysUtils.Format('%.2n GB', [Bytes / OneGB]);
    bsfTB:
      Result := System.SysUtils.Format('%.2n TB', [Bytes / OneTB]);
  end;
end;

// Create Process and Wait for Exit
function RunProcess(FileName: string; ShowCmd: DWORD; wait: Boolean; ProcID: PDWORD): Longword;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
  StartupInfo.wShowWindow := ShowCmd;
  if not CreateProcess(nil,
    @Filename[1],
    nil,
    nil,
    False,
    CREATE_NEW_CONSOLE or
    NORMAL_PRIORITY_CLASS,
    nil,
    nil,
    StartupInfo,
    ProcessInfo)
    then
    Result := WAIT_FAILED
  else
  begin
    if wait = FALSE then
    begin
      if ProcID <> NIL then
        ProcID^ := ProcessInfo.dwProcessId;
      result := WAIT_FAILED;
      exit;
    end;
    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
    GetExitCodeProcess(ProcessInfo.hProcess, Result);
  end;
  if ProcessInfo.hProcess <> 0 then
    CloseHandle(ProcessInfo.hProcess);
  if ProcessInfo.hThread <> 0 then
    CloseHandle(ProcessInfo.hThread);
end;

// Wasserzeichen/Stempel hinzuf�gen
procedure TFreePDF64_Form.WZSTTBClick(Sender: TObject);
var
  i: Integer;
  F: TextFile;
  WZST, WZST2, Zeile: String;
  ProcID: Cardinal;
begin
  FavClose;
  Wasserzeichen_Form.Caption := 'Wasserzeichen/Stempel: ' + IntToStr(LMDShellList1.SelCount) + ' Datei(en) markiert';

  if Einstellungen_Form.Edit5.Text = '' then
    Einstellungen_Form.Edit5.Text := ExtractFilePath(Application.ExeName) + 'pdftk\pdftk.exe';

  if LMDShellList1.Focused and (LMDShellList1.SelCount > 0) then
  begin
    // Form soll mittig angezeigt werden.
    Wasserzeichen_Form.Position := poMainFormCenter;
    if Wasserzeichen_Form.ShowModal = mrOk then
      ABBRUCH := false;

    if Wasserzeichen_Form.bgWatermark.Checked then
    begin
      WZST := 'background';
      WZST2 := 'WZ_'
    end
    else
    begin
      WZST := 'stamp';
      WZST2 := 'ST_';
    end;
  end else
  begin
    MessageDlgCenter('Wasserzeichen/Stempel hinzuf�gen: Bitte PDF-Datei(en) aus dem Quellverzeichnis ausw�hlen!', mtInformation, [mbOk]);
    Exit;
  end;

  // Wenn Abbrechen geklickt wurde...
  if (ABBRUCH = True) or (Wasserzeichen_Form.Edit1.Text = '') then
    Exit
  else
  begin
    if LMDShellList1.Focused and Assigned(LMDShellList1.Selected) then
    begin
      // Verzeichnis erstellen der gew�nschten Endung (\PDF)
      if System.SysUtils.ForceDirectories
        (IncludeTrailingBackslash(Wasserzeichen_Form.Edit2.Text)) then
        // Wenn mehrere Dateien markiert sind...
        for i := 0 to LMDShellList1.SelCount - 1 do
        begin
          Memo1.Lines.Clear;
          // AP3: Welche PDF-Datei(en) soll ein Wasserzeichen erhalten?
          AP3 := IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) +
            LMDShellList1.SelectedItems[i].DisplayName;
          if Uppercase(ExtractFileExt(AP3)) <> ('.PDF') then
            Exit;

          // Kommandozeile von PDFtk
          Zeile := Einstellungen_Form.Edit5.Text + ' "' + AP3 + '" ' + WZST +
            ' "' + Wasserzeichen_Form.Edit1.Text + '" output "' +
            IncludeTrailingBackslash(Wasserzeichen_Form.Edit2.Text) + WZST2 +
            ExtractFileName(AP3) + '"';
          // Starte die Erstellung...
          ProcID := 0;
          if RunProcess(Zeile, SW_HIDE, True, @ProcID) <> 0 then
            // ShowMessage(IntToStr(ProcID));
            MessageDlgCenter('Die Datei "' + ExtractFileName(AP3) +
              '" hat vermutlich Einschr�nkungen (Kennwortschutz, etc).' + #13 +
              'Das Hinzuf�gen von Wasserzeichen/Stamp geht dann leider nicht. Abhilfe w�re,'
              + #13 + 'diese Einschr�nkungen vorher zu entfernen (...das geht mit FreePDF64)!',
              mtError, [mbOk])
          else
          begin
            // Memo f�llen...
            Memo1.Lines.Text := Memo1.Lines.Text + Einstellungen_Form.Edit5.Text
              + ' ' + AP3 + ' ' + WZST + ' ' + Wasserzeichen_Form.Edit1.Text +
              ' output ' + IncludeTrailingBackslash(Wasserzeichen_Form.Edit2.Text) + WZST2 +
              ExtractFileName(AP3);
            // Bis hierhin...

            // FreePDF64Log.txt
            if Logdatei.Checked then
            begin
              // Logdatei (FreePDF64Log.txt) �ffnen/beschreiben etc.
              AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
              try
                Append(F);
              except
                Rewrite(F)
              end;
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ==========> WZ/Stempel: ' + Memo1.Lines.Text));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -          WZ/ST-Datei: ' + IncludeTrailingBackslash(Wasserzeichen_Form.Edit1.Text)));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(AP3))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(AP3)));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(AP3))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(Wasserzeichen_Form.Edit2.Text) + WZST2 + IncludeTrailingBackslash(ExtractFilePath(AP3))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + IncludeTrailingBackslash(Wasserzeichen_Form.Edit2.Text) + WZST2 + ExtractFileName(AP3)));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(IncludeTrailingBackslash(Wasserzeichen_Form.Edit2.Text)
                      + WZST2 + ExtractFileName(AP3)))));
              Closefile(F);

              // Mit einem PDF-Anzeiger anzeigen
              if Einstellungen_Form.AnzeigenCB.Checked then
              begin
                if Einstellungen_Form.Edit3.Text = '' then
                  PDFReader := ExtractFilePath(Application.ExeName) + 'xpdf\xpdfreader\xpdf.exe'
                else
                  PDFReader := Einstellungen_Form.Edit3.Text;
                ShellExecute(Application.Handle, 'open', PChar(PDFReader),
                  PChar('"' + (IncludeTrailingBackslash(Wasserzeichen_Form.Edit2.Text) + WZST2 + ExtractFileName(AP3)) + '"'), NIL, SW_SHOWNORMAL);
              end;
            end;
            // Ende von FreePDF64Log.txt
            ProgressBar1.Position := 100;
          end;
          if Einstellungen_Form.SystemklangCB.Checked then
            PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');
        end;
    end;
//    LMDShellList1.ClearSelection;
  end;
  ProgressBar1.Position := 0;

  LMDShellList1.SetFocus;
end;

// Ausgabe Consolelog -> Memofenster
procedure RunDosInMemo(DosApp: string; AMemo:TMemo);
const
    READ_BUFFER_SIZE = 2400;
var
    Security: TSecurityAttributes;
    readableEndOfPipe, writeableEndOfPipe: THandle;
    start: TStartUpInfo;
    ProcessInfo: TProcessInformation;
    Buffer: PAnsiChar;
    BytesRead: DWORD;
    AppRunning: DWORD;
begin
    Security.nLength := SizeOf(TSecurityAttributes);
    Security.bInheritHandle := True;
    Security.lpSecurityDescriptor := NIL;

    if CreatePipe({var}readableEndOfPipe, {var}writeableEndOfPipe, @Security, 0) then
    begin
        Buffer := AllocMem(READ_BUFFER_SIZE+1);
        FillChar(Start, Sizeof(Start), #0);
        start.cb := SizeOf(start);

        // Set up members of the STARTUPINFO structure.
        // This structure specifies the STDIN and STDOUT handles for redirection.
        // - Redirect the output and error to the writeable end of our pipe.
        // - We must still supply a valid StdInput handle (because we used STARTF_USESTDHANDLES to swear that all three handles will be valid)
        start.dwFlags    := start.dwFlags or STARTF_USESTDHANDLES;
        start.hStdInput  := GetStdHandle(STD_INPUT_HANDLE); //we're not redirecting stdInput; but we still have to give it a valid handle
        start.hStdOutput := writeableEndOfPipe; //we give the writeable end of the pipe to the child process; we read from the readable end
        start.hStdError  := writeableEndOfPipe;

        //We can also choose to say that the wShowWindow member contains a value.
        //In our case we want to force the console window to be hidden.
        start.dwFlags     := start.dwFlags + STARTF_USESHOWWINDOW;
        start.wShowWindow := SW_HIDE;

        // Don't forget to set up members of the PROCESS_INFORMATION structure.
        ProcessInfo := Default(TProcessInformation);

        //WARNING: The unicode version of CreateProcess (CreateProcessW) can modify the command-line "DosApp" string.
        //Therefore "DosApp" cannot be a pointer to read-only memory, or an ACCESS_VIOLATION will occur.
        //We can ensure it's not read-only with the RTL function: UniqueString
        UniqueString({var}DosApp);

        if CreateProcess(NIL, PChar(DosApp), NIL, NIL, True, NORMAL_PRIORITY_CLASS, NIL, NIL, start, {var}ProcessInfo) then
        begin
            //Wait for the application to terminate, as it writes it's output to the pipe.
            //WARNING: If the console app outputs more than 2400 bytes (ReadBuffer),
            //it will block on writing to the pipe and *never* close.
            repeat
                Apprunning := WaitForSingleObject(ProcessInfo.hProcess, 100);
                Application.ProcessMessages;
            until (Apprunning <> WAIT_TIMEOUT);

            //Read the contents of the pipe out of the readable end
            //WARNING: if the console app never writes anything to the StdOutput, then ReadFile will block and never return
            repeat
                BytesRead := 0;
                ReadFile(readableEndOfPipe, Buffer[0], READ_BUFFER_SIZE, {var}BytesRead, NIL);
                Buffer[BytesRead]:= #0;
                // Die n�chste Zeile konvertiert NICHT die deutschen Umlaute?!
//                OemToAnsi(Buffer, Buffer);
                AMemo.Text := AMemo.text + String(Buffer);
            until (BytesRead < READ_BUFFER_SIZE);
        end;
        FreeMem(Buffer);
        CloseHandle(ProcessInfo.hProcess);
        CloseHandle(ProcessInfo.hThread);
        CloseHandle(readableEndOfPipe);
        CloseHandle(writeableEndOfPipe);
    end;
end;

// Anlage(n) einer PDF-Datei hinzuf�gen
procedure TFreePDF64_Form.AnlagenBtnClick(Sender: TObject);
var
  PDFDatei, Zieldatei, Anlage, Zeile, Beschreibung: String;
  ProcID: Cardinal;
  F: TextFile;
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
  begin
    LMDOpenDialog2.InitialDir := LMDShellFolder1.ActiveFolder.PathName;
    if LMDOpenDialog2.Execute then
      Anlage := LMDOpenDialog2.Filename
    else
      Exit;

    // Wenn Erstellung Formatfolder angehakt...
    if Formatverz_Date.Checked then
    begin
      // Verzeichnis erstellen der gew�nschten Endung (hier PDF + Datum)
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'PDF' + ' ' + DateToStr(NOW)) then
        Ziel := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'PDF' + ' ' + DateToStr(NOW)
    end else if Formatverz_OnlyDate.Checked then
    begin
      // Verzeichnis erstellen der gew�nschten Endung (Datum)
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + DateToStr(NOW)) then
        Ziel := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + DateToStr(NOW)
    end else if Formatverz.Checked then
    begin
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'PDF') then
        Ziel := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'PDF';
    end else
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName)) then
        Ziel := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName);

    MyInputQuery('Anlage einer PDF-Datei hinzuf�gen', 'Beschreibung zur Anlage:', Beschreibung);

    Zeile     := Einstellungen_Form.Edit4.Text + ' --add-attachment --description="' + Beschreibung + '" "' + Anlage +
                 '" -- "' + (IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) + LMDShellList1.SelectedItems[0].DisplayName) +
                 '" "' + IncludeTrailingBackslash(Ziel) + LMDShellList1.SelectedItems[0].DisplayName + '"';
    PDFDatei  := IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) + LMDShellList1.SelectedItems[0].DisplayName;
    ZielDatei := IncludeTrailingBackslash(Ziel) + LMDShellList1.SelectedItems[0].DisplayName;

    // Starte die Erstellung...
    ProcID := 0;
    if RunProcess(Zeile, SW_HIDE, True, @ProcID) = 2 then
    begin
      MessageDlgCenter('Quell- und Zielverzeichnis d�rfen beim Hinzuf�gen von Dateien NICHT identisch sein.' + #13 +
                       'Bitte ein anderes Ziel ausw�hlen oder -> Ins Unterverzeichnis beim Erstellen <- nutzen!' , mtInformation, [mbOk]);
      Exit;
    end;

    if RunProcess(Zeile, SW_HIDE, True, @ProcID) = 0 then
    begin
      Memo1.Lines.Text := Zeile;
      // FreePDF64Log.txt
      if Logdatei.Checked then
      begin
        // Logdatei (FreePDF64Log.txt) �ffnen/beschreiben etc.
        AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
        try
          Append(F);
        except
          Rewrite(F)
        end;
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ===> Anlage hinzuf�gen: ' + Zeile));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName)));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + LMDShellList1.SelectedItems[0].DisplayName));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(PDFDatei))));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -               Anlage: ' + Anlage));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(Ziel)));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Zieldatei)));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(Zieldatei))));
        Closefile(F);

        if Einstellungen_Form.SystemklangCB.Checked then
          PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');
      end;
    end;
    Application.ProcessMessages;
    // Mit einem PDF-Anzeiger anzeigen
    if Einstellungen_Form.AnzeigenCB.Checked then
    begin
      if Einstellungen_Form.Edit3.Text = '' then
        PDFReader := ExtractFilePath(Application.ExeName) + 'xpdf\xpdfreader\xpdf.exe'
      else
        PDFReader := Einstellungen_Form.Edit3.Text;
      ShellExecute(Application.Handle, 'open', PChar(PDFReader), PChar(Zieldatei), NIL, SW_SHOWNORMAL);
    end;
  end else
  begin
    MessageDlgCenter('Anlage einer PDF-Datei hinzuf�gen: Bitte EINE PDF-Datei aus dem Quellverzeichnis ausw�hlen!', mtInformation, [mbOk]);
    Exit;
  end;
end;

function TextHoehe(Font: TFont; Text: String): Integer;
var
  B: TBitMap;
begin
  B := TBitMap.Create;
  B.Canvas.Font := Font;
  Result := B.Canvas.TextHeight(Text);
  B.Free;
end;

// Anlage(n) aus einer PDF-Datei extrahieren/entfernen
procedure TFreePDF64_Form.PDFRemoveClick(Sender: TObject);
var
  PDFDatei, Zieldatei, Anlage,
  Zeile, Zeile2, Ausgabe: String;
  ProcID: Cardinal;
  F: TextFile;
  i, j: Integer;
begin
  FavClose;
  Memo1.Clear;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  // Zeige die Attachments der ausgew�hlten PDF-Datei
  if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
  begin
    // Anlagen anzeigen...
    for i := 0 to LMDShellList1.SelCount - 1 do
      RunDosInMemo(XPDF_Detach + ' -list "' + IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) +
                   LMDShellList1.SelectedItems[i].DisplayName + '"', Memo1);

    // Wenn keine Anlagen in der PDF-Datei enthalten sind, Routine mit Hinweisfenster beenden!
    if Memo1.lines[0] = '0 embedded files' then
    begin
      MessageDlgCenter('Fehler beim Extrahieren der Anlage aus der Datei: "' + LMDShellList1.Selected.Caption + '".' + #13 +
                       'Vermutlich enth�lt die PDF-Datei keine Anlage?!', mtError, [mbOk]);
      Exit;
    end;

    if Memo1.Lines.Count > 1 then
    begin
      j:= TextHoehe(Memo1.Font, Memo1.Text);
      j := (j * Memo1.Lines.Count) + MHA;
      if j > Memo1.Parent.Height then
        PDFPanel.Height := j;
    end;

    if not MyInputQuery('Anlage aus einer PDF-Datei extrahieren', 'Bitte Nummer der Anlage angeben:', Anlage) then
      Exit
    else if Anlage = '' then
      Exit;

    // Zeige die Zeile namens "Anlage" aus Memo1 an
    Ausgabe := Memo1.Lines[StrToInt(Anlage)];
    // Die ersten 3 Zeichen davon dann entfernen
    Delete(Ausgabe, 1, 3);
    for i := 0 to LMDShellList1.SelCount - 1 do
      Zeile := XPDF_Detach + ' -save ' + Anlage + ' -o "' + IncludeTrailingBackslash(Ziel) + Ausgabe  + '" "' +
               IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) + LMDShellList1.SelectedItems[i].DisplayName + '"';
    PDFDatei  := IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) + LMDShellList1.SelectedItems[0].DisplayName;
    ZielDatei := IncludeTrailingBackslash(Ziel) + LMDShellList1.SelectedItems[0].DisplayName;

    // Starte die Erstellung und extrahiere die Anlage aus der PDF-Datei
    ProcID := 0;
    // Bei Fehler -> Exit
    if RunProcess(Zeile, SW_HIDE, True, @ProcID) <> 0 then
      Exit;

      Memo1.Lines.Text := Zeile;
      // FreePDF64Log.txt
      if Logdatei.Checked then
      begin
        // Logdatei (FreePDF64Log.txt) �ffnen/beschreiben etc.
        AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
        try
          Append(F);
        except
          Rewrite(F)
        end;
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ==> Anlage extrahieren: ' + Zeile));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName)));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + LMDShellList1.SelectedItems[0].DisplayName));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(Ziel)));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -   Extrahierte Anlage: ' + Ausgabe));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(IncludeTrailingBackslash(Ziel) + Ausgabe))));
        Closefile(F);
        if Einstellungen_Form.SystemklangCB.Checked then
          PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');
      end;

    if MessageDlgCenter('M�chten Sie diese Anlage auch aus der PDF-Datei entfernen?', mtInformation, [mbYes, mbNo]) = mrNo then
      Exit;

    // Wenn Erstellung Formatfolder angehakt...
    if Formatverz_Date.Checked then
    begin
      // Verzeichnis erstellen der gew�nschten Endung (hier PDF + Datum)
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'PDF' + ' ' + DateToStr(NOW)) then
        Ziel := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'PDF' + ' ' + DateToStr(NOW)
    end else if Formatverz_OnlyDate.Checked then
    begin
      // Verzeichnis erstellen der gew�nschten Endung (hier PDF + Datum)
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + DateToStr(NOW)) then
        Ziel := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + DateToStr(NOW)
    end else if Formatverz.Checked then
    begin
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'PDF') then
        Ziel := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'PDF';
    end else
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName)) then
        Ziel := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName);

    // Starte die 2te Erstellung und entferne auch die Anlage aus der PDF-Datei
    Zeile2 := Einstellungen_Form.Edit4.Text + ' --remove-attachment="' + Ausgabe + '" "' +
              (IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) + LMDShellList1.SelectedItems[0].DisplayName) + '" "' +
              IncludeTrailingBackslash(Ziel) + LMDShellList1.SelectedItems[0].DisplayName + '"';

    ProcID := 0;
    if RunProcess(Zeile2, SW_HIDE, True, @ProcID) = 0 then
    begin
      Memo1.Lines.Text := Zeile2;
      // FreePDF64Log.txt
      if Logdatei.Checked then
      begin
        // Logdatei (FreePDF64Log.txt) �ffnen/beschreiben etc.
        AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
        try
          Append(F);
        except
          Rewrite(F)
        end;
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ====> Anlage entfernen: ' + Zeile2));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName)));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + LMDShellList1.SelectedItems[0].DisplayName));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(PDFDatei))));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Entfernte Anlage: ' + Ausgabe));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(Ziel)));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Zieldatei)));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(IncludeTrailingBackslash(Ziel) +
                ExtractFileName(Zieldatei)))));
        Closefile(F);

        if Einstellungen_Form.SystemklangCB.Checked then
          PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');
      end;
    end;
    Application.ProcessMessages;
    // Mit einem PDF-Anzeiger anzeigen
    if Einstellungen_Form.AnzeigenCB.Checked then
    begin
      if Einstellungen_Form.Edit3.Text = '' then
        PDFReader := ExtractFilePath(Application.ExeName) + 'xpdf\xpdfreader\xpdf.exe'
      else
        PDFReader := Einstellungen_Form.Edit3.Text;
      ShellExecute(Application.Handle, 'open', PChar(PDFReader), PChar(Zieldatei), NIL, SW_SHOWNORMAL);
    end;
  end else
  begin
    MessageDlgCenter('Anlage aus einer PDF-Datei extrahieren/entfernen: Bitte EINE PDF-Datei aus dem Quellverzeichnis ausw�hlen!', mtInformation, [mbOk]);
    Exit;
  end;
end;

// Aufruf spezieller Ordner, wie z.B. die Netzwerkumgebung, �Eigene Dateien".
// Nachfolgende Procedure �ffnet einen solchen virtuellen Dialog:
// CSIDL_Controls  f�r "Systemsteuerung",
// CSIDL_Printers  f�r "Drucker",
// CSIDL_Drives	   f�r "Arbeitsplatz",
// CSIDL_Network   f�r "Netzwerkumgebung".
// CSIDL_BITBUCKET f�r "Papierkorb"
// ....
// Weitere Konstanten stehen in der Unit ShlObj.
procedure ShowSpecialFolder(const AFolder: Integer);
var
  ItemIDList: PItemIDList;
  ShExInfo: ShellExecuteInfo;
begin
  ShGetSpecialFolderLocation(Application.Handle, AFolder, ItemIDList);
  FillChar(ShExInfo, SizeOf(ShExInfo), 0);
  with ShExInfo do
  begin
    cbSize := SizeOf(ShExInfo);
    nShow := SW_Show;
    fMask := see_Mask_IDList;
    lpIDList := ItemIDList;
  end;
  ShellExecuteEx(@ShExInfo);
end;

// Programm in den Autostart...
function CreateAutorunEntry(const AName, AFilename: string;
  const AKind: TAutorunKind): Boolean;
var
  Reg: TRegistry;
begin
  Result := false;
  Reg := TRegistry.Create;
  try
    if AKind = akUserRun then
      Reg.Rootkey := HKEY_CURRENT_USER
    else
      Reg.Rootkey := HKEY_LOCAL_MACHINE;

    case AKind of
      akRun, akUserRun:
        Result := Reg.OpenKey
          ('\Software\Microsoft\Windows\CurrentVersion\Run', True);
    end;
    Reg.WriteString(AName, AFilename);
  finally
    Reg.Free;
  end;
end;

// Autosize beider Namen-Spalten
procedure TFreePDF64_Form.AutoSpalteClick(Sender: TObject);
begin
  AutoSpalte.Checked := Not AutoSpalte.Checked;
  if AutoSpalte.Checked then
  begin
    LMDShellList1.Column[0].AutoSize := True;
    LMDShellList2.Column[0].AutoSize := True;
    FreePDF64_Form.Height := FreePDF64_Form.Height + 1;
    FreePDF64_Form.Height := FreePDF64_Form.Height - 1;
  end
  else
  begin
    LMDShellList1.Column[0].AutoSize := false;
    LMDShellList2.Column[0].AutoSize := false;
  end;
end;

procedure TFreePDF64_Form.ResizeEqualClick(Sender: TObject);
begin
  ResizeEqual.Checked := Not ResizeEqual.Checked;
end;

procedure TFreePDF64_Form.AutostartClick(Sender: TObject);
var
  Reg: TRegistry;
begin
  Autostart.Checked := Not Autostart.Checked;
  if Autostart.Checked then
    // Ab in den Autostart nach HKCU: \Software\Microsoft\Windows\CurrentVersion\Run
    CreateAutorunEntry(Application.Title, ParamStr(0), akUserRun)
  else
  // sonst Registry-Eintrag wieder l�schen...
  begin
    Reg := TRegistry.Create;
    try
      Reg.Rootkey := HKEY_CURRENT_USER;
      Reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run\', false);
      Reg.DeleteValue('FreePDF64');
      Reg.CloseKey;
    finally
      Reg.Free;
    end;
  end;
end;

procedure TFreePDF64_Form.Anleitung1Click(Sender: TObject);
begin
  MessageDlgCenter('PDF-Dateien erzeugen, miteinander verbinden, drucken, Seiten entnehmen, Bilder extrahieren, verschl�sseln'
    + #13 + '(128-Bit RC4/AES oder 256-Bit AES), mit Wasserzeichen oder Stempel versehen, uvm.' + #13
    + #13 + 'Drucken aus jedem Programm heraus mit sofortiger PS/PDF/BMP/JPEG/PNG/TIFF/DOCX-Erstellung:'
    + #13 + '- Einfachste Installation des ben�tigten FreePDF64-Druckers (Men�punkt: Installation von Mfilemon)'
    + #13 + '- Alle ben�tigten Programme sind schon im Installationspaket enthalten'
    + #13 + '- Die wichtigsten FreePDF64-Einstellungen inkl. korrekter Pfade sind schon voreingestellt!'
    + #13 + '- Drucke nun aus jeder Windows-Anwendung heraus auf den erstellten FreePDF64-Drucker... Fertig!' + #13
    + #13 + 'Funktionen:'
    + #13 + '01: Erstellen von PS (Postscript) zu PDF/BMP/JPEG/PNG/TIFF/TXT-Dateien'
    + #13 + '02: Erstellen von PDF zu PDF-verschl�sselt/PS/BMP/JPEG/PNG/TIFF/TXT/DOCX-Dateien'
    + #13 + '03: Erstellen von BMP/JPEG/PNG/TIFF zu PDF-Dateien'
    + #13 + '04: PDF-Dateien vor und auch nach der Erstellung verschl�sseln (128-Bit RC4/AES oder 256-Bit AES)'
    + #13 + '05: PDF-Passwortschutz entfernen'
    + #13 + '06: Erstellen von PDF/A-1b bis PDF/A-3b: Ein Dateiformat zur Langzeitarchivierung'
    + #13 + '07: Erstellen von PDF/X-3: Ein Dateiformat f�r den Austausch digitaler Druckvorlagen'
    + #13 + '08: �ndern der PDF-Metadaten (PDFMarks: z.B. Titel, Verfasser, Thema, etc.) bei der Erstellung'
    + #13 + '09: Verbinden von mehreren PS/PDF-Dateien zu einer PDF-Datei'
    + #13 + '10: Distiller Parameter anpassen (Acrobat 5-8 kompatibel)'
    + #13 + '11: Auswahl verschiedener TIFF-Formate. DPI f�r erzeugte BMP/JPEG/TIFF einstellen'
    + #13 + '12: PDF/PS/TXT/TIFF-Datei(en) direkt nach der Erstellung mit dem zugewiesenen Anzeiger �ffnen'
    + #13 + '13: Ausgew�hlte Seiten entnehmen aus allen Formaten'
    + #13 + '14: Schnelle Webanzeige (Optimierung der PDF-Datei)'
    + #13 + '15: Komprimierung der PDF-Datei(en)'
    + #13 + '16: Konvertieren von PDF zu HTML'
    + #13 + '17: Hinzuf�gen eines Wasserzeichens oder Stempels zu einer PDF-Datei'
    + #13 + '18: Anf�gen einer PS- oder PDF-Datei vorne/hinten an die zu erstellende PDF-Datei'
    + #13 + '19: Bilder extrahieren aus PDF-Dateien oder Anlagen zur PDF-Datei hinzuf�gen/extrahieren'
    + #13 + '20: Umfangreichste Suchfunktionen'
    + #13 + '21: E-Mailversand der markierten Datei(en) - gleich der Windows-Funktion "Senden an"'
    + #13 + '22: Automatische �berwachung auf neue eingehende Dateien (z.B. gedruckt aus den Anwendungen an den'
    + #13 + '      FreePDF64-Drucker) mit sofortiger Erstellung ins gew�nschte Format!'
    + #13 + '... uvm.' + #13 + #13 +
    'Weitere Informationen unter: Hilfe - FreePDF64-HowTo',
    mtInformation, [mbOk]);
end;

procedure TFreePDF64_Form.Favoritenspeichern1Click(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile: String;
  i, j: Integer;
begin
  IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
  IniDat := TIniFile.Create(IniFile);
  with IniDat do
  begin
    // Favoritenliste schreiben.
    IniDat.EraseSection('Favorites Left');
    for i := 1 to ListBoxL.Items.Count do
      IniDat.WriteString('Favorites Left', IntToStr(i - 1),
        ListBoxL.Items[i - 1]);
    // Favoritenliste Rechts schreiben.
    IniDat.EraseSection('Favorites Right');
    for j := 1 to ListBoxR.Items.Count do
      IniDat.WriteString('Favorites Right', IntToStr(j - 1),
        ListBoxR.Items[j - 1]);
  end;
  // Speicher wird wieder freigeben
  IniDat.Free;
end;

procedure TFreePDF64_Form.FormDestroy(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile: String;
  i: Integer;
begin
  try
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
    IniDat := TIniFile.Create(IniFile);
    // Speichere beim Beenden des Programmes in die 'FreePDF64.ini'
    with IniDat do
    begin
      // Verlauf FreePDF64 schreiben.
      IniDat.EraseSection('History');
      if ComboBoxL.Items.Count > 0 then
        for i := 1 to ComboBoxL.Items.Count do
          WriteString('History', 'History Left' + IntToStr(i - 1), ComboBoxL.Items[i - 1]);
      if ComboBoxR.Items.Count > 0 then
        for i := 1 to ComboBoxR.Items.Count do
          WriteString('History', 'History Right' + IntToStr(i - 1), ComboBoxR.Items[i - 1]);
      WriteInteger('Start', 'Counter', Counter);
      WriteInteger('Start', 'Sort ColumnL', FSortColumn);
      WriteInteger('Start', 'Sort ColumnR', FSortColumn2);
      WriteBool('Start', 'SortDir ColumnL', FSortAscending);
      WriteBool('Start', 'SortDir ColumnR', FSortAscending2);
    end;
    // Speicher wird wieder freigeben
    IniDat.Free;
  except
    ShowMessage('Fehler festgestellt!');
  end;
  Screen.OnActiveControlChange := NIL;
end;

procedure TFreePDF64_Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ADD then
    Filter1.Click;

  if (ssShift in Shift) then
  begin
    Btn_Copy.Caption := 'Kopieren (Dialog) Umsch+F5';
    Btn_Move.Caption := 'Bewegen (Dialog) Umsch+F6';
  end;

  if (ssShift in Shift) and (Key = VK_F5) then
    CopyTo.Click;
  if (ssShift in Shift) and (Key = VK_F6) then
    MoveTo.Click;
end;

procedure TFreePDF64_Form.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Btn_Copy.Caption := 'F5 Kopieren';
  Btn_Move.Caption := 'F6 Bewegen';
end;

// List all files in a directory: Ergebnis ist in RESULT
function ListFileDir(Path: string): Integer;
var
  SR: TSearchRec;
  i, faHidden: Integer;
begin
  faHidden := 2;
  i := 0;
  if not FreePDF64_Form.VersteckteDateienanzeigen1.Checked then
  begin
    if FindFirst(Path + '*.*', faSysfile and faDirectory, SR) = 0 then
    begin
      repeat
        INC(i);
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;
    Result := i;
  end else
  begin
    if FindFirst(Path + '*.*', faAnyfile and faHidden and not faDirectory, SR) = 0 then
    begin
      repeat
        INC(i);
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;
    Result := i;
  end;
end;

// Verzeichnisgr��e auslesen mit/ohne Unterverzeichnisse
function GetDirSize(dir: string; subdir: Boolean): Int64;
var
  rec: TSearchRec;
  found: Integer;
begin
  Result := 0;
  if dir[Length(dir)] <> '\' then
    dir := dir + '\';
  found := FindFirst(dir + '*.*', faAnyFile, rec);
  while found = 0 do
  begin
    INC(Result, rec.Size);
    if (rec.Attr and faDirectory > 0) and (rec.Name <> '.') and
      (rec.Name <> '..') and (subdir = True) then
      INC(Result, GetDirSize(dir + rec.Name, True));
    found := FindNext(rec);
  end;
  FindClose(rec);
end;

procedure TFreePDF64_Form.Verbinden1Click(Sender: TObject);
begin
  Popup_Aufruf := True;
  Merge.Click;
end;

procedure TFreePDF64_Form.VerbindenBtClick(Sender: TObject);
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  Merge.Click;
end;

procedure SB_Left;
begin
  FreePDF64_Form.StatusBar_Left.SimpleText :=
                  'Datei(en)/Verzeichnis(se): ' +
                  IntToStr(ListFileDir(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName)))
	               	+ '/' +
                  IntToStr(FreePDF64_Form.LMDShellList1.Items.Count - ListFileDir(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName)))
 							    + ' - ' +
                  IntToStr(ListFileDir(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName))) + ' Datei(en)'
                  + ' in ' +
                  FormatByteString(GetDirSize(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName), False));
end;

procedure SB_Right;
begin
  FreePDF64_Form.StatusBar_Right.SimpleText :=
                  'Datei(en)/Verzeichnis(se): ' +
                  IntToStr(ListFileDir(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName)))
	               	+ '/' +
                  IntToStr(FreePDF64_Form.LMDShellList2.Items.Count - ListFileDir(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName)))
							    + ' - ' +
                  IntToStr(ListFileDir(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName))) + ' Datei(en)'
                  + ' in ' +
                  FormatByteString(GetDirSize(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName), False));
end;

procedure TFreePDF64_Form.VersteckteDateienanzeigen1Click(Sender: TObject);
var
  tmpt: TLMDShellListOptions;
begin
  VersteckteDateienanzeigen1.Checked := not VersteckteDateienanzeigen1.Checked;
  tmpt := LMDShellList1.Options;
  if VersteckteDateienanzeigen1.Checked then
    Include(tmpt, loShowHidden)
  else
    Exclude(tmpt, loShowHidden);
  LMDShellList1.Options := tmpt;
  LMDShellList2.Options := tmpt;
  SB_Left;
  SB_Right;
end;

// Wasserzeichen...
procedure TFreePDF64_Form.Wasserzeichen1Click(Sender: TObject);
begin
  WZSTTB.Click;
end;

procedure TFreePDF64_Form.ZiellabelMouseEnter(Sender: TObject);
begin
  Ziellabel.Hint := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName);
end;

procedure TFreePDF64_Form.LMDShellTree2Change(Sender: TObject; Node: TTreeNode);
begin
  Quelllabel.Caption := 'Quelle - ' + MinimizeName(IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName), FreePDF64_Form.Canvas,
                                      Quelllabel.Width - (FavSpL.Width + FavLinks.Width + ParentFolderL.Width + QuellBtn.Width + ComboBoxL.Width + 100));

  // JPEG-Fenster schlie�en
  if Image2.Visible then
  begin
    Image2.Visible := False;
    Image2.Picture := NIL;
    LMDShellList1.Visible := True;
  end;
end;

procedure TFreePDF64_Form.LMDShellTree2Click(Sender: TObject);
begin
  FavClose;
end;

procedure TFreePDF64_Form.BackBtnClick(Sender: TObject);
begin
  FavClose;
  if LMDShellList1.Focused then
    LMDShellFolder1.GoBack(-1)
  else
    LMDShellFolder2.GoBack(-1);
end;

procedure TFreePDF64_Form.FwdBtnClick(Sender: TObject);
begin
  FavClose;
  if LMDShellList1.Focused then
    LMDShellFolder1.GoForward(-1)
  else
    LMDShellFolder2.GoForward(-1);
end;

procedure TFreePDF64_Form.Beenden2Click(Sender: TObject);
begin
  Exit1.Click;
end;

procedure TFreePDF64_Form.Beide_FolderBtnClick(Sender: TObject);
begin
  FavClose;
  ShowFolders1.Click;
end;

procedure TFreePDF64_Form.Seitenextrahieren1Click(Sender: TObject);
begin
  // Form soll mittig angezeigt werden.
  Seiten_Form.Position := poMainFormCenter;
  Seiten_Form.ShowModal;
end;

// Wird f�r "Send To..." ben�tigt
function GetFileListDataObject(const Directory: string; Files:
  TStrings):
  IDataObject;
type
  PArrayOfPItemIDList = ^TArrayOfPItemIDList;
  TArrayOfPItemIDList = Array[0..0] of PItemIDList;
var
  Malloc: IMalloc;
  Root: IShellFolder;
  FolderPidl: PItemIDList;
  Folder: IShellFolder;
  p: PArrayOfPItemIDList;
  chEaten: ULONG;
  dwAttributes: ULONG;
  FileCount: Integer;
  i: Integer;
begin
  Result := NIL;
  if Files.Count = 0 then
    Exit;
  OleCheck(SHGetMalloc(Malloc));
  OleCheck(SHGetDesktopFolder(Root));
  OleCheck(Root.ParseDisplayName(0, NIL, PWideChar(WideString(Directory)), chEaten, FolderPidl, dwAttributes));
  try
    OleCheck(Root.BindToObject(FolderPidl, NIL, IShellFolder, Pointer(Folder)));
    FileCount := Files.Count;
    p := AllocMem(SizeOf(PItemIDList) * FileCount);
    try
      for i := 0 to FileCount - 1 do
      begin
        OleCheck(Folder.ParseDisplayName(0, NIL, PWideChar(WideString(Files[i])), chEaten, p^[i], dwAttributes));
      end;
      OleCheck(Folder.GetUIObjectOf(0, FileCount, p^[0], IDataObject, NIL, Pointer(Result)));
    finally
      for i := 0 to FileCount - 1 do
      begin
//        if p^[i] &lt;&gt; nil then
        if p^[i] = NIL then
          Malloc.Free(p^[i]);
      end;
      FreeMem(p);
    end;
  finally
    Malloc.Free(FolderPidl);
  end;
end;

// Senden an... es wird die Microsoft-Funktion "Send To�" simuliert
procedure TFreePDF64_Form.Sendenan1Click(Sender: TObject);
var
  SelFileList: TStrings;
  DataObject: IDataObject;
  Effect, i: Integer;
  CLSID_SendMail: TGUID;
  DT: IDropTarget;
  P: TPoint;
  F: TextFile;
  m: Array [0..255] of String;
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  if (LMDShellList1.Focused and (LMDShellList1.SelCount = 0)) or (LMDShellList2.Focused and (LMDShellList2.SelCount = 0) )then
  begin
    MessageDlgCenter('Markierte Datei(en) versenden: Bitte Datei(en) ausw�hlen!', mtInformation, [mbOk]);
    Exit;
  end;

  Memo1.Lines.Clear;

  CLSID_SendMail := StringToGUID('{9E56BE60-C50F-11CF-9A2C-00A0C90A90CE}');
  // Wenn eine Datei ausgew�hlt ist, dann...
  if LMDShellList1.Focused and (LMDShellList1.SelCount > 0) then
  with LMDShellList1 do
    begin
      SelFileList := TStringList.Create;
      try
        SelFileList.Capacity := SelCount;
        for i := 0 to SelCount - 1 do
        begin
           SelFileList.Add(SelectedItems[i].DisplayName);
           m[i] := SelectedItems[i].DisplayName;
           Memo1.Lines.Text := Memo1.Lines.Text + 'Senden folgender Datei(en): ' +
                               IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) +
                               SelectedItems[i].DisplayName + #13;
        end;
        DataObject := GetFileListDataObject(LMDShellFolder1.ActiveFolder.PathName, SelFileList);
      finally
        SelFileList.Free;
      end;
      Effect := DROPEFFECT_NONE;
      CoCreateInstance(CLSID_SendMail, NIL, CLSCTX_ALL, IDropTarget, DT);
      DT.DragEnter(DataObject, MK_LBUTTON, P, Effect);
      DT.Drop(DataObject, MK_LBUTTON, P, Effect);
    end;

  if LMDShellList2.Focused and (LMDShellList2.SelCount > 0) then
    with LMDShellList2 do
    begin
      SelFileList := TStringList.Create;
      try
        SelFileList.Capacity := SelCount;
        for i := 0 to SelCount - 1 do
        begin
           SelFileList.Add(SelectedItems[i].DisplayName);
           m[i] := SelectedItems[i].DisplayName;
           Memo1.Lines.Text := Memo1.Lines.Text + 'Senden folgender Datei(en): ' +
                               IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) +
                               SelectedItems[i].DisplayName + #13;
        end;
        DataObject := GetFileListDataObject(LMDShellFolder2.ActiveFolder.PathName, SelFileList);
      finally
        SelFileList.Free;
      end;
      Effect := DROPEFFECT_NONE;
      CoCreateInstance(CLSID_SendMail, NIL, CLSCTX_ALL, IDropTarget, DT);
      DT.DragEnter(DataObject, MK_LBUTTON, P, Effect);
      DT.Drop(DataObject, MK_LBUTTON, P, Effect);
    end;

    // FreePDF64Log.txt
    if Logdatei.Checked then
    begin
      // Logdatei (FreePDF64Log.txt) �ffnen/beschreiben etc.
      AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
      try
        Append(F);
      except
        Rewrite(F)
      end;
      if LMDShellList1.Focused and (LMDShellList1.SelCount > 0) then
      begin
        for i := 0 to LMDShellList1.SelCount - 1 do
        begin
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ==========> Senden von: ' + IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) + m[i]));
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) +
                  LMDShellList1.SelectedItems[i].DisplayName))));
        end;
        Closefile(F)
      end else
      if LMDShellList2.Focused and (LMDShellList2.SelCount > 0) then
      begin
        for i := 0 to LMDShellList2.SelCount - 1 do
        begin
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ==========> Senden von: ' + IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + m[i]));
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) +
                  LMDShellList2.SelectedItems[i].DisplayName))));
        end;
        Closefile(F);
      end;
    end;
end;

// Beide Baumstrukturen anzeigen
procedure TFreePDF64_Form.ShowFolders1Click(Sender: TObject);
begin
  // Show Folders Pane
  if ShowFolders1.Checked then
  begin
    ShowFolders1.Checked := False;
    ShowFolders_Left.Checked := False;
    Splitter1.Visible := false;
    Splitter4.Visible := false;
    LMDShellTree1.Visible := false;
    LMDShellTree2.Visible := false;
    Panel_Left.Visible := false;
    Panel_Right.Visible := false;
    Panel2.Visible := false;
    Panel3.Visible := false;
  end else
  begin
    ShowFolders1.Checked := True;
    ShowFolders_Left.Checked := False;
    Splitter1.Visible := True;
    Splitter4.Visible := True;
    LMDShellTree1.Visible := True;
    LMDShellTree2.Visible := True;
    Panel_Left.Visible := True;
    Panel_Right.Visible := True;
    Panel2.Visible := True;
    Panel3.Visible := True;
  end;

  Quelllabel.Caption := 'Quelle - ' + MinimizeName(IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName), FreePDF64_Form.Canvas,
                                      Quelllabel.Width - (FavSpL.Width + FavLinks.Width + ParentFolderL.Width + QuellBtn.Width + ComboBoxL.Width + 100));
  Ziellabel.Caption := 'Ziel - ' + MinimizeName(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName),
                                   FreePDF64_Form.Canvas, Ziellabel.Width - (FavSpR.Width + FavRechts.Width +
                                   ParentFolderR.Width + ZielBtn.Width + ComboBoxR.Width + 100))
end;

// Nur linke Baumstruktur anzeigen
procedure TFreePDF64_Form.ShowFolders_LeftClick(Sender: TObject);
begin
  // Show Folders Pane
  if ShowFolders1.Checked then
  begin
    ShowFolders1.Checked := False;
    ShowFolders_Left.Checked := False;
    Splitter1.Visible := false;
    Splitter4.Visible := false;
    LMDShellTree1.Visible := false;
    LMDShellTree2.Visible := false;
    Panel_Left.Visible := false;
    Panel_Right.Visible := false;
    Panel2.Visible := false;
    Panel3.Visible := false;
  end;
  // Show Folders Pane
  if ShowFolders_Left.Checked then
  begin
    ShowFolders_Left.Checked := false;
    Splitter1.Visible := false;
    LMDShellTree1.Visible := false;
    Panel_Left.Visible := false;
    Panel2.Visible := false;
  end else
  begin
    ShowFolders_Left.Checked := True;
    Splitter1.Visible := True;
    LMDShellTree1.Visible := True;
    Panel_Left.Visible := True;
    Panel2.Visible := True;
  end;

  Quelllabel.Caption := 'Quelle - ' + MinimizeName(IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName), FreePDF64_Form.Canvas,
                                      Quelllabel.Width - (FavSpL.Width + FavLinks.Width + ParentFolderL.Width + QuellBtn.Width + ComboBoxL.Width + 100));
end;

procedure TFreePDF64_Form.Zielverzeichnisanzeigen1Click(Sender: TObject);
begin
  Zielverzeichnisanzeigen1.Checked := not Zielverzeichnisanzeigen1.Checked;
  LMDShellList2.Visible := Zielverzeichnisanzeigen1.Checked;
  PanelR.Visible := Zielverzeichnisanzeigen1.Checked;
  Splitter2.Visible := Zielverzeichnisanzeigen1.Checked;
  Splitter4.Visible := Zielverzeichnisanzeigen1.Checked;
  if Zielverzeichnisanzeigen1.Checked = False then
  begin
    Beide_FolderBtn.Visible := False;
    ShowFolders1.Visible    := False;
  end else
  begin
    Beide_FolderBtn.Visible := True;
    ShowFolders1.Visible    := True;
  end;
end;

procedure TFreePDF64_Form.ZielverzeichnisimExplorerffnen1Click(Sender: TObject);
var
  APath: String;
begin
  APath := Ziel;
  ShellExecute(Handle, NIL, PChar('explorer'), PChar(APath), NIL, SW_Show);
end;

// Schnellzugriffsliste schlie�en!
procedure TFreePDF64_Form.FavClose;
begin
  if FreePDF64_Form.FavLbL.Visible then
    FreePDF64_Form.FavLbL.Visible := False;

	if FreePDF64_Form.FavLbR.Visible then
      FreePDF64_Form.FavLbR.Visible := False;
end;

// Alle wichtigen Einstellungen in die FreePDF64.ini abspeichern...
procedure TFreePDF64_Form.AllesSpeichern;
var
  i: Integer;
  IniDat: TIniFile;
  IniFile: String;
begin
  IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
  IniDat := TIniFile.Create(IniFile);
  // Speichere beim Beenden des Programmes wichtige Daten in die 'FreePDF64.ini'
  with IniDat do
  begin
    WriteInteger('Position', 'Left', FreePDF64_Form.Left);
    WriteInteger('Position', 'Top', FreePDF64_Form.Top);
    WriteInteger('Position', 'Width', FreePDF64_Form.Width);
    WriteInteger('Position', 'Height', FreePDF64_Form.Height);
    WriteInteger('Position', 'Left Tree Width', Panel_Left.Width);
    WriteInteger('Position', 'Right Tree Width', Panel_Right.Width);
    WriteInteger('Position', 'Right Panel Width', PanelR.Width);
    WriteInteger('Position', 'Memo Panel Height', PDFPanel.Height);
    WriteString('Folder', 'Left', IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName));
    A_S := IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName);
    WriteString('Folder', 'Target', IncludeTrailingBackslash(Ziel));
    B_Z := IncludeTrailingBackslash(Ziel);
    WriteBool('Folder', 'Gridlines', LMDShellList1.GridLines);
    WriteBool('Folder', 'Gridlines', LMDShellList2.GridLines);
    WriteBool('Folder', 'ResizeEqual', ResizeEqual.Checked);
    WriteBool('Folder', 'Autosize Name', AutoSpalte.Checked);
    WriteBool('Folder', 'ShowHidden', VersteckteDateienanzeigen1.Checked);
    WriteBool('Start', 'Logdatei', Logdatei.Checked);
    WriteBool('Start', 'ShowFolders', ShowFolders1.Checked);
    WriteBool('Start', 'ShowFolders Left', ShowFolders_Left.Checked);
    WriteBool('Start', 'TargetView', Zielverzeichnisanzeigen1.Checked);
    WriteBool('Start', 'Tray', InDenTray.Checked);
    WriteBool('Start', 'Splashscreen', Splash1.Checked);
    WriteBool('Start', 'Minimize', KlickaufX.Checked);
    WriteBool('Start', 'Autostart', Autostart.Checked);
    WriteBool('Start', 'Create with DoubleClick', DoppelK.Checked);
    WriteBool('Start', 'Create Formatfolder', Formatverz.Checked);
    WriteBool('Start', 'Create Formatfolder with Date', Formatverz_Date.Checked);
    WriteBool('Start', 'Create Formatfolder only Date', Formatverz_OnlyDate.Checked);
    WriteString('Start', 'Watermark/Stamp', Wasserzeichen_Form.Edit1.Text);
    WriteBool('Start', 'Watermark bg', Wasserzeichen_Form.bgWatermark.Checked);
    WriteBool('Start', 'Stamp fg', Wasserzeichen_Form.vgStamp.Checked);
    // Linke, rechte Column-Breite schreiben
    WriteInteger('Start', 'ColumnsL Width0', LMDShellList1.Column[0].Width);
    WriteInteger('Start', 'ColumnsL Width1', LMDShellList1.Column[1].Width);
    WriteInteger('Start', 'ColumnsL Width2', LMDShellList1.Column[2].Width);
    WriteInteger('Start', 'ColumnsL Width3', LMDShellList1.Column[3].Width);
    WriteInteger('Start', 'ColumnsR Width0', LMDShellList2.Column[0].Width);
    WriteInteger('Start', 'ColumnsR Width1', LMDShellList2.Column[1].Width);
    WriteInteger('Start', 'ColumnsR Width2', LMDShellList2.Column[2].Width);
    WriteInteger('Start', 'ColumnsR Width3', LMDShellList2.Column[3].Width);
    WriteInteger('Start', 'Counter', Counter);

    // Filter schreiben
    IniDat.EraseSection('Filter');
    if Filter_Form.FilterCB.Items.Count > 0 then
      for i := 1 to Filter_Form.FilterCB.Items.Count do
        WriteString('Filter', 'Filter' + IntToStr(i - 1),
          Filter_Form.FilterCB.Items[i - 1]);
  end;
  // Speicher wird wieder freigeben
  IniDat.Free;
end;

procedure TFreePDF64_Form.Speichern1Click(Sender: TObject);
begin
  if FileExists(IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) + 'FreePDF64.ini') then
    if MessageDlgCenter('Einstellungen speichern?' + #13 + #13 +
      'Gespeichert wird alles, au�er dem Schnellzugriff und der History!' + #13 +
      'Diese werden automatisch beim Beenden von FreePDF64 gespeichert.', mtInformation,
      [mbYes, mbNo]) = mrYes then
        // AllesSpeichern aufrufen...
        AllesSpeichern;
end;

// Gespeichert wird nur die Position des Fensters
procedure TFreePDF64_Form.Positionspeichern1Click(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile: String;
begin
  if MessageDlgCenter('Fensterposition speichern?', mtInformation, [mbYes, mbNo]) = mrYes then
  begin
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
    IniDat := TIniFile.Create(IniFile);
    // Speichere beim Beenden des Programmes wichtige Daten in die 'FreePDF64.ini'
    with IniDat do
    begin
      WriteInteger('Position', 'Left', FreePDF64_Form.Left);
      WriteInteger('Position', 'Top', FreePDF64_Form.Top);
    end;
    // Speicher wird wieder freigeben
    IniDat.Free;
  end;
end;

// Eigenschaften anzeigen mit Druck auf Leertaste
procedure TFreePDF64_Form.PropertiesBtnClick(Sender: TObject);
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  if LMDShellList1.Focused and (LMDShellList1.IsEditing = false) then
    LMDShellList1.ShowProperties
  else if LMDShellList2.Focused and (LMDShellList2.IsEditing = false) then
    LMDShellList2.ShowProperties;
end;

procedure TFreePDF64_Form.QuelllabelMouseEnter(Sender: TObject);
begin
  Quelllabel.Hint := IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName);
end;

procedure TFreePDF64_Form.RefreshBtClick(Sender: TObject);
begin
  FavClose;
  LMDShellFolder1.ActiveFolder.Refresh;
  LMDShellFolder2.ActiveFolder.Refresh;
  LMDShellTree1.Refresh;
  LMDShellList1.Refresh;
  LMDShellList2.Refresh;
  LMDShellList1.RefreshData;
  LMDShellList2.RefreshData;
  SB_Left;
  SB_Right;
end;

procedure TFreePDF64_Form.Systemsteuerungaufrufen1Click(Sender: TObject);
begin
  LMDShellAppletLoader1.Applet := cplControlPanel;
  LMDShellAppletLoader1.Execute;
end;

procedure TFreePDF64_Form.TaskManager1Click(Sender: TObject);
begin
  ShellExecute(HWND(NIL), 'open', 'taskmgr', '', '', SW_SHOWNORMAL);
end;

// Fenster angleichen
procedure TFreePDF64_Form.AngleichenTBClick(Sender: TObject);
begin
  FavClose;
  if LMDShellList1.Focused then
    LMDShellFolder2.RootFolder := LMDShellFolder1.ActiveFolder.PathName
  else
    LMDShellFolder1.RootFolder := LMDShellFolder2.ActiveFolder.PathName;
  SB_Left;
  SB_Right;
end;

// Fenster tauschen
procedure TFreePDF64_Form.TauschenTBClick(Sender: TObject);
var
  L, R: String;
begin
  FavClose;
  L := LMDShellFolder1.ActiveFolder.PathName;
  R := LMDShellFolder2.ActiveFolder.PathName;
  LMDShellFolder1.RootFolder := R;
  LMDShellFolder2.RootFolder := L;
  SB_Left;
  SB_Right;
end;

procedure TFreePDF64_Form.Timer1Timer(Sender: TObject);
begin
  FormatBtn.Enabled := not FormatBtn.Enabled;
  Feedback.Enabled  := not Feedback.Enabled;
end;

// Nach dem Start von FreePDF64 wird die Hauptform kurz angezeigt - und danach geht sie in den Tray
procedure TFreePDF64_Form.Timer2Timer(Sender: TObject);
begin
  TrayIcon1.Visible := True;
  FreePDF64_Form.Hide;
  Timer2.Enabled    := False;
end;

procedure TFreePDF64_Form.SearchBtnClick(Sender: TObject);
begin
  Suche_Form.Show;
end;

// Ist Verzeichnis leer?
function IsEmptyFolder(const AsFolder : string) : boolean;
var
  sr : TSearchRec;
begin
  Result := FindFirst(AsFolder + '\*.*', faAnyFile, sr) = 0;
  if not Result then Exit;
  repeat
    if (sr.Name <> '.') and (sr.Name <> '..') and (sr.Attr and faVolumeID = 0) then
    begin
      Result := False;
      Break;
    end;
  until FindNext(sr) <> 0;
  FindClose(sr);
end;

// Anlagen zu einer PDF-Datei anzeigen
procedure TFreePDF64_Form.PDFAttachmentClick(Sender: TObject);
var
  i, j: Integer;
  PDFDatei, Zeile: String;
  ProcID: Cardinal;
  F: TextFile;
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  if not FileExists(XPDF_Detach) then
  begin
    MessageDlgCenter('Achtung: Die Datei "pdfdetach.exe" fehlt im Ordner "' + IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + '"!', mtError, [mbOk]);
    Exit;
  end;

  Memo1.Clear;

  if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
  begin
    for i := 0 to LMDShellList1.SelCount - 1 do
    begin
      RunDosInMemo(XPDF_Detach + ' -list "' + IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) +
                   LMDShellList1.SelectedItems[i].DisplayName + '"', Memo1);
      PDFDatei := IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) + LMDShellList1.SelectedItems[i].DisplayName + '"';
      Zeile := XPDF_Detach + ' -saveall -o "' + ExcludeTrailingPathDelimiter(Ziel) + '" "' + PDFDatei;
    end
  end else
  begin
    MessageDlgCenter('Anlage(n) extrahieren: Bitte EINE PDF-Datei aus dem Quellverzeichnis ausw�hlen!', mtInformation, [mbOk]);
    Exit;
  end;

  // = Nun Anlagen ins Zielverzeichnis speichern ===============
  // Starte die Erstellung...
  ProcID := 0;
  // Bei Fehler -> Exit
  if RunProcess(Zeile, SW_HIDE, True, @ProcID) <> 0 then
    Exit
  else
  if RunProcess(Zeile, SW_HIDE, True, @ProcID) = 0 then
  begin
    if IsEmptyFolder(Ziel) then
    begin
      MessageDlgCenter('Fehler beim Extrahieren der Anlage(n) aus der Datei: "' + ExtractFileName(PDFDatei) + '.' + #13 +
                       'Vermutlich enth�lt die PDF-Datei keine Anlage(n)?!', mtError, [mbOk]);
      Exit;
    end;

    // FreePDF64Log.txt
    if Logdatei.Checked and (Memo1.lines[0] <> '0 embedded files') then
    begin
      // Logdatei (FreePDF64Log.txt) �ffnen/beschreiben etc.
      AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
      try
        Append(F);
      except
        Rewrite(F)
      end;
      PDFDatei := ExtractFileName(PDFDatei);
      Delete(PDFDatei, Length(PDFDatei), 1);

      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' => Anlage(n) speichern: ' + Zeile));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName)));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + PDFDatei));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName)));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -   Anzahl der Anlagen: ' + Memo1.lines[0]));
      for j := 1 to Memo1.Lines.Count - 1 do
      begin
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -             Anlage_' + Memo1.lines[j]));
      end;
      Closefile(F);
    end;
    if Memo1.lines[0] = '0 embedded files' then
    begin
      MessageDlgCenter('Fehler beim Extrahieren der Anlage(n) aus der Datei: "' + ExtractFileName(PDFDatei) + '.' + #13 +
                       'Vermutlich enth�lt die PDF-Datei keine Anlage(n)?!', mtError, [mbOk]);
      Exit;
    end;
    if Einstellungen_Form.SystemklangCB.Checked then
      PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');
  end;

  if Memo1.Lines.Count > 1 then
  begin
    i:= TextHoehe(Memo1.Font, Memo1.Text);
    i := (i * Memo1.Lines.Count) + MHA;
    if i < Memo1.Parent.Height then
      Exit;
    PDFPanel.Height := i;
  end;
end;

// PDF-Informationen anzeigen
procedure TFreePDF64_Form.PDFInfoBtnClick(Sender: TObject);
var
  i: Integer;
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  if not FileExists(XPDF_Info) then
  begin
    MessageDlgCenter('Achtung: Die Datei "pdfinfo.exe" fehlt im Ordner "' + IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + '"!', mtError, [mbOk]);
    Exit;
  end;

  Memo1.Clear;

  if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
    for i := 0 to LMDShellList1.SelCount - 1 do
      RunDosInMemo(XPDF_Info + ' -box -custom "' + IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) +
                   LMDShellList1.SelectedItems[i].DisplayName + '"', Memo1)
  else if LMDShellList2.Focused and (LMDShellList2.SelCount = 1) then
    for i := 0 to LMDShellList2.SelCount - 1 do
      RunDosInMemo(XPDF_Info + ' -box -custom "' + IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) +
                   LMDShellList2.SelectedItems[i].DisplayName + '"', Memo1)
  else
  begin
    MessageDlgCenter('Informationen zu einer PDF-Datei anzeigen: Bitte EINE PDF-Datei aus dem Quellverzeichnis ausw�hlen!', mtInformation, [mbOk]);
    Exit;
  end;

  if Memo1.Lines.Count > 1 then
  begin
    i:= TextHoehe(Memo1.Font, Memo1.Text);
    i := (i * Memo1.Lines.Count) + MHA;
    if i < Memo1.Parent.Height then
      Exit;
    PDFPanel.Height := i;
  end;
end;

// PDF-Font-Informationen anzeigen
procedure TFreePDF64_Form.PDFFontsBtnClick(Sender: TObject);
var
  i: Integer;
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  if not FileExists(XPDF_Fonts) then
  begin
    MessageDlgCenter('Achtung: Die Datei "pdffonts.exe" fehlt im Ordner "' + IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + '"!', mtError, [mbOk]);
    Exit;
  end;

  Memo1.Clear;

  if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
    for i := 0 to LMDShellList1.SelCount - 1 do
      RunDosInMemo(XPDF_Fonts + ' -loc "' + IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) +
                   LMDShellList1.SelectedItems[i].DisplayName + '"', Memo1)
  else if LMDShellList2.Focused and (LMDShellList2.SelCount = 1) then
    for i := 0 to LMDShellList2.SelCount - 1 do
      RunDosInMemo(XPDF_Fonts + ' -loc "' + IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) +
                   LMDShellList2.SelectedItems[i].DisplayName + '"', Memo1)
  else
  begin
    MessageDlgCenter('Die Schriftarten in der PDF-Datei werden aufgelistet: Bitte EINE PDF-Datei aus dem Quellverzeichnis ausw�hlen!', mtInformation, [mbOk]);
    Exit;
  end;

  if Memo1.Lines.Count > 1 then
  begin
    i:= TextHoehe(Memo1.Font, Memo1.Text);
    i := (i * Memo1.Lines.Count) + MHA;
    if i < Memo1.Parent.Height then
      Exit;
    PDFPanel.Height := i;
  end;
end;

// PDF-Passwortschutz entfernen
procedure TFreePDF64_Form.PDFdecryptClick(Sender: TObject);
var
  PDFDatei, Zeile, Zeile2, EndPDF, Ziel, s: String;
  ProcID: Cardinal;
  F: TextFile;
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  LMDOpenDialog1.InitialDir := LMDShellFolder1.ActiveFolder.PathName;
  if LMDOpenDialog1.Execute then
    PDFDatei := LMDOpenDialog1.Filename
  else
    Exit;

  // Wenn Erstellung Formatfolder angehakt...
  if Formatverz_Date.Checked then
  begin
    // Verzeichnis erstellen der gew�nschten Endung (hier PDF + Datum)
    if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'PDF' + ' ' + DateToStr(NOW)) then
      Ziel := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'PDF' + ' ' + DateToStr(NOW)
  end else if Formatverz_OnlyDate.Checked then
  begin
    // Verzeichnis erstellen der gew�nschten Endung (Datum)
    if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + DateToStr(NOW)) then
      Ziel := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + DateToStr(NOW)
  end else if Formatverz.Checked then
  begin
    if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'PDF') then
      Ziel := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'PDF';
  end else
    if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName)) then
      Ziel := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName);

  // QPDF-Pfad => Einstellungen_Form.Edit4.Text
  Zeile  := Einstellungen_Form.Edit4.Text + ' --decrypt "' + PDFDatei + '" "' +
            IncludeTrailingBackslash(Ziel) + ExtractFileName(PDFDatei) + '"';
  EndPDF := IncludeTrailingBackslash(Ziel) + ExtractFileName(PDFDatei);
  // Starte die Erstellung...
  ProcID := 0;
  if RunProcess(Zeile, SW_HIDE, True, @ProcID) = 0 then
  begin
    Memo1.Lines.Text := Zeile;
    // FreePDF64Log.txt
    if Logdatei.Checked then
    begin
      // Logdatei (FreePDF64Log.txt) �ffnen/beschreiben etc.
      AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
      try
        Append(F);
      except
        Rewrite(F)
      end;
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ==> Passwort entfernen: ' + Zeile));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName)));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(PDFDatei)));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(PDFDatei))));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(Ziel)));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(EndPDF)));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(EndPDF))));
      Closefile(F);

      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');

      // Markierte Datei(en) mit einem Anzeigeprogramm anzeigen
      if Einstellungen_Form.AnzeigenCB.Checked then
      begin
        // Pause von 1 sec. einbauen...
        Sleep(1000);
        if Einstellungen_Form.Edit3.Text = '' then
          PDFReader := ExtractFilePath(Application.ExeName) + 'xpdf\xpdfreader\xpdf.exe'
        else
          PDFReader := Einstellungen_Form.Edit3.Text;
        ShellExecute(Application.Handle, 'open', PChar(PDFReader), PChar('"' + EndPDF + '"'), NIL, SW_SHOWNORMAL);
      end;
    end;
  end else
  // Es muss ein Passwort eingegeben werden, sonst geht das Entfernen nicht ...
  begin
    if Einstellungen_Form.SystemklangCB.Checked then
      PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');

    if MyInputQuery('Datei: ' + ExtractFileName(PDFDatei), 'Eingabe vom Passwort erforderlich:', s) then
    begin
//      Zeile2 := Einstellungen_Form.Edit4.Text + ' --decrypt --password="' + s + '" "' + PDFDatei + '" "' +
//                IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + ExtractFileName(PDFDatei) + '"';
      Zeile2 := Einstellungen_Form.Edit4.Text + ' --decrypt --password="' + s + '" "' + PDFDatei + '" "' +
                IncludeTrailingBackslash(Ziel) + ExtractFileName(PDFDatei) + '"';

      ProcID := 0;
      if RunProcess(Zeile2, SW_HIDE, True, @ProcID) = 0 then
      begin
        Memo1.Lines.Text := Zeile2;
        if Logdatei.Checked then
        begin
          AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
          try
            Append(F);
          except
           Rewrite(F)
          end;
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ==> Passwort entfernen: ' + Zeile2));
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName)));
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(PDFDatei)));
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(PDFDatei))));
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName)));
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(EndPDF)));
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(EndPDF))));
          Closefile(F);

          if Einstellungen_Form.SystemklangCB.Checked then
            PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');

          // Markierte Datei(en) mit einem Anzeigeprogramm anzeigen
          if Einstellungen_Form.AnzeigenCB.Checked then
          begin
            Sleep(1000);
            if Einstellungen_Form.Edit3.Text = '' then
              PDFReader := ExtractFilePath(Application.ExeName) + 'xpdf\xpdfreader\xpdf.exe'
            else
              PDFReader := Einstellungen_Form.Edit3.Text;
            ShellExecute(Application.Handle, 'open', PChar(PDFReader), PChar('"' + EndPDF + '"'), NIL, SW_SHOWNORMAL);
          end;
        end;
      end else
      begin
        if Einstellungen_Form.SystemklangCB.Checked then
          PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
        ShowMessage('Passwort falsch - bitte erneut versuchen...');
      end;
    end;
  end;
end;

procedure TFreePDF64_Form.Linker_FolderBtnClick(Sender: TObject);
begin
  FavClose;
  ShowFolders_Left.Click;
end;

procedure TFreePDF64_Form.Image1Click(Sender: TObject);
begin
  if Image1.Proportional then
    Image1.Proportional := False
  else
    Image1.Proportional := True;
end;

procedure TFreePDF64_Form.InDenTrayClick(Sender: TObject);
begin
  if InDenTray.Checked then
    InDenTray.Checked := False
  else
    InDenTray.Checked := True;
end;

procedure TFreePDF64_Form.Splash1Click(Sender: TObject);
begin
  if Splash1.Checked then
  begin
    Splash1.Checked := False;
    Tray1 := True;
  end else
  begin
    Splash1.Checked := True;
    Tray1 := False;
  end;
end;

// Einfacher Klick auf TrayIcon
procedure TFreePDF64_Form.TrayIcon1Click(Sender: TObject);
begin
  ShowVomTray := True;
  FreePDF64_Form.Show;
  Application.BringToFront;
  LMDShellList1.SetFocus;

  // Hide the tray icon and show the window, setting its state property to wsNormal
  TrayIcon1.Visible := False;

  if AutoSpalteJN then
  begin
    AutoSpalte.Checked := True;
    LMDShellList1.Column[0].AutoSize := True;
    LMDShellList2.Column[0].AutoSize := True;
  end else
    AutoSpalte.Checked := False;

  WindowState := wsNormal;
  FreePDF64_Form.BringToFront;
end;

procedure TFreePDF64_Form.TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  MZiel: String;
begin
  if not FreePDF64_Notify.Ziel_FestCB.Checked then
    MZiel := Ziel
  else
    MZiel := FreePDF64_Notify.ZielEdit.Text;

  // RMB zeigt die beiden wichtigen Verzeichnisse an
  if Button = mbRight then
  begin
    PopupMenu3.Items.Items[0].ImageIndex := MonitorBtn.ImageIndex;
    PopupMenu3.Items.Items[1].Caption := FreePDF64_Notify.MonitoringFolder.Text;
    PopupMenu3.Items.Items[2].Caption := MZiel;
  end;
end;

procedure TFreePDF64_Form.EditorClick(Sender: TObject);
begin
  Editoraufrufen1.Click;
end;

procedure TFreePDF64_Form.Btn_CopyClick(Sender: TObject);
begin
  if Btn_Copy.Caption = 'F5 Kopieren' then
    Kopieren1.Click
  else
    CopyTo.Click;
  LMDShellList1.ClearSelection;
  LMDShellList2.ClearSelection;

  Btn_Copy.Caption := 'F5 Kopieren';
  Btn_Move.Caption := 'F6 Bewegen';
end;

procedure TFreePDF64_Form.Btn_MoveClick(Sender: TObject);
begin
  if Btn_Move.Caption = 'F6 Bewegen' then
    Bewegen1.Click
  else
    MoveTo.Click;
  LMDShellList1.ClearSelection;
  LMDShellList2.ClearSelection;

  Btn_Copy.Caption := 'F5 Kopieren';
  Btn_Move.Caption := 'F6 Bewegen';
end;

// Ermittlung des Betriebssystems
function OperatingSystemDisplayName: string;

  function GetWMIObject(const objectName: string): IDispatch;
  var
    chEaten: Integer;
    BindCtx: IBindCtx;
    Moniker: IMoniker;
  begin
    OleCheck(CreateBindCtx(0, bindCtx));
    OleCheck(MkParseDisplayName(BindCtx, PChar(objectName), chEaten, Moniker));
    OleCheck(Moniker.BindToObject(BindCtx, nil, IDispatch, Result));
  end;

  function VarToString(const Value: OleVariant): string;
  begin
    if VarIsStr(Value) then begin
      Result := Trim(Value);
    end else begin
      Result := '';
    end;
  end;

  function FullVersionString(const Item: OleVariant): string;
  var
    Caption, ServicePack, Version: string;
  begin
    Caption := VarToString(Item.Caption);
    ServicePack := VarToString(Item.CSDVersion);
    Version := VarToString(Item.Version);
    Result := Caption;
    if ServicePack <> '' then begin
      Result := Result + ' ' + ServicePack;
    end;
//    Result := Result + ', version ' + Version + ', ';
  end;

var
  objWMIService: OleVariant;
  colItems: OleVariant;
  Item: OleVariant;
  oEnum: IEnumvariant;
  iValue: LongWord;
begin
  Try
    objWMIService := GetWMIObject('winmgmts:\\localhost\root\cimv2');
    colItems := objWMIService.ExecQuery('SELECT Caption, CSDVersion, Version FROM Win32_OperatingSystem', 'WQL', 0);
    oEnum := IUnknown(colItems._NewEnum) as IEnumVariant;
    if oEnum.Next(1, Item, iValue) = 0 then begin
      Result := FullVersionString(Item);
      exit;
    end;
  Except
    // yes, I know this is nasty, but come what may I want to use the fallback code below should the WMI code fail
  End;
  (* Fallback, relies on the deprecated function GetVersionEx, reports erroneous values
     when manifest does not contain supportedOS matching the executing system *)
  Result := TOSVersion.ToString;
end;

procedure TFreePDF64_Form.Btn_RenameClick(Sender: TObject);
var
  i: Integer;
begin
  if (LMDShellList1.Focused and Assigned(LMDShellList1.Selected)) = True then
  begin
    if not DirectoryExists(LMDShellList1.SelectedItem.PathName) then
    begin
      keybd_event(VK_HOME,  MapVirtualKey(VK_HOME, 0),  KEYEVENTF_EXTENDEDKEY, 0); // HOME dr�cken
      keybd_event(VK_HOME,  MapVirtualKey(VK_HOME, 0),  KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0); // HOME loslassen
      keybd_event(VK_SHIFT, MapVirtualKey(VK_SHIFT, 0), KEYEVENTF_EXTENDEDKEY, 0); // Shift dr�cken
      keybd_event(VK_END,   MapVirtualKey(VK_END, 0),   KEYEVENTF_EXTENDEDKEY, 0); // END dr�cken
      for i := 0 to Length(LMDShellList1.SelectedItem.Extension) - 1 do
      begin
        keybd_event(VK_LEFT, MapVirtualKey(VK_LEFT, 0), KEYEVENTF_EXTENDEDKEY, 0);
        keybd_event(VK_LEFT, MapVirtualKey(VK_LEFT, 0), KEYEVENTF_EXTENDEDKEY, 0);
        keybd_event(VK_LEFT, MapVirtualKey(VK_LEFT, 0), KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
        keybd_event(VK_LEFT, MapVirtualKey(VK_LEFT, 0), KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
      end;
      keybd_event(VK_END,   MapVirtualKey(VK_END, 0),   KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0); // END loslassen
      keybd_event(VK_SHIFT, MapVirtualKey(VK_SHIFT, 0), KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0); // Shift loslassen
    end;
    LMDShellList1.Selected.EditCaption;
  end;
  if (LMDShellList2.Focused and Assigned(LMDShellList2.Selected)) = True then
  begin
    if not DirectoryExists(LMDShellList2.SelectedItem.PathName) then
    begin
      keybd_event(VK_HOME,  MapVirtualKey(VK_HOME, 0),  KEYEVENTF_EXTENDEDKEY, 0); // HOME dr�cken
      keybd_event(VK_HOME,  MapVirtualKey(VK_HOME, 0),  KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0); // HOME loslassen
      keybd_event(VK_SHIFT, MapVirtualKey(VK_SHIFT, 0), KEYEVENTF_EXTENDEDKEY, 0); // Shift dr�cken
      keybd_event(VK_END,   MapVirtualKey(VK_END, 0),   KEYEVENTF_EXTENDEDKEY, 0); // END dr�cken
      for i := 0 to Length(LMDShellList2.SelectedItem.Extension) - 1 do
      begin
        keybd_event(VK_LEFT, MapVirtualKey(VK_LEFT, 0), KEYEVENTF_EXTENDEDKEY, 0);
        keybd_event(VK_LEFT, MapVirtualKey(VK_LEFT, 0), KEYEVENTF_EXTENDEDKEY, 0);
        keybd_event(VK_LEFT, MapVirtualKey(VK_LEFT, 0), KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
        keybd_event(VK_LEFT, MapVirtualKey(VK_LEFT, 0), KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0);
      end;
      keybd_event(VK_END,   MapVirtualKey(VK_END, 0),   KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0); // END loslassen
      keybd_event(VK_SHIFT, MapVirtualKey(VK_SHIFT, 0), KEYEVENTF_EXTENDEDKEY or KEYEVENTF_KEYUP, 0); // Shift loslassen
    end;
    LMDShellList2.Selected.EditCaption;
  end;
end;

// Task schlie�en (hier Ghostscript)
procedure KillTask(ExeFileName: string);
var
  h: HWnd;
begin // ExeFileName = caption or cmd path
  h := FindWindow(NIL, LPCWSTR(ExeFileName));
  if h <> 0 then
    PostMessage(h, WM_CLOSE, 0, 0);
end;

// JPEG richtig drehen!
procedure RotateJPEGImage(const AFileName: string; AImage: TImage);
var
  GPImage: TGPImage;
  GPGraphics: TGPGraphics;
  pPropItem: PPropertyItem;
  BufferSize: Cardinal;
  Orientation: Byte;
  RotateType: TRotateFlipType;
  W, H: Integer;
  Ratio: Double;
begin
  GPImage:= TGPImage.Create(AFileName);
  try
    BufferSize := GPImage.GetPropertyItemSize(PropertyTagOrientation);
    if BufferSize > 0 then
    begin
      GetMem(pPropItem, BufferSize);
      GPImage.GetPropertyItem(PropertyTagOrientation, BufferSize, pPropItem);
      Orientation := PByte(pPropItem.Value)^;
      case Orientation of
        1: RotateType := RotateNoneFlipNone; // Horizontal - No rotation required
        2: RotateType := RotateNoneFlipX;
        3: RotateType := Rotate180FlipNone;
        4: RotateType := Rotate180FlipX;
        5: RotateType := Rotate90FlipX;
        6: RotateType := Rotate90FlipNone;
        7: RotateType := Rotate270FlipX;
        8: RotateType := Rotate270FlipNone;
        else
          RotateType := RotateNoneFlipNone; // Unknown rotation?
      end;
      if RotateType <> RotateNoneFlipNone then
        GPImage.RotateFlip(RotateType);
    end;

    // Berechne das Verh�ltnis f�r die Anzeige
    Ratio := GPImage.GetWidth / AImage.Width;
    if Ratio < GPImage.GetHeight / AImage.Height then
      Ratio := GPImage.GetHeight / AImage.Height;
    W := Round(GPImage.GetWidth / Ratio);
    H := Round(GPImage.GetHeight / Ratio);

    // L�sche das aktuelle Bild in der TImage-Komponente
    AImage.Picture.Assign(nil);
    AImage.Width := W;
    AImage.Height := H;

    // Zeichne das gedrehte Bild auf die TImage-Komponente
    GPGraphics := TGPGraphics.Create(AImage.Canvas.Handle);
    try
      GPGraphics.DrawImage(GPImage, 0, 0, W, H);
    finally
      GPGraphics.Free;
    end;
  finally
    GPImage.Free;
  end;
end;

// PS/PDF-Dateien anschauen mit Ghostscript oder dem XPDFReader
procedure TFreePDF64_Form.Btn_ViewClick(Sender: TObject);
var
  Param, XPDFReader: String;
begin
  if Einstellungen_Form.Edit3.Text = '' then
    Einstellungen_Form.Edit3.Text := ExtractFilePath(Application.ExeName) + 'xpdf\xpdfreader\xpdf.exe';
  XPDFReader := Einstellungen_Form.Edit3.Text;
  PDFReader  := XPDFReader;

  if (LMDShellList1.Focused and Assigned(LMDShellList1.Selected)) = True then
      Auswahl := LMDShellList1.SelectedItem.PathName
  else
    if (LMDShellList2.Focused and Assigned(LMDShellList2.Selected)) = True then
      Auswahl := LMDShellList2.SelectedItem.PathName;

  // JPEG anzeigen
  if Image1.Visible then
  begin
    Image1.Visible := False;
    Image1.Picture := NIL;
    LMDShellList2.Visible := True;
    Exit;
  end else
  if Image2.Visible then
  begin
    Image2.Visible := False;
    Image2.Picture := NIL;
    LMDShellList1.Visible := True;
    Exit;
  end else

  if (LMDShellList1.Focused and Assigned(LMDShellList1.Selected)) = True then
    if (Uppercase(ExtractFileExt(Auswahl)) = ('.JPG')) or (Uppercase(ExtractFileExt(Auswahl)) = ('.JPEG')) or
       (Uppercase(ExtractFileExt(Auswahl)) = ('.BMP')) or (Uppercase(ExtractFileExt(Auswahl)) = ('.PNG')) or
       (Uppercase(ExtractFileExt(Auswahl)) = ('.TIF')) then
    begin
      LMDShellList2.Visible := False;
      Image1.Visible := True;
      Image1.Picture.LoadFromFile(Auswahl);
      Exit;
    end;
  if (LMDShellList2.Focused and Assigned(LMDShellList2.Selected)) = True then
    if (Uppercase(ExtractFileExt(Auswahl)) = ('.JPG')) or (Uppercase(ExtractFileExt(Auswahl)) = ('.JPEG')) or
       (Uppercase(ExtractFileExt(Auswahl)) = ('.BMP')) or (Uppercase(ExtractFileExt(Auswahl)) = ('.PNG')) or
       (Uppercase(ExtractFileExt(Auswahl)) = ('.TIF')) then
    begin
      LMDShellList1.Visible := False;
      Image2.Visible := True;
      Image2.Picture.LoadFromFile(Auswahl);
      Exit;
    end;

  if not FileExists(XPDFReader) or
    (Uppercase(ExtractFileExt(Auswahl)) <> ('.PDF')) then
  // Ghostscript aufrufen...
  begin
    Ghostscript := Einstellungen_Form.Edit1.Text;
    // Wenn eine Datei ausgew�hlt ist, dann...
    if (LMDShellList1.Focused and Assigned(LMDShellList1.Selected)) = True then
    begin
      Param := '-dSAFER -dBATCH -r120 -dAutoRotatePages=/PageByPage "' + Auswahl + '"';
      Auswahl := Ghostscript + ' ' + Param;
      ShellExecute(Application.Handle, 'open', PChar(Ghostscript), PChar(Param), '', SW_HIDE);
      MessageDlgCenter('Anzeigen beendet!', mtInformation, [mbOk]);
      KillTask(Ghostscript);
    end
    else if (LMDShellList2.Focused and Assigned(LMDShellList2.Selected)) = True then
    begin
      Param := '-dSAFER -dBATCH -r120 -dAutoRotatePages=/PageByPage "' + Auswahl + '"';
      Auswahl := Ghostscript + ' ' + Param;
      ShellExecute(Application.Handle, 'open', PChar(Ghostscript), PChar(Param), '', SW_HIDE);
      MessageDlgCenter('Anzeigen beendet!', mtInformation, [mbOk]);
      KillTask(Ghostscript);
    end;
  end else
  begin
    // XPDFReader aufrufen...
    ShellExecute(Application.Handle, 'open', PChar(XPDFReader), PChar('"' + Auswahl + '"'), '', SW_NORMAL);
    KillTask(XPDFReader);
  end;
end;

// Rechtsklick auf TImage
procedure TFreePDF64_Form.Image1ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  Auswahl := LMDShellList1.SelectedItem.PathName;
  RotateJPEGImage(Auswahl, Image1);
end;

procedure TFreePDF64_Form.Image2Click(Sender: TObject);
begin
  if Image2.Proportional then
    Image2.Proportional := False
  else
    Image2.Proportional := True;
end;

procedure TFreePDF64_Form.Image2ContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  Auswahl := LMDShellList2.SelectedItem.PathName;
  RotateJPEGImage(Auswahl, Image2);
end;

procedure TFreePDF64_Form.Btn_DeleteClick(Sender: TObject);
begin
  if LMDShellList1.Focused and (LMDShellList1.SelCount > 0) then
    LMDShellList1.DeleteItems
  else if LMDShellList2.Focused and (LMDShellList2.SelCount > 0) then
    LMDShellList2.DeleteItems;

  RefreshBt.Click;
  // Einmal Taste DOWN dr�cken f�r Markierung des ersten Eintrags
  keybd_event(VK_DOWN, MapVirtualKey(VK_DOWN, 0), KEYEVENTF_EXTENDEDKEY, 0);
end;

procedure TFreePDF64_Form.AbbrechenPnClick(Sender: TObject);
begin
  AbbrechenPn.BevelOuter := BvLowered;
  if FAbbrechen = True then
    FAbbrechen := False
  else
    FAbbrechen := True;
end;

procedure TFreePDF64_Form.Aktualisieren1Click(Sender: TObject);
begin
  RefreshBt.Click;
end;

procedure TFreePDF64_Form.ComboBoxLCloseUp(Sender: TObject);
begin
  if System.SysUtils.DirectoryExists(ComboBoxL.Items[ComboBoxL.ItemIndex]) then
    LMDShellFolder1.RootFolder := ComboBoxL.Items[ComboBoxL.ItemIndex]
  else
    ComboBoxL.Items.Delete(ComboBoxL.ItemIndex);
  LMDShellList1.SetFocus;
end;

procedure TFreePDF64_Form.ComboBoxRCloseUp(Sender: TObject);
begin
  if System.SysUtils.DirectoryExists(ComboBoxR.Items[ComboBoxR.ItemIndex]) then
    LMDShellFolder2.RootFolder := ComboBoxR.Items[ComboBoxR.ItemIndex]
  else
    ComboBoxR.Items.Delete(ComboBoxR.ItemIndex);
  LMDShellList2.SetFocus;
end;

// Max. Breite der ComboBox
function MaxValueCB(Box: TComboBox): Integer;
var
  i, max: Integer;
begin
  // der Variablen max die oberste Zahl in der ComboBox zugewiesen
  max := Box.Canvas.TextWidth(Box.Items[0]);
  // for-Schleife, alle Zahlen der ComboBox werden durchgegangen
  for i := 0 to Box.Items.Count - 1 do
  begin
    // wenn eine Zahl gr��er als max ist wird diese Zahl in der Variablen max gespeichert
    if max < Box.Canvas.TextWidth(Box.Items[i]) then
      max := Box.Canvas.TextWidth(Box.Items[i]);
  end;
  // der R�ckgabewert, also die gr��te Zahl
  Result := max;
end;

procedure TFreePDF64_Form.ComboBoxLDropDown(Sender: TObject);
begin
  FavClose;
  // Keine doppelten Eintr�ge zulassen...
  if ComboBoxL.Items.IndexOf(LMDShellFolder1.ActiveFolder.PathName) = -1 then
    ComboBoxL.Items.Add(LMDShellFolder1.ActiveFolder.PathName);

  SendMessage(ComboBoxL.Handle, CB_SETDROPPEDWIDTH, MaxValueCB(ComboBoxL) + 30, 0);
end;

procedure TFreePDF64_Form.ComboBoxRDropDown(Sender: TObject);
begin
  FavClose;
  // Keine doppelten Eintr�ge zulassen...
  if ComboBoxR.Items.IndexOf(LMDShellFolder2.ActiveFolder.PathName) = -1 then
    ComboBoxR.Items.Add(LMDShellFolder2.ActiveFolder.PathName);

  SendMessage(ComboBoxR.Handle, CB_SETDROPPEDWIDTH, MaxValueCB(ComboBoxR) + 30, 0);
end;

procedure TFreePDF64_Form.ConfigBtnClick(Sender: TObject);
begin
  FavClose;
  Einstellungen_Form.Position := poMainFormCenter;
  Einstellungen1.Click;
  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers[printer.printerindex] +
    ' | Erstellte Dateien (seit Nullstellung): ' + IntToStr(Counter);
end;

procedure TFreePDF64_Form.DoppelKClick(Sender: TObject);
begin
  DoppelK.Checked := Not DoppelK.Checked;
end;

procedure TFreePDF64_Form.FormatverzClick(Sender: TObject);
begin
  Formatverz.Checked          := NOT Formatverz.Checked;
  Formatverz_Date.Checked     := False;
  Formatverz_OnlyDate.Checked := False;
end;

procedure TFreePDF64_Form.Formatverz_DateClick(Sender: TObject);
begin
  Formatverz_Date.Checked     := NOT Formatverz_Date.Checked;
  Formatverz.Checked          := False;
  Formatverz_OnlyDate.Checked := False;
end;

procedure TFreePDF64_Form.Formatverz_OnlyDateClick(Sender: TObject);
begin
  Formatverz_OnlyDate.Checked := NOT Formatverz_OnlyDate.Checked;
  Formatverz_Date.Checked     := False;
  Formatverz.Checked          := False;
end;

procedure TFreePDF64_Form.Drucker1Click(Sender: TObject);
begin
  ShowSpecialFolder(CSIDL_PRINTERS);
end;

procedure TFreePDF64_Form.ber1Click(Sender: TObject);
begin
  // Form soll mittig angezeigt werden.
  Info_Form.Position := poScreenCenter;
  Info_Form.ShowModal;
end;

procedure TFreePDF64_Form.berFreePDF641Click(Sender: TObject);
begin
  FreePDF64_Form.ber1.Click
end;

procedure TFreePDF64_Form.berwachung1Click(Sender: TObject);
begin
  // Form soll mittig angezeigt werden.
  FreePDF64_Notify.Position := poScreenCenter;
  FreePDF64_Notify.ShowModal;
end;

procedure TFreePDF64_Form.Bewegen1Click(Sender: TObject);
begin
  if LMDShellList1.Focused and (LMDShellList1.SelCount > 0) then
  begin
    LMDShellList1.CutToClipboard;
    LMDShellList2.ClearSelection;
    LMDShellList2.PasteFromClipboard;
  end
  else if LMDShellList2.Focused and (LMDShellList2.SelCount > 0) then
  begin
    LMDShellList2.CutToClipboard;
    LMDShellList1.ClearSelection;
    LMDShellList1.PasteFromClipboard;
  end;
  RefreshBt.Click;
end;

// Anzeige der Datei(en) im Editor
procedure TFreePDF64_Form.BtnEditorClick(Sender: TObject);
var
  i: Integer;
begin
  try
    // Wenn eine Datei ausgew�hlt ist, dann...
    if (LMDShellList1.Focused and Assigned(LMDShellList1.Selected)) = True then
    begin
      // Ist mindestens ein Eintrag selektiert, dann...
      for i := 0 to LMDShellList1.SelCount - 1 do
      begin
        // Der interne Editor (Notepad) oder der in die FreePDF64.ini eingetragene wird aufgerufen...
        if Einstellungen_Form.Edit2.Text = '' then
          Einstellungen_Form.Edit2.Text := 'notepad.exe';
        ShellExecute(Application.Handle, 'open',
          PChar(Einstellungen_Form.Edit2.Text),
          PChar(' "' + IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) +
          LMDShellList1.SelectedItems[i].DisplayName + '"'), NIL, SW_SHOWNORMAL)
      end;
    end else
    if (LMDShellList2.Focused and Assigned(LMDShellList2.Selected)) = True then
    begin
      for i := 0 to LMDShellList2.SelCount - 1 do
      begin
        // Der interne Editor (Notepad) oder der in die FreePDF64.ini eingetragene wird aufgerufen...
        if Einstellungen_Form.Edit2.Text = '' then
          Einstellungen_Form.Edit2.Text := 'notepad.exe';
        ShellExecute(Application.Handle, 'open',
          PChar(Einstellungen_Form.Edit2.Text),
          PChar(' "' + IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) +
          LMDShellList2.SelectedItems[i].DisplayName + '"'), NIL, SW_SHOWNORMAL)
      end;
    end;
  except
    MessageBox(0, 'Anzeigefehler', 'Problem', 16);
    Exit;
  end;
end;

procedure TFreePDF64_Form.Editor1Click(Sender: TObject);
begin
  BtnEditor.Click;
end;

procedure TFreePDF64_Form.Editoraufrufen1Click(Sender: TObject);
begin
  if Einstellungen_Form.Edit2.Text = '' then
    Einstellungen_Form.Edit2.Text := 'notepad.exe';
  // Editor aufrufen...
  ShellExecute(Application.Handle, 'open', PChar(Einstellungen_Form.Edit2.Text),
    NIL, NIL, SW_SHOWNORMAL)
end;

procedure TFreePDF64_Form.Einstellungen1Click(Sender: TObject);
begin
  // Aufruf der Einstellungen-Form
  Einstellungen_Form.ShowModal;
end;

procedure TFreePDF64_Form.Einstellungenndern2Click(Sender: TObject);
begin
  // Aufruf der Einstellungen-Form
  Einstellungen_Form.Position := poScreenCenter;
  Einstellungen_Form.ShowModal;
end;

procedure TFreePDF64_Form.Exit1Click(Sender: TObject);
begin
  Tray1 := False;
  Close;
  Application.Terminate;
end;

procedure TFreePDF64_Form.FavLbLClick(Sender: TObject);
var
  i, j, L: Integer;
  k, s: String;
begin
  for i := 0 to FavLbL.Items.Count - 1 do
    if FavLbL.Selected[i] then
      for L := 1 to Length(ListBoxL.Items[i]) do
      begin
        j := Pos('*|*', ListBoxL.Items[i]);
        if j > 0 then
        begin
          k := Copy(ListBoxL.Items[i], 0, j - 1);
          s := ListBoxL.Items[i];
          Delete(s, 1, Length(k) + 3);
          if not System.SysUtils.DirectoryExists(s) then
            ShowMessage('"' + s + '" ist nicht mehr vorhanden!');
          LMDShellFolder1.ChDir(s);
          LMDShellList1.SetFocus;
          if LMDShellList1.Selected = NIL then
            LMDShellList1.ItemIndex := 0;
          Break;
        end;
      end;
  FavLbL.Visible := False;
end;

procedure TFreePDF64_Form.FavLbLMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FavLbL.ItemIndex := FavLbL.ItemAtPos(Point(X, Y), True);
end;

procedure TFreePDF64_Form.FavLbLMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  i: Integer;
//  olh: string;
begin
  with FavLbL do
    begin
//      olh := Hint;
      i := ItemAtPos(Point(X, Y), False);
      if (i <= Items.Count - 1) then
//      begin
//        Hint := Items.Strings[i];
        FavLbL.Selected[i] := True;
//      end else
//        Hint := '';
//      if Hint <> olh then
//        Application.CancelHint;
    end;
end;

procedure TFreePDF64_Form.FavLbRClick(Sender: TObject);
var
  i, j, L: Integer;
  k, s: String;
begin
  for i := 0 to FavLbR.Items.Count - 1 do
    if FavLbR.Selected[i] then
      for L := 1 to Length(ListBoxR.Items[i]) do
      begin
        j := Pos('*|*', ListBoxR.Items[i]);
        if j > 0 then
        begin
          k := Copy(ListBoxR.Items[i], 0, j - 1);
          s := ListBoxR.Items[i];
          Delete(s, 1, Length(k) + 3);
          if not System.SysUtils.DirectoryExists(s) then
            ShowMessage('"' + s + '" ist nicht mehr vorhanden!');
          LMDShellFolder2.ChDir(s);
          LMDShellList2.SetFocus;
          if LMDShellList2.Selected = NIL then
            LMDShellList2.ItemIndex := 0;
          Break;
        end;
      end;
  FavLbR.Visible := False;
  Ziel := IncludeTrailingBackslash(s);
  Ziellabel.Caption := 'Ziel - ' + MinimizeName(IncludeTrailingBackslash(Ziel),
                       FreePDF64_Form.Canvas, Ziellabel.Width - (FavSpR.Width + FavRechts.Width +
                       ParentFolderR.Width + ZielBtn.Width + ComboBoxR.Width + 100))
end;

procedure TFreePDF64_Form.FavLbRMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FavLbR.ItemIndex := FavLbR.ItemAtPos(Point(X, Y), True);
end;

procedure TFreePDF64_Form.FavLbRMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  i: Integer;
//  olh: string;
begin
  with FavLbR do
    begin
//      olh := Hint;
      i := ItemAtPos(Point(X, Y), False);
      if (i <= Items.Count - 1) then
//      begin
//        Hint := Items.Strings[i];
        FavLbR.Selected[i] := True;
//      end else
//        Hint := '';
//      if Hint <> olh then
//        Application.CancelHint;
    end;
end;

function MaxValue(Box: TListBox): Integer;
var
  i, max: Integer;
begin
  // der Variablen max die oberste Zahl in der Listbox zugewiesen
  max := Box.Canvas.TextWidth(Box.Items[0]);
  // for-Schleife, alle Zahlen der Listbox werden durchgegangen
  for i := 0 to Box.Items.Count - 1 do
  begin
    // wenn eine Zahl gr��er als max ist wird diese Zahl in der Variablen max gespeichert
    if max < Box.Canvas.TextWidth(Box.Items[i]) then
      max := Box.Canvas.TextWidth(Box.Items[i]);
  end;
  // der R�ckgabewert, also die gr��te Zahl
  Result := max;
end;

procedure TFreePDF64_Form.FavLinksClick(Sender: TObject);
begin
	if FreePDF64_Form.FavLbR.Visible then
      FreePDF64_Form.FavLbR.Visible := False;

  if not FavLbL.Visible then
  begin
    if ListBoxL.Items.Count > 0 then
    begin
      FavLbL.Width := MaxValue(FavLbL) + 15;
      if FavLbL.Width < 150 then
        FavLbL.Width := 150;
    end;
    FavLbL.Visible := True;
    FavLbL.Left := LMDShellList1.Width - FavLbL.Width;
    FavLbL.Top := Quelllabel.Height + 1;
    if LMDShellList1.Height < ((FavLbL.Items.Count * FavLbL.ItemHeight) + 5)
    then
     FavLbL.Height := LMDShellList1.Height - 4
    else
      begin
        FavLbL.Height := FavLbL.Items.Count * FavLbL.ItemHeight;
        FavLbL.Height := FavLbL.Height + 5;
      end;
  end else
    FavLbL.Visible := False;
end;

procedure TFreePDF64_Form.FavRechtsClick(Sender: TObject);
begin
  if FreePDF64_Form.FavLbL.Visible then
    FreePDF64_Form.FavLbL.Visible := False;

  if not FavLbR.Visible then
  begin
    if ListBoxR.Items.Count > 0 then
    begin
      FavLbR.Width := MaxValue(FavLbR) + 15;
      if FavLbR.Width < 150 then
        FavLbR.Width := 150;
    end;
    FavLbR.Visible := True;
    FavLbR.Left := LMDShellList2.Width - FavLbR.Width;
    FavLbR.Top := Ziellabel.Height + 1;
    if LMDShellList2.Height < ((FavLbR.Items.Count * FavLbR.ItemHeight) + 5)
    then
      FavLbR.Height := LMDShellList2.Height - 4
    else
      begin
        FavLbR.Height := FavLbR.Items.Count * FavLbR.ItemHeight;
        FavLbR.Height := FavLbR.Height + 5;
      end;
  end else
    FavLbR.Visible := False;
end;

// Favoriten hinzuf�gen links
procedure TFreePDF64_Form.FavSpLClick(Sender: TObject);
begin
  FavClose;
  Favoriten_Form.Position := poMainFormCenter;
  Favoriten_Form.ShowModal;
  Favoritenspeichern1.Click;
end;

// Favoriten hinzuf�gen rechts
procedure TFreePDF64_Form.FavSpRClick(Sender: TObject);
begin
  FavClose;
  Favoriten2_Form.Position := poMainFormCenter;
  Favoriten2_Form.ShowModal;
  Favoritenspeichern1.Click;
end;

procedure TFreePDF64_Form.FeedbackClick(Sender: TObject);
begin
  FavClose;
  ShellExecute(FreePDF64_Form.Handle, 'open', 'mailto:FreePDF64@outlook.com'+'?subject=Feedback zu FreePDF64',
               NIL, NIL, SW_SHOWNORMAL);
end;

procedure TFreePDF64_Form.FilterTBClick(Sender: TObject);
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  Filter1.Click;
end;

// Dateifilter definieren
procedure TFreePDF64_Form.Filter1Click(Sender: TObject);
begin
  if LMDShellList1.Focused then
  begin
    Links := True;
    Rechts := false;
  end else
  begin
    Links := false;
    Rechts := True;
  end;
  // Form soll mittig angezeigt werden.
  Filter_Form.Position := poMainFormCenter;
  Filter_Form.ShowModal;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers[printer.printerindex] +
    ' | Erstellte Dateien (seit Nullstellung): ' + IntToStr(Counter);
end;

procedure TFreePDF64_Form.FormatBtnClick(Sender: TObject);
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  Einstellungen1.Click;
end;

procedure TFreePDF64_Form.PlaySoundFile(FileName: string);
begin
 if FileExists(FileName) then
   PlaySound(pchar(FileName), 0, SND_ASYNC or SND_FILENAME);

 { Flags are:
    SND_SYNC  =0 = Start playing, and wait for the sound to finish
    SND_ASYNC =1 = Start playing, and don't wait to return
    SND_LOOP  =8 = Keep looping the sound until another sound is played  }
end;

// Word: 0 - 65535, wobei 65535 die lauteste St�rke ist
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
  vol:= volL + volR shl 16;
  // set volume
  waveOutSetVolume(hWO, vol);
  waveOutClose(hWO);
end;

function MenuItemRightJustify(MenuItem: TMenuItem): Boolean;
var
  Info: TMenuItemInfo;
  MenuHandle: THandle;
  MenuIndex: Integer;
  Caption: String;
begin
  MenuHandle := MenuItem.Parent.Handle;
  MenuIndex := MenuItem.MenuIndex;
  FillChar(Info, SizeOf(Info), 0);
  Info.cbSize := SizeOf(Info);
  Info.fMask := MIIM_TYPE;
  Result := GetMenuItemInfo(MenuHandle, MenuIndex, True, Info);

  if not Result then
    Exit;

  SetLength(Caption, Info.cch);
  Info.dwTypeData := Pointer(Caption);
  Info.cch := Info.cch + 1;
  Result := GetMenuItemInfo(MenuHandle, MenuIndex, True, Info);

  if not Result then
    Exit;

  Info.fType := Info.fType or MFT_RIGHTJUSTIFY;
  Result := SetMenuItemInfo(MenuHandle, MenuIndex, True, Info);
end;

procedure TFreePDF64_Form.FormClick(Sender: TObject);
begin
  FavClose;
end;

procedure TFreePDF64_Form.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TFreePDF64_Form.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if KlickaufX.Checked then
  begin
    CanClose := False;
    if AutoSpalte.Checked then
      AutoSpalteJN := True
    else
      AutoSpalteJN := False;

    FreePDF64_Form.Hide;
    TrayIcon1.Visible := True;
  end;
end;

procedure TFreePDF64_Form.FormCreate(Sender: TObject);
var
  i, ie1, i1, j1, Laenge: Integer;
  IniDat: TIniFile;
  IniFile, ies, k1, s: string;
  iec: Array [0 .. 255] of String;
  Log: Boolean;
begin
  UseLatestCommonDialogs := False;
  MsgDlgIcons[TMsgDlgType.mtInformation] := TMsgDlgIcon.mdiInformation;

  Screen.OnActiveControlChange := ActiveControlChanged;

  // Initialisieren...
  PDFPanelH          := 0;
  AutoSpalteJN       := False;
  ShowVomTray        := False;
  Suche_ItemAnzeigen := False;

  // Wenn die FreePDF64-Ini-Datei vorgefunden wird...
  if FileExists(IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) + 'FreePDF64.ini') then
  begin
    try
      // Aufruf der Initialisierungsdatei 'FreePDF64.ini'
      IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
      IniDat := TIniFile.Create(IniFile);
      with IniDat do
      begin
        FreePDF64_Form.Left := ReadInteger('Position', 'Left', FreePDF64_Form.Left);
        FreePDF64_Form.Top := ReadInteger('Position', 'Top', FreePDF64_Form.Top);
        Width := ReadInteger('Position', 'Width', FreePDF64_Form.Width);
        Height := ReadInteger('Position', 'Height', FreePDF64_Form.Height);
        Panel_Left.Width := ReadInteger('Position', 'Left Tree Width', Panel_Left.Width);
        Panel_Right.Width := ReadInteger('Position', 'Right Tree Width', Panel_Right.Width);
        PanelR.Width := ReadInteger('Position', 'Right Panel Width', PanelR.Width);
        PDFPanel.Height := ReadInteger('Position', 'Memo Panel Height', PDFPanel.Height);
        PDFPanelH := PDFPanel.Height;
        PDFReader := ReadString('Files', 'PDF-Reader', PDFReader);
        LMDShellList1.GridLines := ReadBool('Folder', 'Gridlines', LMDShellList1.GridLines);
        LMDShellList2.GridLines := ReadBool('Folder', 'Gridlines', LMDShellList1.GridLines);
        ResizeEqual.Checked := ReadBool('Folder', 'ResizeEqual', ResizeEqual.Checked);
        VersteckteDateienanzeigen1.Checked := ReadBool('Folder', 'ShowHidden', VersteckteDateienanzeigen1.Checked);
        InDenTray.Checked := ReadBool('Start', 'Tray', InDenTray.Checked);
        KlickaufX.Checked := ReadBool('Start', 'Minimize', KlickaufX.Checked);
        DoppelK.Checked := ReadBool('Start', 'Create with DoubleClick', DoppelK.Checked);
        Formatverz.Checked := ReadBool('Start', 'Create Formatfolder', Formatverz.Checked);
        Formatverz_Date.Checked := ReadBool('Start', 'Create Formatfolder with Date', Formatverz_Date.Checked);
        Formatverz_OnlyDate.Checked := ReadBool('Start', 'Create Formatfolder only Date', Formatverz_OnlyDate.Checked);

        Log := ReadBool('Start', 'Logdatei', Logdatei.Checked);
        Logdatei.Checked := Log;

        if not ValueExists('Files','PDF-Reader') then
          PDFReader := ExtractFilePath(Application.ExeName) + 'xpdf\xpdfreader\xpdf.exe';
        PDFReader  := ReadString('Files', 'PDF-Reader', PDFReader);

        if not ValueExists('Start','Splashscreen') then
          WriteBool('Start', 'Splashscreen', True);
        Splash1.Checked := ReadBool('Start', 'Splashscreen', Splash);

        if InDenTray.Checked then
          Timer2.Enabled := True
        else
          Timer2.Enabled := False;

        // History Links lesen
        for i := 1 to 254 do
        begin
          iec[i - 1] := IniDat.ReadString('History',
            'History Left' + IntToStr(i - 1), s);
          if iec[i - 1] = '' then
            Break;
          ComboBoxL.Items.Insert(i - 1, iec[i - 1]);
        end;
        // History Rechts lesen
        for i := 1 to 254 do
        begin
          iec[i - 1] := IniDat.ReadString('History',
            'History Right' + IntToStr(i - 1), s);
          if iec[i - 1] = '' then
            Break;
          ComboBoxR.Items.Insert(i - 1, iec[i - 1]);
        end;

        // Favoritenliste Links einlesen
        for ie1 := 1 to 254 do
        begin
          iec[ie1 - 1] := ReadString('Favorites Left', IntToStr(ie1 - 1), ies);
          if iec[ie1 - 1] = '' then
            Break;
          for i1 := 1 to Length(iec[ie1 - 1]) do
          begin
            // Suche nach '*|*'
            j1 := Pos('*|*', (iec[ie1 - 1]));
            if j1 > 0 then // String wurde entdeckt. j1 enth�lt die Position.
            begin
              k1 := Copy((iec[ie1 - 1]), 0, j1 - 1);
              // k1: Enth�lt nun alles vor dem Trennzeichen...
              FavLbL.Items.Add(k1);
              Break;
            end;
          end;
          ListBoxL.Items.Add(iec[ie1 - 1]);
        end;
        // Favoriten Rechts einlesen
        for ie1 := 1 to 254 do
        begin
          iec[ie1 - 1] := ReadString('Favorites Right', IntToStr(ie1 - 1), ies);
          if iec[ie1 - 1] = '' then
            Break;
          for i1 := 1 to Length(iec[ie1 - 1]) do
          begin
            // Suche nach '*|*'
            j1 := Pos('*|*', (iec[ie1 - 1]));
            if j1 > 0 then // String wurde entdeckt. j1 enth�lt die Position.
            begin
              k1 := Copy((iec[ie1 - 1]), 0, j1 - 1);
              // k1: Enth�lt nun alles vor dem Trennzeichen...
              FavLbR.Items.Add(k1);
              Break;
            end;
          end;
          ListBoxR.Items.Add(iec[ie1 - 1]);
        end;

      end;
      IniDat.Free;
    except
     begin
        if Einstellungen_Form.SystemklangCB.Checked then
          PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
        ShowMessage('Error');
      end;
    end;
  end else
    Splash1.Checked := True;

  TClickSplitter(Splitter2).OnDblClick := SplDblClick;
  TClickSplitter(Splitter3).OnDblClick := SplDblClick3;
  MenuItemRightJustify(Hilfe1);

  // Die Buttons werden dargestellt und ausgerichtet!
  Laenge := FreePDF64_Form.Width div 7;
  Btn_Rename.Left := 1;
  Btn_Rename.Align := alLeft;
  Btn_Rename.Width := Laenge;
  BtnEditor.Left := 2;
  BtnEditor.Align := alLeft;
  BtnEditor.Width := Laenge;
  Btn_View.Left := 3;
  Btn_View.Align := alLeft;
  Btn_View.Width := Laenge;
  Btn_Copy.Left := 4;
  Btn_Copy.Align := alLeft;
  Btn_Copy.Width := Laenge;
  Btn_Move.Left := 5;
  Btn_Move.Align := alLeft;
  Btn_Move.Width := Laenge;
  Btn_NewFolder.Left := 6;
  Btn_NewFolder.Align := alLeft;
  Btn_NewFolder.Width := Laenge;
  Btn_Delete.Left := 7;
  Btn_Delete.Align := alClient;
  Btn_Delete.Width := Laenge;
end;

procedure TFreePDF64_Form.QuellBtnClick(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile: string;
begin
  FavClose;
  try
    // Aufruf der Initialisierungsdatei 'FreePDF64.ini'
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
    IniDat := TIniFile.Create(IniFile);
    with IniDat do
      LMDShellFolder1.RootFolder := ReadString('Folder', 'Left', A_S);
    IniDat.Free;
  except
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
      ShowMessage('Error');
    end;
  end;
  if LMDShellList1.Selected = NIL then
    LMDShellList1.ItemIndex := 0;
end;

procedure TFreePDF64_Form.ZielBtnClick(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile: string;
begin
  FavClose;
  try
    // Aufruf der Initialisierungsdatei 'FreePDF64.ini'
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
    IniDat := TIniFile.Create(IniFile);
    with IniDat do
      LMDShellFolder2.RootFolder := ReadString('Folder', 'Target', B_Z);
    IniDat.Free;
  except
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
      ShowMessage('Error');
    end;
  end;
  if LMDShellList2.Selected = NIL then
    LMDShellList2.ItemIndex := 0;
end;

procedure TFreePDF64_Form.QuellBtnMouseEnter(Sender: TObject);
begin
  QuellBtn.Hint := 'Ins gespeicherte Quellverzeichnis wechseln:' + #10#13 + MinimizeName(IncludeTrailingBackslash(A_S),
                   FreePDF64_Form.Canvas, Quelllabel.Width - 250);
end;

procedure TFreePDF64_Form.ZielBtnMouseEnter(Sender: TObject);
begin
  ZielBtn.Hint := 'Ins gespeicherte Zielverzeichnis wechseln:' + #10#13 + MinimizeName(IncludeTrailingBackslash(B_Z),
                   FreePDF64_Form.Canvas, Ziellabel.Width - 250);
end;

procedure TFreePDF64_Form.FormResize(Sender: TObject);
var
  Laenge: Integer;
begin
  if ResizeEqual.Checked then
    // Splitter soll sich in der Mitte befinden.
    if Panel_Right.Visible then
      PanelR.Width := (PanelL.Width + Panel_Right.Width + PanelR.Width) div 2
    else
      PanelR.Width := (PanelL.Width + PanelR.Width) div 2;

  // Die Buttons werden dargestellt und ausgerichtet!
  Laenge := FreePDF64_Form.Width div 7;
  Btn_Rename.Left := 1;
  Btn_Rename.Width := Laenge;
  Btn_Delete.Left := 2;
  Btn_Delete.Width := Laenge;
  Btn_NewFolder.Left := 3;
  Btn_NewFolder.Width := Laenge;
  Btn_Move.Left := 4;
  Btn_Move.Width := Laenge;
  Btn_Copy.Left := 5;
  Btn_Copy.Width := Laenge;
  BtnEditor.Left := 6;
  BtnEditor.Width := Laenge;
  Btn_View.Left := 7;
  Btn_View.Width := Laenge;
end;

procedure TFreePDF64_Form.HilfezudenEinstellungen1Click(Sender: TObject);
begin
  // Form soll mittig angezeigt werden.
  Einstellungen_Hilfe_Form.Position := poScreenCenter;
  Einstellungen_Hilfe_Form.ShowModal;
end;

// Linke/Rechte History l�schen
procedure TFreePDF64_Form.History1Click(Sender: TObject);
var
  Msg: String;
begin
  Msg := 'Soll die Verzeichnis-History (links/rechts) wirklich gel�scht werden?';
  if MessageDlgCenter(Msg, mtInformation, [mbYes, mbNo]) = mrYes then
  begin
    ComboBoxL.Items.Clear;
    ComboBoxR.Items.Clear
  end;
end;

procedure TFreePDF64_Form.SuchennachSucheninHistorylschen1Click(Sender: TObject);
var
  Msg: String;
begin
  Msg := 'Soll die Suchen nach-/Suchen in-History im Suche-Fenster wirklich gel�scht werden?';
  if MessageDlgCenter(Msg, mtInformation, [mbYes, mbNo]) = mrYes then
  begin
    Suche_Form.SearchField.Items.Clear;
    Suche_Form.FileField.Items.Clear
  end;
end;

procedure TFreePDF64_Form.Info2Click(Sender: TObject);
begin
 // Form soll mittig angezeigt werden.
  Info_Form.Position := poScreenCenter;
  Info_Form.ShowModal;
end;

// Manuelle Installation von Mfilemon, anschlie�end dir mfilemon.reg-Datei ausf�hren lassen...
procedure TFreePDF64_Form.Installation1Click(Sender: TObject);
var
  MFDatei, Reg, s1: String;
  ProcID: Cardinal;
begin
  if MessageDlgCenter('Hier�ber wird automatisch der FreePDF64-Drucker eingerichtet!' + #13 + #13 +
                      'Bitte einfach die nachfolgende Installation durchklicken:' + #13 +
                      '1. Das Druckeranschlu�-Umleitungsprogramm "Mfilemon" wird installiert.' + #13 +
                      '2. Ben�tigte Registry-Eintr�ge werden hinzugef�gt.' + #13 +
                      '3. Ein manueller Windows-Neustart ist nun erforderlich.' + #13 + #13 +
                      'Nach dem Neustart ist der Drucker "FreePDF64" aus jedem Programm' + #13 +
                      'heraus ausw�hlbar. ' + #13 + #13 +
                      'Weitere Informationen unter: Hilfe - FreePDF64-HowTo',mtInformation, [mbYes,mbNo]) = IDNO then
    Exit;

  MFDatei := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) + 'mfilemon\mfilemon-setup.exe';
  if FileExists(MFDatei) then
  begin
    // Starte die Erstellung...
    ProcID := 0;
    if RunProcess(MFDatei, SW_HIDE, True, @ProcID) = 0 then
    begin
      // Definitions-Datei "mfilemon.reg" mit dem richtigen Pfad anpassen!
      s1 := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));
      s1 := StringReplace(s1, '\', '\\', [rfReplaceAll]);
      with TStringList.Create do
      try
        LoadFromFile(IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) + 'Definition files\mfilemon.reg');
        Delete(3);
        // "OutputPath"="C:\\FreePDF64\\Quellverzeichnis"
        Insert(3, '"OutputPath"="' + s1 + 'Quellverzeichnis' + '"');
        SaveToFile(ExtractFilePath(Application.ExeName) + 'Definition files\mfilemon.reg');
      finally
        Free;
      end;
    end else
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
      MessageDlgCenter('Fehler bei der Installation von "Mfilemon" - Bitte wiederholen!', mtError, [mbOk]);
      Exit;
    end;
  end else
  begin
    MessageDlgCenter('Die Datei "mfilemon-setup.exe" wurde im Verzeichnis "' + IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) +
                     'mfilemon\" ' + 'nicht gefunden.' + #13 +
                     'Sie wird f�r die Installation des FreePDF64-Druckers ben�tigt! Weitere Infos unter Hilfe - FreePDF64-HowTo',
                     mtError, [mbOk]);
    Exit;
  end;

  Reg := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName) + 'Definition files');
  Reg := Reg + 'mfilemon.reg';
  if FileExists(Reg) then
  begin
    // Starte die Erstellung...
    ShellExecute(Handle, NIL, PChar(Reg), NIL, NIL, SW_SHOWNORMAL);
    MessageDlgCenter('Nach der erfolgten Registry-Anpassung ist ein Windows-Neustart erforderlich!', mtInformation, [mbOk]);
    Exit;
  end else
  if Einstellungen_Form.SystemklangCB.Checked then
    PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
  MessageDlgCenter('Die Datei "mfilemon.reg" wurde im Verzeichnis "' + IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) +
                   'Definition files\" ' + 'nicht gefunden.' + #13 +
                   'Sie wird f�r die Installation des FreePDF64-Druckers ben�tigt! Weitere Infos unter Hilfe - FreePDF64-HowTo',
                    mtError, [mbOk]);
end;

procedure TFreePDF64_Form.KlickaufXClick(Sender: TObject);
begin
  if KlickaufX.Checked then
    KlickaufX.Checked := False
  else
    KlickaufX.Checked := True;
end;

procedure TFreePDF64_Form.Kopieren1Click(Sender: TObject);
begin
  if LMDShellList1.Focused and (LMDShellList1.SelCount > 0) then
  begin
    LMDShellList1.CopyToClipboard;
    LMDShellList2.ClearSelection;
    LMDShellList2.PasteFromClipboard;
  end
  else if LMDShellList2.Focused and (LMDShellList2.SelCount > 0) then
  begin
    LMDShellList2.CopyToClipboard;
    LMDShellList1.ClearSelection;
    LMDShellList1.PasteFromClipboard;
  end;
  RefreshBt.Click;
end;

function ComputerName: String;
var
  Size: DWORD;
begin
  Size := MAX_COMPUTERNAME_LENGTH + 1;
  SetLength(Result, Size);
  if GetComputerName(PChar(Result), Size) then
    SetLength(Result, Size)
  else
    Result := '';
end;

function GetCurrentUserName : string;
const
  cnMaxUserNameLen = 254;
var
  sUserName     : string;
  dwUserNameLen : DWord;
begin
  dwUserNameLen := cnMaxUserNameLen-1;
  SetLength( sUserName, cnMaxUserNameLen );
  GetUserName(PChar( sUserName ),dwUserNameLen );
  SetLength( sUserName, dwUserNameLen );
  Result := sUserName;
end;

// Soll bei einem Druckerwechsel ansprechen, damit der neue Standarddrucker angezeigt wird
procedure TFreePDF64_Form.WMSettingChange(var Message: TMessage);
begin
  Printer.PrinterIndex := - 1;
  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers[printer.printerindex] +
    ' | Erstellte Dateien (seit Nullstellung): ' + IntToStr(Counter);
end;

// Beim Minimieren die Form verstecken und Icon in die TNA
procedure TFreePDF64_Form.WMSysCommand(var Message: TWMSysCommand);
begin
  // Fenster wurde minimiert
  if Message.CmdType and $FFF0 = SC_MINIMIZE then
  begin
    if AutoSpalte.Checked then
      AutoSpalteJN := True
    else
      AutoSpalteJN := False;

    FreePDF64_Form.Hide;
    TrayIcon1.Visible := True;
  end else
    inherited;
end;

function ListViewSort(Item1, Item2: TListItem; Data: Integer): Integer; stdcall;
var
  ColumnIndex: Integer;
begin
  ColumnIndex := Data;

  if Item1.SubItems.Count > ColumnIndex then
    Result := CompareText(Item1.SubItems[ColumnIndex], Item2.SubItems[ColumnIndex])
  else
    Result := 0;
end;

procedure TFreePDF64_Form.FormShow(Sender: TObject);
var
  c, i, ie1: Integer;
  IniDat: TIniFile;
  IniFile, ies, s, s1: string;
  tmpt: TLMDShellListOptions;
  iec: Array [0 .. 255] of String;
  regKey: TRegistry;
  Notify_Active: Boolean;
begin
  if ShowVomTray = True then
  begin
    ShowVomTray := False;
    Exit;
  end;

  FreePDF64_Form.Caption := 'FreePDF64 - die PDF-Toolsammlung | Benutzername: ' + GetCurrentUsername;
  FreePDF64_Form.Caption := FreePDF64_Form.Caption + ' | Computername: ' + ComputerName + ' | Betriebssystem: ' + OperatingSystemDisplayName;

  FAbbrechen := False;
  // Wenn Aufruf von FreePDF64-Verbinden via Kontextmen� dann...
  if ParamCount > 0 then
  begin
    Merge.Click;
    // Nach der Erstellung dann FreePDF64.exe beenden!
    Close;
  end;

  // Pfad zu den Definition files viewjpeg.ps f�r Erstellung JPEG zu PDF sowie PDF/Ab und PDF/X
  ViewJPEG := ExtractFilePath(Application.ExeName) + 'gs\lib\viewjpeg.ps';
  PDFA_1   := ExtractFilePath(Application.ExeName) + 'Definition files\PDFA.ps';
  PDFX_1   := ExtractFilePath(Application.ExeName) + 'Definition files\PDFX.ps';

  Autostart.Checked := False;

  //============================================================================
  // Wenn die FreePDF64-Ini-Datei nicht vorgefunden wird...
  if not FileExists(IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) + 'FreePDF64.ini') then
  begin
    // Wenn Splashscreen = True, dann Splashscreen anzeigen
    Splashscreen_Form.Position := poScreenCenter;
    Splashscreen_Form.Show;

    // Ghostscript
    Einstellungen_Form.Edit1.Text := ExtractFilePath(Application.ExeName) + 'gs\bin\gswin64c.exe';
    // QPDF
    Einstellungen_Form.Edit4.Text := ExtractFilePath(Application.ExeName) + 'qpdf\bin\qpdf.exe';
    // PDFtk
    Einstellungen_Form.Edit5.Text := ExtractFilePath(Application.ExeName) + 'pdftk\pdftk.exe';
    // ImageMagick-Converter
    Einstellungen_Form.Edit7.Text := ExtractFilePath(Application.ExeName) + 'ImageMagick';
    ImageMagick := IncludeTrailingBackslash(Einstellungen_Form.Edit7.Text) + 'magick.exe';
    // XPDF-Tools
    Einstellungen_Form.Edit6.Text := ExtractFilePath(Application.ExeName) + 'xpdf\bin64';
    XPDF_Images := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdfimages.exe';
    XPDF_ToHTML := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdftohtml.exe';
    XPDF_Info   := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdfinfo.exe';
    XPDF_Detach := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdfdetach.exe';
    XPDF_Fonts  := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdffonts.exe';

    // XPDFReader
    Einstellungen_Form.Edit3.Text := ExtractFilePath(Application.ExeName) + 'xpdf\xpdfreader\xpdf.exe';
    PDFReader := Einstellungen_Form.Edit3.Text;

    LMDShellFolder1.RootFolder := ExtractFilePath(Application.ExeName) + 'Quellverzeichnis';
    LMDShellFolder2.RootFolder := ExtractFilePath(Application.ExeName) + 'Zielverzeichnis';
    // Notify-Einstellungen...
    FreePDF64_Notify.MonitoringFolder.Text := IncludeTrailingBackslash(LMDShellFolder1.RootFolder);
    LMDShellList1.GridLines := True;
    LMDShellList2.GridLines := True;

    // Splitter soll sich in der Mitte befinden.
    PanelR.Width := (PanelL.Width + Panel_Right.Width + PanelR.Width) div 2;
    // �berwachung ist AUS
    MonitorBtn.ImageIndex := 58;
    MonitorBtn.Caption    := '  AUS';
    MHA := 80;

    try
      // Aufruf der Initialisierungsdatei 'FreePDF64.ini'
      IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
      IniDat := TIniFile.Create(IniFile);
      with IniDat do
      begin
        // Linke, rechte Column-Breite schreiben
        WriteInteger('Start', 'ColumnsL Width0', 100);
        WriteInteger('Start', 'ColumnsL Width1', 100);
        WriteInteger('Start', 'ColumnsL Width2', 70);
        WriteInteger('Start', 'ColumnsL Width3', 100);
        WriteInteger('Start', 'ColumnsR Width0', 100);
        WriteInteger('Start', 'ColumnsR Width1', 100);
        WriteInteger('Start', 'ColumnsR Width2', 70);
        WriteInteger('Start', 'ColumnsR Width3', 100);
        WriteBool('Start', 'ShowFolders', ShowFolders1.Checked);
        WriteBool('Start', 'ShowFolders Left', ShowFolders_Left.Checked);
        WriteBool('Start', 'Autostart', Autostart.Checked);
        WriteBool('Folder', 'Gridlines', LMDShellList1.GridLines);
        WriteBool('Folder', 'Gridlines', LMDShellList2.GridLines);
        WriteBool('Folder', 'ResizeEqual', ResizeEqual.Checked);
      end;
      // Speicher wird wieder freigeben
      IniDat.Free;
    except
      begin
        if Einstellungen_Form.SystemklangCB.Checked then
          PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
        ShowMessage('Error');
      end;
    end;
    // Erstmal eine gut gef�llte FreePDF64.ini erzeugen!
    AllesSpeichern;
    Exit;
  end;
  //============================================================================

  // Ghostscript
  if Einstellungen_Form.Edit1.Text = '' then
    Einstellungen_Form.Edit1.Text := ExtractFilePath(Application.ExeName) + 'gs\bin\gswin64c.exe';
  // QPDF
  if Einstellungen_Form.Edit4.Text = '' then
    Einstellungen_Form.Edit4.Text := ExtractFilePath(Application.ExeName) + 'qpdf\bin\qpdf.exe';
  // PDFtk
  if Einstellungen_Form.Edit5.Text = '' then
    Einstellungen_Form.Edit5.Text := ExtractFilePath(Application.ExeName) + 'pdftk\pdftk.exe';
  // ImageMagick-Converter
  if Einstellungen_Form.Edit7.Text = '' then
    Einstellungen_Form.Edit7.Text := ExtractFilePath(Application.ExeName) + 'ImageMagick';
  ImageMagick := IncludeTrailingBackslash(Einstellungen_Form.Edit7.Text) + 'magick.exe';
  // XPDF-Tools
  if Einstellungen_Form.Edit6.Text = '' then
    Einstellungen_Form.Edit6.Text := ExtractFilePath(Application.ExeName) + 'xpdf\bin64';
  // XPDF-Tools
  XPDF_Images := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdfimages.exe';
  XPDF_ToHTML := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdftohtml.exe';
  XPDF_Info   := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdfinfo.exe';
  XPDF_Detach := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdfdetach.exe';
  XPDF_Fonts  := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdffonts.exe';

  // XPDFReader
  if Einstellungen_Form.Edit3.Text = '' then
    Einstellungen_Form.Edit3.Text := ExtractFilePath(Application.ExeName) + 'xpdf\xpdfreader\xpdf.exe';

  Application.HintHidePause := 10000; // 10 Sekunden
  Memo1.Height := 64;

  try
    // Aufruf der Initialisierungsdatei 'FreePDF64.ini'
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
    IniDat := TIniFile.Create(IniFile);
    with IniDat do
    begin
      // Linke, rechte Tree-Column-Breite lesen
      LMDShellList1.Column[0].Width := ReadInteger('Start', 'ColumnsL Width0', c);
      LMDShellList1.Column[1].Width := ReadInteger('Start', 'ColumnsL Width1', c);
      LMDShellList1.Column[2].Width := ReadInteger('Start', 'ColumnsL Width2', c);
      LMDShellList1.Column[3].Width := ReadInteger('Start', 'ColumnsL Width3', c);
      LMDShellList2.Column[0].Width := ReadInteger('Start', 'ColumnsR Width0', c);
      LMDShellList2.Column[1].Width := ReadInteger('Start', 'ColumnsR Width1', c);
      LMDShellList2.Column[2].Width := ReadInteger('Start', 'ColumnsR Width2', c);
      LMDShellList2.Column[3].Width := ReadInteger('Start', 'ColumnsR Width3', c);

      if FreePDF64_Notify.MonitoringFolder.Text = '' then
        FreePDF64_Notify.MonitoringFolder.Text := IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName);

      if not ValueExists('Folder','Left') then
      begin
        Ziel := ExtractFilePath(Application.ExeName) + 'Zielverzeichnis';
        A_S  := ExtractFilePath(Application.ExeName) + 'Quellverzeichnis';
        B_Z  := Ziel;
      end else
      begin
        A_S := ReadString('Folder', 'Left', A_S);
        B_Z := ReadString('Folder', 'Target', B_Z);
        Ziel := B_Z;
      end;
      Application.ProcessMessages;

      Zielverzeichnisanzeigen1.Checked := ReadBool('Start', 'TargetView', Zielverzeichnisanzeigen1.Checked);
      FreePDF64_Notify.MonitoringFolder.Text := ReadString('Monitoring', 'Folder', FreePDF64_Notify.MonitoringFolder.Text);
      Notify_Active := ReadBool('Monitoring', 'Start', FreePDF64_Notify.LMDShellNotify.Active);
      FreePDF64_Notify.SpinEditSec.Value := ReadInteger('Monitoring', 'Time', FreePDF64_Notify.SpinEditSec.Value);
      FreePDF64_Notify.Ziel_FestCB.Checked := ReadBool('Monitoring', 'Fixed', FreePDF64_Notify.Ziel_FestCB.Checked);
      FreePDF64_Notify.ZielEdit.Text := ReadString('Monitoring', 'Fixed Folder', FreePDF64_Notify.ZielEdit.Text);
      Einstellungen_Form.AnzeigenCB.Checked := ReadBool('Format', 'View File', Einstellungen_Form.AnzeigenCB.Checked);
      Einstellungen_Form.SystemklangCB.Checked := ReadBool('Format', 'System Sound', Einstellungen_Form.SystemklangCB.Checked);
      Einstellungen_Form.PDF_Shrink.Checked := ReadBool('Format', 'Shrink PDF', Einstellungen_Form.PDF_Shrink.Checked);
      ShowFolders1.Checked := ReadBool('Start', 'ShowFolders', ShowFolders1.Checked);
      ShowFolders_Left.Checked := ReadBool('Start', 'ShowFolders Left', ShowFolders_Left.Checked);
      Wasserzeichen_Form.Edit1.Text := ReadString('Start', 'Watermark/Stamp', Wasserzeichen_Form.Edit1.Text);
      Wasserzeichen_Form.bgWatermark.Checked := ReadBool('Start', 'Watermark bg', Wasserzeichen_Form.bgWatermark.Checked);
      Wasserzeichen_Form.vgStamp.Checked := ReadBool('Start', 'Stamp fg', Wasserzeichen_Form.vgStamp.Checked);
      AutoSpalte.Checked := ReadBool('Folder', 'Autosize Name', AutoSpalte.Checked);
      Autostart.Checked := ReadBool('Start', 'Autostart', Autostart.Checked);
      Dateianlage_Form.Datei1.Text := ReadString('Files', 'Datei Vorne', Dateianlage_Form.Datei1.Text);
      Dateianlage_Form.Datei2.Text := ReadString('Files', 'Datei Hinten', Dateianlage_Form.Datei2.Text);
      Einstellungen_Form.HeightSpin.Value := ReadInteger('Start',  'Memo Height Addition', Einstellungen_Form.HeightSpin.Value);
      Einstellungen_Form.SoundSpin.Value := ReadInteger('Format', 'System Sound Volume 0-65535', Einstellungen_Form.SoundSpin.Value);

      if not ValueExists('Start','Counter') then
        Counter := 0
      else
        Counter := ReadInteger('Start', 'Counter', Counter);

      Vol1 := Einstellungen_Form.SoundSpin.Value;
      if (Vol1 < 0) or (Vol1 > 65535) then
        Vol1 := 65535;
      Vol2 := Vol1;
      // Word: 0 - 65535, wobei 65535 die lauteste St�rke ist
      SetVolume(Vol1,Vol2);

      //Memo Height Addition
      MHA := Einstellungen_Form.HeightSpin.Value;

      if (Dateianlage_Form.Datei1.Text <> '') or (Dateianlage_Form.Datei2.Text <> '') then
        Dateianlage_Form.DateianlageCB.Checked := True
      else
      begin
        Dateianlage_Form.DateianlageCB.Checked := False;
        Dateianlage_Form.Clear.Click;
      end;
      if not FileExists(Dateianlage_Form.Datei1.Text) or not FileExists(Dateianlage_Form.Datei2.Text) then
        Dateianlage_Form.Clear.Click;

      Einstellungen_Form.ZusatzAnAus.Checked := ReadBool('Zusatz', 'On/Off', Einstellungen_Form.ZusatzAnAus.Checked);
      if Einstellungen_Form.ZusatzAnAus.Checked = False then
        Einstellungen_Form.Zusatz.Enabled := False
      else
        Einstellungen_Form.Zusatz.Enabled := True;
      if not FreePDF64_Notify.Ziel_FestCB.Checked then
        FreePDF64_Notify.ZielEdit.Text := IncludeTrailingBackslash(LMDShellFolder2.RootFolder);

      // Filter lesen
      for ie1 := 1 to 10 do
      begin
        iec[ie1 - 1] := IniDat.ReadString('Filter', 'Filter' + IntToStr(ie1 - 1), ies);
        if iec[ie1 - 1] = '' then
          Break;
        Filter_Form.FilterCB.Items.Insert(ie1 - 1, iec[ie1 - 1]);
      end;

      // Zusatz lesen
      Zusatz_Form.ZusatzCB.Items.Clear;
      for ie1 := 1 to 20 do
      begin
        Zusatz_Form.ZusatzCB.Items.BeginUpdate;
        try
          iec[ie1 - 1] := IniDat.ReadString('Zusatz', 'Zeichenketten' + IntToStr(ie1 - 1), ies);
          if iec[ie1 - 1] = '' then
            Break;
          Zusatz_Form.ZusatzCB.Items.Add(iec[ie1 - 1]);
        finally
          Zusatz_Form.ZusatzCB.Items.EndUpdate;
        end;
      end;
      FSortAscending  := True;
      FSortAscending2 := True;
      FSortColumn  := ReadInteger('Start', 'Sort ColumnL', FSortColumn);
      FSortColumn2 := ReadInteger('Start', 'Sort ColumnR', FSortColumn2);
      FSortAscending  := ReadBool('Start', 'SortDir ColumnL', FSortAscending);
      FSortAscending2 := ReadBool('Start', 'SortDir ColumnR', FSortAscending2);
    end;
    IniDat.Free;
  except
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
      ShowMessage('Error');
    end;
  end;

  // Show Folders Both Pane
  if ShowFolders1.Checked then
  begin
    ShowFolders1.Checked := False;
    ShowFolders1.Click
  end;
  // Show Folders Left Pane
  if ShowFolders_Left.Checked then
  begin
    ShowFolders1.Checked     := True;
    ShowFolders_Left.Checked := False;
    ShowFolders_Left.Click;
  end;

  // Vorgabewert beim Start des Programms
  //  Encrypt_Form.EncryptCombo.ItemIndex := 1;
  if Einstellungen_Form.AuswahlRG.ItemIndex      = 0  then Text_FormatBtn := ' PS/PDF zu PDF '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 1  then Text_FormatBtn := ' PDF zu PS '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 2  then Text_FormatBtn := ' PDF zu DOCX '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 3  then Text_FormatBtn := ' PS/PDF zu TXT '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 4  then Text_FormatBtn := ' PS/PDF zu BMP '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 5  then Text_FormatBtn := ' PS/PDF zu JPEG '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 6  then Text_FormatBtn := ' PS/PDF zu PNG '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 7  then Text_FormatBtn := ' PS/PDF zu TIFF G4 - BW '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 8  then Text_FormatBtn := ' PS/PDF zu TIFF LZW - BW '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 9  then Text_FormatBtn := ' PS/PDF zu TIFF (uncompressed) '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 10  then Text_FormatBtn := ' BMP zu PDF '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 11 then Text_FormatBtn := ' JPEG zu PDF '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 12 then Text_FormatBtn := ' PNG zu PDF '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 13 then Text_FormatBtn := ' TIFF zu PDF ';
  FormatBtn.Caption  := 'Formatauswahl:' + Text_FormatBtn;

  Quelllabel.Caption := 'Quelle - ' + MinimizeName(IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName), FreePDF64_Form.Canvas,
                                      Quelllabel.Width - (FavSpL.Width + FavLinks.Width + ParentFolderL.Width + QuellBtn.Width + ComboBoxL.Width + 100));
  Ziellabel.Caption  := 'Ziel - ' + MinimizeName(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName),
                                    FreePDF64_Form.Canvas, Ziellabel.Width - (FavSpR.Width + FavRechts.Width +
                                    ParentFolderR.Width + ZielBtn.Width + ComboBoxR.Width + 100));

  if LMDShellList1.GridLines then
    Gitternetzlinien1.Checked := True
  else
    Gitternetzlinien1.Checked := false;

  if AutoSpalte.Checked then
  begin
    LMDShellList1.Column[0].AutoSize := True;
    LMDShellList2.Column[0].AutoSize := True;
    FreePDF64_Form.Height := FreePDF64_Form.Height + 1;
    FreePDF64_Form.Height := FreePDF64_Form.Height - 1;
  end;

  tmpt := LMDShellList1.Options;
  if VersteckteDateienanzeigen1.Checked then
    Include(tmpt, loShowHidden)
  else
    Exclude(tmpt, loShowHidden);
  LMDShellList1.Options := tmpt;
  LMDShellList2.Options := tmpt;

  if Ziel = '' then
  begin
    Ziel := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));
    LMDShellFolder2.RootFolder := Ziel;
  end;

  LMDShellFolder1.RootFolder := A_S;
  LMDShellFolder2.RootFolder := B_Z;
  FreePDF64_Form.QuellBtn.Click;
  FreePDF64_Notify.LMDShellNotify.Active := Notify_Active;

  if Zielverzeichnisanzeigen1.Checked = False then
  begin
    Beide_FolderBtn.Visible := False;
    ShowFolders1.Visible    := False;
  end else
  begin
    Beide_FolderBtn.Visible := True;
    ShowFolders1.Visible    := True;
  end;

  // Wenn beide ShowFolders = False...
  if (ShowFolders1.Checked = False) and (ShowFolders_Left.Checked = False) then
  begin
    ShowFolders1.Checked     := False;
    ShowFolders_Left.Checked := False;
    Splitter1.Visible        := False;
    Splitter4.Visible        := False;
    LMDShellTree1.Visible    := False;
    LMDShellTree2.Visible    := False;
    Panel_Left.Visible       := False;
    Panel_Right.Visible      := False;
    Panel2.Visible           := False;
    Panel3.Visible           := False;
  end;

  // Rechtes Zielverzeichnis anzeigen
  Splitter2.Visible     := Zielverzeichnisanzeigen1.Checked;
  LMDShellList2.Visible := Splitter2.Visible;
  PanelR.Visible        := Splitter2.Visible;

  DokuInfo_Form.Clear.Click;
  DokuInfo_Form.MetadatenCB.Checked := False;

  // L�sche den ersten RootFolder-Eintrag links und rechts
  for i := 0 to ComboBoxL.Items.Count - 1 do
    if ComboBoxL.Items.Strings[i] = LMDShellFolder1.RootFolder then ComboBoxL.Items.Delete(i);
  for i := 0 to ComboBoxR.Items.Count - 1 do
    if ComboBoxR.Items.Strings[i] = LMDShellFolder2.RootFolder then ComboBoxR.Items.Delete(i);

  SB_Left;
  SB_Right;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers[printer.printerindex] +
    ' | Erstellte Dateien (seit Nullstellung): ' + IntToStr(Counter);

  // Abfrage auf FreePDF64-Registry-Eintrag...
  begin
    regKey := TRegistry.Create; // (KEY_READ OR KEY_WOW64_64KEY);
    try
      regKey.Rootkey := HKEY_CURRENT_USER;
      if regKey.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', False) then
      try
        // Pr�fen, ob Wert "FreePDF64" vorhanden
        if regKey.ValueExists('FreePDF64') then
          Autostart.Checked := True
        else
          Autostart.Checked := False;
      finally
        regKey.CloseKey();
      end;
     finally
      regKey.Free;
    end;
  end;

  Quelllabel.Color := RGB(220,220,220);
  Ziellabel.Color  := clBtnFace;

  // Wenn TrayIcon sichtbar ist...
  if TrayIcon1.Visible = False then
  begin
    // Wenn Splashscreen = True, dann Splashscreen anzeigen
    if Splash1.Checked then
    begin
      Splashscreen_Form.Position := poScreenCenter;
      Splashscreen_Form.Show;
    end;
  end;

  // Definitions-Datei "PDFA.ps" mit dem richtigen Pfad anpassen!
  s1 := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName));
  s  := s1;
  for i := 1 to length(s) do
    if s[i] = '\' then s[i] := '/';
  s1 := s;
  with TStringList.Create do
  try
    LoadFromFile(IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) + 'Definition files\PDFA.ps');
    Delete(6);
    Insert(6, '/ICCProfile (' + s1 + 'Definition files/default_rgb.icc)');
    SaveToFile(ExtractFilePath(Application.ExeName) + 'Definition files\PDFA.ps');
  finally
    Free;
  end;

  // �berwachung auf...
  FreePDF64_Notify.LMDShellNotify.WatchFolder := Trim(FreePDF64_Notify.MonitoringFolder.Text);
  if FreePDF64_Notify.LMDShellNotify.Active then
  begin
    MonitorBtn.ImageIndex := 57;
    MonitorBtn.Caption    := '  AN';
  end else
  begin
    MonitorBtn.ImageIndex := 58;
    MonitorBtn.Caption    := '  AUS';
  end;

  // Sortierung der Spalten nach gespeicherten Variable 'FSortColumn..., FSortAscending...'
  if FSortColumn  >= 0 then
    LMDShellList1.SortColumn(FSortColumn);
  if FSortColumn2 >= 0 then
    LMDShellList2.SortColumn(FSortColumn2);

  if FSortAscending then
    LMDShellList1.SortDirection := sdAscending
  else
    LMDShellList1.SortDirection := sdDescending;
  if FSortAscending2 then
    LMDShellList2.SortDirection := sdAscending
  else
    LMDShellList2.SortDirection := sdDescending;
end;

procedure TFreePDF64_Form.Gitternetzlinien1Click(Sender: TObject);
begin
  Gitternetzlinien1.Checked := Not Gitternetzlinien1.Checked;
  LMDShellList1.GridLines := Gitternetzlinien1.Checked;
  LMDShellList2.GridLines := Gitternetzlinien1.Checked;
end;

procedure TFreePDF64_Form.LMDShellFolder1Change(Sender: TObject);
var
  i, j: Integer;
begin
  // Merke Dir das Verzeichnis, von wo man ausgegangen ist...
  i := LMDShellFolder1.BackwardPathList.Count - 2;

  // Wenn aus dem Suchefenster heraus das markierte Item angezeigt werden soll...
  if Suche_ItemAnzeigen = False then
  begin
    for j := 0 to LMDShellList1.Items.Count - 1 do
      if LMDShellList1.Items.Item[j].Caption = ExtractFileName(LMDShellFolder1.BackwardPathList.Strings[i]) then // und gefunden...
      begin
        LMDShellList1.ItemIndex := j;
        LMDShellList1.Selected  := LMDShellList1.Items.Item[j];
      end;
    if (LMDShellList1.Items.Count > 0) and (LMDShellList1.Selcount = 0) then
      LMDShellList1.ItemIndex := 0;
  end;

  LMDShellFolder1.RootFolder := LMDShellFolder1.ActiveFolder.PathName;
  Quelllabel.Caption := 'Quelle - ' + MinimizeName(IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName), FreePDF64_Form.Canvas,
                                      Quelllabel.Width - (FavSpL.Width + FavLinks.Width + ParentFolderL.Width + QuellBtn.Width + ComboBoxL.Width + 100));

  // Keine doppelten Eintr�ge zulassen...
  if ComboBoxL.Items.IndexOf(LMDShellFolder1.ActiveFolder.PathName) = -1 then
    ComboBoxL.Items.Add(LMDShellFolder1.ActiveFolder.PathName);

  SB_Left;

  if AutoSpalte.Checked then
  begin
    LMDShellList1.Column[0].AutoSize := True;
    LMDShellList2.Column[0].AutoSize := True;
  end;
  Suche_ItemAnzeigen := False;
end;

procedure TFreePDF64_Form.LMDShellFolder2Change(Sender: TObject);
var
  i, j: Integer;
begin
  // Merke Dir das Verzeichnis, von wo man ausgegangen ist...
  i := LMDShellFolder2.BackwardPathList.Count - 2;

  if Suche_ItemAnzeigen = False then
  begin
    // Wenn aus dem Suchefenster heraus das markierte Item angezeigt werden soll...
    for j := 0 to LMDShellList2.Items.Count - 1 do
      if LMDShellList2.Items.Item[j].Caption = ExtractFileName(LMDShellFolder2.BackwardPathList.Strings[i]) then // und gefunden...
      begin
        LMDShellList2.ItemIndex := j;
        LMDShellList2.Selected  := LMDShellList2.Items.Item[j];
      end;
    if (LMDShellList2.Items.Count > 0) and (LMDShellList2.Selcount = 0) then
      LMDShellList2.ItemIndex := 0;
  end;

  LMDShellFolder2.RootFolder := LMDShellFolder2.ActiveFolder.PathName;
  Ziel := IncludeTrailingBackslash(LMDShellFolder2.RootFolder);
  Ziellabel.Caption := 'Ziel - ' + MinimizeName(IncludeTrailingBackslash(Ziel),
                       FreePDF64_Form.Canvas, Ziellabel.Width - (FavSpR.Width + FavRechts.Width +
                       ParentFolderR.Width + ZielBtn.Width + ComboBoxR.Width + 100));

  // Keine doppelten Eintr�ge zulassen...
  if ComboBoxR.Items.IndexOf(LMDShellFolder2.ActiveFolder.PathName) = -1 then
    ComboBoxR.Items.Add(LMDShellFolder2.ActiveFolder.PathName);

  SB_Right;

  if AutoSpalte.Checked then
  begin
    LMDShellList1.Column[0].AutoSize := True;
    LMDShellList2.Column[0].AutoSize := True;
  end;
  Suche_ItemAnzeigen := False;
end;

// Abfrage auf richtige Extension zur Erstellungsauswahl!
procedure TFreePDF64_Form.ExtAbfrage;
begin
  if (FreePDF64_Form.LMDShellList1.SelCount > 0) and
     (LMDShellList1.Cursor <> crHourGlass) then
  begin
    if Einstellungen_Form.AuswahlRG.ItemIndex = 1 then
    begin
      if (Uppercase(ExtractFileExt(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName) +
          FreePDF64_Form.LMDShellList1.Selected.Caption)) =  '.PDF') then
        FreePDF64_Form.FormatBtn.Font.Color := clWindowText
      else
        FreePDF64_Form.FormatBtn.Font.Color := clRed;
    end else
    if Einstellungen_Form.AuswahlRG.ItemIndex = 10 then
    begin
      if (Uppercase(ExtractFileExt(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName) +
          FreePDF64_Form.LMDShellList1.Selected.Caption)) =  '.BMP') then
        FreePDF64_Form.FormatBtn.Font.Color := clWindowText
      else
        FreePDF64_Form.FormatBtn.Font.Color := clRed;
    end else
    if Einstellungen_Form.AuswahlRG.ItemIndex = 11 then
    begin
      if (Uppercase(ExtractFileExt(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName) +
          FreePDF64_Form.LMDShellList1.Selected.Caption)) =  '.JPG') or
         (Uppercase(ExtractFileExt(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName) +
          FreePDF64_Form.LMDShellList1.Selected.Caption)) =  '.JPEG') then
        FreePDF64_Form.FormatBtn.Font.Color := clWindowText
      else
        FreePDF64_Form.FormatBtn.Font.Color := clRed;
    end else
    if Einstellungen_Form.AuswahlRG.ItemIndex = 12 then
    begin
      if (Uppercase(ExtractFileExt(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName) +
          FreePDF64_Form.LMDShellList1.Selected.Caption)) =  '.PNG') then
        FreePDF64_Form.FormatBtn.Font.Color := clWindowText
      else
        FreePDF64_Form.FormatBtn.Font.Color := clRed;
    end else
    if Einstellungen_Form.AuswahlRG.ItemIndex = 13 then
    begin
      if (Uppercase(ExtractFileExt(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName) +
          FreePDF64_Form.LMDShellList1.Selected.Caption)) =  '.TIF') then
        FreePDF64_Form.FormatBtn.Font.Color := clWindowText
      else
        FreePDF64_Form.FormatBtn.Font.Color := clRed;
    end else
      if (Uppercase(ExtractFileExt(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName) +
          FreePDF64_Form.LMDShellList1.Selected.Caption)) =  '.PS') or
         (Uppercase(ExtractFileExt(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName) +
          FreePDF64_Form.LMDShellList1.Selected.Caption)) =  '.PRN') or
         (Uppercase(ExtractFileExt(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName) +
          FreePDF64_Form.LMDShellList1.Selected.Caption)) =  '.PDF') then
        FreePDF64_Form.FormatBtn.Font.Color := clWindowText
      else
        FreePDF64_Form.FormatBtn.Font.Color := clRed;
  end else
    FreePDF64_Form.FormatBtn.Font.Color := clWindowText;
end;

// Verzeichnis l�schen
function DelDir(dir: string): Boolean;
var
  fos: TSHFileOpStruct;
begin
  ZeroMemory(@fos, SizeOf(fos));
  with fos do
  begin
    wFunc := FO_DELETE;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom := PChar(dir + #0);
  end;
  Result := (0 = ShFileOperation(fos));
end;

// Bilder aus PDF-Datei extrahieren
procedure TFreePDF64_Form.ExtractBtnClick(Sender: TObject);
var
  ProcID: Cardinal;
  FileName, Zeile, Memozeile, Bildziel: String;
  F: TextFile;
  j: Integer;
begin
  j := 0;
  if not FileExists(XPDF_Images) then
  begin
    MessageDlgCenter('Achtung: Die Datei "pdfimages.exe" fehlt im Ordner "' + IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + '"!', mtError, [mbOk]);
    Exit;
  end;
  BildZiel := IncludeTrailingBackslash(Ziel) + 'Extrahierte Bilder';

  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
  begin
    FileName := ExtractFileName(LMDShellList1.SelectedItem.PathName);
    // Wenn der Zielordner schon vorhanden ist, dann Umbenennen...
    repeat
      Ziel2 := BildZiel;
      // Gibt es Ziel2, dann INC...
      if DirectoryExists(Ziel2) then
      begin
        INC(j);
        Ziel2 := BildZiel + '_' + IntToStr(j);
      end;
      // Wiederhole alles solange...
    until not DirectoryExists(Ziel2);
      BildZiel := Ziel2;

    // Abfrage, ob das Extrahieren funktionieren wird...
    if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
      Zeile := XPDF_Images + ' -j "' + LMDShellList1.SelectedItem.PathName + '" >NIL';

    ProcID := 0;
    // Ja wird funktionieren. Weiter geht's mit Erstellung der Ziel-Verzeichnisse...
    if RunProcess(Zeile, SW_HIDE, True, @ProcID) = 0 then
    begin
      // Verzeichnis erstellen "Extrahierte Bilder"
      if System.SysUtils.ForceDirectories(Bildziel) then
        Zeile := XPDF_Images + ' -j "' + LMDShellList1.SelectedItem.PathName + '" "' + Bildziel + '\' + FileName + '"';

      // Starte nun die richtige Erstellung...
      if RunProcess(Zeile, SW_HIDE, True, @ProcID) = 0 then
        Memozeile := XPDF_Images + ' -j "' + LMDShellList1.SelectedItem.PathName + '" "' +
                     Bildziel + '\' + ExtractFileName(FileName) + '-xxxx.xxx' + '"';
    end else
    begin
      MessageDlgCenter('Fehler beim Extrahieren von Bildern aus der Datei: "' + FileName + '".' + #13 +
                       'Vermutlich ist die PDF-Datei verschl�sselt, enth�lt kein Bild oder es ist keine PDF-Datei?!', mtError, [mbOk]);
      ProgressBar1.Position := 0;
    end;

    if IsEmptyFolder(Bildziel) then
    begin
      DelDir(Bildziel);
      MessageDlgCenter('Fehler beim Extrahieren von Bildern aus der Datei: "' + FileName + '".' + #13 +
                       'Vermutlich ist die PDF-Datei verschl�sselt, enth�lt kein Bild oder es ist keine PDF-Datei?!', mtError, [mbOk]);
      Exit;
    end;
    if Einstellungen_Form.SystemklangCB.Checked then
      PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');

    // FreePDF64Log.txt
    if Logdatei.Checked then
    begin
      Memo1.Lines.Text := Memozeile;
      // Logdatei (FreePDF64Log.txt) �ffnen/beschreiben etc.
      AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
      try
        Append(F);
      except
        Rewrite(F)
      end;
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ===> Extrahiere Bilder: ' + Zeile));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + ExtractFilePath(LMDShellList1.SelectedItem.PathName)));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(LMDShellList1.SelectedItem.PathName)));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(LMDShellList1.SelectedItem.PathName))));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + Bildziel));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(FileName) + '-xxxx.xxx'));
      Closefile(F);
    end;
  end else
  begin
    MessageDlgCenter('Bilder extrahieren: Bitte EINE PDF-Datei aus dem Quellverzeichnis ausw�hlen!', mtInformation, [mbOk]);
    Exit;
  end;
end;

// Erstelle PDF zu HTML
procedure TFreePDF64_Form.HTMLBtnClick(Sender: TObject);
var
  ProcID: Cardinal;
  FileName, Zeile, Memozeile, HTMLZiel: String;
  F: TextFile;
  j: Integer;
begin
  j := 0;
  if not FileExists(XPDF_ToHTML) then
  begin
    MessageDlgCenter('Achtung: Die Datei "pdftohtml.exe" fehlt im Ordner "' + IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + '"!', mtError, [mbOk]);
    Exit;
  end;
  HTMLZiel := IncludeTrailingBackslash(Ziel) + 'HTML';

  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
  begin
    FileName := ExtractFileName(LMDShellList1.SelectedItem.PathName);

    // Wenn der Zielordner schon vorhanden ist, dann Umbenennen...
    repeat
      Ziel2 := HTMLZiel;
      // Gibt es Ziel2, dann INC...
      if DirectoryExists(Ziel2) then
      begin
        INC(j);
        Ziel2 := HTMLZiel + '_' + IntToStr(j);
      end;
      // Wiederhole alles solange...
    until not DirectoryExists(Ziel2);
      HTMLZiel := Ziel2;

    Zeile := XPDF_toHTML + ' -meta -overwrite -q "' + LMDShellList1.SelectedItem.PathName + '" "' + HTMLZiel + '"';

    // Starte die Erstellung...
    ProcID := 0;
    if RunProcess(Zeile, SW_HIDE, True, @ProcID) = 0 then
    begin
      Memozeile := XPDF_toHTML + ' -meta -overwrite -q "' + LMDShellList1.SelectedItem.PathName + '" "' + HTMLZiel + '\"';
      Memo1.Lines.Text := Memozeile;
      // FreePDF64Log.txt
      if Logdatei.Checked then
      begin
        // Logdatei (FreePDF64Log.txt) �ffnen/beschreiben etc.
        AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
        try
          Append(F);
        except
          Rewrite(F)
        end;
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' =========> PDF zu HTML: ' + Zeile));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + ExtractFilePath(LMDShellList1.SelectedItem.PathName)));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(LMDShellList1.SelectedItem.PathName)));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(LMDShellList1.SelectedItem.PathName))));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + HTMLZiel + '\'));
        Closefile(F);

        if Einstellungen_Form.SystemklangCB.Checked then
          PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');
      end;
    end else
    begin
      MessageDlgCenter('Fehler beim Konvertieren zu HTML aus der Datei: "' + FileName + '".' + #13 +
                       'Vermutlich ist die PDF-Datei verschl�sselt oder es ist keine PDF-Datei?!', mtError, [mbOk]);
      ProgressBar1.Position := 0;
      if IsEmptyFolder(IncludeTrailingBackslash(Ziel) + 'HTML') then
        DelDir(IncludeTrailingBackslash(Ziel) + 'HTML');
    end;
  end else
  begin
    MessageDlgCenter('Konvertieren PDF zu HTML: Bitte EINE PDF-Datei aus dem Quellverzeichnis ausw�hlen!',
                      mtInformation, [mbOk]);
    Exit;
  end;
end;

procedure TFreePDF64_Form.LMDShellList1Click(Sender: TObject);
begin
  FavClose;
  Memo1.Clear;

  if LMDShellList1.SelCount = 0 then
    Exit
  else
  if Image1.Visible then
    Image1.Picture.LoadFromFile(LMDShellList1.SelectedItem.pathname);
end;

// Starte die Erstellung mit Doppelklick auf ein Listenelement, au�er es ist ein Verzeichnis...
procedure TFreePDF64_Form.LMDShellList1DblClick(Sender: TObject);
begin
  if LMDShellList1.SelCount = 0 then
    Exit;

  if System.SysUtils.DirectoryExists(LMDShellList1.SelectedItem.PathName) then
  begin
    LMDShellList1.SuppressDefaultAction := false;
    Exit
  end
  else if DoppelK.Checked then
  begin
    LMDShellList1.SuppressDefaultAction := True;
    PDF_Erstellung.Click;
  end
  else
    LMDShellList1.SuppressDefaultAction := false;
end;

procedure TFreePDF64_Form.LMDShellList1Enter(Sender: TObject);
begin
//  if LMDShellList1.Selected = NIL then
  if (LMDShellList1.Items.Count > 0) and (LMDShellList1.Selcount = 0) then
    LMDShellList1.ItemFocused;
//    LMDShellList1.ItemIndex := 0;

  if LMDShellList1.FileFilter <> '*.*' then
    FilterTB.ImageIndex := 69
  else
    FilterTB.ImageIndex := 68;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers[printer.printerindex] +
    ' | Erstellte Dateien (seit Nullstellung): ' + IntToStr(Counter);

  Quelllabel.Color := RGB(220,220,220);
  Ziellabel.Color := clBtnFace;
end;

procedure TFreePDF64_Form.LMDShellList1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if LMDShellList1.SelCount > 0 then
    PDF_Erstellung.Caption := ('Markiert: ' + IntToStr(LMDShellList1.SelCount) + ' => Erstellung starten!')
  else
    PDF_Erstellung.Caption := ('Erstellung starten!');
  // Abfrage auf Hinweis bzgl. der Extension
  ExtAbfrage;
  SB_Left;
end;

procedure TFreePDF64_Form.LMDShellList2Change(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  SB_Right;
end;

procedure TFreePDF64_Form.LMDShellList2Click(Sender: TObject);
begin
  FavClose;
  Memo1.Clear;

  if LMDShellList2.SelCount = 0 then
    Exit
  else
  if Image2.Visible then
    Image2.Picture.LoadFromFile(LMDShellList2.SelectedItem.pathname);
end;

procedure TFreePDF64_Form.LMDShellList1ColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  if Column.Index = FSortColumn then
    FSortAscending := not FSortAscending
  else
  begin
    FSortColumn := Column.Index;
    FSortAscending := True;
  end;
end;

procedure TFreePDF64_Form.LMDShellList2ColumnClick(Sender: TObject;
  Column: TListColumn);
begin
  if Column.Index = FSortColumn2 then
    FSortAscending2 := not FSortAscending2
  else
  begin
    FSortColumn2 := Column.Index;
    FSortAscending2 := True;
  end;
end;

procedure TFreePDF64_Form.LMDShellList2Enter(Sender: TObject);
begin
//  if LMDShellList2.Selected = NIL then
  if (LMDShellList2.Items.Count > 0) and (LMDShellList2.Selcount = 0) then
    LMDShellList2.ItemFocused;
//    LMDShellList2.ItemIndex := 0;

  if LMDShellList2.FileFilter <> '*.*' then
    FilterTB.ImageIndex := 69
  else
    FilterTB.ImageIndex := 68;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers[printer.printerindex] +
    ' | Erstellte Dateien (seit Nullstellung): ' + IntToStr(Counter);

  Ziellabel.Color := RGB(220,220,220);
  Quelllabel.Color := clBtnFace;
end;

procedure TFreePDF64_Form.LMDShellList1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (LMDShellList1.IsEditing = false) then
    Btn_Delete.Click;

  if (Key = VK_BACK) and (LMDShellList1.IsEditing = false) then
    ParentFolderL.Click;

  if (Key = VK_SPACE) then
    PropertiesBtn.Click;

  if Key = VK_RETURN then
  begin
    LMDShellList1.Open;
    if LMDShellList1.SelCount = 0 then
      LMDShellList1.Selected := LMDShellList1.ItemFocused;
  end;
end;

procedure TFreePDF64_Form.LMDShellList2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) and (LMDShellList2.IsEditing = false) then
    Btn_Delete.Click;

  if (Key = VK_BACK) and (LMDShellList2.IsEditing = false) then
    ParentFolderR.Click;

  if (Key = VK_SPACE) then
    PropertiesBtn.Click;

  if Key = VK_RETURN then
  begin
    LMDShellList2.Open;
    if LMDShellList2.SelCount = 0 then
      LMDShellList2.Selected := LMDShellList2.ItemFocused;
  end;
end;

procedure TFreePDF64_Form.LMDShellList1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  SB_Left;
end;

procedure TFreePDF64_Form.LMDShellList2SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  SB_Right;
end;

procedure TFreePDF64_Form.LMDShellTree1Change(Sender: TObject; Node: TTreeNode);
begin
  PDF_Erstellung.Caption := ('Erstellung starten!');

  // JPEG-Fenster schlie�en
  if Image1.Visible then
  begin
    Image1.Visible := False;
    Image1.Picture := NIL;
    LMDShellList2.Visible := True;
  end;
end;

procedure TFreePDF64_Form.LMDShellTree1Click(Sender: TObject);
begin
  FavClose;
end;

procedure TFreePDF64_Form.Loeschen1Click(Sender: TObject);
begin
  Btn_Delete.Click;
end;

procedure TFreePDF64_Form.LogBtClick(Sender: TObject);
begin
  FavClose;
  Logdateiansehen1.Click;
end;

procedure TFreePDF64_Form.Logdateiansehen1Click(Sender: TObject);
begin
  if Einstellungen_Form.Edit2.Text = '' then
    Einstellungen_Form.Edit2.Text := 'notepad.exe';

  if ExtractFileName(Einstellungen_Form.Edit2.Text) = 'notepad++.exe' then
    ShellExecute(Application.Handle, 'open', PChar(Einstellungen_Form.Edit2.Text),
      PChar(' -n999999 "' + ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt' + '"'),
      NIL, SW_SHOWNORMAL)
  else
    ShellExecute(Application.Handle, 'open', PChar(Einstellungen_Form.Edit2.Text),
      PChar(' "' + ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt' + '"'),
      NIL, SW_SHOWNORMAL)
end;

procedure TFreePDF64_Form.Logdateiansehen2Click(Sender: TObject);
begin
  LogBt.Click;
end;

procedure TFreePDF64_Form.LogdateiClick(Sender: TObject);
begin
  Logdatei.Checked := Not Logdatei.Checked;
end;

// Logdatei (FreePDF64Log.txt) l�schen
procedure TFreePDF64_Form.Logdateilschen1Click(Sender: TObject);
var
  Msg: String;
begin
  Msg := 'Soll die Logdatei wirklich gel�scht werden?';
  if MessageDlgCenter(Msg, mtInformation, [mbYes, mbNo]) = mrYes then
    if not DeleteFile(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt') then
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
//      ShowMessage(SysErrorMessage(GetLastError));
    end;
end;

procedure TFreePDF64_Form.MainMenu1Change(Sender: TObject; Source: TMenuItem; Rebuild: Boolean);
begin
  FavClose;
end;

procedure TFreePDF64_Form.MarkEntfClick(Sender: TObject);
var
  i: Integer;
begin
  if FavLbL.Visible then
  begin
    for i := FavLbL.Items.Count - 1 downto 0 do
      if FavLbL.Selected[i] then
      begin
        FavLbL.Items.Delete(i);
        ListBoxL.Items.Delete(i);
        FavLbL.Visible := False;
      end
  end
  else if FavLbR.Visible then
  begin
    for i := FavLbR.Items.Count - 1 downto 0 do
      if FavLbR.Selected[i] then
      begin
        FavLbR.Items.Delete(i);
        ListBoxR.Items.Delete(i);
        FavLbR.Visible := False;
      end;
  end;
  Favoritenspeichern1.Click;
end;

procedure TFreePDF64_Form.Allelschen1Click(Sender: TObject);
var
  i: Integer;
  Msg: String;
begin
  Msg := 'Soll die komplette Schnellzugriffsliste wirklich gel�scht werden?';
  if MessageDlgCenter(Msg, mtInformation, [mbYes, mbNo]) = mrYes then
  begin
    if FavLbL.Visible then
    begin
      for i := ListBoxL.Items.Count - 1 downto 0 do
      begin
        FavLbL.Items.Delete(i);
        ListBoxL.Items.Delete(i);
        FavLbL.Visible := False;
      end;
    end
    else if FavLbR.Visible then
    begin
      for i := ListBoxR.Items.Count - 1 downto 0 do
      begin
        FavLbR.Items.Delete(i);
        ListBoxR.Items.Delete(i);
        FavLbR.Visible := False;
      end;
    end;
  end;
  Favoritenspeichern1.Click;
end;

procedure TFreePDF64_Form.Allemarkieren1Click(Sender: TObject);
begin
  if LMDShellList1.Focused then
  begin
    if LMDShellList1.SelCount > 1 then
    begin
      LMDShellList1.ClearSelection;
      LMDShellList1.ItemIndex := 0;
    end else
    begin
      LMDShellList1.Cursor := crHourGlass;
      LMDShellList1.SelectAll;
      LMDShellList1.Cursor := crDefault;
    end;
  end else
  if LMDShellList2.Focused then
    if LMDShellList2.SelCount > 1 then
    begin
      LMDShellList2.ClearSelection;
      LMDShellList2.ItemIndex := 0;
    end else
    begin
      LMDShellList2.Cursor := crHourGlass;
      LMDShellList2.SelectAll;
      LMDShellList2.Cursor := crDefault;
    end;
end;

// Extract Extension OHNE Punkt!
function ExtractFileExtensionWithoutDot(const FileName: string): string;
begin
  Result := Copy(ExtractFileExt(FileName), 2);
end;

procedure TFreePDF64_Form.Memo1Click(Sender: TObject);
begin
  FavClose;
end;

procedure TFreePDF64_Form.Memo1DblClick(Sender: TObject);
var
  i: Integer;
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcPrevious.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else
    LMDShellList2.SetFocus;

  if PDFPanelH > PDFPanel.Height then
    PDFPanel.Height := PDFPanelH;

  if Memo1.Lines.Count > 0 then
  begin
    i:= TextHoehe(Memo1.Font, Memo1.Text);
    i := (i * Memo1.Lines.Count) + 80;
    PDFPanel.Height := i;
  end;
end;

procedure TFreePDF64_Form.MergeClick(Sender: TObject);
var
  A1, p, s, AP1, AP1_1, AP1_2, AP1_3, AP1_4, AP1_5, VonSpin,
  BisSpin, files, files2, NZiel, PZiel, QPDFZiel, QPDF_Zeile,
  DokuSicherheit, DS1, DS2, DS3, DS4, DS5, AX: String;
  i, j, R, dpi, DP, DP1, Level,
  PDFALevel: Integer;
  Res: Boolean;
  StartUp: TStartupInfo;
  Process: TProcessInformation;
  InpHandle, OutpHandle: THandle;
  fExitCode: Cardinal;
  F: TextFile;
  NewItem: TListItem;
begin
  Memo1.Clear;
  s := '.pdf';
  j := 0;
  // Wenn Aufruf von FreePDF64-Verbinden via Kontextmen� dann...
  while j < ParamCount do
  begin
    Inc(j);
    NewItem := Auswahl_Form.FileList.Items.Add;
    NewItem.Caption := ParamStr(j);
  end;

  keybd_event(VK_HOME, 0, 0, 0);

  if FreePDF64_Notify.Ziel_FestCB.Checked then
    Ziel := FreePDF64_Notify.ZielEdit.Text;
  p := IncludeTrailingBackslash(Ziel);

  if MyInputQuery_Verbinden('Verbinden', 'Zielverzeichnis -> siehe Hilfetext am Mauszeiger!' + #13 + #13 + 'Dateiname:',
                            'Zielverzeichnis: ' + p + #13 +
                            'Es ist gleich dem aktuellen Zielverzeichnis der �berwachung (siehe dort)', s) then
  begin
    if FileExists(IncludeTrailingBackslash(Ziel) + s) then
    begin
      ShowMessage('Achtung: "' + s + '" ist in "' + Ziel + '" schon vorhanden! Bitte anderen Dateinamen nehmen!');
      Merge.Click;
      Exit
    end else
      MERGEDATEI := s;
  end else
    Exit;

  if Popup_Aufruf then
    Auswahl_Form.Position := poScreenCenter
  else
    Auswahl_Form.Position := poMainFormCenter;
  Popup_Aufruf := False;

  // Wenn KEIN Aufruf von FreePDF64-Verbinden via Kontextmen� dann...
  if ParamCount = 0 then
  begin
    // Form soll mittig angezeigt werden.
    Auswahl_Form.ShowModal;
    // Wenn Abbrechen geklickt wurde...
    if ABBRUCH = True then
      Exit;
  end;

  QPDF := Einstellungen_Form.Edit4.Text;

  if Auswahl_Form.FileList.Items.Count > 0 then
  begin
    // Wo liegt das Ghostscript-Programm?
    Ghostscript := Einstellungen_Form.Edit1.Text;
    // Wechsel das Verzeichnis.
    ChDir(Ziel);
    // PDF-Level
    Level := Einstellungen_Form.PDFLevel.ItemIndex;
    case Level of
      0: AP1_1 := ' -dCompatibilityLevel=1.4'; // Acrobat 5
      1: AP1_1 := ' -dCompatibilityLevel=1.5'; // Acrobat 6
      2: AP1_1 := ' -dCompatibilityLevel=1.6'; // Acrobat 7
      3: AP1_1 := ' -dCompatibilityLevel=1.7'; // Acrobat 8
    end;
    // Schriftarten/F�llmuster-dpi?
    dpi := Einstellungen_Form.SchriftParams.ItemIndex;
    case dpi of
      0: AP1_2 := ' -r72';
      1: AP1_2 := ' -r96';
      2: AP1_2 := ' -r150';
      3: AP1_2 := ' -r300';
      4: AP1_2 := ' -r600';
      5: AP1_2 := ' -r720';
    end;
    // Welcher Distiller-Parameter?
    DP := Einstellungen_Form.DistParam.ItemIndex;
    case DP of
      0: AP1_3 := ' -DPDFSETTINGS=/default';
      1: AP1_3 := ' -DPDFSETTINGS=/screen';
      2: AP1_3 := ' -DPDFSETTINGS=/ebook';
      3: AP1_3 := ' -DPDFSETTINGS=/printer';
      4: AP1_3 := ' -DPDFSETTINGS=/prepress';
    end;

    // PDF/A-Level
    if Einstellungen_Form.PDFA_CB.Checked = True then
    begin
      PDFALevel := Einstellungen_Form.PDFA.ItemIndex;
      case PDFALevel of
        0: AP1_4 := '-dNOSAFER -dPDFA -sColorConversionStrategy=RGB ';
        1: AP1_4 := '-dNOSAFER -dPDFA=2 -sColorConversionStrategy=RGB ';
        2: AP1_4 := '-dNOSAFER -dPDFA=3 -sColorConversionStrategy=RGB ';
      end;
    end else
      Einstellungen_Form.PDFA_CB.Checked := False;

    // PDF/X-3-Level
    if Einstellungen_Form.PDFX.Checked = True then
      AP1_4 := '-dPDFX -sColorConversionStrategy=CMYK '
    else
      Einstellungen_Form.PDFX.Checked := False;

    // Schnelle Webanzeige
    if Einstellungen_Form.FastCB.Checked then
      AP1_5 := ' -dFastWebView'
    else
      AP1_5 := '';
    DP1 := Einstellungen_Form.AutoRP.ItemIndex;
    case DP1 of
      0: AP4 := '-dAutoRotatePages=/None ';
      1: AP4 := '-dAutoRotatePages=/All ';
      2: AP4 := '-dAutoRotatePages=/PageByPage ';
    end; // of case

    // Seitenentnahme von- bis
    VonSpin := IntToStr(Seiten_Form.VonSE.Value);
    BisSpin := IntToStr(Seiten_Form.BisSE.Value);
    if (Seiten_Form.VonSE.Value > 0) or (Seiten_Form.BisSE.Value > 0) then
      AP6 := '-dFirstPage=' + VonSpin + ' -dLastPage=' + BisSpin + ' '
    else
      AP6 := '';
    AP1 := '-dNOPAUSE -dDOPDFMARKS -dPreserveMarkedContent=true ' + AP6 + AP4 + '-sDEVICE=pdfwrite' + AP1_5;

    // Die erzeugte PDF-Datei in 128 RC4/AES oder 265 AES umwandeln...
    // qpdf --encrypt --user-password=<password> --owner-password=<password> --bits=128 oder --bits=256 -- somefile.pdf somefile_encrypted.pdf
    if (Encrypt_Form.EncryptCombo.ItemIndex = 0) or (Encrypt_Form.EncryptCombo.ItemIndex = 1) or (Encrypt_Form.EncryptCombo.ItemIndex = 2) then
    begin
      if Encrypt_Form.DruckenCB.Checked then
        DS1 := ' --print=none';
      if Encrypt_Form.HQCB.Checked then
        DS2 := ' --print=low';
      if Encrypt_Form.FormularCB.Checked then
        DS3 := ' --annotate=n --form=n';
      if Encrypt_Form.KopEntCB.Checked then
        DS4 := ' --extract=n';
      if Encrypt_Form.DokuAenderCB.Checked then
        DS5 := ' --modify-other=n';
      DokuSicherheit := DS1 + DS2 + DS3 + DS4 + DS5;
      if Encrypt_Form.DruckenCB.Checked and Encrypt_Form.FormularCB.Checked and
        Encrypt_Form.KopEntCB.Checked and Encrypt_Form.DokuAenderCB.Checked then
        // Alles verboten
        DokuSicherheit := DokuSicherheit + ' --assemble=n';
    end;
    // -------------------------------------------------------------------------
    // Hinweise
    // ========
    // AP1_1: ist der PDF-Level
    // AP1_2: sind die dpi
    // AP1_3: sind die 'distiller parameters'
    // AP1_4: Specify the -dPDFA option: PDF/A-1, -dPDFA=2 for PDF/A-2 or -dPDFA=3 for PDF/A-3
    //        or -dPDFX for PDF/X-3
    // -------------------------------------------------------------------------
    // Ghostscript-Parameter zum Zusammenf�gen der Dateien.

    // In 'files' sind die ausgew�hlten Dateien aus dem Verbinden-Fenster
    files := '';
    if Auswahl_Form.FileList.Items.Count > 0 then
    begin
      for i := 0 to Auswahl_Form.FileList.Items.Count - 1 do
      begin
        files2 := Auswahl_Form.FileList.Items[i].Caption;
        files  := files + ' "' + files2  + '"';
      end;
    end;

    if Einstellungen_Form.PDFA_CB.Checked then
      AX := ' "' + PDFA_1 + '" ';
    if Einstellungen_Form.PDFX.Checked then
      AX := ' "' + PDFX_1 + '" ';
    if (Einstellungen_Form.PDFA_CB.Checked = False) and (Einstellungen_Form.PDFX.Checked = False) then
      AX := ' ';

    // Wenn Erstellung Formatfolder angehakt...
    if Formatverz.Checked then
      // Verzeichnis erstellen der gew�nschten Endung (hier PDF)
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(Ziel) + 'PDF') then
        Ziel := IncludeTrailingBackslash(Ziel) + 'PDF';
    if Formatverz_Date.Checked then
      // Verzeichnis erstellen der gew�nschten Endung (hier PDF + Datum)
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(Ziel) + 'PDF' + ' ' + DateToStr(NOW)) then
        Ziel := IncludeTrailingBackslash(Ziel) + 'PDF' + ' ' + DateToStr(NOW);
    if Formatverz_OnlyDate.Checked then
      // Verzeichnis erstellen der gew�nschten Endung (Datum)
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(Ziel) + DateToStr(NOW)) then
        Ziel := IncludeTrailingBackslash(Ziel) + DateToStr(NOW);

    A1 := AP1_4 + AP1 + A1 + AP1_3 + AP1_2 + AP1_1 + (' -sOutputFile="' + IncludeTrailingBackslash(Ziel) + MERGEDATEI +
          '"' + AX + '-dBATCH' + files) + ' "' + (ExtractFilePath(Application.ExeName) + 'pdfmarks"');

    Memo1.Lines.Text := Memo1.Lines.Text + (Ghostscript + ' ' + A1);
    if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then // 128 RC4
      Memo1.Lines.Text := Memo1.Lines.Text + #13 + (QPDF + ' --allow-weak-crypto --encrypt --user-password="' + Versch5 + '" --owner-password="' + Versch3 + '" --bits=128' +
        DokuSicherheit + ' -- "' + IncludeTrailingBackslash(Ziel) + MERGEDATEI + '" --replace-input="' + IncludeTrailingBackslash(Ziel) + MERGEDATEI + '"');
    if (Encrypt_Form.EncryptCombo.ItemIndex = 1) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then // 128 AES
      Memo1.Lines.Text := Memo1.Lines.Text + #13 + (QPDF + ' --encrypt --user-password="' + Versch5 + '" --owner-password="' + Versch3 + '" --bits=128 --use-aes=y' +
        DokuSicherheit + ' -- "' + IncludeTrailingBackslash(Ziel) + MERGEDATEI + '" --replace-input="' + IncludeTrailingBackslash(Ziel) + MERGEDATEI + '"');
    if (Encrypt_Form.EncryptCombo.ItemIndex = 2) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then // 256 AES
      Memo1.Lines.Text := Memo1.Lines.Text + #13 + (QPDF + ' --encrypt --user-password="' + Versch5 + '" --owner-password="' + Versch3 + '" --bits=256' +
        DokuSicherheit + ' --allow-insecure -- "' + IncludeTrailingBackslash(Ziel) + MERGEDATEI + '" --replace-input="' + IncludeTrailingBackslash(Ziel) + MERGEDATEI + '"');

    // Records initalisieren
    FillChar(StartUp, SizeOf(StartUp), #0);
    FillChar(Process, SizeOf(Process), #0);

    StartUp.cb := SizeOf(StartUp);
    StartUp.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    // Konsolenfenster verbergen
    StartUp.wShowWindow := SW_HIDE;

    // Anonymous Pipe erzeugen
    if CreatePipe(InpHandle, OutpHandle, NIL, 0) then
    begin
      // I/O-Handles setzen
      StartUp.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
      StartUp.hStdOutput := OutpHandle;
      StartUp.hStdError := GetStdHandle(STD_ERROR_HANDLE);;
      Application.ProcessMessages;

      // Aufruf von Ghostscript und Mergen der PDF-Dateien.
      if (Einstellungen_Form.AuswahlRG.ItemIndex <> 0) then
         (Einstellungen_Form.AuswahlRG.ItemIndex := 0); // Umstellung auf (128-Bit) PS/PDF
      begin
        Res := CreateProcess(NIL, PChar(Ghostscript + ' ' + A1),
               NIL, NIL, True, CREATE_DEFAULT_ERROR_MODE or
               CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, NIL, NIL,
               StartUp, Process);
        if Res then
        // Warte auf Beendigung der PDF-Erstellung!
        begin
          repeat
            R := WaitForSingleObject(Process.hProcess, 200); // INFINITE);
            ProgressBar1.Position := ProgressBar1.Position + 5;
            GetExitCodeProcess(Process.hProcess, fExitCode);
          until R <> WAIT_TIMEOUT;
        end;
        // The CloseHandle function closes an open object handle.
        CloseHandle(Process.hProcess);
        CloseHandle(Process.hThread);
      end;

      if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then
      begin // falls gew�nscht, nun die 128-RC4 Verschl�sselung
        PZiel := ExtractFilePath(IncludeTrailingBackslash(Ziel) + MERGEDATEI);
        NZiel := ExtractFileName(IncludeTrailingBackslash(Ziel) + MERGEDATEI);
        QPDFZiel := (PZiel + 'QPDF_' + NZiel);
        QPDF_Zeile := (QPDF + ' --allow-weak-crypto --encrypt --user-password="' + Encrypt_Form.KennwortE.Text +
                      '" --owner-password="' + Encrypt_Form.BerechtigungE.Text + '" --bits=128' + DokuSicherheit +
                      ' -- "' + IncludeTrailingBackslash(Ziel) + MERGEDATEI + '" --replace-input="' +
                      QPDFZiel + '"');
        Res := CreateProcess(NIL, PChar(QPDF_Zeile), NIL, NIL, True,
                             CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                             NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
        if Res then
        // Warte auf Beendigung der PDF-Erstellung!
        begin
          repeat
            R := WaitForSingleObject(Process.hProcess, 200); // INFINITE);
            ProgressBar1.Position := ProgressBar1.Position + 5;
            GetExitCodeProcess(Process.hProcess, fExitCode);
          until R <> WAIT_TIMEOUT;
        end;
        // The CloseHandle function closes an open object handle.
        CloseHandle(Process.hProcess);
        CloseHandle(Process.hThread);
      end else
      if (Encrypt_Form.EncryptCombo.ItemIndex = 1) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then
      begin // falls gew�nscht, nun die 128-AES Verschl�sselung
        PZiel := ExtractFilePath(IncludeTrailingBackslash(Ziel) + MERGEDATEI);
        NZiel := ExtractFileName(IncludeTrailingBackslash(Ziel) + MERGEDATEI);
        QPDFZiel := (PZiel + 'QPDF_' + NZiel);
        QPDF_Zeile := (QPDF + ' --encrypt --user-password="' + Encrypt_Form.KennwortE.Text +
                      '" --owner-password="' + Encrypt_Form.BerechtigungE.Text + '" --bits=128 --use-aes=y' + DokuSicherheit +
                      ' -- "' + IncludeTrailingBackslash(Ziel) + MERGEDATEI + '" --replace-input="' +
                      QPDFZiel + '"');
        Res := CreateProcess(NIL, PChar(QPDF_Zeile), NIL, NIL, True,
                             CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                             NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
        if Res then
        // Warte auf Beendigung der PDF-Erstellung!
        begin
          repeat
            R := WaitForSingleObject(Process.hProcess, 200); // INFINITE);
            ProgressBar1.Position := ProgressBar1.Position + 5;
            GetExitCodeProcess(Process.hProcess, fExitCode);
          until R <> WAIT_TIMEOUT;
        end;
        // The CloseHandle function closes an open object handle.
        CloseHandle(Process.hProcess);
        CloseHandle(Process.hThread);
      end else
      if (Encrypt_Form.EncryptCombo.ItemIndex = 2) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then
      begin // falls gew�nscht, nun die 256-AES Verschl�sselung
        PZiel := ExtractFilePath(IncludeTrailingBackslash(Ziel) + MERGEDATEI);
        NZiel := ExtractFileName(IncludeTrailingBackslash(Ziel) + MERGEDATEI);
        QPDFZiel := (PZiel + 'QPDF_' + NZiel);
        QPDF_Zeile := (QPDF + ' --encrypt --user-password="' + Encrypt_Form.KennwortE.Text +
                      '" --owner-password="' + Encrypt_Form.BerechtigungE.Text + '" --bits=256' + DokuSicherheit +
                      ' --allow-insecure -- "' + IncludeTrailingBackslash(Ziel) + MERGEDATEI + '" --replace-input="' +
                      QPDFZiel + '"');

        Res := CreateProcess(NIL, PChar(QPDF_Zeile), NIL, NIL, True,
                             CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                             NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
        if Res then
        begin
          repeat
            R := WaitForSingleObject(Process.hProcess, 200); // INFINITE);
            ProgressBar1.Position := ProgressBar1.Position + 5;
            GetExitCodeProcess(Process.hProcess, fExitCode);
          until R <> WAIT_TIMEOUT;
        end;
        // The CloseHandle function closes an open object handle.
        CloseHandle(Process.hProcess);
        CloseHandle(Process.hThread);
      end;
    end;

    // PDFmarks wieder l�schen auf Standardeintr�ge
    if DokuInfo_Form.MetadatenCB.Checked = False then
      DokuInfo_Form.Clear.Click;

    if Logdatei.Checked then
    begin
      // Logdatei (FreePDF64Log.txt) �ffnen/beschreiben etc.
      AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
      try
        Append(F);
      except
        Rewrite(F)
      end;

      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ===========> Verbinden: ' + Memo1.Lines.Text));
      for i := 0 to Auswahl_Form.FileList.Items.Count - 1 do
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Dateiname: ' + PChar(Auswahl_Form.FileList.Items[i].Caption)));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + IncludeTrailingBackslash(Ziel) + MERGEDATEI));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(IncludeTrailingBackslash(Ziel) + MERGEDATEI))));

      Closefile(F);
    end;
    // Ende von FreePDF64Log.txt
  end;

  if Formatverz.Checked or Formatverz_Date.Checked then
    s := IncludeTrailingBackslash(Ziel) + s;

  // Verbinden-PDF-Datei mit dem PDF-Anzeiger anzeigen
  // Wenn Aufruf von FreePDF64-Verbinden via Kontextmen� dann...
  if ((Einstellungen_Form.AuswahlRG.ItemIndex = 0) and // PDF
    (Einstellungen_Form.AnzeigenCB.Checked)) or (ParamCount > 0) then
  begin
    if Einstellungen_Form.Edit3.Text = '' then
      PDFReader := ExtractFilePath(Application.ExeName) + 'xpdf\xpdfreader\xpdf.exe'
    else
      PDFReader := Einstellungen_Form.Edit3.Text;
    ShellExecute(Application.Handle, 'open', PChar(PDFReader), PChar('"' + IncludeTrailingBackslash(Ziel) + ExtractFileName(s) + '"'), NIL, SW_SHOWNORMAL);
  end;

  ProgressBar1.Position := 100;

  if Einstellungen_Form.SystemklangCB.Checked then
    PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');

  ProgressBar1.Position := 0;
  Einstellungen_Form.Close;
end;

procedure TFreePDF64_Form.Netzwerk1Click(Sender: TObject);
begin
  LMDShellAppletLoader1.Applet := cplNetwork;
  LMDShellAppletLoader1.Execute;
end;

procedure TFreePDF64_Form.NeuerOrdner1Click(Sender: TObject);
begin
  Btn_NewFolder.Click;
end;

procedure TFreePDF64_Form.NullstellungClick(Sender: TObject);
var
  Msg: String;
begin
  Msg := 'Soll der Erstellz�hler wirklich auf Null gesetzt werden?';
  if MessageDlgCenter(Msg, mtInformation, [mbYes, mbNo]) = mrYes then
    Counter := 0;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers[printer.printerindex] +
    ' | Erstellte Dateien (seit Nullstellung): ' + IntToStr(Counter);
end;

procedure TFreePDF64_Form.MonitorBtnClick(Sender: TObject);
begin
  FavClose;
  // Form soll mittig angezeigt werden.
  FreePDF64_Notify.Position := poMainFormCenter;
  FreePDF64_Notify.ShowModal;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers[printer.printerindex] +
    ' | Erstellte Dateien (seit Nullstellung): ' + IntToStr(Counter);
end;

procedure TFreePDF64_Form.MonitorBtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FavClose;
  if Button = mbRight then
  begin
    if FreePDF64_Notify.LMDShellNotify.Active then
      FreePDF64_Notify.btnStop.Click
    else
      FreePDF64_Notify.btnStart.Click
  end;
  FreePDF64_Notify.OkBitBtn.Click;

  if FreePDF64_Notify.LMDShellNotify.Active = True then
  begin
    MonitorBtn.Caption    := '  AN';
    MonitorBtn.ImageIndex := 57;
  end else
  begin
    MonitorBtn.Caption    := '  AUS';
    MonitorBtn.ImageIndex := 58;
  end;
end;

procedure TFreePDF64_Form.MonitorBtnMouseEnter(Sender: TObject);
begin
  FreePDF64_Form.MonitorBtn.Hint := 'Schnelles AN/AUS durch rechte Maustaste';

  if FreePDF64_Notify.LMDShellNotify.Active then
  begin
    MonitorBtn.ImageIndex := 57;
    MonitorBtn.Caption    := '  AN';
  end else
  begin
    MonitorBtn.ImageIndex := 58;
    MonitorBtn.Caption    := '  AUS';
  end;
end;

procedure TFreePDF64_Form.MonitoringBtnClick(Sender: TObject);
begin
  // Form soll mittig angezeigt werden.
  FreePDF64_Notify.Position := poMainFormCenter;
  FreePDF64_Notify.ShowModal;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers[printer.printerindex] +
    ' | Erstellte Dateien (seit Nullstellung): ' + IntToStr(Counter);
end;

// Dr�cken der rechten Maustaste auf das �berwachungssymbol schaltet diese AN/AUS...
procedure TFreePDF64_Form.MonitoringBtnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
  begin
    if FreePDF64_Notify.LMDShellNotify.Active then
      FreePDF64_Notify.btnStop.Click
    else
      FreePDF64_Notify.btnStart.Click
  end;
  FreePDF64_Notify.OkBitBtn.Click;
end;

procedure TFreePDF64_Form.PanelLResize(Sender: TObject);
begin
  if AutoSpalte.Checked then
  begin
    LMDShellList1.Column[0].AutoSize := True;
    LMDShellList2.Column[0].AutoSize := True;
  end;
end;

procedure TFreePDF64_Form.PanelRResize(Sender: TObject);
begin
  if AutoSpalte.Checked then
  begin
    LMDShellList1.Column[0].AutoSize := True;
    LMDShellList2.Column[0].AutoSize := True;
  end;
end;

procedure TFreePDF64_Form.Papierkorb1Click(Sender: TObject);
begin
  ShowSpecialFolder(CSIDL_BITBUCKET);
end;

procedure TFreePDF64_Form.ParentFolderLClick(Sender: TObject);
begin
  FavClose;
  LMDShellFolder1.LevelUp;
  if LMDShellList1.Selected = NIL then
    LMDShellList1.ItemIndex := 0;
end;

procedure TFreePDF64_Form.ParentFolderRClick(Sender: TObject);
begin
  FavClose;
  LMDShellFolder2.LevelUp;
  if LMDShellList2.Selected = NIL then
    LMDShellList2.ItemIndex := 0;
end;

procedure TFreePDF64_Form.FreePDF64inibearbeiten1Click(Sender: TObject);
var
  FreePDF64Ini: String;
begin
  FreePDF64Ini := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) + 'FreePDF64.ini';
  // Wenn die FreePDF64.ini vorhanden ist, dann...
  if FileExists(FreePDF64Ini) then
    // Editor aufrufen...
    if Einstellungen_Form.Edit2.Text = '' then
      Einstellungen_Form.Edit2.Text := 'notepad.exe';
  ShellExecute(Application.Handle, 'open', PChar(Einstellungen_Form.Edit2.Text),
    PChar(' "' + FreePDF64Ini + '"'), NIL, SW_SHOWNORMAL)
end;

procedure TFreePDF64_Form.FreePDFHowTo1Click(Sender: TObject);
var
  s: String;
begin
  s := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) + 'FreePDF64-HowTo.pdf';
  if not FileExists(s) then
    ShowMessage('''' + s + ''' scheint nicht vorhanden zu sein! Bitte FreePDF64 nochmals neu downloaden.')
  else
  begin
    if Einstellungen_Form.Edit3.Text = '' then
      PDFReader := ExtractFilePath(Application.ExeName) + 'xpdf\xpdfreader\xpdf.exe'
    else
      PDFReader := Einstellungen_Form.Edit3.Text;
    ShellExecute(Application.Handle, 'open', PChar(PDFReader), PChar('"' + s + '"'), NIL, SW_SHOWNORMAL);
  end;
end;

function NowUTC: TDateTime;
var
  SystemTime: TSystemTime;
begin
  GetSystemTime(SystemTime);
  Result := SystemTimeToDateTime(SystemTime);
end;

procedure TFreePDF64_Form.PDF_ErstellungClick(Sender: TObject);
var
  dpi, DP, DP1,
  c, i, j, k, Level, PDFALevel, R: Integer;
  Res: Boolean;
  StartUp: TStartupInfo;
  Process: TProcessInformation;
  InpHandle, OutpHandle: THandle;
  fExitCode: Cardinal;
  AP1, AP1_1, AP1_2, AP1_3, AP1_4, AP1_5, AP3_1, DokuSicherheit, AX, Memozeile,
  DS1, DS2, DS3, DS4, DS5, Spin1, Spin2, VonSpin, BisSpin, Ziel3, Zielanz,
  PZiel, NZiel, QPDFZiel, QPDF_Zeile, z, JV, Endzielname, Datei_Vorne, Datei_Hinten: String;
  F: TextFile;
  ProcID: Cardinal;
begin
  FavClose;

  Timer1.Enabled := False;
  FormatBtn.Enabled := True;
  Feedback.Enabled := True;
  // Ist der Pfad zum Ghostscript-Programm in den Einstellungen eingetragen?
  if not FileExists(Einstellungen_Form.Edit1.Text) then
  begin
    MessageDlgCenter
      ('Der Pfad zum Ghostscriptprogramm ''gswin64c.exe'' fehlt in den Einstellungen'
      + #13 + 'oder ist falsch. Ohne eines dieser Programme arbeitet FreePDF64 leider nicht!',
      mtInformation, [mbOk]);
    Exit;
  end;

  // ACHTUNG: Ziel = Watchfolder der �berwachungsfunktion!
  if ((IncludeTrailingBackslash(Ziel) = IncludeTrailingBackslash(FreePDF64_Notify.LMDShellNotify.WatchFolder)) and
    FreePDF64_Notify.LMDShellNotify.Active) then
  begin
    MessageDlgCenter('Achtung: Zielverzeichnis = �berwachungsverzeichnis' + #13 + #13 +
                     'Das kann zu unkontrolliertem Verhalten bei der' + #13 +
                     'Erstellung f�hren. Bitte �ndern oder solange die' + #13 +
                     '�berwachungsfunktion deaktivieren!', mtWarning, [mbOk]);
    Exit
  end;

  if not FileExists(ExtractFilePath(Application.ExeName) + 'pdfmarks') then
    DokuInfo_Form.BitBtn1.Click;

  // Ist keine Datei ausgew�hlt, dann diese Prozedur beenden...
  if LMDShellList1.SelCount = 0 then
    Exit;

  Ziel := IncludeTrailingBackslash(Ziel);
  try
    Memo1.Clear;
    // Wo liegt das Ghostscript-Programm 'gswin64c.exe'?
    Ghostscript := Einstellungen_Form.Edit1.Text;
    // Wo liegt das QPDF-Programm?
    QPDF := Einstellungen_Form.Edit4.Text;
    Hochkommata := '"';

    // PDF-Level
    Level := Einstellungen_Form.PDFLevel.ItemIndex;
    case Level of
      0: AP1_1 := ' -dCompatibilityLevel=1.4'; // Acrobat 5
      1: AP1_1 := ' -dCompatibilityLevel=1.5'; // Acrobat 6
      2: AP1_1 := ' -dCompatibilityLevel=1.6'; // Acrobat 7
      3: AP1_1 := ' -dCompatibilityLevel=1.7'; // Acrobat 8
    end;

    // Schriftarten/F�llmuster-dpi?
    dpi := Einstellungen_Form.SchriftParams.ItemIndex;
    case dpi of
      0: AP1_2 := ' -r72';
      1: AP1_2 := ' -r96';
      2: AP1_2 := ' -r150';
      3: AP1_2 := ' -r300';
      4: AP1_2 := ' -r600';
      5: AP1_2 := ' -r720';
    end;

    // Welcher Distiller-Parameter?
    DP := Einstellungen_Form.DistParam.ItemIndex;
    case DP of
      0: AP1_3 := ' -DPDFSETTINGS=/default';
      1: AP1_3 := ' -DPDFSETTINGS=/screen';
      2: AP1_3 := ' -DPDFSETTINGS=/ebook';
      3: AP1_3 := ' -DPDFSETTINGS=/printer';
      4: AP1_3 := ' -DPDFSETTINGS=/prepress';
    end;

    // PDF/A-Level
    if Einstellungen_Form.PDFA_CB.Checked = True then
    begin
      PDFALevel := Einstellungen_Form.PDFA.ItemIndex;
      case PDFALevel of
        0: AP1_4 := '-dNOSAFER -dPDFA -sColorConversionStrategy=RGB ';
        1: AP1_4 := '-dNOSAFER -dPDFA=2 -sColorConversionStrategy=RGB ';
        2: AP1_4 := '-dNOSAFER -dPDFA=3 -sColorConversionStrategy=RGB ';
      end;
    end else
      Einstellungen_Form.PDFA_CB.Checked := False;

    // PDF/X-3-Level
    if Einstellungen_Form.PDFX.Checked = True then
      AP1_4 := '-dPDFX -sColorConversionStrategy=CMYK '
    else
      Einstellungen_Form.PDFX.Checked := False;

    // Schnelle Webanzeige
    if Einstellungen_Form.FastCB.Checked then
      AP1_5 := ' -dFastWebView'
    else
      AP1_5 := '';

    DP1 := Einstellungen_Form.AutoRP.ItemIndex;
    case DP1 of
      0: AP4 := '-dAutoRotatePages=/None ';
      1: AP4 := '-dAutoRotatePages=/All ';
      2: AP4 := '-dAutoRotatePages=/PageByPage ';
    end; // of case

    // Parameter und Abfrage auf PDF, PS, JPEG oder TIFF
    Spin1 := IntToStr(Einstellungen_Form.SpinEdit2.Value);
    Spin2 := IntToStr(Einstellungen_Form.SpinEdit1.Value);

    // Seitenentnahme von - bis
    VonSpin := IntToStr(Seiten_Form.VonSE.Value);
    BisSpin := IntToStr(Seiten_Form.BisSE.Value);
    if (Seiten_Form.VonSE.Value > 0) or (Seiten_Form.BisSE.Value > 0) then
      AP6 := '-dFirstPage=' + VonSpin + ' -dLastPage=' + BisSpin + ' '
    else
      AP6 := '';

    case Einstellungen_Form.AuswahlRG.ItemIndex of
      0:  AP1 := '-dNOPAUSE -dDOPDFMARKS -dBATCH -dPreserveMarkedContent=true ' + AP6 + AP4 + '-sDEVICE=pdfwrite' + AP1_5; // PDF
      1:  AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-dSAFER -sDEVICE=ps2write'; // PS
      2:  AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=docxwrite'; // DOCX
      3:  AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=txtwrite'; // TXT
      4:  AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=bmp256 ' + '-r' + Spin2; // BMP
      5:  AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=jpeg -dJPEGQ=' + Spin1 + ' ' + '-r' + Spin2; // JPEG
      6:  AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=png16m ' + '-r' + Spin2; // PNG
      7:  AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=tiffg4 ' + '-r' + Spin2; // TIFF G4
      8:  AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=tifflzw ' + '-r' + Spin2; // TIFF LZW
      9:  AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=tiff24nc ' + '-r' + Spin2;
        // TIFF - 24-bit RGB output (8 bits per component) uncompressed
      11: AP1 := '-dNOPAUSE -dNOSAFER -dBATCH -sDEVICE=pdfwrite' + AP1_5; // JPEG zu PDF
    end;

    // -------------------------------------------------------------------------
    {
      # permission: <number>
      # => The sum of following numbers ---> allows
      # 0 ----------> all rights prohibited  (default)
      # 4    --> printing
      # 8    --> modifying
      # 16   --> copying contents
      # 32   --> adding / changing text annotations
      # 256  --> filling in (existing) formulary fields
      # 512  --> extracting text / graphics
      # 1024 --> assembling the document
      # 2048 --> adding / changing text annotations
      # -1 ----------> all rights permitted

      // Verschl�sselungseinstellungen zuweisen
      Encrypt_Form.EncryptCombo.ItemIndex := Versch1;
      Encrypt_Form.BerechtigungE.Text     := Versch3;
      Encrypt_Form.KennwortE.Text         := Versch5;
      Encrypt_Form.DruckenCB.Checked      := Versch6;
      Encrypt_Form.DokuaenderCB.Checked   := Versch7;
      Encrypt_Form.KopEntCB.Checked       := Versch8;
      Encrypt_Form.InhaltCB.Checked       := Versch9;
      Encrypt_Form.FormularCB.Checked     := Versch10;
      Encrypt_Form.HQCB.Checked           := Versch11;
    }
    // Die erzeugte PDF-Datei in 128-AES oder 265-AES umwandeln...
    if (Encrypt_Form.BerechtigungCB.Checked or Encrypt_Form.KennwortCB.Checked) then
    begin
      if Encrypt_Form.DruckenCB.Checked then
        DS1 := ' --print=none';
      if Encrypt_Form.HQCB.Checked then
        DS2 := ' --print=low';
      if Encrypt_Form.FormularCB.Checked then
        DS3 := ' --annotate=n --form=n';
      if Encrypt_Form.KopEntCB.Checked then
        DS4 := ' --extract=n';
      if Encrypt_Form.DokuAenderCB.Checked then
        DS5 := ' --modify-other=n';
      DokuSicherheit := DS1 + DS2 + DS3 + DS4 + DS5;
      if Encrypt_Form.DruckenCB.Checked and Encrypt_Form.FormularCB.Checked and
        Encrypt_Form.KopEntCB.Checked and Encrypt_Form.DokuAenderCB.Checked then
        // Alles verboten
        DokuSicherheit := DokuSicherheit + ' --assemble=n';
    end;
    // -------------------------------------------------------------------------

    // Records initalisieren
    FillChar(StartUp, SizeOf(StartUp), #0);
    FillChar(Process, SizeOf(Process), #0);
    StartUp.cb := SizeOf(StartUp);
    StartUp.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    // Konsolenfenster verbergen
    StartUp.wShowWindow := SW_HIDE;

    j := 0;
    z := Ziel;
    FAbbrechen := False;

    if Einstellungen_Form.PDFA_CB.Checked then
      AX := ' "' + PDFA_1 + '" ';
    if Einstellungen_Form.PDFX.Checked then
      AX := ' "' + PDFX_1 + '" ';
    if (Einstellungen_Form.PDFA_CB.Checked = False) and (Einstellungen_Form.PDFX.Checked = False) then
      AX := ' ';

    // ----> START
    begin
      AbbrechenPn.Visible := True;
      // Wenn mehrere Dateien markiert sind...
      for i := 0 to LMDShellList1.SelCount - 1 do
      begin
        INC(Counter);
        if (Einstellungen_Form.PDFA_CB.Checked = False) and (Einstellungen_Form.PDFX.Checked = False) then
          AP1_4 := '';
        ProgressBar1.Position := 0;
        // AP3: Welche Datei(en) sollen in PDF umgewandelt werden?
        AP3 := LMDShellList1.SelectedItem.PathName;

        if Einstellungen_Form.ZusatzAnAus.Checked = True then
        begin
          try
            begin
              // Folgende Zeichenketten werden aus den ermittelten Dateinamen beim Drucken in eine PDF-Datei entfernt...
              Endzielname := AP3;
              for c := 0 to Zusatz_Form.ZusatzCB.Items.Count - 1 do
              begin
                AP3 := StringReplace(AP3, Zusatz_Form.ZusatzCB.Items.Strings[c], '', [rfReplaceAll, rfIgnoreCase]);

                 if not RenameFile(Endzielname, AP3) then
//                  ShowMessage('Error renaming file!');
              end;
            end;
          finally
            Application.ProcessMessages;
          end;
        end;

        LMDShellList1.ItemIndex := - 1;

        if (Einstellungen_Form.AuswahlRG.ItemIndex = 0)  or
           (Einstellungen_Form.AuswahlRG.ItemIndex = 10)  or
           (Einstellungen_Form.AuswahlRG.ItemIndex = 11) or
           (Einstellungen_Form.AuswahlRG.ItemIndex = 12) or
           (Einstellungen_Form.AuswahlRG.ItemIndex = 13) then // PDF
          Ziel := (IncludeTrailingBackslash(z) + ChangeFileExt(ExtractFileName(AP3), '.pdf'))
        else if Einstellungen_Form.AuswahlRG.ItemIndex = 1 then // PS
          Ziel := (IncludeTrailingBackslash(z) + ChangeFileExt(ExtractFileName(AP3), '.ps'))
        else if Einstellungen_Form.AuswahlRG.ItemIndex = 2 then // DOCX
          Ziel := (IncludeTrailingBackslash(z) + ChangeFileExt(ExtractFileName(AP3), '.docx'))
        else if Einstellungen_Form.AuswahlRG.ItemIndex = 3 then // TXT
          Ziel := (IncludeTrailingBackslash(z) + ChangeFileExt(ExtractFileName(AP3), '.txt'))
        else if Einstellungen_Form.AuswahlRG.ItemIndex = 4 then // BMP
          Ziel := (IncludeTrailingBackslash(z) + ChangeFileExt(ExtractFileName(AP3), '_%03d.bmp'))
        else if Einstellungen_Form.AuswahlRG.ItemIndex = 5 then // JPEG
          Ziel := (IncludeTrailingBackslash(z) + ChangeFileExt(ExtractFileName(AP3), '_%03d.jpg'))
        else if Einstellungen_Form.AuswahlRG.ItemIndex = 6 then // PNG
          Ziel := (IncludeTrailingBackslash(z) + ChangeFileExt(ExtractFileName(AP3), '_%03d.png'))
        else if (Einstellungen_Form.AuswahlRG.ItemIndex > 6) and
          (Einstellungen_Form.AuswahlRG.ItemIndex < 10) then // TIFF
          Ziel := (IncludeTrailingBackslash(z) + ChangeFileExt(ExtractFileName(AP3), '.tif'));

        // Anonymous Pipe erzeugen
        if CreatePipe(InpHandle, OutpHandle, NIL, 0) then
        begin
          // I/O-Handles setzen
          StartUp.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
          StartUp.hStdOutput := OutpHandle;
          StartUp.hStdError := GetStdHandle(STD_ERROR_HANDLE);;
          // -----------------------------------------------------------------------------
          // Hinweise
          // ========
          // Programmdatei: gswin64c.exe
          // AP1:           Ghostscript-Parameter ('-dNOPAUSE -dDOPDFMARKS -dBATCH -sDEVICE=pdfwrite')
          // Ziel:          Name und Verzeichnis der Zieldatei
          // AP3:           Welche Datei(en) sollen in PDF umgewandelt werden?
          // AP1_1:         ist der PDF-Level
          // AP1_2:         sind die dpi
          // AP1_3:         sind die 'distiller parameters'
          // AP1_4:         Specify the -dPDFA option: PDF/A-1b, -dPDFA=2 for PDF/A-2b or -dPDFA=3 for PDF/A-3b
          //                or -dPDFX for PDF/X-3
          // AP1_5:         Schnelle Webanzeige
          // AP5:           sind die PDFmarks
          // -----------------------------------------------------------------------------
          Application.ProcessMessages;

          // PDFmarks -> Titel (Dateiname ohne Endung), Erstell- und Ge�ndert-Datum
          if DokuInfo_Form.MetadatenCB.Checked = False then
          begin
            if DokuInfo_Form.TitelEdit.Text = '' then
              DokuInfo_Form.TitelEdit.Text := ChangeFileExt(ExtractFileName(Ziel), '');

            if DokuInfo_Form.CreationDateEdit.Text = '' then
              DokuInfo_Form.CreationDateEdit.Text := FormatDateTime('yyyymmddhhnnss', NowUTC);

            if DokuInfo_Form.ModDateEdit.Text = '' then
              DokuInfo_Form.ModDateEdit.Text := FormatDateTime('yyyymmddhhnnss', NowUTC);
          end;

          // PDFmarks speichern...
          DokuInfo_Form.BitBtn1.Click;
          AP5 := ' "' + (ExtractFilePath(Application.ExeName) + 'pdfmarks"');
          Application.HandleMessage;

          // PDFmarks wieder l�schen auf Standardeintr�ge
          if DokuInfo_Form.MetadatenCB.Checked = False then
            DokuInfo_Form.Clear.Click;
          // Variable Ziel zwischenspeichern
          Ziel3 := Ziel;

          // Wenn Erstellung Formatfolder angehakt...
          if Formatverz.Checked then
          begin
            // Verzeichnis erstellen der gew�nschten Endung (z.B. \PDF)
            if System.SysUtils.ForceDirectories(Uppercase(ExtractFilePath(Ziel) + ExtractFileExtensionWithoutDot(Ziel))) then
              Ziel := (IncludeTrailingBackslash(ExtractFilePath(Ziel) + ExtractFileExtensionWithoutDot(Uppercase(Ziel)))) + ExtractFileName(Ziel);
          end else
          // Wenn Erstellung Formatfolder mit Datum angehakt...
          if Formatverz_Date.Checked then
          begin
            // Verzeichnis erstellen der gew�nschten Endung (z.B. \PDF)
            if System.SysUtils.ForceDirectories(Uppercase(ExtractFilePath(Ziel) + ExtractFileExtensionWithoutDot(Ziel) + ' ' + DateToStr(NOW))) then
              Ziel := (IncludeTrailingBackslash(ExtractFilePath(Ziel) + ExtractFileExtensionWithoutDot(Uppercase(Ziel)) + ' ' + DateToStr(NOW))) + ExtractFileName(Ziel);
          end;
          // Wenn Erstellung Formatfolder only Datum angehakt...
          if Formatverz_OnlyDate.Checked then
          begin
            if System.SysUtils.ForceDirectories(Uppercase(ExtractFilePath(Ziel) + DateToStr(NOW))) then
              Ziel := (IncludeTrailingBackslash(ExtractFilePath(Ziel) + DateToStr(NOW))) + ExtractFileName(Ziel);
          end;

          // Wenn die Zieldatei schon vorhanden ist, dann Umbenennen...
          begin
            repeat
              Ziel2 := ChangeFileExt(Ziel, '') + ExtractFileExt(Ziel);
              // Gibt es Ziel2, dann INC...
              if FileExists(Ziel2) then
              begin
                INC(j);
                Ziel2 := ChangeFileExt(Ziel, '') + '_' + IntToStr(j) +
                  ExtractFileExt(Ziel);
              end;
              // Wiederhole alles solange...
            until not FileExists(Ziel2);
            Ziel := Ziel2;
          end;

          // F�r die Erstellung JPEG zu PDF
          AP3_1 := AP3;
          // IncludeTrailingBackslash zu Slash umwandeln
          for k := 1 to Length(AP3_1) do begin
            if AP3_1[k] = '\' then AP3_1[k] := '/';
          end;

          if (Einstellungen_Form.PDFA_CB.Checked or Einstellungen_Form.PDFX.Checked) then
            JV := ' -sOutputFile="' + Ziel + '" ' + AX + ' "' + ViewJPEG + '" -c "('+ AP3_1 +') <</PageSize 2 index viewJPEGgetsize 2 array astore>> setpagedevice viewJPEG"'
          else
            JV := ' -sOutputFile="' + Ziel + '" "' + ViewJPEG + '" -c "('+ AP3_1 +') <</PageSize 2 index viewJPEGgetsize 2 array astore>> setpagedevice viewJPEG"';

          // Erstellung BMP/PNG/TIFF to PDF
          if (Einstellungen_Form.AuswahlRG.ItemIndex = 10) or (Einstellungen_Form.AuswahlRG.ItemIndex = 12) or
             (Einstellungen_Form.AuswahlRG.ItemIndex = 13) then
          begin
            ProcID := 0;
            // Starte nun die richtige Erstellung...
            if RunProcess(ImageMagick + ' -define pdf:Author="" -define pdf:Creator="FreePDF64 (https://github.com/FreePDF64)" "' + AP3 + '" "' + Ziel + Hochkommata, SW_HIDE, True, @ProcID) = 0 then
              Memozeile := ImageMagick + ' -define pdf:Author="" -define pdf:Creator="FreePDF64 (https://github.com/FreePDF64)" "' + AP3 + '" "' + Ziel + Hochkommata;
          end;

          // PDF-Erstellung von 128-Bit PS/PDF
          if (Einstellungen_Form.AuswahlRG.ItemIndex = 0) then // 128-Bit PS/PDF
            Res := CreateProcess(NIL, PChar(Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 +
                   ' ' + '-sOutputFile="' + Ziel + '"' + AX + (Hochkommata + AP3 +
                   Hochkommata + AP5)), NIL, NIL, True, CREATE_DEFAULT_ERROR_MODE or
                   CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, NIL, NIL,
                   StartUp, Process)

          // PDF-Erstellung von JPEG zu PDF, PDF verkleinern nicht gew�nscht
          else if (Einstellungen_Form.PDF_Shrink.Checked = False) and
                  (Einstellungen_Form.AuswahlRG.ItemIndex = 11) then
            Res := CreateProcess(NIL, PChar(Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_1 + JV), NIL, NIL, True,
                   CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
                   NIL, NIL, StartUp, Process)

          // PDF-Erstellung von JPEG zu PDF, PDF verkleinern ist gew�nscht
          else if Einstellungen_Form.PDF_Shrink.Checked and
                 (Einstellungen_Form.AuswahlRG.ItemIndex = 11) then
            Res := CreateProcess(NIL, PChar(Ghostscript + ' ' + AP1 + JV), NIL, NIL, True,
                   CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
                   NIL, NIL, StartUp, Process)

          // Erstellung JPEG/TIFF
          else if (Einstellungen_Form.AuswahlRG.ItemIndex > 0) or
                  (Einstellungen_Form.AuswahlRG.ItemIndex < 10) then
            Res := CreateProcess(NIL, PChar(Ghostscript + ' ' + AP1_4 + AP1 + ' ' + '-sOutputFile="' +
                   Ziel + '"' + AX + (Hochkommata + AP3 + Hochkommata + AP5)), NIL, NIL,
                   True, CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                   NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);

          if Res then
          // Warte auf Beendigung der PDF-Erstellung!
          begin
            repeat
              // Auf Process warten
              // ==================
              // The WaitForSingleObject function returns when one of the following occurs:
              // - The specified object is in the signaled state.
              // - The time-out interval elapses.
              //
              // time-out interval in milliseconds von 500 auf 1000 h�her setzen!
              // oder besser: INFINITE
              //
              R := WaitForSingleObject(Process.hProcess, 200); // INFINITE);
              ProgressBar1.Position := ProgressBar1.Position + 5;
              GetExitCodeProcess(Process.hProcess, fExitCode);
            until R <> WAIT_TIMEOUT;
            // FERTIG! Genug gewartet - Weiter gehts!!!
            // Dateianlage vorne/hinten anf�gen - wenn gew�nscht
            if (Dateianlage_Form.Datei1.Text <> '') or (Dateianlage_Form.Datei2.Text <> '') then
            begin
              if Dateianlage_Form.Datei1.Text <> '' then
                Datei_Vorne := Hochkommata + Dateianlage_Form.Datei1.Text + Hochkommata
              else
                Datei_Vorne := '';
              if Dateianlage_Form.Datei2.Text <> '' then
                Datei_Hinten := Hochkommata + Dateianlage_Form.Datei2.Text + Hochkommata
              else
                Datei_Hinten := '';
              Res := CreateProcess(NIL, PChar(Ghostscript + ' ' + AP1 + ' ' + '-sOutputFile="' + Ziel + '" '
                     + (Datei_Vorne + ' ' + Hochkommata + AP3 + Hochkommata + ' ' + Datei_Hinten + AP5)) ,NIL, NIL, True,
                     CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
              if Res then
              begin
                repeat
                  R := WaitForSingleObject(Process.hProcess, 200);
                  ProgressBar1.Position := ProgressBar1.Position + 5;
                  GetExitCodeProcess(Process.hProcess, fExitCode);
                until R <> WAIT_TIMEOUT;
              end;
              Application.ProcessMessages;
            end;

//========= PDF-Erstellung von PDF zu PDF/JPEG zu PDF, PDF verkleinern ist gew�nscht ======
{
            if Einstellungen_Form.PDF_Shrink.Checked and
              ((Einstellungen_Form.AuswahlRG.ItemIndex = 0) or
              (Einstellungen_Form.AuswahlRG.ItemIndex = 11)) then
}
            if Einstellungen_Form.PDF_Shrink.Checked then
            begin
              // Nun die Erstellung von PDF zu PS
              Res := CreateProcess(NIL,
                PChar(Ghostscript + ' -dNOPAUSE -dBATCH -dSAFER -sDEVICE=ps2write -sOutputFile="' +
                Ziel +'.ps' + '" ' + (Hochkommata + Ziel + Hochkommata)), NIL, NIL,
                True, CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
              if Res then
              begin
                repeat
                  R := WaitForSingleObject(Process.hProcess, 200);
                  ProgressBar1.Position := ProgressBar1.Position + 5;
                  GetExitCodeProcess(Process.hProcess, fExitCode);
                until R <> WAIT_TIMEOUT;
              end;
              Application.ProcessMessages;
              // Nun die Erstellung wieder zur�ck von PS zu PDF
              Res := CreateProcess(NIL,
                PChar(Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 +
                ' ' + '-sOutputFile="' + Ziel + '"' + AX + (Hochkommata + Ziel + '.ps' +
                Hochkommata + AP5)), NIL, NIL, True, CREATE_DEFAULT_ERROR_MODE or
                CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, NIL, NIL,
                StartUp, Process);
              if Res then
              begin
                repeat
                  R := WaitForSingleObject(Process.hProcess, 200);
                  ProgressBar1.Position := ProgressBar1.Position + 5;
                  GetExitCodeProcess(Process.hProcess, fExitCode);
                until R <> WAIT_TIMEOUT;
              end;
              Application.ProcessMessages;
              // L�schen der .ps-Datei des Zwischenerstellschritts
              if not DeleteFile(Ziel + '.ps') then
              begin
                if Einstellungen_Form.SystemklangCB.Checked then
                  PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
                ShowMessage(SysErrorMessage(GetLastError));
              end;
            end;
//==============================================================================
            // Nun die 128-Bit RC4 PDF-Erstellung, wenn gew�nscht... ===========
            if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then
            begin
              PZiel := ExtractFilePath(Ziel);
              NZiel := ExtractFileName(Ziel);
              QPDFZiel := (PZiel + 'QPDF_' + NZiel);

              QPDF_Zeile := (QPDF + ' --allow-weak-crypto --encrypt --user-password="' + Encrypt_Form.KennwortE.Text +
                            '" --owner-password="' + Encrypt_Form.BerechtigungE.Text + '" --bits=128' + DokuSicherheit
                            + ' -- "' + Ziel + '" "' + QPDFZiel + '"');

              Res := CreateProcess(NIL, PChar(QPDF_Zeile), NIL, NIL, True,
                                   CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                                   NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
              if Res then
              begin
                repeat
                  R := WaitForSingleObject(Process.hProcess, 200); // INFINITE);
                  ProgressBar1.Position := ProgressBar1.Position + 5;
                  GetExitCodeProcess(Process.hProcess, fExitCode);
                until R <> WAIT_TIMEOUT;
              end;
              if FileExists(Ziel) then
                DeleteFile(Ziel);

              if not RenameFile(QPDFZiel, PZiel + NZiel) then
              begin
                if Einstellungen_Form.SystemklangCB.Checked then
                  PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
                ShowMessage('Error renaming file!');
              end
            end else
            // .. bis hierhin ==================================================
//==============================================================================
            // Nun die 128-Bit AES PDF-Erstellung, wenn gew�nscht... ===========
            if (Encrypt_Form.EncryptCombo.ItemIndex = 1) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then
            begin
              PZiel := ExtractFilePath(Ziel);
              NZiel := ExtractFileName(Ziel);
              QPDFZiel := (PZiel + 'QPDF_' + NZiel);

              QPDF_Zeile := (QPDF + ' --encrypt --user-password="' + Encrypt_Form.KennwortE.Text +
                            '" --owner-password="' + Encrypt_Form.BerechtigungE.Text + '" --bits=128 --use-aes=y' + DokuSicherheit
                            + ' -- "' + Ziel + '" "' + QPDFZiel + '"');

              Res := CreateProcess(NIL, PChar(QPDF_Zeile), NIL, NIL, True,
                                   CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                                   NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
              if Res then
              begin
                repeat
                  R := WaitForSingleObject(Process.hProcess, 200); // INFINITE);
                  ProgressBar1.Position := ProgressBar1.Position + 5;
                  GetExitCodeProcess(Process.hProcess, fExitCode);
                until R <> WAIT_TIMEOUT;
              end;
              if FileExists(Ziel) then
                DeleteFile(Ziel);

              if not RenameFile(QPDFZiel, PZiel + NZiel) then
              begin
                if Einstellungen_Form.SystemklangCB.Checked then
                  PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
                ShowMessage('Error renaming file!');
              end
            end else
            // .. bis hierhin ==================================================
//==============================================================================
            // Nun die 256-Bit AES PDF-Erstellung, wenn gew�nscht... ===========
            if (Encrypt_Form.EncryptCombo.ItemIndex = 2) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then
            begin
              PZiel := ExtractFilePath(Ziel);
              NZiel := ExtractFileName(Ziel);
              QPDFZiel := (PZiel + 'QPDF_' + NZiel);
              QPDF_Zeile := (QPDF + ' --encrypt --user-password="' + Encrypt_Form.KennwortE.Text +
                            '" --owner-password="' + Encrypt_Form.BerechtigungE.Text + '" --bits=256' + DokuSicherheit
                            + ' --allow-insecure -- "' + Ziel + '" "' + QPDFZiel + '"');

              Res := CreateProcess(NIL, PChar(QPDF_Zeile), NIL, NIL, True,
                                   CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                                   NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
              if Res then
              begin
                repeat
                  R := WaitForSingleObject(Process.hProcess, 200); // INFINITE);
                  ProgressBar1.Position := ProgressBar1.Position + 5;
                  GetExitCodeProcess(Process.hProcess, fExitCode);
                until R <> WAIT_TIMEOUT;
              end;
              if FileExists(Ziel) then
                DeleteFile(Ziel);

              if not RenameFile(QPDFZiel, PZiel + NZiel) then
              begin
                if Einstellungen_Form.SystemklangCB.Checked then
                  PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
                ShowMessage('Error renaming file!');
              end;
            end;
            // .. bis hierhin ==================================================

            // The CloseHandle function closes an open object handle.
            CloseHandle(Process.hThread);
            CloseHandle(Process.hProcess);
          end;

          // Memo f�llen...
          if (Einstellungen_Form.AuswahlRG.ItemIndex = 0) then // Auswahl ist PDF
          begin
            if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then // 128 RC4 ?
            begin
              Memo1.Lines.Text := Memo1.Lines.Text +
                (Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 + ' ' +
                '-sOutputFile="' + Ziel + '"' + AX + (Hochkommata + AP3 + Hochkommata + AP5 + #13));
              Zielanz := Ziel;
              Memo1.Lines.Text := Memo1.Lines.Text +
                (QPDF + ' --allow-weak-crypto --encrypt --user-password="' + Versch5 + '" --owner-password="' + Versch3 + '" --bits=128' +
                DokuSicherheit + ' -- "' + Ziel + '" "' + Ziel
                + '" <- 128-Bit RC4');
            end else
            if (Encrypt_Form.EncryptCombo.ItemIndex = 1) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then // 128 AES ?
            begin
              Memo1.Lines.Text := Memo1.Lines.Text +
                (Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 + ' ' +
                '-sOutputFile="' + Ziel + '"' + AX + (Hochkommata + AP3 + Hochkommata + AP5 + #13));
              Zielanz := Ziel;
              Memo1.Lines.Text := Memo1.Lines.Text +
                (QPDF + ' --encrypt --user-password="' + Versch5 + '" --owner-password="' + Versch3 + '" --bits=128 --use-aes=y' +
                DokuSicherheit + ' -- "' + Ziel + '" "' + Ziel
                + '" <- 128-Bit AES');
            end else
            if (Encrypt_Form.EncryptCombo.ItemIndex = 2) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then // 256 AES ?
            begin
              Memo1.Lines.Text := Memo1.Lines.Text +
                (Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 + ' ' +
                '-sOutputFile="' + Ziel + '"' + AX + (Hochkommata + AP3 + Hochkommata + AP5 + #13));
              Zielanz := Ziel;
              Memo1.Lines.Text := Memo1.Lines.Text +
                (QPDF + ' --encrypt --user-password="' + Versch5 + '" --owner-password="' + Versch3 + '" --bits=256' +
                DokuSicherheit + ' --allow-insecure -- "' + Ziel + '" "' + Ziel
                + '" <- 256-Bit AES');
            end else
            if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and ((Encrypt_Form.BerechtigungCB.Checked) or (Encrypt_Form.KennwortCB.Checked = True)) then // 128 AES ?
            begin
              Memo1.Lines.Text := Memo1.Lines.Text +
                (Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 + ' ' +
                '-sOutputFile="' + Ziel + '"' + AX + (Hochkommata + AP3 + Hochkommata + AP5 +
                ' <- 128-Bit RC4' + #13));
              Zielanz := Ziel;
            end else
            begin
              Memo1.Lines.Text := Memo1.Lines.Text +
                (Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 + ' ' +
                '-sOutputFile="' + Ziel + '"' + AX + (Hochkommata + AP3 + Hochkommata + AP5 + #13));
              Zielanz := Ziel;
            end;
            // Dateianlage vorne/hinten angef�gt
            if Dateianlage_Form.Datei1.Text <> '' then
              Memo1.Lines.Text := Memo1.Lines.Text + 'Datei vorne angef�gt:  ' + Dateianlage_Form.Datei1.Text + #13;
            if Dateianlage_Form.Datei2.Text <> '' then
              Memo1.Lines.Text := Memo1.Lines.Text + 'Datei hinten angef�gt: ' + Dateianlage_Form.Datei2.Text;
          end else
          if Einstellungen_Form.AuswahlRG.ItemIndex = 11 then // JPEG zu PDF
          begin
            Memo1.Lines.Text := Memo1.Lines.Text +
              (Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_1 + JV);
              Zielanz := Ziel;
          end else
          // BMP/PNG/TIFF zu PDF
          if (Einstellungen_Form.AuswahlRG.ItemIndex = 10) or (Einstellungen_Form.AuswahlRG.ItemIndex = 12) or
             (Einstellungen_Form.AuswahlRG.ItemIndex = 13) then
            Memo1.Lines.Text := Memozeile
          else
          begin
            if (Einstellungen_Form.AuswahlRG.ItemIndex > 0) and
               (Einstellungen_Form.AuswahlRG.ItemIndex < 10) then
            // Auswahl ist PS, TXT, BMP, JPG, PNG, TIFF
              Memo1.Lines.Text := Memo1.Lines.Text +
                (Ghostscript + ' ' + AP1_4 + AP1 + ' ' + '-sOutputFile="' + Ziel
                + '"' + AX + (Hochkommata + AP3 + Hochkommata + #13))
            else
              Memo1.Lines.Text := Memo1.Lines.Text +
                (Ghostscript + ' ' + AP1_4 + AP1 + ' ' + '-sOutputFile="' + Ziel
                + '"' + AX + (Hochkommata + AP3 + Hochkommata + AP5 + #13));
          end;

          // Logdatei (FreePDF64Log.txt) �ffnen/beschreiben etc.
          if (FreePDF64_Form.Logdatei.Checked) then
          begin
            AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
            try
              Append(F);
            except
              Rewrite(F)
            end;
            if Einstellungen_Form.PDF_Shrink.Enabled and
               Einstellungen_Form.PDF_Shrink.Checked then
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' =======> Formatauswahl:' + Text_FormatBtn + '- komprimiert')) // PS/PDF/JPEG zu PDF/JPEG/TIFF'
            else
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' =======> Formatauswahl:' + Text_FormatBtn)); // PS/PDF/JPEG zu PDF/JPEG/TIFF'

            if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then // 128 RC4
            begin
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' + Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(AP3))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(AP3)));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(AP3))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Ziel)));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' + (QPDF + ' --allow-weak-crypto --encrypt --user-password="' + Versch5 +
                      '" --owner-password="' + Versch3 + '" --bits=128' + DokuSicherheit + ' -- "' + Ziel + '" "' + Ziel + '"')));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(Ziel)));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Ziel) + ' <- 128-Bit RC4'));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(Ziel))));
            end;

            if (Encrypt_Form.EncryptCombo.ItemIndex = 1) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then // 128 AES
            begin
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' + Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(AP3))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(AP3)));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(AP3))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Ziel)));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' + (QPDF + ' --encrypt --user-password="' + Versch5 +
                      '" --owner-password="' + Versch3 + '" --bits=128 --use-aes=y' + DokuSicherheit + ' -- "' + Ziel + '" "' + Ziel + '"')));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(Ziel)));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Ziel) + ' <- 128-Bit AES'));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(Ziel))));
            end;

            if (Encrypt_Form.EncryptCombo.ItemIndex = 2) and ((Encrypt_Form.BerechtigungCB.Checked = True) or (Encrypt_Form.KennwortCB.Checked = True)) then // 256 AES
            begin
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' + Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(AP3))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(AP3)));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(AP3))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Ziel)));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' + (QPDF + ' --encrypt --user-password="' + Versch5 +
                      '" --owner-password="' + Versch3 + '" --bits=256' + DokuSicherheit + ' --allow-insecure -- "' + Ziel + '" "' + Ziel + '"')));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(Ziel)));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Ziel) + ' <- 256-Bit AES'));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(Ziel))));
            end;

            if ((Encrypt_Form.BerechtigungCB.Checked = False) and (Encrypt_Form.KennwortCB.Checked = False)) then
            begin
              if (Einstellungen_Form.AuswahlRG.ItemIndex = 0) then // PDF
              begin
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' + Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(AP3))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(AP3)));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(AP3))));
                if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and (Encrypt_Form.BerechtigungCB.Checked or Encrypt_Form.KennwortCB.Checked) then // 128 RC4
                begin
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Ziel) + ' <- 128-Bit RC4'))
                end else
                begin
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Ziel)));
                end;
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(Ziel))));

                // Dateianlage vorne/hinten angef�gt
                if Dateianlage_Form.Datei1.Text <> '' then
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -  Datei vorne anf�gen: ' +
                          IncludeTrailingBackslash(ExtractFilePath(Dateianlage_Form.Datei1.Text)) + ExtractFileName(Dateianlage_Form.Datei1.Text)));
                if Dateianlage_Form.Datei2.Text <> '' then
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' - Datei hinten anf�gen: ' +
                          IncludeTrailingBackslash(ExtractFilePath(Dateianlage_Form.Datei2.Text)) + ExtractFileName(Dateianlage_Form.Datei2.Text)));

              end else
              if Einstellungen_Form.AuswahlRG.ItemIndex = 11 then // PDF
              begin
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' + Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_1 + JV));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(AP3))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(AP3)));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(AP3))));
                if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and (Encrypt_Form.BerechtigungCB.Checked or Encrypt_Form.KennwortCB.Checked) then // 128 RC4
                begin
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Ziel) + ' <- 128-Bit RC4'))
                end else
                begin
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Ziel)));
                end;
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(Ziel))))
              end else
              // PS/DOCX/TXT/TIFF
              if (Einstellungen_Form.AuswahlRG.ItemIndex = 1) or
                 (Einstellungen_Form.AuswahlRG.ItemIndex = 2) or
                 (Einstellungen_Form.AuswahlRG.ItemIndex = 3) or
                 (Einstellungen_Form.AuswahlRG.ItemIndex = 7) or
                 (Einstellungen_Form.AuswahlRG.ItemIndex = 8) or
                 (Einstellungen_Form.AuswahlRG.ItemIndex = 9) then
              begin
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' + Ghostscript + ' ' + AP1_4 + AP1));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(AP3))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(AP3)));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(AP3))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Ziel)));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(Ziel))))
              end else
              // BMP, JPEG, PNG
              if (Einstellungen_Form.AuswahlRG.ItemIndex = 4) or
                 (Einstellungen_Form.AuswahlRG.ItemIndex = 5) or
                 (Einstellungen_Form.AuswahlRG.ItemIndex = 6) then
              begin
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' + Ghostscript + ' ' + AP1_4 + AP1));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(AP3))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(AP3)));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(AP3))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Ziel)));
              end else
              // BMP, JPEG, PNG, TIFF zu PDF
              if (Einstellungen_Form.AuswahlRG.ItemIndex = 10) or
                 (Einstellungen_Form.AuswahlRG.ItemIndex = 12) or
                 (Einstellungen_Form.AuswahlRG.ItemIndex = 13) then
              begin
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' + ImageMagick +
                        ' -define pdf:Author="" -define pdf:Creator="FreePDF64 (https://github.com/FreePDF64)" "' + AP3 + '" "' + Ziel + '"'));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -     Quellverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(AP3))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + ExtractFileName(AP3)));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Quelldateigr��e: ' + FormatByteString(MyFileSize(AP3))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -      Zielverzeichnis: ' + IncludeTrailingBackslash(ExtractFilePath(Ziel))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFileName(Ziel)));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -       Zieldateigr��e: ' + FormatByteString(MyFileSize(Ziel))))
              end;
            end;
            Closefile(F);
          end;
          // Ende von FreePDF64Log.txt

          // Dateieintr�ge der Dateianlage wieder l�schen
          if Dateianlage_Form.DateianlageCB.Checked = False then
            Dateianlage_Form.Clear.Click;
        end;
        // Markierte Datei(en) mit einem Anzeigeprogramm anzeigen
        if Einstellungen_Form.AnzeigenCB.Checked then
        begin
          if (Einstellungen_Form.AuswahlRG.ItemIndex = 0) or
             (Einstellungen_Form.AuswahlRG.ItemIndex = 11) then // PDF anzeigen
          begin
            if Zielanz = Ziel then
              Zielanz := Ziel;
            if (Einstellungen_Form.AuswahlRG.ItemIndex = 10) or
               (Einstellungen_Form.AuswahlRG.ItemIndex = 12) or
               (Einstellungen_Form.AuswahlRG.ItemIndex = 13) then // PDF anzeigen
              Zielanz := Ziel;

            // Pause von 1 sec. einbauen...
            Sleep(1000);

            if Einstellungen_Form.Edit3.Text = '' then
              PDFReader := ExtractFilePath(Application.ExeName) + 'xpdf\xpdfreader\xpdf.exe'
            else
              PDFReader := Einstellungen_Form.Edit3.Text;

            if Encrypt_Form.EncryptCombo.ItemIndex = 1 then
              ShellExecute(Application.Handle, 'open', PChar(PDFReader), PChar('"' + Ziel + '"'), NIL, SW_SHOWNORMAL)
            else
              ShellExecute(Application.Handle, 'open', PChar(PDFReader), PChar('"' + Zielanz + '"'), NIL, SW_SHOWNORMAL);
          end else

          if (Einstellungen_Form.AuswahlRG.ItemIndex = 10) or (Einstellungen_Form.AuswahlRG.ItemIndex = 12) or
             (Einstellungen_Form.AuswahlRG.ItemIndex = 13) then // BMP/PNG/TIFF
              ShellExecute(Application.Handle, 'open', PChar(PDFReader), PChar('"' + Ziel + '"'), NIL, SW_SHOWNORMAL)
          else

          if (Einstellungen_Form.AuswahlRG.ItemIndex = 1) or (Einstellungen_Form.AuswahlRG.ItemIndex = 3) then // PS/DOCX/TXT
          begin
            if Einstellungen_Form.Edit2.Text = '' then
              ShellExecute(Application.Handle, NIL, PChar('"' + Ziel + '"'), NIL, NIL, SW_SHOWNORMAL)
            else
              ShellExecute(Application.Handle, 'open',
                PChar(Einstellungen_Form.Edit2.Text), PChar('"' + Ziel + '"'), NIL, SW_SHOWNORMAL);
          end else
          if (Einstellungen_Form.AuswahlRG.ItemIndex > 6) and
                  (Einstellungen_Form.AuswahlRG.ItemIndex < 10) then // TIFF
            ShellExecute(Application.Handle, NIL, PChar('"' + Ziel + '"'), NIL, NIL, SW_SHOWNORMAL);
        end;
        // Progressbar
        ProgressBar1.Position := 100;
        // Abbrechen-Taste gedr�ckt...
        if FAbbrechen = True then
        begin
          ProgressBar1.Position := 0;
          AbbrechenPn.BevelOuter := BvLowered;
          FAbbrechen := False;
          Break;
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      // Wird im Falle eines Fehlers ausgef�hrt...
      ShowMessage(E.ClassName + ': ' + E.Message);
      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
    end;
  end;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers[printer.printerindex] +
    ' | Erstellte Dateien (seit Nullstellung): ' + IntToStr(Counter);

  if Einstellungen_Form.SystemklangCB.Checked then
    PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');
  AbbrechenPn.Visible := False;
  AbbrechenPn.BevelOuter := BvRaised;

  SB_Left;
  SB_Right;

  // Variable Ziel wieder zur�cksetzen
  Ziel := Ziel3;

  // Nach der Erstellung den ersten Eintrag markieren
  LMDShellList1.ItemIndex := 0;

  // Seiten wieder zur�ckstellen
  Seiten_Form.VonSE.Value := 0;
  Seiten_Form.BisSE.Value := 0;

  Ziel := ExtractFilePath(Ziel);
  z := Ziel;
  ProgressBar1.Position := 0;

  LMDShellList1.RefreshData;
  LMDShellList2.RefreshData;
  �berwachung_Erstellung := False;
end;

procedure TFreePDF64_Form.PDF_ErstellungMouseEnter(Sender: TObject);
begin
  Timer1.Enabled := True;
end;

procedure TFreePDF64_Form.PDF_ErstellungMouseLeave(Sender: TObject);
begin
  Timer1.Enabled    := False;
  FormatBtn.Enabled := True;
  Feedback.Enabled  := True;
end;

procedure TFreePDF64_Form.PfadimExplorerffnen1Click(Sender: TObject);
begin
  ShellExecute(Handle, NIL, PChar('explorer'),
    PChar(ExtractFilePath(Application.ExeName)), NIL, SW_Show);
end;

end.
