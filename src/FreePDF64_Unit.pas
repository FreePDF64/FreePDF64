//
// Programmname: FreePDF64
//
// Zweck dieses Programms:
// Erstellung von PDF/PS/JPEG/TIFF/TXT-Dateien aus u.a. Postscript-Dateien.
// Goodie: Die zu erzeugenden Dateien werden in das Eingabeverzeichnis
// gedruckt (über FreePDF64 Postscript-Drucker) oder kopiert und sind nach Erstellung als
// PDF-Datei(en) oder im anderen gewünschten Format im Zielverzeichnis!
//
// Was braucht man außer 'FreePDF64' noch:
// - GhostScript
// - ImageMagick
// - ExifTool
// - QPDF
// - PDFtk
// - Die Xpdf-Tools
// - Optional SumatraPDF
//
// Angefangen im:    Dezember 2021
// Programmiert mit: Embarcadero Delphi 12.1 Community Edition
//
// Hinweis: Wenn ein Formular erzeugt wird und seine Eigenschaft
// Visible auf True gesetzt ist, werden die folgenden
// Ereignisse in der angegebenen Reihenfolge ausgelöst:
// 1.  OnCreate
// 2.  OnShow        -> Form erscheint
// 3.  OnPaint
// 4.  OnActivate
// 5.  OnResize
// 6.  ARBEITEN MIT DEM PROGRAMM
// 7.  PROGRAMM BEENDEN
// 8.  OnCloseQuery
// 9.  OnClose
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
  Vcl.VirtualImageList, Vcl.BaseImageCollection, Vcl.ImageCollection,
  Vcl.AppEvnts, System.Win.TaskbarCore, Vcl.Taskbar,
  LMDVersionInfo, Vcl.OleCtrls, SHDocVw;

const
  WM_TASKBAREVENT = WM_USER + 1; // Taskbar message
  OneKB = 1024;
  OneMB = OneKB * OneKB;
  OneGB = OneKB * OneMB;
  OneTB = Int64(OneKB) * OneGB;

  FOLDERID_UserProfiles: TGUID = '{0762D272-C50A-4BB0-A382-697DCD729B80}';
  FOLDERID_ProgramFiles: TGUID = '{905E63B6-CDF3-4F11-8E03-FFB7CFB0FCB3}';
  FOLDERID_ProgramFilesX86: TGUID = '{7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E}';

type
  TExecuteWaitEvent = procedure(const ProcessInfo: TProcessInformation;
    var ATerminate: Boolean) of object;

type
  TByteStringFormat = (bsfDefault, bsfBytes, bsfKB, bsfMB, bsfGB, bsfTB);

type
  TAutorunKind = (akUserRun, akRun);

type
  TFileBasicInfo = record
    CreationTime: TFileTime;
    LastAccessTime: TFileTime;
    LastWriteTime: TFileTime;
    ChangeTime: TFileTime;
    FileAttributes: Cardinal;
  end;

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
    PanelR: TPanel;
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
    BtnEditor: TSpeedButton;
    Kopieren1: TMenuItem;
    Favoritenspeichern1: TMenuItem;
    Panel_Left: TPanel;
    LMDShellTree1: TLMDShellTree;
    ListBoxL: TListBox;
    Panel2: TPanel;
    DoppelK: TMenuItem;
    AngleichenTB: TToolButton;
    TauschenTB: TToolButton;
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
    Panel_Right: TPanel;
    Panel3: TPanel;
    LMDShellTree2: TLMDShellTree;
    Splitter4: TSplitter;
    PanelLMDShellList2: TPanel;
    LMDShellList2: TLMDShellList;
    ListBoxR: TListBox;
    FavLbR: TListBox;
    RefreshBt: TToolButton;
    ProgressBar1: TProgressBar;
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
    FolderBtn: TToolButton;
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
    Status1: TMenuItem;
    PDFdecrypt: TToolButton;
    LMDOpenDialog1: TLMDOpenDialog;
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
    SearchBtn: TToolButton;
    Suche2: TMenuItem;
    Suche3: TMenuItem;
    SuchemitAltF71: TMenuItem;
    ImageList1: TImageList;
    Formatverz_OnlyDate: TMenuItem;
    ResizeEqual: TMenuItem;
    Nullstellung: TMenuItem;
    AutoSizeBtn: TMenuItem;
    PanelL: TPanel;
    Image2: TImage;
    LMDShellList1: TLMDShellList;
    FavLbL: TListBox;
    StatusBar_Left: TStatusBar;
    Panel1: TPanel;
    RootL: TSpeedButton;
    ParentFolderL: TSpeedButton;
    QuellBtn: TSpeedButton;
    ComboBoxL: TComboBox;
    Quelllabel: TPanel;
    FavSpL: TSpeedButton;
    FavLinks: TSpeedButton;
    Panel4: TPanel;
    ComboBoxR: TComboBox;
    RootR: TSpeedButton;
    ParentFolderR: TSpeedButton;
    FavSpR: TSpeedButton;
    FavRechts: TSpeedButton;
    ZielBtn: TSpeedButton;
    Ziellabel: TPanel;
    AbfrageaufeinneuesUpdate1: TMenuItem;
    LMDVersionInfo1: TLMDVersionInfo;
    Feedback1: TMenuItem;
    PDF_Kompress: TToolButton;
    PDFInformationenanzeigen1: TMenuItem;
    VerwendeteSchriftartenauflisten1: TMenuItem;
    PDFkomprimieren1: TMenuItem;
    LMDShellRestartDialog1: TLMDShellRestartDialog;
    AutoSize: TToolButton;
    ToolButton1: TToolButton;
    ToolButton7: TToolButton;
    MemoBtn: TToolButton;
    SuchenHistorylschen1: TMenuItem;
    Systray_Taskleiste: TMenuItem;
    PaneloverPrgB: TPanel;
    VirtualImageList2: TVirtualImageList;
    ShowNetworkShares: TMenuItem;
    ViewStyleBtn1: TSpeedButton;
    ViewStyleBtn2: TSpeedButton;
    AutoFormat: TMenuItem;
    Bereinigung1: TMenuItem;
    N20: TMenuItem;
    N21: TMenuItem;
    PDFWerkzeuge1: TMenuItem;
    PortMonitorlogansehen1: TMenuItem;
    LogundStatusinformationen1: TMenuItem;
    Netzlaufwerk1: TMenuItem;
    Oberflche1: TMenuItem;
    PDFErstellung1: TMenuItem;
    Programmfenster1: TMenuItem;
    Dateisystem1: TMenuItem;
    WindowsIntegration1: TMenuItem;
    UPD: TMenuItem;
    PortMonitorLoglschen1: TMenuItem;
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
    procedure AutostartClick(Sender: TObject);
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
    procedure Verbinden1Click(Sender: TObject);
    procedure Allemarkieren1Click(Sender: TObject);
    procedure LMDShellList1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure TaskManager1Click(Sender: TObject);
    procedure AbbrechenPnClick(Sender: TObject);
    procedure ExtractBtnClick(Sender: TObject);
    procedure Btn_ViewClick(Sender: TObject);
    procedure Sendenan1Click(Sender: TObject);
    procedure FolderBtnClick(Sender: TObject);
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
    procedure MonitorBtnClick(Sender: TObject);
    procedure MonitorBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StatusBitBtnClick(Sender: TObject);
    procedure Status1Click(Sender: TObject);
    procedure Statusinformationen1Click(Sender: TObject);
    procedure LMDShellList1Click(Sender: TObject);
    procedure LMDShellTree1Click(Sender: TObject);
    procedure LMDShellTree2Click(Sender: TObject);
    procedure LMDShellList2Click(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure Memo1Click(Sender: TObject);
    procedure MainMenu1Change(Sender: TObject; Source: TMenuItem;
      Rebuild: Boolean);
    procedure HTMLBtnClick(Sender: TObject);
    procedure PDFInfoBtnClick(Sender: TObject);
    procedure PDFAttachmentClick(Sender: TObject);
    procedure AnlagenBtnClick(Sender: TObject);
    procedure PDFRemoveClick(Sender: TObject);
    procedure PDFFontsBtnClick(Sender: TObject);
    procedure MonitorBtnMouseEnter(Sender: TObject);
    procedure TrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ComboBoxLCloseUp(Sender: TObject);
    procedure ComboBoxRCloseUp(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Image1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Image2ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Image2Click(Sender: TObject);
    procedure SearchBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LMDShellList2Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure Formatverz_OnlyDateClick(Sender: TObject);
    procedure ResizeEqualClick(Sender: TObject);
    procedure NullstellungClick(Sender: TObject);
    procedure LMDShellList2ColumnClick(Sender: TObject; Column: TListColumn);
    procedure LMDShellList1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure RootLClick(Sender: TObject);
    procedure RootRClick(Sender: TObject);
    procedure AutoSizeClick(Sender: TObject);
    procedure AutoSizeBtnClick(Sender: TObject);
    procedure Btn_ViewMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Btn_ViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Btn_RenameMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Btn_CopyMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Btn_MoveMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Btn_NewFolderMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Btn_DeleteMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Btn_DeleteMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Btn_NewFolderMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BtnEditorMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Btn_RenameMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormatBtnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormatBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BtnEditorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AbfrageaufeinneuesUpdate1Click(Sender: TObject);
    procedure PDF_KompressClick(Sender: TObject);
    procedure Memo1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure LogBtMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MemoBtnClick(Sender: TObject);
    procedure Memo1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Memo1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure SuchenHistorylschen1Click(Sender: TObject);
    procedure Systray_TaskleisteClick(Sender: TObject);
    procedure LMDShellList1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LMDShellList2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ZiellabelClick(Sender: TObject);
    procedure QuelllabelClick(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure Logdateiansehen2Click(Sender: TObject);
    procedure LMDShellList1FilterItem(Sender: TObject; ShellItem: TLMDCustomShellItem; var Accept: Boolean);
    procedure LMDShellList2FilterItem(Sender: TObject; ShellItem: TLMDCustomShellItem; var Accept: Boolean);
    procedure LMDShellTree1FilterItem(Sender: TObject; ShellItem: TLMDCustomShellItem; var Accept: Boolean);
    procedure LMDShellTree2FilterItem(Sender: TObject; ShellItem: TLMDCustomShellItem; var Accept: Boolean);
    procedure ShowNetworkSharesClick(Sender: TObject);
    procedure ViewStyleBtn2Click(Sender: TObject);
    procedure ViewStyleBtn1Click(Sender: TObject);
    procedure LMDShellList1InfoTip(Sender: TObject; Item: TListItem;
      var InfoTip: string);
    procedure LMDShellList2InfoTip(Sender: TObject; Item: TListItem;
      var InfoTip: string);
    procedure AutoFormatClick(Sender: TObject);
    procedure PortMonitorlogansehen1Click(Sender: TObject);
    procedure UPDClick(Sender: TObject);
    procedure Btn_RenameMouseEnter(Sender: TObject);
    procedure LMDShellTree1Editing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure LMDShellTree2Editing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure LMDShellTree2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LMDShellTree1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PortMonitorLoglschen1Click(Sender: TObject);
    private
      { Private-Deklarationen }
      wcActive, wcPrevious: TWinControl;
      FSortColumn, FSortColumn2: Integer;
      FSortAscending, FSortAscending2: Boolean;
      FDirectoryNavigation1: Boolean;
      F2Pressed: Boolean;
    public
      { Public-Deklarationen }
      PDF_UeberwachungsDatei: string;
      FormLoaded: Boolean;
      procedure AllesSpeichern;
      procedure FavClose;
      procedure PlaySoundFile(FileName: string);
      procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
      procedure WMSettingChange(var Message: TMessage); message WM_SETTINGCHANGE;
      procedure WMQueryEndSession(var Msg: TWMQueryEndSession); message WM_QUERYENDSESSION;
      procedure ActiveControlChanged(Sender: TObject);
    protected
    published
      { Doppelclick auf Splitter }
      property OnDblClick;
  end;

var
  FreePDF64_Form: TFreePDF64_Form;
  // Globale Variablen
  Left, Top, Width, Height: Integer;
  AP4, AP5, AP6, Editor, Ghostscript, ViewJPEG, QPDF, STA1, STA2, Auswahl,
    ImageMagick, ExifTool, GE, Versch3, Versch5, A_S, B_Z, Ziel, AP3,
    MERGEDATEI, Ziel2, MonitoringFile, StartFolder, Text_FormatBtn, PDFA_1,
    PDFX_1, XPDF_Images, XPDF_ToHTML, XPDF_Detach, XPDF_Fonts: String;
  ParaJN, Versch1, Vol1, Vol2, PDFPanelH, MHA, Counter: Integer;
  ABBRUCH, LI, RE, LF, RF, Versch6, Versch7, Versch8, Versch9, Versch10,
    Versch11, Do1, In1, Überwachung_Erstellung, Links, Rechts,
    Windows_Session_End, FAbbrechen, Splash, Tray1, Popup_Aufruf, AutospalteJN,
    ShowVomTray, Suche_ItemAnzeigen, Info_Anzeigen: Boolean;
  Baum: Byte;
  Hochkommata: String[1];
  KnownNetworkDrives: array['A'..'Z'] of string;
  HinweisAutoFormat: Boolean = True;

implementation

uses
  Einstellungen_Unit, Encrypt_Unit, DokuInfo_Unit,
  Seiten_Unit, Favoriten_Unit, Favoriten2_Unit, Auswahl_Unit,
  Info_Unit, FreePDF64_Notify_Unit, Einstellungen_Hilfe_Unit,
  Filter_Unit, Wasserzeichen_Unit, Zusatz_Unit, Splashscreen_Unit,
  Dateianlage_Unit, Status_Unit, Anleitung_Unit, Suchen, uPDFBrowserForm,
  FreePDF64PrinterConfig;

{$R *.DFM}
{$R FreePDF64.res}

// Schnelles Anhängen an das Memo.
// AppendMemoText(... kopiert bei jedem Aufruf
// den kompletten bisherigen Inhalt und wird bei großen Logs zunehmend langsam.
procedure AppendMemoText(const S: string);
var
  P: Integer;
begin
  if S = '' then
    Exit;

  P := FreePDF64_Form.Memo1.GetTextLen;
  FreePDF64_Form.Memo1.SelStart := P;
  FreePDF64_Form.Memo1.SelLength := 0;
  FreePDF64_Form.Memo1.SelText := S;
  FreePDF64_Form.Memo1.SelStart := P + Length(S);
end;

// Klick auf Splitter2 registrieren
procedure Register;
begin
  RegisterComponents('Samples', [TClickSplitter]);
end;

procedure TFreePDF64_Form.ActiveControlChanged(Sender: TObject);
begin
  wcPrevious := wcActive;
  wcActive := FreePDF64_Form.ActiveControl;
end;

// Doppelklick auf Splitter2
procedure TFreePDF64_Form.SplDblClick(Sender: TObject);

  procedure HideImage(img: TImage; showList: TLMDShellList);
  begin
    img.Visible := False;
    img.Picture := nil;
    showList.Visible := True;
  end;

  procedure SetAutoSize(All: Boolean);
  begin
    LMDShellList1.Column[0].AutoSize := All;
    LMDShellList2.Column[0].AutoSize := All;
  end;

var
  a: Boolean;
begin
  // JPEG-Fenster schließen
  if Image1.Visible then
    HideImage(Image1, LMDShellList2)
  else if Image2.Visible then
    HideImage(Image2, LMDShellList1);

  // AutoSize temporär aktivieren
  a := LMDShellList1.Column[0].AutoSize;
  SetAutoSize(True);

  // Splitter soll sich in der Mitte befinden
  PanelR.Width := (PanelL.Width + PanelR.Width) div 2;

  // AutoSize zurücksetzen
  SetAutoSize(a);

  Sleep(100);
  RefreshBt.Click;
end;

// Doppelklick auf Splitter3
procedure TFreePDF64_Form.SplDblClick3(Sender: TObject);
begin
  if not FileExists(IncludeTrailingBackslash
    (ExtractFilePath(Application.ExeName)) + 'FreePDF64.ini') then
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

procedure QL;
var
  s: String;
begin
  s := 'Quelle - ' + FreePDF64_Notify.MonitoringFolder.Text + '*.*';
  if (FreePDF64_Form.Quelllabel.Caption = s) and
    (FreePDF64_Form.MonitorBtn.ImageIndex = 57) then
    FreePDF64_Form.Quelllabel.Font.Color := clRed
  else
    FreePDF64_Form.Quelllabel.Font.Color := clWindowText
end;

procedure ZL;
var
  s: String;
begin
  s := 'Ziel - ' + FreePDF64_Notify.MonitoringFolder.Text + '*.*';
  if (FreePDF64_Form.Ziellabel.Caption = s) and
    (FreePDF64_Form.MonitorBtn.ImageIndex = 57) then
    FreePDF64_Form.Ziellabel.Font.Color := clRed
  else
    FreePDF64_Form.Ziellabel.Font.Color := clWindowText
end;

procedure TFreePDF64_Form.StatusBitBtnClick(Sender: TObject);
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if Assigned(wcPrevious) then
  begin
    if wcPrevious = LMDShellList1 then
      LMDShellList1.SetFocus
    else if wcPrevious = LMDShellList2 then
      LMDShellList2.SetFocus;
  end;

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
  Buffer: array [0 .. 51] of Char;
begin
  for I := 0 to 25 do
    Buffer[I] := Chr(I + Ord('A'));
  for I := 0 to 25 do
    Buffer[I + 26] := Chr(I + Ord('a'));
  GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
  Result.X := Result.X div 52;
end;

function UniInputQuery(const ACaption, APrompt: string;
                       var Value: string;
                       const AHint: string = '';
                       const MultiLine: Boolean = False;
                       const Password: Boolean = False): Boolean;
const
  SOK     = 'OK';
  SCancel = 'Abbrechen';

  function DUx(Form: TForm; v: Integer): Integer;
  begin
    Result := MulDiv(v, Form.Canvas.TextWidth('0'), 4);
  end;

  function DUy(Form: TForm; v: Integer): Integer;
  begin
    Result := MulDiv(v, Form.Canvas.TextHeight('0'), 8);
  end;

  procedure CenterOnMain(Form: TForm);
  var
    X, Y: Integer;
  begin
    X := Application.MainForm.Left +
         (Application.MainForm.Width - Form.Width) div 2;
    Y := Application.MainForm.Top +
         (Application.MainForm.Height - Form.Height) div 2;

    if X < 0 then X := 0;
    if X + Form.Width > Screen.Width then
      X := Screen.Width - Form.Width;

    if Y < 0 then Y := 0;
    if Y + Form.Height > Screen.Height then
      Y := Screen.Height - Form.Height;

    Form.SetBounds(X, Y, Form.Width, Form.Height);
  end;

var
  Form: TForm;
  Prompt: TLabel;
  Edit: TWinControl;
  BtnTop, BtnW, BtnH: Integer;
begin
  Result := False;

  Form := TForm.Create(Application);
  try
    Form.BorderStyle := bsDialog;
    Form.Caption := ACaption;
    Form.Canvas.Font := Form.Font;

    // Basisgröße
    Form.ClientWidth  := DUx(Form, 193);
    Form.ClientHeight := DUy(Form, If MultiLine then 110 else 70);

    CenterOnMain(Form);

    // Prompt
    Prompt := TLabel.Create(Form);
    Prompt.Parent := Form;
    Prompt.AutoSize := True;
    Prompt.Left := DUx(Form, 8);
    Prompt.Top := DUy(Form, 8);
    Prompt.Caption := APrompt;
    if AHint <> '' then
    begin
      Prompt.ShowHint := True;
      Prompt.Hint := AHint;
      Prompt.Cursor := crHandPoint;
    end;

    // Edit / Memo
    if MultiLine then
    begin
      var Memo := TMemo.Create(Form);
      Edit := Memo;
      Memo.ScrollBars := ssVertical;
      Memo.WordWrap := True;
      Memo.Lines.Text := Value;
    end
    else
    begin
      var E := TEdit.Create(Form);
      Edit := E;
      E.Text := Value;
      E.MaxLength := 255;
      if Password then
        E.PasswordChar := '*';
    end;

    Edit.Parent := Form;
    Edit.Left := Prompt.Left;
    Edit.Top := DUy(Form, If MultiLine then 28 else 22);

    Edit.Width := DUx(Form, 176);
    if MultiLine then
      Edit.Height := DUy(Form, 60);

    // Button
    BtnTop := DUy(Form, If MultiLine then 95 else 48);

    BtnW   := DUx(Form, 50);
    BtnH   := DUy(Form, 14);

    with TButton.Create(Form) do
    begin
      Parent := Form;
      Caption := SOK;
      ModalResult := mrOk;
      Default := True;
      SetBounds(DUx(Form, 38), BtnTop, BtnW, BtnH);
    end;

    with TButton.Create(Form) do
    begin
      Parent := Form;
      Caption := SCancel;
      ModalResult := mrCancel;
      Cancel := True;
      SetBounds(DUx(Form, 102), BtnTop, BtnW, BtnH);
    end;

    // Ergebnis
    if Form.ShowModal = mrOk then
    begin
      if MultiLine then
        Value := TMemo(Edit).Lines.Text
      else
        Value := TEdit(Edit).Text;

      Result := True;
    end;
  finally
    Form.Free;
  end;
end;

// Größe der Datei angeben
function MyFileSize(const FileName: string): Int64;
var
  Data: WIN32_FILE_ATTRIBUTE_DATA;
begin
  Result := 0;
  // GetFileAttributesEx ist für eine einzelne Datei schneller als FindFirst,
  // da keine Suchstruktur aufgebaut werden muss.
  if GetFileAttributesEx(PChar(FileName), GetFileExInfoStandard, @Data) then
    Result := (Int64(Data.nFileSizeHigh) shl 32) or Data.nFileSizeLow;
end; { MyFileSize }

// Prozentualen Anteil der ersten Datei an der zweiten Datei ermitteln.
// Wird für die Anzeige der PDF-Komprimierung verwendet.
function FileSizePercent(const NumeratorFile, DenominatorFile: string): Integer;
var
  Numerator, Denominator: Int64;
  Value: Double;
begin
  Numerator := MyFileSize(NumeratorFile);
  Denominator := MyFileSize(DenominatorFile);

  if Denominator <= 0 then
    Exit(0);

  Value := (Numerator / Denominator) * 100.0;
  if Value <= 0 then
    Exit(0);
  if Value >= MaxInt then
    Exit(MaxInt);

  Result := Round(Value);
end;

// MessageDlg zentriert
function MessageDlgCenter(const Msg: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons): Integer;
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
function FormatByteString(Bytes: UInt64;
  Format: TByteStringFormat = bsfDefault): string;
begin
  if Format = bsfDefault then
    if      Bytes < OneKB then Format := bsfBytes
    else if Bytes < OneMB then Format := bsfKB
    else if Bytes < OneGB then Format := bsfMB
    else if Bytes < OneTB then Format := bsfGB
    else                     Format := bsfTB;

  case Format of
    bsfBytes: Result := System.SysUtils.Format('%d Bytes', [Bytes]);
    bsfKB:    Result := System.SysUtils.Format('%.2n KB', [Bytes / OneKB]);
    bsfMB:    Result := System.SysUtils.Format('%.2n MB', [Bytes / OneMB]);
    bsfGB:    Result := System.SysUtils.Format('%.2n GB', [Bytes / OneGB]);
    bsfTB:    Result := System.SysUtils.Format('%.2n TB', [Bytes / OneTB]);
  end;
end;

// Create Process and Wait for Exit
function RunProcess(FileName: string; ShowCmd: DWORD; wait: Boolean;
  ProcID: PDWORD): Longword;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  Result := WAIT_FAILED;
  FillChar(StartupInfo, SizeOf(StartupInfo), 0);
  FillChar(ProcessInfo, SizeOf(ProcessInfo), 0);

  if Trim(FileName) = '' then
    Exit;

  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
  StartupInfo.wShowWindow := ShowCmd;
  if not CreateProcess(nil, PChar(FileName), nil, nil, False,
    CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo,
    ProcessInfo) then
    Exit
  else
  begin
    if not wait then
    begin
      if ProcID <> NIL then
        ProcID^ := ProcessInfo.dwProcessId;
      // Handles werden auch bei asynchronem Start sofort geschlossen.
      // Der Prozess selbst läuft unabhängig davon weiter.
      CloseHandle(ProcessInfo.hProcess);
      CloseHandle(ProcessInfo.hThread);
      ProcessInfo.hProcess := 0;
      ProcessInfo.hThread := 0;
      Result := WAIT_FAILED;
      Exit;
    end;
    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
    GetExitCodeProcess(ProcessInfo.hProcess, Result);
  end;
  if ProcessInfo.hProcess <> 0 then
    CloseHandle(ProcessInfo.hProcess);
  if ProcessInfo.hThread <> 0 then
    CloseHandle(ProcessInfo.hThread);
end;

// Wasserzeichen/Stempel hinzufügen
procedure TFreePDF64_Form.WZSTTBClick(Sender: TObject);
var
  I: Integer;
  F: TextFile;
  WZST, WZST2, Zeile: String;
  ProcID: Cardinal;
  PDFForm: TPDFBrowserForm;
begin
  FavClose;

  // Gibt das Steuerelement an, das momentan den Eingabefokus hat
  if Screen.ActiveControl = LMDShellList2 then
  begin
    MessageDlgCenter
      ('PDF Wasserzeichen/Stempel einfügen: Bitte PDF-Datei(en) aus dem Quellverzeichnis auswählen!',
      mtInformation, [mbOk]);
    Exit;
  end;

  Wasserzeichen_Form.Caption := 'Wasserzeichen/Stempel: ' +
    IntToStr(LMDShellList1.SelCount) + ' Datei(en) markiert';

  if Einstellungen_Form.Edit5.Text = '' then
    Einstellungen_Form.Edit5.Text := ExtractFilePath(Application.ExeName) +
      'pdftk\pdftk.exe';

  if LMDShellList1.Focused and (LMDShellList1.SelCount > 0) then
  begin
    // Form soll mittig angezeigt werden.
    Wasserzeichen_Form.Position := poMainFormCenter;
    if Wasserzeichen_Form.ShowModal = mrOk then
      ABBRUCH := False;

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
  end;

  // Wenn Abbrechen geklickt wurde...
  if (ABBRUCH = True) or (Wasserzeichen_Form.Edit1.Text = '') then
    Exit
  else
  begin
    if LMDShellList1.Focused and Assigned(LMDShellList1.Selected) then
    begin
      // Verzeichnis erstellen der gewünschten Endung (\PDF)
      if System.SysUtils.ForceDirectories
        (IncludeTrailingBackslash(Wasserzeichen_Form.Edit2.Text)) then
        // Wenn mehrere Dateien markiert sind...
        for I := 0 to LMDShellList1.SelCount - 1 do
        begin
          Memo1.Lines.Clear;
          // AP3: Welche PDF-Datei(en) soll ein Wasserzeichen erhalten?
          AP3 := IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName)
            + LMDShellList1.SelectedItems[I].DisplayName;

          if Uppercase(ExtractFileExt(AP3)) <> ('.PDF') then
          begin
            MessageDlgCenter
              ('PDF Wasserzeichen/Stempel einfügen: Bitte PDF-Datei(en) aus dem Quellverzeichnis auswählen!',
              mtInformation, [mbOk]);
            Exit;
          end;

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
              '" hat vermutlich Einschränkungen (Kennwortschutz, etc).' + #13 +
              'Das Hinzufügen von Wasserzeichen/Stamp geht dann leider nicht. Abhilfe wäre,'
              + #13 + 'diese Einschränkungen vorher zu entfernen (...das geht mit FreePDF64)!',
              mtError, [mbOk])
          else
          begin
            // Memo füllen...
            AppendMemoText(Einstellungen_Form.Edit5.Text
              + ' ' + AP3 + ' ' + WZST + ' ' + Wasserzeichen_Form.Edit1.Text +
              ' output ' + IncludeTrailingBackslash
              (Wasserzeichen_Form.Edit2.Text) + WZST2 + ExtractFileName(AP3));
            // Bis hierhin...

            // FreePDF64Log.txt
            if Logdatei.Checked then
            begin
              // Logdatei (FreePDF64Log.txt) öffnen/beschreiben etc.
              AssignFile(F, PChar(ExtractFilePath(Application.ExeName) +
                'FreePDF64Log.txt'));
              try
                Append(F);
              except
                Rewrite(F)
              end;
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                ' ==========> WZ/STEMPEL: ' + Memo1.Lines.Text));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                ' -           Quelldatei: ' + AP3));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                ' -           Dateigröße: ' +
                FormatByteString(MyFileSize(AP3))));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                ' -          WZ/ST-Datei: ' + Wasserzeichen_Form.Edit1.Text));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                ' -            Zieldatei: ' + IncludeTrailingBackslash
                (Wasserzeichen_Form.Edit2.Text) + WZST2 +
                ExtractFileName(AP3)));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                ' -           Dateigröße: ' +
                FormatByteString(MyFileSize(IncludeTrailingBackslash
                (Wasserzeichen_Form.Edit2.Text) + WZST2 +
                ExtractFileName(AP3)))));
              Closefile(F);

              // Mit der PDFForm anzeigen
              if Einstellungen_Form.AnzeigenCB.Checked then
              begin
                PDFForm := TPDFBrowserForm.Create(Self);
                PDFForm.PDFFileName := IncludeTrailingBackslash(Wasserzeichen_Form.Edit2.Text) + WZST2 + ExtractFileName(AP3);
                PDFForm.Show;
                Application.ProcessMessages;
              end;
            end;
            // Ende von FreePDF64Log.txt
            ProgressBar1.Position := 100;
          end;
          if Einstellungen_Form.SystemklangCB.Checked then
            PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');
        end;
    end;
    // LMDShellList1.ClearSelection;
  end;
  ProgressBar1.Position := 0;

  LMDShellList1.SetFocus;
end;

// Ausgabe Consolelog -> Memofenster
procedure GetDosOutput(Output: TMemo; CommandLine: String; Work: String);
var
  SA: TSecurityAttributes;
  SI: TStartupInfo;
  PI: TProcessInformation;
  StdOutPipeRead, StdOutPipeWrite: THandle;
  WasOK: Boolean;
  Buffer: array [0 .. 255] of AnsiChar;
  BytesRead: Cardinal;
  WorkDir: string;
  ProcessCreated: Boolean;
begin
  // Memo-Inhalt-Schriftfarbe auf Weiss setzen
  FreePDF64_Form.Memo1.Font.Color := clWhite;

  StdOutPipeRead := 0;
  StdOutPipeWrite := 0;
  FillChar(SI, SizeOf(SI), 0);
  FillChar(PI, SizeOf(PI), 0);

  FillChar(SA, SizeOf(SA), 0);
  SA.nLength := SizeOf(SA);
  SA.bInheritHandle := True;
  SA.lpSecurityDescriptor := nil;

  ProcessCreated := False;
  if not CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0) then
  begin
    FreePDF64_Form.Memo1.Font.Color := clBlack;
    Exit;
  end;

  try
    // Das Leseende darf nicht an den gestarteten Prozess vererbt werden.
    // Dadurch kann ReadFile zuverlässig EOF erkennen, sobald der Prozess
    // sein Ausgaberohr geschlossen hat.
    SetHandleInformation(StdOutPipeRead, HANDLE_FLAG_INHERIT, 0);

    SI.cb := SizeOf(SI);
    SI.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    SI.wShowWindow := SW_HIDE;
    SI.hStdInput := GetStdHandle(STD_INPUT_HANDLE);
    SI.hStdOutput := StdOutPipeWrite;
    SI.hStdError := StdOutPipeWrite;

    WorkDir := Work;
    ProcessCreated := CreateProcess(nil, PChar('cmd.exe /C ' + CommandLine),
      nil, nil, True, 0, nil, PChar(WorkDir), SI, PI);

    // Das Schreibende wird im Elternprozess nicht mehr benötigt.
    CloseHandle(StdOutPipeWrite);
    StdOutPipeWrite := 0;

    if ProcessCreated then
    begin
      try
        repeat
          WasOK := ReadFile(StdOutPipeRead, Buffer, SizeOf(Buffer) - 1,
            BytesRead, nil);
          if WasOK and (BytesRead > 0) then
          begin
            Buffer[BytesRead] := #0;
            Output.SelStart := Output.GetTextLen;
            Output.SelLength := 0;
            Output.SelText := Buffer;
          end;
        until (not WasOK) or (BytesRead = 0);

        WaitForSingleObject(PI.hProcess, INFINITE);
      finally
        CloseHandle(PI.hThread);
        CloseHandle(PI.hProcess);
        PI.hThread := 0;
        PI.hProcess := 0;
      end;
    end;
  finally
    if StdOutPipeWrite <> 0 then
      CloseHandle(StdOutPipeWrite);
    if StdOutPipeRead <> 0 then
      CloseHandle(StdOutPipeRead);
  end;

  // Memo-Inhalt-Schriftfarbe wieder auf Schwarz setzen
  FreePDF64_Form.Memo1.Font.Color := clBlack;
end;

// Anlage(n) einer PDF-Datei hinzufügen
procedure TFreePDF64_Form.AnlagenBtnClick(Sender: TObject);
var
  PDFDatei, Zieldatei, Anlage, Zeile, Beschreibung: String;
  ProcID: Cardinal;
  F: TextFile;
  PDFForm: TPDFBrowserForm;

  function GetSelectedPDF: string;
  var
    SL: TLMDShellList;
    SF: TLMDShellFolder;
  begin
    if LMDShellList1.Focused then
    begin
      SL := LMDShellList1;
      SF := LMDShellFolder1;
    end
    else
    begin
      SL := LMDShellList2;
      SF := LMDShellFolder2;
    end;

    if SL.SelCount <> 1 then Exit('');

    Result := IncludeTrailingBackslash(SF.ActiveFolder.PathName) +
              SL.SelectedItems[0].DisplayName;

    if UpperCase(ExtractFileExt(Result)) <> '.PDF' then
      Result := '';
  end;

  function SelectAttachment(const InitialDir: string): string;
  begin
    LMDOpenDialog2.InitialDir := InitialDir;
    if LMDOpenDialog2.Execute then
      Result := LMDOpenDialog2.FileName
    else
      Result := '';
  end;

  procedure LogLine(const S: string);
  begin
    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ==' + S));
  end;

begin
  FavClose;

  // Fokus wiederherstellen
  if wcActive.Name = 'LMDShellList1' then LMDShellList1.SetFocus
  else if wcActive.Name = 'LMDShellList2' then LMDShellList2.SetFocus;

  // PDF-Datei ermitteln
  PDFDatei := GetSelectedPDF;
  if PDFDatei = '' then
  begin
    MessageDlgCenter(
      'PDF Anlage hinzufügen: Bitte EINE PDF-Datei aus dem Quell- oder Zielverzeichnis auswählen!',
      mtInformation, [mbOk]);
    Exit;
  end;

  // Anlage auswählen
  Anlage := SelectAttachment(ExtractFilePath(PDFDatei));
  if Anlage = '' then Exit;

  // Beschreibung abfragen
  UniInputQuery('PDF Anlage hinzufügen', 'Beschreibung zur Anlage:', Beschreibung);

  // Zielverzeichnis "Anlage" erstellen
  if ForceDirectories(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'Anlage') then
    Ziel := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + 'Anlage';

  // Zieldatei bestimmen
  if LMDShellList1.Focused then
    Zieldatei := IncludeTrailingBackslash(Ziel) + LMDShellList1.SelectedItems[0].DisplayName
  else
    Zieldatei := IncludeTrailingBackslash(Ziel) + LMDShellList2.SelectedItems[0].DisplayName;

  // Kommandozeile
  Zeile := Einstellungen_Form.Edit4.Text +
           ' --add-attachment --description="' + Beschreibung +
           '" "' + Anlage + '" -- "' + PDFDatei + '" "' + Zieldatei + '"';

  // Prozess starten
  ProcID := 0;
  if RunProcess(Zeile, SW_HIDE, True, @ProcID) = 0 then
  begin
    Memo1.Lines.Text := Zeile;

    if Logdatei.Checked then
    begin
      AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
      try Append(F) except Rewrite(F) end;

      LogLine('=> ANLAGE HINZUFÜGEN: ' + Zeile);
      LogLine('          Quelldatei: ' + PDFDatei);
      LogLine('          Dateigröße: ' + FormatByteString(MyFileSize(PDFDatei)));
      LogLine('              Anlage: ' + Anlage);
      LogLine('           Zieldatei: ' + Zieldatei);
      LogLine('          Dateigröße: ' + FormatByteString(MyFileSize(Zieldatei)));

      CloseFile(F);

      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');
    end;
  end;

  Application.ProcessMessages;

  // PDF anzeigen
  if Einstellungen_Form.AnzeigenCB.Checked then
  begin
    PDFForm := TPDFBrowserForm.Create(Self);
    PDFForm.PDFFileName := Zieldatei;
    PDFForm.Show;
    Application.ProcessMessages;
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
  PDFDatei, Zieldatei, Anlage, Zeile, Zeile2, Ausgabe, Befehlszeile, Work: string;
  ProcID: Cardinal;
  F: TextFile;
  j: Integer;
  PDFForm: TPDFBrowserForm;

  function ActiveList: TLMDShellList;
  begin
    if LMDShellList1.Focused then Result := LMDShellList1
    else Result := LMDShellList2;
  end;

  function ActiveFolder: TLMDShellFolder;
  begin
    if LMDShellList1.Focused then Result := LMDShellFolder1
    else Result := LMDShellFolder2;
  end;

  function SelectedPDF: string;
  begin
    if ActiveList.SelCount <> 1 then Exit('');
    Result := IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName) +
              ActiveList.SelectedItems[0].DisplayName;
    if UpperCase(ExtractFileExt(Result)) <> '.PDF' then Result := '';
  end;

  procedure Log(const S: string);
  begin
    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ==' + S));
  end;

