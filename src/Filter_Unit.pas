unit Filter_Unit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TFilter_Form = class(TForm)
    FilterCB: TComboBox;
    Label1: TLabel;
    BitBtn1: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Filter_Form: TFilter_Form;

implementation

{$R *.dfm}

uses FreePDF64_Unit;

procedure TFilter_Form.BitBtn1Click(Sender: TObject);
begin
  // Keine doppelten Einträge zulassen...
  if FilterCB.Items.IndexOf(FilterCB.Text) = - 1 then
    FilterCB.Items.Add(FilterCB.Text);

  if Links then
  begin
    FreePDF64_Form.LMDShellList1.ItemIndex := - 1;
    FreePDF64_Form.LMDShellList1.FileFilter := FilterCB.Text;
    if FreePDF64_Form.LMDShellList1.FileFilter <> '*.*' then
    begin
      FreePDF64_Form.FilterTB.ImageIndex := 69;
      FreePDF64_Form.FilterTB.Hint := 'Dateifilter ist gesetzt!'
    end else
    begin
      FreePDF64_Form.FilterTB.ImageIndex := 68;
      FreePDF64_Form.FilterTB.Hint := 'Dateifilter festlegen';
    end;
  end else
  begin
    FreePDF64_Form.LMDShellList2.ItemIndex := - 1;
    FreePDF64_Form.LMDShellList2.FileFilter := FilterCB.Text;
    if FreePDF64_Form.LMDShellList2.FileFilter <> '*.*' then
    begin
      FreePDF64_Form.FilterTB.ImageIndex := 69;
      FreePDF64_Form.FilterTB.Hint := 'Dateifilter ist gesetzt!'
    end else
    begin
      FreePDF64_Form.FilterTB.ImageIndex := 68;
      FreePDF64_Form.FilterTB.Hint := 'Dateifilter festlegen';
    end;
  end;
end;

procedure TFilter_Form.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    Close;
end;

procedure TFilter_Form.FormShow(Sender: TObject);
begin
  FilterCB.Text := '*.*';
  FilterCB.SetFocus;
end;

end.
