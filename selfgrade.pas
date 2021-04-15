unit SelfGrade;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  StdCtrls, ExtCtrls, Grids, ComCtrls;

type

  { TFormSelfGrade }

  TFormSelfGrade = class(TForm)
    BAJSSettings: TButton;
    BClear: TBitBtn;
    BClearPage3: TButton;
    BEndGrad: TButton;
    BContinue: TButton;
    BLdPage3: TButton;
    BLoadCSV: TBitBtn;
    BNextStudent: TButton;
    BOpenCSV: TButton;
    BQuit: TBitBtn;
    BSaveCSV: TBitBtn;
    BClear012: TButton;
    BSelFnam: TButton;
    BStartGrad: TBitBtn;
    BLoadSelectedStud: TButton;
    BFind: TButton;
    Button1: TButton;
    BFix3: TButton;
    CBAutoSave: TCheckBox;
    CBGradeNext: TCheckBox;
    CBSelfGradingRunning: TCheckBox;
    CBOnTop: TCheckBox;
    LabelCurGradeDir: TLabel;
    LabelFileName: TLabel;
    LabelGradLine: TLabel;
    MemoSGLog: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    SGSelfGrade: TStringGrid;
    StatusBar: TStatusBar;
    Timer1: TTimer;
    procedure BClearPage3Click(Sender: TObject);
    procedure BContinueClick(Sender: TObject);
    procedure BEndedGradingClick(Sender: TObject);
    procedure BFindClick(Sender: TObject);
    procedure BFix3Click(Sender: TObject);
    procedure BLoadCSVClick(Sender: TObject);
    procedure BLoadSelectedStudClick(Sender: TObject);
    procedure BNextStudentClick(Sender: TObject);
    procedure BOpenCSVClick(Sender: TObject);
    procedure BSelFnamClick(Sender: TObject);
    procedure BStartGradClick(Sender: TObject);
    procedure BClearClick(Sender: TObject);
    procedure BLdPage3Click(Sender: TObject);
    procedure BClear012Click(Sender: TObject);
    procedure BQuitClick(Sender: TObject);
    procedure BSaveCSVClick(Sender: TObject);
    procedure BAJSSettingsClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CBOnTopChange(Sender: TObject);
    procedure SGSelfGradeSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
    procedure Timer1Timer(Sender: TObject);
    procedure Log(const LogText: string);
  private

  public

    //GradingRunning : Boolean;  -- Obsolete, use CBSelfGradingRunning

  end;

var
  FormSelfGrade: TFormSelfGrade;
  procedure StartGradingGr7;

implementation

uses ProjManage, G7Draw, main, StructuredTextUtils, LCLIntf, strutils, math;

{$R *.lfm}

{ TFormSelfGrade }

const
  _GRADECSV   = 'SelfGrade.csv';
  _GRADECODE  = 'SelfGradeCodePage3.xml.FA5';

var
  StartGradingTime : TDateTime;


function GetGradeCSVFileName() : string;
begin
  result := FormSelfGrade.SelectDirectoryDialog.FileName + '\' + _GRADECSV;
end;

function GetGradeCodeFileName() : string;
begin
  result := FormSelfGrade.SelectDirectoryDialog.FileName + '\' + _GRADECODE;
end;

procedure UpdateCaptionAndStatusBar();
begin
  FormSelfGrade.Caption :=  FormSelfGrade.LabelGradLine.Caption +
         ' SelfGrade - ' + FormSelfGrade.SelectDirectoryDialog.FileName;
  FormSelfGrade.StatusBar.Panels[0].Text :=
          FormSelfGrade.LabelGradLine.Caption + ' =>' + ExtractFileNameWithoutExt(Project.FileName);
end;

procedure TFormSelfGrade.BQuitClick(Sender: TObject);
begin
  BSaveCSVClick(Sender);
  Project.Modified := False;  // Hack to quit directly without dialog
  FMain.Close;
end;

