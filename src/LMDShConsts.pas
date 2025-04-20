unit LMDShConsts;
{###############################################################################

LMDShConsts unit (DS)
------------------------
Contains ShellPack constants


Changes
-------
Release 4.0 (September 2006)
 - Initial Release

###############################################################################}

interface
resourcestring
  // error messages
  IDSHELL_ErrShVersion                 = 'Diese Operation wird in dieser Version nicht unterstützt.';
  IDSHELL_ErrInvalidFolder             = 'Ungültiger Ordner';

  IDSHELL_OK                    = 'Ok';
  IDShell_About                 = 'Über';
  IDSHELL_CANCEL                = 'Abbrechen';

  IDSHELL_ColumnName            = 'Name';
  IDSHELL_ColumnSize            = 'Größe';
  IDSHELL_ColumnType            = 'Typ';
  IDSHELL_ColumnAttr            = 'Attribute';
  IDSHELL_ColumnCreateDate      = 'Erstellt am';
  IDSHELL_ColumnCreateTime      = 'Erstellt um';
  IDSHELL_ColumnAccessDate      = 'Letzter Zugriff am';
  IDSHELL_ColumnAccessTime      = 'Letzter Zugriff um';
  IDSHELL_ColumnWriteDate       = 'Geändert am';
  IDSHELL_ColumnWriteTime       = 'Geändert um';
  IDSHELL_ColumnModified        = 'Geändert';
  sBrowseForFolder              = 'Verzeichnis auswählen';
  sBrowseInstruction            = 'Bitte wählen Sie ein Verzeichnis aus';
  sDeleteFolderHint             = 'Ausgewählten Ordner löschen.';
  sCreateFolderHint             = 'Neuen Ordner erstellen.';
  sNewFolderName                = 'Neuer Ordner';
  sDuplicatedPath               = 'Pfad bereits in der Liste enthalten!';
  sPickRootPath                 = 'Bitte einen Wurzelpfad bestimmen';
  sEditRoot                     = 'Pfa&d ändern';
  sPathCaption                  = 'Verzeichnisse';
  sEmpty                        = '(Leer)';

  // LMDSHListDlg
  IDSHELL_SELECTDETAILS         = 'Details auswählen:';
  IDSHELL_DEFAULTCOLUMNS        = 'Standardeinstellungen verwenden';
  IDSHELL_BUTTONUP              = 'Nach oben';
  IDSHELL_BUTTONDOWN            = 'Nach unten';
  IDSHELL_WIDTHCAPTION          = 'Breite der ausgewählten Spalte (in Pixel):';
  IDSHELL_COLINSTRUCTION        = 'Wählen Sie Details aus, die für Dateien in diesem Ordner angezeigt werden sollen.';
  IDSHELL_HIDE                  = 'Ausblenden';
  IDSHELL_DISPLAY               = 'Anzeigen';

  // Filter Dialog
  IDSHELL_SpecifyFilter         = 'Dateifilter festlegen...';
  IDSHELL_FilterInstruction     = 'Filter werden durch Semikolons getrennt.';
  IDSHELL_FilterOptions         = 'Filter ausschalten'#13'Nur Dateien'#13'Dateien und Ordner';
  IDSHELL_Filters               = 'Dateifilter';
  IDSHELL_ApplyFilter           = 'Dateifilter anwenden auf...';

  IDSHELL_COPYTO                = 'Kopieren nach...';
  IDSHELL_COPYTOINST            = 'Auf den Ordner klicken, in den die Datei(en) kopierten werden sollen.';
  IDSHELL_MOVETO                = 'Verschieben nach...';
  IDSHELL_MOVETOINST            = 'Auf den Ordner klicken, in den die Datei(en) verschoben werden sollen.';
  IDSHELL_SHOWPROPERTIES        = 'Eigenschaften';
  IDSHELL_RENAME                = 'Umbenennen';
  IDSHELL_OPENWITH              = 'Öffnen mit...';
  IDSHELL_OPEN                  = 'Öffnen';
  IDSHELL_CREATEFOLDER          = 'Neuer Ordner';
  IDSHELL_RUN                   = 'Ausführen';
  IDSHELL_MAILTO                = 'Senden...';
  IDSHELL_BACKWARD              = 'Zurück';
  IDSHELL_FORWARD               = 'Vorwärts';
  IDSHELL_UPLEVEL               = 'Aufwärts';
  IDSHELL_CUT                   = 'Ausschneiden';
  IDSHELL_COPY                  = 'Kopieren';
  IDSHELL_PASTE                 = 'Einfügen';
  IDSHELL_DELETE                = 'Löschen';
  IDSHELL_SELECTALL             = 'Alles markieren';
  IDSHELL_INVERTSELECTION       = 'Invert Selection';
  IDSHELL_OPENDOSWINDOW         = 'Dos-Fenster öffnen';
  IDSHELL_FINDFILES             = 'Datei(en) suchen...';
  IDSHELL_FINDCOMPUTER          = 'Computer suchen...';
  IDSHELL_FORMATDISK            = 'Diskette formatieren...';
  IDSHELL_SELECTDISKFORMAT      = 'Bitte Disk für Formatieren auswählen';
  IDSHELL_COPYDISK              = 'Disk kopieren...';
  IDSHELL_MAPDRIVE              = 'Laufwerk verbinden...';
  IDSHELL_UNMAPDRIVE            = 'Laufwerk trennen...';
  IDSHELL_EDITDISKLABEL         = 'Disk umbenennen ...';
  IDSHELL_SELECTDISKLABEL       = 'Bitte Disk auswählen, die umbenannt werden soll';
  IDSHELL_FILTER                = 'Filter...';
  IDSHELL_COPYFILENAMEASTEXT    = 'Kopiere Dateiname als Text';
  IDSHELL_COPYPATHNAMEASTEXT    = 'Kopiere Dateipfad als Text';
  IDSHELL_VIEW                  = 'Ansicht';

implementation


end.