begin
  FavClose;
  Memo1.Clear;

  // Fokus wiederherstellen
  if wcActive.Name = 'LMDShellList1' then LMDShellList1.SetFocus
  else if wcActive.Name = 'LMDShellList2' then LMDShellList2.SetFocus;

  // PDF-Datei bestimmen
  PDFDatei := SelectedPDF;
  if PDFDatei = '' then
  begin
    MessageDlgCenter(
      'PDF Anlage(n) anzeigen und extrahieren: Bitte EINE PDF-Datei auswählen!',
      mtInformation, [mbOk]);
    Exit;
  end;

  // Attachments anzeigen
  Work := ExtractFilePath(ActiveFolder.ActiveFolder.PathName);
  Befehlszeile := XPDF_Detach + ' -list "' + PDFDatei + '"';
  GetDosOutput(Memo1, Befehlszeile, Work);
  Memo1.Perform(EM_LineScroll, 0, -Memo1.Lines.Count - 1);

  // Keine Anlagen?
  if Memo1.Lines[0] = '0 embedded files' then
  begin
    MessageDlgCenter(
      'Fehler beim Extrahieren der Anlage aus "' +
      ActiveList.Selected.Caption + '".' + #13 +
      'Vermutlich enthält die PDF-Datei keine Anlage?!',
      mtError, [mbOk]);
    Exit;
  end;

  // Memo-Höhe anpassen
  if Memo1.Lines.Count > 1 then
  begin
    j := TextHoehe(Memo1.Font, Memo1.Text);
    j := (j * Memo1.Lines.Count) + MHA;
    if j > Memo1.Parent.Height then PDFPanel.Height := j;
  end;

  // Anlage-Nummer abfragen
  if not UniInputQuery('PDF Anlage extrahieren',
                       'Bitte Nummer der Anlage angeben:', Anlage)
     or (Anlage = '') then Exit;

  // Zielverzeichnis erstellen
  if ForceDirectories(IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName) + 'Anlagen') then
    Ziel := IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName) + 'Anlagen';

  // Anlage-Zeile aus Memo extrahieren
  Ausgabe := Memo1.Lines[StrToInt(Anlage)];
  Delete(Ausgabe, 1, 3);

  // Extrahieren
  Zeile := XPDF_Detach + ' -save ' + Anlage + ' -o "' +
           IncludeTrailingBackslash(Ziel) + Ausgabe + '" "' + PDFDatei + '"';

  ProcID := 0;
  if RunProcess(Zeile, SW_HIDE, True, @ProcID) <> 0 then Exit;

  Memo1.Lines.Text := Zeile;

  // Logging
  if Logdatei.Checked then
  begin
    AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
    try Append(F) except Rewrite(F) end;

    Log('> ANLAGE EXTRAHIEREN: ' + Zeile);
    Log('          Quelldatei: ' + PDFDatei);
    Log('     Zielverzeichnis: ' + ExcludeTrailingBackslash(Ziel));
    Log('  Extrahierte Anlage: ' + Ausgabe);
    Log('          Dateigröße: ' + FormatByteString(MyFileSize(IncludeTrailingBackslash(Ziel) + Ausgabe)));

    CloseFile(F);

    if Einstellungen_Form.SystemklangCB.Checked then
      PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');
  end;

  // Anlage auch aus PDF entfernen?
  if MessageDlgCenter('Möchten Sie diese Anlage auch aus der PDF-Datei entfernen?',
                      mtInformation, [mbYes, mbNo]) = mrNo then Exit;

  // Entfernen
  Zeile2 := Einstellungen_Form.Edit4.Text +
            ' --remove-attachment="' + Ausgabe + '" "' +
            PDFDatei + '" "' + IncludeTrailingBackslash(Ziel) +
            ActiveList.SelectedItems[0].DisplayName + '"';

  ProcID := 0;
  if RunProcess(Zeile2, SW_HIDE, True, @ProcID) = 0 then
  begin
    Memo1.Lines.Text := Zeile2;

    if Logdatei.Checked then
    begin
      AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
      try Append(F) except Rewrite(F) end;

      Log('> ANLAGE ENTFERNEN: ' + Zeile2);
      Log('        Quelldatei: ' + PDFDatei);
      Log('        Dateigröße: ' + FormatByteString(MyFileSize(PDFDatei)));
      Log('  Entfernte Anlage: ' + Ausgabe);
      Log('         Zieldatei: ' + IncludeTrailingBackslash(Ziel) + ExtractFileName(Zieldatei));
      Log('        Dateigröße: ' + FormatByteString(MyFileSize(IncludeTrailingBackslash(Ziel) +
                                                       ExtractFileName(Zieldatei))));

      CloseFile(F);

      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');
    end;
  end;

  Application.ProcessMessages;

  // PDF anzeigen
  if Einstellungen_Form.AnzeigenCB.Checked then
  begin
    PDFForm := TPDFBrowserForm.Create(Self);
    PDFForm.PDFFileName := Zieldatei;
    PDFForm.Show;
    Application.ProcessMessages;
  end;
end;

// Aufruf spezieller Ordner, wie z.B. die Netzwerkumgebung, „Eigene Dateien".
// Nachfolgende Procedure öffnet einen solchen virtuellen Dialog:
// CSIDL_Controls  für "Systemsteuerung",
// CSIDL_Printers  für "Drucker",
// CSIDL_Drives	   für "Arbeitsplatz",
// CSIDL_Network   für "Netzwerkumgebung".
// CSIDL_BITBUCKET für "Papierkorb"
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
  Result := False;
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

// Schnelles Autosize (Ein- und danach sofort wieder Ausschalten) beider Namen-Spalten
procedure TFreePDF64_Form.AutoFormatClick(Sender: TObject);
begin
  AutoFormat.Checked := Not AutoFormat.Checked;
  if AutoFormat.Checked then
    HinweisAutoFormat := True
  else
    HinweisAutoFormat := False;
end;

procedure TFreePDF64_Form.AutoSizeBtnClick(Sender: TObject);
begin
  AutoSizeBtn.Checked := Not AutoSizeBtn.Checked;
  if AutoSizeBtn.Checked then
    AutoSize.Visible := True
  else
    AutoSize.Visible := False;
end;

procedure TFreePDF64_Form.AutoSizeClick(Sender: TObject);
var
  a: Boolean;
begin
  // JPEG-Fenster vorher schließen
  if Image1.Visible or Image2.Visible then
  begin
    SplDblClick(Sender);
    Exit;
  end;

  // Aktuellen AutoSize-Zustand merken
  a := LMDShellList1.Column[0].AutoSize;

  // Beide Listen während der gesamten Änderung nicht neu zeichnen
  LMDShellList1.Perform(WM_SETREDRAW, 0, 0);
  LMDShellList2.Perform(WM_SETREDRAW, 0, 0);

  try
    // Spalten automatisch anpassen
    LMDShellList1.Column[0].AutoSize := True;
    LMDShellList2.Column[0].AutoSize := True;

    // Splitter soll sich in der Mitte befinden
    PanelR.Width := (PanelL.Width + PanelR.Width) div 2;

    // Erzwingt die Neuberechnung der Fenstergröße
    FreePDF64_Form.Height := FreePDF64_Form.Height + 1;
    FreePDF64_Form.Height := FreePDF64_Form.Height - 1;

    // Ursprünglichen AutoSize-Zustand wiederherstellen
    LMDShellList1.Column[0].AutoSize := a;
    LMDShellList2.Column[0].AutoSize := a;

  except
    on E: Exception do
      ShowMessage(
        'Eine Ausnahme ist aufgetreten: ' + E.Message
      );
  end;

  // Zeichnen wieder einschalten
  LMDShellList1.Perform(WM_SETREDRAW, 1, 0);
  LMDShellList2.Perform(WM_SETREDRAW, 1, 0);

  // Nur den endgültigen Zustand anzeigen
  LMDShellList1.Invalidate;
  LMDShellList2.Invalidate;

  LMDShellList1.Update;
  LMDShellList2.Update;

  RefreshBt.Click;
end;

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
    LMDShellList1.Column[0].AutoSize := False;
    LMDShellList2.Column[0].AutoSize := False;
  end;
end;

procedure TFreePDF64_Form.ResizeEqualClick(Sender: TObject);
begin
  ResizeEqual.Checked := Not ResizeEqual.Checked;
end;

procedure TFreePDF64_Form.RootLClick(Sender: TObject);
begin
  FavClose;

  LMDShellList1.Perform(WM_SETREDRAW, 0, 0);
  try
    LMDShellFolder1.ChDir(IncludeTrailingBackslash
      (ExtractFileDrive(LMDShellFolder1.ActiveFolder.PathName)));
  finally
    LMDShellList1.Perform(WM_SETREDRAW, 1, 0);
    LMDShellList1.Invalidate;
    LMDShellList1.Update;
  end;

  if LMDShellList1.Selected = NIL then
    LMDShellList1.ItemIndex := 0;
end;

procedure TFreePDF64_Form.RootRClick(Sender: TObject);
begin
  FavClose;
  LMDShellList2.Perform(WM_SETREDRAW, 0, 0);
  try
    LMDShellFolder2.ChDir(IncludeTrailingBackslash
      (ExtractFileDrive(LMDShellFolder2.ActiveFolder.PathName)));
  finally
    LMDShellList2.Perform(WM_SETREDRAW, 1, 0);
    LMDShellList2.Invalidate;
    LMDShellList2.Update;
  end;

  if LMDShellList2.Selected = NIL then
    LMDShellList2.ItemIndex := 0;
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
  // sonst Registry-Eintrag wieder löschen...
  begin
    Reg := TRegistry.Create;
    try
      Reg.Rootkey := HKEY_CURRENT_USER;
      Reg.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run\', False);
      Reg.DeleteValue('FreePDF64');
      Reg.CloseKey;
    finally
      Reg.Free;
    end;
  end;
end;

procedure TFreePDF64_Form.Anleitung1Click(Sender: TObject);
begin
  Anleitung_Form.Position := poMainFormCenter;
  Anleitung_Form.Memo1.Lines.Text :=
    'PDF-Dateien erzeugen, zusammenfügen, drucken, Seiten entnehmen, Bilder extrahieren, verschlüsseln'
    + #13 + '(128-Bit RC4/AES oder 256-Bit AES), mit Wasserzeichen oder Stempel versehen, uvm.'
    + #13 + #13 +
    'Drucken aus jedem Programm heraus mit sofortiger PS/PDF/BMP/JPEG/PNG/TIFF/DOCX-Erstellung:'
    + #13 + '- Drucken aus allen Programmen auf den FreePDF64 Postscript-Drucker'
    + #13 + '- Alle benötigten Programme sind schon im Installationspaket enthalten'
    + #13 + '- Die wichtigsten FreePDF64-Einstellungen inkl. korrekter Pfade sind schon voreingestellt!'
    + #13 + '- Drucke nun aus jeder Windows-Anwendung heraus auf den erstellten FreePDF64-Drucker... Fertig!'
    + #13 + #13 +
    'Funktionen:' + #13 +
    '01: Erstellen von PS (Postscript) zu PDF/BMP/JPEG/PNG/TIFF/TXT-Dateien' + #13 +
    '02: Erstellen von PDF zu PDF-verschlüsselt/PS/BMP/JPEG/PNG/TIFF/TXT/DOCX-Dateien' + #13 +
    '03: Erstellen von BMP/JPEG/PNG/TIFF zu PDF-Dateien' + #13 +
    '04: PDF-Dateien vor und auch nach der Erstellung verschlüsseln (128-Bit RC4/AES oder 256-Bit AES)' + #13 +
    '05: PDF-Passwortschutz entfernen' + #13 +
    '06: Erstellen von PDF/A-1b bis PDF/A-3b: Ein Dateiformat zur Langzeitarchivierung' + #13 +
    '07: Erstellen von PDF/X-3 sowie PDF/X-4a: Ein Dateiformat für den Austausch digitaler Druckvorlagen' + #13 +
    '08: Ändern der PDF-Metadaten (PDFMarks: z.B. Titel, Verfasser, Thema, etc.) bei der Erstellung' + #13 +
    '09: Zusammenfügen von mehreren PS/PDF-Dateien zu einer PDF-Datei' + #13 +
    '10: Distiller Parameter anpassen (Acrobat 5-8 kompatibel)' + #13 +
    '11: Auswahl verschiedener TIFF-Formate. DPI für erzeugte BMP/JPEG/TIFF einstellen' + #13 +
    '12: PDF/PS/TXT/TIFF-Datei(en) direkt nach der Erstellung mit dem zugewiesenen Anzeiger öffnen' + #13 +
    '13: Ausgewählte Seiten entnehmen aus allen Formaten' + #13 +
    '14: Schnelle Webanzeige (Optimierung der PDF-Datei)' + #13 +
    '15: Komprimierung der PDF-Datei(en)' + #13 +
    '16: Konvertieren von PDF zu HTML' + #13 +
    '17: Hinzufügen eines Wasserzeichens oder Stempels zu einer PDF-Datei' + #13 +
    '18: Anfügen einer PS- oder PDF-Datei vorne/hinten an die zu erstellende PDF-Datei' + #13 +
    '19: Bilder extrahieren aus PDF-Dateien oder Anlagen zur PDF-Datei hinzufügen/extrahieren' + #13 +
    '20: Umfangreichste Suchfunktionen' + #13 +
    '21: E-Mailversand der markierten Datei(en)' + #13 +
    '22: Automatische Überwachung auf neue eingehende Dateien' + #13 +
    '... uvm.' + #13 + #13 +
    'Weitere Informationen unter: Hilfe - FreePDF64-HowTo';

  Anleitung_Form.ShowModal;
end;

procedure TFreePDF64_Form.Favoritenspeichern1Click(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile: String;
  I, j: Integer;
begin
  IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
  IniDat := TIniFile.Create(IniFile);
  with IniDat do
  begin
    // Favoritenliste schreiben.
    IniDat.EraseSection('Favorites Left');
    for I := 1 to ListBoxL.Items.Count do
      IniDat.WriteString('Favorites Left', IntToStr(I - 1),
        ListBoxL.Items[I - 1]);
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
  I: Integer;
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
        for I := 1 to ComboBoxL.Items.Count do
          WriteString('History', 'History Left' + IntToStr(I - 1),
            ComboBoxL.Items[I - 1]);
      if ComboBoxR.Items.Count > 0 then
        for I := 1 to ComboBoxR.Items.Count do
          WriteString('History', 'History Right' + IntToStr(I - 1),
            ComboBoxR.Items[I - 1]);
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
end;

// List all files in a directory: Ergebnis ist in RESULT
function ListFileDir(const Path: string): Integer;
var
  SR: TSearchRec;
  SearchResult: Integer;
  AttrMask: Integer;
const
  faHidden: Byte = 2;
begin
  Result := 0;

  // ListFileDir wird für die Dateizählung verwendet. Verzeichnisse werden
  // deshalb grundsätzlich nicht mitgezählt. Wenn versteckte/systembedingte
  // Dateien ausgeblendet sind, werden auch diese nicht gezählt.
  if FreePDF64_Form.VersteckteDateienanzeigen1.Checked then
    AttrMask := faAnyFile - faDirectory
  else
    AttrMask := faAnyFile - faDirectory - faHidden - faSysFile;

  SearchResult := FindFirst(IncludeTrailingPathDelimiter(Path) + '*.*',
    AttrMask, SR);
  if SearchResult <> 0 then
    Exit;

  try
    repeat
      if (SR.Name <> '.') and (SR.Name <> '..') and
         ((SR.Attr and faDirectory) = 0) then
        Inc(Result);
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

// Verzeichnisgröße auslesen mit/ohne Unterverzeichnisse
function GetDirSize(const dir: string; subdir: Boolean): Int64;
var
  Rec: TSearchRec;
  SearchResult: Integer;
  AttrMask: Integer;
  CurrentDir: string;
const
  faHidden: Byte = 2;
begin
  Result := 0;
  CurrentDir := IncludeTrailingPathDelimiter(dir);

  // Verzeichnisse müssen für die Rekursion mitgefunden werden.
  // Die eigentliche Größenaddition erfolgt ausschließlich für Dateien.
  if FreePDF64_Form.VersteckteDateienanzeigen1.Checked then
    AttrMask := faAnyFile
  else
    AttrMask := faAnyFile - faHidden - faSysFile;

  SearchResult := FindFirst(CurrentDir + '*.*', AttrMask, Rec);
  if SearchResult <> 0 then
    Exit;

  try
    repeat
      if (Rec.Name <> '.') and (Rec.Name <> '..') then
      begin
        if (Rec.Attr and faDirectory) <> 0 then
        begin
          if subdir then
            Inc(Result, GetDirSize(CurrentDir + Rec.Name, True));
        end
        else
          Inc(Result, Rec.Size);
      end;
    until FindNext(Rec) <> 0;
  finally
    FindClose(Rec);
  end;
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
  else if wcActive.Name = 'LMDShellList2' then
    LMDShellList2.SetFocus;

  Merge.Click;
end;

procedure SB_Left;
begin
  FreePDF64_Form.StatusBar_Left.SimpleText := 'Datei(en)/Verzeichnis(se): ' +
    IntToStr(ListFileDir(IncludeTrailingBackslash
    (FreePDF64_Form.LMDShellFolder1.ActiveFolder.PathName))) + '/' +
    IntToStr(FreePDF64_Form.LMDShellList1.Items.Count -
    ListFileDir(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.
    ActiveFolder.PathName))) +
    ' - ' + IntToStr
    (ListFileDir(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.
    ActiveFolder.PathName))) + ' Datei(en)' +
    ' in ' + FormatByteString
    (GetDirSize(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder1.
    ActiveFolder.PathName), False));
end;

procedure SB_Right;
begin
  FreePDF64_Form.StatusBar_Right.SimpleText := 'Datei(en)/Verzeichnis(se): ' +
    IntToStr(ListFileDir(IncludeTrailingBackslash
    (FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName))) + '/' +
    IntToStr(FreePDF64_Form.LMDShellList2.Items.Count -
    ListFileDir(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder2.
    ActiveFolder.PathName))) + ' - ' +
    IntToStr(ListFileDir(IncludeTrailingBackslash
    (FreePDF64_Form.LMDShellFolder2.ActiveFolder.PathName))) + ' Datei(en)' +
    ' in ' + FormatByteString
    (GetDirSize(IncludeTrailingBackslash(FreePDF64_Form.LMDShellFolder2.
    ActiveFolder.PathName), False));
end;

procedure TFreePDF64_Form.VersteckteDateienanzeigen1Click(Sender: TObject);
var
  tmpt: TLMDShellListOptions;
  tmpt2: TLMDShellTreeOptions;
begin
  if not VersteckteDateienanzeigen1.Checked then
    MessageDlgCenter('Versteckte Dateien werden nur entsprechend der Explorer-Einstellung angezeigt.' + #13 +
                     'Bedeutet: Wenn aktiviert im Explorer, dann auch sichtbar hier!',
                      mtInformation, [mbOk]);

  VersteckteDateienanzeigen1.Checked := not VersteckteDateienanzeigen1.Checked;

  tmpt := LMDShellList1.Options;
  tmpt2 := LMDShellTree1.Options;
  if VersteckteDateienanzeigen1.Checked then
  begin
    Include(tmpt, loShowHidden);
    Include(tmpt2, toShowHidden);
  end
  else
  begin
    Exclude(tmpt, loShowHidden);
    Exclude(tmpt2, toShowHidden);
  end;
  LMDShellList1.Options := tmpt;
  LMDShellList2.Options := tmpt;
  LMDShellTree1.Options := tmpt2;
  LMDShellTree2.Options := tmpt2;

  LMDShellTree1.RefreshBranches(LMDShellTree1.Selected.Parent);
  LMDShellTree2.RefreshBranches(LMDShellTree2.Selected.Parent);

  SB_Left;
  SB_Right;
end;

procedure TFreePDF64_Form.ViewStyleBtn1Click(Sender: TObject);
begin
  if LMDShellList1.ViewStyle = vsReport then
    LMDShellList1.ViewStyle := vsList
  else
    LMDShellList1.ViewStyle := vsReport;
end;

procedure TFreePDF64_Form.ViewStyleBtn2Click(Sender: TObject);
begin
  if LMDShellList2.ViewStyle = vsReport then
    LMDShellList2.ViewStyle := vsList
  else
    LMDShellList2.ViewStyle := vsReport;
end;

// Aufruf der Github-Release-Seite von FreePDF64
procedure TFreePDF64_Form.AbfrageaufeinneuesUpdate1Click(Sender: TObject);
var
  Datum: String;
begin
  Datum := '08.10.2026';
  Delete(Datum, 11, 9); // Entfernt die letzten 9 Zeichen
  if MessageDlgCenter('Aktuell genutzt wird:' + ' Version ' +
    LMDVersionInfo1.ProductVersion + ' - 64 bit (' + Datum + ')' +
    #13 + #13 +
    'Mit Klick auf [ Ja ] geht es weiter zur FreePDF64-Releaseseite!',
    mtInformation, [mbYes, mbNo]) = mrYes then
    ShellExecute(Application.Handle, 'open',
      PChar('https://github.com/FreePDF64/FreePDF64/releases'), NIL, NIL,
      SW_NORMAL);
end;

// Wasserzeichen...
procedure TFreePDF64_Form.Wasserzeichen1Click(Sender: TObject);
begin
  WZSTTB.Click;
end;

procedure TFreePDF64_Form.ZiellabelClick(Sender: TObject);
begin
  ParentFolderR.Click;
end;

// Abfrage auf :: am Anfang von LMDShellFolder.ActiveFolder.DisplayName
function StartsWithColons(const AText: string): Boolean;
begin
  Result := (Length(AText) > 0) and (AText[1] = ':') and (AText[2] = ':');
end;

procedure TFreePDF64_Form.LMDShellTree2Change(Sender: TObject; Node: TTreeNode);
begin
  // JPEG-Fenster schließen
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

procedure TFreePDF64_Form.LMDShellTree1Editing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
  AllowEdit := F2Pressed;
//  F2Pressed := False;
end;

procedure TFreePDF64_Form.LMDShellTree2Editing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
  AllowEdit := F2Pressed;
//  F2Pressed := False;
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

procedure TFreePDF64_Form.FolderBtnClick(Sender: TObject);
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

// Wird für "Send To..." benötigt
function GetFileListDataObject(const Directory: string; Files: TStrings)
  : IDataObject;
type
  PArrayOfPItemIDList = ^TArrayOfPItemIDList;
  TArrayOfPItemIDList = Array [0 .. 0] of PItemIDList;
var
  Malloc: IMalloc;
  Root: IShellFolder;
  FolderPidl: PItemIDList;
  Folder: IShellFolder;
  p: PArrayOfPItemIDList;
  chEaten: ULONG;
  dwAttributes: ULONG;
  FileCount: Integer;
  I: Integer;
begin
  Result := NIL;
  if Files.Count = 0 then
    Exit;
  OleCheck(SHGetMalloc(Malloc));
  OleCheck(SHGetDesktopFolder(Root));
  OleCheck(Root.ParseDisplayName(0, NIL, PWideChar(WideString(Directory)),
    chEaten, FolderPidl, dwAttributes));
  try
    OleCheck(Root.BindToObject(FolderPidl, NIL, IShellFolder, Pointer(Folder)));
    FileCount := Files.Count;
    p := AllocMem(SizeOf(PItemIDList) * FileCount);
    try
      for I := 0 to FileCount - 1 do
      begin
        OleCheck(Folder.ParseDisplayName(0, NIL, PWideChar(WideString(Files[I])
          ), chEaten, p^[I], dwAttributes));
      end;
      OleCheck(Folder.GetUIObjectOf(0, FileCount, p^[0], IDataObject, NIL,
        Pointer(Result)));
    finally
      for I := 0 to FileCount - 1 do
      begin
        // if p^[i] &lt;&gt; nil then
        if p^[I] = NIL then
          Malloc.Free(p^[I]);
      end;
      FreeMem(p);
    end;
  finally
    Malloc.Free(FolderPidl);
  end;
end;

// Senden an... es wird die Microsoft-Funktion "Send To…" simuliert
procedure TFreePDF64_Form.Sendenan1Click(Sender: TObject);
var
  SelFileList: TStrings;
  DataObject: IDataObject;
  Effect, I: Integer;
  CLSID_SendMail: TGUID;
  DT: IDropTarget;
  p: TPoint;
  F: TextFile;
  m: Array [0 .. 255] of String;
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else if wcActive.Name = 'LMDShellList2' then
    LMDShellList2.SetFocus;

  if (LMDShellList1.Focused and (LMDShellList1.SelCount = 0)) or
    (LMDShellList2.Focused and (LMDShellList2.SelCount = 0)) then
  begin
    MessageDlgCenter
      ('Markierte Datei(en) versenden: Bitte Datei(en) auswählen!',
      mtInformation, [mbOk]);
    Exit;
  end;

  Memo1.Lines.Clear;

  CLSID_SendMail := StringToGUID('{9E56BE60-C50F-11CF-9A2C-00A0C90A90CE}');
  // Wenn eine Datei ausgewählt ist, dann...
  if LMDShellList1.Focused and (LMDShellList1.SelCount > 0) then
    with LMDShellList1 do
    begin
      SelFileList := TStringList.Create;
      try
        SelFileList.Capacity := SelCount;
        for I := 0 to SelCount - 1 do
        begin
          SelFileList.Add(SelectedItems[I].DisplayName);
          m[I] := SelectedItems[I].DisplayName;
          AppendMemoText('Senden folgender Datei(en): '
            + IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) +
            SelectedItems[I].DisplayName + #13);
        end;
        DataObject := GetFileListDataObject
          (LMDShellFolder1.ActiveFolder.PathName, SelFileList);
      finally
        SelFileList.Free;
      end;
      Effect := DROPEFFECT_NONE;
      CoCreateInstance(CLSID_SendMail, NIL, CLSCTX_ALL, IDropTarget, DT);
      DT.DragEnter(DataObject, MK_LBUTTON, p, Effect);
      DT.Drop(DataObject, MK_LBUTTON, p, Effect);
    end;

  if LMDShellList2.Focused and (LMDShellList2.SelCount > 0) then
    with LMDShellList2 do
    begin
      SelFileList := TStringList.Create;
      try
        SelFileList.Capacity := SelCount;
        for I := 0 to SelCount - 1 do
        begin
          SelFileList.Add(SelectedItems[I].DisplayName);
          m[I] := SelectedItems[I].DisplayName;
          AppendMemoText('Senden folgender Datei(en): '
            + IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) +
            SelectedItems[I].DisplayName + #13);
        end;
        DataObject := GetFileListDataObject
          (LMDShellFolder2.ActiveFolder.PathName, SelFileList);
      finally
        SelFileList.Free;
      end;
      Effect := DROPEFFECT_NONE;
      CoCreateInstance(CLSID_SendMail, NIL, CLSCTX_ALL, IDropTarget, DT);
      DT.DragEnter(DataObject, MK_LBUTTON, p, Effect);
      DT.Drop(DataObject, MK_LBUTTON, p, Effect);
    end;

  // FreePDF64Log.txt
  if Logdatei.Checked then
  begin
    // Logdatei (FreePDF64Log.txt) öffnen/beschreiben etc.
    AssignFile(F, PChar(ExtractFilePath(Application.ExeName) +
      'FreePDF64Log.txt'));
    try
      Append(F);
    except
      Rewrite(F)
    end;
    if LMDShellList1.Focused and (LMDShellList1.SelCount > 0) then
    begin
      for I := 0 to LMDShellList1.SelCount - 1 do
      begin
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
          ' ==========> SENDEN VON: ' + IncludeTrailingBackslash
          (LMDShellFolder1.ActiveFolder.PathName) + m[I]));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
          ' -           Dateigröße: ' + FormatByteString
          (MyFileSize(IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.
          PathName) + LMDShellList1.SelectedItems[I].DisplayName))));
      end;
      Closefile(F)
    end
    else if LMDShellList2.Focused and (LMDShellList2.SelCount > 0) then
    begin
      for I := 0 to LMDShellList2.SelCount - 1 do
      begin
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
          ' ==========> SENDEN VON: ' + IncludeTrailingBackslash
          (LMDShellFolder2.ActiveFolder.PathName) + m[I]));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
          ' -           Dateigröße: ' + FormatByteString
          (MyFileSize(IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.
          PathName) + LMDShellList2.SelectedItems[I].DisplayName))));
      end;
      Closefile(F);
    end;
  end;
end;

// Baumansichten durchschalten
procedure TFreePDF64_Form.ShowFolders1Click(Sender: TObject);
begin
  FavClose;

  // Rechter Panel gleich linker Panel
  Panel_Right.Width := Panel_Left.Width;

  // Beide Baumansichten nicht sichtbar? Dann linke Baumansicht einschalten
  if not LMDShellTree1.Visible and not LMDShellTree2.Visible then
  begin
    LMDShellTree1.Visible := True;
    Splitter1.Visible := True;
    Panel_Left.Visible := True;
    Panel2.Visible := True;
    Splitter4.Visible := False;
    Panel_Right.Visible := False;
    Panel3.Visible := False;
    Baum := 1;
  end
  else
    // Linke Baumansicht sichtbar? Dann beide Baumansichten einschalten
    if LMDShellTree1.Visible and not LMDShellTree2.Visible then
    begin
      LMDShellTree1.Visible := True;
      LMDShellTree2.Visible := True;
      Splitter1.Visible := True;
      Splitter4.Visible := True;
      Panel_Left.Visible := True;
      Panel_Right.Visible := True;
      Panel2.Visible := True;
      Panel3.Visible := True;
      Baum := 2;
    end
    else
      // Beide Baumansichten sichtbar? Dann beide Baumansichten abschalten
      if LMDShellTree1.Visible and LMDShellTree2.Visible then
      begin
        LMDShellTree1.Visible := False;
        LMDShellTree2.Visible := False;
        Splitter1.Visible := False;
        Splitter4.Visible := False;
        Panel_Left.Visible := False;
        Panel_Right.Visible := False;
        Panel2.Visible := False;
        Panel3.Visible := False;
        Baum := 3;
      end;
end;

procedure TFreePDF64_Form.ZielverzeichnisimExplorerffnen1Click(Sender: TObject);
var
  APath: String;
begin
  APath := Ziel;
  ShellExecute(Handle, NIL, PChar('explorer'), PChar(APath), NIL, SW_Show);
end;

// Schnellzugriffsliste schließen!
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
  I: Integer;
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
    WriteInteger('Position', 'Right Panel Width', PanelR.Width);
    WriteInteger('Position', 'Memo Panel Height', PDFPanel.Height);
    WriteString('Folder', 'Left',
      IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName));
    A_S := IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName);
    WriteString('Folder', 'Target', IncludeTrailingBackslash(Ziel));
    B_Z := IncludeTrailingBackslash(Ziel);
    WriteBool('Folder', 'Gridlines', LMDShellList1.GridLines);
    WriteBool('Folder', 'Gridlines', LMDShellList2.GridLines);
    WriteBool('Folder', 'ResizeEqual', ResizeEqual.Checked);
    WriteBool('Folder', 'Autosize Name', AutoSpalte.Checked);
    WriteBool('Folder', 'ShowHidden', VersteckteDateienanzeigen1.Checked);
    WriteBool('Start', 'Logdatei', Logdatei.Checked);
    WriteBool('Start', 'AutoSize Button', AutoSizeBtn.Checked);
    WriteBool('Start', 'Rename by double-clicking', UPD.Checked);
    WriteBool('Start', 'ShowNetworkShares Button', ShowNetworkShares.Checked);
    WriteInteger('Start', 'ShowFolders', Baum);
    WriteBool('Start', 'System Tray', InDenTray.Checked);
    WriteBool('Start', 'System Tray/Taskbar', Systray_Taskleiste.Checked);
    WriteBool('Start', 'Splashscreen', Splash1.Checked);
    WriteBool('Start', 'Minimize', KlickaufX.Checked);
    WriteBool('Start', 'Autostart', Autostart.Checked);
    WriteBool('Start', 'Create with DoubleClick', DoppelK.Checked);
    WriteBool('Start', 'Format selection based on ext.', AutoFormat.Checked);
    WriteBool('Start', 'Create Formatfolder', Formatverz.Checked);
    WriteBool('Start', 'Create Formatfolder with Date',
      Formatverz_Date.Checked);
    WriteBool('Start', 'Create Formatfolder only Date',
      Formatverz_OnlyDate.Checked);
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
    WriteInteger('Start', 'ViewStyle_Left', Ord(LMDShellList1.ViewStyle));
    WriteInteger('Start', 'ViewStyle_Right', Ord(LMDShellList2.ViewStyle));

    // Filter schreiben
    IniDat.EraseSection('Filter');
    if Filter_Form.FilterCB.Items.Count > 0 then
      for I := 1 to Filter_Form.FilterCB.Items.Count do
        WriteString('Filter', 'Filter' + IntToStr(I - 1),
          Filter_Form.FilterCB.Items[I - 1]);
  end;
  // Speicher wird wieder freigeben
  IniDat.Free;
end;

procedure TFreePDF64_Form.Speichern1Click(Sender: TObject);
begin
  if FileExists(IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) +
    'FreePDF64.ini') then
    if MessageDlgCenter('Alle Einstellungen speichern?' + #13 + #13 +
      'Gespeichert wird alles, außer dem Schnellzugriff und der History!' + #13
      + 'Diese werden automatisch beim Beenden von FreePDF64 gespeichert.',
      mtInformation, [mbYes, mbNo]) = mrYes then
      // AllesSpeichern aufrufen...
      AllesSpeichern;
end;

// Gespeichert wird nur die Position des Fensters
procedure TFreePDF64_Form.Positionspeichern1Click(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile: String;
begin
  if MessageDlgCenter('Nur Fensterposition speichern?', mtInformation, [mbYes, mbNo]
    ) = mrYes then
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
  else if wcActive.Name = 'LMDShellList2' then
    LMDShellList2.SetFocus;

  if LMDShellList1.Focused and (LMDShellList1.IsEditing = False) then
    LMDShellList1.ShowProperties
  else if LMDShellList2.Focused and (LMDShellList2.IsEditing = False) then
    LMDShellList2.ShowProperties;
end;

procedure TFreePDF64_Form.QuelllabelClick(Sender: TObject);
begin
  ParentFolderL.Click;
end;

procedure TFreePDF64_Form.QuelllabelMouseEnter(Sender: TObject);
begin
  Quelllabel.Hint := IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName);
end;

procedure TFreePDF64_Form.ZiellabelMouseEnter(Sender: TObject);
begin
  Ziellabel.Hint := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName);
end;