procedure TFormSelfGrade.BSaveCSVClick(Sender: TObject);
begin
  //MemoSelfGrade.Lines.SaveToFile(extractFilePath(Project.FileName)+GRADECSV);
  SGSelfGrade.SaveToCSVFile(GetGradeCSVFileName());
  UpdateCaptionAndStatusBar();
end;

procedure TFormSelfGrade.BAJSSettingsClick(Sender: TObject);
var dummy : boolean;
begin
  //Project.FileName := 'C:\ajs\Sist_e_Autom_2017_18\Avalia\ut1';
  Project.FileName := 'C:\ajs\Sist_e_Autom_2017_18\Avalia\MT2';
  SelectDirectoryDialog.FileName   := Project.FileName;
  SelectDirectoryDialog.InitialDir :=   SelectDirectoryDialog.FileName ;
  BSelFnamClick(nil);
  //ProjectOpen(GetGradeCodeFileName());
  ProjectNew;
  Dummy := true;
  SGSelfGradeSelectCell(Sender,1,1,dummy);
  //SGSelfGrade.Row := 16;
  //SGSelfGrade.Col := 1;
  //ProjectOpen(SGSelfGrade.Cells[1,16]);
  BClearPage3Click(nil);
  BLdPage3Click(nil);
  UpdateCaptionAndStatusBar();
end;

procedure TFormSelfGrade.Button1Click(Sender: TObject);
begin
  ProjectSaveFA5(GetGradeCodeFileName());
  Log('Saved '+GetGradeCodeFileName());
end;

procedure TFormSelfGrade.CBOnTopChange(Sender: TObject);
begin
  if CBOnTop.Checked then
    FormSelfGrade.FormStyle := fsSystemStayOnTop
  else
    FormSelfGrade.FormStyle := fsNormal;
end;



procedure TFormSelfGrade.SGSelfGradeSelectCell(Sender: TObject; aCol,
  aRow: Integer; var CanSelect: Boolean);
begin
  if CBSelfGradingRunning.Checked then exit;
  LabelGradLine.Caption := IntToStr(aRow);
  LabelFileName.Caption := SGSelfGrade.Cells[1,aRow];
  UpdateCaptionAndStatusBar();
end;


var FlagReallyAutoGradeNext : Boolean;

procedure TFormSelfGrade.Timer1Timer(Sender: TObject);
var grid_li : integer;
begin
  if CBSelfGradingRunning.Checked and (PLCState.SysWords[127]>0) then begin
    Application.ProcessMessages;
    BEndedGradingClick(nil);
    Log('---Grading AutoEnded SW127='+IntToStr(PLCState.SysWords[127]));
    Application.ProcessMessages;
    FormSelfGrade.BringToFront;
    if CBGradeNext.Checked then
                           FlagReallyAutoGradeNext:=True;
    UpdateCaptionAndStatusBar();
    Application.ProcessMessages;
    PLCState.SysWords[127] := 0;
    exit;
  end;

  if FlagReallyAutoGradeNext then begin
    FlagReallyAutoGradeNext:=False;
    Application.ProcessMessages;
    try
      grid_li := StrToInt(LabelGradLine.Caption)+1;
      if grid_li > SGSelfGrade.RowCount-1 then begin
        Log('Stopping Auto Grade next... last line reached... '+LabelGradLine.Caption);
        CBGradeNext.Checked := False;
      end else begin
        LabelGradLine.Caption := IntToStr(grid_li);
        Application.ProcessMessages;
        BStartGradClick(nil);
      end;
    except
      Log('Auto Grade Next Exception'+LabelGradLine.Caption);
      CBGradeNext.Checked := False;
    end;
    Application.ProcessMessages;
    UpdateCaptionAndStatusBar();
  end;
end;


procedure TFormSelfGrade.BClearClick(Sender: TObject);
var
  i : integer;
