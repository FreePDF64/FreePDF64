object PDFBrowserForm: TPDFBrowserForm
  Left = 303
  Top = 133
  Margins.Left = 4
  Margins.Top = 4
  Margins.Right = 4
  Margins.Bottom = 4
  Caption = 'PDF-Anzeiger'
  ClientHeight = 708
  ClientWidth = 1114
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 20
  object WVWindowParentPDF: TWVWindowParent
    Left = 0
    Top = 0
    Width = 1114
    Height = 708
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
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
