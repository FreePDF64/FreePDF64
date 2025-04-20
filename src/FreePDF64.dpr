program FreePDF64;

{$R *.dres}

uses
  Vcl.Forms,
  FreePDF64_Unit in 'FreePDF64_Unit.pas' {FreePDF64_Form},
  Vcl.Themes,
  Vcl.Styles,
  LMDShConsts in 'LMDShConsts.pas',
  DokuInfo_Unit in 'DokuInfo_Unit.pas' {DokuInfo_Form},
  Einstellungen_Unit in 'Einstellungen_Unit.pas' {Einstellungen_Form},
  Encrypt_Unit in 'Encrypt_Unit.pas' {Encrypt_Form},
  Seiten_Unit in 'Seiten_Unit.pas' {Seiten_Form},
  Favoriten_Unit in 'Favoriten_Unit.pas' {Favoriten_Form},
  Info_Unit in 'Info_Unit.pas' {Info_Form},
  FreePDF64_Notify_Unit in 'FreePDF64_Notify_Unit.pas' {FreePDF64_Notify},
  Einstellungen_Hilfe_Unit in 'Einstellungen_Hilfe_Unit.pas' {Einstellungen_Hilfe_Form},
  Favoriten2_Unit in 'Favoriten2_Unit.pas' {Favoriten2_Form},
  Filter_Unit in 'Filter_Unit.pas' {Filter_Form},
  Wasserzeichen_Unit in 'Wasserzeichen_Unit.pas' {Wasserzeichen_Form},
  EineInstanz_Unit in 'EineInstanz_Unit.pas',
  Zusatz_Unit in 'Zusatz_Unit.pas' {Zusatz_Form},
  Splashscreen_Unit in 'Splashscreen_Unit.pas' {Splashscreen_Form},
  Dateianlage_Unit in 'Dateianlage_Unit.pas' {Dateianlage_Form},
  Status_Unit in 'Status_Unit.pas' {Status_Form},
  Auswahl_Unit in 'Auswahl_Unit.pas' {Auswahl_Form},
  Suchen in 'Suchen.pas' {Suche_Form};

{$R *.RES}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'FreePDF64';
  Application.CreateForm(TFreePDF64_Form, FreePDF64_Form);
  Application.CreateForm(TEinstellungen_Form, Einstellungen_Form);
  Application.CreateForm(TAuswahl_Form, Auswahl_Form);
  Application.CreateForm(TEncrypt_Form, Encrypt_Form);
  Application.CreateForm(TDokuInfo_Form, DokuInfo_Form);
  Application.CreateForm(TSeiten_Form, Seiten_Form);
  Application.CreateForm(TFavoriten_Form, Favoriten_Form);
  Application.CreateForm(TInfo_Form, Info_Form);
  Application.CreateForm(TFreePDF64_Notify, FreePDF64_Notify);
  Application.CreateForm(TEinstellungen_Hilfe_Form, Einstellungen_Hilfe_Form);
  Application.CreateForm(TFavoriten2_Form, Favoriten2_Form);
  Application.CreateForm(TFilter_Form, Filter_Form);
  Application.CreateForm(TWasserzeichen_Form, Wasserzeichen_Form);
  Application.CreateForm(TZusatz_Form, Zusatz_Form);
  Application.CreateForm(TSplashscreen_Form, Splashscreen_Form);
  Application.CreateForm(TDateianlage_Form, Dateianlage_Form);
  Application.CreateForm(TStatus_Form, Status_Form);
  Application.CreateForm(TSuche_Form, Suche_Form);
  Application.CreateForm(TAuswahl_Form, Auswahl_Form);
  Application.CreateForm(TSuche_Form, Suche_Form);
  Application.Run;
end.

