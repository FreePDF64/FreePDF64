object Suche_Info: TSuche_Info
  Left = 0
  Top = 0
  Margins.Left = 8
  Margins.Top = 8
  Margins.Right = 8
  Margins.Bottom = 8
  BorderIcons = [biSystemMenu]
  Caption = 'Hilfe zum Suchefenster'
  ClientHeight = 1077
  ClientWidth = 1355
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -30
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 240
  TextHeight = 41
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 1355
    Height = 1005
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alClient
    Color = clBtnFace
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
    ExplicitLeft = 400
    ExplicitTop = 60
    ExplicitWidth = 185
    ExplicitHeight = 90
  end
  object Button1: TButton
    Left = 0
    Top = 1005
    Width = 1355
    Height = 72
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alBottom
    Caption = 'Schlie'#223'en'
    TabOrder = 1
    OnClick = Button1Click
    ExplicitWidth = 1407
  end
end
