object Zusatz_Form: TZusatz_Form
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Zeichenketten festlegen'
  ClientHeight = 186
  ClientWidth = 301
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 20
  object Label1: TLabel
    Left = 15
    Top = 43
    Width = 254
    Height = 80
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 
      'Obige Zeichenketten werden aus den Dateinamen beim Drucken in ei' +
      'ne PDF-Datei entfernt -> Bestes Ergebnis bei Abfrage auf nur ein' +
      'e Zeichenkette!'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object Clear: TSpeedButton
    Left = 246
    Top = 134
    Width = 29
    Height = 27
    Hint = 'Alle Eintr'#228'ge l'#246'schen'
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
  object BitBtn1: TBitBtn
    Left = 88
    Top = 134
    Width = 132
    Height = 44
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
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object ZusatzCB: TComboBox
    Left = 15
    Top = 10
    Width = 272
    Height = 28
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabOrder = 1
  end
end
