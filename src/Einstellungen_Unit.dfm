object Einstellungen_Form: TEinstellungen_Form
  Left = 14
  Top = 175
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Einstellungen f'#252'r '#220'berwachung und manuelle Erstellung'
  ClientHeight = 702
  ClientWidth = 954
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poDesigned
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 20
  object Label1: TLabel
    Left = 14
    Top = 8
    Width = 234
    Height = 20
    Hint = 'Homepage von Ghostscript aufrufen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Ghostscript 64-Bit (gswin64c.exe):   '
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = Label1Click
  end
  object Label2: TLabel
    Left = 14
    Top = 188
    Width = 217
    Height = 20
    Hint = 'Homepage von Notepad++ aufrufen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Auswahl des Editors (optional):   '
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = Label2Click
  end
  object Label3: TLabel
    Left = 14
    Top = 38
    Width = 242
    Height = 20
    Hint = 'Homepage von QPDF aufrufen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'QPDF (Kommandozeilenprogramm):'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = Label3Click
  end
  object Label6: TLabel
    Left = 14
    Top = 68
    Width = 243
    Height = 20
    Hint = 'Homepage von PDFtk aufrufen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'PDFtk (Kommandozeilenprogramm):'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = Label6Click
  end
  object Label7: TLabel
    Left = 14
    Top = 98
    Width = 236
    Height = 20
    Hint = 'Homepage der Xpdf-Tools aufrufen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Xpdf-Tools (Verzeichnis ausw'#228'hlen):'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = Label7Click
  end
  object HintLabel: TLabel
    Left = 278
    Top = 618
    Width = 188
    Height = 34
    Hint = 
      'F'#252'r die Verschl'#252'sselung von PDF-Dateien muss PDF/A oder PDF/X-3 ' +
      'deaktiviert sein!'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    AutoSize = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
  end
  object ImageMagick: TLabel
    Left = 14
    Top = 128
    Width = 253
    Height = 20
    Hint = 'Homepage von ImageMagick aufrufen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'ImageMagick (Verzeichnis ausw'#228'hlen):'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = ImageMagickClick
  end
  object Label8: TLabel
    Left = 840
    Top = 448
    Width = 27
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Vol.:'
  end
  object Label9: TLabel
    Left = 830
    Top = 409
    Width = 37
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'MHA:'
  end
  object ExifTool: TLabel
    Left = 14
    Top = 158
    Width = 216
    Height = 20
    Hint = 'Homepage von ExifTool aufrufen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'ExifTool (Verzeichnis ausw'#228'hlen):'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = ExifToolClick
  end
  object Edit1: TEdit
    Left = 278
    Top = 5
    Width = 622
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
    TabOrder = 0
  end
  object MonitoringBtn: TButton
    Left = 911
    Top = 5
    Width = 31
    Height = 28
    Hint = 'Pfad zur Datei '#39'gswin64c.exe'#39
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '>>'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnClick = MonitoringBtnClick
  end
  object Edit2: TEdit
    Left = 278
    Top = 185
    Width = 622
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
    TabOrder = 12
  end
  object Button2: TButton
    Left = 911
    Top = 185
    Width = 31
    Height = 28
    Hint = 'Pfad zum Editor'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '>>'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 13
    OnClick = Button2Click
  end
  object DistParam: TRadioGroup
    Left = 481
    Top = 225
    Width = 222
    Height = 155
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Distiller Parameter'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemIndex = 2
    Items.Strings = (
      'Default'
      'Screen Optimized'
      'eBook'
      'Print Optimized'
      'Prepress Optimized')
    ParentFont = False
    ParentShowHint = False
    ShowHint = False
    TabOrder = 17
    TabStop = True
  end
  object SchriftParams: TRadioGroup
    Left = 278
    Top = 360
    Width = 188
    Height = 213
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Schriftarten/F'#252'llmuster'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemIndex = 3
    Items.Strings = (
      '72 dpi'
      '96 dpi'
      '150 dpi'
      '300 dpi'
      '600 dpi'
      '720 dpi')
    ParentFont = False
    TabOrder = 16
    TabStop = True
  end
  object PDFLevel: TRadioGroup
    Left = 278
    Top = 225
    Width = 188
    Height = 126
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'PDF-Kompatibilit'#228'tslevel'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemIndex = 3
    Items.Strings = (
      'Acrobat 5 (PDF 1.4)'
      'Acrobat 6 (PDF 1.5)'
      'Acrobat 7 (PDF 1.6)'
      'Acrobat 8 (PDF 1.7)')
    ParentFont = False
    TabOrder = 15
    TabStop = True
  end
  object OKBitBtn1: TBitBtn
    Left = 278
    Top = 649
    Width = 163
    Height = 44
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Speichern'
    Default = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    Glyph.Data = {
      360C0000424D360C000000000000360000002800000020000000200000000100
      180000000000000C0000130B0000130B00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000102
      0119250C00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000101003E5A
      1C7CB33A0A100500000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000334A187CB3
      3A7CB33A5D842A01010000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000001E2A0D7CB33A7CB3
      3A7CB33A7CB33A19240C00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000C13057CB03A7CB33A7CB3
      3A7CB33A7CB33A6D9D3302040100000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000006090271A4367CB33A7CB33A4868
      2178AC387CB33A7CB33A39521A00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000002040163912E7CB33A7CB33A5980290001
      002739137CB33A7CB33A7CB33A0E150700000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000020401587F297CB33A7CB33A79B13A080A040000
      00020201699A317CB33A7CB33A6E9E3404060200000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000060902628F2F7CB33A7CB33A7CB33A1E2D0E0000000000
      0000000016210B7CB33A7CB33A7CB33A52772701020000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000151E0A7CB33A7CB33A7CB33A354D180000000000000000
      00000000010100567C287CB33A7CB33A7CB33A3D581D01010000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000608027CB33A7CB33A4B6D240101010000000000000000
      00000000000000090F057CB33A7CB33A7CB33A7CB33A2D401400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000618E2E5F892C0204010000000000000000000000
      000000000000000000003D581D7CB33A7CB33A7CB33A7CB33A2B3E1400000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000141C080405020000000000000000000000000000
      0000000000000000000003060275A8357CB33A7CB33A7CB33A7CB33A32461701
      0100000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000001A270B7CB33A7CB33A7CB33A7CB33A7CB33A47
      6621020401000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000001004B6B237CB33A7CB33A7CB33A7CB33A7C
      B33A628F2F060902000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000205026C9B327CB33A7CB33A7CB33A7C
      B33A7CB33A71A435080C04000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000B10057CB03A7CB33A7CB33A7C
      B33A7CB33A7CB33A060A02000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000002435117CB33A7CB33A7C
      B33A7CB33A507525000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000010100405D1E7CB33A7C
      B33A7CB33A202E0E000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000101014361207C
      B33A7CB33A060B04000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000001010022
      310F588029000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000010100000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000}
    ModalResult = 1
    ParentFont = False
    TabOrder = 33
    OnClick = OKBitBtn1Click
  end
  object AuswahlRG: TRadioGroup
    Left = 14
    Top = 225
    Width = 249
    Height = 408
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Formatauswahl'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemIndex = 0
    Items.Strings = (
      'PS (Postscript)/PDF zu PDF *'
      'PDF zu PS'
      'PDF zu DOCX'
      'PS/PDF zu TXT'
      'PS/PDF zu BMP'
      'PS/PDF zu JPEG'
      'PS/PDF zu PNG'
      'PS/PDF zu TIFF (G4 - BW)'
      'PS/PDF zu TIFF (LZW - BW)'
      'PS/PDF zu TIFF (uncompressed)'
      'BMP zu PDF *'
      'JPEG zu PDF *'
      'PNG zu PDF *'
      'TIFF zu PDF *')
    ParentFont = False
    ParentShowHint = False
    ShowHint = False
    TabOrder = 14
    TabStop = True
    OnClick = AuswahlRGClick
  end
  object AusgabeRG: TGroupBox
    Left = 481
    Top = 389
    Width = 222
    Height = 70
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Ausgabe'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 18
    object Label4: TLabel
      Left = 8
      Top = 30
      Width = 26
      Height = 20
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'DPI:'
    end
    object Label5: TLabel
      Left = 92
      Top = 30
      Width = 56
      Height = 20
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Qualit'#228't:'
    end
    object SpinEdit1: TSpinEdit
      Left = 38
      Top = 25
      Width = 52
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 10
      MaxValue = 600
      MinValue = 0
      TabOrder = 0
      Value = 300
    end
    object SpinEdit2: TSpinEdit
      Left = 156
      Top = 25
      Width = 53
      Height = 31
      Hint = 
        'Kleiner Wert: Schlechte Qualit'#228't bei kleiner Dateigr'#246#223'e, '#13#10'Gro'#223'e' +
        'r Wert: Gute Qualit'#228't bei gro'#223'er Dateigr'#246#223'e'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Increment = 10
      MaxValue = 100
      MinValue = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Value = 75
    end
  end
  object AnzeigenCB: TCheckBox
    Left = 720
    Top = 491
    Width = 220
    Height = 26
    Hint = 
      'Zeigt die erstelle(n) PDF-Datei(en) im integrierten PDF-Anzeiger' +
      ' an'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Erstellte Datei(en) anzeigen'
    Checked = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    State = cbChecked
    TabOrder = 24
  end
  object EncryptBt: TBitBtn
    Left = 278
    Top = 590
    Width = 188
    Height = 43
    Hint = 'PDF-Dateien verschl'#252'sseln mit 128-Bit RC4/AES oder 256-Bit AES'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Verschl'#252'sselung'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ImageIndex = 86
    ImageName = 'Key'
    Images = FreePDF64_Form.VirtualImageList1
    NumGlyphs = 2
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 29
    OnClick = EncryptBtClick
  end
  object AutoRP: TRadioGroup
    Left = 720
    Top = 225
    Width = 220
    Height = 105
    Hint = 
      'Nein: beh'#228'lt die Ausrichtung jeder Seite bei'#13#10'Alle: dreht alle S' +
      'eiten'#13#10'Pro Seite: dreht die Seiten automatisch einzeln'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Seiten automatisch drehen'
    Ctl3D = True
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemIndex = 1
    Items.Strings = (
      'Nein'
      'Alle'
      'Seite f'#252'r Seite')
    ParentCtl3D = False
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 19
    WordWrap = True
    OnClick = AutoRPClick
  end
  object PDFMark: TBitBtn
    Left = 14
    Top = 649
    Width = 249
    Height = 44
    Hint = 
      #196'ndern von Titel, Verfasser, Thema, Schl'#252'sselw'#246'rter, Erstelldatu' +
      'm, '#196'nderungsdatum, Anwendung'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'PDF-Metadaten'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ImageIndex = 87
    ImageName = 'Write'
    Images = FreePDF64_Form.VirtualImageList1
    NumGlyphs = 2
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 32
    OnClick = PDFMarkClick
  end
  object CancelBitBtn1: TBitBtn
    Left = 459
    Top = 649
    Width = 163
    Height = 44
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Cancel = True
    Caption = 'Abbrechen'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    Glyph.Data = {
      360C0000424D360C000000000000360000002800000020000000200000000100
      180000000000000C0000130B0000130B00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000206180101
      0400000000000000000000000000000000000000000000000000000001010304
      081A000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000002020B2141DB0A15
      450000000000000000000000000000000000000000000000000000000B184E1B
      3AC2000102000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000002030E1E3ECC2348EF2041
      D90102060000000000000000000000000000000000000000000102062043E123
      48EF060C27000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000002030B2043E32348EF2348EF2348
      EF1328870000010000000000000000000000000000000000000E1C5E2348EF23
      48EF070D2E000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000050B292245E72348EF2348
      EF2348EF07103500000000000000000000000000000002020A2345E92348EF09
      123B000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000408182245E72348
      EF2348EF2146E702040E0000000000000000000000011327852348EF10227300
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000050B242348
      EE2348EF2348EF1C39BE010103000000000000070E2F2348EF1A37B401010400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000812
      3E2348EF2348EF2348EF11247C00000002020A2043E12041D901020900000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      011224792348EF2348EF2348EF0D1A561A38BA2348ED04081C00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000001031A35AF2348EF2348EF2348EF2348EF0C195200000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000102081F40D72348EF2348EF2348EF01020600000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000A14412348EF2348EF2348EF0E1D6100000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000102071E3ED12348EF2348EF2348EF2348EF050B2500000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000102172F9D2348EF1B38BF2144DF2348EF2348EF2142DF01020A00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000C19572348EF2348EF02051108113A2348EF2348EF2348EF1A36B500010300
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000408
      1F2348EF2348EF1024760000000001021C3AC32348EF2348EF2348EF12278100
      0001000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000102082141
      DB2348EF2146E6010207000000000000050B262348EF2348EF2348EF2348EF0A
      164A000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000001031A35B02348
      EF2348EF0C19520000000000000000000000011731A52348EF2348EF2348EF23
      48EF050A20000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000113267D2348EF2348
      EF1E40D601010300000000000000000000000004081B2348EF2348EF2348EF23
      48EF071033000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000A15462348EF2348EF2348
      EF0710350000000000000000000000000000000000011B38B72348EF2348EF11
      257E000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000008123E2348EF2348EF2348EF1A36
      B6000002000000000000000000000000000000000000070E302348EF1E3DCD01
      0103000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000002030C1C3CC32348EF2348EF0408
      1C0000000000000000000000000000000000000000000001021F40D8050B2300
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000102050F1E6617309D0000
      0000000000000000000000000000000000000000000000000004081D00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000020000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000}
    ModalResult = 2
    ParentFont = False
    TabOrder = 34
    OnClick = CancelBitBtn1Click
  end
  object SeitenBt: TBitBtn
    Left = 481
    Top = 475
    Width = 222
    Height = 43
    Hint = 
      'Ausgew'#228'hlte Seiten entnehmen aus allen Formaten bei der Erstellu' +
      'ng'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Seiten entnehmen'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ImageIndex = 97
    ImageName = '2530841_document_general_letter_note_office_icon'
    Images = FreePDF64_Form.VirtualImageList1
    NumGlyphs = 2
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 37
    OnClick = SeitenBtClick
  end
  object PDFA: TRadioGroup
    Left = 720
    Top = 369
    Width = 102
    Height = 114
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'PDF/A'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ItemIndex = 0
    Items.Strings = (
      'PDF/A-1b'
      'PDF/A-2b'
      'PDF/A-3b')
    ParentFont = False
    TabOrder = 21
    TabStop = True
  end
  object PDFA_CB: TCheckBox
    Left = 720
    Top = 339
    Width = 74
    Height = 21
    Hint = 'PDF/A-1 bis PDF/A-3 ist ein Dateiformat zur Langzeitarchivierung'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'PDF/A'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 20
    OnClick = PDFA_CBClick
  end
  object Info: TButton
    Left = 871
    Top = 649
    Width = 69
    Height = 44
    Hint = 'Hilfe zu den Einstellungen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    BiDiMode = bdLeftToRight
    ImageAlignment = iaCenter
    ImageIndex = 48
    ImageName = 'Item49'
    Images = FreePDF64_Form.VirtualImageList1
    ParentBiDiMode = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 36
    OnClick = InfoClick
  end
  object FastCB: TCheckBox
    Left = 720
    Top = 551
    Width = 220
    Height = 26
    Hint = 'PDF-Datei wird optimiert f'#252'r schnelle Webanzeige'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Schnelle Webanzeige'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 26
  end
  object UeberwachungBtn: TBitBtn
    Left = 637
    Top = 649
    Width = 220
    Height = 44
    Hint = #220'berwachungseinstellungen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = #220'berwachung'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    Images = FreePDF64_Form.VirtualImageList1
    NumGlyphs = 2
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 35
    OnClick = UeberwachungBtnClick
  end
  object Edit4: TEdit
    Left = 278
    Top = 35
    Width = 622
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
  object Button1: TButton
    Left = 911
    Top = 35
    Width = 31
    Height = 28
    Hint = 'Pfad zur Datei '#39'qpdf.exe'#39
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '>>'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = Button1Click
  end
  object Edit5: TEdit
    Left = 278
    Top = 65
    Width = 622
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
    TabOrder = 4
  end
  object Button4: TButton
    Left = 911
    Top = 65
    Width = 31
    Height = 28
    Hint = 'Pfad zur Datei '#39'pdftk.exe'#39
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '>>'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnClick = Button4Click
  end
  object PDF_Shrink: TCheckBox
    Left = 720
    Top = 581
    Width = 220
    Height = 26
    Hint = 
      'Komprimiert die PDF-Datei beim Erstellen nochmals mittels Ghosts' +
      'cript'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '1ste PDF-Komprimierung'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 27
    OnClick = PDF_ShrinkClick
  end
  object Edit6: TEdit
    Left = 278
    Top = 95
    Width = 622
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
    TabOrder = 6
  end
  object Button5: TButton
    Left = 911
    Top = 95
    Width = 31
    Height = 28
    Hint = 'Pfad zu den Xpdf-Tools'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '>>'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
    OnClick = Button5Click
  end
  object Zusatz: TBitBtn
    Left = 573
    Top = 590
    Width = 130
    Height = 43
    Hint = 
      'Entfernen von Zeichenketten aus den ermittelten Dateinamen beim ' +
      'Drucken in eine PDF-Datei'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Zeichenketten'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 31
    OnClick = ZusatzClick
  end
  object ZusatzAnAus: TCheckBox
    Left = 494
    Top = 601
    Width = 72
    Height = 21
    Hint = 'Entfernung der Zeichenketten ein-/ausschalten'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'An/Aus'
    Checked = True
    ParentShowHint = False
    ShowHint = True
    State = cbChecked
    TabOrder = 30
    OnClick = ZusatzAnAusClick
  end
  object SystemklangCB: TCheckBox
    Left = 720
    Top = 521
    Width = 220
    Height = 26
    Hint = 'Ein Systemklang wird nach der Erstellung abgespielt'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Systemklang nach Erstellung'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 25
  end
  object Dateianlage: TBitBtn
    Left = 481
    Top = 530
    Width = 222
    Height = 43
    Hint = 
      'Eine ausgew'#228'hlte PS- oder PDF-Datei vorne/hinten bei PDF-Erstell' +
      'ung anf'#252'gen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Datei vorne/hinten anf'#252'gen'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 38
    OnClick = DateianlageClick
  end
  object PDFX: TCheckBox
    Left = 830
    Top = 338
    Width = 80
    Height = 23
    Hint = 'PDF/X-3 ist f'#252'r den Austausch digitaler Druckvorlagen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'PDF/X-3'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 22
    OnClick = PDFXClick
  end
  object Edit7: TEdit
    Left = 278
    Top = 125
    Width = 622
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
    TabOrder = 8
  end
  object Button6: TButton
    Left = 911
    Top = 125
    Width = 31
    Height = 28
    Hint = 'Pfad zu den ImageMagick-Tools'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '>>'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
    OnClick = Button6Click
  end
  object HeightSpin: TSpinEdit
    Left = 871
    Top = 404
    Width = 47
    Height = 31
    Hint = 
      'Die Informationen (Metadaten, Verschl'#252'sselung, etc.)'#13#10'zu einer D' +
      'atei werden im unteren Anzeigefenster an-'#13#10'gezeigt. Diese Fenste' +
      'rh'#246'he l'#228#223't sich hier anpassen.'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabStop = False
    MaxValue = 300
    MinValue = 0
    ParentShowHint = False
    ShowHint = True
    TabOrder = 39
    Value = 80
  end
  object SoundSpin: TSpinEdit
    Left = 871
    Top = 443
    Width = 69
    Height = 31
    Hint = 
      'Manuelles Anpassen der Lautst'#228'rke des Systemklangs:'#13#10'0: Ton aus'#13 +
      #10'65535: Ton am lautesten'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    TabStop = False
    Increment = 100
    MaxValue = 65535
    MinValue = 0
    ParentShowHint = False
    ShowHint = True
    TabOrder = 41
    Value = 40000
  end
  object PDF_Shrink2: TCheckBox
    Left = 720
    Top = 611
    Width = 190
    Height = 26
    Hint = 'Komprimiert die PDF-Datei beim Erstellen nochmals mittels QPDF'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '2te PDF-Komprimierung'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 28
    OnClick = PDF_Shrink2Click
  end
  object Edit8: TEdit
    Left = 278
    Top = 155
    Width = 622
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
    TabOrder = 10
  end
  object Button7: TButton
    Left = 911
    Top = 155
    Width = 31
    Height = 28
    Hint = 'Pfad zu den ExifTool-Tools'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = '>>'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 11
    OnClick = Button7Click
  end
  object FontCB: TCheckBox
    Left = 922
    Top = 409
    Width = 18
    Height = 21
    Hint = 
      'Umschalten zwischen Schriftart Consolas und Courier New im unter' +
      'en Anzeigefenster:'#13#10'Checked: Consolas 10, Unchecked: Courier New' +
      ' 10'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Checked = True
    ParentShowHint = False
    ShowHint = True
    State = cbChecked
    TabOrder = 40
    OnClick = FontCBClick
  end
  object PDFX4: TCheckBox
    Left = 830
    Top = 364
    Width = 95
    Height = 23
    Hint = 
      'PDF/X-4a soll dem Anspruch an einen m'#246'glichst medienneutralen Au' +
      'stausch gerecht werden'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'PDF/X-4a'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 23
    OnClick = PDFX4Click
  end
  object Shrink2CB: TCheckBox
    Left = 910
    Top = 615
    Width = 18
    Height = 21
    Hint = 'Nur komprimierte Datei erzeugen (ohne K_ am Anfang)'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Checked = True
    Enabled = False
    ParentShowHint = False
    ShowHint = True
    State = cbChecked
    TabOrder = 42
  end
  object LMDOpenDialog1: TLMDOpenDialog
    Filter = 
      '*.exe|*.exe|*.*|*.*|Ghostscript 64-Bit|gswin64c.exe|QPDF|qpdf.ex' +
      'e'
    Left = 451
    Top = 51
  end
  object LMDShellSysBrowseDialog1: TLMDShellSysBrowseDialog
    OwnerHandle = pwApplication
    RootFolder = 'sfMyComputer'
    Options = [boExpandDomains, boEnableOk, boNewGUI]
    Left = 590
    Top = 50
  end
end
