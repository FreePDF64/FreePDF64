object PDFBrowserForm: TPDFBrowserForm
  Left = 303
  Top = 133
  Margins.Left = 8
  Margins.Top = 8
  Margins.Right = 8
  Margins.Bottom = 8
  Caption = 'PDF Viewer'
  ClientHeight = 1495
  ClientWidth = 2228
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -30
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 240
  TextHeight = 41
  object WVWindowParentPDF: TWVWindowParent
    Left = 0
    Top = 0
    Width = 2228
    Height = 1495
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alClient
    Color = clBtnShadow
    TabStop = True
    TabOrder = 0
    Browser = WVBrowserPDF
  end
  object TimerPDF: TTimer
    Enabled = False
    Interval = 300
    OnTimer = TimerPDFTimer
    Left = 412
    Top = 160
  end
  object WVBrowserPDF: TWVBrowser
    TargetCompatibleBrowserVersion = '95.0.1020.44'
    AllowSingleSignOnUsingOSPrimaryAccount = False
    OnInitializationError = WVBrowserPDFInitializationError
    OnAfterCreated = WVBrowserPDFAfterCreated
    Left = 200
    Top = 160
  end
end