begin
  SGSelfGrade.Clear;
  MemoSGLog.Clear;
  SGSelfGrade.ColCount   := 128-50+8;
  SGSelfGrade.RowCount   := 1;
  SGSelfGrade.FixedCols  := 1;
  SGSelfGrade.Cells[0,0] := '#';
  SGSelfGrade.Cells[1,0] := 'FNam';
  SGSelfGrade.Cells[2,0] := 'St Tim';
  SGSelfGrade.Cells[3,0] := 'End Tim';
  SGSelfGrade.Cells[4,0] := 'Stud_N';
  SGSelfGrade.Cells[5,0] := 'HLink';
  SGSelfGrade.Cells[6,0] := 'Proj Dat';
  SGSelfGrade.Cells[7,0] := ' ~SW~ ';
  for i := 50 to High(PLCState.SysWords) do begin
     SGSelfGrade.Cells[8+i-50,0]:='' + IntToStr(i) ;
  end;
end;

procedure TFormSelfGrade.BLdPage3Click(Sender: TObject);
var temp : integer;
  s : string;
begin

  Log('Load '+GetGradeCodeFileName());

  if FileExists(GetGradeCodeFileName()) then begin
    temp := FormG7.DeleteObjectsInPage(3);
    if temp>0 then  Log('Warning!!!! Deleted '+IntToStr(temp)+' objects');
    s := project.FileName;
    ProjectOpenFA5(GetGradeCodeFileName(), True);
    //if copy(Project.FileName,1,4)<>'_SG_' then Project.FileName := '_SG_'+s; // Keep FileName
  end else begin
    ShowMessage('File '+GetGradeCodeFileName()+' Does NOT exist');
  end;
  UpdateCaptionAndStatusBar();
end;


procedure TFormSelfGrade.BClear012Click(Sender: TObject);
begin
  FormG7.DeleteObjectsInPage(0);
  FormG7.DeleteObjectsInPage(1);
  FormG7.DeleteObjectsInPage(2);
  Log('Deleted Pages 0, 1 and 2 ');
end;


