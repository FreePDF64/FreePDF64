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
  IDSHELL_ErrShVersion                 = 'Diese Operation wird in dieser Version nicht unterst�tzt.';
  IDSHELL_ErrInvalidFolder             = 'Ung�ltiger Ordner';

  IDSHELL_OK                    = 'Ok';
  IDShell_About                 = '�ber';
  IDSHELL_CANCEL                = 'Abbrechen';

  IDSHELL_ColumnName            = 'Name';
  IDSHELL_ColumnSize            = 'Gr��e';
  IDSHELL_ColumnType            = 'Typ';
  IDSHELL_ColumnAttr            = 'Attribute';
  IDSHELL_ColumnCreateDate      = 'Erstellt am';
  IDSHELL_ColumnCreateTime      = 'Erstellt um';
  IDSHELL_ColumnAccessDate      = 'Letzter Zugriff am';
  IDSHELL_ColumnAccessTime      = 'Letzter Zugriff um';
  IDSHELL_ColumnWriteDate       = 'Ge�ndert am';
  IDSHELL_ColumnWriteTime       = 'Ge�ndert um';
  IDSHELL_ColumnModified        = 'Ge�ndert';
  sBrowseForFolder              = 'Verzeichnis ausw�hlen';
  sBrowseInstruction            = 'Bitte w�hlen Sie ein Verzeichnis aus';
  sDeleteFolderHint             = 'Ausgew�hlten Ordner l�schen.';
  sCreateFolderHint             = 'Neuen Ordner erstellen.';
  sNewFolderName                = 'Neuer Ordner';
  sDuplicatedPath               = 'Pfad bereits in der Liste enthalten!';
  sPickRootPath                 = 'Bitte einen Wurzelpfad bestimmen';
  sEditRoot                     = 'Pfa&d �ndern';
  sPathCaption                  = 'Verzeichnisse';
  sEmpty                        = '(Leer)';

  // LMDSHListDlg
  IDSHELL_SELECTDETAILS         = 'Details ausw�hlen:';
  IDSHELL_DEFAULTCOLUMNS        = 'Standardeinstellungen verwenden';
  IDSHELL_BUTTONUP              = 'Nach oben';
  IDSHELL_BUTTONDOWN            = 'Nach unten';
  IDSHELL_WIDTHCAPTION          = 'Breite der ausgew�hlten Spalte (in Pixel):';
  IDSHELL_COLINSTRUCTION        = 'W�hlen Sie Details aus, die f�r Dateien in diesem Ordner angezeigt werden sollen.';
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
  IDSHELL_OPENWITH              = '�ffnen mit...';
  IDSHELL_OPEN                  = '�ffnen';
  IDSHELL_CREATEFOLDER          = 'Neuer Ordner';
  IDSHELL_RUN                   = 'Ausf�hren';
  IDSHELL_MAILTO                = 'Senden...';
  IDSHELL_BACKWARD              = 'Zur�ck';
  IDSHELL_FORWARD               = 'Vorw�rts';
  IDSHELL_UPLEVEL               = 'Aufw�rts';
  IDSHELL_CUT                   = 'Ausschneiden';
  IDSHELL_COPY                  = 'Kopieren';
  IDSHELL_PASTE                 = 'Einf�gen';
  IDSHELL_DELETE                = 'L�schen';
  IDSHELL_SELECTALL             = 'Alles markieren';
  IDSHELL_INVERTSELECTION       = 'Invert Selection';
  IDSHELL_OPENDOSWINDOW         = 'Dos-Fenster �ffnen';
  IDSHELL_FINDFILES             = 'Datei(en) suchen...';
  IDSHELL_FINDCOMPUTER          = 'Computer suchen...';
  IDSHELL_FORMATDISK            = 'Diskette formatieren...';
  IDSHELL_SELECTDISKFORMAT      = 'Bitte Disk f�r Formatieren ausw�hlen';
  IDSHELL_COPYDISK              = 'Disk kopieren...';
  IDSHELL_MAPDRIVE              = 'Laufwerk verbinden...';
  IDSHELL_UNMAPDRIVE            = 'Laufwerk trennen...';
  IDSHELL_EDITDISKLABEL         = 'Disk umbenennen ...';
  IDSHELL_SELECTDISKLABEL       = 'Bitte Disk ausw�hlen, die umbenannt werden soll';
  IDSHELL_FILTER                = 'Filter...';
  IDSHELL_COPYFILENAMEASTEXT    = 'Kopiere Dateiname als Text';
  IDSHELL_COPYPATHNAMEASTEXT    = 'Kopiere Dateipfad als Text';
  IDSHELL_VIEW                  = 'Ansicht';

implementation


end.
