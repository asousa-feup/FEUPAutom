program FeupAutom;

//{$MODE Delphi}
{$mode objfpc}{$H+}

uses
  Forms, Interfaces,Controls,
  SysUtils,
  main in 'main.pas' {FMain},
  Variables in 'Variables.pas' {FVariables},
  StructuredTextUtils in 'StructuredTextUtils.pas',
  IOLeds in 'IOLeds.pas' {FIOLeds},
  structuredtext2pas in 'structuredtext2pas.pas',
  MMTimer in 'MMTimer.pas',
  WMCopyData in 'WMCopyData.pas',
  ProjManage in 'ProjManage.pas',
  Logger in 'Logger.pas' {FLog},
  splash in 'splash.pas' {FormSplash},
  G7Draw in 'G7Draw.pas' {FormG7},
  //G7Editor in 'G7Editor.pas' {FG7Editor},
  Pas2C in 'Pas2C.pas',
  SelfGrade in 'SelfGrade.pas';

{$R *.res}

begin
  DecimalSeparator:='.';
  Application.Scaled:=True;
  Application.HintHidePause := 10000;
  Application.Initialize;
  Application.Title := 'FEUPAutom';
  Application.ProcessMessages;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFVariables, FVariables);
  Application.CreateForm(TFormSplash, FormSplash);
  Application.CreateForm(TFIOLeds, FIOLeds);
  Application.CreateForm(TFLog, FLog);
  Application.CreateForm(TFormG7, FormG7);
  Application.CreateForm(TFormG7, FormViewG7);
  //Application.CreateForm(TFG7Editor, FG7Editor);
  Application.CreateForm(TFormSelfGrade, FormSelfGrade);
  //FormSplash.FormStyle := fsSystemStayOnTop;
  Application.Run;

end.