procedure TFreePDF64_Form.RefreshBtClick(Sender: TObject);
begin
  FavClose;

  // Zeichnen während des gesamten Refresh-Vorgangs abschalten
  LMDShellList1.Perform(WM_SETREDRAW, 0, 0);
  LMDShellList2.Perform(WM_SETREDRAW, 0, 0);
  LMDShellTree1.Perform(WM_SETREDRAW, 0, 0);
  LMDShellTree2.Perform(WM_SETREDRAW, 0, 0);

  try
    // Ordner aktualisieren
    LMDShellFolder1.ActiveFolder.Refresh;
    LMDShellFolder2.ActiveFolder.Refresh;

    // Trees aktualisieren
    LMDShellTree1.Refresh;
    LMDShellTree2.Refresh;

    // Listen aktualisieren
    LMDShellList1.Refresh;
    LMDShellList2.Refresh;

    LMDShellList1.RefreshData;
    LMDShellList2.RefreshData;

    // Statusleisten aktualisieren
    SB_Left;
    SB_Right;

  finally
    // Zeichnen wieder einschalten
    LMDShellTree1.Perform(WM_SETREDRAW, 1, 0);
    LMDShellTree2.Perform(WM_SETREDRAW, 1, 0);
    LMDShellList1.Perform(WM_SETREDRAW, 1, 0);
    LMDShellList2.Perform(WM_SETREDRAW, 1, 0);

    // Nur den fertigen Zustand neu zeichnen
    LMDShellTree1.Invalidate;
    LMDShellTree2.Invalidate;
    LMDShellList1.Invalidate;
    LMDShellList2.Invalidate;

    LMDShellTree1.Update;
    LMDShellTree2.Update;
    LMDShellList1.Update;
    LMDShellList2.Update;
  end;
end;

procedure TFreePDF64_Form.Systemsteuerungaufrufen1Click(Sender: TObject);
begin
  LMDShellAppletLoader1.Applet := cplControlPanel;
  LMDShellAppletLoader1.Execute;
end;

procedure TFreePDF64_Form.Systray_TaskleisteClick(Sender: TObject);
begin
  if Systray_Taskleiste.Checked then
    Systray_Taskleiste.Checked := False
  else
    Systray_Taskleiste.Checked := True;
end;

procedure TFreePDF64_Form.TaskManager1Click(Sender: TObject);
begin
  ShellExecute(HWND(NIL), 'open', 'taskmgr', '', '', SW_SHOWNORMAL);
end;

// Fenster angleichen
procedure TFreePDF64_Form.AngleichenTBClick(Sender: TObject);
begin
  FavClose;
  if  Quelllabel.Color <> clBtnFace then
  begin
    LMDShellList2.Perform(WM_SETREDRAW, 0, 0);
    try
      LMDShellFolder2.ChDir(LMDShellFolder1.ActiveFolder.PathName)
    finally
      LMDShellList2.Perform(WM_SETREDRAW, 1, 0);
      LMDShellList2.Invalidate;
      LMDShellList2.Update;
    end;
  end else
  begin
    LMDShellList1.Perform(WM_SETREDRAW, 0, 0);
    try
    LMDShellFolder1.ChDir(LMDShellFolder2.ActiveFolder.PathName);
    finally
      LMDShellList1.Perform(WM_SETREDRAW, 1, 0);
      LMDShellList1.Invalidate;
      LMDShellList1.Update;
    end;
  end;

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

  LMDShellList1.Perform(WM_SETREDRAW, 0, 0);
  try
    LMDShellFolder1.ChDir(R);
  finally
    LMDShellList1.Perform(WM_SETREDRAW, 1, 0);
    LMDShellList1.Invalidate;
    LMDShellList1.Update;
  end;

  LMDShellList2.Perform(WM_SETREDRAW, 0, 0);
  try
    LMDShellFolder2.ChDir(L);
  finally
    LMDShellList2.Perform(WM_SETREDRAW, 1, 0);
    LMDShellList2.Invalidate;
    LMDShellList2.Update;
  end;

  SB_Left;
  SB_Right;
end;

procedure TFreePDF64_Form.Timer1Timer(Sender: TObject);
begin
  FormatBtn.Enabled := not FormatBtn.Enabled;
end;

// Nach dem Start von FreePDF64 wird die Hauptform kurz angezeigt - und danach geht sie in den System Tray
procedure TFreePDF64_Form.Timer2Timer(Sender: TObject);
begin
  if Systray_Taskleiste.Checked then
  begin
    FreePDF64_Form.Visible := False;
    TrayIcon1.Visible := True;
    Timer2.Enabled := False;
  end
  else
  begin
    FreePDF64_Form.WindowState := wsMinimized;
    Timer2.Enabled := False;
  end;
end;

procedure TFreePDF64_Form.ToolButton6Click(Sender: TObject);
begin
  LMDShellList1.SetFocus;
end;

procedure TFreePDF64_Form.SearchBtnClick(Sender: TObject);
begin
  // Suchformular wurde noch nicht erzeugt bzw. nach dem letzten
  // Schließen mit caFree bereits wieder freigegeben.
  if not Assigned(Suche_Form) then
    Suche_Form := TSuche_Form.Create(Application);

  if IsIconic(Suche_Form.Handle) then
    Suche_Form.WindowState := wsNormal
  else
    Suche_Form.Show;
end;

// Ist Verzeichnis leer?
function IsEmptyFolder(const AsFolder: string): Boolean;
var
  SR: TSearchRec;
begin
  Result := FindFirst(AsFolder + '\*.*', faAnyFile, SR) = 0;
  if not Result then
    Exit;
  repeat
    if (SR.Name <> '.') and (SR.Name <> '..') and (SR.Attr and faVolumeID = 0)
    then
    begin
      Result := False;
      Break;
    end;
  until FindNext(SR) <> 0;
  FindClose(SR);
end;

// Anlage(n) der markierten PDF-Datei anzeigen und ins Zielverzeichnis extrahieren
procedure TFreePDF64_Form.PDFAttachmentClick(Sender: TObject);
var
  I, j: Integer;
  PDFDatei, Zeile, Befehlszeile, Work: string;
  ProcID: Cardinal;
  F: TextFile;

  function ActiveList: TLMDShellList;
  begin
    if LMDShellList1.Focused then Result := LMDShellList1
    else Result := LMDShellList2;
  end;

  function ActiveFolder: TLMDShellFolder;
  begin
    if LMDShellList1.Focused then Result := LMDShellFolder1
    else Result := LMDShellFolder2;
  end;

  function SelectedPDF: string;
  begin
    if ActiveList.SelCount <> 1 then Exit('');
    Result := IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName) +
              ActiveList.Selected.Caption;
    if UpperCase(ExtractFileExt(Result)) <> '.PDF' then Result := '';
  end;

  procedure Log(const S: string);
  begin
    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ==' + S));
  end;

begin
  FavClose;
  Memo1.Clear;

  // Fokus wiederherstellen
  if wcActive.Name = 'LMDShellList1' then LMDShellList1.SetFocus
  else if wcActive.Name = 'LMDShellList2' then LMDShellList2.SetFocus;

  // pdfdetach.exe vorhanden?
  if not FileExists(XPDF_Detach) then
  begin
    MessageDlgCenter('Achtung: Die Datei "pdfdetach.exe" fehlt im Ordner "' +
      IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + '"!',
      mtError, [mbOk]);
    Exit;
  end;

  // PDF-Datei bestimmen
  PDFDatei := SelectedPDF;
  if PDFDatei = '' then
  begin
    MessageDlgCenter(
      'PDF Anlage(n) anzeigen und extrahieren: Bitte EINE PDF-Datei auswählen!',
      mtInformation, [mbOk]);
    Exit;
  end;

  // Attachments anzeigen
  Work := ExtractFilePath(ActiveFolder.ActiveFolder.PathName);
  Befehlszeile := XPDF_Detach + ' -list "' + PDFDatei + '"';
  GetDosOutput(Memo1, Befehlszeile, Work);
  Memo1.Perform(EM_LineScroll, 0, -Memo1.Lines.Count - 1);

  // Keine Anlagen?
  if Memo1.Lines[0] = '0 embedded files' then
  begin
    MessageDlgCenter('Fehler beim Extrahieren der Anlage(n) aus "' +
      ExtractFileName(PDFDatei) + '".' + #13 +
      'Vermutlich enthält die PDF-Datei keine Anlage(n)?!', mtError, [mbOk]);
    Exit;
  end;

  // Zielverzeichnis erstellen
  if ForceDirectories(IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName) + 'Anlagen') then
    Ziel := IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName) + 'Anlagen';

  // Befehl zum Speichern aller Anlagen
  Zeile := XPDF_Detach + ' -saveall -o "' +
           ExcludeTrailingPathDelimiter(Ziel) + '" "' + PDFDatei + '"';

  // Anlagen extrahieren
  ProcID := 0;
  if RunProcess(Zeile, SW_HIDE, True, @ProcID) <> 0 then Exit;

  // Keine Anlagen extrahiert?
  if IsEmptyFolder(Ziel) then
  begin
    MessageDlgCenter('Fehler beim Extrahieren der Anlage(n) aus "' +
      ExtractFileName(PDFDatei) + '".' + #13 +
      'Vermutlich enthält die PDF-Datei keine Anlage(n)?!', mtError, [mbOk]);
    Exit;
  end;

  // Logging
  if Logdatei.Checked and (Memo1.Lines[0] <> '0 embedded files') then
  begin
    AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
    try Append(F) except Rewrite(F) end;

    Log(' ANLAGE(N) SPEICHERN: ' + Zeile);
    Log('    Quellverzeichnis: ' + IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName));
    Log('          Quelldatei: ' + ExtractFileName(PDFDatei));
    Log('     Zielverzeichnis: ' + Ziel);
    Log('  Anzahl der Anlagen: ' + Memo1.Lines[0]);

    for j := 1 to Memo1.Lines.Count - 1 do
      Log('  Anlage_' + Memo1.Lines[j]);

    CloseFile(F);
  end;

  // Memo-Höhe anpassen
  if Memo1.Lines.Count > 1 then
  begin
    I := TextHoehe(Memo1.Font, Memo1.Text);
    I := (I * Memo1.Lines.Count) + MHA;
    if I >= Memo1.Parent.Height then
      PDFPanel.Height := I;
  end;

  if Einstellungen_Form.SystemklangCB.Checked then
    PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');
end;

// Informationen über jegliche Art von Datei (auch PDF) anzeigen
procedure TFreePDF64_Form.PDFInfoBtnClick(Sender: TObject);
var
  Work, Befehlszeile, SelFile, SelPath: String;
  ShellList: TLMDShellList;
  ShellFolder: TLMDShellFolder;

  function ActiveList: TLMDShellList;
  begin
    if LMDShellList1.Focused then Result := LMDShellList1
    else Result := LMDShellList2;
  end;

  function ActiveFolder: TLMDShellFolder;
  begin
    if LMDShellList1.Focused then Result := LMDShellFolder1
    else Result := LMDShellFolder2;
  end;

begin
  Info_Anzeigen := True;
  FavClose;
  Memo1.Clear;

  // Fokus wiederherstellen
  if wcActive.Name = 'LMDShellList1' then LMDShellList1.SetFocus
  else if wcActive.Name = 'LMDShellList2' then LMDShellList2.SetFocus;

  // ExifTool vorhanden?
  if not FileExists(ExifTool) then
  begin
    MessageDlgCenter(
      'Achtung: Die Datei "exiftool.exe" fehlt im Ordner "' +
      IncludeTrailingBackslash(Einstellungen_Form.Edit8.Text) + '"!',
      mtError, [mbOk]);
    Exit;
  end;

  // aktive Liste + Ordner bestimmen
  ShellList   := ActiveList;
  ShellFolder := ActiveFolder;

  if ShellList.SelCount <> 1 then
  begin
    MessageDlgCenter(
      'Datei/Ordnerinformationen anzeigen: Bitte EINE Datei/Ordner auswählen!',
      mtInformation, [mbOk]);
    Exit;
  end;

  // Datei + Pfad
  SelFile := ShellList.Selected.Caption;
  SelPath := IncludeTrailingBackslash(ShellFolder.ActiveFolder.PathName);
  Work    := ExtractFilePath(ShellFolder.ActiveFolder.PathName);

  // UI: Fortschrittsanzeige
  PaneloverPrgB.Visible := True;
  PaneloverPrgB.Caption := SelPath + SelFile;

  // ExifTool-Befehlszeile
  Befehlszeile :=
    ExifTool + ' -L ' + GE +
    ' -g1 -charset filename=cp1252 -a -All:All -e "' +
    SelPath + SelFile + '"';

  // DOS-Ausgabe in Memo
  GetDosOutput(Memo1, Befehlszeile, Work);

  // Memo nach oben scrollen
  Memo1.Perform(EM_LineScroll, 0, -Memo1.Lines.Count - 1);

  if Memo1.Lines.Count > 0 then
  begin
    PDFPanel.Parent := Self;
    PDFPanel.Left   := 0;
    PDFPanel.Top    := 0;
    PDFPanel.Width  := ClientWidth;
    PDFPanel.Height := ClientHeight - ToolBar1.Height;
    PDFPanel.BringToFront;

    // Buttons unsichtbar machen...
    PDF_Erstellung.Visible := False;
    FormatBtn.Visible      := False;
    PanelBottom.Visible    := False;
  end;

  MemoBtn.Visible := True;
  Info_Anzeigen   := False;
end;

procedure TFreePDF64_Form.PDFFontsBtnClick(Sender: TObject);
var
  I: Integer;
  Befehlszeile, Work, PDFDatei: String;

  function ActiveList: TLMDShellList;
  begin
    if LMDShellList1.Focused then Result := LMDShellList1
    else Result := LMDShellList2;
  end;

  function ActiveFolder: TLMDShellFolder;
  begin
    if LMDShellList1.Focused then Result := LMDShellFolder1
    else Result := LMDShellFolder2;
  end;

  function SelectedPDF: string;
  begin
    if ActiveList.SelCount <> 1 then Exit('');
    Result := IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName) +
              ActiveList.Selected.Caption;
    if UpperCase(ExtractFileExt(Result)) <> '.PDF' then Result := '';
  end;

begin
  FavClose;

  // Fokus wiederherstellen
  if wcActive.Name = 'LMDShellList1' then LMDShellList1.SetFocus
  else if wcActive.Name = 'LMDShellList2' then LMDShellList2.SetFocus;

  // pdffonts.exe vorhanden?
  if not FileExists(XPDF_Fonts) then
  begin
    MessageDlgCenter(
      'Achtung: Die Datei "pdffonts.exe" fehlt im Ordner "' +
      IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + '"!',
      mtError, [mbOk]);
    Exit;
  end;

  Memo1.Clear;

  // PDF-Datei bestimmen
  PDFDatei := SelectedPDF;
  if PDFDatei = '' then
  begin
    MessageDlgCenter(
      'PDF Schriftarten aufgelisten: Bitte EINE PDF-Datei auswählen!',
      mtInformation, [mbOk]);
    Exit;
  end;

  // Arbeitsverzeichnis
  Work := ExtractFilePath(ActiveFolder.ActiveFolder.PathName);

  // Befehlszeile
  Befehlszeile := XPDF_Fonts + ' -loc "' + PDFDatei + '"';

  // Ausgabe nach Memo
  GetDosOutput(Memo1, Befehlszeile, Work);
  Memo1.Perform(EM_LineScroll, 0, -Memo1.Lines.Count - 1);

  // Memo-Höhe anpassen
  if Memo1.Lines.Count > 1 then
  begin
    I := TextHoehe(Memo1.Font, Memo1.Text);
    I := (I * Memo1.Lines.Count) + MHA;
    if I >= Memo1.Parent.Height then
      PDFPanel.Height := I;
  end;

  MemoBtn.Visible := True;
end;

// PDF Passwortschutz entfernen
procedure TFreePDF64_Form.PDFdecryptClick(Sender: TObject);
var
  PDFDatei, Zeile, Zeile2, EndPDF, Ziel, s: String;
  ProcID: Cardinal;
  F: TextFile;
  PDFForm: TPDFBrowserForm;

  function ActiveList: TLMDShellList;
  begin
    if LMDShellList1.Focused then Result := LMDShellList1
    else Result := LMDShellList2;
  end;

  function ActiveFolder: TLMDShellFolder;
  begin
    if LMDShellList1.Focused then Result := LMDShellFolder1
    else Result := LMDShellFolder2;
  end;

  function SelectedPDF: string;
  begin
    if ActiveList.SelCount <> 1 then Exit('');
    Result := IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName) +
              ActiveList.Selected.Caption;
    if UpperCase(ExtractFileExt(Result)) <> '.PDF' then Result := '';
  end;

  procedure Log(const S: string);
  begin
    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ==' + S));
  end;

  procedure ShowPDF(const FileName: string);
  begin
    if Einstellungen_Form.AnzeigenCB.Checked then
    begin
      Sleep(1000);
      PDFForm := TPDFBrowserForm.Create(Self);
      PDFForm.PDFFileName := FileName;
      PDFForm.Show;
      Application.ProcessMessages;
    end;
  end;

begin
  FavClose;

  // Fokus wiederherstellen
  if wcActive.Name = 'LMDShellList1' then LMDShellList1.SetFocus
  else if wcActive.Name = 'LMDShellList2' then LMDShellList2.SetFocus;

  // PDF-Datei bestimmen
  PDFDatei := SelectedPDF;
  if PDFDatei = '' then
  begin
    MessageDlgCenter(
      'PDF Passwortschutz entfernen: Bitte EINE PDF-Datei auswählen!',
      mtInformation, [mbOk]);
    Exit;
  end;

  // Zielverzeichnis erstellen
  if ForceDirectories(IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName) + 'Decrypt PDF') then
    Ziel := IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName) + 'Decrypt PDF';

  // QPDF-Befehl
  EndPDF := IncludeTrailingBackslash(Ziel) + ExtractFileName(PDFDatei);
  Zeile  := Einstellungen_Form.Edit4.Text + ' --decrypt "' + PDFDatei + '" "' + EndPDF + '"';

  // Versuch ohne Passwort
  ProcID := 0;
  if RunProcess(Zeile, SW_HIDE, True, @ProcID) = 0 then
  begin
    Memo1.Lines.Text := Zeile;

    if Logdatei.Checked then
    begin
      AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
      try Append(F) except Rewrite(F) end;

      Log('> PASSWORT ENTFERNEN: ' + Zeile);
      Log('          Quelldatei: ' + PDFDatei);
      Log('          Dateigröße: ' + FormatByteString(MyFileSize(PDFDatei)));
      Log('           Zieldatei: ' + EndPDF);
      Log('          Dateigröße: ' + FormatByteString(MyFileSize(EndPDF)));

      CloseFile(F);

      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');

      ShowPDF(EndPDF);
    end;

    Exit;
  end;

  // Passwort erforderlich
  if Einstellungen_Form.SystemklangCB.Checked then
    PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');

  if not UniInputQuery('Datei: ' + ExtractFileName(PDFDatei),
                       'Eingabe vom Passwort erforderlich:', s) then Exit;

  // QPDF mit Passwort
  Zeile2 := Einstellungen_Form.Edit4.Text +
            ' --decrypt --password="' + s + '" "' + PDFDatei + '" "' + EndPDF + '"';

  ProcID := 0;
  if RunProcess(Zeile2, SW_HIDE, True, @ProcID) = 0 then
  begin
    Memo1.Lines.Text := Zeile2;

    if Logdatei.Checked then
    begin
      AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
      try Append(F) except Rewrite(F) end;

      Log('> PASSWORT ENTFERNEN: ' + Zeile2);
      Log('          Quelldatei: ' + PDFDatei);
      Log('          Dateigröße: ' + FormatByteString(MyFileSize(PDFDatei)));
      Log('           Zieldatei: ' + EndPDF);
      Log('          Dateigröße: ' + FormatByteString(MyFileSize(EndPDF)));

      CloseFile(F);

      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');

      ShowPDF(EndPDF);
    end;
  end
  else
  begin
    if Einstellungen_Form.SystemklangCB.Checked then
      PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');

    ShowMessage('Passwort falsch - bitte erneut versuchen...');
  end;
end;

// Komprimierung einer PDF-Datei mittels QPDF
procedure TFreePDF64_Form.PDF_KompressClick(Sender: TObject);
var
  PDFDatei, QPDF_ExtractFile, Zeile, EndPDF, Ziel: String;
  ProcID: Cardinal;
  F: TextFile;
  Komprimierung: Integer;
  PDFForm: TPDFBrowserForm;

  function ActiveList: TLMDShellList;
  begin
    if LMDShellList1.Focused then Result := LMDShellList1
    else Result := LMDShellList2;
  end;

  function ActiveFolder: TLMDShellFolder;
  begin
    if LMDShellList1.Focused then Result := LMDShellFolder1
    else Result := LMDShellFolder2;
  end;

  function SelectedPDF: string;
  begin
    if ActiveList.SelCount <> 1 then Exit('');
    Result := IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName) +
              ActiveList.Selected.Caption;
    if UpperCase(ExtractFileExt(Result)) <> '.PDF' then Result := '';
  end;

  procedure Log(const S: string);
  begin
    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' ==' + S));
  end;

  procedure ShowPDF(const FileName: string);
  begin
    if Einstellungen_Form.AnzeigenCB.Checked then
    begin
      Sleep(1000);
      PDFForm := TPDFBrowserForm.Create(Self);
      PDFForm.PDFFileName := Filename;
      PDFForm.Show;
      Application.ProcessMessages;
    end;
  end;

