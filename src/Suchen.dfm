object Suche_Form: TSuche_Form
  Left = 0
  Top = 0
  Anchors = [akLeft, akTop, akRight]
  Caption = 'Suchen nach Datei(en)/Verzeichnis(sen)'
  ClientHeight = 677
  ClientWidth = 984
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
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
  PixelsPerInch = 120
  TextHeight = 20
  object Panel_oben: TPanel
    Left = 0
    Top = 0
    Width = 984
    Height = 225
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alTop
    TabOrder = 0
    OnEnter = Panel_obenEnter
    DesignSize = (
      984
      225)
    object Label1: TLabel
      Left = 14
      Top = 19
      Width = 85
      Height = 20
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Suchen nach:'
    end
    object Label2: TLabel
      Left = 14
      Top = 53
      Width = 66
      Height = 20
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Suchen in:'
    end
    object Label4: TLabel
      Left = 256
      Top = 156
      Width = 25
      Height = 20
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'und'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object Clear: TSpeedButton
      Left = 388
      Top = 187
      Width = 29
      Height = 27
      Hint = 'Auswahl Dateigr'#246#223'e zur'#252'cksetzen'
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
    object TextLabel: TLabel
      Left = 14
      Top = 121
      Width = 79
      Height = 20
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Text suchen:'
    end
    object LabelTextCB: TLabel
      Left = 105
      Top = 121
      Width = 301
      Height = 20
      Hint = 
        'Textsuche geht nur bei "Zeige nur Dateien" und ohne "Datumssuche' +
        '"'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoSize = False
      Caption = 'Label'
      ParentShowHint = False
      ShowHint = True
    end
    object DateigroesseLabel: TLabel
      Left = 107
      Top = 185
      Width = 44
      Height = 28
      Hint = 
        'Suche nach bestimmter Dateigr'#246#223'e geht nur bei "Zeige nur Dateien' +
        '"'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoSize = False
      ParentShowHint = False
      ShowHint = True
    end
    object DirCheckbox: TCheckBox
      Left = 359
      Top = 89
      Width = 246
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Inkl. Unterverzeichnisse'
      TabOrder = 6
    end
    object ButtonHoch: TButton
      Left = 733
      Top = 50
      Width = 27
      Height = 28
      Hint = 'Eine Ebene h'#246'her'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Caption = '..'
      ImageAlignment = iaCenter
      Images = FreePDF64_Form.VirtualImageList1
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = ButtonHochClick
    end
    object Browse: TButton
      Left = 764
      Top = 50
      Width = 40
      Height = 28
      Hint = 'Laufwerk/Verzeichnis ausw'#228'hlen'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      ImageAlignment = iaCenter
      ImageIndex = 8
      ImageName = 'Item9'
      Images = FreePDF64_Form.VirtualImageList1
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = BrowseClick
    end
    object FileField: TComboBox
      Left = 105
      Top = 16
      Width = 698
      Height = 28
      Hint = 'F'#252'r Hilfe bitte das Fragezeichen anklicken'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoDropDownWidth = True
      Anchors = [akLeft, akTop, akRight]
      DropDownCount = 20
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnDropDown = FileFieldDropDown
    end
    object SearchField: TComboBox
      Left = 105
      Top = 50
      Width = 592
      Height = 28
      Hint = 'Hier nur einen Anfangspfad f'#252'r die Suche angeben'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoDropDownWidth = True
      Anchors = [akLeft, akTop, akRight]
      DropDownCount = 20
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnDropDown = SearchFieldDropDown
    end
    object StopSearchButton: TBitBtn
      Left = 812
      Top = 50
      Width = 159
      Height = 35
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      Kind = bkAbort
      NumGlyphs = 2
      ParentFont = False
      TabOrder = 20
      OnClick = StopSearchButtonClick
    end
    object StartSearchButton: TBitBtn
      Left = 812
      Top = 12
      Width = 159
      Height = 35
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Caption = 'Suche starten'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      Kind = bkOK
      NumGlyphs = 2
      ParentFont = False
      TabOrder = 19
      OnClick = StartSearchButtonClick
    end
    object HiddenCheckbox: TCheckBox
      Left = 537
      Top = 89
      Width = 145
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AllowGrayed = True
      Caption = 'Versteckt+System'
      Checked = True
      ParentShowHint = False
      ShowHint = False
      State = cbChecked
      TabOrder = 7
    end
    object SearchMaxDate: TDateTimePicker
      Left = 286
      Top = 153
      Width = 98
      Height = 28
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Date = 38156.000000000000000000
      Time = 0.999988425923220300
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 12
    end
    object SearchMinDate: TDateTimePicker
      Left = 153
      Top = 153
      Width = 98
      Height = 28
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Date = 45705.000000000000000000
      Time = 0.000011574076779652
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 11
    end
    object DatumCheckBox: TCheckBox
      Left = 14
      Top = 156
      Width = 137
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Datum zwischen:'
      TabOrder = 10
      OnClick = DatumCheckBoxClick
    end
    object ButtonRoot: TButton
      Left = 702
      Top = 50
      Width = 27
      Height = 28
      Hint = 'Sprung zu Root'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Caption = '\'
      ImageAlignment = iaCenter
      ImageIndex = 2
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = ButtonRootClick
    end
    object FilesFoldersCB: TComboBox
      Left = 105
      Top = 84
      Width = 246
      Height = 28
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Style = csDropDownList
      DoubleBuffered = False
      ItemIndex = 0
      ParentDoubleBuffered = False
      TabOrder = 5
      Text = 'Zeige Dateien und Verzeichnisse'
      OnChange = FilesFoldersCBChange
      Items.Strings = (
        'Zeige Dateien und Verzeichnisse'
        'Zeige nur Dateien'
        'Zeige nur Verzeichnisse')
    end
    object FileSizeCombo: TComboBox
      Left = 153
      Top = 187
      Width = 40
      Height = 28
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
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
      Left = 324
      Top = 187
      Width = 60
      Height = 28
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
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
      Left = 392
      Top = 121
      Width = 333
      Height = 21
      Hint = 
        'Beim Kopieren/Bewegen wird nicht nachgefragt, bevor eine Datei a' +
        'utomatisch umbenannt wird'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Beim Kopieren/Bewegen autom. umbenennen'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
    end
    object SuchergebnisBtn: TBitBtn
      Left = 812
      Top = 191
      Width = 159
      Height = 26
      Hint = 'Suchergebnis speichern und anzeigen'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Caption = 'Suchergebnis'
      Default = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ModalResult = 1
      NumGlyphs = 2
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 23
      OnClick = SuchergebnisBtnClick
    end
    object TextCB: TComboBox
      Left = 105
      Top = 118
      Width = 279
      Height = 28
      Hint = 'Suche geht nur bei "Zeige nur Dateien" und ohne "Datumssuche"'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      AutoDropDownWidth = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      OnDropDown = TextCBDropDown
    end
    object Info: TButton
      Left = 896
      Top = 88
      Width = 75
      Height = 32
      Hint = 'Hilfe zum Suchefenster'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      BiDiMode = bdLeftToRight
      ImageAlignment = iaCenter
      ImageIndex = 48
      ImageName = 'Item49'
      Images = FreePDF64_Form.VirtualImageList1
      ParentBiDiMode = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 21
      OnClick = InfoClick
    end
    object AlterCB: TCheckBox
      Left = 392
      Top = 156
      Width = 119
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Nicht '#228'lter als:'
      TabOrder = 13
      OnClick = AlterCBClick
    end
    object AgeAuswahl: TComboBox
      Left = 573
      Top = 153
      Width = 93
      Height = 28
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Style = csDropDownList
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
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
      Left = 514
      Top = 151
      Width = 51
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Enabled = False
      MaxValue = 365
      MinValue = 0
      TabOrder = 14
      Value = 1
    end
    object FileSize: TSpinEdit
      Left = 201
      Top = 186
      Width = 116
      Height = 31
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      MaxValue = 2147483647
      MinValue = 0
      TabOrder = 17
      Value = 1
      OnClick = FileSizeClick
      OnEnter = FileSizeEnter
      OnKeyPress = FileSizeKeyPress
    end
    object DTP: TDateTimePicker
      Left = 752
      Top = 148
      Width = 173
      Height = 28
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Date = 45704.000000000000000000
      Time = 0.604020405095070600
      Kind = dtkDateTime
      TabOrder = 24
      TabStop = False
      Visible = False
    end
    object DateiCheckBox: TCheckBox
      Left = 14
      Top = 188
      Width = 121
      Height = 21
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Dateigr'#246#223'e:'
      TabOrder = 25
      OnClick = DateiCheckBoxClick
    end
    object SortBtn: TBitBtn
      Left = 648
      Top = 191
      Width = 159
      Height = 26
      Hint = 'Verzeichnis(se) zuerst, Datei(en) zuletzt'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Anchors = [akTop, akRight]
      Caption = 'Ergebnis umsortieren'
      Default = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ModalResult = 1
      NumGlyphs = 2
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 22
      OnClick = SortBtnClick
    end
  end
  object Suchpanel: TPanel
    Left = 0
    Top = 225
    Width = 984
    Height = 401
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    TabOrder = 1
    OnResize = SuchpanelResize
    object Splitter1: TSplitter
      Left = 1
      Top = 1
      Height = 399
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      ExplicitHeight = 465
    end
    object ListBox1: TListBox
      Left = 4
      Top = 1
      Width = 979
      Height = 399
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Style = lbOwnerDrawFixed
      Align = alClient
      DoubleBuffered = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ItemHeight = 20
      MultiSelect = True
      ParentDoubleBuffered = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      Sorted = True
      TabOrder = 0
      OnClick = ListBox1Click
      OnDblClick = ListBox1DblClick
      OnDrawItem = ListBox1DrawItem
      OnMouseDown = ListBox1MouseDown
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 654
    Width = 984
    Height = 23
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Panels = <
      item
        Width = 100
      end
      item
        Width = 100
      end>
    ParentShowHint = False
    ShowHint = False
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 626
    Width = 984
    Height = 28
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alBottom
    BevelOuter = bvLowered
    DoubleBuffered = False
    ParentDoubleBuffered = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    object Btn_2: TSpeedButton
      Left = 121
      Top = 1
      Width = 120
      Height = 26
      Hint = 'Kopieren von Datei(en)/Verzeichnis(se)'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'F5 Kopieren'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = Btn_2Click
      ExplicitLeft = 215
    end
    object Btn_7: TSpeedButton
      Left = 841
      Top = 1
      Width = 120
      Height = 26
      Hint = 'Alle Dateien markieren'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'Markieren'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = Btn_7Click
      OnMouseDown = Btn_7MouseDown
      ExplicitLeft = 842
    end
    object Btn_6: TSpeedButton
      Left = 601
      Top = 1
      Width = 120
      Height = 26
      Hint = 'Gehe zur Datei/zum Verzeichnis (auch per Doppelklick m'#246'glich)'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'F10 Gehe zu'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = ListBox1DblClick
      ExplicitHeight = 27
    end
    object Btn_1: TSpeedButton
      Left = 1
      Top = 1
      Width = 120
      Height = 26
      Hint = 'Datei(en) im Editor '#246'ffnen'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'F4 Editor'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = Btn_1Click
      ExplicitLeft = 229
      ExplicitTop = -6
    end
    object Btn_5: TSpeedButton
      Left = 721
      Top = 1
      Width = 120
      Height = 26
      Hint = 'Datei(en) ins '#220'berwachungs-Quellverzeichnis kopieren'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'Copy -> Quell'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = DateiinsQuellverzeichniskopieren1Click
      ExplicitLeft = 733
    end
    object Btn_4: TSpeedButton
      Left = 361
      Top = 1
      Width = 120
      Height = 26
      Hint = 'L'#246'schen von Datei(en)/Verzeichnis(se)'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'F8 L'#246'schen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = Btn_4Click
      ExplicitHeight = 27
    end
    object Btn_3: TSpeedButton
      Left = 241
      Top = 1
      Width = 120
      Height = 26
      Hint = 'Verschieben von Datei(en)/Verzeichnis(se)'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'F6 Bewegen'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = Btn_3Click
      ExplicitLeft = 243
    end
    object Btn_0: TSpeedButton
      Left = 481
      Top = 1
      Width = 120
      Height = 26
      Hint = 
        'Umfangreiche Datei-Informationen (Metadaten) anzeigen:'#13#10'Rechtskl' +
        'ick im unteren Anzeigefenster der Hauptform zeigt'#13#10'die Metadaten' +
        ' im externen Editor an'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alLeft
      BiDiMode = bdLeftToRight
      Caption = 'F9 Datei-Info'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ParentBiDiMode = False
      ShowHint = True
      OnClick = Btn_0Click
      ExplicitLeft = 533
      ExplicitTop = 7
    end
    object SucheEdit: TEdit
      Left = 4
      Top = 0
      Width = 197
      Height = 28
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      TabStop = False
      BevelKind = bkTile
      BevelOuter = bvRaised
      TabOrder = 0
      Visible = False
      OnChange = SucheEditChange
    end
    object AnzeigenPanel: TPanel
      Left = 201
      Top = 2
      Width = 97
      Height = 26
      Hint = 'Gefundende Eintr'#228'ge ganz oben anzeigen'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      ParentCustomHint = False
      BevelKind = bkFlat
      BiDiMode = bdLeftToRight
      Caption = 'Ergebnis...'
      Ctl3D = True
      DoubleBuffered = False
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentBackground = False
      ParentCtl3D = False
      ParentDoubleBuffered = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Visible = False
      OnClick = AnzeigenPanelClick
    end
  end
  object LMDShellSysBrowseDialog1: TLMDShellSysBrowseDialog
    OwnerHandle = pwApplication
    RootFolder = 'sfMyComputer'
    Options = [boExpandDomains, boEnableOk, boNewGUI]
    Left = 668
    Top = 277
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 801
    Top = 268
  end
  object MainMenu1: TMainMenu
    Left = 838
    Top = 421
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
  end
  object Timer2: TTimer
    Interval = 500
    OnTimer = Timer2Timer
    Left = 807
    Top = 447
  end
end
