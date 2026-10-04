object Anleitung_Form: TAnleitung_Form
  Left = 0
  Top = 0
  Margins.Left = 8
  Margins.Top = 8
  Margins.Right = 8
  Margins.Bottom = 8
  BorderIcons = [biSystemMenu]
  Caption = 'FreePDF64 '#8211' Funktionen'
  ClientHeight = 1112
  ClientWidth = 1407
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -30
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 240
  TextHeight = 41
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 1407
    Height = 1040
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alClient
    Color = clBtnFace
    Lines.Strings = (
      'Memo1')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object Button1: TButton
    Left = 0
    Top = 1040
    Width = 1407
    Height = 72
    Margins.Left = 8
    Margins.Top = 8
    Margins.Right = 8
    Margins.Bottom = 8
    Align = alBottom
    Caption = 'Schlie'#223'en'
    TabOrder = 1
    OnClick = Button1Click
  end
end