begin
  FavClose;

  // Fokus wiederherstellen
  if wcActive.Name = 'LMDShellList1' then LMDShellList1.SetFocus
  else if wcActive.Name = 'LMDShellList2' then LMDShellList2.SetFocus;

  // PDF-Datei bestimmen
  PDFDatei := SelectedPDF;
  if PDFDatei = '' then
  begin
    MessageDlgCenter(
      'PDF komprimieren: Bitte EINE PDF-Datei auswählen!',
      mtInformation, [mbOk]);
    Exit;
  end;

  // Zielverzeichnis erstellen
  if ForceDirectories(IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName) + 'Komprimierte PDF') then
    Ziel := IncludeTrailingBackslash(ActiveFolder.ActiveFolder.PathName) + 'Komprimierte PDF';

  // QPDF-Pfad
  QPDF_ExtractFile := 'K_' + ExtractFileName(PDFDatei);
  EndPDF := IncludeTrailingBackslash(Ziel) + QPDF_ExtractFile;

  Zeile := Einstellungen_Form.Edit4.Text +
           ' --optimize-images --object-streams=generate --compression-level=9 ' +
           '--recompress-flate "' + PDFDatei + '" "' + EndPDF + '"';

  // Starte die Erstellung
  ProcID := 0;
  if RunProcess(Zeile, SW_HIDE, True, @ProcID) = 0 then
  begin
    Memo1.Lines.Text := Zeile;

    if Logdatei.Checked then
    begin
      AssignFile(F, PChar(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt'));
      try Append(F) except Rewrite(F) end;

      Komprimierung := 100 - FileSizePercent(EndPDF, PDFDatei);

      Log('=> PDF-KOMPRIMIERUNG: ' + Zeile);
      Log('          Quelldatei: ' + PDFDatei);
      Log('          Dateigröße: ' + FormatByteString(MyFileSize(PDFDatei)));
      Log('           Zieldatei: ' + EndPDF);
      Log('          Dateigröße: ' + FormatByteString(MyFileSize(EndPDF)) +
          ' (um ' + IntToStr(Komprimierung) + '% komprimiert)');

      CloseFile(F);

      AppendMemoText(#13#13 +
        'Ergebnis: "' + ExtractFileName(PDFDatei) + '" wurde um ' +
        IntToStr(Komprimierung) + '% komprimiert -> "' +
        ExtractFileName(EndPDF) + '"');

      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\confirmation.wav');

      ShowPDF(EndPDF);
    end;
  end;
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
  end
  else
  begin
    Splash1.Checked := True;
    Tray1 := False;
  end;
end;

// Einfacher Klick auf TrayIcon
procedure TFreePDF64_Form.TrayIcon1Click(Sender: TObject);
begin
  ShowVomTray := True;
  FreePDF64_Form.Visible := True;
  Application.BringToFront;

  // Hide the system tray icon and show the window, setting its state property to wsNormal
  TrayIcon1.Visible := False;

  if AutospalteJN then
  begin
    AutoSpalte.Checked := True;
    LMDShellList1.Column[0].AutoSize := True;
    LMDShellList2.Column[0].AutoSize := True;
  end
  else
    AutoSpalte.Checked := False;

  WindowState := wsNormal;
  FreePDF64_Form.BringToFront;
end;

procedure TFreePDF64_Form.TrayIcon1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  MZiel: String;
begin
  if not FreePDF64_Notify.Ziel_FestCB.Checked then
    MZiel := Ziel
  else
    MZiel := FreePDF64_Notify.ZielEdit.Text;

  // MITTLERE MAUSTASTE → Suchefenster öffnen
  if Button = mbMiddle then
  begin
    SearchBtn.Click;
    Exit;
  end;

  // Normales Rechtsklick → PopupMenu öffnen mit richtigen Verzeichnisse
  if Button = mbRight then
  begin
    if MonitorBtn.ImageIndex = 57 then
      PopupMenu3.Items.Items[0].ImageIndex := 4
    else
      PopupMenu3.Items.Items[0].ImageIndex := 5;
    PopupMenu3.Items.Items[1].Caption := IncludeTrailingBackslash(FreePDF64_Notify.MonitoringFolder.Text);
    PopupMenu3.Items.Items[2].Caption := IncludeTrailingBackslash(MZiel);
  end;
end;

procedure TFreePDF64_Form.UPDClick(Sender: TObject);
begin
  UPD.Checked := Not UPD.Checked;
  if not UPD.Checked then
  begin
    LMDShellList1.ReadOnly := True;
    LMDShellList2.ReadOnly := True;
    F2Pressed := False;
  end else
  if UPD.Checked then
  begin
    LMDShellList1.ReadOnly := False;
    LMDShellList2.ReadOnly := False;
    F2Pressed := True;
  end;
end;

procedure TFreePDF64_Form.EditorClick(Sender: TObject);
begin
  Editoraufrufen1.Click;
end;

// Kopieren
procedure TFreePDF64_Form.Btn_CopyMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Btn_Copy.Flat := True;

  try
    if Button = mbLeft then
      Kopieren1.Click
    else
    if Button = mbRight then
      CopyTo.Click;
  finally
    Btn_Copy.Flat := False;
  end;
end;

// Bewegen/Verschieben
procedure TFreePDF64_Form.Btn_MoveMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Btn_Move.Flat := True;

  try
    if Button = mbLeft then
      Bewegen1.Click
    else
    if Button = mbRight then
      MoveTo.Click;
  finally
    Btn_Move.Flat := False;
  end;
end;

// Bewegen: fFlags siehe Stichwort SHFILEOPSTRUCT
function MoveFileEx(const ASource, ADest: string;
  ARenameCheck: Boolean = False): Boolean;
var
  sh: TSHFileOpStruct;
begin
  sh.Wnd := Application.Handle;
  sh.wFunc := FO_MOVE;

  // String muss mit #0#0 terminiert werden, um das Listenende zu setzen
  sh.pFrom := pchar(ASource + #0#0);
  sh.pTo := pchar(ADest + #0#0);
  sh.fFlags := fof_MultiDestFiles;
  if ARenameCheck then
    sh.fFlags := sh.fFlags or fof_RenameOnCollision;
  Result := SHFileOperation(sh) = 0;
end;

procedure TFreePDF64_Form.Btn_NewFolderMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Btn_NewFolder.Flat := True;

  if LMDShellList1.Focused and (LMDShellList1.SelCount > 0) then
    LMDShellList1.ClearSelection
  else if LMDShellList2.Focused and (LMDShellList2.SelCount > 0) then
    LMDShellList2.ClearSelection
end;

procedure TFreePDF64_Form.Btn_NewFolderMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Btn_NewFolder.Flat := False;
end;

// Ermittlung des Betriebssystems
function OperatingSystemDisplayName: string;

  function GetWMIObject(const objectName: string): IDispatch;
  var
    chEaten: Integer;
    BindCtx: IBindCtx;
    Moniker: IMoniker;
  begin
    OleCheck(CreateBindCtx(0, BindCtx));
    OleCheck(MkParseDisplayName(BindCtx, PChar(objectName), chEaten, Moniker));
    OleCheck(Moniker.BindToObject(BindCtx, nil, IDispatch, Result));
  end;

  function VarToString(const Value: OleVariant): string;
  begin
    if VarIsStr(Value) then
    begin
      Result := Trim(Value);
    end
    else
    begin
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
    if ServicePack <> '' then
    begin
      Result := Result + ' ' + ServicePack;
    end;
    // Result := Result + ', version ' + Version + ', ';
  end;

var
  objWMIService: OleVariant;
  colItems: OleVariant;
  Item: OleVariant;
  oEnum: IEnumvariant;
  iValue: Longword;
begin
  Try
    objWMIService := GetWMIObject('winmgmts:\\localhost\root\cimv2');
    colItems := objWMIService.ExecQuery
      ('SELECT Caption, CSDVersion, Version FROM Win32_OperatingSystem',
      'WQL', 0);
    oEnum := IUnknown(colItems._NewEnum) as IEnumvariant;
    if oEnum.Next(1, Item, iValue) = 0 then
    begin
      Result := FullVersionString(Item);
      Exit;
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
  I: Integer;
begin
  LMDShellList1.ReadOnly := False;
  LMDShellList2.ReadOnly := False;
  F2Pressed := True;

  if (LMDShellList1.Focused and Assigned(LMDShellList1.Selected)) = True then
    LMDShellList1.Rename
  else
  if (LMDShellList2.Focused and Assigned(LMDShellList2.Selected)) = True then
     LMDShellList2.Rename;

  if ((LMDShellTree1.Focused and Assigned(LMDShellTree1.Selected)) = True) then
    LMDShellTree1.Rename
  else
  if ((LMDShellTree2.Focused and Assigned(LMDShellTree2.Selected)) = True) then
    LMDShellTree2.Rename;
end;

procedure TFreePDF64_Form.Btn_RenameMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Btn_Rename.Flat := True;
end;

procedure TFreePDF64_Form.Btn_RenameMouseEnter(Sender: TObject);
begin
  if not UPD.Checked then
    Btn_Rename.Hint := 'Umbenennen hiermit möglich, nicht per Doppelklick oder RMB-Kontextmenü!' + #13 +
                       'Bei Bedarf kann die Funktion unter „Optionen → Oberfläche“ aktiviert werden'
  else
    Btn_Rename.Hint := '';
end;

procedure TFreePDF64_Form.Btn_RenameMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Btn_Rename.Flat := False;
end;

// Task schließen (hier Ghostscript)
procedure KillTask(ExeFileName: string);
var
  h: HWND;
begin // ExeFileName = caption or cmd path
  h := FindWindow(NIL, LPCWSTR(ExeFileName));
  if h <> 0 then
    PostMessage(h, WM_CLOSE, 0, 0);
end;

// JPEG richtig drehen!
procedure RotateJPEGImage(const AFilename: string; AImage: TImage);
var
  GPImage: TGPImage;
  GPGraphics: TGPGraphics;
  pPropItem: PPropertyItem;
  BufferSize: Cardinal;
  Orientation: Byte;
  RotateType: TRotateFlipType;
  w, h: Integer;
  Ratio: Double;
begin
  GPImage := TGPImage.Create(AFilename);
  try
    BufferSize := GPImage.GetPropertyItemSize(PropertyTagOrientation);
    if BufferSize > 0 then
    begin
      GetMem(pPropItem, BufferSize);
      GPImage.GetPropertyItem(PropertyTagOrientation, BufferSize, pPropItem);
      Orientation := PByte(pPropItem.Value)^;
      case Orientation of
        1:
          RotateType := RotateNoneFlipNone; // Horizontal - No rotation required
        2:
          RotateType := RotateNoneFlipX;
        3:
          RotateType := Rotate180FlipNone;
        4:
          RotateType := Rotate180FlipX;
        5:
          RotateType := Rotate90FlipX;
        6:
          RotateType := Rotate90FlipNone;
        7:
          RotateType := Rotate270FlipX;
        8:
          RotateType := Rotate270FlipNone;
      else
        RotateType := RotateNoneFlipNone; // Unknown rotation?
      end;
      if RotateType <> RotateNoneFlipNone then
        GPImage.RotateFlip(RotateType);
    end;

    // Berechne das Verhältnis für die Anzeige
    Ratio := GPImage.GetWidth / AImage.Width;
    if Ratio < GPImage.GetHeight / AImage.Height then
      Ratio := GPImage.GetHeight / AImage.Height;
    w := Round(GPImage.GetWidth / Ratio);
    h := Round(GPImage.GetHeight / Ratio);

    // Lösche das aktuelle Bild in der TImage-Komponente
    AImage.Picture.Assign(nil);
    AImage.Width := w;
    AImage.Height := h;

    // Zeichne das gedrehte Bild auf die TImage-Komponente
    GPGraphics := TGPGraphics.Create(AImage.Canvas.Handle);
    try
      GPGraphics.DrawImage(GPImage, 0, 0, w, h);
    finally
      GPGraphics.Free;
    end;
  finally
    GPImage.Free;
  end;
end;

// PS/PDF-Dateien anschauen mit Ghostscript oder...
procedure TFreePDF64_Form.Btn_ViewClick(Sender: TObject);
var
  I, Offset, PDFCount, BaseOffset: Integer;
  Param: String;
  S: TStringList;
  PDFForm: TPDFBrowserForm;
begin
  if (LMDShellList1.Focused and Assigned(LMDShellList1.Selected)) = True then
    Auswahl := LMDShellList1.SelectedItem.PathName
  else if (LMDShellList2.Focused and Assigned(LMDShellList2.Selected)) = True then
    Auswahl := LMDShellList2.SelectedItem.PathName
  else
    Exit;

  // JPEG anzeigen
  if Image1.Visible then
  begin
    Image1.Visible := False;

    // Geladene Grafik vollständig freigeben
    Image1.Picture.Graphic := nil;

    LMDShellList2.Visible := True;
    Exit;
  end
  else if Image2.Visible then
  begin
    Image2.Visible := False;

    // Geladene Grafik vollständig freigeben
    Image2.Picture.Graphic := nil;

    LMDShellList1.Visible := True;
    Exit;
  end
  else
    // Bildformate anzeigen
    if (LMDShellList1.Focused and Assigned(LMDShellList1.Selected)) = True then
      if (Uppercase(ExtractFileExt(Auswahl)) = ('.JPG')) or
        (Uppercase(ExtractFileExt(Auswahl)) = ('.JPEG')) or
        (Uppercase(ExtractFileExt(Auswahl)) = ('.BMP')) or
        (Uppercase(ExtractFileExt(Auswahl)) = ('.PNG')) or
        (Uppercase(ExtractFileExt(Auswahl)) = ('.TIF')) then
      begin
        LMDShellList2.Visible := False;
        Image1.Visible := True;
        Image1.Picture.LoadFromFile(Auswahl);
        Exit;
      end;

  if (LMDShellList2.Focused and Assigned(LMDShellList2.Selected)) = True then
    if (Uppercase(ExtractFileExt(Auswahl)) = ('.JPG')) or
      (Uppercase(ExtractFileExt(Auswahl)) = ('.JPEG')) or
      (Uppercase(ExtractFileExt(Auswahl)) = ('.BMP')) or
      (Uppercase(ExtractFileExt(Auswahl)) = ('.PNG')) or
      (Uppercase(ExtractFileExt(Auswahl)) = ('.TIF')) then
    begin
      LMDShellList1.Visible := False;
      Image2.Visible := True;
      Image2.Picture.LoadFromFile(Auswahl);
      Exit;
    end;

  PDFCount := 0;
  BaseOffset := 20;

  if UpperCase(ExtractFileExt(Auswahl)) = '.PDF' then
  begin
    if LMDShellList1.Focused then
    begin
      for I := 0 to LMDShellList1.SelCount - 1 do
      begin
        PDFForm := TPDFBrowserForm.Create(Self);
        PDFForm.PDFFileName := LMDShellList1.SelectedItems[I].PathName;

        Offset := MulDiv(
          (PDFCount mod 8) * BaseOffset,
          PDFForm.CurrentPPI,
          96
        );

        PDFForm.Left := PDFForm.Left + Offset;
        PDFForm.Top := PDFForm.Top + Offset;

        PDFForm.Show;
        Application.ProcessMessages;

        Inc(PDFCount);
      end;
    end
    else if LMDShellList2.Focused then
    begin
      for I := 0 to LMDShellList2.SelCount - 1 do
      begin
        PDFForm := TPDFBrowserForm.Create(Self);
        PDFForm.PDFFileName := LMDShellList2.SelectedItems[I].PathName;

        Offset := MulDiv(
          (PDFCount mod 8) * BaseOffset,
          PDFForm.CurrentPPI,
          96
        );

        PDFForm.Left := PDFForm.Left + Offset;
        PDFForm.Top := PDFForm.Top + Offset;

        PDFForm.Show;
        Application.ProcessMessages;

        Inc(PDFCount);
      end;
    end;

    Exit;
  end;

  if (Uppercase(ExtractFileExt(Auswahl)) = ('.PRN')) or
    (Uppercase(ExtractFileExt(Auswahl)) = ('.PS')) then
  begin
    Ghostscript := Einstellungen_Form.Edit1.Text;

    if ((LMDShellList1.Focused and Assigned(LMDShellList1.Selected)) = True) or
      ((LMDShellList2.Focused and Assigned(LMDShellList2.Selected)) = True) then
    begin
      Param := '-dSAFER -dBATCH -r120 -dAutoRotatePages=/PageByPage "' +
        Auswahl + '"';

      ShellExecute(
        Application.Handle,
        'open',
        PChar(Ghostscript),
        PChar(Param),
        '',
        SW_HIDE
      );

      MessageDlgCenter('Anzeigen beendet!', mtInformation, [mbOk]);
      KillTask(Ghostscript);
    end;
  end
  else
  begin
    S := TStringList.Create;
    try
      try
        S.LoadFromFile(Auswahl, TEncoding.UTF8);
      except
        on E: Exception do
        begin
          S.LoadFromFile(Auswahl, TEncoding.ANSI);
        end;
      end;

      Memo1.Lines.Assign(S);
    finally
      S.Free;
    end;

    if Memo1.Lines.Count > 0 then
    begin
      PaneloverPrgB.Visible := True;
      PaneloverPrgB.Caption := Auswahl;

      PDFPanel.Parent := Self;
      PDFPanel.Left   := 0;
      PDFPanel.Top    := 0;
      PDFPanel.Width  := ClientWidth;
      PDFPanel.Height := ClientHeight - ToolBar1.Height;
      PDFPanel.BringToFront;

      PDF_Erstellung.Visible := False;
      FormatBtn.Visible      := False;
      PanelBottom.Visible    := False;

      MemoBtn.Visible := True;
    end
    else
    begin
      if PDFPanel.Height > PDFPanelH then
      begin
        Memo1.Clear;
        PDFPanel.Height       := PDFPanelH;
        PaneloverPrgB.Visible := False;
        MemoBtn.Visible       := False;
      end;
    end;
  end;
end;

procedure TFreePDF64_Form.Btn_ViewMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Btn_View.Flat := True;
end;

procedure TFreePDF64_Form.Btn_ViewMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Btn_View.Flat := False;
end;

// Rechtsklick auf TImage
procedure TFreePDF64_Form.Image1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
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

procedure TFreePDF64_Form.Image2ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
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
  // Einmal Taste DOWN drücken für Markierung des ersten Eintrags
  keybd_event(VK_DOWN, MapVirtualKey(VK_DOWN, 0), KEYEVENTF_EXTENDEDKEY, 0);
end;

procedure TFreePDF64_Form.Btn_DeleteMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Btn_Delete.Flat := True;
end;

procedure TFreePDF64_Form.Btn_DeleteMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Btn_Delete.Flat := False;
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
  begin
    LMDShellList2.Perform(WM_SETREDRAW, 0, 0);
    try
      LMDShellFolder1.ChDir(ComboBoxL.Items[ComboBoxL.ItemIndex])
    finally
      LMDShellList2.Perform(WM_SETREDRAW, 1, 0);
      LMDShellList2.Invalidate;
      LMDShellList2.Update;
    end;
  end else
    ComboBoxL.Items.Delete(ComboBoxL.ItemIndex);
  LMDShellList1.SetFocus;
end;

procedure TFreePDF64_Form.ComboBoxRCloseUp(Sender: TObject);
begin
  if System.SysUtils.DirectoryExists(ComboBoxR.Items[ComboBoxR.ItemIndex]) then
  begin
    LMDShellList1.Perform(WM_SETREDRAW, 0, 0);
    try
      LMDShellFolder2.ChDir(ComboBoxR.Items[ComboBoxR.ItemIndex])
    finally
      LMDShellList1.Perform(WM_SETREDRAW, 1, 0);
      LMDShellList1.Invalidate;
      LMDShellList1.Update;
    end;
  end else
    ComboBoxR.Items.Delete(ComboBoxR.ItemIndex);
  LMDShellList2.SetFocus;
end;

procedure TFreePDF64_Form.ComboBoxLDropDown(Sender: TObject);
var
  s: String;
begin
  FavClose;
  if StartsWithColons(LMDShellFolder1.ActiveFolder.PathName) then
    s := LMDShellFolder1.ActiveFolder.DisplayName
  else
    s := LMDShellFolder1.ActiveFolder.PathName;
  // Keine doppelten Einträge zulassen...
  if ComboBoxL.Items.IndexOf(s) = -1 then
    ComboBoxL.Items.Insert(0, s);
end;

procedure TFreePDF64_Form.ComboBoxRDropDown(Sender: TObject);
var
  s: String;
begin
  FavClose;

  if StartsWithColons(LMDShellFolder2.ActiveFolder.PathName) then
    s := LMDShellFolder2.ActiveFolder.DisplayName
  else
    s := LMDShellFolder2.ActiveFolder.PathName;
  // Keine doppelten Einträge zulassen...
  if ComboBoxR.Items.IndexOf(s) = -1 then
    ComboBoxR.Items.Insert(0, s);
end;

procedure TFreePDF64_Form.ConfigBtnClick(Sender: TObject);
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if Assigned(wcPrevious) then
  begin
    if wcPrevious = LMDShellList1 then
      LMDShellList1.SetFocus
    else if wcPrevious = LMDShellList2 then
      LMDShellList2.SetFocus;
  end;

  Einstellungen_Form.Position := poMainFormCenter;
  Einstellungen1.Click;
  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers
    [Printer.printerindex] + ' | Erstellte Dateien (seit Nullstellung): ' +
    IntToStr(Counter);
end;

procedure TFreePDF64_Form.DoppelKClick(Sender: TObject);
begin
  DoppelK.Checked := Not DoppelK.Checked;
end;

procedure TFreePDF64_Form.FormatverzClick(Sender: TObject);
begin
  Formatverz.Checked := NOT Formatverz.Checked;
  Formatverz_Date.Checked := False;
  Formatverz_OnlyDate.Checked := False;
end;

procedure TFreePDF64_Form.Formatverz_DateClick(Sender: TObject);
begin
  Formatverz_Date.Checked := NOT Formatverz_Date.Checked;
  Formatverz.Checked := False;
  Formatverz_OnlyDate.Checked := False;
end;

procedure TFreePDF64_Form.Formatverz_OnlyDateClick(Sender: TObject);
begin
  Formatverz_OnlyDate.Checked := NOT Formatverz_OnlyDate.Checked;
  Formatverz_Date.Checked := False;
  Formatverz.Checked := False;
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
    LMDShellList2.SetFocus;
  end;
  RefreshBt.Click;
  keybd_event(VK_DOWN, MapVirtualKey(VK_DOWN, 0), KEYEVENTF_EXTENDEDKEY, 0);
end;

// Anzeige der Datei(en) im Editor
procedure TFreePDF64_Form.BtnEditorClick(Sender: TObject);
var
  I: Integer;
begin
  try
    // Wenn eine Datei ausgewählt ist, dann...
    if (LMDShellList1.Focused and Assigned(LMDShellList1.Selected)) = True then
    begin
      // Ist mindestens ein Eintrag selektiert, dann...
      for I := 0 to LMDShellList1.SelCount - 1 do
      begin
        // Der interne Editor (Notepad) oder der in die FreePDF64.ini eingetragene wird aufgerufen...
        if Einstellungen_Form.Edit2.Text = '' then
          Einstellungen_Form.Edit2.Text := 'notepad.exe';
        ShellExecute(Application.Handle, 'open',
          PChar(Einstellungen_Form.Edit2.Text),
          PChar(' "' + IncludeTrailingBackslash
          (LMDShellFolder1.ActiveFolder.PathName) + LMDShellList1.SelectedItems
          [I].DisplayName + '"'), NIL, SW_SHOWNORMAL)
      end;
    end
    else if (LMDShellList2.Focused and Assigned(LMDShellList2.Selected)) = True
    then
    begin
      for I := 0 to LMDShellList2.SelCount - 1 do
      begin
        // Der interne Editor (Notepad) oder der in die FreePDF64.ini eingetragene wird aufgerufen...
        if Einstellungen_Form.Edit2.Text = '' then
          Einstellungen_Form.Edit2.Text := 'notepad.exe';
        ShellExecute(Application.Handle, 'open',
          PChar(Einstellungen_Form.Edit2.Text),
          PChar(' "' + IncludeTrailingBackslash
          (LMDShellFolder2.ActiveFolder.PathName) + LMDShellList2.SelectedItems
          [I].DisplayName + '"'), NIL, SW_SHOWNORMAL)
      end;
    end;
  except
    MessageBox(0, 'Anzeigefehler', 'Problem', 16);
    Exit;
  end;
end;

procedure TFreePDF64_Form.BtnEditorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  BtnEditor.Flat := True;
end;

procedure TFreePDF64_Form.BtnEditorMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  BtnEditor.Flat := False;
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
  I, j, L: Integer;
  k, s: String;
begin
  for I := 0 to FavLbL.Items.Count - 1 do
    if FavLbL.Selected[I] then
      for L := 1 to Length(ListBoxL.Items[I]) do
      begin
        j := Pos('*|*', ListBoxL.Items[I]);
        if j > 0 then
        begin
          FavLbL.Visible := False;
          k := Copy(ListBoxL.Items[I], 0, j - 1);
          s := ListBoxL.Items[I];
          Delete(s, 1, Length(k) + 3);
          if not System.SysUtils.DirectoryExists(s) then
          begin
            ShowMessage('"' + s + '" ist nicht mehr vorhanden!');
            s := ExtractFilePath(Quelllabel.Caption);
            Exit;
          end
          else
          begin
            LMDShellList1.Perform(WM_SETREDRAW, 0, 0);
            try
              LMDShellFolder1.ChDir(s);
            finally
              LMDShellList1.Perform(WM_SETREDRAW, 1, 0);
              LMDShellList1.Invalidate;
              LMDShellList1.Update;
             end;
            LMDShellList1.SetFocus;
            if LMDShellList1.Selected = NIL then
              LMDShellList1.ItemIndex := 0;
            Break;
          end;
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
  I: Integer;
begin
  with FavLbL do
  begin
    I := ItemAtPos(Point(X, Y), False);
    if (I <= Items.Count - 1) then
      FavLbL.Selected[I] := True;
  end;
end;

procedure TFreePDF64_Form.FavLbRClick(Sender: TObject);
var
  I, j, L: Integer;
  k, s: String;
begin
  for I := 0 to FavLbR.Items.Count - 1 do
    if FavLbR.Selected[I] then
      for L := 1 to Length(ListBoxR.Items[I]) do
      begin
        j := Pos('*|*', ListBoxR.Items[I]);
        if j > 0 then
        begin
          FavLbR.Visible := False;
          k := Copy(ListBoxR.Items[I], 0, j - 1);
          s := ListBoxR.Items[I];
          Delete(s, 1, Length(k) + 3);
          if not System.SysUtils.DirectoryExists(s) then
          begin
            ShowMessage('"' + s + '" ist nicht mehr vorhanden!');
            s := Ziel;
            Exit;
          end
          else
          begin
            LMDShellList2.Perform(WM_SETREDRAW, 0, 0);
            try
              LMDShellFolder2.ChDir(s);
            finally
              LMDShellList2.Perform(WM_SETREDRAW, 1, 0);
              LMDShellList2.Invalidate;
              LMDShellList2.Update;
            end;
            LMDShellList2.SetFocus;
            if LMDShellList2.Selected = NIL then
              LMDShellList2.ItemIndex := 0;
            Break;
          end;
        end;
      end;
  FavLbR.Visible := False;
  Ziel := IncludeTrailingBackslash(s);
  Ziellabel.Caption := 'Ziel - ' + MinimizeName(IncludeTrailingBackslash(Ziel) +
    '*.*', FreePDF64_Form.Canvas,
    Ziellabel.Width - (FavSpR.Width + FavRechts.Width + ParentFolderR.Width +
    ZielBtn.Width +
    ComboBoxR.Width))
end;

procedure TFreePDF64_Form.FavLbRMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FavLbR.ItemIndex := FavLbR.ItemAtPos(Point(X, Y), True);
end;

procedure TFreePDF64_Form.FavLbRMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  I: Integer;
begin
  with FavLbR do
  begin
    I := ItemAtPos(Point(X, Y), False);
    if (I <= Items.Count - 1) then
      FavLbR.Selected[I] := True;
  end;
end;

function MaxValue(Box: TListBox): Integer;
var
  I, max: Integer;
begin
  // der Variablen max die oberste Zahl in der Listbox zugewiesen
  max := Box.Canvas.TextWidth(Box.Items[0]);
  // for-Schleife, alle Zahlen der Listbox werden durchgegangen
  for I := 0 to Box.Items.Count - 1 do
  begin
    // wenn eine Zahl größer als max ist wird diese Zahl in der Variablen max gespeichert
    if max < Box.Canvas.TextWidth(Box.Items[I]) then
      max := Box.Canvas.TextWidth(Box.Items[I]);
  end;
  // der Rückgabewert, also die größte Zahl
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
  end
  else
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
  end
  else
    FavLbR.Visible := False;
end;

// Favoriten hinzufügen links
procedure TFreePDF64_Form.FavSpLClick(Sender: TObject);
begin
  FavClose;
  Favoriten_Form.Position := poMainFormCenter;
  Favoriten_Form.ShowModal;
  Favoritenspeichern1.Click;
end;

// Favoriten hinzufügen rechts
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
  ShellExecute(FreePDF64_Form.Handle, 'open', 'mailto:FreePDF64@outlook.com' +
    '?subject=Feedback zu FreePDF64', NIL, NIL, SW_SHOWNORMAL);
end;

procedure TFreePDF64_Form.FilterTBClick(Sender: TObject);
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else if wcActive.Name = 'LMDShellList2' then
    LMDShellList2.SetFocus;

  Filter1.Click;
end;

// Dateifilter definieren
procedure TFreePDF64_Form.Filter1Click(Sender: TObject);
begin
  if LMDShellList1.Focused then
  begin
    Links := True;
    Rechts := False;
  end
  else
  begin
    Links := False;
    Rechts := True;
  end;
  // Form soll mittig angezeigt werden.
  Filter_Form.Position := poMainFormCenter;
  Filter_Form.ShowModal;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers
    [Printer.printerindex] + ' | Erstellte Dateien (seit Nullstellung): ' +
    IntToStr(Counter);
end;

procedure TFreePDF64_Form.FormatBtnClick(Sender: TObject);
begin
  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else if wcActive.Name = 'LMDShellList2' then
    LMDShellList2.SetFocus;

  Einstellungen1.Click;
end;

procedure TFreePDF64_Form.FormatBtnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormatBtn.Flat := True;
end;

procedure TFreePDF64_Form.FormatBtnMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FormatBtn.Flat := False;
end;

procedure TFreePDF64_Form.PlaySoundFile(FileName: string);
begin
  if FileExists(FileName) then
    PlaySound(PChar(FileName), 0, SND_ASYNC or SND_FILENAME);

  { Flags are:
    SND_SYNC  =0 = Start playing, and wait for the sound to finish
    SND_ASYNC =1 = Start playing, and don't wait to return
    SND_LOOP  =8 = Keep looping the sound until another sound is played }
end;

// Word: 0 - 65535, wobei 65535 die lauteste Stärke ist
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
  vol := volL + volR shl 16;
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

procedure TFreePDF64_Form.WMQueryEndSession(var Msg: TWMQueryEndSession);
begin
  try
    Application.ProcessMessages;
    // Code, um Ressourcen freizugeben
    Msg.Result := 1; // Erlaubt das Herunterfahren
  except
    on E: Exception do
    begin
      ShowMessage('Fehler beim Beenden von FreePDF64!' + E.Message);
      Msg.Result := 0; // Shutdown verhindern
    end;
  end;
end;

procedure TFreePDF64_Form.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if KlickaufX.Checked then
  begin
    CanClose := False;
    if AutoSpalte.Checked then
      AutospalteJN := True
    else
      AutospalteJN := False;

    if Systray_Taskleiste.Checked then
    begin
      FreePDF64_Form.Visible := False;
      TrayIcon1.Visible := True;
    end
    else
      FreePDF64_Form.WindowState := wsMinimized;
  end;
end;

procedure TFreePDF64_Form.FormCreate(Sender: TObject);
var
  I: Integer;
  Ini: TIniFile;
  IniPath, S: string;
  Entry: string;
begin
  Application.HintHidePause := 5000;
  UseLatestCommonDialogs := False;
  MsgDlgIcons[mtInformation] := TMsgDlgIcon.mdiInformation;
  Screen.OnActiveControlChange := ActiveControlChanged;

  // Grundzustände
  PDFPanelH := PDFPanel.Height;
  AutospalteJN := False;
  ShowVomTray := False;
  Suche_ItemAnzeigen := False;
  Baum := 0;
  FormLoaded := False;
  Versch1 := 2;

  IniPath := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) + 'FreePDF64.ini';

  if FileExists(IniPath) then
  begin
    try
      Ini := TIniFile.Create(IniPath);

      // Netzwerkfilter
      ShowNetworkShares.Checked := Ini.ReadBool('Start', 'ShowNetworkShares Button', ShowNetworkShares.Checked);
      LMDShellTree1.Filtered := not ShowNetworkShares.Checked;
      LMDShellList1.Filtered := not ShowNetworkShares.Checked;
      LMDShellTree2.Filtered := not ShowNetworkShares.Checked;
      LMDShellList2.Filtered := not ShowNetworkShares.Checked;
      LMDShellFolder1.Filtered := not ShowNetworkShares.Checked;
      LMDShellFolder2.Filtered := not ShowNetworkShares.Checked;

      LMDShellTree1.RefreshBranches(LMDShellTree1.Selected.Parent);
      LMDShellTree2.RefreshBranches(LMDShellTree2.Selected.Parent);

      // Fensterpositionen
      Left   := Ini.ReadInteger('Position', 'Left', Left);
      Top    := Ini.ReadInteger('Position', 'Top', Top);
      Width  := Ini.ReadInteger('Position', 'Width', Width);
      Height := Ini.ReadInteger('Position', 'Height', Height);

      Panel_Left.Width  := Ini.ReadInteger('Position', 'Left Tree Width', Panel_Left.Width);
      PDFPanel.Height   := Ini.ReadInteger('Position', 'Memo Panel Height', PDFPanel.Height);
      PanelR.Width      := Ini.ReadInteger('Position', 'Right Panel Width', PanelR.Width);
      PDFPanelH         := PDFPanel.Height;

      // Folder-Einstellungen
      LMDShellList1.GridLines := Ini.ReadBool('Folder', 'Gridlines', LMDShellList1.GridLines);
      LMDShellList2.GridLines := LMDShellList1.GridLines;

      ResizeEqual.Checked := Ini.ReadBool('Folder', 'ResizeEqual', ResizeEqual.Checked);
      VersteckteDateienanzeigen1.Checked := Ini.ReadBool('Folder', 'ShowHidden', VersteckteDateienanzeigen1.Checked);

      // Startoptionen
      InDenTray.Checked := Ini.ReadBool('Start', 'System Tray', InDenTray.Checked);
      Systray_Taskleiste.Checked := Ini.ReadBool('Start', 'System Tray/Taskbar', Systray_Taskleiste.Checked);
      KlickaufX.Checked := Ini.ReadBool('Start', 'Minimize', KlickaufX.Checked);
      DoppelK.Checked := Ini.ReadBool('Start', 'Create with DoubleClick', DoppelK.Checked);
      AutoFormat.Checked := Ini.ReadBool('Start', 'Format selection based on ext.', AutoFormat.Checked);

      Formatverz.Checked := Ini.ReadBool('Start', 'Create Formatfolder', Formatverz.Checked);
      Formatverz_Date.Checked := Ini.ReadBool('Start', 'Create Formatfolder with Date', Formatverz_Date.Checked);
      Formatverz_OnlyDate.Checked := Ini.ReadBool('Start', 'Create Formatfolder only Date', Formatverz_OnlyDate.Checked);

      Logdatei.Checked := Ini.ReadBool('Start', 'Logdatei', Logdatei.Checked);

      AutoSizeBtn.Checked := Ini.ReadBool('Start', 'AutoSize Button', AutoSizeBtn.Checked);
      AutoSize.Enabled := AutoSizeBtn.Checked;

      UPD.Checked := Ini.ReadBool('Start', 'Rename by double-clicking', UPD.Checked);

      if not Ini.ValueExists('Start', 'Splashscreen') then
        Ini.WriteBool('Start', 'Splashscreen', True);
      Splash1.Checked := Ini.ReadBool('Start', 'Splashscreen', Splash1.Checked);

      // History Links
      for I := 0 to 253 do
      begin
        Entry := Ini.ReadString('History', 'History Left' + IntToStr(I), '');
        if Entry = '' then Break;
        ComboBoxL.Items.Add(Entry);
      end;

      // History Rechts
      for I := 0 to 253 do
      begin
        Entry := Ini.ReadString('History', 'History Right' + IntToStr(I), '');
        if Entry = '' then Break;
        ComboBoxR.Items.Add(Entry);
      end;

      // Favoriten Links
      for I := 0 to 253 do
      begin
        Entry := Ini.ReadString('Favorites Left', IntToStr(I), '');
        if Entry = '' then Break;

        S := Copy(Entry, 1, Pos('*|*', Entry) - 1);
        if S <> '' then FavLbL.Items.Add(S);

        ListBoxL.Items.Add(Entry);
      end;

      // Favoriten Rechts
      for I := 0 to 253 do
      begin
        Entry := Ini.ReadString('Favorites Right', IntToStr(I), '');
        if Entry = '' then Break;

        S := Copy(Entry, 1, Pos('*|*', Entry) - 1);
        if S <> '' then FavLbR.Items.Add(S);

        ListBoxR.Items.Add(Entry);
      end;

      Ini.Free;
    except
      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
      ShowMessage('Error');
    end;
  end
  else
    Splash1.Checked := True;

  MenuItemRightJustify(Hilfe1);

  // Buttons ausrichten
  I := Width div 7;

  Btn_Rename.Align := alLeft;
  Btn_Rename.Width := I;

  BtnEditor.Align := alLeft;
  BtnEditor.Width := I;

  Btn_View.Align := alLeft;
  Btn_View.Width := I;

  Btn_Copy.Align := alLeft;
  Btn_Copy.Width := I;

  Btn_Move.Align := alLeft;
  Btn_Move.Width := I;

  Btn_NewFolder.Align := alLeft;
  Btn_NewFolder.Width := I;

  Btn_Delete.Align := alClient;
  Btn_Delete.Width := I;
end;

procedure TFreePDF64_Form.QuellBtnClick(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile, s: string;
begin
  FavClose;
  try
    // Aufruf der Initialisierungsdatei 'FreePDF64.ini'
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
    IniDat := TIniFile.Create(IniFile);
    with IniDat do
      s := ReadString('Folder', 'Left', A_S);
    IniDat.Free;
  except
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) +
          'sounds\alert.wav');
      ShowMessage('Error');
    end;
  end;

  if FreePDF64_Form.Visible then
  begin
    LMDShellList1.Perform(WM_SETREDRAW, 0, 0);
    try
      LMDShellFolder1.ChDir(s);
    finally
      LMDShellList1.Perform(WM_SETREDRAW, 1, 0);
      LMDShellList1.Invalidate;
      LMDShellList1.Update;
    end;

    if LMDShellList1.Selected = NIL then
      LMDShellList1.ItemIndex := 0;
  end;
end;

procedure TFreePDF64_Form.ZielBtnClick(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile, s: string;
begin
  FavClose;
  try
    // Aufruf der Initialisierungsdatei 'FreePDF64.ini'
    IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
    IniDat := TIniFile.Create(IniFile);
    with IniDat do
      s := ReadString('Folder', 'Target', B_Z);
    IniDat.Free;
  except
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) +
          'sounds\alert.wav');
      ShowMessage('Error');
    end;
  end;

  if FreePDF64_Form.Visible then
  begin
    LMDShellList2.Perform(WM_SETREDRAW, 0, 0);
    try
      LMDShellFolder2.ChDir(s);
    finally
      LMDShellList2.Perform(WM_SETREDRAW, 1, 0);
      LMDShellList2.Invalidate;
      LMDShellList2.Update;
    end;
    if LMDShellList2.Selected = NIL then
      LMDShellList2.ItemIndex := 0;
  end;
end;

procedure TFreePDF64_Form.QuellBtnMouseEnter(Sender: TObject);
begin
  QuellBtn.Hint := 'Schneller Sprung ins gespeicherte Quellverzeichnis:' +
    #10#13 +
    MinimizeName(IncludeTrailingBackslash(A_S), FreePDF64_Form.Canvas,
    Quelllabel.Width - 250);
end;

procedure TFreePDF64_Form.ZielBtnMouseEnter(Sender: TObject);
begin
  ZielBtn.Hint := 'Schneller Sprung ins gespeicherte Zielverzeichnis:' + #10#13 +
    MinimizeName(IncludeTrailingBackslash(B_Z), FreePDF64_Form.Canvas,
    Ziellabel.Width - 250);
end;

procedure TFreePDF64_Form.FormResize(Sender: TObject);
var
  Laenge: Integer;
begin
  // Ist die FreePDF64_Form nun sichtbar?
  if FormLoaded = True then
  begin
    if ResizeEqual.Checked and Panel_Right.Visible then
      PanelR.Width := (PanelL.Width + Panel_Right.Width + PanelR.Width) div 2;
  end;

  // Fenster hat wieder die normale Größe
  if WindowState = wsNormal then
  begin
    // Splitter soll sich in der Mitte befinden.
    if ResizeEqual.Checked and Panel_Right.Visible then
      PanelR.Width := (PanelL.Width + Panel_Right.Width + PanelR.Width) div 2
    else
    if ResizeEqual.Checked and not Panel_Right.Visible then
      PanelR.Width := (PanelL.Width + PanelR.Width) div 2;
  end;

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

procedure TFreePDF64_Form.SuchenHistorylschen1Click(Sender: TObject);
var
  IniDat: TIniFile;
  IniFile, Msg: String;
  I: Integer;
begin
  Msg := 'Soll die Suchen nach-/Suchen in-/Textsuche-History im Suche-Fenster wirklich gelöscht werden?';
  if MessageDlgCenter(Msg, mtInformation, [mbYes, mbNo]) = mrYes then
  begin
    Suche_Form.SearchField.Items.Clear;
    Suche_Form.FileField.Items.Clear;
    Suche_Form.TextCB.Items.Clear;
    try
      IniFile := ExtractFilePath(Application.ExeName) + 'FreePDF64.ini';
      IniDat := TIniFile.Create(IniFile);
      // Speichere beim Beenden des Programmes in die 'FreePDF64.ini'
      with IniDat do
        // Verlauf Suche-Form schreiben.
        IniDat.EraseSection('Search');
      if Suche_Form.SearchField.Items.Count > 0 then
        for I := 0 to Suche_Form.SearchField.Items.Count do
          IniDat.WriteString('Search', 'SearchField' + IntToStr(I),
            Suche_Form.SearchField.Items[I]);

      if Suche_Form.FileField.Items.Count > 0 then
        for I := 0 to Suche_Form.FileField.Items.Count do
          IniDat.WriteString('Search', 'FileField' + IntToStr(I),
            Suche_Form.FileField.Items[I]);

      // Textsuche schreiben.
      if Suche_Form.TextCB.Items.Count > 0 then
        for I := 0 to Suche_Form.TextCB.Items.Count do
          IniDat.WriteString('Search', 'Textsearch' + IntToStr(I),
            Suche_Form.TextCB.Items[I]);

      IniDat.WriteInteger('Search', 'Top', Suche_Form.Top);
      IniDat.WriteInteger('Search', 'Left', Suche_Form.Left);
      IniDat.WriteInteger('Search', 'Height', Suche_Form.Height);
      IniDat.WriteInteger('Search', 'Width', Suche_Form.Width);
      // Speicher wird wieder freigeben
      IniDat.Free;
    except
      ShowMessage('Fehler festgestellt!');
    end;
  end;
end;

// Linke/Rechte History löschen
procedure TFreePDF64_Form.History1Click(Sender: TObject);
var
  Msg: String;
begin
  Msg := 'Soll die linke und rechte Verzeichnis-History wirklich gelöscht werden?';
  if MessageDlgCenter(Msg, mtInformation, [mbYes, mbNo]) = mrYes then
  begin
    ComboBoxL.Items.Clear;
    ComboBoxR.Items.Clear
  end;
end;

procedure TFreePDF64_Form.Info2Click(Sender: TObject);
begin
  // Form soll mittig angezeigt werden.
  Info_Form.Position := poScreenCenter;
  Info_Form.ShowModal;
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

function GetCurrentUserName: string;
var
  Buffer: array[0..255] of Char;
  Size: DWORD;
begin
  Size := Length(Buffer);
  if GetUserName(Buffer, Size) then
    Result := Buffer
  else
    Result := '';
end;

// Soll bei einem Druckerwechsel ansprechen, damit der neue Standarddrucker angezeigt wird
procedure TFreePDF64_Form.WMSettingChange(var Message: TMessage);
begin
  Printer.printerindex := -1;
  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers
    [Printer.printerindex] + ' | Erstellte Dateien (seit Nullstellung): ' +
    IntToStr(Counter);
end;

// Beim Minimieren die Form verstecken und Icon in die TNA
procedure TFreePDF64_Form.WMSysCommand(var Message: TWMSysCommand);
begin
  // Fenster wurde minimiert
  if Message.CmdType and $FFF0 = SC_MINIMIZE then
  begin
    if AutoSpalte.Checked then
      AutospalteJN := True
    else
      AutospalteJN := False;

    if FreePDF64_Form.Visible then
    begin
      if Systray_Taskleiste.Checked then
      begin
        FreePDF64_Form.Visible := False;
        TrayIcon1.Visible := True;
      end
      else
        FreePDF64_Form.WindowState := wsMinimized;
    end;
  end
  else
    inherited;
end;

function ListViewSort(Item1, Item2: TListItem; Data: Integer): Integer; stdcall;
var
  ColumnIndex: Integer;
begin
  ColumnIndex := Data;

  if Item1.SubItems.Count > ColumnIndex then
    Result := CompareText(Item1.SubItems[ColumnIndex],
      Item2.SubItems[ColumnIndex])
  else
    Result := 0;
end;

procedure TFreePDF64_Form.FormShow(Sender: TObject);
var
  c, I, ie1, VS_Left, VS_Right: Integer;
  IniDat: TIniFile;
  IniFile, ies, s, s1, s2, z1, BasePath: string;
  tmpt: TLMDShellListOptions;
  tmpt2: TLMDShellTreeOptions;
  iec: Array [0 .. 255] of String;
  regKey: TRegistry;
  Notify_Active: Boolean;
begin
  if ShowVomTray then
  begin
    ShowVomTray := False;
    Exit;
  end;

  if not UPD.Checked then
  begin
    LMDShellList1.ReadOnly := True;
    LMDShellList2.ReadOnly := True;
    F2Pressed := False;
  end else
  if UPD.Checked then
  begin
    LMDShellList1.ReadOnly := False;
    LMDShellList2.ReadOnly := False;
    F2Pressed := True;
  end;

  BasePath := ExtractFilePath(Application.ExeName);
  IniFile  := IncludeTrailingBackslash(BasePath) + 'FreePDF64.ini';

  FreePDF64_Form.Caption := 'FreePDF64 - die PDF-Toolsammlung | ' + GetCurrentUserName +
                            ' | ' + ComputerName + ' | ' + OperatingSystemDisplayName;

  FAbbrechen := False;
  Info_Anzeigen := False;

  // Kontextmenü-Aufruf
  if ParamCount > 0 then
  begin
    Merge.Click;
    Close;
    Exit;
  end;

  // Pfade zu Definition_files
  ViewJPEG := BasePath + 'gs\lib\viewjpeg.ps';
  PDFA_1   := BasePath + 'Definition_files\PDFA.ps';
  PDFX_1   := BasePath + 'Definition_files\PDFX.ps';

  Autostart.Checked := False;

  // ============================================================================
  // Wenn die FreePDF64-Ini-Datei nicht vorgefunden wird...
  // ============================================================================
  if not FileExists(IniFile) then
  begin
    // Ghostscript
    Einstellungen_Form.Edit1.Text := BasePath + 'gs\bin\gswin64c.exe';
    // QPDF
    Einstellungen_Form.Edit4.Text := BasePath + 'qpdf\bin\qpdf.exe';
    // PDFtk
    Einstellungen_Form.Edit5.Text := BasePath + 'pdftk\pdftk.exe';
    // ImageMagick-Converter
    Einstellungen_Form.Edit7.Text := BasePath + 'ImageMagick\';
    ImageMagick := IncludeTrailingBackslash(Einstellungen_Form.Edit7.Text) + 'magick.exe';
    // ExifTool
    Einstellungen_Form.Edit8.Text := BasePath + 'ExifTool\';
    ExifTool := IncludeTrailingBackslash(Einstellungen_Form.Edit8.Text) + 'exiftool.exe';
    // XPDF-Tools
    Einstellungen_Form.Edit6.Text := BasePath + 'xpdf\bin64\';
    XPDF_Images := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdfimages.exe';
    XPDF_ToHTML := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdftohtml.exe';
    XPDF_Detach := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdfdetach.exe';
    XPDF_Fonts := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdffonts.exe';

    LMDShellFolder1.RootFolder := BasePath + 'Quellverzeichnis';
    LMDShellFolder2.RootFolder := BasePath + 'Zielverzeichnis';

    FreePDF64_Notify.MonitoringFolder.Text := 'C:\FreePDF64\Quellverzeichnis\';
    FreePDF64_Notify.btnStart.Click;

    LMDShellList1.GridLines := True;
    LMDShellList2.GridLines := True;

    // Splitter mittig
    PanelR.Width := (PanelL.Width + Panel_Right.Width + PanelR.Width) div 2;

    MonitorBtn.ImageIndex := 57;
    MonitorBtn.Caption := '  AN';
    MHA := 80;

    try
      IniDat := TIniFile.Create(IniFile);
      with IniDat do
      begin
        WriteInteger('Start', 'ColumnsL Width0', 100);
        WriteInteger('Start', 'ColumnsL Width1', 100);
        WriteInteger('Start', 'ColumnsL Width2', 70);
        WriteInteger('Start', 'ColumnsL Width3', 100);
        WriteInteger('Start', 'ColumnsR Width0', 100);
        WriteInteger('Start', 'ColumnsR Width1', 100);
        WriteInteger('Start', 'ColumnsR Width2', 70);
        WriteInteger('Start', 'ColumnsR Width3', 100);
        WriteInteger('Start', 'ShowFolders', Baum);
        WriteBool('Start', 'Autostart', Autostart.Checked);
        WriteBool('Folder', 'Gridlines', LMDShellList1.GridLines);
        WriteBool('Folder', 'Gridlines', LMDShellList2.GridLines);
        WriteBool('Folder', 'ResizeEqual', ResizeEqual.Checked);
      end;
      IniDat.Free;
    except
      begin
        if Einstellungen_Form.SystemklangCB.Checked then
          PlaySoundFile(BasePath + 'sounds\alert.wav');
        ShowMessage('Error');
      end;
    end;

    AllesSpeichern;

    if Self.Visible then
    begin
      Splashscreen_Form.Position := poScreenCenter;
      Splashscreen_Form.ShowModal;
    end;

    Exit;
  end;
  // Ende von -> Wenn die FreePDF64-Ini-Datei nicht vorgefunden wird...
  // ============================================================================

  // Standardpfade sicherstellen (wenn INI existiert)
  if Einstellungen_Form.Edit1.Text = '' then
    Einstellungen_Form.Edit1.Text := BasePath + 'gs\bin\gswin64c.exe';
  if Einstellungen_Form.Edit4.Text = '' then
    Einstellungen_Form.Edit4.Text := BasePath + 'qpdf\bin\qpdf.exe';
  if Einstellungen_Form.Edit5.Text = '' then
    Einstellungen_Form.Edit5.Text := BasePath + 'pdftk\pdftk.exe';
  if Einstellungen_Form.Edit7.Text = '' then
    Einstellungen_Form.Edit7.Text := BasePath + 'ImageMagick\';
  ImageMagick := IncludeTrailingBackslash(Einstellungen_Form.Edit7.Text) + 'magick.exe';
  if Einstellungen_Form.Edit8.Text = '' then
    Einstellungen_Form.Edit8.Text := BasePath + 'ExifTool\';
  ExifTool := IncludeTrailingBackslash(Einstellungen_Form.Edit8.Text) + 'exiftool.exe';
  if Einstellungen_Form.Edit6.Text = '' then
    Einstellungen_Form.Edit6.Text := BasePath + 'xpdf\bin64\';
  XPDF_Images  := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdfimages.exe';
  XPDF_ToHTML  := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdftohtml.exe';
  XPDF_Detach  := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdfdetach.exe';
  XPDF_Fonts   := IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + 'pdffonts.exe';

  Memo1.Height := 64;

  // ============================================================================
  // Wenn die FreePDF64-Ini-Datei vorgefunden wird...
  // ============================================================================
  try
    IniDat := TIniFile.Create(IniFile);
    with IniDat do
    begin
      // Spaltenbreiten
      LMDShellList1.Column[0].Width := ReadInteger('Start', 'ColumnsL Width0', c);
      LMDShellList1.Column[1].Width := ReadInteger('Start', 'ColumnsL Width1', c);
      LMDShellList1.Column[2].Width := ReadInteger('Start', 'ColumnsL Width2', c);
      LMDShellList1.Column[3].Width := ReadInteger('Start', 'ColumnsL Width3', c);
      LMDShellList2.Column[0].Width := ReadInteger('Start', 'ColumnsR Width0', c);
      LMDShellList2.Column[1].Width := ReadInteger('Start', 'ColumnsR Width1', c);
      LMDShellList2.Column[2].Width := ReadInteger('Start', 'ColumnsR Width2', c);
      LMDShellList2.Column[3].Width := ReadInteger('Start', 'ColumnsR Width3', c);

      VS_Left := ReadInteger('Start', 'ViewStyle_Left', Ord(vsReport));
      LMDShellList1.ViewStyle := TViewStyle(VS_Left);
      VS_Right := ReadInteger('Start', 'ViewStyle_Right', Ord(vsReport));
      LMDShellList2.ViewStyle := TViewStyle(VS_Right);

      if FreePDF64_Notify.MonitoringFolder.Text = '' then
        FreePDF64_Notify.MonitoringFolder.Text := 'C:\FreePDF64\Quellverzeichnis\';

      if not ValueExists('Folder', 'Left') then
      begin
        Ziel := BasePath + 'Zielverzeichnis';
        A_S  := BasePath + 'Quellverzeichnis';
        B_Z  := Ziel;
      end
      else
      begin
        A_S  := ReadString('Folder', 'Left', A_S);
        B_Z  := ReadString('Folder', 'Target', B_Z);
        Ziel := B_Z;
      end;

      FreePDF64_Notify.MonitoringFolder.Text := ReadString('Monitoring', 'Folder', FreePDF64_Notify.MonitoringFolder.Text);
      try
        UpdateFreePDF64PrinterSourceDirectory(FreePDF64_Notify.MonitoringFolder.Text);
      except
        // Fehler ignorieren
      end;

      Notify_Active := ReadBool('Monitoring', 'Start', FreePDF64_Notify.LMDShellNotify.Active);
      FreePDF64_Notify.SpinEditSec.Value :=
        ReadInteger('Monitoring', 'Time', FreePDF64_Notify.SpinEditSec.Value);
      FreePDF64_Notify.Ziel_FestCB.Checked :=
        ReadBool('Monitoring', 'Fixed', FreePDF64_Notify.Ziel_FestCB.Checked);
      FreePDF64_Notify.BenachrichtigungCB.Checked :=
        ReadBool('Monitoring', 'Note', FreePDF64_Notify.BenachrichtigungCB.Checked);
      z1 := ReadString('Monitoring', 'Fixed Folder', FreePDF64_Notify.ZielEdit.Text);

      Einstellungen_Form.AnzeigenCB.Checked :=
        ReadBool('Format', 'View File', Einstellungen_Form.AnzeigenCB.Checked);
      Einstellungen_Form.SystemklangCB.Checked :=
        ReadBool('Format', 'System Sound', Einstellungen_Form.SystemklangCB.Checked);
      Einstellungen_Form.PDF_Shrink.Checked :=
        ReadBool('Format', 'Shrink PDF', Einstellungen_Form.PDF_Shrink.Checked);
      Einstellungen_Form.PDF_Shrink2.Checked :=
        ReadBool('Format', 'Shrink PDF2', Einstellungen_Form.PDF_Shrink2.Checked);
      Einstellungen_Form.Shrink2CB.Checked :=
        ReadBool('Format', 'Shrink PDF2 Overwrite', Einstellungen_Form.Shrink2CB.Checked);

      Baum := ReadInteger('Start', 'ShowFolders', Baum);
      Wasserzeichen_Form.Edit1.Text :=
        ReadString('Start', 'Watermark/Stamp', Wasserzeichen_Form.Edit1.Text);
      Wasserzeichen_Form.bgWatermark.Checked :=
        ReadBool('Start', 'Watermark bg', Wasserzeichen_Form.bgWatermark.Checked);
      Wasserzeichen_Form.vgStamp.Checked :=
        ReadBool('Start', 'Stamp fg', Wasserzeichen_Form.vgStamp.Checked);

      AutoSpalte.Checked := ReadBool('Folder', 'Autosize Name', AutoSpalte.Checked);
      Autostart.Checked := ReadBool('Start', 'Autostart', Autostart.Checked);

      Dateianlage_Form.Datei1.Text :=
        ReadString('Files', 'Datei Vorne', Dateianlage_Form.Datei1.Text);
      Dateianlage_Form.Datei2.Text :=
        ReadString('Files', 'Datei Hinten', Dateianlage_Form.Datei2.Text);

      Einstellungen_Form.HeightSpin.Value :=
        ReadInteger('Start', 'Memo Height Addition', Einstellungen_Form.HeightSpin.Value);
      Einstellungen_Form.SoundSpin.Value :=
        ReadInteger('Format', 'System Sound Volume 0-65535', Einstellungen_Form.SoundSpin.Value);

      FreePDF64_Notify.ZielEdit.Text := IncludeTrailingBackslash(z1);

      if Splash1.Checked then
      begin
        Splashscreen_Form.Position := poScreenCenter;
        Splashscreen_Form.ShowModal;
      end;

      if not ValueExists('Start', 'Counter') then
        Counter := 0
      else
        Counter := ReadInteger('Start', 'Counter', Counter);

      Vol1 := Einstellungen_Form.SoundSpin.Value;
      if (Vol1 < 0) or (Vol1 > 65535) then
        Vol1 := 65535;
      Vol2 := Vol1;
      SetVolume(Vol1, Vol2);

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
      Einstellungen_Form.Zusatz.Enabled := Einstellungen_Form.ZusatzAnAus.Checked;

      Einstellungen_Form.FontCB.Checked := ReadBool('Zusatz', 'Memo Font', Einstellungen_Form.FontCB.Checked);
      if Einstellungen_Form.FontCB.Checked then
      begin
        Memo1.Font.Name := 'Consolas';
        Memo1.Font.Size := 10;
      end
      else
      begin
        Memo1.Font.Name := 'Courier New';
        Memo1.Font.Size := 10;
      end;

      if not FreePDF64_Notify.Ziel_FestCB.Checked then
        FreePDF64_Notify.ZielEdit.Text := IncludeTrailingBackslash(LMDShellFolder2.RootFolder);

      // Suche-SearchField lesen
      for I := 0 to 254 do
      begin
        iec[I] := ReadString('Search', 'SearchField' + IntToStr(I), s);
        if iec[I] = '' then
          Break;
        Suche_Form.SearchField.Items.Insert(I, iec[I]);
      end;

      // Suche-FileField lesen
      for I := 0 to 254 do
      begin
        iec[I] := ReadString('Search', 'FileField' + IntToStr(I), s);
        if iec[I] = '' then
          Break;
        Suche_Form.FileField.Items.Insert(I, iec[I]);
      end;

      // Suche-Textsuche lesen
      for I := 0 to 254 do
      begin
        iec[I] := ReadString('Search', 'Textsearch' + IntToStr(I), s);
        if iec[I] = '' then
          Break;
        Suche_Form.TextCB.Items.Insert(I, iec[I]);
      end;

      // Filter lesen
      for ie1 := 0 to 9 do
      begin
        iec[ie1] := ReadString('Filter', 'Filter' + IntToStr(ie1), ies);
        if iec[ie1] = '' then
          Break;
        Filter_Form.FilterCB.Items.Insert(ie1, iec[ie1]);
      end;

      // Zusatz lesen
      Zusatz_Form.ZusatzCB.Items.Clear;
      for ie1 := 0 to 19 do
      begin
        Zusatz_Form.ZusatzCB.Items.BeginUpdate;
        try
          iec[ie1] := ReadString('Other', 'Zeichenketten' + IntToStr(ie1), ies);
          if iec[ie1] = '' then
            Break;
          Zusatz_Form.ZusatzCB.Items.Add(iec[ie1]);
        finally
          Zusatz_Form.ZusatzCB.Items.EndUpdate;
        end;
      end;

      FSortAscending  := True;
      FSortAscending2 := True;
      FSortColumn     := ReadInteger('Start', 'Sort ColumnL', FSortColumn);
      FSortColumn2    := ReadInteger('Start', 'Sort ColumnR', FSortColumn2);
      FSortAscending  := ReadBool('Start', 'SortDir ColumnL', FSortAscending);
      FSortAscending2 := ReadBool('Start', 'SortDir ColumnR', FSortAscending2);
    end;
    IniDat.Free;
  except
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(BasePath + 'sounds\alert.wav');
      ShowMessage('Error');
    end;
  end;
  // Ende von -> Wenn die FreePDF64-Ini-Datei vorgefunden wird...
  // ============================================================================

  // Vorgabewert beim Start des Programms
  if Einstellungen_Form.AuswahlRG.ItemIndex = 0 then
    Text_FormatBtn := ' PS/PDF zu PDF '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 1 then
    Text_FormatBtn := ' PDF zu PS '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 2 then
    Text_FormatBtn := ' PDF zu DOCX '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 3 then
    Text_FormatBtn := ' PS/PDF zu TXT '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 4 then
    Text_FormatBtn := ' PS/PDF zu BMP '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 5 then
    Text_FormatBtn := ' PS/PDF zu JPEG '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 6 then
    Text_FormatBtn := ' PS/PDF zu PNG '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 7 then
    Text_FormatBtn := ' PS/PDF zu TIFF G4 - BW '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 8 then
    Text_FormatBtn := ' PS/PDF zu TIFF LZW - BW '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 9 then
    Text_FormatBtn := ' PS/PDF zu TIFF (uncompressed) '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 10 then
    Text_FormatBtn := ' BMP zu PDF '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 11 then
    Text_FormatBtn := ' JPEG zu PDF '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 12 then
    Text_FormatBtn := ' PNG zu PDF '
  else if Einstellungen_Form.AuswahlRG.ItemIndex = 13 then
    Text_FormatBtn := ' TIFF zu PDF ';
  FormatBtn.Caption := 'Formatauswahl:' + Text_FormatBtn;

  if not FormLoaded then
  begin
    // Quell-Label
    if StartsWithColons(LMDShellFolder1.ActiveFolder.PathName) then
      s2 := LMDShellFolder1.ActiveFolder.DisplayName
    else
      s2 := LMDShellFolder1.ActiveFolder.PathName;
    Quelllabel.Caption := 'Quelle - ' +
      MinimizeName(IncludeTrailingBackslash(s2) + '*.*', Canvas,
        Quelllabel.Width - (FavSpL.Width + FavLinks.Width +
        ParentFolderL.Width + QuellBtn.Width + ComboBoxL.Width));

    // Ziel-Label
    if StartsWithColons(LMDShellFolder2.ActiveFolder.PathName) then
      s2 := LMDShellFolder2.ActiveFolder.DisplayName
    else
      s2 := LMDShellFolder2.ActiveFolder.PathName;
    Ziellabel.Caption := 'Ziel - ' +
      MinimizeName(IncludeTrailingBackslash(s2) + '*.*', Canvas,
        Ziellabel.Width - (FavSpR.Width + FavRechts.Width +
        ParentFolderR.Width + ZielBtn.Width + ComboBoxR.Width));

    Gitternetzlinien1.Checked := LMDShellList1.GridLines;

    if AutoSpalte.Checked then
    begin
      LMDShellList1.Column[0].AutoSize := True;
      LMDShellList2.Column[0].AutoSize := True;
      Height := Height + 1;
      Height := Height - 1;
    end;

    tmpt  := LMDShellList1.Options;
    tmpt2 := LMDShellTree1.Options;
    if VersteckteDateienanzeigen1.Checked then
    begin
      Include(tmpt, loShowHidden);
      Include(tmpt2, toShowHidden);
    end
    else
    begin
      Exclude(tmpt, loShowHidden);
      Exclude(tmpt2, toShowHidden);
    end;
    LMDShellList1.Options := tmpt;
    LMDShellList2.Options := tmpt;
    LMDShellTree1.Options := tmpt2;
    LMDShellTree2.Options := tmpt2;

    if Ziel = '' then
    begin
      Ziel := IncludeTrailingBackslash(BasePath);
      LMDShellFolder2.RootFolder := Ziel;
    end;

    FreePDF64_Notify.LMDShellNotify.Active := Notify_Active;

    DokuInfo_Form.Clear.Click;
    DokuInfo_Form.MetadatenCB.Checked := False;

    // RootFolder-Einträge aus Comboboxen entfernen
    for I := ComboBoxL.Items.Count - 1 downto 0 do
      if ComboBoxL.Items[I] = LMDShellFolder1.RootFolder then
        ComboBoxL.Items.Delete(I);
    for I := ComboBoxR.Items.Count - 1 downto 0 do
      if ComboBoxR.Items[I] = LMDShellFolder2.RootFolder then
        ComboBoxR.Items.Delete(I);

    SB_Left;
    SB_Right;

    StatusBar1.Panels[0].Text :=
      'Standarddrucker: ' + Printer.Printers[Printer.PrinterIndex] +
      ' | Erstellte Dateien (seit Nullstellung): ' + IntToStr(Counter);

    // Registry-Autostart
    regKey := TRegistry.Create;
    try
      regKey.RootKey := HKEY_CURRENT_USER;
      if regKey.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', False) then
      begin
        Autostart.Checked := regKey.ValueExists('FreePDF64');
        regKey.CloseKey;
      end;
    finally
      regKey.Free;
    end;

    // PDFA.ps anpassen
    s1 := IncludeTrailingBackslash(BasePath);
    s := s1;
    for I := 1 to Length(s) do
      if s[I] = '\' then
        s[I] := '/';
    s1 := s;
    with TStringList.Create do
      try
        LoadFromFile(BasePath + 'Definition_files\PDFA.ps');
        Delete(6);
        Insert(6, '/ICCProfile (' + s1 + 'Definition_files/default_rgb.icc)');
        SaveToFile(BasePath + 'Definition_files\PDFA.ps');
      finally
        Free;
      end;

    LogBt.Hint :=
      'LMB: Ansehen im unteren Anzeigefenster' + #13 +
      'RMB: Ansehen im externen Editor';

    FreePDF64_Notify.LMDShellNotify.WatchFolder := Trim(IncludeTrailingBackslash(FreePDF64_Notify.MonitoringFolder.Text));
    if FreePDF64_Notify.LMDShellNotify.Active then
    begin
      MonitorBtn.ImageIndex := 57;
      MonitorBtn.Caption := '  AN';
    end
    else
    begin
      MonitorBtn.ImageIndex := 58;
      MonitorBtn.Caption := '  AUS';
    end;

    if FSortColumn >= 0 then
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

    if WindowState = wsMinimized then
      if Splash1.Checked then
      begin
        Splashscreen_Form.Position := poScreenCenter;
        Splashscreen_Form.ShowModal;
      end;

    // Baum-Startabfrage
    LMDShellTree1.Visible := (Baum = 2) or (Baum = 3);
    LMDShellTree2.Visible := (Baum = 3);

    FolderBtn.Click;

    TClickSplitter(Splitter2).OnDblClick := SplDblClick;
    TClickSplitter(Splitter3).OnDblClick := SplDblClick3;

    LMDShellList1.ClearSelection;
    LMDShellList2.ClearSelection;
    if LMDShellList1.Items.Count > 0 then
      LMDShellList1.ItemIndex := 0;
    LMDShellList1.SetFocus;

    LMDShellList1.Perform(WM_SETREDRAW, 0, 0);
    try
      LMDShellFolder1.ChDir(A_S);
    finally
      LMDShellList1.Perform(WM_SETREDRAW, 1, 0);
      LMDShellList1.Invalidate;
      LMDShellList1.Update;
    end;
    LMDShellList2.Perform(WM_SETREDRAW, 0, 0);
    try
      LMDShellFolder2.ChDir(B_Z);
      LMDShellFolder2.RootFolder := B_Z;
    finally
      LMDShellList2.Perform(WM_SETREDRAW, 1, 0);
      LMDShellList2.Invalidate;
      LMDShellList2.Update;
    end;

    QuellBtn.Click;
    ZielBtn.Click;

    FormLoaded := True;

    Timer2.Enabled := InDenTray.Checked;
  end;
end;

procedure TFreePDF64_Form.Gitternetzlinien1Click(Sender: TObject);
begin
  Gitternetzlinien1.Checked := Not Gitternetzlinien1.Checked;
  LMDShellList1.GridLines := Gitternetzlinien1.Checked;
  LMDShellList2.GridLines := Gitternetzlinien1.Checked;
end;

procedure TFreePDF64_Form.LMDShellFolder1Change(Sender: TObject);
var
  I, j: Integer;
  s: String;
begin
  try
    // ------------------------------------------------------------
    // Index des vorherigen Verzeichnisses bestimmen
    // ------------------------------------------------------------
    if LMDShellFolder1.BackwardPathList.Count >= 2 then
      I := LMDShellFolder1.BackwardPathList.Count - 2
    else
      I := -1;

    // ------------------------------------------------------------
    // Normale Navigation
    //
    // Bei einem Sprung aus dem Suchefenster wird dieser komplette
    // Block übersprungen.
    // ------------------------------------------------------------
    if not Suche_ItemAnzeigen then
    begin
      if I >= 0 then
      begin
        s := ExtractFileName(
          LMDShellFolder1.BackwardPathList.Strings[I]
        );

        // Eintrag suchen und markieren
        for j := 0 to LMDShellList1.Items.Count - 1 do
        begin
          if SameText(
            LMDShellList1.Items[j].Caption,
            s
          ) then
          begin
            LMDShellList1.ItemIndex := j;
            LMDShellList1.Selected := LMDShellList1.Items[j];
            Break;
          end;
        end;
      end;

      // Falls nichts markiert wurde, ersten Eintrag auswählen
      if (LMDShellList1.Items.Count > 0) and
         (LMDShellList1.SelCount = 0) then
      begin
        LMDShellList1.ItemIndex := 0;
      end;
    end;

    // ------------------------------------------------------------
    // Aktuellen Pfad ermitteln
    // ------------------------------------------------------------
    if StartsWithColons(LMDShellFolder1.ActiveFolder.PathName) then
      s := LMDShellFolder1.ActiveFolder.DisplayName
    else
      s := LMDShellFolder1.ActiveFolder.PathName;

    // ------------------------------------------------------------
    // Quellenanzeige aktualisieren
    // ------------------------------------------------------------
    Quelllabel.Caption :=
      'Quelle - ' +
      MinimizeName(
        IncludeTrailingBackslash(s) + '*.*',
        Canvas,
        Quelllabel.Width -
          (FavSpL.Width +
           FavLinks.Width +
           ParentFolderL.Width +
           QuellBtn.Width +
           ComboBoxL.Width)
      );

    // ------------------------------------------------------------
    // Pfad nur hinzufügen, wenn noch nicht vorhanden
    // ------------------------------------------------------------
    if ComboBoxL.Items.IndexOf(s) = -1 then
      ComboBoxL.Items.Insert(0, s);

    // ------------------------------------------------------------
    // Normale Navigation:
    // SB_Left nur dann ausführen.
    //
    // Beim Sprung aus der Suche ist der zusätzliche Aufruf
    // nicht erforderlich.
    // ------------------------------------------------------------
    if not Suche_ItemAnzeigen then
      SB_Left;

    // ------------------------------------------------------------
    // AutoSize:
    // Bei einem Suchsprung nicht durchführen.
    // ------------------------------------------------------------
    if (not Suche_ItemAnzeigen) and AutoSpalte.Checked then
    begin
      LMDShellList1.Column[0].AutoSize := True;
      LMDShellList2.Column[0].AutoSize := True;
    end;

    // ------------------------------------------------------------
    // Reset für Suche
    // ------------------------------------------------------------
    Suche_ItemAnzeigen := False;

    // ------------------------------------------------------------
    // QL bleibt erhalten
    // ------------------------------------------------------------
    QL;

  finally
    // ------------------------------------------------------------
    // Wurde der Change durch einen Doppelklick auf ein
    // Verzeichnis ausgelöst?
    //
    // Dann war die LMDShellList während der Navigation
    // für das Zeichnen gesperrt.
    // ------------------------------------------------------------
    if FDirectoryNavigation1 then
    begin
      FDirectoryNavigation1 := False;

      // Zeichnen wieder einschalten
      LMDShellList1.Perform(WM_SETREDRAW, 1, 0);

      // Jetzt genau einmal neu zeichnen
      LMDShellList1.Invalidate;
      LMDShellList1.Update;
    end;
  end;
end;

procedure TFreePDF64_Form.LMDShellFolder2Change(Sender: TObject);
var
  I, j: Integer;
  s, fileName: String;
begin
  // ------------------------------------------------------------
  // Zeichnen der LMDShellList2 während des Verzeichniswechsels
  // unterdrücken, um Flackern zu vermeiden.
  // ------------------------------------------------------------
  try

    // ------------------------------------------------------------
    // Index des vorherigen Verzeichnisses bestimmen
    // ------------------------------------------------------------
    if LMDShellFolder2.BackwardPathList.Count >= 2 then
      I := LMDShellFolder2.BackwardPathList.Count - 2
    else
      I := -1;

    // ------------------------------------------------------------
    // Wenn aus dem Suchefenster heraus das markierte Item
    // angezeigt werden soll, diesen Block überspringen.
    // ------------------------------------------------------------
    if not Suche_ItemAnzeigen then
    begin
      if I >= 0 then
      begin
        fileName := ExtractFileName(
          LMDShellFolder2.BackwardPathList.Strings[I]
        );

        // Eintrag suchen und markieren
        for j := 0 to LMDShellList2.Items.Count - 1 do
        begin
          if SameText(
            LMDShellList2.Items[j].Caption,
            fileName
          ) then
          begin
            LMDShellList2.ItemIndex := j;
            LMDShellList2.Selected := LMDShellList2.Items[j];
            Break;
          end;
        end;
      end;

      // Falls nichts markiert wurde, ersten Eintrag auswählen
      if (LMDShellList2.Items.Count > 0) and
         (LMDShellList2.SelCount = 0) then
      begin
        LMDShellList2.ItemIndex := 0;
      end;
    end;

    // ------------------------------------------------------------
    // Anzeige des aktuellen Pfads
    // ------------------------------------------------------------
    if StartsWithColons(LMDShellFolder2.ActiveFolder.PathName) then
      s := LMDShellFolder2.ActiveFolder.DisplayName
    else
      s := LMDShellFolder2.ActiveFolder.PathName;

    // ------------------------------------------------------------
    // Zielpfad aktualisieren
    // ------------------------------------------------------------
    Ziel := IncludeTrailingBackslash(
      LMDShellFolder2.ActiveFolder.PathName
    );

    // ------------------------------------------------------------
    // Zielanzeige aktualisieren
    // ------------------------------------------------------------
    Ziellabel.Caption :=
      'Ziel - ' +
      MinimizeName(
        IncludeTrailingBackslash(s) + '*.*',
        Canvas,
        Ziellabel.Width -
          (FavSpR.Width +
           FavRechts.Width +
           ParentFolderR.Width +
           ZielBtn.Width +
           ComboBoxR.Width)
      );

    // ------------------------------------------------------------
    // Pfad nur hinzufügen, wenn noch nicht vorhanden
    // ------------------------------------------------------------
    if ComboBoxR.Items.IndexOf(s) = -1 then
      ComboBoxR.Items.Insert(0, s);

    // ------------------------------------------------------------
    // Nur bei normaler Navigation ausführen
    // ------------------------------------------------------------
    if not Suche_ItemAnzeigen then
      SB_Right;

    // ------------------------------------------------------------
    // AutoSize:
    // Bei einem Suchsprung nicht durchführen.
    // ------------------------------------------------------------
    if (not Suche_ItemAnzeigen) and AutoSpalte.Checked then
    begin
      LMDShellList1.Column[0].AutoSize := True;
      LMDShellList2.Column[0].AutoSize := True;
    end;

    // ------------------------------------------------------------
    // Reset für Suche
    // ------------------------------------------------------------
    Suche_ItemAnzeigen := False;

    // ------------------------------------------------------------
    // ZL bleibt erhalten
    // ------------------------------------------------------------
    ZL;

  finally
    // ------------------------------------------------------------
    // Zeichnen wieder einschalten
    // ------------------------------------------------------------
    LMDShellList2.Perform(WM_SETREDRAW, 1, 0);

    // Nur einmal neu zeichnen
    LMDShellList2.Invalidate;
    LMDShellList2.Update;
  end;
end;

// Verzeichnis löschen
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

// PDF zu Bilder
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
    MessageDlgCenter('Achtung: Die Datei "pdfimages.exe" fehlt im Ordner "' +
      IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + '"!',
      mtError, [mbOk]);
    Exit;
  end;
  Bildziel := IncludeTrailingBackslash(Ziel) + 'Extrahierte Bilder';

  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else if wcActive.Name = 'LMDShellList2' then
    LMDShellList2.SetFocus;

  if (LMDShellList1.Focused and (LMDShellList1.SelCount = 1)) or
    (LMDShellList2.Focused and (LMDShellList2.SelCount = 1)) then
  begin
    if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
      FileName := ExtractFileName(LMDShellList1.SelectedItem.PathName)
    else
      FileName := ExtractFileName(LMDShellList2.SelectedItem.PathName);
    // Wenn der Zielordner schon vorhanden ist, dann Umbenennen...
    repeat
      Ziel2 := Bildziel;
      // Gibt es Ziel2, dann INC...
      if DirectoryExists(Ziel2) then
      begin
        INC(j);
        Ziel2 := Bildziel + '_' + IntToStr(j);
      end;
      // Wiederhole alles solange...
    until not DirectoryExists(Ziel2);
    Bildziel := Ziel2;

    // Abfrage, ob das Extrahieren funktionieren wird...
    if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
      Zeile := XPDF_Images + ' -j "' + LMDShellList1.SelectedItem.PathName
        + '" >NIL'
    else
      Zeile := XPDF_Images + ' -j "' + LMDShellList2.SelectedItem.PathName
        + '" >NIL';

    ProcID := 0;
    // Ja wird funktionieren. Weiter geht's mit Erstellung der Ziel-Verzeichnisse...
    if RunProcess(Zeile, SW_HIDE, True, @ProcID) = 0 then
    begin
      // Verzeichnis erstellen "Extrahierte Bilder"
      if System.SysUtils.ForceDirectories(Bildziel) then
        if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
          Zeile := XPDF_Images + ' -j "' + LMDShellList1.SelectedItem.PathName +
            '" "' + Bildziel + '\' + FileName + '"'
        else
          Zeile := XPDF_Images + ' -j "' + LMDShellList2.SelectedItem.PathName +
            '" "' + Bildziel + '\' + FileName + '"';
      // Starte nun die richtige Erstellung...
      if RunProcess(Zeile, SW_HIDE, True, @ProcID) = 0 then
        if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
          Memozeile := XPDF_Images + ' -j "' +
            LMDShellList1.SelectedItem.PathName + '" "' + Bildziel + '\' +
            ExtractFileName(FileName) + '-xxxx.xxx' + '"'
        else
          Memozeile := XPDF_Images + ' -j "' +
            LMDShellList2.SelectedItem.PathName + '" "' + Bildziel + '\' +
            ExtractFileName(FileName) + '-xxxx.xxx' + '"'
    end
    else
    begin
      MessageDlgCenter('Fehler beim Extrahieren von Bildern aus der Datei: "' +
        FileName + '".' + #13 +
        'Vermutlich ist die PDF-Datei verschlüsselt, enthält kein Bild oder es ist keine PDF-Datei?!',
        mtError, [mbOk]);
      ProgressBar1.Position := 0;
      Exit;
    end;

    if IsEmptyFolder(Bildziel) then
    begin
      DelDir(Bildziel);
      MessageDlgCenter('Fehler beim Extrahieren von Bildern aus der Datei: "' +
        FileName + '".' + #13 +
        'Vermutlich ist die PDF-Datei verschlüsselt, enthält kein Bild oder es ist keine PDF-Datei?!',
        mtError, [mbOk]);
      Exit;
    end;
    if Einstellungen_Form.SystemklangCB.Checked then
      PlaySoundFile(ExtractFilePath(Application.ExeName) +
        'sounds\confirmation.wav');

    // FreePDF64Log.txt
    if Logdatei.Checked then
    begin
      Memo1.Lines.Text := Memozeile;
      // Logdatei (FreePDF64Log.txt) öffnen/beschreiben etc.
      AssignFile(F, PChar(ExtractFilePath(Application.ExeName) +
        'FreePDF64Log.txt'));
      try
        Append(F);
      except
        Rewrite(F)
      end;
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
        ' ==> EXTRAHIERTE BILDER: ' + Zeile));
      if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
      begin
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
          ' -           Quelldatei: ' + LMDShellList1.SelectedItem.PathName));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
          ' -           Dateigröße: ' + FormatByteString
          (MyFileSize(LMDShellList1.SelectedItem.PathName))));
      end
      else
      begin
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
          ' -           Quelldatei: ' + LMDShellList2.SelectedItem.PathName));
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
          ' -           Dateigröße: ' + FormatByteString
          (MyFileSize(LMDShellList2.SelectedItem.PathName))));
      end;
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
        ' -        Zieldatei(en): ' + IncludeTrailingBackslash(Bildziel) +
        ExtractFileName(FileName) + '-xxxx.xxx'));
      Closefile(F);
    end;
  end;

  if Uppercase(ExtractFileExt(FileName)) <> '.PDF' then
  begin
    MessageDlgCenter
      ('PDF Bilder extrahieren: Bitte EINE PDF-Datei aus dem Quell- oder Zielverzeichnis auswählen!',
      mtInformation, [mbOk]);
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
    MessageDlgCenter('Achtung: Die Datei "pdftohtml.exe" fehlt im Ordner "' +
      IncludeTrailingBackslash(Einstellungen_Form.Edit6.Text) + '"!',
      mtError, [mbOk]);
    Exit;
  end;
  HTMLZiel := IncludeTrailingBackslash(Ziel) + 'HTML';

  FavClose;

  // Was war die letzte aktive Komponente?
  if wcActive.Name = 'LMDShellList1' then
    LMDShellList1.SetFocus
  else if wcActive.Name = 'LMDShellList2' then
    LMDShellList2.SetFocus;

  if (LMDShellList1.Focused and (LMDShellList1.SelCount = 1)) or
    (LMDShellList2.Focused and (LMDShellList2.SelCount = 1)) then
  begin
    if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
      FileName := ExtractFileName(LMDShellList1.SelectedItem.PathName)
    else
      if LMDShellList2.Focused and (LMDShellList2.SelCount = 1) then
      FileName := ExtractFileName(LMDShellList2.SelectedItem.PathName);

    if Uppercase(ExtractFileExt(FileName)) <> '.PDF' then
    begin
      MessageDlgCenter
        ('PDF zu HTML: Bitte EINE PDF-Datei aus dem Quell- oder Zielverzeichnis auswählen!',
        mtInformation, [mbOk]);
      Exit;
    end;

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

    if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
      Zeile := XPDF_ToHTML + ' -meta -overwrite -q "' +
        LMDShellList1.SelectedItem.PathName + '" "' + HTMLZiel + '"'
    else
      Zeile := XPDF_ToHTML + ' -meta -overwrite -q "' +
        LMDShellList2.SelectedItem.PathName + '" "' + HTMLZiel + '"';

    // Starte die Erstellung...
    ProcID := 0;
    if RunProcess(Zeile, SW_HIDE, True, @ProcID) = 0 then
    begin
      if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
        Memozeile := XPDF_ToHTML + ' -meta -overwrite -q "' +
          LMDShellList1.SelectedItem.PathName + '" "' + HTMLZiel + '\"'
      else
        Memozeile := XPDF_ToHTML + ' -meta -overwrite -q "' +
          LMDShellList2.SelectedItem.PathName + '" "' + HTMLZiel + '\"';
      Memo1.Lines.Text := Memozeile;
      // FreePDF64Log.txt
      if Logdatei.Checked then
      begin
        // Logdatei (FreePDF64Log.txt) öffnen/beschreiben etc.
        AssignFile(F, PChar(ExtractFilePath(Application.ExeName) +
          'FreePDF64Log.txt'));
        try
          Append(F);
        except
          Rewrite(F)
        end;
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
          ' =========> PDF ZU HTML: ' + Zeile));
        if LMDShellList1.Focused and (LMDShellList1.SelCount = 1) then
        begin
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
            ' -           Quelldatei: ' + LMDShellList1.SelectedItem.PathName));
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
            ' -           Dateigröße: ' + FormatByteString
            (MyFileSize(LMDShellList1.SelectedItem.PathName))));
        end
        else
        begin
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
            ' -           Quelldatei: ' + LMDShellList2.SelectedItem.PathName));
          Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
            ' -           Dateigröße: ' + FormatByteString
            (MyFileSize(LMDShellList2.SelectedItem.PathName))));
        end;
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
          ' -      Zielverzeichnis: ' + HTMLZiel));
        Closefile(F);

        if Einstellungen_Form.SystemklangCB.Checked then
          PlaySoundFile(ExtractFilePath(Application.ExeName) +
            'sounds\confirmation.wav');
      end;
    end
    else
    begin
      MessageDlgCenter('Fehler beim Konvertieren zu HTML aus der Datei: "' +
        FileName + '".' + #13 +
        'Vermutlich ist die PDF-Datei verschlüsselt oder es ist keine PDF-Datei?!',
        mtError, [mbOk]);
      ProgressBar1.Position := 0;
      if IsEmptyFolder(IncludeTrailingBackslash(Ziel) + 'HTML') then
        DelDir(IncludeTrailingBackslash(Ziel) + 'HTML');
    end;
  end
  else
  begin
    MessageDlgCenter
      ('Konvertieren PDF zu HTML: Bitte EINE PDF-Datei aus dem Quell- oder Zielverzeichnis auswählen!',
      mtInformation, [mbOk]);
    Exit;
  end;
