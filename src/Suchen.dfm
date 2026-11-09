object Suche_Form: TSuche_Form
  Left = 0
  Top = 0
  Margins.Left = 2
  Margins.Top = 2
  Margins.Right = 2
  Margins.Bottom = 2
  Anchors = [akLeft, akTop, akRight]
  Caption = 'Suchen nach Datei(en)/Verzeichnis(se)'
  ClientHeight = 540
  ClientWidth = 862
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnResize = FormResize
  OnShow = FormShow
  TextHeight = 15
  object Panel_oben: TPanel
    Left = 0
    Top = 0
    Width = 862
    Height = 193
    Align = alTop
    TabOrder = 0
    OnEnter = Panel_obenEnter
    ExplicitWidth = 860
    DesignSize = (
      862
      193)
    object Label1: TLabel
      Left = 11
      Top = 15
      Width = 71
      Height = 15
      Caption = 'Suchen nach:'
    end
    object Label2: TLabel
      Left = 11
      Top = 42
      Width = 55
      Height = 15
      Caption = 'Suchen in:'
    end
    object Label4: TLabel
      Left = 205
      Top = 138
      Width = 21
      Height = 15
      Caption = 'und'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object Clear: TSpeedButton
      Left = 310
      Top = 162
      Width = 24
      Height = 22
      Hint = 'Auswahl Dateigr'#246#223'e zur'#252'cksetzen'
      ImageIndex = 88
      ImageName = 'trashcan'
      Images = FreePDF64_Form.VirtualImageList1
      NumGlyphs = 2
      ParentShowHint = False
      ShowHint = True
      OnClick = ClearClick
    end
    object LabelTextCB: TLabel
      Left = 84
      Top = 97
      Width = 241
      Height = 16
      Hint = 
        'Textsuche geht nur bei "Zeige nur Dateien" und ohne "Datumssuche' +
        '"'
      AutoSize = False
      Caption = 'Label'
      ParentShowHint = False
      ShowHint = True
    end
    object DateigroesseLabel: TLabel
      Left = 86
      Top = 148
      Width = 35
      Height = 22
      Hint = 
        'Suche nach bestimmter Dateigr'#246#223'e geht nur bei "Zeige nur Dateien' +
        '"'
      AutoSize = False
      ParentShowHint = False
      ShowHint = True
    end
    object TextLb: TLabel
      Left = 11
      Top = 92
      Width = 65
      Height = 15
      Caption = 'Text suchen:'
    end
    object DirCheckbox: TCheckBox
      Left = 314
      Top = 70
      Width = 141
      Height = 16
      Caption = 'Inkl. Unterverzeichnisse'
      TabOrder = 6
    end
    object ButtonHoch: TButton
      Left = 667
      Top = 40
      Width = 22
      Height = 22
      Hint = 'Eine Ebene h'#246'her'
      Anchors = [akTop, akRight]
      Caption = '..'
      ImageAlignment = iaCenter
      Images = FreePDF64_Form.VirtualImageList1
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = ButtonHochClick
      ExplicitLeft = 665
    end
    object Browse: TButton
      Left = 692
      Top = 40
      Width = 32
      Height = 22
      Hint = 'Laufwerk/Verzeichnis ausw'#228'hlen'
      Anchors = [akTop, akRight]
      ImageAlignment = iaCenter
      ImageIndex = 8
      ImageName = 'Item9'
      Images = FreePDF64_Form.VirtualImageList1
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = BrowseClick
      ExplicitLeft = 690
    end
    object FileField: TComboBox
      Left = 84
      Top = 13
      Width = 639
      Height = 23
      Hint = 'F'#252'r Hilfe bitte das Fragezeichen anklicken'
      AutoDropDownWidth = True
      Anchors = [akLeft, akTop, akRight]
      DropDownCount = 20
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnCloseUp = FileFieldCloseUp
      OnDropDown = FileFieldDropDown
      ExplicitWidth = 637
    end
    object SearchField: TComboBox
      Left = 84
      Top = 40
      Width = 554
      Height = 23
      Hint = 'Hier nur einen Anfangspfad f'#252'r die Suche angeben'
      AutoDropDownWidth = True
      Anchors = [akLeft, akTop, akRight]
      DropDownCount = 20
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnDropDown = SearchFieldDropDown
      ExplicitWidth = 552
    end
    object StopSearchButton: TBitBtn
      Left = 730
      Top = 40
      Width = 124
      Height = 28
      Anchors = [akTop, akRight]
      Caption = 'Abbrechen'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
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
      ModalResult = 3
      ParentFont = False
      TabOrder = 20
      OnClick = StopSearchButtonClick
      ExplicitLeft = 728
    end
    object StartSearchButton: TBitBtn
      Left = 730
      Top = 10
      Width = 124
      Height = 28
      Anchors = [akTop, akRight]
      Caption = 'Suche starten'
      Default = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
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
      TabOrder = 19
      OnClick = StartSearchButtonClick
      ExplicitLeft = 728
    end
    object HiddenCheckbox: TCheckBox
      Left = 462
      Top = 70
      Width = 116
      Height = 16
      AllowGrayed = True
      Caption = 'Versteckt+System'
      Checked = True
      ParentShowHint = False
      ShowHint = False
      State = cbChecked
      TabOrder = 7
    end
    object SearchMaxDate: TDateTimePicker
      Left = 229
      Top = 135
      Width = 78
      Height = 23
      Date = 38156.00000000000000000
      Time = 0.99998842592322040
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 12
    end
    object SearchMinDate: TDateTimePicker
      Left = 122
      Top = 135
      Width = 79
      Height = 23
      Date = 45705.00000000000000000
      Time = 0.00001157407677965
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 11
    end
    object DatumCheckBox: TCheckBox
      Left = 11
      Top = 138
      Width = 110
      Height = 16
      Caption = 'Datum zwischen:'
      TabOrder = 10
      OnClick = DatumCheckBoxClick
    end
    object ButtonRoot: TButton
      Left = 642
      Top = 40
      Width = 22
      Height = 22
      Hint = 'Sprung zu Root'
      Anchors = [akTop, akRight]
      Caption = '\'
      ImageAlignment = iaCenter
      ImageIndex = 2
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = ButtonRootClick
      ExplicitLeft = 640
    end
    object FilesFoldersCB: TComboBox
      Left = 84
      Top = 67
      Width = 223
      Height = 23
      Style = csDropDownList
      DoubleBuffered = False
      ItemIndex = 1
      ParentDoubleBuffered = False
      TabOrder = 5
      Text = 'Zeige nur Dateien'
      OnChange = FilesFoldersCBChange
      Items.Strings = (
        'Zeige Dateien und Verzeichnisse'
        'Zeige nur Dateien'
        'Zeige nur Verzeichnisse')
    end
    object FileSizeCombo: TComboBox
      Left = 122
      Top = 162
      Width = 32
      Height = 23
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ItemIndex = 1
      ParentFont = False
      TabOrder = 16
      Text = '>'
      Items.Strings = (
        '='
        '>'
        '<')
    end
    object SizeAuswahl: TComboBox
      Left = 259
      Top = 162
      Width = 48
      Height = 23
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ItemIndex = 1
      ParentFont = False
      TabOrder = 18
      Text = 'KB'
      Items.Strings = (
        'Byte'
        'KB'
        'MB'
        'GB')
    end
    object UmbenennenCB: TCheckBox
      Left = 314
      Top = 102
      Width = 252
      Height = 16
      Hint = 
        'Beim Kopieren/Bewegen wird nicht nachgefragt, bevor eine Datei a' +
        'utomatisch umbenannt wird'
      Caption = 'Bei Kopieren/Bewegen autom. umbenennen'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
    end
    object SuchergebnisBtn: TBitBtn
      Left = 730
      Top = 163
      Width = 124
      Height = 21
      Hint = 'Suchergebnis speichern und anzeigen'
      Anchors = [akTop, akRight]
      Caption = 'Suchergebnis'
      Default = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ModalResult = 1
      NumGlyphs = 2
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 22
      OnClick = SuchergebnisBtnClick
      ExplicitLeft = 728
    end
    object TextCB: TComboBox
      Left = 84
      Top = 98
      Width = 223
      Height = 23
      Hint = 'Suche geht nur bei "Zeige nur Dateien" und ohne "Datumssuche"'
      AutoDropDownWidth = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      OnDropDown = TextCBDropDown
    end
    object Info: TButton
      Left = 797
      Top = 70
      Width = 57
      Height = 26
      Hint = 'Hilfe zum Suchefenster'
      Anchors = [akTop, akRight]
      BiDiMode = bdLeftToRight
      ImageAlignment = iaCenter
      ImageIndex = 46
      ImageName = 'Item49'
      Images = FreePDF64_Form.VirtualImageList1
      ParentBiDiMode = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 21
      OnClick = InfoClick
      ExplicitLeft = 795
    end
    object AlterCB: TCheckBox
      Left = 314
      Top = 138
      Width = 95
      Height = 16
      Caption = 'Nicht '#228'lter als:'
      TabOrder = 13
      OnClick = AlterCBClick
    end
    object AgeAuswahl: TComboBox
      Left = 458
      Top = 135
      Width = 75
      Height = 23
      Style = csDropDownList
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ItemIndex = 1
      ParentFont = False
      TabOrder = 15
      Text = 'Tag(e)'
      Items.Strings = (
        'Stunde(n)'
        'Tag(e)'
        'Woche(n)'
        'Monat(e)'
        'Jahr(e)')
    end
    object AgeSizeEdit: TSpinEdit
      Left = 411
      Top = 134
      Width = 41
      Height = 24
      Enabled = False
      MaxValue = 365
      MinValue = 0
      TabOrder = 14
      Value = 1
    end
    object FileSize: TSpinEdit
      Left = 161
      Top = 162
      Width = 93
      Height = 24
      MaxValue = 2147483647
      MinValue = 0
      TabOrder = 17
      Value = 1
      OnClick = FileSizeClick
      OnEnter = FileSizeEnter
      OnKeyPress = FileSizeKeyPress
    end
    object DTP: TDateTimePicker
      Left = 602
      Top = 118
      Width = 138
      Height = 23
      Date = 45704.00000000000000000
      Time = 0.60402040509507060
      Kind = dtkDateTime
      TabOrder = 23
      TabStop = False
      Visible = False
    end
    object DateiCheckBox: TCheckBox
      Left = 11
      Top = 165
      Width = 97
      Height = 17
      Caption = 'Dateigr'#246#223'e:'
      TabOrder = 24
      OnClick = DateiCheckBoxClick
    end
    object SuchergebnisCB: TCheckBox
      Left = 558
      Top = 165
      Width = 163
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Suche im Suchergebnis [F2]'
      ParentShowHint = False
      ShowHint = False
      TabOrder = 25
      OnClick = SuchergebnisCBClick
      ExplicitLeft = 556
    end
    object PDFCB: TCheckBox
      Left = 11
      Top = 109
      Width = 68
      Height = 17
      Hint = 'Auch PDF-Dateien durchsuchen'
      Caption = 'inkl. PDF'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 26
    end
  end
  object Suchpanel: TPanel
    Left = 0
    Top = 193
    Width = 862
    Height = 306
    Align = alClient
    TabOrder = 1
    OnResize = SuchpanelResize
    ExplicitWidth = 860
    ExplicitHeight = 298
    object Splitter1: TSplitter
      Left = 1
      Top = 1
      Width = 2
      Height = 304
      MinSize = 24
      ExplicitHeight = 305
    end
    object ListBox1: TListBox
      Left = 3
      Top = 1
      Width = 858
      Height = 304
      Style = lbOwnerDrawFixed
      Align = alClient
      DoubleBuffered = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      MultiSelect = True
      ParentDoubleBuffered = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 0
      OnClick = ListBox1Click
      OnDblClick = ListBox1DblClick
      OnDrawItem = ListBox1DrawItem
      OnMouseDown = ListBox1MouseDown
      ExplicitWidth = 856
      ExplicitHeight = 296
    end
    object SucheEdit: TEdit
      Left = 618
      Top = 278
      Width = 157
      Height = 23
      TabStop = False
      BevelKind = bkTile
      BevelOuter = bvRaised
      TabOrder = 1
      Visible = False
      OnChange = SucheEditChange
    end
    object AnzeigenPanel: TPanel
      Left = 775
      Top = 279
      Width = 84
      Height = 21
      Hint = 'Gefundene Eintr'#228'ge ganz oben im Suchergebnis anzeigen'
      ParentCustomHint = False
      BevelKind = bkFlat
      BiDiMode = bdLeftToRight
      Caption = 'Ergebnis...'
      Ctl3D = True
      DoubleBuffered = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentBackground = False
      ParentCtl3D = False
      ParentDoubleBuffered = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Visible = False
      OnClick = AnzeigenPanelClick
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 522
    Width = 862
    Height = 18
    Panels = <
      item
        Width = 80
      end
      item
        Width = 80
      end>
    ParentShowHint = False
    ShowHint = False
    ExplicitTop = 514
    ExplicitWidth = 860
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 499
    Width = 862
    Height = 23
    Align = alBottom
    BevelOuter = bvLowered
    DoubleBuffered = False
    ParentDoubleBuffered = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    ExplicitTop = 491
    ExplicitWidth = 860
    object Btn_2: TSpeedButton
      Left = 193
      Top = 1
      Width = 96
      Height = 21
      Hint = 'Kopieren mit Dialog'
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'F5 Kopieren'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = Btn_2Click
    end
    object Btn_6: TSpeedButton
      Left = 577
      Top = 1
      Width = 96
      Height = 21
      Hint = 'Gehe zur Datei/zum Verzeichnis (auch per Doppelklick m'#246'glich)'
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'F10 Gehe zu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = ListBox1DblClick
    end
    object Btn_1: TSpeedButton
      Left = 97
      Top = 1
      Width = 96
      Height = 21
      Hint = 'Datei(en) im Editor '#246'ffnen'
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'F4 Editor'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = Btn_1Click
    end
    object Btn_5: TSpeedButton
      Left = 673
      Top = 1
      Width = 96
      Height = 21
      Hint = 
        'Datei(en) ins '#220'berwachungs-Quellverzeichnis kopieren:'#13#10'Wenn auto' +
        'matische '#220'berwachung aktiv ist, startet die  '#13#10'sofortige Erstell' +
        'ung in PDF-Datei(en)'
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'Copy -> Quell'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = DateiinsQuellverzeichniskopieren1Click
    end
    object Btn_4: TSpeedButton
      Left = 385
      Top = 1
      Width = 96
      Height = 21
      Hint = 'L'#246'schen von Datei(en)/Verzeichnis(se)'
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'F8 L'#246'schen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = Btn_4Click
    end
    object Btn_3: TSpeedButton
      Left = 289
      Top = 1
      Width = 96
      Height = 21
      Hint = 'Verschieben mit Dialog'
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'F6 Bewegen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = Btn_3Click
    end
    object Btn_0: TSpeedButton
      Left = 481
      Top = 1
      Width = 96
      Height = 21
      Hint = 
        'Umfangreiche Datei-Informationen (Metadaten) anzeigen:'#13#10'RMB im u' +
        'nteren Anzeigefenster der Hauptform zeigt'#13#10'die Metadaten im exte' +
        'rnen Editor an'
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'F9 Datei-Info'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = Btn_0Click
    end
    object Btn_8: TSpeedButton
      Left = 1
      Top = 1
      Width = 96
      Height = 21
      Hint = 'PDF-Dateien anzeigen im FreePDF64-Viewer'
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'F3 PDF anzeigen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = Btn_8Click
    end
  end
  object LMDShellSysBrowseDialog1: TLMDShellSysBrowseDialog
    OwnerHandle = pwApplication
    RootFolder = 'sfMyComputer'
    Options = [boExpandDomains, boEnableOk, boNewGUI]
    Left = 638
    Top = 272
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 801
    Top = 268
  end
  object MainMenu1: TMainMenu
    Left = 1298
    Top = 621
    object DateiInfo1: TMenuItem
      Caption = 'Datei-Info'
      ShortCut = 120
      Visible = False
      OnClick = DateiInfo1Click
    end
    object Editor1: TMenuItem
      Caption = 'Editor'
      ShortCut = 115
      Visible = False
      OnClick = Editor1Click
    end
    object Kopieren1: TMenuItem
      Caption = 'Kopieren'
      ShortCut = 116
      Visible = False
      OnClick = Kopieren1Click
    end
    object Bewegen1: TMenuItem
      Caption = 'Bewegen'
      ShortCut = 117
      Visible = False
      OnClick = Bewegen1Click
    end
    object Lschen1: TMenuItem
      Caption = 'L'#246'schen'
      ShortCut = 119
      Visible = False
      OnClick = Lschen1Click
    end
    object Gehezu1: TMenuItem
      Caption = 'Gehe zu'
      ShortCut = 121
      Visible = False
      OnClick = ListBox1DblClick
    end
    object Markieren1: TMenuItem
      Caption = 'Markieren'
      ShortCut = 16449
      Visible = False
      OnClick = Markieren1Click
    end
    object PDFViewer1: TMenuItem
      Caption = 'PDF Viewer'
      ShortCut = 114
      Visible = False
      OnClick = Btn_8Click
    end
  end
end