procedure StartGradingGr7;
var li : integer; fn : string;
begin
  FormSelfGrade.Log('---BEGIN '+ resourceVersionInfo() +' Grading Ln='+FormSelfGrade.LabelGradLine.Caption);
  FormG7.MenuStartQAtPg2.Checked := true;
  FormSelfGrade.CBSelfGradingRunning.Checked:=True;
  li := StrToIntDef(FormSelfGrade.LabelGradLine.Caption,-1);
  if li < 1 then begin
    ShowMessage('Self Grade Error #1 - invalid line');
    FormSelfGrade.CBSelfGradingRunning.Checked:=False;
    exit;
  end;
  fn:='';
  try
    fn:=FormSelfGrade.SGSelfGrade.Cells[1,Li];
  finally
  end;
  if fn='' then begin
    ShowMessageOrLog('Self Grade Error #2 - exception empty filename');
    FormSelfGrade.CBSelfGradingRunning.Checked:=False;
    exit;
  end;

  ProjectNew();
  StartGradingTime := now();
  FormSelfGrade.SGSelfGrade.Cells[2,Li] := DateTimeToStr(StartGradingTime);

  if not ProjectOpen(FormSelfGrade.SelectDirectoryDialog.FileName+'\'+fn) then begin
    StartGradingTime := 0;
    FormSelfGrade.CBSelfGradingRunning.Checked := false;
    FormG7.BBStop_GR7Click(nil);   // Extra Safety Measure
    //Application.ProcessMessages();
    ShowMessageOrLog('Self Grade  Error #4 - error opening project'+crlf+FormSelfGrade.SelectDirectoryDialog.FileName+'\'+fn);
    //Application.ProcessMessages();
    exit;
  end else begin
    FormSelfGrade.Log('Really Start FA '+resourceVersionInfo()+' Grading '+fn);
    //Application.ProcessMessages;
    FormSelfGrade.BLdPage3Click(nil);
    FormSelfGrade.Caption := FormSelfGrade.LabelGradLine.Caption+' - ' + fn;
    //Application.ProcessMessages;
    FormSelfGrade.BLdPage3Click(nil);

    //FormSelfGrade.CBSelfGradingRunning.checked := FormG7.BBStop_GR7.Enabled;
    FormSelfGrade.CBSelfGradingRunning.checked := True;
    FormG7.BIniRunClick(nil);  // Carefull: Grade with IniRunButton
    Application.ProcessMessages;
    if (not FormG7.BBStop_GR7.Enabled) then begin
      try
        if (FMain.LBErrors.Items.Count>0) then
          FormSelfGrade.Log('First Error: '+FMain.LBErrors.Items[0])
        else
          FormSelfGrade.Log('Unspecific error in load or start running...');
      finally
      end;
      ShowMessageOrLog('Self Grade Error #5 - Does not run...');
      PLCState.SysWords[127]:=666;
      //FormSelfGrade.BEndedGradingClick(nil);
    end;
  end;
end;




procedure TFormSelfGrade.BStartGradClick(Sender: TObject);
begin
  StartGradingGr7;
end;

procedure TFormSelfGrade.BEndedGradingClick(Sender: TObject);
var
    ThisAge : Longint;
    aCol, aRow , i : integer;
    s : string;
begin
  CBSelfGradingRunning.Checked := False;
  FormG7.BBStop_GR7Click(nil);
  //Application.ProcessMessages;

  aRow := StrToIntDef(LabelGradLine.Caption,-1);
  if aRow<0 then begin ShowMessage('Row<0'); exit; end;

  aCol:=3;
  SGSelfGrade.Cells[aCol,aRow] := DateTimeToStr(Now);                inc(aCol);
  SGSelfGrade.Cells[aCol,aRow] := G7Draw.GetStudentNumbers();        inc(aCol);
  SGSelfGrade.Cells[aCol,aRow] := '=hyperlink("'+project.FileName + '")';   inc(aCol);
  try
    ThisAge := FileAge(project.FileName);
    SGSelfGrade.Cells[aCol,aRow] := DateTimeToStr(FileDateToDateTime(ThisAge));
  finally
  end;
  inc(aCol);
  SGSelfGrade.Cells[aCol,aRow] := 'Log:';                                inc(aCol);

  for i := 50 to High(PLCState.SysWords) do begin
    SGSelfGrade.Cells[aCol+i-50,aRow] := IntToStr(PLCState.SysWords[i]) ;
  end;

  // Save the Log texto to StringGrid col 7
  s:='';
  for i:=MemoSGLog.Lines.Count-1 downto 0 do begin
    if copy(MemoSGLog.Lines[i],1,8)='---BEGIN' then break;
    s := MemoSGLog.Lines[i] + '| ' + s;
  end;
  SGSelfGrade.Cells[7,aRow]:=s;

  Application.ProcessMessages;
  FormSelfGrade.BringToFront;
  Application.ProcessMessages;
  if CBAutoSave.Checked then BSaveCSVClick(nil);
end;

var PersistentFindString : string;

procedure TFormSelfGrade.BFindClick(Sender: TObject);
var
  i : integer;
  dummy : boolean;
begin
  if not InputQuery('', 'Text to find BELOW CURSOR (case insensitive + wildcards ? *)', PersistentFindString) then exit;
  for i := StrToIntDef(LabelFileName.Caption,1) to SGSelfGrade.RowCount-1 do begin
    if IsWild(SGSelfGrade.Cells[1,i],PersistentFindString,True) then begin
      dummy:=true;
      SGSelfGradeSelectCell(Sender,1,i,dummy);
      SGSelfGrade.Row := i;
      SGSelfGrade.Col := 1;
      SGSelfGrade.SetFocus;
      exit;
    end;
  end;
end;

procedure TFormSelfGrade.BFix3Click(Sender: TObject);
var n : integer;
begin
  n := SpecialSGFixAllG7Obj();
  Log('Found '+IntToStr(n)+' objects');
end;


procedure TFormSelfGrade.BLoadCSVClick(Sender: TObject);
begin
  SGSelfGrade.LoadFromCSVFile(GetGradeCSVFileName());
end;

procedure TFormSelfGrade.BLoadSelectedStudClick(Sender: TObject);
var fn : string;
begin
  fn:=SGSelfGrade.Cells[1,StrToInt(LabelGradLine.Caption)];
  ProjectOpen(FormSelfGrade.SelectDirectoryDialog.FileName+'\'+fn);
end;

procedure TFormSelfGrade.BNextStudentClick(Sender: TObject);
var ln : integer;
var dummy : boolean;
begin
  dummy := true;
  ln := min(StrToIntDef(LabelGradLine.Caption,1)+1,SGSelfGrade.RowCount-1);
  SGSelfGradeSelectCell(Sender,1,ln,dummy);
  SGSelfGrade.Row := ln;
  SGSelfGrade.Col := 1;
  SGSelfGrade.SetFocus;
  Application.ProcessMessages;
  BLoadSelectedStudClick(nil);
end;

procedure TFormSelfGrade.BOpenCSVClick(Sender: TObject);
begin
  OpenDocument(GetGradeCSVFileName());
end;

procedure TFormSelfGrade.Log(const LogText : string);
begin
  MemoSGLog.Append(LogText);
end;


procedure TFormSelfGrade.BSelFnamClick(Sender: TObject);
var
  sl: TStringList;
  i: Integer;
begin
  BClearClick(nil);
  if (sender<>nil) then begin
    SelectDirectoryDialog.InitialDir := extractFilePath(Project.FileName);
    if not SelectDirectoryDialog.Execute then exit;
  end;
  //https://www.tweaking4all.com/forum/delphi-lazarus-free-pascal/lazarus-find-all-files-in-a-directory-and-subdirectories-matching-criteria/
  sl := FindAllFiles(SelectDirectoryDialog.FileName, '*.FA5', True,faAnyFile);

  for i:=0 to sl.Count-1 do begin
    if LowerCase(ExtractFileName(sl.Strings[i])) = Lowercase(_GRADECODE) then begin
      sl.Delete(i);
      break;
    end;
  end;

  SGSelfGrade.RowCount := sl.Count+1;
  try
    SGSelfGrade.Cells[0,0] := '#=' + IntToStr(sl.Count);
    for i:=0 to sl.Count-1 do begin
      SGSelfGrade.Cells[0,i+1] := IntToStr(i+1);
      //SGSelfGrade.Cells[1,i+1] := ExtractFileName(sl.Strings[i]);
      SGSelfGrade.Cells[1,i+1] := copy(sl.Strings[i],Length(SelectDirectoryDialog.FileName)+2,999);
    end;
  finally
    sl.Free;
  end;

  UpdateCaptionAndStatusBar();
  Log('SelfGrad' + SelectDirectoryDialog.FileName + '   |   ' + _GRADECODE + '   |   ' + _GRADECSV );
  LabelCurGradeDir.caption := SelectDirectoryDialog.FileName;
end;



procedure TFormSelfGrade.BClearPage3Click(Sender: TObject);
begin
  FormG7.DeleteObjectsInPage(3);
end;

procedure TFormSelfGrade.BContinueClick(Sender: TObject);
var
  i : integer;
  dummy : boolean;
begin
  for i := 1 to SGSelfGrade.RowCount-1 do begin
    if trim(SGSelfGrade.Cells[3,i])='' then begin
      dummy:=true;
      SGSelfGradeSelectCell(Sender,1,i, dummy);
      //SGSelfGrade.Row := 16;
      //SGSelfGrade.Col := 3;
      exit;
    end;
  end;
end;






begin
  PersistentFindString := 'Example: *Lu*s*Sousa*';
end.