end;

procedure TFreePDF64_Form.LMDShellList1Click(Sender: TObject);
var
  I: Integer;
begin
  FavClose;

  if LMDShellList1.Items.Count = 0 then
    Exit;

  Memo1.Clear;

  if (LMDShellList1.Items.Count > 0) and (LMDShellList1.SelCount = 0) then
  begin
    for I := 0 to LMDShellList1.Items.Count - 1 do
      LMDShellList1.Items[I].Selected := LMDShellList1.Items[I].Selected or
        LMDShellList1.Items[I].Focused;
    Exit;
  end
  else
    if Image1.Visible then
    Image1.Picture.LoadFromFile(LMDShellList1.SelectedItem.PathName)
  else
    if not DirectoryExists(LMDShellList1.SelectedItem.PathName) then
end;

// Starte die Erstellung mit Doppelklick auf ein Listenelement, außer es ist ein Verzeichnis...
procedure TFreePDF64_Form.LMDShellList1DblClick(Sender: TObject);
begin
  if LMDShellList1.SelCount = 0 then
    Exit;

  // ------------------------------------------------------------
  // Doppelklick auf ein Verzeichnis
  // ------------------------------------------------------------
  if System.SysUtils.DirectoryExists(
       LMDShellList1.SelectedItem.PathName) then
  begin
    // Die normale LMD-Ordnernavigation bleibt aktiv.
    // Das angeklickte Verzeichnis wird weiterhin automatisch
    // an LMDShellFolder1 übergeben.
    LMDShellList1.SuppressDefaultAction := False;

    // Zeichnen während des internen Verzeichniswechsels
    // unterdrücken.
    FDirectoryNavigation1 := True;
    LMDShellList1.Perform(WM_SETREDRAW, 0, 0);

    Exit;
  end;

  // ------------------------------------------------------------
  // Doppelklick auf eine Datei
  // ------------------------------------------------------------
  if DoppelK.Checked then
  begin
    // Die normale LMD-Aktion für die Datei unterdrücken.
    LMDShellList1.SuppressDefaultAction := True;

    PDF_Erstellung.Click;
  end
  else
    LMDShellList1.SuppressDefaultAction := False;
