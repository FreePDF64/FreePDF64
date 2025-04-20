object Einstellungen_Hilfe_Form: TEinstellungen_Hilfe_Form
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Hilfe zu den Einstellungen'
  ClientHeight = 813
  ClientWidth = 1052
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 17
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 1052
    Height = 813
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    BevelOuter = bvNone
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Segoe UI'
    Font.Style = []
    Lines.Strings = (
      ' Verschl'#252'sselung:'
      ' PDF-Dateien verschl'#252'sseln mit 128-Bit RC4/AES oder 256-Bit AES.'
      ''
      ' Schriftarten/F'#252'llmuster: '
      
        ' Gibt die Aufl'#246'sung (in dpi) der Schriftarten/F'#252'llmuster an, die' +
        ' konvertiert werden m'#252'ssen.'
      ''
      ' Formatauswahl:'
      ' - PS (Postscript) zu PDF, BMP, JPEG, PNG, TIFF, TXT.'
      
        ' - PDF zu PDF-verschl'#252'sselt, PS, BMP, JPEG, PNG, TIFF, TXT, DOCX' +
        '.'
      ' - TIFF (G6 - BW): G4 fax encoding, Schwarz/Weiss-Ausgabe.'
      
        ' - TIFF (LZW - BW): LZW-kompatibel, komprimierte Schwarz/Weiss-A' +
        'usgabe.'
      
        ' - TIFF (uncompressed): 24-bit RGB, unkomprimierte Ausgabe (8 bi' +
        'ts per component).'
      ' - BMP zu PDF.'
      ' - JPEG zu PDF. '
      ' - PNG zu PDF. '
      ' - TIFF zu PDF. '
      ''
      ' PDF-Metadaten (die sogenannten PDFMarks):'
      
        ' '#196'ndern von Titel, Verfasser, Thema, Schl'#252'sselw'#246'rter, Erstelldat' +
        'um, '#196'nderungsdatum, Anwendung.'
      ''
      ' Distiller Parameter:'
      
        ' - Default = mittelgro'#223'e PDFs, Acrobat 4 kompatibel (Farbe = 72 ' +
        'dpi, Graustufen = 72 dpi, S/W = 300 dpi).'
      
        ' - Screen Optimized = kleine PDFs, Acrobat 3 kompatibel (Farbe =' +
        ' 72 dpi, Graustufen = 72 dpi, S/W = 300 dpi).'
      
        ' - eBook = f'#252'r PDFs, die vorwiegend am Bildschirm gelesen werden' +
        '. Acrobat 4 kompatibel (Farbe = 150 dpi, Graustufen = 150 dpi, S' +
        '/W = 300 dpi).'
      
        ' - Printer Optimized = speziell f'#252'r die Druckerausgabe (= gute Q' +
        'ualit'#228't). Acrobat 4 kompatibel (Farbe = 300 dpi, Graustufen = 30' +
        '0 dpi, S/W = 1200 dpi).'
      
        ' - Prepress Optimized = speziell f'#252'r die Druckvorstufe (= h'#246'chst' +
        'e Qualit'#228't). Acrobat 4 kompatibel (Farbe = 300 dpi, Graustufen =' +
        ' 300 dpi, S/W = 1200 dpi).'
      ''
      ' Ausgabe:'
      ' DPI und Qualit'#228't f'#252'r BMP/JPEG/TIFF einstellen.'
      ''
      ' PDF-Kompatibilit'#228'tslevel:'
      
        ' Auswahl zwischen den verschiedenen Version PDF 1.4 bis PDF 1.7.' +
        ' Auch Kompatibilit'#228'tsstufe genannt.'
      ''
      ' Erstellen von PDF/A:'
      
        ' PDF/A-1b bis PDF/A-3b ist ein Dateiformat zur Langzeitarchivier' +
        'ung. Ziel des PDF/A-Standards ist, dass PDF-Dokumente erstellt w' +
        'erden k'#246'nnen, deren '
      ' visuelles Erscheinungsbild '#252'ber die Zeit erhalten bleibt.'
      
        ' PDF/A-1b - Konzentriert sich haupts'#228'chlich auf die Erhaltung de' +
        'r visuellen Darstellung eines Dokument.'
      
        ' PDF/A-2b - Enth'#228'lt mehrere Erg'#228'nzungen wie z.B. eine JPEG 2000-' +
        'Kompression, optionale Inhaltsebenen und PDF-Pakete. Integration' +
        ' von Dateianh'#228'ngen '
      ' m'#246'glich (sofern PDF/A-konform).'
      
        ' PDF/A-3b - Fast identisch mit PDF/A-2b. Der einzige Unterschied' +
        ' ist, dass er es erlaubt, beliebige Dateiformate in PDF/A-konfor' +
        'me Dateien zu integrieren.'
      ''
      ' Erstellen von PDF/X: '
      
        ' PDF/X-3 ist ein Dateiformat f'#252'r den Austausch digitaler Druckvo' +
        'rlagen.'
      
        ' PDF/X-4a soll dem Anspruch an einen m'#246'glichst medienneutralen A' +
        'ustausch gerecht werden.'
      ''
      ' Seiten automatisch drehen:'
      ' Nein, Alle oder Seite f'#252'r Seite.'
      ''
      ' Schnelle Webanzeige:'
      
        ' PDF-Datei wird optimiert f'#252'r schnelle Webanzeige. Beachte, dass' +
        ' die Konvertierung dadurch etwas langsamer ist und die PDF-Datei' +
        ' in der Regel etwas '
      
        ' gr'#246#223'er wird. Diese Option ist nicht mit der Erstellung einer ve' +
        'rschl'#252'sselten (passwortgesch'#252'tzten) PDF-Datei kompatibel.'
      ''
      ' Erstellte Datei(en) anzeigen:'
      
        ' PDF/PS/TXT/TIFF-Dateien werden direkt nach der Erstellung mit d' +
        'em zugewiesenen Anzeiger ge'#246'ffnet.'
      ''
      ' MHA -> Memo Height Addition:'
      
        ' Die Informationen (Metadaten, Verschl'#252'sselung, etc.) zu einer P' +
        'DF-Datei werden im unteren Anzeigefenster angezeigt. Diese Fenst' +
        'erh'#246'he l'#228#223't sich'
      ' hier anpassen. Der Standardwert ist: 80.'
      ''
      ' Vol. -> Systemklang nach Erstellung:'
      
        ' Als akustischer Hinweis wird ein Systemklang nach der Erstellun' +
        'g abgespielt. F'#252'r eigenen Sound einfach die beiden WAV-Dateien i' +
        'm Sounds-Verzeichnis '
      
        ' von FreePDF64 austauschen. Das Anpassen der Lautst'#228'rke des Syst' +
        'emklangs ist mit dem SpinEdit im Einstellunsgfenster m'#246'glich ode' +
        'r direkt in der '
      
        ' FreePDF64.ini: [Format] - [System Sound Volume 0-65535]. Wobei ' +
        #39'0'#39' Ton aus und '#39'65535'#39' Ton am lautesten bedeutet.'
      ''
      ' PDF-Datei(en) komprimieren:'
      
        ' Bei der Erstellung der PDF-Datei wird diese erst in eine Postsc' +
        'ript-Datei (PS) umgewandelt und von dort wieder in eine PDF-Date' +
        'i. Diese Prozedur '
      ' komprimiert die erstellte PDF-Datei meist um ein Vielfaches.'
      ''
      ' Seiten entnehmen:'
      
        ' Ausw'#228'hlen der Seiten, welche dann aus allen Formaten bei der Er' +
        'stellung entnommen werden.'
      ''
      ' Datei vorne/hinten anf'#252'gen:'
      
        ' Eine ausgew'#228'hlte Postscript- oder PDF-Datei als als erste und/o' +
        'der letzte Datei an die zu erstellende PDF-Datei anf'#252'gen. Geht n' +
        'ur bei Formatauswahl: PS '
      ' (Postscript)/PDF zu PDF.'
      ''
      ' Zeichenketten:'
      
        ' Entfernen von Zeichenketten aus den ermittelten Dateinamen beim' +
        ' Drucken in eine PDF-Datei. Beispiel: Beim Drucken aus z.B. Word' +
        ' in eine f'#252'r'
      
        ' FreePDF64 ben'#246'tigte Postscript-Datei, f'#228'ngt der Dateiname mit "' +
        'Microsoft Word - " an. Nun kann man hier diese Zeichenkette hint' +
        'erlegen und diese'
      
        ' wird dann bei der PDF-Erstellung entfernt - und es bleibt nur d' +
        'er gew'#252'nschte Dateiname '#252'brig.'
      ''
      ' '#220'berwachung:'
      
        ' Hier kann man ein '#220'berwachungsverzeichnis angeben, in welchem a' +
        'uf jede neu eingehende Datei '#252'berwacht wird (siehe dazu unter de' +
        'm Men'#252'punkt  '
      
        ' Hilfe - FreePDF64-HowTo und dort Abschnitt "Erstellen/Einrichte' +
        'n des FreePDF64-Druckers unter Windows"). Diese kann dann sofort' +
        ' automatisch in das '
      
        ' gew'#252'nschte Format erstellt werden. Des Weiteren kann die Einste' +
        'llung der Wartezeit bis zum Erstellvorgang angepa'#223't werden - fal' +
        'ls es zu '
      
        ' '#220'berschneidungen mit dem Druck ins Zielverzeichnis und dem ansc' +
        'hlie'#223'enden Beginn der Erstellung kommt.'
      ''
      
        ' HINWEIS bzgl. Entfernung des PDF-Passworts aus PDF-Dateien durc' +
        'h erneute PDF-Erstellung mit FreePDF64:'
      ' - 128-Bit RC4 verschl'#252'sselt, mit Berechtigungspasswort: GEHT'
      
        ' - 128-Bit RC4 verschl'#252'sselt, mit Passwort zum '#214'ffnen des Dokume' +
        'nts: GEHT NICHT'
      ' - 128-Bit AES verschl'#252'sselt, mit Berechtigungspasswort: GEHT'
      
        ' - 128-Bit AES verschl'#252'sselt, mit Passwort zum '#214'ffnen des Dokume' +
        'nts: GEHT NICHT'
      ' - 256-Bit AES verschl'#252'sselt, mit Berechtigungspasswort: GEHT'
      
        ' - 256-Bit AES verschl'#252'sselt, mit Passwort zum '#214'ffnen des Dokume' +
        'nts: GEHT'
      
        ' ===> Daf'#252'r sollte man am besten die Funktion "PDF-Passwortschut' +
        'z entfernen" (siehe in der Symbolleiste) nutzen!')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
    WantReturns = False
    OnKeyDown = Memo1KeyDown
    ExplicitWidth = 622
    ExplicitHeight = 429
  end
end
