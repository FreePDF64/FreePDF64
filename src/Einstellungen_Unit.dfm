object Einstellungen_Form: TEinstellungen_Form
  Left = 14
  Top = 175
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Einstellungen f'#252'r '#220'berwachung und manuelle Erstellung'
  ClientHeight = 728
  ClientWidth = 953
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poDesigned
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 20
  object Label1: TLabel
    Left = 14
    Top = 5
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
    Top = 185
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
  object PDFAnzeiger: TLabel
    Left = 14
    Top = 215
    Width = 268
    Height = 20
    Hint = 'Homepage von SumatraPDF aufrufen'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Auswahl des PDF-Anzeigers (optional):   '
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = PDFAnzeigerClick
  end
  object Label3: TLabel
    Left = 14
    Top = 35
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
    Top = 65
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
    Top = 95
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
    Top = 125
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
    Top = 476
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
    Top = 437
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
    Top = 155
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
    Top = 256
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
    TabOrder = 19
    TabStop = True
  end
  object SchriftParams: TRadioGroup
    Left = 278
    Top = 390
    Width = 188
    Height = 214
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
    TabOrder = 18
    TabStop = True
  end
  object PDFLevel: TRadioGroup
    Left = 278
    Top = 256
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
    TabOrder = 17
    TabStop = True
  end
  object OKBitBtn1: TBitBtn
    Left = 278
    Top = 675
    Width = 163
    Height = 44
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
    TabOrder = 35
    OnClick = OKBitBtn1Click
  end
  object AuswahlRG: TRadioGroup
    Left = 14
    Top = 256
    Width = 249
    Height = 405
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
      'PS (Postscript)/PDF zu PDF'
      'PDF zu PS'
      'PDF zu DOCX'
      'PS/PDF zu TXT'
      'PS/PDF zu BMP'
      'PS/PDF zu JPEG'
      'PS/PDF zu PNG'
      'PS/PDF zu TIFF (G4 - BW)'
      'PS/PDF zu TIFF (LZW - BW)'
      'PS/PDF zu TIFF (uncompressed)'
      'BMP zu PDF'
      'JPEG zu PDF'
      'PNG zu PDF'
      'TIFF zu PDF')
    ParentFont = False
    ParentShowHint = False
    ShowHint = False
    TabOrder = 16
    TabStop = True
    OnClick = AuswahlRGClick
  end
  object AusgabeRG: TGroupBox
    Left = 481
    Top = 425
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
    TabOrder = 20
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
    Top = 516
    Width = 220
    Height = 26
    Hint = 'Zeigt die erstelle(n) PDF-Datei(en) im PDF-Anzeiger an'
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
    TabOrder = 26
  end
  object Edit3: TEdit
    Left = 278
    Top = 215
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
    TabOrder = 14
  end
  object Button3: TButton
    Left = 911
    Top = 215
    Width = 31
    Height = 28
    Hint = 'Pfad zum PDF-Anzeiger'
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
    TabOrder = 15
    OnClick = Button3Click
  end
  object EncryptBt: TBitBtn
    Left = 278
    Top = 618
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
    TabOrder = 31
    OnClick = EncryptBtClick
  end
  object AutoRP: TRadioGroup
    Left = 720
    Top = 256
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
    TabOrder = 21
    WordWrap = True
    OnClick = AutoRPClick
  end
  object PDFMark: TBitBtn
    Left = 14
    Top = 675
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
    TabOrder = 34
    OnClick = PDFMarkClick
  end
  object CancelBitBtn1: TBitBtn
    Left = 459
    Top = 675
    Width = 163
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
    Kind = bkCancel
    NumGlyphs = 2
    ParentFont = False
    TabOrder = 36
    OnClick = CancelBitBtn1Click
  end
  object SeitenBt: TBitBtn
    Left = 481
    Top = 510
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
    TabOrder = 39
    OnClick = SeitenBtClick
  end
  object PDFA: TRadioGroup
    Left = 720
    Top = 395
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
    TabOrder = 23
    TabStop = True
  end
  object PDFA_CB: TCheckBox
    Left = 720
    Top = 370
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
    TabOrder = 22
    OnClick = PDFA_CBClick
  end
  object Info: TButton
    Left = 871
    Top = 675
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
    TabOrder = 38
    OnClick = InfoClick
  end
  object FastCB: TCheckBox
    Left = 720
    Top = 576
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
    TabOrder = 28
  end
  object UeberwachungBtn: TBitBtn
    Left = 637
    Top = 675
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
    TabOrder = 37
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
    Top = 606
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
    TabOrder = 29
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
    Hint = 'Pfad zu den XPDF-Tools'
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
    Left = 582
    Top = 618
    Width = 121
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
    TabOrder = 33
    OnClick = ZusatzClick
  end
  object ZusatzAnAus: TCheckBox
    Left = 506
    Top = 629
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
    TabOrder = 32
    OnClick = ZusatzAnAusClick
  end
  object SystemklangCB: TCheckBox
    Left = 720
    Top = 546
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
    TabOrder = 27
  end
  object Dateianlage: TBitBtn
    Left = 481
    Top = 561
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
    TabOrder = 40
    OnClick = DateianlageClick
  end
  object PDFX: TCheckBox
    Left = 830
    Top = 369
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
    TabOrder = 24
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
    Top = 432
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
    TabOrder = 41
    Value = 80
  end
  object SoundSpin: TSpinEdit
    Left = 871
    Top = 471
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
    TabOrder = 43
    Value = 40000
  end
  object PDF_Shrink2: TCheckBox
    Left = 720
    Top = 636
    Width = 220
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
    TabOrder = 30
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
  object ExifToolGE: TCheckBox
    Left = 238
    Top = 156
    Width = 18
    Height = 21
    Hint = 
      'Umschalten zwischen deutscher/englischer Ausgabe der Datei-Infor' +
      'mationen:'#13#10'Checked: Deutsch, Unchecked: Englisch'
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Checked = True
    ParentShowHint = False
    ShowHint = True
    State = cbChecked
    TabOrder = 44
    OnClick = ExifToolGEClick
  end
  object FontCB: TCheckBox
    Left = 922
    Top = 437
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
    TabOrder = 42
    OnClick = FontCBClick
  end
  object PDFX4: TCheckBox
    Left = 830
    Top = 395
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
    TabOrder = 25
    OnClick = PDFX4Click
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