end;

procedure TFreePDF64_Form.LMDShellList1Enter(Sender: TObject);
begin
  PDF_Erstellung.Enabled := True;

  if (LMDShellList1.Items.Count > 0) and (LMDShellList1.SelCount = 0) then
    LMDShellList1.ItemFocused;

  if LMDShellList1.FileFilter <> '*.*' then
    FilterTB.ImageIndex := 69
  else
    FilterTB.ImageIndex := 68;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers
    [Printer.printerindex] + ' | Erstellte Dateien (seit Nullstellung): ' +
    IntToStr(Counter);

  Quelllabel.Color := clGradientActiveCaption;
  Ziellabel.Color := clBtnFace;
end;

procedure TFreePDF64_Form.LMDShellList1FilterItem(Sender: TObject; ShellItem: TLMDCustomShellItem; var Accept: Boolean);
begin
  Accept := not ShellItem.DisplayName.Contains('\\');
end;

function GetFileModifiedTime(const FileName: string): TDateTime;
var
  FileHandle: THandle;
  FileData: TWin32FindData;
  stUTC, stLocal: TSystemTime;
begin
  FileHandle := FindFirstFile(PChar(FileName), FileData);
  if FileHandle <> INVALID_HANDLE_VALUE then
  begin
    try
      // ftLastWriteTime IMMER als UTC interpretieren
      FileTimeToSystemTime(FileData.ftLastWriteTime, stUTC);

      // UTC → lokale Zeit (Sommerzeit korrekt)
      SystemTimeToTzSpecificLocalTime(nil, stUTC, stLocal);

      Result := SystemTimeToDateTime(stLocal);
    finally
      Winapi.Windows.FindClose(FileHandle);
    end;
  end
  else
    Result := 0;
end;

function GetFileTypeName(const FileName: string): string;
var
  Info: SHFileInfo;
begin
  if SHGetFileInfo(PChar(FileName), 0, Info, SizeOf(Info),
                   SHGFI_TYPENAME or SHGFI_USEFILEATTRIBUTES) <> 0 then
    Result := Info.szTypeName
  else
    Result := '';
end;

function GetKnownFolderPath(const KnownFolderID: TGUID): string;
var
  Path: PWideChar;
begin
  Result := '';
  if SHGetKnownFolderPath(KnownFolderID, 0, 0, Path) = S_OK then
  begin
    Result := Path;
    CoTaskMemFree(Path);
  end;
end;

function ResolveRealFolderPath(const Caption, FilePath: string): string;
const
  MAP: array[0..8] of record
    Key: string;
    Path: string;
  end = (
    // Caption‑Mapping
    (Key: 'benutzer';            Path: 'KNOWN:UserProfiles'),
    (Key: 'users';               Path: 'KNOWN:UserProfiles'),
    (Key: 'programme';           Path: 'KNOWN:ProgramFiles'),
    (Key: 'program files';       Path: 'KNOWN:ProgramFiles'),
    (Key: 'programme (x86)';     Path: 'KNOWN:ProgramFilesX86'),
    (Key: 'program files (x86)'; Path: 'KNOWN:ProgramFilesX86'),
    (Key: 'perflogs';            Path: 'C:\PerfLogs'),

    // Junction‑Mapping
    (Key: 'c:\programme';        Path: 'KNOWN:ProgramFiles'),
    (Key: 'c:\programme (x86)';  Path: 'KNOWN:ProgramFilesX86')
  );
var
  I: Integer;
  C, F: string;
begin
  C := Caption.ToLower;
  F := FilePath.ToLower;

  for I := Low(MAP) to High(MAP) do
  begin
    if (C = MAP[I].Key) or (F = MAP[I].Key) then
    begin
      if MAP[I].Path.StartsWith('KNOWN:') then
      begin
        if MAP[I].Path = 'KNOWN:UserProfiles'    then Exit(GetKnownFolderPath(FOLDERID_UserProfiles));
        if MAP[I].Path = 'KNOWN:ProgramFiles'    then Exit(GetKnownFolderPath(FOLDERID_ProgramFiles));
        if MAP[I].Path = 'KNOWN:ProgramFilesX86' then Exit(GetKnownFolderPath(FOLDERID_ProgramFilesX86));
      end
      else
        Exit(MAP[I].Path);
    end;
  end;

  Result := FilePath;
end;

procedure TFreePDF64_Form.LMDShellList1InfoTip(Sender: TObject; Item: TListItem;
  var InfoTip: string);
var
  FilePath: string;
  RealPath: string;
  SR: TSearchRec;
  IsDir: Boolean;
  ModifiedDT: TDateTime;
  ModifiedStr: string;
  TypeName: string;
begin
  InfoTip := '';

  if LMDShellList1.ViewStyle = vsList then
  begin
    FilePath := IncludeTrailingBackslash(LMDShellFolder1.ActiveFolder.PathName) + Item.Caption;
    RealPath := ResolveRealFolderPath(Item.Caption, FilePath);

    // Normale Dateiattribute
    if FindFirst(RealPath, faAnyFile, SR) = 0 then
    begin
      IsDir := (SR.Attr and faDirectory) <> 0;
      FindClose(SR);
    end
    else
    begin
      // ⭐ Spezialfall: Ordner nicht lesbar (Programme, WindowsApps, PerfLogs, Junctions)
      FreePDF64_Form.StatusBar_Left.SimpleText :=
        Item.Caption + ', Dateiordner, Datum in dieser Ansicht nicht lesbar';
      Exit;
    end;

    // Ordner
    if IsDir then
    begin
      ModifiedDT := GetFileModifiedTime(RealPath);

      if ModifiedDT = 0 then
      begin
        FreePDF64_Form.StatusBar_Left.SimpleText :=
          Item.Caption + ', Dateiordner, Datum in dieser Ansicht nicht lesbar';
        Exit;
      end;

      ModifiedStr := FormatDateTime('dd.mm.yyyy hh:nn:ss', ModifiedDT);

      FreePDF64_Form.StatusBar_Left.SimpleText :=
        Item.Caption + ', Dateiordner, Geändert: ' + ModifiedStr;
    end

    // Datei
    else
    begin
      ModifiedDT  := GetFileModifiedTime(RealPath);
      ModifiedStr := FormatDateTime('dd.mm.yyyy hh:nn:ss', ModifiedDT);
      TypeName    := GetFileTypeName(RealPath);

      FreePDF64_Form.StatusBar_Left.SimpleText :=
        Item.Caption + ', ' +
        FormatByteString(SR.Size) + ', ' +
        TypeName + ', ' + ModifiedStr;
    end;
  end;
end;

procedure TFreePDF64_Form.LMDShellList2InfoTip(Sender: TObject; Item: TListItem;
  var InfoTip: string);
var
  FilePath: string;
  RealPath: string;
  SR: TSearchRec;
  IsDir: Boolean;
  ModifiedDT: TDateTime;
  ModifiedStr: string;
  TypeName: string;
begin
  InfoTip := '';

  if LMDShellList2.ViewStyle = vsList then
  begin
    FilePath := IncludeTrailingBackslash(LMDShellFolder2.ActiveFolder.PathName) + Item.Caption;
    RealPath := ResolveRealFolderPath(Item.Caption, FilePath);

    // Normale Dateiattribute
    if FindFirst(RealPath, faAnyFile, SR) = 0 then
    begin
      IsDir := (SR.Attr and faDirectory) <> 0;
      FindClose(SR);
    end
    else
    begin
      // ⭐ Spezialfall: Ordner nicht lesbar (Programme, WindowsApps, PerfLogs, Junctions)
      FreePDF64_Form.StatusBar_Right.SimpleText :=
        Item.Caption + ', Dateiordner, Datum in dieser Ansicht nicht lesbar';
      Exit;
    end;

    // Ordner
    if IsDir then
    begin
      ModifiedDT := GetFileModifiedTime(RealPath);

      if ModifiedDT = 0 then
      begin
        FreePDF64_Form.StatusBar_Right.SimpleText :=
          Item.Caption + ', Dateiordner, Datum in dieser Ansicht nicht lesbar';
        Exit;
      end;

      ModifiedStr := FormatDateTime('dd.mm.yyyy hh:nn:ss', ModifiedDT);

      FreePDF64_Form.StatusBar_Right.SimpleText :=
        Item.Caption + ', Dateiordner, Geändert: ' + ModifiedStr;
    end

    // Datei
    else
    begin
      ModifiedDT  := GetFileModifiedTime(RealPath);
      ModifiedStr := FormatDateTime('dd.mm.yyyy hh:nn:ss', ModifiedDT);
      TypeName    := GetFileTypeName(RealPath);

      FreePDF64_Form.StatusBar_Right.SimpleText :=
        Item.Caption + ', ' +
        FormatByteString(SR.Size) + ', ' +
        TypeName + ', ' + ModifiedStr;
    end;
  end;
end;

procedure TFreePDF64_Form.LMDShellList1Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  if LMDShellList1.SelCount > 0 then
    PDF_Erstellung.Caption := ('Markiert: ' + IntToStr(LMDShellList1.SelCount) + ' => Erstellung starten!');

  SB_Left;
end;

procedure TFreePDF64_Form.LMDShellList2Change(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  SB_Right;
end;

procedure TFreePDF64_Form.LMDShellList2Click(Sender: TObject);
var
  I: Integer;
begin
  FavClose;

  if LMDShellList2.Items.Count = 0 then
    Exit;

  Memo1.Clear;

  if (LMDShellList2.Items.Count > 0) and (LMDShellList2.SelCount = 0) then
  begin
    for I := 0 to LMDShellList2.Items.Count - 1 do
      LMDShellList2.Items[I].Selected := LMDShellList2.Items[I].Selected or
        LMDShellList2.Items[I].Focused;
    Exit;
  end
  else
    if Image2.Visible then
    Image2.Picture.LoadFromFile(LMDShellList2.SelectedItem.PathName)
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
  PDF_Erstellung.Enabled := False;

  if (LMDShellList2.Items.Count > 0) and (LMDShellList2.SelCount = 0) then
    LMDShellList2.ItemIndex := 0;

  if LMDShellList2.FileFilter <> '*.*' then
    FilterTB.ImageIndex := 69
  else
    FilterTB.ImageIndex := 68;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers
    [Printer.printerindex] + ' | Erstellte Dateien (seit Nullstellung): ' +
    IntToStr(Counter);

  Ziellabel.Color := clGradientActiveCaption;
  Quelllabel.Color := clBtnFace;
end;

procedure TFreePDF64_Form.LMDShellList2FilterItem(Sender: TObject; ShellItem: TLMDCustomShellItem; var Accept: Boolean);
begin
  Accept := not ShellItem.DisplayName.Contains('\\');
end;

procedure TFreePDF64_Form.LMDShellList1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Wenn das Panel schon auf ist, wieder schließen...
  MemoBtn.Click;
  PDFPanel.Height := PDFPanelH;

  if (Key = VK_ESCAPE) then
  begin
    if IsIconic(Suche_Form.Handle) then
      Suche_Form.WindowState := wsNormal;
  end;

  if (Key = VK_DELETE) and (LMDShellList1.IsEditing = False) then
    Btn_Delete.Click;

  if (Key = VK_BACK) and (LMDShellList1.IsEditing = False) then
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

procedure TFreePDF64_Form.LMDShellList1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if not UPD.Checked then
    LMDShellList1.ReadOnly := True
  else
  if UPD.Checked then
    LMDShellList1.ReadOnly := False;

  if Button = mbMiddle then
    ParentFolderL.Click;
end;

procedure TFreePDF64_Form.LMDShellList2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Wenn das Panel schon auf ist, wieder schließen...
  MemoBtn.Click;
  PDFPanel.Height := PDFPanelH;

  if (Key = VK_ESCAPE) then
  begin
    if IsIconic(Suche_Form.Handle) then
      Suche_Form.WindowState := wsNormal;
  end;

  if (Key = VK_DELETE) and (LMDShellList2.IsEditing = False) then
    Btn_Delete.Click;

  if (Key = VK_BACK) and (LMDShellList2.IsEditing = False) then
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

procedure TFreePDF64_Form.LMDShellList2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if not UPD.Checked then
    LMDShellList2.ReadOnly := True
  else
  if UPD.Checked then
    LMDShellList2.ReadOnly := False;

  if Button = mbMiddle then
    ParentFolderR.Click;
end;

procedure TFreePDF64_Form.LMDShellList1SelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  // Wenn das Panel schon auf ist, wieder schließen...
  MemoBtn.Click;
  PDFPanel.Height := PDFPanelH;

  SB_Left;

  // Linkes Bild anzeigen durch KeyUp/Down - linke Maustaste wurde nicht gedrückt...
  if Image1.Visible and (GetKeyState(VK_LBUTTON) and $8000 = 0) then
  begin
    if (LMDShellList1.Focused and Assigned(LMDShellList1.Selected)) = True then
      if (Uppercase(ExtractFileExt(Auswahl)) = ('.JPG')) or
        (Uppercase(ExtractFileExt(Auswahl)) = ('.JPEG')) or
        (Uppercase(ExtractFileExt(Auswahl)) = ('.BMP')) or
        (Uppercase(ExtractFileExt(Auswahl)) = ('.PNG')) or
        (Uppercase(ExtractFileExt(Auswahl)) = ('.TIF')) then
      begin
        Auswahl := LMDShellList1.SelectedItem.PathName;
        LMDShellList2.Visible := False;
        Image1.Picture.LoadFromFile(Auswahl);
      end;
  end;
end;

procedure TFreePDF64_Form.LMDShellList2SelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  // Wenn das Panel schon auf ist, wieder schließen...
  MemoBtn.Click;
  PDFPanel.Height := PDFPanelH;

  SB_Right;

  // Rechtes Bild anzeigen durch KeyUp/Down - linke Maustaste wurde nicht gedrückt...
  if Image2.Visible and (GetKeyState(VK_LBUTTON) and $8000 = 0) then
  begin
    if (LMDShellList2.Focused and Assigned(LMDShellList2.Selected)) = True then
      if (Uppercase(ExtractFileExt(Auswahl)) = ('.JPG')) or
        (Uppercase(ExtractFileExt(Auswahl)) = ('.JPEG')) or
        (Uppercase(ExtractFileExt(Auswahl)) = ('.BMP')) or
        (Uppercase(ExtractFileExt(Auswahl)) = ('.PNG')) or
        (Uppercase(ExtractFileExt(Auswahl)) = ('.TIF')) then
      begin
        Auswahl := LMDShellList2.SelectedItem.PathName;
        LMDShellList1.Visible := False;
        Image2.Picture.LoadFromFile(Auswahl);
      end;
  end;
end;

procedure TFreePDF64_Form.LMDShellTree1Change(Sender: TObject; Node: TTreeNode);
begin
  // JPEG-Fenster schließen
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

procedure TFreePDF64_Form.LMDShellTree1FilterItem(Sender: TObject; ShellItem: TLMDCustomShellItem; var Accept: Boolean);
begin
  Accept := not ShellItem.DisplayName.Contains('\\');
end;

procedure TFreePDF64_Form.LMDShellTree1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not UPD.Checked then
    F2Pressed := False
  else
  if UPD.Checked then
    F2Pressed := True;
end;

procedure TFreePDF64_Form.LMDShellTree2FilterItem(Sender: TObject; ShellItem: TLMDCustomShellItem; var Accept: Boolean);
begin
  Accept := not ShellItem.DisplayName.Contains('\\');
end;

procedure TFreePDF64_Form.LMDShellTree2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not UPD.Checked then
    F2Pressed := False
  else
  if UPD.Checked then
    F2Pressed := True;
end;

procedure TFreePDF64_Form.Loeschen1Click(Sender: TObject);
begin
  Btn_Delete.Click;
end;

procedure TFreePDF64_Form.LogBtMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  LogFile: String;
begin
  FavClose;
  Memo1.Clear;

  LogFile := ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt';

  // Linke Maustaste → Log anzeigen
  if Button = mbLeft then
  begin
    Memo1.Lines.LoadFromFile(LogFile);

    PaneloverPrgB.Visible := True;
    PaneloverPrgB.Caption := LogFile;

    if Memo1.Lines.Count > 0 then
    begin
      PDFPanel.Parent := Self;
      PDFPanel.Left   := 0;
      PDFPanel.Top    := 0;
      PDFPanel.Width  := ClientWidth;
      PDFPanel.Height := ClientHeight - ToolBar1.Height;
      PDFPanel.BringToFront;

      // Buttons unsichtbar machen...
      PDF_Erstellung.Visible := False;
      FormatBtn.Visible      := False;
      PanelBottom.Visible    := False;
    end;

    // Abbruch-Button für Memofenster
    MemoBtn.Visible := True;
  end

  // Rechte Maustaste → Panel schließen oder Log extern öffnen
  else if Button = mbRight then
  begin
    // Panel offen? → schließen
    if PDFPanel.Height > PDFPanelH then
    begin
      PaneloverPrgB.Visible := False;
      Memo1.Clear;
      PDFPanel.Height := PDFPanelH;
      MemoBtn.Visible := False;
    end;

    // Externes Log-Programm
    if Einstellungen_Form.Edit2.Text = '' then
      Einstellungen_Form.Edit2.Text := 'notepad.exe';

    ShellExecute(
      Application.Handle,
      'open',
      PChar(Einstellungen_Form.Edit2.Text),
      PChar(' "' + LogFile + '"'),
      nil,
      SW_SHOWNORMAL
    );
  end;

  // Memo zur letzten Zeile scrollen
  Memo1.Perform(EM_LineScroll, 0, Memo1.Lines.Count - 1);
end;

procedure TFreePDF64_Form.Logdateiansehen1Click(Sender: TObject);
var
  LogFile: String;
begin
  FavClose;
  Memo1.Clear;

  LogFile := ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt';

  begin
    Memo1.Lines.LoadFromFile(LogFile);

    PaneloverPrgB.Visible := True;
    PaneloverPrgB.Caption := LogFile;

    if Memo1.Lines.Count > 0 then
    begin
      PDFPanel.Parent := Self;
      PDFPanel.Left   := 0;
      PDFPanel.Top    := 0;
      PDFPanel.Width  := ClientWidth;
      PDFPanel.Height := ClientHeight - ToolBar1.Height;
      PDFPanel.BringToFront;

      // Buttons unsichtbar machen...
      PDF_Erstellung.Visible := False;
      FormatBtn.Visible      := False;
      PanelBottom.Visible    := False;
    end;

    MemoBtn.Visible := True;
  end;

  // Memo zur letzten Zeile scrollen
  Memo1.Perform(EM_LineScroll, 0, Memo1.Lines.Count - 1);
end;

// FreePDF64 Postscript-Drucker: PortMonitor.log ansehen
procedure TFreePDF64_Form.PortMonitorlogansehen1Click(Sender: TObject);
begin
  FavClose;

  Memo1.Lines.LoadFromFile(IncludeTrailingPathDelimiter(GetEnvironmentVariable('ProgramData')) +
                           'FreePDF64\PortMonitor.log');
  PaneloverPrgB.Visible := True;
  PaneloverPrgB.Caption := IncludeTrailingPathDelimiter(GetEnvironmentVariable('ProgramData')) +
                           'FreePDF64\PortMonitor.log';

  if Memo1.Lines.Count > 0 then
  begin
    PDFPanel.Parent := Self;
    PDFPanel.Left   := 0;
    PDFPanel.Top    := 0;
    PDFPanel.Width  := ClientWidth;
    PDFPanel.Height := ClientHeight - ToolBar1.Height;
    PDFPanel.BringToFront;

    // Buttons unsichtbar machen...
    PDF_Erstellung.Visible := False;
    FormatBtn.Visible      := False;
    PanelBottom.Visible    := False;
  end;
  MemoBtn.Visible := True;

  // zur letzen Zeile:
  Memo1.Perform(EM_LineScroll, 0, Memo1.Lines.Count - 1);
end;


// Aufuf vom PopUp-Menü
procedure TFreePDF64_Form.Logdateiansehen2Click(Sender: TObject);
begin
  if Einstellungen_Form.Edit2.Text = '' then
    Einstellungen_Form.Edit2.Text := 'notepad.exe';

  ShellExecute(Application.Handle, 'open', PChar(Einstellungen_Form.Edit2.Text),
    PChar(' "' + ExtractFilePath(Application.ExeName) +
    'FreePDF64Log.txt' + '"'), NIL, SW_SHOWNORMAL)
end;

procedure TFreePDF64_Form.LogdateiClick(Sender: TObject);
begin
  Logdatei.Checked := Not Logdatei.Checked;
end;

// Logdatei (FreePDF64Log.txt) löschen
procedure TFreePDF64_Form.Logdateilschen1Click(Sender: TObject);
var
  Msg: String;
begin
  Msg := 'Soll die Logdatei wirklich gelöscht werden?';
  if MessageDlgCenter(Msg, mtInformation, [mbYes, mbNo]) = mrYes then
    if not DeleteFile(ExtractFilePath(Application.ExeName) + 'FreePDF64Log.txt') then
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
      // ShowMessage(SysErrorMessage(GetLastError));
    end;
end;

// PortMonitor.log löschen
procedure TFreePDF64_Form.PortMonitorLoglschen1Click(Sender: TObject);
var
  Msg: String;
begin
  Msg := 'Soll die PortMonitor.log wirklich gelöscht werden?';
  if MessageDlgCenter(Msg, mtInformation, [mbYes, mbNo]) = mrYes then
    if not DeleteFile(IncludeTrailingPathDelimiter(GetEnvironmentVariable('ProgramData')) + 'FreePDF64\PortMonitor.log') then
    begin
      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) + 'sounds\alert.wav');
      // ShowMessage(SysErrorMessage(GetLastError));
    end;
end;

procedure TFreePDF64_Form.MainMenu1Change(Sender: TObject; Source: TMenuItem;
  Rebuild: Boolean);
begin
  FavClose;
end;

procedure TFreePDF64_Form.MarkEntfClick(Sender: TObject);
var
  I: Integer;
begin
  if FavLbL.Visible then
  begin
    for I := FavLbL.Items.Count - 1 downto 0 do
      if FavLbL.Selected[I] then
      begin
        FavLbL.Items.Delete(I);
        ListBoxL.Items.Delete(I);
        FavLbL.Visible := False;
      end
  end
  else if FavLbR.Visible then
  begin
    for I := FavLbR.Items.Count - 1 downto 0 do
      if FavLbR.Selected[I] then
      begin
        FavLbR.Items.Delete(I);
        ListBoxR.Items.Delete(I);
        FavLbR.Visible := False;
      end;
  end;
  Favoritenspeichern1.Click;
end;

procedure TFreePDF64_Form.Allelschen1Click(Sender: TObject);
var
  I: Integer;
  Msg: String;
begin
  Msg := 'Soll die komplette Schnellzugriffsliste wirklich gelöscht werden?';
  if MessageDlgCenter(Msg, mtInformation, [mbYes, mbNo]) = mrYes then
  begin
    if FavLbL.Visible then
    begin
      for I := ListBoxL.Items.Count - 1 downto 0 do
      begin
        FavLbL.Items.Delete(I);
        ListBoxL.Items.Delete(I);
        FavLbL.Visible := False;
      end;
    end
    else if FavLbR.Visible then
    begin
      for I := ListBoxR.Items.Count - 1 downto 0 do
      begin
        FavLbR.Items.Delete(I);
        ListBoxR.Items.Delete(I);
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
    end
    else
    begin
      LMDShellList1.Cursor := crHourGlass;
      LMDShellList1.SelectAll;
      LMDShellList1.Cursor := crDefault;
    end;
  end
  else if LMDShellList2.Focused then
    if LMDShellList2.SelCount > 1 then
    begin
      LMDShellList2.ClearSelection;
      LMDShellList2.ItemIndex := 0;
    end
    else
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

procedure TFreePDF64_Form.Memo1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  Handled := True;
end;

procedure TFreePDF64_Form.Memo1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    if IsIconic(Suche_Form.Handle) then
      Suche_Form.WindowState := wsNormal;
  end;

  // Wenn das Panel schon auf ist, wieder schließen...
  MemoBtn.Click;
end;

procedure TFreePDF64_Form.Memo1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  // mbRight: Rechte Maustaste
  if Button = mbRight then
    if Trim(Memo1.Text) <> '' then
    begin
      Memo1.Lines.SaveToFile(ExtractFilePath(Application.ExeName) +
        'Metadata.txt');

      if Einstellungen_Form.Edit2.Text = '' then
        Einstellungen_Form.Edit2.Text := 'notepad.exe';

      ShellExecute(Application.Handle, 'open',
        PChar(Einstellungen_Form.Edit2.Text),
        PChar(' "' + ExtractFilePath(Application.ExeName) + 'Metadata.txt' +
        '"'), NIL, SW_SHOWNORMAL);
      StatusBar1.Panels[0].Text := 'Datei "Metadata.txt" liegt nun unter: ' +
        ExtractFilePath(Application.ExeName);
    end;
end;

procedure TFreePDF64_Form.MemoBtnClick(Sender: TObject);
begin
  if IsIconic(Suche_Form.Handle) then
    Suche_Form.WindowState := wsNormal;

  // Wenn das Panel schon auf ist, wieder schließen...
  if PDFPanel.Height > PDFPanelH then
  begin
    PaneloverPrgB.Visible := False;
    Memo1.Clear;
    PDFPanel.Height := PDFPanelH;
    MemoBtn.Visible := False;
    PDF_Erstellung.Visible := True;
    FormatBtn.Visible := True;
    PanelBottom.Visible := True;
  end;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers
    [Printer.printerindex] + ' | Erstellte Dateien (seit Nullstellung): ' +
    IntToStr(Counter);
end;

procedure TFreePDF64_Form.MergeClick(Sender: TObject);
var
  A1, p, s, AP1, AP1_1, AP1_2, AP1_3, AP1_4, AP1_5, VonSpin, BisSpin, Files,
    files2, NZiel, PZiel, QPDFZiel, QPDF_Zeile, DokuSicherheit, DS1, DS2, DS3,
    DS4, DS5, AX: String;
  I, j, R, dpi, DP, DP1, Level, PDFALevel, BaseOffset: Integer;
  Res: Boolean;
  StartUp: TStartupInfo;
  Process: TProcessInformation;
  InpHandle, OutpHandle: THandle;
  fExitCode: Cardinal;
  F: TextFile;
  NewItem: TListItem;
  PDFForm: TPDFBrowserForm;
begin
  Memo1.Clear;
  s := '.pdf';
  j := 0;
  // Wenn Aufruf von FreePDF64-Zusammenfügen via Kontextmenü dann...
  while j < ParamCount do
  begin
    INC(j);
    NewItem := Auswahl_Form.FileList.Items.Add;
    NewItem.Caption := ParamStr(j);
  end;

  keybd_event(VK_HOME, 0, 0, 0);

  if FreePDF64_Notify.Ziel_FestCB.Checked then
    Ziel := FreePDF64_Notify.ZielEdit.Text;
  p := IncludeTrailingBackslash(Ziel);

  if UniInputQuery(
     'PS/PDF zusammenfügen',
     'Zielverzeichnis → siehe Hinweis beim Mauszeiger!' + #13#13 + 'Dateiname:',
     s,
     'Zielverzeichnis: ' + p + #13 +
     'Es ist gleich dem aktuellen Zielverzeichnis der Überwachung (siehe dort)',
     False,   // MultiLine
     False    // Password
   ) then
  begin
    if FileExists(IncludeTrailingBackslash(Ziel) + s) then
    begin
      ShowMessage('Achtung: "' + s + '" ist in "' + Ziel +
        '" schon vorhanden! Bitte anderen Dateinamen nehmen!');
      Merge.Click;
      Exit
    end
    else
      MERGEDATEI := s;
  end
  else
    Exit;

  if Popup_Aufruf then
    Auswahl_Form.Position := poScreenCenter
  else
    Auswahl_Form.Position := poMainFormCenter;
  Popup_Aufruf := False;

  // Wenn KEIN Aufruf von FreePDF64-Zusammenfügen via Kontextmenü dann...
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
      0:
        AP1_1 := ' -dCompatibilityLevel=1.4'; // Acrobat 5
      1:
        AP1_1 := ' -dCompatibilityLevel=1.5'; // Acrobat 6
      2:
        AP1_1 := ' -dCompatibilityLevel=1.6'; // Acrobat 7
      3:
        AP1_1 := ' -dCompatibilityLevel=1.7'; // Acrobat 8
    end;
    // Schriftarten/Füllmuster-dpi?
    dpi := Einstellungen_Form.SchriftParams.ItemIndex;
    case dpi of
      0:
        AP1_2 := ' -r72';
      1:
        AP1_2 := ' -r96';
      2:
        AP1_2 := ' -r150';
      3:
        AP1_2 := ' -r300';
      4:
        AP1_2 := ' -r600';
      5:
        AP1_2 := ' -r720';
    end;
    // Welcher Distiller-Parameter?
    DP := Einstellungen_Form.DistParam.ItemIndex;
    case DP of
      0:
        AP1_3 := ' -DPDFSETTINGS=/default';
      1:
        AP1_3 := ' -DPDFSETTINGS=/screen';
      2:
        AP1_3 := ' -DPDFSETTINGS=/ebook';
      3:
        AP1_3 := ' -DPDFSETTINGS=/printer';
      4:
        AP1_3 := ' -DPDFSETTINGS=/prepress';
    end;

    // PDF/A-Level
    if Einstellungen_Form.PDFA_CB.Checked = True then
    begin
      PDFALevel := Einstellungen_Form.PDFA.ItemIndex;
      case PDFALevel of
        0:
          AP1_4 := '-dNOSAFER -dPDFA -sColorConversionStrategy=RGB ';
        1:
          AP1_4 := '-dNOSAFER -dPDFA=2 -sColorConversionStrategy=RGB ';
        2:
          AP1_4 := '-dNOSAFER -dPDFA=3 -sColorConversionStrategy=RGB ';
      end;
    end
    else
      Einstellungen_Form.PDFA_CB.Checked := False;

    // PDF/X-3-Level
    if Einstellungen_Form.PDFX.Checked = True then
      AP1_4 := '-dPDFX=3 -sColorConversionStrategy=CMYK '
    else
      Einstellungen_Form.PDFX.Checked := False;

    // PDF/X-4a-Level
    if Einstellungen_Form.PDFX4.Checked = True then
      AP1_4 := '-dPDFX=4 -sColorConversionStrategy=CMYK '
    else
      Einstellungen_Form.PDFX4.Checked := False;

    // Schnelle Webanzeige
    if Einstellungen_Form.FastCB.Checked then
      AP1_5 := ' -dFastWebView'
    else
      AP1_5 := '';
    DP1 := Einstellungen_Form.AutoRP.ItemIndex;
    case DP1 of
      0:
        AP4 := '-dAutoRotatePages=/None ';
      1:
        AP4 := '-dAutoRotatePages=/All ';
      2:
        AP4 := '-dAutoRotatePages=/PageByPage ';
    end; // of case

    // Seitenentnahme von- bis
    VonSpin := IntToStr(Seiten_Form.VonSE.Value);
    BisSpin := IntToStr(Seiten_Form.BisSE.Value);
    if (Seiten_Form.VonSE.Value > 0) or (Seiten_Form.BisSE.Value > 0) then
      AP6 := '-dFirstPage=' + VonSpin + ' -dLastPage=' + BisSpin + ' '
    else
      AP6 := '';
    AP1 := '-dNOPAUSE -dDOPDFMARKS -dPreserveMarkedContent=true ' + AP6 + AP4 +
      '-sDEVICE=pdfwrite' + AP1_5;

    // Die erzeugte PDF-Datei in 128 RC4/AES oder 265 AES umwandeln...
    // qpdf --encrypt --user-password=<password> --owner-password=<password> --bits=128 oder --bits=256 -- somefile.pdf somefile_encrypted.pdf
    if (Encrypt_Form.EncryptCombo.ItemIndex = 0) or
      (Encrypt_Form.EncryptCombo.ItemIndex = 1) or
      (Encrypt_Form.EncryptCombo.ItemIndex = 2) then
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
    // or -dPDFX=3 for PDF/X-3 or -dPDFX=4 for PDF/X-4a
    // -------------------------------------------------------------------------
    // Ghostscript-Parameter zum Zusammenfügen der Dateien.

    // In 'files' sind die ausgewählten Dateien aus dem Zusammenfügen-Fenster
    Files := '';
    if Auswahl_Form.FileList.Items.Count > 0 then
    begin
      for I := 0 to Auswahl_Form.FileList.Items.Count - 1 do
      begin
        files2 := Auswahl_Form.FileList.Items[I].Caption;
        Files := Files + ' "' + files2 + '"';
      end;
    end;

    if Einstellungen_Form.PDFA_CB.Checked then
      AX := ' "' + PDFA_1 + '" ';
    if Einstellungen_Form.PDFX.Checked or Einstellungen_Form.PDFX4.Checked then
      AX := ' "' + PDFX_1 + '" ';
    if (Einstellungen_Form.PDFA_CB.Checked = False) and
      (Einstellungen_Form.PDFX.Checked = False) and
      (Einstellungen_Form.PDFX4.Checked = False) then
      AX := ' ';

    // Wenn Erstellung Formatfolder angehakt...
    if Formatverz.Checked then
      // Verzeichnis erstellen der gewünschten Endung (hier PDF)
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(Ziel) + 'PDF')
      then
        Ziel := IncludeTrailingBackslash(Ziel) + 'PDF';
    if Formatverz_Date.Checked then
      // Verzeichnis erstellen der gewünschten Endung (hier PDF + Datum)
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(Ziel) + 'PDF'
        + ' ' + DateToStr(Now)) then
        Ziel := IncludeTrailingBackslash(Ziel) + 'PDF' + ' ' + DateToStr(Now);
    if Formatverz_OnlyDate.Checked then
      // Verzeichnis erstellen der gewünschten Endung (Datum)
      if System.SysUtils.ForceDirectories(IncludeTrailingBackslash(Ziel) +
        DateToStr(Now)) then
        Ziel := IncludeTrailingBackslash(Ziel) + DateToStr(Now);

    A1 := AP1_4 + AP1 + A1 + AP1_3 + AP1_2 + AP1_1 +
      (' -sOutputFile="' + IncludeTrailingBackslash(Ziel) + MERGEDATEI + '"' +
      AX + '-dBATCH' + Files) + ' "' + (ExtractFilePath(Application.ExeName) +
      'pdfmarks"');

    AppendMemoText((Ghostscript + ' ' + A1));
    if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and
      ((Encrypt_Form.BerechtigungCB.Checked = True) or
      (Encrypt_Form.KennwortCB.Checked = True)) then // 128 RC4
      AppendMemoText(#13 +
        (QPDF + ' --allow-weak-crypto --encrypt --user-password="' + Versch5 +
        '" --owner-password="' + Versch3 + '" --bits=128' + DokuSicherheit +
        ' -- "' + IncludeTrailingBackslash(Ziel) + MERGEDATEI +
        '" --replace-input="' + IncludeTrailingBackslash(Ziel) +
        MERGEDATEI + '"'));
    if (Encrypt_Form.EncryptCombo.ItemIndex = 1) and
      ((Encrypt_Form.BerechtigungCB.Checked = True) or
      (Encrypt_Form.KennwortCB.Checked = True)) then // 128 AES
      AppendMemoText(#13 +
        (QPDF + ' --encrypt --user-password="' + Versch5 +
        '" --owner-password="' + Versch3 + '" --bits=128 --use-aes=y' +
        DokuSicherheit + ' -- "' + IncludeTrailingBackslash(Ziel) + MERGEDATEI +
        '" --replace-input="' + IncludeTrailingBackslash(Ziel) +
        MERGEDATEI + '"'));
    if (Encrypt_Form.EncryptCombo.ItemIndex = 2) and
      ((Encrypt_Form.BerechtigungCB.Checked = True) or
      (Encrypt_Form.KennwortCB.Checked = True)) then // 256 AES
      AppendMemoText(#13 +
        (QPDF + ' --encrypt --user-password="' + Versch5 +
        '" --owner-password="' + Versch3 + '" --bits=256' + DokuSicherheit +
        ' --allow-insecure -- "' + IncludeTrailingBackslash(Ziel) + MERGEDATEI +
        '" --replace-input="' + IncludeTrailingBackslash(Ziel) +
        MERGEDATEI + '"'));

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
        (Einstellungen_Form.AuswahlRG.ItemIndex := 0);
      // Umstellung auf (128-Bit) PS/PDF
      begin
        Res := CreateProcess(NIL, PChar(Ghostscript + ' ' + A1), NIL, NIL, True,
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
      end;

      if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and
        ((Encrypt_Form.BerechtigungCB.Checked = True) or
        (Encrypt_Form.KennwortCB.Checked = True)) then
      begin // falls gewünscht, nun die 128-RC4 Verschlüsselung
        PZiel := ExtractFilePath(IncludeTrailingBackslash(Ziel) + MERGEDATEI);
        NZiel := ExtractFileName(IncludeTrailingBackslash(Ziel) + MERGEDATEI);
        QPDFZiel := (PZiel + 'QPDF_' + NZiel);
        QPDF_Zeile := (QPDF + ' --allow-weak-crypto --encrypt --user-password="'
          + Encrypt_Form.KennwortE.Text + '" --owner-password="' +
          Encrypt_Form.BerechtigungE.Text + '" --bits=128' + DokuSicherheit +
          ' -- "' + IncludeTrailingBackslash(Ziel) + MERGEDATEI +
          '" --replace-input="' + QPDFZiel + '"');
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
      end
      else if (Encrypt_Form.EncryptCombo.ItemIndex = 1) and
        ((Encrypt_Form.BerechtigungCB.Checked = True) or
        (Encrypt_Form.KennwortCB.Checked = True)) then
      begin // falls gewünscht, nun die 128-AES Verschlüsselung
        PZiel := ExtractFilePath(IncludeTrailingBackslash(Ziel) + MERGEDATEI);
        NZiel := ExtractFileName(IncludeTrailingBackslash(Ziel) + MERGEDATEI);
        QPDFZiel := (PZiel + 'QPDF_' + NZiel);
        QPDF_Zeile := (QPDF + ' --encrypt --user-password="' +
          Encrypt_Form.KennwortE.Text + '" --owner-password="' +
          Encrypt_Form.BerechtigungE.Text + '" --bits=128 --use-aes=y' +
          DokuSicherheit + ' -- "' + IncludeTrailingBackslash(Ziel) + MERGEDATEI
          + '" --replace-input="' + QPDFZiel + '"');
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
      end
      else if (Encrypt_Form.EncryptCombo.ItemIndex = 2) and
        ((Encrypt_Form.BerechtigungCB.Checked = True) or
        (Encrypt_Form.KennwortCB.Checked = True)) then
      begin // falls gewünscht, nun die 256-AES Verschlüsselung
        PZiel := ExtractFilePath(IncludeTrailingBackslash(Ziel) + MERGEDATEI);
        NZiel := ExtractFileName(IncludeTrailingBackslash(Ziel) + MERGEDATEI);
        QPDFZiel := (PZiel + 'QPDF_' + NZiel);
        QPDF_Zeile := (QPDF + ' --encrypt --user-password="' +
          Encrypt_Form.KennwortE.Text + '" --owner-password="' +
          Encrypt_Form.BerechtigungE.Text + '" --bits=256' + DokuSicherheit +
          ' --allow-insecure -- "' + IncludeTrailingBackslash(Ziel) + MERGEDATEI
          + '" --replace-input="' + QPDFZiel + '"');

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

    // PDFmarks wieder löschen auf Standardeinträge
    if DokuInfo_Form.MetadatenCB.Checked = False then
      DokuInfo_Form.Clear.Click;

    if Logdatei.Checked then
    begin
      // Logdatei (FreePDF64Log.txt) öffnen/beschreiben etc.
      AssignFile(F, PChar(ExtractFilePath(Application.ExeName) +
        'FreePDF64Log.txt'));
      try
        Append(F);
      except
        Rewrite(F)
      end;

      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
        ' =======> ZUSAMMENFÜGEN: ' + Memo1.Lines.Text));
      for I := 0 to Auswahl_Form.FileList.Items.Count - 1 do
        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
          ' -            Dateiname: ' + PChar(Auswahl_Form.FileList.Items[I]
          .Caption)));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
        ' -            Zieldatei: ' + IncludeTrailingBackslash(Ziel) +
        MERGEDATEI));
      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
        ' -           Dateigröße: ' + FormatByteString
        (MyFileSize(IncludeTrailingBackslash(Ziel) + MERGEDATEI))));

      Closefile(F);
    end;
    // Ende von FreePDF64Log.txt
  end;

  if Formatverz.Checked or Formatverz_Date.Checked then
    s := IncludeTrailingBackslash(Ziel) + s;

  // Grundversatz bei 100 % DPI
  BaseOffset := 20;

  // Zusammenfügen-PDF-Datei mit dem PDF-Anzeiger anzeigen
  // Wenn Aufruf von FreePDF64-Zusammenfügen via Kontextmenü dann...
  if ((Einstellungen_Form.AuswahlRG.ItemIndex = 0) and // PDF
    (Einstellungen_Form.AnzeigenCB.Checked)) or (ParamCount > 0) then
  begin
    PDFForm := TPDFBrowserForm.Create(Self);
    PDFForm.PDFFileName := IncludeTrailingBackslash(Ziel) + ExtractFileName(s);
    PDFForm.Show;
    Application.ProcessMessages;
  end;

  ProgressBar1.Position := 100;

  if Einstellungen_Form.SystemklangCB.Checked then
    PlaySoundFile(ExtractFilePath(Application.ExeName) +
      'sounds\confirmation.wav');

  ProgressBar1.Position := 0;
  Einstellungen_Form.Close;
