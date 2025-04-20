object FreePDF64_Notify: TFreePDF64_Notify
  Left = 206
  Top = 120
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #220'berwachung'
  ClientHeight = 294
  ClientWidth = 458
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 120
  DesignSize = (
    458
    294)
  TextHeight = 16
  object lbObserved: TLabel
    Left = 20
    Top = 9
    Width = 172
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #220'berwachungsverzeichnis:'
    FocusControl = MonitoringFolder
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Wartezeit: TLabel
    Left = 20
    Top = 143
    Width = 307
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Wartezeit bis zur Erstellung in sec. (300 max.):  '
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 20
    Top = 71
    Width = 164
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Aktuelles Zielverzeichnis:'
    FocusControl = ZielEdit
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object SendToBtn: TSpeedButton
    Left = 390
    Top = 243
    Width = 31
    Height = 33
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ImageIndex = 7
    ImageName = 'Item8'
    Images = FreePDF64_Form.VirtualImageList1
    Flat = True
    Layout = blGlyphRight
    ParentShowHint = False
    ShowHint = True
    OnClick = SendToBtnClick
  end
  object MonitoringFolder: TEdit
    Left = 20
    Top = 35
    Width = 357
    Height = 28
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
  end
  object btnStart: TButton
    Left = 37
    Top = 184
    Width = 181
    Height = 45
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'AN'
    Enabled = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ImageIndex = 57
    ParentFont = False
    TabOrder = 5
    OnClick = btnStartClick
  end
  object btnStop: TButton
    Left = 239
    Top = 184
    Width = 181
    Height = 45
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'AUS'
    Enabled = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ImageIndex = 58
    ParentFont = False
    TabOrder = 6
    OnClick = btnStopClick
  end
  object OkBitBtn: TBitBtn
    Left = 84
    Top = 243
    Width = 132
    Height = 43
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Speichern'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    Kind = bkOK
    NumGlyphs = 2
    ParentFont = False
    TabOrder = 7
    OnClick = OkBitBtnClick
  end
  object MonitoringBtn: TButton
    Left = 390
    Top = 33
    Width = 31
    Height = 31
    Hint = #220'berwachungsverzeichnis ausw'#228'hlen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '>>'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -14
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnClick = MonitoringBtnClick
  end
  object SpinEditSec: TSpinEdit
    Left = 326
    Top = 139
    Width = 52
    Height = 31
    Hint = 'Wartezeit bis zur Erstellung in Sekunden'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    MaxValue = 300
    MinValue = 0
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    Value = 5
  end
  object CancelBitBtn1: TBitBtn
    Left = 242
    Top = 243
    Width = 132
    Height = 43
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    Kind = bkCancel
    NumGlyphs = 2
    ParentFont = False
    TabOrder = 8
    OnClick = CancelBitBtn1Click
  end
  object ZielEdit: TEdit
    Left = 20
    Top = 98
    Width = 357
    Height = 28
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    TabOrder = 2
  end
  object Ziel_FestCB: TCheckBox
    Left = 390
    Top = 98
    Width = 56
    Height = 26
    Hint = 'Aktuelles Zielverzeichnis als "Fest" (unver'#228'nderbar) einstellen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Fest'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = Ziel_FestCBClick
  end
  object LMDShellNotify: TLMDShellNotify
    Active = False
    NotifyEvents = [snDiskEvent]
    Options = [ioAcceptInterrupts, ioAcceptNonInterrupts]
    WatchSubFolders = False
    RootFolder = 'sfDesktop'
    MaxNotifications = 0
    OnFileCreate = LMDShellNotifyFileCreate
    OnShellChangeNotify = LMDShellNotifyShellChangeNotify
    Left = 401
    Top = 144
  end
  object LMDShellSysBrowseDialog1: TLMDShellSysBrowseDialog
    OwnerHandle = pwApplication
    RootFolder = 'sfMyComputer'
    Options = [boExpandDomains, boEnableOk, boNewGUI]
    Left = 46
    Top = 84
  end
  object LMDShellRestartDialog1: TLMDShellRestartDialog
    Left = 79
    Top = 159
  end
  object LMDShellLink1: TLMDShellLink
    Left = 275
    Top = 10
  end
end
