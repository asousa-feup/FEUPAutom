unit Logger;
{$mode objfpc}{$H+}

interface

uses
  {$IFDEF Windows}
    Windows,
  {$ENDIF}
  //Messages,
  SysUtils, Variants, Classes, Controls, Forms, Graphics, Dialogs, ExtCtrls,
  StdCtrls, CheckLst, Grids, StructuredTextUtils, Spin, TAGraph, TASeries,
  TASources, TATools, TAStyles, TANavigation, TAIntervalSources, TAChartListbox  ;

type

  { TFLog }

  TFLog = class(TForm)
    ChartLog: TChart;
    ChartListbox1: TChartListbox;
    ChartLogLineSeries1: TLineSeries;
    ChartLogLineSeries10: TLineSeries;
    ChartLogLineSeries2: TLineSeries;
    ChartLogLineSeries3: TLineSeries;
    ChartLogLineSeries4: TLineSeries;
    ChartLogLineSeries5: TLineSeries;
    ChartLogLineSeries6: TLineSeries;
    ChartLogLineSeries7: TLineSeries;
    ChartLogLineSeries8: TLineSeries;
    ChartLogLineSeries9: TLineSeries;
    ChartStyles1: TChartStyles;
    ChartToolset1: TChartToolset;
    IntervalChartSource1: TIntervalChartSource;
    Label1: TLabel;
    Label2: TLabel;
    SpinStartTime: TSpinEdit;
    SpinEndTime: TSpinEdit;
    BClear: TButton;
    Export: TButton;
    BDraw: TButton;
    CLBSeries: TCheckListBox;
    CBTypes: TComboBox;
    SaveDialogExport: TSaveDialog;
    CBShowPercentNames: TCheckBox;
    LabelTooManyPoints: TLabel;
    CBLogTimers: TCheckBox;
    CBAutoDraw: TCheckBox;
    TimerAutoDraw: TTimer;
    procedure BDrawClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CBTypesChange(Sender: TObject);
    procedure CLBSeriesClickCheck(Sender: TObject);
    procedure BClearClick(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpinStartTimeChange(Sender: TObject);
    procedure SpinEndTimeChange(Sender: TObject);
    procedure CBShowPercentNamesClick(Sender: TObject);
    procedure CBAutoDrawClick(Sender: TObject);
    procedure TimerAutoDrawTimer(Sender: TObject);
  private
    { Private declarations }
    procedure FillCLBSeries;
    function GetRidOfTimerDot(const s:string) : string;
    function GetTimerDotSuffix(const s: string): string;
  public
    { Public declarations }
  end;

var  SeriesArray : array[0..9] of TLineSeries; // GLOBAL VAR !!!!!!!!!!!!!!

const
  MaxPLCHistory = {128; //} 10240;
  MaxPtCountPerSeries = 1024;

type PLCInteger = word; // SmallInt

type
  TPLCStateHist = record
    TimeStamp                         : DWord;
    InBits, OutBits, MemBits, SysBits : DWord;
    MemWords: array [0..MaxMemWords-1] of PLCInteger;
    SysWords: array [0..MaxSysWords-1] of PLCInteger;
    TimersQ : DWord;
    TimersV, TimersP: array [0..MaxTimers-1] of PLCInteger;
  end;

  TPLCStateHistArray = array [0..MaxPLCHistory] of TPLCStateHist;

var
  FLog: TFLog;
  PLCStateHist : TPLCStateHistArray;
  PLCHistStart, PLCHistSize, PLCHistFree  : integer;

procedure DoLogging(const aPLCState : TPLCState);

implementation

uses Math,Variables, structuredtext2pas, ProjManage, StrUtils, main;

{$R *.lfm}

var InitialTimeStamp : DWord;

procedure ClearHistory;
begin
  PLCHistStart:=0;
  PLCHistSize:=0;
  PLCHistFree:=0;
  InitialTimeStamp:=0;
end;

procedure FormClear;
begin
  FLog.ChartLogLineSeries1.clear;
  FLog.ChartLogLineSeries2.clear;
  FLog.ChartLogLineSeries3.clear;
  FLog.ChartLogLineSeries4.clear;
  FLog.ChartLogLineSeries5.clear;
  FLog.ChartLogLineSeries6.clear;
  FLog.ChartLogLineSeries7.clear;
  FLog.ChartLogLineSeries8.clear;
  FLog.ChartLogLineSeries9.clear;
  FLog.ChartLogLineSeries10.clear;
  ClearHistory;
  FLog.SpinStartTime.Value:=0;
  FLog.SpinEndTime.Value:=0;
end;

function MakeHistory(const aPLCState : TPLCState) : TPLCStateHist ;
var i : integer;
begin
  if InitialTimeStamp=0 then InitialTimeStamp:=MYGetTickCount;
  with result do begin
    TimeStamp:=MYGetTickCount-InitialTimeStamp;
    InBits :=BitsToDWord(aPLCState.InBits);
    OutBits:=BitsToDWord(aPLCState.OutBits);
    MemBits:=BitsToDWord(aPLCState.MemBits);
    SysBits:=BitsToDWord(aPLCState.SysBits) AND $FFFEFFFE; // Cuidado !!!
    TimersQ:=0;                                            // bits 0 e 16 não gravados !
    for i :=0 to high(aPLCState.Timers) do begin
      if (aPLCState.Timers[i].Q) then
        TimersQ:=TimersQ or DWORD(DWORD(1) shl i);
    end;
    for i :=0 to high(aPLCState.MemWords) do begin
      MemWords[i]:=PLCInteger (aPLCState.MemWords[i]);    // Protegido em 2019 para nº negativos não crasharem
    end;
    for i :=1 to high(aPLCState.SysWords) do begin
      SysWords[i]:=PLCInteger (aPLCState.SysWords[i]);
    end;
    SysWords[0]:=0;                                        // Cuidado !!!  CycleCount não gravado
    for i :=0 to high(aPLCState.Timers) do begin
      if FLog.CBLogTimers.Checked then begin
        TimersV[i]:=PLCInteger (aPLCState.Timers[i].V);
        TimersP[i]:=PLCInteger (aPLCState.Timers[i].P);
      end else begin
        TimersV[i]:=0;
        TimersP[i]:=0;
      end;
    end;
  end;
end;

function GetBooleanFromHistory(const PackBits : DWord; const bitn : integer ) : boolean ;
begin
  result:=(PackBits AND (1 shl bitn)) <> 0;
end;

function GetBit01FromHistory(const PackBits : DWord; const bitn : integer ) : integer ; overload;
begin
  result:=(PackBits AND (1 shl bitn)) shr bitn;
end;


function NextInHistory(const i : integer) : integer;
begin
  result:=(i+1) mod MaxPLCHistory;
end;

function PrevInHistory(var i : integer) : integer;
begin
  if i=0 then
    result:=MaxPLCHistory-1
  else
    result:=(i-1);
end;


procedure DoLogging(const aPLCState : TPLCState);
begin

  PLCStateHist[PLCHistFree]:=MakeHistory(aPLCState);

  // Shall I Advance ???
  if (PLCHistSize=0) or not (CompareMem(@PLCStateHist[PLCHistFree].InBits,
                                        @PLCStateHist[PrevInHistory(PLCHistFree)].InBits,
                                        sizeof(TPLCStateHist)-4)) then begin
    // Decided to advance...
    if PLCHistSize < (MaxPLCHistory-1) then begin
      PLCHistSize :=PLCHistSize+1;
    end else begin
      PLCHistStart:=NextInHistory(PLCHistStart);
    end;
    PLCHistFree:=NextInHistory(PLCHistFree);
  end; // Shall I Advance ???

end;



function IsNameAWord(const PercName : string) : boolean;
begin
  result:=false;
  try
    if       UpperCase(MidStr(PercName,3,1))='W' then
      result:=True
    else if ( UpperCase(MidStr(PercName,2,1)) = 'T' ) and (
               ( UpperCase(RightStr(PercName,1)) = 'P' ) or
               ( UpperCase(RightStr(PercName,1)) = 'V' )     ) then
      result:=True;
  except
  end;
end;



function GetIntegerValueFromHistory(const aHist : TPLCStateHist; const PercName : string) : integer;
var
  Channel : integer;
begin

 result:=-9999;

  try

    if (UpperCase(MidStr(PercName,2,1))='T') then
          channel:=StrToInt(Copy(PercName,4,pos('.',PercName)-4))
    else if       UpperCase(MidStr(PercName,3,1))='W' then
      channel:=StrToInt(Copy(PercName,4,length(PercName)))
    else if (UpperCase(MidStr(PercName,2,1))='M') or
            (UpperCase(MidStr(PercName,2,1))='S') then
      channel:=StrToInt(Copy(PercName,3,length(PercName)))
    else if (UpperCase(MidStr(PercName,2,1))='I') or
            (UpperCase(MidStr(PercName,2,1))='Q') then
      channel:=StrToInt(Copy(PercName,pos('.',PercName)+1,length(PercName)))
    else Channel:=-99;

    if          UpperCase(MidStr(PercName,2,1))='I' then begin
      result:=GetBit01FromHistory(aHist. InBits,Channel);
    end else if UpperCase(MidStr(PercName,2,1))='Q' then begin
      result:=GetBit01FromHistory(aHist.OutBits,Channel);
    end else if UpperCase(MidStr(PercName,2,2))='MW' then begin
      result:=aHist.MemWords[Channel];
    end else if UpperCase(MidStr(PercName,2,1))='M' then begin
      result:=GetBit01FromHistory(aHist.MemBits,Channel);
    end else if UpperCase(MidStr(PercName,2,2))='SW' then begin
      result:=aHist.SysWords[Channel];
    end else if UpperCase(MidStr(PercName,2,1))='S' then begin
      result:=GetBit01FromHistory(aHist.SysBits,Channel);
    end else if UpperCase(MidStr(PercName,2,1))='T' then begin
      case (UpperCase(RightStr(PercName,1)))[1] of
        'Q' : result:=GetBit01FromHistory(aHist.TimersQ,Channel);
        'V' : result:=aHist.TimersV[Channel];
        'P' : result:=aHist.TimersP[Channel];
      end;
    end else result:=-999;

  except
  end;
end;


function TFLog.GetRidOfTimerDot(const s:string) : string;
var len : integer;
begin
  len:=max(pos('.V',s),max(pos('.Q',s),pos('.P',s)))-1;
  if len=-1 then
    result:=s
  else
    result:=LeftStr(s,len);
end;

function TFLog.GetTimerDotSuffix(const s:string) : string;
var len : integer;
begin
  len:=max(pos('.V',s),max(pos('.Q',s),pos('.P',s)));
  if len=0 then
    result:=''
  else
    result:=Copy(s,len,2);
end;

procedure TFLog.BDrawClick(Sender: TObject);
var
  HistCurs, CLBCurs, SerCnt, PtCntPerSeries : integer;
  VarName : string;
begin

  LabelTooManyPoints.Visible:=false;

  ChartLog.BeginUpdateBounds;

  for CLBCurs:=0 to ChartLog.SeriesCount-1 do
    ChartLog.Series.Items[CLBCurs].Active:=False;

  ChartLogLineSeries1.Clear;
  ChartLogLineSeries2.Clear;
  ChartLogLineSeries3.Clear;
  ChartLogLineSeries4.Clear;
  ChartLogLineSeries5.Clear;
  ChartLogLineSeries6.Clear;
  ChartLogLineSeries7.Clear;
  ChartLogLineSeries8.Clear;
  ChartLogLineSeries9.Clear;
  ChartLogLineSeries10.Clear;


  //SerCnt:=0;
  //for SerCnt := Low(SeriesArray) to High(SeriesArray) do begin
  //  SeriesArray[SerCnt].LinePen.Color:=;
  //end;

  //FA_TAG: ChartLog.Axis.Left.AutomaticMinimum:=False;
  //FA_TAG: ChartLog.Axes.Left.AutomaticMaximum:=False;

  SerCnt:=0;
  for CLBCurs:=0 to CLBSeries.Items.Count-1 do begin
    if not CLBSeries.Checked[CLBCurs] then Continue;
    if SerCnt>=ChartLog.SeriesCount then break;

    VarName := CLBSeries.Items[CLBCurs];
    if pos('=',VarName)>0 then begin
      VarName:=copy(VarName,1,pos(' = ',VarName)-1) // line has both names
    end else begin
        if not CBShowPercentNames.Checked then begin
          VarName:=GetPercentNameFromUserName(GetRidOfTimerDot(VarName));
          Varname:=varname+GetTimerDotSuffix(CLBSeries.Items[CLBCurs]);
        end;
    end;
    ChartLog.Series[SerCnt].Active := True;
    SeriesArray[SerCnt].Title := CLBSeries.Items[CLBCurs];

    PtCntPerSeries:=0;
    HistCurs:=PLCHistStart;                // Go to interesting timestamp's
    while (HistCurs<>PLCHistFree) do begin
      if PLCStateHist[HistCurs].TimeStamp>=DWord(SpinStartTime.Value*1000) then break;
      HistCurs:=NextInHistory(HistCurs);
    end;
    if (HistCurs<>PLCHistStart) and
       (PLCStateHist[HistCurs].TimeStamp>=DWord(SpinStartTime.Value*1000)) then
      HistCurs:=PrevInHistory(HistCurs);

    if (copy(VarName,3,1)='W') or (GetTimerDotSuffix(VarName)='.V') or (GetTimerDotSuffix(VarName)='.P') then begin
       //FA_TAG: ChartLog.Axes.Left.AutomaticMinimum:=True;
       //FA_TAG: ChartLog.Axes.Left.AutomaticMaximum:=True;
    end;

    while (HistCurs<>PLCHistFree) do begin // While in interesting timestamp's
      if SpinEndTime.Value<>0 then
        if PLCStateHist[HistCurs].TimeStamp>DWord(SpinEndTime.Value*1000) then break;

      if IsNameAWord(VarName) then begin
          SeriesArray[SerCnt].LinePen.Width := 3 ;
          SeriesArray[SerCnt].AddXY(PLCStateHist[HistCurs].TimeStamp/1000 ,
              GetIntegerValueFromHistory(PLCStateHist[HistCurs],VarName));
      end else begin
          SeriesArray[SerCnt].LinePen.Width := 1 ;
          SeriesArray[SerCnt].AddXY(PLCStateHist[HistCurs].TimeStamp/1000 ,
              SerCnt + GetIntegerValueFromHistory(PLCStateHist[HistCurs],VarName) * 0.5 + 0.01 );
      end;

      HistCurs:=NextInHistory(HistCurs);
      Inc(PtCntPerSeries);
      if (PtCntPerSeries >= MaxPtCountPerSeries) then begin
        LabelTooManyPoints.Visible:=true;
        break;
      end;
    end;
    Inc(SerCnt);

  end;


  {// DelphiStuff
  ChartLog.AxisList.Axes[0].Intervals.MinLength:=0;//FA_TAG: ChartLog.Axes.Left.Minimum:=0;
  ChartLog.AxisList.Axes[0].Intervals.MaxLength:=SerCnt; //FA_TAG: ChartLog.Axes.Left.Maximum:=SerCnt;
  }
end;


procedure TFLog.Button1Click(Sender: TObject);
const
  N = 100;
  MIN = -10;
  MAX = 10;
var
  i: Integer;
  x: Double;
begin
  ChartLogLineSeries1.AddXY(random(100), random(100));
  //for i:=0 to N-1 do begin
  //  x := MIN + (MAX - MIN) * i /(N - 1);
  //  ChartLogLineSeries1.AddXY(x, sin(x));
  //  ChartLogLineSeries2.AddXY(x, cos(x));
  //  ChartLogLineSeries3.AddXY(x, sin(x)*cos(x));
  //end;

end;


procedure TFLog.FillCLBSeries;
var
  i : integer;
  CurName : string;
begin

{All,Filled, I - Input, Q - Output, M - Memory Bits, MW - Memory Words,
 S - System Bits, SW - System Words, TM - Timers }

  CLBSeries.Clear;
  for i := 1 to FVariables.SGVars.RowCount-1 do begin
    if Copy(FVariables.SGVars.Cells[0,i],2,1)<>'T' then begin
      if (FVariables.SGVars.Cells[1,i]='') then
        CurName:=FVariables.SGVars.Cells[0,i]     // Percent Name Only
      else if CBShowPercentNames.Checked then
             CurName:=FVariables.SGVars.Cells[0,i]+' = '+FVariables.SGVars.Cols[1][i] // Both Names
           else
             CurName:=FVariables.SGVars.Cols[1][i]; //SimplexName Only
      CLBSeries.Items.Append(CurName);
    end else begin
      if (FVariables.SGVars.Cells[1,i]='') then begin
        CLBSeries.Items.Append(FVariables.SGVars.Cells[0,i]+'.V'); // Percent Name Only
        CLBSeries.Items.Append(FVariables.SGVars.Cells[0,i]+'.P');
        CLBSeries.Items.Append(FVariables.SGVars.Cells[0,i]+'.Q');
      end else begin
        if CBShowPercentNames.Checked then begin                   // Both Names
          CLBSeries.Items.Append(FVariables.SGVars.Cells[0,i]+'.V = '+FVariables.SGVars.Cols[1][i]+'.V');
          CLBSeries.Items.Append(FVariables.SGVars.Cells[0,i]+'.P = '+FVariables.SGVars.Cols[1][i]+'.P');
          CLBSeries.Items.Append(FVariables.SGVars.Cells[0,i]+'.Q = '+FVariables.SGVars.Cols[1][i]+'.Q');
        end else begin
          CLBSeries.Items.Append(FVariables.SGVars.Cols[1][i]+'.V'); // Simplex Names Only
          CLBSeries.Items.Append(FVariables.SGVars.Cols[1][i]+'.P');
          CLBSeries.Items.Append(FVariables.SGVars.Cols[1][i]+'.Q');
        end;
      end;
    end;
  end;

  CBTypesChange(Self);


  exit;


end;


procedure TFLog.FormActivate(Sender: TObject);
begin
  if (CLBSeries.Items.Count=0) then FillCLBSeries;  //if {(Project.Modified) or} (CLBSeries.Items.Count=0) then FillCLBSeries;
  BDrawClick(Self);
end;

procedure TFLog.CBTypesChange(Sender: TObject);
var
  i : integer;
  PercName : string;
begin

  if Length(CBTypes.Text)<2 then exit;

  if CBTypes.Text[1]='A' then begin
    CLBSeries.TopIndex:=0;
    exit;
  end;

  if CBTypes.Text[1]='F' then begin
    for i := 0 to CLBSeries.Count-1 do
      if pos('=',CLBSeries.Items[i])>0 then break;
    CLBSeries.TopIndex:=i;
  end;

  for i := 0 to CLBSeries.Count-1 do begin
    if CBShowPercentNames.Checked then
      PercName:=CLBSeries.Items[i]
    else begin
      PercName:=GetPercentNameFromUserName(GetRidOfTimerDot(CLBSeries.Items[i]));
    end;
    if PercName='' then PercName:=CLBSeries.Items[i]; // Must be empty simplex name

    if (CBTypes.Text[2]='W') then begin   // MW, SW
      if copy(PercName,2,2)=Copy(CBTypes.Text,1,2) then break;
    end else begin
      if PercName[2]=CBTypes.Text[1] then break;
    end;
  end;
  CLBSeries.TopIndex:=i;
end;

procedure TFLog.CLBSeriesClickCheck(Sender: TObject);
begin
  BDrawClick(Sender);
end;

procedure TFLog.BClearClick(Sender: TObject);
begin
  FormClear;
end;

procedure TFLog.ExportClick(Sender: TObject);
var
  SL : TStringList;
  HistCurs,i : integer;
  ln : string;
begin

  SaveDialogExport.FileName:=ChangeFileExt(Project.FileName,'.csv');
  if not SaveDialogExport.Execute then exit;

  SL:=TStringList.Create;

  HistCurs:=PLCHistStart;

  // header
  ln:='TimeStamp,';

  with PLCStateHist[HistCurs] do begin
    for i:=0 to MaxInBits-1 do begin
      ln:=ln + 'I'+IntToStr(i)+', ';
    end;
    for i:=0 to MaxOutBits-1 do begin
      ln:=ln + 'Q'+IntToStr(i)+', ';
    end;
    for i:=0 to MaxMemBits-1 do begin
      ln:=ln + 'M'+IntToStr(i)+', ';
    end;
    for i:=0 to MaxSysBits-1 do begin
      ln:=ln + 'S'+IntToStr(i)+', ';
    end;
    for i:=0 to MaxTimers-1 do begin
      ln:=ln + 'TimersQ'+IntToStr(i)+', ';
    end;
    //ln:=ln+'MW:,';
    for i :=0 to high(MemWords) do begin
      ln:=ln + 'MW'+IntToStr(i)+', ';
    end;
    //ln:=ln+'SW:,';
    for i :=1 to high(SysWords) do begin
      ln:=ln + 'SW'+IntToStr(i)+', ';
    end;
    //ln:=ln+'TimP:,';
    for i :=0 to high(TimersP) do begin
      ln:=ln + 'TimersP'+IntToStr(i)+', ';
    end;
    //ln:=ln+'TimV:,';
    for i :=0 to high(TimersV) do begin
      ln:=ln + 'TimersV'+IntToStr(i)+', ';
    end;
  end;
  SL.Append(ln);

  // export cycle
  while (HistCurs<>PLCHistFree) do begin
    with PLCStateHist[HistCurs] do begin
      ln:=IntToStr(TimeStamp)+', ';
      for i:=0 to MaxInBits-1 do begin
        ln:=ln + IntToStr(GetBit01FromHistory(InBits,i))+', ';
      end;
      for i:=0 to MaxOutBits-1 do begin
        ln:=ln + IntToStr(GetBit01FromHistory(OutBits,i))+', ';
      end;
      for i:=0 to MaxMemBits-1 do begin
        ln:=ln + IntToStr(GetBit01FromHistory(MemBits,i))+', ';
      end;
      for i:=0 to MaxSysBits-1 do begin
        ln:=ln + IntToStr(GetBit01FromHistory(SysBits,i))+', ';
      end;
      for i:=0 to MaxTimers-1 do begin
        ln:=ln + IntToStr(GetBit01FromHistory(TimersQ,i))+', ';
      end;

      //ln:=ln+'MW:,';
      for i :=0 to high(MemWords) do begin
        ln:=ln + IntToStr(MemWords[i])+', ';
      end;
      //ln:=ln+'SW:,';
      for i :=1 to high(SysWords) do begin
        ln:=ln + IntToStr(SysWords[i])+', ';
      end;
      //ln:=ln+'TimP:,';
      for i :=0 to high(TimersP) do begin
        ln:=ln + IntToStr(TimersP[i])+', ';
      end;
      //ln:=ln+'TimV:,';
      for i :=0 to high(TimersV) do begin
        ln:=ln + IntToStr(TimersV[i])+', ';
      end;

      HistCurs:=NextInHistory(HistCurs);
    end;
    SL.Append(ln);
  end;

  SL.SaveToFile(SaveDialogExport.FileName);

  SL.Free;
end;

procedure TFLog.FormCreate(Sender: TObject);
begin
  //ChartLogLineSeries1.AddXY(0, 0);
  //ChartLogLineSeries1.AddXY(1, 2);
  //ChartLogLineSeries1.AddXY(2, 1);
  //ChartLogLineSeries1.AddXY(3, 1.5);

  SeriesArray[0] := ChartLogLineSeries1;
  SeriesArray[1] := ChartLogLineSeries2;
  SeriesArray[2] := ChartLogLineSeries3;
  SeriesArray[3] := ChartLogLineSeries4;
  SeriesArray[4] := ChartLogLineSeries5;
  SeriesArray[5] := ChartLogLineSeries6;
  SeriesArray[6] := ChartLogLineSeries7;
  SeriesArray[7] := ChartLogLineSeries8;
  SeriesArray[8] := ChartLogLineSeries9;
  SeriesArray[9] := ChartLogLineSeries10;

end;

procedure TFLog.SpinStartTimeChange(Sender: TObject);
begin
  if SpinEndTime.Value < SpinStartTime.Value then
    SpinEndTime.Value := SpinStartTime.Value+1;
  BDrawClick(Self);
end;

procedure TFLog.SpinEndTimeChange(Sender: TObject);
begin
  if SpinEndTime.Value < SpinStartTime.Value then
    SpinEndTime.Value := SpinStartTime.Value;
  BDrawClick(Self);
end;

procedure TFLog.CBShowPercentNamesClick(Sender: TObject);
begin
  FillCLBSeries();
  BDrawClick(Sender);
end;

procedure TFLog.CBAutoDrawClick(Sender: TObject);
begin
  TimerAutoDraw.Enabled := CBAutoDraw.Checked;
end;

procedure TFLog.TimerAutoDrawTimer(Sender: TObject);
begin
  BDrawClick(Sender);
end;

end.

