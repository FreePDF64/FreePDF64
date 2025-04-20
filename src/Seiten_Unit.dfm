object Seiten_Form: TSeiten_Form
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Seiten entnehmen'
  ClientHeight = 160
  ClientWidth = 384
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poMainFormCenter
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 17
  object Clear: TSpeedButton
    Left = 345
    Top = 107
    Width = 29
    Height = 28
    Hint = 'Auswahl zur'#252'cksetzen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ImageIndex = 88
    ImageName = 'trashcan'
    Images = FreePDF64_Form.VirtualImageList1
    NumGlyphs = 2
    ParentShowHint = False
    ShowHint = True
    OnClick = ClearClick
  end
  object AusgabeRG: TGroupBox
    Left = 45
    Top = 15
    Width = 294
    Height = 81
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Bitte Seiten ausw'#228'hlen (bis max. 1000):'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object Label4: TLabel
      Left = 25
      Top = 38
      Width = 28
      Height = 20
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Von:'
    end
    object Label5: TLabel
      Left = 163
      Top = 39
      Width = 22
      Height = 20
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Bis:'
    end
    object VonSE: TSpinEdit
      Left = 61
      Top = 34
      Width = 63
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      MaxValue = 1000
      MinValue = 0
      TabOrder = 0
      Value = 0
      OnChange = VonSEChange
    end
    object BisSE: TSpinEdit
      Left = 193
      Top = 34
      Width = 62
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      MaxValue = 1000
      MinValue = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Value = 0
      OnExit = BisSEExit
    end
  end
  object CancelBitBtn: TBitBtn
    Left = 201
    Top = 109
    Width = 133
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
    TabOrder = 2
    OnClick = CancelBitBtnClick
  end
  object OkBitBtn: TBitBtn
    Left = 50
    Top = 109
    Width = 133
    Height = 43
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Ok'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    Kind = bkOK
    NumGlyphs = 2
    ParentFont = False
    TabOrder = 1
  end
end