end;

procedure TFreePDF64_Form.ShowNetworkSharesClick(Sender: TObject);
begin
  ShowNetworkShares.Checked := Not ShowNetworkShares.Checked;
  if ShowNetworkShares.Checked then
  begin
    LMDShellTree1.Filtered := False;
    LMDShellTree2.Filtered := False;
    LMDShellList1.Filtered := False;
    LMDShellList2.Filtered := False;
    LMDShellFolder1.Filtered := False;
    LMDShellFolder2.Filtered := False;
  end else
  begin
    LMDShellTree1.Filtered := True;
    LMDShellTree2.Filtered := True;
    LMDShellList1.Filtered := True;
    LMDShellList2.Filtered := True;
    LMDShellFolder1.Filtered := True;
    LMDShellFolder2.Filtered := True;
  end;
  LMDShellTree1.RefreshBranches(LMDShellTree1.Selected.Parent);
  LMDShellTree2.RefreshBranches(LMDShellTree2.Selected.Parent);
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
  Msg := 'Soll der Erstellzähler wirklich auf Null gesetzt werden?';
  if MessageDlgCenter(Msg, mtInformation, [mbYes, mbNo]) = mrYes then
    Counter := 0;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers
    [Printer.printerindex] + ' | Erstellte Dateien (seit Nullstellung): ' +
    IntToStr(Counter);
end;



procedure TFreePDF64_Form.MonitorBtnClick(Sender: TObject);
begin
  FavClose;

  if Assigned(wcPrevious) then
  begin
    if wcPrevious = LMDShellList1 then
      LMDShellList1.SetFocus
    else if wcPrevious = LMDShellList2 then
      LMDShellList2.SetFocus;
  end;

  // Form soll mittig angezeigt werden.
  FreePDF64_Notify.Position := poMainFormCenter;
  FreePDF64_Notify.ShowModal;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers
    [Printer.printerindex] + ' | Erstellte Dateien (seit Nullstellung): ' +
    IntToStr(Counter);
end;

procedure TFreePDF64_Form.MonitorBtnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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
    MonitorBtn.Caption := '  AN';
    MonitorBtn.ImageIndex := 57;
  end
  else
  begin
    MonitorBtn.Caption := '  AUS';
    MonitorBtn.ImageIndex := 58;
  end;
end;

procedure TFreePDF64_Form.MonitorBtnMouseEnter(Sender: TObject);
begin
  FreePDF64_Form.MonitorBtn.Hint :=
    'Schnelles Überwachung-AN/-AUS durch rechte Maustaste';

  if FreePDF64_Notify.LMDShellNotify.Active then
  begin
    MonitorBtn.ImageIndex := 57;
    MonitorBtn.Caption := '  AN';
  end
  else
  begin
    MonitorBtn.ImageIndex := 58;
    MonitorBtn.Caption := '  AUS';
  end;
end;

procedure TFreePDF64_Form.MonitoringBtnClick(Sender: TObject);
begin
  // Form soll mittig angezeigt werden.
  FreePDF64_Notify.Position := poMainFormCenter;
  FreePDF64_Notify.ShowModal;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers
    [Printer.printerindex] + ' | Erstellte Dateien (seit Nullstellung): ' +
    IntToStr(Counter);
end;

// Drücken der rechten Maustaste auf das Überwachungssymbol schaltet diese AN/AUS...
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
  FreePDF64Ini := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName))
    + 'FreePDF64.ini';
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
  PDFForm: TPDFBrowserForm;
