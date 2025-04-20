object Dateianlage_Form: TDateianlage_Form
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Datei vorne/hinten anf'#252'gen (PS- oder PDF-Datei)'
  ClientHeight = 171
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OnKeyDown = FormKeyDown
  PixelsPerInch = 120
  TextHeight = 20
  object Hinten: TLabel
    Left = 10
    Top = 50
    Width = 142
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Datei hinten anf'#252'gen:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Vorne: TLabel
    Left = 10
    Top = 14
    Width = 138
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Datei vorne anf'#252'gen:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Clear: TSpeedButton
    Left = 382
    Top = 120
    Width = 29
    Height = 27
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
  object Datei1: TEdit
    Left = 162
    Top = 11
    Width = 346
    Height = 28
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = False
    TabOrder = 0
  end
  object Datei2: TEdit
    Left = 162
    Top = 47
    Width = 346
    Height = 28
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object Datei1Btn: TButton
    Left = 520
    Top = 10
    Width = 31
    Height = 31
    Hint = 'Vordere Datei ausw'#228'hlen'
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
    OnClick = Datei1BtnClick
  end
  object Datei2Btn: TButton
    Left = 520
    Top = 46
    Width = 31
    Height = 31
    Hint = 'Hintere Datei '#246'ffnen'
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
    TabOrder = 3
    OnClick = Datei2BtnClick
  end
  object DateianlageCB: TCheckBox
    Left = 10
    Top = 87
    Width = 462
    Height = 21
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Datei(en) beibehalten - auch nach dem Neustart!'
    TabOrder = 4
    OnClick = DateianlageCBClick
  end
  object BitBtn1: TBitBtn
    Left = 219
    Top = 120
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
    Kind = bkOK
    NumGlyphs = 2
    ParentFont = False
    TabOrder = 5
  end
  object LMDOpenDialog1: TLMDOpenDialog
    Filter = '*.ps; *.pdf |*.ps; *.pdf'
    Left = 81
    Top = 116
  end
end