begin
  s := IncludeTrailingBackslash(ExtractFilePath(Application.ExeName)) +
    'FreePDF64-HowTo.pdf';
  if not FileExists(s) then
    ShowMessage('''' + s +
      ''' scheint nicht vorhanden zu sein! Bitte FreePDF64 nochmals neu downloaden.')
  else
  begin
    PDFForm := TPDFBrowserForm.Create(Self);
    PDFForm.PDFFileName := s;
    PDFForm.Show;
    Application.ProcessMessages;
  end;
end;

function NowUTC: TDateTime;
var
  SystemTime: TSystemTime;
begin
  GetSystemTime(SystemTime);
  Result := SystemTimeToDateTime(SystemTime);
end;

procedure TFreePDF64_Form.PDF_ErstellungMouseEnter(Sender: TObject);
begin
  Timer1.Enabled := True;
end;

procedure TFreePDF64_Form.PDF_ErstellungMouseLeave(Sender: TObject);
begin
  Timer1.Enabled := False;
  FormatBtn.Enabled := True;
end;

procedure TFreePDF64_Form.PfadimExplorerffnen1Click(Sender: TObject);
begin
  ShellExecute(Handle, NIL, PChar('explorer'),
    PChar(ExtractFilePath(Application.ExeName)), NIL, SW_Show);
end;

procedure TFreePDF64_Form.PDF_ErstellungClick(Sender: TObject);
var
  c, I, j, k, R, Komprimierung: Integer;
  AnzahlDateien: Integer;
  UeberwachungsAufruf: Boolean;
  Res: Boolean;
  StartUp: TStartupInfo;
  Process: TProcessInformation;
  InpHandle, OutpHandle: THandle;
  fExitCode, ProcID: Cardinal;
  AP1, AP1_1, AP1_2, AP1_3, AP1_4, AP1_5, AP3_1, DokuSicherheit, AX, Memozeile,
    DS1, DS2, DS3, DS4, DS5, Spin1, Spin2, VonSpin, BisSpin, Ziel3, Zielanz,
    PZiel, NZiel, QPDFZiel, QPDF_Zeile, z, JV, Endzielname, Datei_Vorne,
    QPDF_ExtractFile, Datei_Hinten, DateiEndung, Buttontext: String;
  F: TextFile;
  PDFForm: TPDFBrowserForm;
const
  PDFLevels : array[0..3] of string = ('1.4', '1.5', '1.6', '1.7');
  DPIs:       array[0..5] of string = ('72', '96', '150', '300', '600', '720');
  DistParams: array[0..4] of string = ('/default', '/screen', '/ebook', '/printer', '/prepress');
  PDFAParams: array[0..2] of string = ('-dNOSAFER -dPDFA -sColorConversionStrategy=RGB ',
                                       '-dNOSAFER -dPDFA=2 -sColorConversionStrategy=RGB ',
                                       '-dNOSAFER -dPDFA=3 -sColorConversionStrategy=RGB ');
  AutoRotateParams: array[0..2] of string = ('-dAutoRotatePages=/None ',
                                             '-dAutoRotatePages=/All ',
                                             '-dAutoRotatePages=/PageByPage ');
begin
  { --------------------------------------------------------------- }
  { Automatische Verarbeitung aus dem Überwachungsordner             }
  { --------------------------------------------------------------- }
  UeberwachungsAufruf := Überwachung_Erstellung and (PDF_UeberwachungsDatei <> '');

  if UeberwachungsAufruf then
    AnzahlDateien := 1
  else
    AnzahlDateien := LMDShellList1.SelCount;

  FavClose;

  // Wenn FreePDF64 NICHT im Tray, dann...
  // Bei einer automatischen Überwachung darf die aktuelle
  // LMDShellList-Ansicht nicht verändert werden.
  if (not UeberwachungsAufruf) and (TrayIcon1.Visible = False) then
  begin
    // Was war die letzte aktive Komponente?
    if Assigned(wcPrevious) then
    begin
      if wcPrevious = LMDShellList1 then
        LMDShellList1.SetFocus
      else if wcPrevious = LMDShellList2 then
        LMDShellList2.SetFocus;
    end;
  end;

  Timer1.Enabled    := False;
  FormatBtn.Enabled := True;
  // Ist der Pfad zum Ghostscript-Programm in den Einstellungen eingetragen?
  if not FileExists(Einstellungen_Form.Edit1.Text) then
  begin
    MessageDlgCenter
      ('Der Pfad zum Ghostscriptprogramm ''gswin64c.exe'' fehlt in den Einstellungen'
      + #13 +
      'oder ist falsch. Ohne eines dieser Programme arbeitet FreePDF64 leider nicht!',
      mtInformation, [mbOk]);
    Exit;
  end;

  // ACHTUNG: Ziel = Watchfolder der Überwachungsfunktion!
  if ((IncludeTrailingBackslash(Ziel) = IncludeTrailingBackslash
    (FreePDF64_Notify.LMDShellNotify.WatchFolder)) and
    FreePDF64_Notify.LMDShellNotify.Active) then
  begin
    MessageDlgCenter('Achtung: Zielverzeichnis = Überwachungsverzeichnis' + #13
      + #13 + 'Das kann zu unkontrolliertem Verhalten bei der' + #13 +
      'Erstellung führen. Bitte ändern oder solange die' + #13 +
      'Überwachungsfunktion deaktivieren!', mtWarning, [mbOk]);
    Exit
  end;

  if not FileExists(ExtractFilePath(Application.ExeName) + 'pdfmarks') then
    DokuInfo_Form.BitBtn1.Click;

  // Ist keine Datei ausgewählt, dann diese Prozedur beenden...
  // Bei der automatischen Überwachung kommt die Quelldatei direkt
  // aus PDF_UeberwachungsDatei und nicht aus LMDShellList1.
  if not UeberwachungsAufruf then
  begin
    if (LMDShellList1.Focused and (LMDShellList1.SelCount = 0)) or
       LMDShellList2.Focused then
      Exit;
  end;

  Ziel := IncludeTrailingBackslash(Ziel);
  FillChar(StartUp, SizeOf(StartUp), #0);
  FillChar(Process, SizeOf(Process), #0);
  StartUp.cb := SizeOf(StartUp);
  StartUp.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
  StartUp.wShowWindow := SW_HIDE;
  InpHandle := 0;
  OutpHandle := 0;
  try
    Memo1.Clear;
    // Wo liegt das Ghostscript-Programm 'gswin64c.exe'?
    Ghostscript := Einstellungen_Form.Edit1.Text;
    // Wo liegt das QPDF-Programm?
    QPDF := Einstellungen_Form.Edit4.Text;
    Hochkommata := '"';

    // PDF-Level
    AP1_1 := ' -dCompatibilityLevel=' + PDFLevels[Einstellungen_Form.PDFLevel.ItemIndex];
    // Schriftarten/Füllmuster-DPI
    AP1_2 := ' -r' +  DPIs[Einstellungen_Form.SchriftParams.ItemIndex];
    // Welcher Distiller-Parameter?
    AP1_3 := ' -DPDFSETTINGS=' + DistParams[Einstellungen_Form.DistParam.ItemIndex];
    // PDF/A-Level
    if Einstellungen_Form.PDFA_CB.Checked then
      AP1_4 := PDFAParams[Einstellungen_Form.PDFA.ItemIndex]
    else
      Einstellungen_Form.PDFA_CB.Checked := False;

    // PDF/X-3-Level
    if Einstellungen_Form.PDFX.Checked = True then
      AP1_4 := '-dPDFX=3 -sColorConversionStrategy=CMYK '
    else
      Einstellungen_Form.PDFX.Checked := False;

    // PDF/X-4a-Level
    if Einstellungen_Form.PDFX4.Checked = True then
      AP1_4 := '-dPDFX=4 -sColorConversionStrategy=CMYK '
    else
      Einstellungen_Form.PDFX4.Checked := False;

    // Schnelle Webanzeige
    if Einstellungen_Form.FastCB.Checked then
      AP1_5 := ' -dFastWebView'
    else
      AP1_5 := '';

    AP4 := AutoRotateParams[Einstellungen_Form.AutoRP.ItemIndex];

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
      0:
        AP1 := '-dNOPAUSE -dDOPDFMARKS -dBATCH -dPreserveMarkedContent=true ' +
          AP6 + AP4 + '-sDEVICE=pdfwrite' + AP1_5; // PDF
      1:
        AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-dSAFER -sDEVICE=ps2write'; // PS
      2:
        AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=docxwrite'; // DOCX
      3:
        AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=txtwrite'; // TXT
      4:
        AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=bmp256 ' + '-r' + Spin2;
      // BMP
      5:
        AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=jpeg -dJPEGQ=' + Spin1 +
          ' ' + '-r' + Spin2; // JPEG
      6:
        AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=png16m ' + '-r' + Spin2;
      // PNG
      7:
        AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=tiffg4 ' + '-r' + Spin2;
      // TIFF G4
      8:
        AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=tifflzw ' + '-r' + Spin2;
      // TIFF LZW
      9:
        AP1 := '-dNOPAUSE -dBATCH ' + AP6 + '-sDEVICE=tiff24nc ' + '-r' + Spin2;
      // TIFF - 24-bit RGB output (8 bits per component) uncompressed
      11:
        AP1 := '-dNOPAUSE -dNOSAFER -dBATCH -sDEVICE=pdfwrite' + AP1_5;
      // JPEG zu PDF
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

      // Verschlüsselungseinstellungen zuweisen
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
    if (Encrypt_Form.BerechtigungCB.Checked or Encrypt_Form.KennwortCB.Checked)
    then
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

    // Records bereits vor dem äußeren try initialisiert.

    j := 0;
    z := Ziel;
    FAbbrechen := False;

    if Einstellungen_Form.PDFA_CB.Checked then
      AX := ' "' + PDFA_1 + '" ';
    if Einstellungen_Form.PDFX.Checked or Einstellungen_Form.PDFX4.Checked then
      AX := ' "' + PDFX_1 + '" ';
    if (Einstellungen_Form.PDFA_CB.Checked = False) and
       (Einstellungen_Form.PDFX.Checked = False) and
       (Einstellungen_Form.PDFX4.Checked = False) then
      AX := ' ';

    // ----> START
    begin
      AbbrechenPn.Visible := True;

      // Bei der automatischen Überwachung genau eine Datei verarbeiten.
      // Bei der normalen Bedienung bleibt die bisherige Verarbeitung
      // aller markierten Dateien unverändert.
      for I := 0 to AnzahlDateien - 1 do
      begin
        INC(Counter);
        if (Einstellungen_Form.PDFA_CB.Checked = False) and
           (Einstellungen_Form.PDFX.Checked = False) and
           (Einstellungen_Form.PDFX4.Checked = False) then
          AP1_4 := '';
        ProgressBar1.Position := 0;
        // AP3: Welche Datei soll verarbeitet werden?
        if UeberwachungsAufruf then
          AP3 := PDF_UeberwachungsDatei
        else
          AP3 := LMDShellList1.SelectedItem.PathName;

        // Verzeichnisse können nicht in PDF umgewandelt werden.
        // Deshalb das Verzeichnis entmarkieren und sofort mit dem
        // nächsten markierten Eintrag weitermachen.
        if DirectoryExists(AP3) then
        begin
          if not UeberwachungsAufruf then
            LMDShellList1.Items[LMDShellList1.Selected.Index].Selected := False;

          Continue;
        end;

        // Bei einer automatischen Überwachung darf die aktuelle
        // LMDShellList-Auswahl nicht verändert werden.
        if not UeberwachungsAufruf then
          LMDShellList1.Items[LMDShellList1.Selected.Index].Selected := False;

        if UeberwachungsAufruf or FreePDF64_Form.AutoFormat.Checked then
        begin
          HinweisAutoFormat := False;
          { ---------------------------------------------------------- }
          { Dateiendung ermitteln und AuswahlRG automatisch einstellen }
          { ---------------------------------------------------------- }
          DateiEndung := UpperCase(ExtractFileExt(AP3));

          if (DateiEndung = '.PDF') or (DateiEndung = '.PS') or (DateiEndung = '') then
          begin
            Einstellungen_Form.AuswahlRG.ItemIndex := 0;
            FormatBtn.Caption := 'Formatauswahl: PS/PDF zu PDF ';
          end else
          if DateiEndung = '.BMP' then
          begin
            Einstellungen_Form.AuswahlRG.ItemIndex := 10;
            FormatBtn.Caption := 'Formatauswahl: BMP zu PDF ';
          end else
          if (DateiEndung = '.JPG') or (DateiEndung = '.JPEG') then
          begin
            Einstellungen_Form.AuswahlRG.ItemIndex := 11;
            FormatBtn.Caption := 'Formatauswahl: JPEG zu PDF ';
          end else
          if DateiEndung = '.PNG' then
          begin
            Einstellungen_Form.AuswahlRG.ItemIndex := 12;
            FormatBtn.Caption := 'Formatauswahl: PNG zu PDF ';
          end else
          if (DateiEndung = '.TIFF') or (DateiEndung = '.TIF') then
          begin
            Einstellungen_Form.AuswahlRG.ItemIndex := 13;
            FormatBtn.Caption := 'Formatauswahl: TIFF zu PDF ';
          end;
        end;

        { ---------------------------------------------------------- }
        { AP1 nach der automatischen Formaterkennung erneut aufbauen }
        { Wichtig: AP1 wurde oben vor Kenntnis der Überwachungsdatei }
        { aufgebaut. Für den Überwachungsaufruf muss jetzt der       }
        { aktuelle ItemIndex verwendet werden.                       }
        { ---------------------------------------------------------- }
        if UeberwachungsAufruf then
        begin
          case Einstellungen_Form.AuswahlRG.ItemIndex of
            0:
              AP1 := '-dNOPAUSE -dDOPDFMARKS -dBATCH -dPreserveMarkedContent=true ' +
                AP6 + AP4 + '-sDEVICE=pdfwrite' + AP1_5;
            11:
              AP1 := '-dNOPAUSE -dNOSAFER -dBATCH -sDEVICE=pdfwrite' + AP1_5;
          end;
        end;

        { --------------------------------------------------------- }
        { PDF-Erstellung erst nach der Endungsprüfung               }
        { --------------------------------------------------------- }

        // AP3 bleibt immer unverändert und zeigt auf die tatsächliche Quelldatei.
        // Endzielname bestimmt ausschließlich den Namen der Zieldatei.
        Endzielname := AP3;

        if Einstellungen_Form.ZusatzAnAus.Checked = True then
        begin
          try
            begin
              // ZusatzCB verändert nur den Zieldateinamen.
              // Die Quelldatei AP3 wird NICHT umbenannt.
              for c := 0 to Zusatz_Form.ZusatzCB.Items.Count - 1 do
              begin
                Endzielname := StringReplace(Endzielname,
                  Zusatz_Form.ZusatzCB.Items.Strings[c],
                  '', [rfReplaceAll, rfIgnoreCase]);
              end;
            end;
          finally
            Application.ProcessMessages;
          end;
        end;

        // LMDShellList1.ItemIndex := - 1;

        if Einstellungen_Form.AuswahlRG.ItemIndex in [0, 10, 11, 12, 13] then // PDF
          Ziel := (IncludeTrailingBackslash(z) +
            ChangeFileExt(ExtractFileName(Endzielname), '.pdf'))
        else if Einstellungen_Form.AuswahlRG.ItemIndex = 1 then // PS
          Ziel := (IncludeTrailingBackslash(z) +
            ChangeFileExt(ExtractFileName(Endzielname), '.ps'))
        else if Einstellungen_Form.AuswahlRG.ItemIndex = 2 then // DOCX
          Ziel := (IncludeTrailingBackslash(z) +
            ChangeFileExt(ExtractFileName(Endzielname), '.docx'))
        else if Einstellungen_Form.AuswahlRG.ItemIndex = 3 then // TXT
          Ziel := (IncludeTrailingBackslash(z) +
            ChangeFileExt(ExtractFileName(Endzielname), '.txt'))
        else if Einstellungen_Form.AuswahlRG.ItemIndex = 4 then // BMP
          Ziel := (IncludeTrailingBackslash(z) +
            ChangeFileExt(ExtractFileName(Endzielname), '_%03d.bmp'))
        else if Einstellungen_Form.AuswahlRG.ItemIndex = 5 then // JPEG
          Ziel := (IncludeTrailingBackslash(z) +
            ChangeFileExt(ExtractFileName(Endzielname), '_%03d.jpg'))
        else if Einstellungen_Form.AuswahlRG.ItemIndex = 6 then // PNG
          Ziel := (IncludeTrailingBackslash(z) +
            ChangeFileExt(ExtractFileName(Endzielname), '_%03d.png'))
        else if (Einstellungen_Form.AuswahlRG.ItemIndex > 6) and
          (Einstellungen_Form.AuswahlRG.ItemIndex < 10) then // TIFF
          Ziel := (IncludeTrailingBackslash(z) +
            ChangeFileExt(ExtractFileName(Endzielname), '.tif'));

        // Anonymous Pipe erzeugen
        if CreatePipe(InpHandle, OutpHandle, NIL, 0) then
        begin
          try
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
          // or -dPDFX=3 for PDF/X-3 or -dPDFX=4 for PDF/X-4a
          // AP1_5:         Schnelle Webanzeige
          // AP5:           sind die PDFmarks
          // -----------------------------------------------------------------------------
          Application.ProcessMessages;

          // PDFmarks -> Titel (Dateiname ohne Endung), Erstell- und Geändert-Datum
          if DokuInfo_Form.MetadatenCB.Checked = False then
          begin
            if DokuInfo_Form.TitelEdit.Text = '' then
              DokuInfo_Form.TitelEdit.Text :=
                ChangeFileExt(ExtractFileName(Ziel), '');

            if DokuInfo_Form.CreationDateEdit.Text = '' then
              DokuInfo_Form.CreationDateEdit.Text :=
                FormatDateTime('yyyymmddhhnnss', NowUTC);

            if DokuInfo_Form.ModDateEdit.Text = '' then
              DokuInfo_Form.ModDateEdit.Text :=
                FormatDateTime('yyyymmddhhnnss', NowUTC);
          end;

          // PDFmarks speichern...
          DokuInfo_Form.BitBtn1.Click;
          AP5 := ' "' + (ExtractFilePath(Application.ExeName) + 'pdfmarks"');
          Application.HandleMessage;

          // PDFmarks wieder löschen auf Standardeinträge
          if DokuInfo_Form.MetadatenCB.Checked = False then
            DokuInfo_Form.Clear.Click;
          // Variable Ziel zwischenspeichern
          Ziel3 := Ziel;

          // Wenn Erstellung Formatfolder angehakt...
          if Formatverz.Checked then
          begin
            // Verzeichnis erstellen der gewünschten Endung (z.B. \PDF)
            if System.SysUtils.ForceDirectories
              (Uppercase(ExtractFilePath(Ziel) + ExtractFileExtensionWithoutDot
              (Ziel))) then
              Ziel := (IncludeTrailingBackslash(ExtractFilePath(Ziel) +
                ExtractFileExtensionWithoutDot(Uppercase(Ziel)))) +
                ExtractFileName(Ziel);
          end
          else
            // Wenn Erstellung Formatfolder mit Datum angehakt...
            if Formatverz_Date.Checked then
            begin
              // Verzeichnis erstellen der gewünschten Endung (z.B. \PDF)
              if System.SysUtils.ForceDirectories
                (Uppercase(ExtractFilePath(Ziel) +
                ExtractFileExtensionWithoutDot(Ziel) + ' ' + DateToStr(Now)))
              then
                Ziel := (IncludeTrailingBackslash(ExtractFilePath(Ziel) +
                  ExtractFileExtensionWithoutDot(Uppercase(Ziel)) + ' ' +
                  DateToStr(Now))) + ExtractFileName(Ziel);
            end;
          // Wenn Erstellung Formatfolder only Datum angehakt...
          if Formatverz_OnlyDate.Checked then
          begin
            if System.SysUtils.ForceDirectories
              (Uppercase(ExtractFilePath(Ziel) + DateToStr(Now))) then
              Ziel := (IncludeTrailingBackslash(ExtractFilePath(Ziel) +
                DateToStr(Now))) + ExtractFileName(Ziel);
          end;

          // Wenn die Zieldatei schon vorhanden ist, dann umbenennen...
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

          // Für die Erstellung JPEG zu PDF
          AP3_1 := AP3;
          // IncludeTrailingBackslash zu Slash umwandeln
          for k := 1 to Length(AP3_1) do
          begin
            if AP3_1[k] = '\' then
              AP3_1[k] := '/';
          end;

          if (Einstellungen_Form.PDFA_CB.Checked or
            Einstellungen_Form.PDFX.Checked or Einstellungen_Form.PDFX4.Checked)
          then
            JV := ' -sOutputFile="' + Ziel + '" ' + AX + ' "' + ViewJPEG +
              '" -c "(' + AP3_1 +
              ') <</PageSize 2 index viewJPEGgetsize 2 array astore>> setpagedevice viewJPEG"'
          else
            JV := ' -sOutputFile="' + Ziel + '" "' + ViewJPEG + '" -c "(' +
              AP3_1 +
              ') <</PageSize 2 index viewJPEGgetsize 2 array astore>> setpagedevice viewJPEG"';

          // Erstellung BMP/PNG/TIFF to PDF
          if Einstellungen_Form.AuswahlRG.ItemIndex in [10, 12, 13] then
          begin
            ProcID := 0;
            // Starte nun die richtige Erstellung...
            if RunProcess(ImageMagick +
              ' -define pdf:Author="" -define pdf:Creator="FreePDF64 (https://github.com/FreePDF64)" "'
              +
              AP3 + '" "' + Ziel + Hochkommata, SW_HIDE, True, @ProcID) = 0 then
              Memozeile := ImageMagick +
                ' -define pdf:Author="" -define pdf:Creator="FreePDF64 (https://github.com/FreePDF64)" "'
                +
                AP3 + '" "' + Ziel + Hochkommata;
          end;

          // PDF-Erstellung von 128-Bit PS/PDF
          if (Einstellungen_Form.AuswahlRG.ItemIndex = 0) then // 128-Bit PS/PDF
            Res := CreateProcess(NIL,
              PChar(Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 +
              ' ' + '-sOutputFile="' + Ziel + '"' + AX + (Hochkommata + AP3 +
              Hochkommata + AP5)), NIL, NIL, True, CREATE_DEFAULT_ERROR_MODE or
              CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, NIL, NIL,
              StartUp, Process)

            // PDF-Erstellung von JPEG zu PDF, PDF verkleinern nicht gewünscht
          else if (Einstellungen_Form.PDF_Shrink.Checked = False) and
            (Einstellungen_Form.AuswahlRG.ItemIndex = 11) then
            Res := CreateProcess(NIL,
              PChar(Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_1 + JV), NIL,
              NIL, True, CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
              NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process)

            // PDF-Erstellung von JPEG zu PDF, PDF verkleinern ist gewünscht
          else if Einstellungen_Form.PDF_Shrink.Checked and
            (Einstellungen_Form.AuswahlRG.ItemIndex = 11) then
            Res := CreateProcess(NIL, PChar(Ghostscript + ' ' + AP1 + JV), NIL,
              NIL, True, CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
              NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process)

            // Erstellung JPEG/TIFF
          else if (Einstellungen_Form.AuswahlRG.ItemIndex > 0) and
            (Einstellungen_Form.AuswahlRG.ItemIndex < 10) then
            Res := CreateProcess(NIL,
              PChar(Ghostscript + ' ' + AP1_4 + AP1 + ' ' + '-sOutputFile="' +
              Ziel + '"' + AX + (Hochkommata + AP3 + Hochkommata + AP5)), NIL,
              NIL, True, CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
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
              // time-out interval in milliseconds von 500 auf 1000 höher setzen!
              // oder besser: INFINITE
              //
              R := WaitForSingleObject(Process.hProcess, 200); // INFINITE);
              ProgressBar1.Position := ProgressBar1.Position + 5;
              GetExitCodeProcess(Process.hProcess, fExitCode);
              Application.ProcessMessages;

              // Abbruch auch während eines laufenden Ghostscript-Prozesses
              // sofort berücksichtigen. Der Prozess wird beendet und danach
              // werden seine Handles wie gewohnt geschlossen.
              if FAbbrechen then
              begin
                TerminateProcess(Process.hProcess, 1);
                WaitForSingleObject(Process.hProcess, INFINITE);
                R := WAIT_OBJECT_0;
              end;
            until R <> WAIT_TIMEOUT;
            CloseHandle(Process.hThread);
            Process.hThread := 0;
            CloseHandle(Process.hProcess);
            Process.hProcess := 0;
            if FAbbrechen then
              Break;
            // FERTIG! Genug gewartet - Weiter gehts!!!
            // Dateianlage vorne/hinten anfügen - wenn gewünscht
            if (Dateianlage_Form.Datei1.Text <> '') or
              (Dateianlage_Form.Datei2.Text <> '') then
            begin
              if Dateianlage_Form.Datei1.Text <> '' then
                Datei_Vorne := Hochkommata + Dateianlage_Form.Datei1.Text +
                  Hochkommata
              else
                Datei_Vorne := '';
              if Dateianlage_Form.Datei2.Text <> '' then
                Datei_Hinten := Hochkommata + Dateianlage_Form.Datei2.Text +
                  Hochkommata
              else
                Datei_Hinten := '';
              Res := CreateProcess(NIL,
                PChar(Ghostscript + ' ' + AP1 + ' ' + '-sOutputFile="' + Ziel +
                '" ' + (Datei_Vorne + ' ' + Hochkommata + AP3 + Hochkommata +
                ' ' + Datei_Hinten + AP5)), NIL, NIL, True,
                CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
              if Res then
              begin
                repeat
                  R := WaitForSingleObject(Process.hProcess, 200);
                  ProgressBar1.Position := ProgressBar1.Position + 5;
                  GetExitCodeProcess(Process.hProcess, fExitCode);
                  Application.ProcessMessages;

                  // Abbruch auch während eines laufenden Prozesses
                  // sofort durchführen.
                  if FAbbrechen then
                  begin
                    TerminateProcess(Process.hProcess, 1);
                    WaitForSingleObject(Process.hProcess, INFINITE);
                    R := WAIT_OBJECT_0;
                  end;
                until R <> WAIT_TIMEOUT;
                CloseHandle(Process.hThread);
                Process.hThread := 0;
                CloseHandle(Process.hProcess);
                Process.hProcess := 0;
                if FAbbrechen then
                  Break;
              end;
              Application.ProcessMessages;
            end;

            // ========= PDF-Erstellung von PDF zu PDF/JPEG zu PDF, PDF verkleinern ist gewünscht ======
            if Einstellungen_Form.PDF_Shrink.Checked then
            begin
              // Nun die Erstellung von PDF zu PS
              Res := CreateProcess(NIL,
                PChar(Ghostscript +
                ' -dNOPAUSE -dBATCH -dSAFER -sDEVICE=ps2write -sOutputFile="' +
                Ziel + '.ps' + '" ' + (Hochkommata + Ziel + Hochkommata)), NIL,
                NIL, True, CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
              if Res then
              begin
                repeat
                  R := WaitForSingleObject(Process.hProcess, 200);
                  ProgressBar1.Position := ProgressBar1.Position + 5;
                  GetExitCodeProcess(Process.hProcess, fExitCode);
                  Application.ProcessMessages;

                  // Abbruch auch während eines laufenden Prozesses
                  // sofort durchführen.
                  if FAbbrechen then
                  begin
                    TerminateProcess(Process.hProcess, 1);
                    WaitForSingleObject(Process.hProcess, INFINITE);
                    R := WAIT_OBJECT_0;
                  end;
                until R <> WAIT_TIMEOUT;
                CloseHandle(Process.hThread);
                Process.hThread := 0;
                CloseHandle(Process.hProcess);
                Process.hProcess := 0;
                if FAbbrechen then
                  Break;
              end;
              Application.ProcessMessages;
              // Nun die Erstellung wieder zurück von PS zu PDF
              Res := CreateProcess(NIL,
                PChar(Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 +
                ' ' + '-sOutputFile="' + ExtractFilePath(Ziel) + 'K_'
                + ExtractFileName(Ziel) + '"' + AX + (Hochkommata + Ziel + '.ps'
                + Hochkommata + AP5)), NIL, NIL, True,
                CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
              if Res then
              begin
                repeat
                  R := WaitForSingleObject(Process.hProcess, 200);
                  ProgressBar1.Position := ProgressBar1.Position + 5;
                  GetExitCodeProcess(Process.hProcess, fExitCode);
                  Application.ProcessMessages;

                  // Abbruch auch während eines laufenden Prozesses
                  // sofort durchführen.
                  if FAbbrechen then
                  begin
                    TerminateProcess(Process.hProcess, 1);
                    WaitForSingleObject(Process.hProcess, INFINITE);
                    R := WAIT_OBJECT_0;
                  end;
                until R <> WAIT_TIMEOUT;
                CloseHandle(Process.hThread);
                Process.hThread := 0;
                CloseHandle(Process.hProcess);
                Process.hProcess := 0;
                if FAbbrechen then
                  Break;
              end;
              Application.ProcessMessages;
              // Löschen der .ps-Datei des Zwischenerstellschritts
              if not DeleteFile(Ziel + '.ps') then
              begin
                if Einstellungen_Form.SystemklangCB.Checked then
                  PlaySoundFile(ExtractFilePath(Application.ExeName) +
                    'sounds\alert.wav');
                ShowMessage(SysErrorMessage(GetLastError));
              end;
            end;

            if Einstellungen_Form.PDF_Shrink2.Checked then
            begin
              if not Einstellungen_Form.Shrink2CB.Checked then
              begin
                QPDF_ExtractFile := 'K_' + ExtractFileName(Ziel);
                QPDF_Zeile := (QPDF + ' --optimize-images --object-streams=generate --compression-level=9 --recompress-flate "'
                               + Ziel + '" "' + ExtractFilePath(Ziel) + QPDF_ExtractFile + Hochkommata);
              end else
              begin
                QPDF_Zeile := (QPDF + ' --replace-input --optimize-images --object-streams=generate --compression-level=9 --recompress-flate "'
                               + Ziel + Hochkommata);
              end;
              Res := CreateProcess(NIL, PChar(QPDF_Zeile), NIL, NIL, True,
                CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
              if Res then
              begin
                repeat
                  R := WaitForSingleObject(Process.hProcess, 200);
                  ProgressBar1.Position := ProgressBar1.Position + 5;
                  GetExitCodeProcess(Process.hProcess, fExitCode);
                  Application.ProcessMessages;

                  // Abbruch auch während eines laufenden Prozesses
                  // sofort durchführen.
                  if FAbbrechen then
                  begin
                    TerminateProcess(Process.hProcess, 1);
                    WaitForSingleObject(Process.hProcess, INFINITE);
                    R := WAIT_OBJECT_0;
                  end;
                until R <> WAIT_TIMEOUT;
                CloseHandle(Process.hThread);
                Process.hThread := 0;
                CloseHandle(Process.hProcess);
                Process.hProcess := 0;
                if FAbbrechen then
                  Break;
              end;
              Application.ProcessMessages;
            end;

            // =================================================================
            // Nun die 128-Bit RC4 PDF-Erstellung, wenn gewünscht... ===========
            if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and
              ((Encrypt_Form.BerechtigungCB.Checked = True) or
              (Encrypt_Form.KennwortCB.Checked = True)) then
            begin
              PZiel := ExtractFilePath(Ziel);
              NZiel := ExtractFileName(Ziel);
              QPDFZiel := (PZiel + 'QPDF_' + NZiel);

              QPDF_Zeile :=
                (QPDF + ' --allow-weak-crypto --encrypt --user-password="' +
                Encrypt_Form.KennwortE.Text + '" --owner-password="' +
                Encrypt_Form.BerechtigungE.Text + '" --bits=128' +
                DokuSicherheit + ' -- "' + Ziel + '" "' + QPDFZiel + '"');

              Res := CreateProcess(NIL, PChar(QPDF_Zeile), NIL, NIL, True,
                CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
              if Res then
              begin
                repeat
                  R := WaitForSingleObject(Process.hProcess, 200); // INFINITE);
                  ProgressBar1.Position := ProgressBar1.Position + 5;
                  GetExitCodeProcess(Process.hProcess, fExitCode);


                  Application.ProcessMessages;


                  // Abbruch auch während eines laufenden Prozesses sofort durchführen.

                  if FAbbrechen then

                  begin

                    TerminateProcess(Process.hProcess, 1);

                    WaitForSingleObject(Process.hProcess, INFINITE);

                    R := WAIT_OBJECT_0;

                  end;

                until R <> WAIT_TIMEOUT;
                CloseHandle(Process.hThread);
                Process.hThread := 0;
                CloseHandle(Process.hProcess);
                Process.hProcess := 0;
                if FAbbrechen then
                  Break;
              end;
              if FileExists(Ziel) then
                DeleteFile(Ziel);

              if not RenameFile(QPDFZiel, PZiel + NZiel) then
              begin
                if Einstellungen_Form.SystemklangCB.Checked then
                  PlaySoundFile(ExtractFilePath(Application.ExeName) +
                    'sounds\alert.wav');
                ShowMessage('Error renaming file!');
              end
            end
            else
              // .. bis hierhin ==================================================
              // =================================================================
              // Nun die 128-Bit AES PDF-Erstellung, wenn gewünscht... ===========
              if (Encrypt_Form.EncryptCombo.ItemIndex = 1) and
                ((Encrypt_Form.BerechtigungCB.Checked = True) or
                (Encrypt_Form.KennwortCB.Checked = True)) then
              begin
                PZiel := ExtractFilePath(Ziel);
                NZiel := ExtractFileName(Ziel);
                QPDFZiel := (PZiel + 'QPDF_' + NZiel);

                QPDF_Zeile := (QPDF + ' --encrypt --user-password="' +
                  Encrypt_Form.KennwortE.Text + '" --owner-password="' +
                  Encrypt_Form.BerechtigungE.Text + '" --bits=128 --use-aes=y' +
                  DokuSicherheit + ' -- "' + Ziel + '" "' + QPDFZiel + '"');

                Res := CreateProcess(NIL, PChar(QPDF_Zeile), NIL, NIL, True,
                  CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                  NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
                if Res then
                begin
                  repeat
                    R := WaitForSingleObject(Process.hProcess, 200);
                    // INFINITE);
                    ProgressBar1.Position := ProgressBar1.Position + 5;
                    GetExitCodeProcess(Process.hProcess, fExitCode);


                    Application.ProcessMessages;


                    // Abbruch auch während eines laufenden Prozesses sofort durchführen.

                    if FAbbrechen then

                    begin

                      TerminateProcess(Process.hProcess, 1);

                      WaitForSingleObject(Process.hProcess, INFINITE);

                      R := WAIT_OBJECT_0;

                    end;

                  until R <> WAIT_TIMEOUT;
                  CloseHandle(Process.hThread);
                  Process.hThread := 0;
                  CloseHandle(Process.hProcess);
                  Process.hProcess := 0;
                  if FAbbrechen then
                    Break;
                end;
                if FileExists(Ziel) then
                  DeleteFile(Ziel);

                if not RenameFile(QPDFZiel, PZiel + NZiel) then
                begin
                  if Einstellungen_Form.SystemklangCB.Checked then
                    PlaySoundFile(ExtractFilePath(Application.ExeName) +
                      'sounds\alert.wav');
                  ShowMessage('Error renaming file!');
                end
              end
              else
                // .. bis hierhin ==================================================
                // =================================================================
                // Nun die 256-Bit AES PDF-Erstellung, wenn gewünscht... ===========
                if (Encrypt_Form.EncryptCombo.ItemIndex = 2) and
                  ((Encrypt_Form.BerechtigungCB.Checked = True) or
                  (Encrypt_Form.KennwortCB.Checked = True)) then
                begin
                  PZiel := ExtractFilePath(Ziel);
                  NZiel := ExtractFileName(Ziel);
                  QPDFZiel := (PZiel + 'QPDF_' + NZiel);
                  QPDF_Zeile := (QPDF + ' --encrypt --user-password="' +
                    Encrypt_Form.KennwortE.Text + '" --owner-password="' +
                    Encrypt_Form.BerechtigungE.Text + '" --bits=256' +
                    DokuSicherheit + ' --allow-insecure -- "' + Ziel + '" "' +
                    QPDFZiel + '"');

                  Res := CreateProcess(NIL, PChar(QPDF_Zeile), NIL, NIL, True,
                    CREATE_DEFAULT_ERROR_MODE or CREATE_NEW_CONSOLE or
                    NORMAL_PRIORITY_CLASS, NIL, NIL, StartUp, Process);
                  if Res then
                  begin
                    repeat
                      R := WaitForSingleObject(Process.hProcess, 200);
                      // INFINITE);
                      ProgressBar1.Position := ProgressBar1.Position + 5;
                      GetExitCodeProcess(Process.hProcess, fExitCode);


                      Application.ProcessMessages;


                      // Abbruch auch während eines laufenden Prozesses sofort durchführen.

                      if FAbbrechen then

                      begin

                        TerminateProcess(Process.hProcess, 1);

                        WaitForSingleObject(Process.hProcess, INFINITE);

                        R := WAIT_OBJECT_0;

                      end;

                    until R <> WAIT_TIMEOUT;
                    CloseHandle(Process.hThread);
                    Process.hThread := 0;
                    CloseHandle(Process.hProcess);
                    Process.hProcess := 0;
                    if FAbbrechen then
                      Break;
                  end;
                  if FileExists(Ziel) then
                    DeleteFile(Ziel);

                  if not RenameFile(QPDFZiel, PZiel + NZiel) then
                  begin
                    if Einstellungen_Form.SystemklangCB.Checked then
                      PlaySoundFile(ExtractFilePath(Application.ExeName) +
                        'sounds\alert.wav');
                    ShowMessage('Error renaming file!');
                  end;
                end;
            // .. bis hierhin ==================================================

          end;

          // Memo füllen...
          if (Einstellungen_Form.PDF_Shrink.Enabled and Einstellungen_Form.PDF_Shrink.Checked) or
             (Einstellungen_Form.PDF_Shrink2.Enabled and Einstellungen_Form.PDF_Shrink2.Checked) then
          begin
            AppendMemoText((Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 + ' ' +
                                '-sOutputFile="' + ExtractFilePath(Ziel) + 'K_' + ExtractFileName(Ziel) + '"' +
                                AX + (Hochkommata + Ziel + '.ps"' + AP5 + ' ')));
            if Einstellungen_Form.PDF_Shrink2.Enabled and
              Einstellungen_Form.PDF_Shrink2.Checked then
            begin
              if not Einstellungen_Form.Shrink2CB.Checked then
              begin
                QPDF_ExtractFile := 'K_' + ExtractFileName(Ziel);
                AppendMemoText((QPDF + ' --optimize-images --object-streams=generate --compression-level=9 --recompress-flate "' + Ziel +
                                    '" "' + ExtractFilePath(Ziel) + QPDF_ExtractFile + Hochkommata));
              end else
                AppendMemoText((QPDF + ' --replace-input --optimize-images --object-streams=generate --compression-level=9 --recompress-flate "' +
                                    Ziel + Hochkommata));
            end
          end
          else
          begin
            if (Einstellungen_Form.AuswahlRG.ItemIndex = 0) then
            // Auswahl ist PDF
            begin
              if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and
                ((Encrypt_Form.BerechtigungCB.Checked = True) or
                (Encrypt_Form.KennwortCB.Checked = True)) then // 128 RC4 ?
              begin
                AppendMemoText((Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 + ' '
                  + '-sOutputFile="' + Ziel + '"' + AX +
                  (Hochkommata + AP3 + Hochkommata + AP5 + #13)));
                Zielanz := Ziel;
                AppendMemoText((QPDF + ' --allow-weak-crypto --encrypt --user-password="' +
                  Versch5 + '" --owner-password="' + Versch3 + '" --bits=128' +
                  DokuSicherheit + ' -- "' + Ziel + '" "' + Ziel +
                  '" <- 128-Bit RC4'));
              end
              else if (Encrypt_Form.EncryptCombo.ItemIndex = 1) and
                ((Encrypt_Form.BerechtigungCB.Checked = True) or
                (Encrypt_Form.KennwortCB.Checked = True)) then // 128 AES ?
              begin
                AppendMemoText((Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 + ' '
                  + '-sOutputFile="' + Ziel + '"' + AX +
                  (Hochkommata + AP3 + Hochkommata + AP5 + #13)));
                Zielanz := Ziel;
                AppendMemoText((QPDF + ' --encrypt --user-password="' + Versch5 +
                  '" --owner-password="' + Versch3 + '" --bits=128 --use-aes=y'
                  + DokuSicherheit + ' -- "' + Ziel + '" "' + Ziel +
                  '" <- 128-Bit AES'));
              end
              else if (Encrypt_Form.EncryptCombo.ItemIndex = 2) and
                ((Encrypt_Form.BerechtigungCB.Checked = True) or
                (Encrypt_Form.KennwortCB.Checked = True)) then // 256 AES ?
              begin
                AppendMemoText((Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 + ' '
                  + '-sOutputFile="' + Ziel + '"' + AX +
                  (Hochkommata + AP3 + Hochkommata + AP5 + #13)));
                Zielanz := Ziel;
                AppendMemoText((QPDF + ' --encrypt --user-password="' + Versch5 +
                  '" --owner-password="' + Versch3 + '" --bits=256' +
                  DokuSicherheit + ' --allow-insecure -- "' + Ziel + '" "' +
                  Ziel + '" <- 256-Bit AES'));
              end
              else if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and
                ((Encrypt_Form.BerechtigungCB.Checked) or
                (Encrypt_Form.KennwortCB.Checked = True)) then // 128 AES ?
              begin
                AppendMemoText((Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 + ' '
                  + '-sOutputFile="' + Ziel + '"' + AX +
                  (Hochkommata + AP3 + Hochkommata + AP5 +
                  ' <- 128-Bit RC4' + #13)));
                Zielanz := Ziel;
              end
              else
              begin
                AppendMemoText((Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_2 + AP1_1 + ' '
                  + '-sOutputFile="' + Ziel + '"' + AX +
                  (Hochkommata + AP3 + Hochkommata + AP5 + #13)));
                Zielanz := Ziel;
              end;
              // Dateianlage vorne/hinten angefügt
              if Dateianlage_Form.Datei1.Text <> '' then
                AppendMemoText('Datei vorne angefügt:  '
                  + Dateianlage_Form.Datei1.Text + #13);
              if Dateianlage_Form.Datei2.Text <> '' then
                AppendMemoText('Datei hinten angefügt: '
                  + Dateianlage_Form.Datei2.Text);
            end
            else if Einstellungen_Form.AuswahlRG.ItemIndex = 11 then
            // JPEG zu PDF
            begin
              AppendMemoText((Ghostscript + ' ' + AP1_4 + AP1 + AP1_3 + AP1_1 + JV));
              Zielanz := Ziel;
            end
            else
              // BMP/PNG/TIFF zu PDF
              if Einstellungen_Form.AuswahlRG.ItemIndex in [10, 12, 13] then
                Memo1.Lines.Text := Memozeile
              else
              begin
                if (Einstellungen_Form.AuswahlRG.ItemIndex > 0) and
                  (Einstellungen_Form.AuswahlRG.ItemIndex < 10) then
                  // Auswahl ist PS, TXT, BMP, JPG, PNG, TIFF
                  AppendMemoText((Ghostscript + ' ' + AP1_4 + AP1 + ' ' + '-sOutputFile="' +
                    Ziel + '"' + AX + (Hochkommata + AP3 + Hochkommata + #13)))
                else
                  AppendMemoText((Ghostscript + ' ' + AP1_4 + AP1 + ' ' + '-sOutputFile="' +
                    Ziel + '"' + AX + (Hochkommata + AP3 + Hochkommata +
                    AP5 + #13)));
              end;
          end;

          // Logdatei (FreePDF64Log.txt) öffnen/beschreiben etc.
          if (FreePDF64_Form.Logdatei.Checked) then
          begin
            AssignFile(F, PChar(ExtractFilePath(Application.ExeName) +
              'FreePDF64Log.txt'));
            try
              Append(F);
            except
              Rewrite(F)
            end;
            if Einstellungen_Form.PDF_Shrink2.Enabled and
              Einstellungen_Form.PDF_Shrink2.Checked then
            begin
              QPDF_ExtractFile := 'K_' + ExtractFileName(Ziel);
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' =======> FORMATAUSWAHL: Erstellte PDF zu PDF - komprimiert'));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' + Ghostscript + ' ' + AP1_4 + AP1 +
                      AP1_3 + AP1_2 + AP1_1));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Quelldatei: ' + AP3));
              Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Dateigröße: ' + FormatByteString(MyFileSize(AP3))));

              if not Einstellungen_Form.Shrink2CB.Checked then
              begin
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + Ziel));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Dateigröße: ' + FormatByteString(MyFileSize(Ziel))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' +
                                (QPDF + ' --optimize-images --object-streams=generate --compression-level=9 --recompress-flate "' + Ziel +
                                 '" ' + '"' + ExtractFilePath(Ziel) + QPDF_ExtractFile + Hochkommata)));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFilePath(Ziel) +
                           QPDF_ExtractFile));

                Komprimierung := (FileSizePercent(ExtractFilePath(Ziel) + QPDF_ExtractFile, AP3));
                Komprimierung := 100 - Komprimierung;
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Dateigröße: ' +
                  FormatByteString(MyFileSize(ExtractFilePath(Ziel) + QPDF_ExtractFile))) + ' (um ' + IntToStr(Komprimierung) +
                                   '% komprimiert vom Original)');
              end else
              begin
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -              Befehle: ' +
                                (QPDF + ' --replace-input --optimize-images --object-streams=generate --compression-level=9 --recompress-flate --recompress-flate "' +
                                 Ziel + Hochkommata)));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + Ziel));

                Komprimierung := (FileSizePercent(Ziel, AP3));
                Komprimierung := 100 - Komprimierung;
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Dateigröße: ' +
                  FormatByteString(MyFileSize(Ziel))) + ' (um ' + IntToStr(Komprimierung) +
                                   '% komprimiert vom Original)');
              end;
            end else
            begin
              Buttontext := StringReplace(FormatBtn.Caption, 'Formatauswahl:', '', [rfReplaceAll]);
              if Einstellungen_Form.PDF_Shrink.Enabled and
                Einstellungen_Form.PDF_Shrink.Checked then
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' =======> FORMATAUSWAHL: Erstellte PDF zu PDF ' + '- komprimiert')
                  ) // PS/PDF/JPEG zu PDF/JPEG/TIFF'
              else
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' =======> FORMATAUSWAHL:' + Buttontext));
              // PS/PDF/JPEG zu PDF/JPEG/TIFF'

              if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and
                ((Encrypt_Form.BerechtigungCB.Checked = True) or
                (Encrypt_Form.KennwortCB.Checked = True)) then // 128 RC4
              begin
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -              Befehle: ' + Ghostscript + ' ' + AP1_4 + AP1
                  + AP1_3 + AP1_2 + AP1_1));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Quelldatei: ' + AP3));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Dateigröße: ' +
                  FormatByteString(MyFileSize(AP3))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -            Zieldatei: ' + Ziel));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Dateigröße: ' +
                  FormatByteString(MyFileSize(Ziel))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -              Befehle: ' +
                  (QPDF + ' --allow-weak-crypto --encrypt --user-password="' +
                  Versch5 + '" --owner-password="' + Versch3 + '" --bits=128' +
                  DokuSicherheit + ' -- "' + Ziel + '" "' + Ziel + '"')));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Quelldatei: ' + Ziel));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Dateigröße: ' +
                  FormatByteString(MyFileSize(Ziel))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -            Zieldatei: ' + Ziel + ' <- 128-Bit RC4'));

                Komprimierung := (FileSizePercent(Ziel, AP3));
                Komprimierung := 100 - Komprimierung;
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Dateigröße: ' +
                        FormatByteString(MyFileSize(Ziel))) + ' (um ' +
                        IntToStr(Komprimierung) + '% komprimiert vom Original)');
              end;

              if (Encrypt_Form.EncryptCombo.ItemIndex = 1) and
                ((Encrypt_Form.BerechtigungCB.Checked = True) or
                (Encrypt_Form.KennwortCB.Checked = True)) then // 128 AES
              begin
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -              Befehle: ' + Ghostscript + ' ' + AP1_4 + AP1
                  + AP1_3 + AP1_2 + AP1_1));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Quelldatei: ' + AP3));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Dateigröße: ' +
                  FormatByteString(MyFileSize(AP3))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -            Zieldatei: ' + Ziel));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Dateigröße: ' +
                  FormatByteString(MyFileSize(Ziel))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -              Befehle: ' +
                  (QPDF + ' --encrypt --user-password="' + Versch5 +
                  '" --owner-password="' + Versch3 + '" --bits=128 --use-aes=y'
                  + DokuSicherheit + ' -- "' + Ziel + '" "' + Ziel + '"')));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Quelldatei: ' + Ziel));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Dateigröße: ' +
                  FormatByteString(MyFileSize(Ziel))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -            Zieldatei: ' + Ziel + ' <- 128-Bit AES'));

                Komprimierung :=
                  (FileSizePercent(Ziel, AP3));
                Komprimierung := 100 - Komprimierung;
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Dateigröße: ' +
                  FormatByteString(MyFileSize(Ziel))) + ' (um ' +
                  IntToStr(Komprimierung) + '% komprimiert vom Original)');
              end;

              if (Encrypt_Form.EncryptCombo.ItemIndex = 2) and
                ((Encrypt_Form.BerechtigungCB.Checked = True) or
                (Encrypt_Form.KennwortCB.Checked = True)) then // 256 AES
              begin
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -              Befehle: ' + Ghostscript + ' ' + AP1_4 + AP1
                  + AP1_3 + AP1_2 + AP1_1));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Quelldatei: ' + AP3));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Dateigröße: ' +
                  FormatByteString(MyFileSize(AP3))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -            Zieldatei: ' + Ziel));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Dateigröße: ' +
                  FormatByteString(MyFileSize(Ziel))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -              Befehle: ' +
                  (QPDF + ' --encrypt --user-password="' + Versch5 +
                  '" --owner-password="' + Versch3 + '" --bits=256' +
                  DokuSicherheit + ' --allow-insecure -- "' + Ziel + '" "' +
                  Ziel + '"')));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Quelldatei: ' + Ziel));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Dateigröße: ' +
                  FormatByteString(MyFileSize(Ziel))));
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -            Zieldatei: ' + Ziel + ' <- 256-Bit AES'));

                Komprimierung :=
                  (FileSizePercent(Ziel, AP3));
                Komprimierung := 100 - Komprimierung;
                Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                  ' -           Dateigröße: ' +
                  FormatByteString(MyFileSize(Ziel))) +
                  ' (keine Komprimierung)');
              end;

              if ((Encrypt_Form.BerechtigungCB.Checked = False) and
                (Encrypt_Form.KennwortCB.Checked = False)) then
              begin
                if (Einstellungen_Form.AuswahlRG.ItemIndex = 0) then // PDF
                begin
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                    ' -              Befehle: ' + Ghostscript + ' ' + AP1_4 +
                    AP1 + AP1_3 + AP1_2 + AP1_1));
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                    ' -           Quelldatei: ' + AP3));
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                    ' -           Dateigröße: ' +
                    FormatByteString(MyFileSize(AP3))));
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                    ' -            Zieldatei: ' + Ziel));
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                    ' -           Dateigröße: ' +
                    FormatByteString(MyFileSize(Ziel))));

                  if Einstellungen_Form.PDF_Shrink.Enabled and
                    Einstellungen_Form.PDF_Shrink.Checked then
                  begin
                    if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and
                      (Encrypt_Form.BerechtigungCB.Checked or
                      Encrypt_Form.KennwortCB.Checked) then // 128 RC4
                      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                        Now) + ' -            Zieldatei: ' +
                        ExtractFilePath(Ziel) + 'K_' +
                        ExtractFileName(Ziel) + ' <- 128-Bit RC4'))
                    else
                      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                        Now) + ' -            Zieldatei: ' +
                        ExtractFilePath(Ziel) + 'K_' +
                        ExtractFileName(Ziel)))
                  end
                  else if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and
                    (Encrypt_Form.BerechtigungCB.Checked or
                    Encrypt_Form.KennwortCB.Checked) then // 128 RC4
                    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                      Now) + ' -            Zieldatei: ' + Ziel +
                      ' <- 128-Bit RC4'));

                  if Einstellungen_Form.PDF_Shrink.Enabled and
                    Einstellungen_Form.PDF_Shrink.Checked then
                  begin
                    Komprimierung :=
                      (FileSizePercent(ExtractFilePath(Ziel) + 'K_'
                      + ExtractFileName(Ziel), AP3));
                    Komprimierung := 100 - Komprimierung;
                    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                      Now) + ' -           Dateigröße: ' +
                      FormatByteString(MyFileSize(ExtractFilePath(Ziel) +
                      'K_' + ExtractFileName(Ziel)))) + ' (um ' +
                      IntToStr(Komprimierung) + '% komprimiert vom Original)');
                  end;

                  // Dateianlage vorne/hinten angefügt
                  if Dateianlage_Form.Datei1.Text <> '' then
                    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                      Now) + ' -  Datei vorne anfügen: ' +
                      IncludeTrailingBackslash(ExtractFilePath
                      (Dateianlage_Form.Datei1.Text)) +
                      ExtractFileName(Dateianlage_Form.Datei1.Text)));
                  if Dateianlage_Form.Datei2.Text <> '' then
                    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                      Now) + ' - Datei hinten anfügen: ' +
                      IncludeTrailingBackslash(ExtractFilePath
                      (Dateianlage_Form.Datei2.Text)) +
                      ExtractFileName(Dateianlage_Form.Datei2.Text)));

                end
                else if Einstellungen_Form.AuswahlRG.ItemIndex = 11 then // PDF
                begin
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                    ' -              Befehle: ' + Ghostscript + ' ' + AP1_4 +
                    AP1 + AP1_3 + AP1_1 + JV));
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                    ' -           Quelldatei: ' + AP3));
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                    ' -           Dateigröße: ' +
                    FormatByteString(MyFileSize(AP3))));
                  if (Encrypt_Form.EncryptCombo.ItemIndex = 0) and
                    (Encrypt_Form.BerechtigungCB.Checked or
                    Encrypt_Form.KennwortCB.Checked) then // 128 RC4
                    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                      Now) + ' -            Zieldatei: ' + Ziel +
                      ' <- 128-Bit RC4'))
                  else
                    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                      Now) + ' -            Zieldatei: ' + Ziel));
                  Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) +
                    ' -           Dateigröße: ' +
                    FormatByteString(MyFileSize(Ziel))));

                  if (Einstellungen_Form.PDF_Shrink.Checked = True) then
                  begin
                    Komprimierung := (FileSizePercent(ExtractFilePath(Ziel) + 'K_' + ExtractFileName(Ziel), AP3));
                    Komprimierung := 100 - Komprimierung;
                    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -            Zieldatei: ' + ExtractFilePath(Ziel) +
                                     'K_' + ExtractFileName(Ziel)));
                    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss', Now) + ' -           Dateigröße: ' +
                                     FormatByteString(MyFileSize(ExtractFilePath(Ziel) + 'K_' + ExtractFileName(Ziel)))) + ' (um ' +
                                     IntToStr(Komprimierung) + '% komprimiert vom Original)');
                  end;

                end
                else
                  // PS/DOCX/TXT/TIFF
                  if Einstellungen_Form.AuswahlRG.ItemIndex in [1, 2, 3, 7, 8, 9] then
                  begin
                    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                      Now) + ' -              Befehle: ' + Ghostscript + ' ' +
                      AP1_4 + AP1));
                    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                      Now) + ' -           Quelldatei: ' + AP3));
                    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                      Now) + ' -           Dateigröße: ' +
                      FormatByteString(MyFileSize(AP3))));
                    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                      Now) + ' -            Zieldatei: ' + Ziel));
                    Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                      Now) + ' -           Dateigröße: ' +
                      FormatByteString(MyFileSize(Ziel))));
                  end
                  else
                    // BMP, JPEG, PNG
                    if Einstellungen_Form.AuswahlRG.ItemIndex in [4, 5, 6] then
                    begin
                      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                        Now) + ' -              Befehle: ' + Ghostscript + ' ' +
                        AP1_4 + AP1));
                      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                        Now) + ' -           Quelldatei: ' + AP3));
                      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                        Now) + ' -           Dateigröße: ' +
                        FormatByteString(MyFileSize(AP3))));
                      Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                        Now) + ' -            Zieldatei: ' + Ziel));
                    end
                    else
                      // BMP, JPEG, PNG, TIFF zu PDF
                      if Einstellungen_Form.AuswahlRG.ItemIndex in [10, 12, 13] then
                      begin
                        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                          Now) + ' -              Befehle: ' + ImageMagick +
                          ' -define pdf:Author="" -define pdf:Creator="FreePDF64 (https://github.com/FreePDF64)" "'
                          + AP3 + '" "' + Ziel + '"'));
                        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                          Now) + ' -           Quelldatei: ' + AP3));
                        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                          Now) + ' -           Dateigröße: ' +
                          FormatByteString(MyFileSize(AP3))));
                        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                          Now) + ' -            Zieldatei: ' + Ziel));
                        Writeln(F, PChar(FormatDateTime('dd.mm.yyyy hh:mm:ss',
                          Now) + ' -           Dateigröße: ' +
                          FormatByteString(MyFileSize(Ziel))))
                      end;
              end;
            end;
            Closefile(F);
          end;
          // Ende von FreePDF64Log.txt

          // Dateieinträge der Dateianlage wieder löschen
          if Dateianlage_Form.DateianlageCB.Checked = False then
            Dateianlage_Form.Clear.Click;
          finally
            if InpHandle <> 0 then
            begin
              CloseHandle(InpHandle);
              InpHandle := 0;
            end;
            if OutpHandle <> 0 then
            begin
              CloseHandle(OutpHandle);
              OutpHandle := 0;
            end;
            StartUp.hStdInput := 0;
            StartUp.hStdOutput := 0;
            StartUp.hStdError := 0;
          end;
        end;
        // Markierte Datei(en) mit einem Anzeigeprogramm anzeigen
        if Einstellungen_Form.AnzeigenCB.Checked then
        begin
          if Einstellungen_Form.AuswahlRG.ItemIndex in [0, 11] then // PDF anzeigen
          begin
            if Einstellungen_Form.PDF_Shrink2.Enabled and
              Einstellungen_Form.PDF_Shrink2.Checked then
            begin
              if not Einstellungen_Form.Shrink2CB.Checked then
              begin
                QPDF_ExtractFile := 'K_' + ExtractFileName(Ziel);
                Zielanz := ExtractFilePath(Ziel) + QPDF_ExtractFile;
              end else
                Zielanz := Ziel;
            end
            else if Einstellungen_Form.PDF_Shrink.Enabled and Einstellungen_Form.PDF_Shrink.Checked then
              Zielanz := ExtractFilePath(Ziel) + 'K_' + ExtractFileName(Ziel)
            else if Zielanz = Ziel then
              Zielanz := Ziel;

            // Falls in einem Erstellungszweig keine explizite
            // Zielanz-Zuweisung erfolgte, immer die tatsächlich
            // erstellte Zieldatei verwenden.
            if Zielanz = '' then
              Zielanz := Ziel;

            if Einstellungen_Form.AuswahlRG.ItemIndex in [10, 12, 13] then // PDF anzeigen
              Zielanz := Ziel;

            // Pause von 1 sec. einbauen...
            Sleep(1000);

            // Anzeigen in der PDFForm
            if Encrypt_Form.EncryptCombo.ItemIndex = 1 then
            begin
              PDFForm := TPDFBrowserForm.Create(Self);
              PDFForm.PDFFileName := Ziel;
              PDFForm.Show;
              Application.ProcessMessages;
            end else
            begin
              PDFForm := TPDFBrowserForm.Create(Self);
              PDFForm.PDFFileName := Zielanz;
              PDFForm.Show;
              Application.ProcessMessages;
            end;
          end else
            if Einstellungen_Form.AuswahlRG.ItemIndex in [10, 12, 13] then // BMP/PNG/TIFF
            begin
              PDFForm := TPDFBrowserForm.Create(Self);
              PDFForm.PDFFileName := Ziel;
              PDFForm.Show;
              Application.ProcessMessages;
            end else
              if Einstellungen_Form.AuswahlRG.ItemIndex in [1, 3] then // PS/DOCX/TXT
              begin
                if Einstellungen_Form.Edit2.Text = '' then
                  ShellExecute(Application.Handle, NIL, PChar('"' + Ziel + '"'),
                    NIL, NIL, SW_SHOWNORMAL)
                else
                  ShellExecute(Application.Handle, 'open', PChar(Einstellungen_Form.Edit2.Text), PChar('"' + Ziel + '"'),
                               NIL, SW_SHOWNORMAL);
              end
              else if (Einstellungen_Form.AuswahlRG.ItemIndex > 6) and
              (Einstellungen_Form.AuswahlRG.ItemIndex < 10) then // TIFF
                ShellExecute(Application.Handle, NIL, PChar('"' + Ziel + '"'), NIL, NIL, SW_SHOWNORMAL);
        end;
        // Progressbar
        ProgressBar1.Position := 100;
        // Abbrechen-Taste gedrückt...
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
      if Process.hThread <> 0 then
      begin
        CloseHandle(Process.hThread);
        Process.hThread := 0;
      end;
      if Process.hProcess <> 0 then
      begin
        CloseHandle(Process.hProcess);
        Process.hProcess := 0;
      end;
      if InpHandle <> 0 then
      begin
        CloseHandle(InpHandle);
        InpHandle := 0;
      end;
      if OutpHandle <> 0 then
      begin
        CloseHandle(OutpHandle);
        OutpHandle := 0;
      end;
      // Wird im Falle eines Fehlers ausgeführt...
      ShowMessage(E.ClassName + ': ' + E.Message);
      if Einstellungen_Form.SystemklangCB.Checked then
        PlaySoundFile(ExtractFilePath(Application.ExeName) +
          'sounds\alert.wav');
    end;
  end;

  StatusBar1.Panels[0].Text := 'Standarddrucker: ' + Printer.Printers
    [Printer.printerindex] + ' | Erstellte Dateien (seit Nullstellung): ' +
    IntToStr(Counter);

  if Einstellungen_Form.SystemklangCB.Checked then
    PlaySoundFile(ExtractFilePath(Application.ExeName) +
      'sounds\confirmation.wav');
  FAbbrechen := False;
  AbbrechenPn.Visible := False;
  AbbrechenPn.BevelOuter := BvRaised;

  SB_Left;
  SB_Right;

  // Variable Ziel wieder zurücksetzen
  Ziel := Ziel3;

  // Nach einer normalen manuellen Erstellung wieder ins
  // LMDShellList1 gehen. Bei der automatischen Überwachung darf
  // die aktuelle Benutzeransicht nicht verändert werden.
  if (not UeberwachungsAufruf) and FreePDF64_Form.Visible then
  begin
    LMDShellList1.SetFocus;
    keybd_event(VK_SPACE, MapVirtualKey(VK_SPACE, 0), KEYEVENTF_EXTENDEDKEY, 0);
    // SPACE drücken
  end;

  // Seiten wieder zurückstellen
  Seiten_Form.VonSE.Value := 0;
  Seiten_Form.BisSE.Value := 0;

  Ziel := ExtractFilePath(Ziel);
  z := Ziel;
  ProgressBar1.Position := 0;

  // Bei einer automatischen Überwachung keine Shell-Ansicht
  // aktualisieren oder umschalten.
  if not UeberwachungsAufruf then
  begin
    LMDShellList1.RefreshData;
    LMDShellList2.RefreshData;
  end;

  Überwachung_Erstellung := False;
end;

end.
