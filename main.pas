unit main;

{$MODE Delphi}          


interface

uses
  {$IFDEF Windows}
    Windows,
  {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, math, Grids, inifiles,ExtCtrls, Buttons, ComCtrls,

  lclintf{Open URL},

  //Modbus NOVO (lnet) MB_TAG
  lNetComponents, lnet,

  //Syns que funcionam
  SynEdit, SynMemo, SynHighlighterPas, SynHighlighterCpp, SynEditTypes,
  SynCompletion, SynHighlighterAny, SynHighlighterMulti,

  //Outros
  StructuredTextUtils, PrintersDlgs,

  //PASCAL SCRIPT
  uPSComponent,uPSRuntime,uPSCompiler,uPSUtils,

  //Para RiseEdge e Falling Edge vars
  structuredtext2pas,
  modbustcpclient {New ModBus Implement AJS 201905} ;

  { FA_TAG_
  NAO DAO:
  //WMCopyData,

  //DWS:
  //dws2Exprs, dws2Compiler, dws2Stack,dws2Debugger,

  //SYN:
  //,SynEditMiscClasses, SynEditSearch, SynEditPrint,
  //  SynEditOptionsDialog, SynEditRegexSearch, SynUniHighlighter,
  // SynCompletionProposal, SynAutoCorrect,
  // SynHighlighterST,
  //AppEvnts,
}

const cmwData=$FFFFFFFF;
      cmwClose=$FFFFFFFE;
      cmwLevel=$FFFFFFF0;

      crlf=#13+#10;


var VersionString : string ='FEUPAutom - 32b/64b-  ';  // Also see begin

FUNCTION resourceVersionInfo: STRING;

type

 TScriptState = (ssUndefined, ssReadyToRun, ssRunning);
 //TProgramState = (psUndefined, psReadyToRun, psRunning, psRunningStopped, psTerminated);

  { TFMain }

{FA_TAG:
   //dws
    DelphiWebScriptII: TDelphiWebScriptII;
    dws2Unit: Tdws2Unit;
    dws2SimpleDebugger: Tdws2SimpleDebugger;

	//Syn
    SynMemoHeader: TSynMemo;
    SynEditPrint: TSynEditPrint;
    SynEditSearch: TSynEditSearch;
    SynUniversal: TSynUniSyn;
    SynAutoCorrect: TSynAutoCorrect;
    SynSTSyn: TSynSTSyn;

	//Others
    ApplicationEvents: TApplicationEvents;
    PrintDialog: TPrintDialog;
}
  TFMain = class(TForm)
    Bevel2: TBevel;
    BIniRun: TBitBtn;
    bFactio: TButton;
    BMBSampleWrite: TButton;
    BMBStatusCheck: TButton;
    BMBSampleRead: TButton;
    Button2: TButton;
    Button3: TButton;
    CBExamMode: TCheckBox;
    EditAnimation: TEdit;
    LabelWarnObsoleteSt: TLabel;
    LabelInspect: TLabel;
    LabelCLangErr: TLabel;
    MemoCrypt1: TMemo;
    MemoCrypt2: TMemo;
    MemoDebugMB: TMemo;
    MemoDiskBreadCrumbs: TMemo;
    MenuGrafcetView: TMenuItem;
    MenuStartGrading: TMenuItem;
    MenuItem2: TMenuItem;
    MenuWindowSelfGradeGr7: TMenuItem;
    RGMBWriteFunc1: TRadioGroup;
    SynCpp: TSynCppSyn;
    TabCrypt: TTabSheet;
    TCP: TLTCPComponent;   //MB_TAG
    PSScript1: TPSScript;             //Pascal SCRIPT!!!
	//Syn
    SynEditC : TSynEdit;
    SynPasSyn: TSynPasSyn;
    SynEditPascal: TSynEdit;
    SynEditST: TSynEdit;
    SynCompletion: TSynCompletion;
    SynMemoHeader: TSynMemo;
    SynAnySyn_ST: TSynAnySyn;

    //others (for now)

    MainMenu: TMainMenu;
    MenuFile: TMenuItem;
    MenuWindow: TMenuItem;
    MenuVariables: TMenuItem;
    MenuExit: TMenuItem;
    MenuCalculator: TMenuItem;
    MenuInputsOutputs: TMenuItem;
    MenuProgram: TMenuItem;
    MenuCompile: TMenuItem;
    MenuHelp: TMenuItem;
    MenuAbout: TMenuItem;
    MenuOnlineHelp: TMenuItem;
    MenuLocalHelp: TMenuItem;
    MenuStop: TMenuItem;
    MenuRun: TMenuItem;
    PrintDialog: TPrintDialog;
    StatusBar: TStatusBar;
    MenuRunOnce: TMenuItem;
    MenuSave: TMenuItem;
    MenuSaveAs: TMenuItem;
    MenuOpen: TMenuItem;
    MenuEdit: TMenuItem;
    MenuUndo: TMenuItem;
    MenuRedo: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    MenuNew: TMenuItem;
    MenuTargets: TMenuItem;
    MenuSimplePark: TMenuItem;
    ReplaceDialog: TReplaceDialog;
    MenuPrintSource: TMenuItem;
    MenuPrintVarList: TMenuItem;
    N3: TMenuItem;
    MenuPrintSourceVarList: TMenuItem;
    N4: TMenuItem;
    MenuFind: TMenuItem;
    MenuReplace: TMenuItem;
    FindDialog: TFindDialog;
    PageControl: TPageControl;
    TabProject: TTabSheet;
    TabST: TTabSheet;
    PageControlBottom: TPageControl;
    TabOutput: TTabSheet;
    TabErrors: TTabSheet;
    MemoResult: TMemo;
    LBErrors: TListBox;
    TabPascal: TTabSheet;
    Splitter1: TSplitter;
    MenuPascal: TMenuItem;
    EditMsgdebug: TEdit;
    EditDebug: TEdit;
    TabValues: TTabSheet;
    BPrintAllValues: TButton;
    MemoValues: TMemo;
    BClearList: TButton;
    MenuVarValues: TMenuItem;
    Label1: TLabel;
    EditAuthors: TEdit;
    Label2: TLabel;
    EditComments: TEdit;
    N5: TMenuItem;
    MenuClearMemory: TMenuItem;
    MenuClearAllIOs: TMenuItem;
    MenuSimplePark2: TMenuItem;
    MenuParkTwoBarriers: TMenuItem;
    MenuClearSystem: TMenuItem;
    MenuGate: TMenuItem;
    MenuClearAll: TMenuItem;
    N6: TMenuItem;
    MenuLog: TMenuItem;
    N7: TMenuItem;
    NewFind1: TMenuItem;
    NewReplace1: TMenuItem;
    FA_Timer: TTimer;
    TimerStartParam: TTimer;
    TimerSplash: TTimer;
    N8: TMenuItem;
    MenuThunderbird: TMenuItem;
    CBGrafcet: TCheckBox;
    MenuGrafcet: TMenuItem;
    EditMBIP: TEdit;
    EditMBPort: TEdit;
    BSetParams: TButton;
    LabelMBStatus: TLabel;
    EditPeriodMiliSec: TEdit;
    FontDialog1: TFontDialog;
    TimUpdtVarInfo: TTimer;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    CBWinMessages: TCheckBox;
    CBModBus: TCheckBox;
    Bevel1: TBevel;
    BBRun: TBitBtn;
    Button1: TButton;
    BBStop: TBitBtn;
    EditMBNRead: TEdit;
    EditMBNWrite: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    EditMBOffs_I: TEdit;
    EditMBOffs_O: TEdit;
    Label3: TLabel;
    Label7: TLabel;
    BResetWinPos: TButton;
    BTestMBRdWr: TButton;
    N9: TMenuItem;
    ResetPositions1: TMenuItem;
    N10: TMenuItem;
    MenuSFS: TMenuItem;
    N11: TMenuItem;
    MenuSTB: TMenuItem;
    RGMBReadFunc: TRadioGroup;
    TimerRunTimeBomb: TTimer;
    TimeBomb1: TMenuItem;
    N12: TMenuItem;
    Tab_C_: TTabSheet;
    BST2C: TBitBtn;
    BMake: TBitBtn;
    TabMakeMsgs: TTabSheet;
    MemoMakeMsgs: TMemo;
    BDude: TBitBtn;
    MemoErr: TMemo;
    MenuNextG7STCmakeDude: TMenuItem;
    CBGen_C_Code: TCheckBox;

    //Procedures:
    procedure bFactioClick(Sender: TObject);
    procedure BIniRunClick(Sender: TObject);
    procedure BMBSampleWriteClick(Sender: TObject);
    procedure BMBStatusCheckClick(Sender: TObject);
    procedure BMBSampleReadClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CBGrafcetChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure MenuGrafcetViewClick(Sender: TObject);
    procedure MenuShowSelfGradClick(Sender: TObject);
    procedure MenuWindowSelfGradeGr7Click(Sender: TObject);
    procedure MenuStartGradingClick(Sender: TObject);
    procedure TCPAccept(aSocket: TLSocket);
    procedure TCPConnect(aSocket: TLSocket);
    procedure TCPDisconnect(aSocket: TLSocket);
    procedure TCPError(const msg: string; aSocket: TLSocket);
    procedure TCPReceive(aSocket: TLSocket);
    procedure PSScript1Compile(Sender: TPSScript);
    procedure PSScript1Execute(Sender: TPSScript);
    procedure SynEditSTStatusChange(Sender: TObject;        Changes: TSynStatusChanges);
    procedure SynEditSTMouseMove(Sender: TObject; {%H-}Shift: TShiftState; X,        Y: Integer);
    procedure SynEditCStatusChange(Sender: TObject;         Changes: TSynStatusChanges);
    procedure FormCreate(Sender: TObject);
    procedure MenuVariablesClick(Sender: TObject);
    procedure MenuExitClick(Sender: TObject);
    procedure MenuCalculatorClick(Sender: TObject);
    procedure MenuInputsOutputsClick(Sender: TObject);
    procedure BCompileClick(Sender: TObject);
    procedure MenuCompileClick(Sender: TObject);
    procedure MenuRunClick(Sender: TObject);
    //procedure ApplicationEventsMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure MenuStopClick(Sender: TObject);
    procedure MenuRunOnceClick(Sender: TObject);
    procedure LBErrorsClick(Sender: TObject);
    procedure MenuUndoClick(Sender: TObject);
    procedure MenuRedoClick(Sender: TObject);
    procedure BTestWMClick(Sender: TObject);
    procedure MenuLocalHelpClick(Sender: TObject);
    procedure MenuSelectTargetClick(Sender: TObject);
    procedure MenuNewClick(Sender: TObject);
    procedure MenuOpenClick(Sender: TObject);
    procedure MenuSaveClick(Sender: TObject);
    procedure MenuSaveAsClick(Sender: TObject);
    procedure MenuOnlineHelpClick(Sender: TObject);
    procedure FindDialogFind(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuPrintSourceClick(Sender: TObject);
    procedure MenuFindClick(Sender: TObject);
    procedure MenuReplaceClick(Sender: TObject);
    procedure ReplaceDialogFind(Sender: TObject);
    procedure ReplaceDialogReplace(Sender: TObject);
    procedure FindDialogClose(Sender: TObject);
    procedure ReplaceDialogClose(Sender: TObject);
    procedure MenuPrintVarListClick(Sender: TObject);
    procedure MenuPrintSourceVarListClick(Sender: TObject);
    procedure MenuPascalClick(Sender: TObject);
    procedure BClearListClick(Sender: TObject);
    procedure MenuVarValuesClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EditAuthorsChange(Sender: TObject);
    procedure EditCommentsChange(Sender: TObject);
    procedure MenuClearMemoryClick(Sender: TObject);
    procedure MenuClearAllIOsClick(Sender: TObject);
    procedure MenuClearSystemClick(Sender: TObject);
    procedure MenuClearAllClick(Sender: TObject);
    procedure Splitter1CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure MenuLogClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FA_TimerTimer(Sender: TObject);
    procedure TimerSplashTimer(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; {%H-}Shift: TShiftState);
    procedure CBGrafcetClick(Sender: TObject);
    procedure MenuGrafcetClick(Sender: TObject);
    procedure BSetParamsClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TimerStartParamTimer(Sender: TObject);
    procedure TimUpdtVarInfoTimer(Sender: TObject);
    procedure CBModBusClick(Sender: TObject);
    procedure CBWinMessagesClick(Sender: TObject);
    procedure BBRunClick(Sender: TObject);
    procedure BBStopClick(Sender: TObject);
    procedure IdModBusClient1Disconnected(Sender: TObject);
    procedure BResetWinPosClick(Sender: TObject);
    procedure BTestMBRdWrClick(Sender: TObject);
    procedure ResetPositions1Click(Sender: TObject);
    procedure MenuSFSClick(Sender: TObject);
    procedure MenuSTBClick(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
    procedure TimerRunTimeBombTimer(Sender: TObject);
    procedure TimeBomb1Click(Sender: TObject);
    procedure BST2CClick(Sender: TObject);
    procedure BMakeClick(Sender: TObject);
    procedure BDudeClick(Sender: TObject);
    procedure MemoMakeMsgsClick(Sender: TObject);
    procedure MenuNextG7STCmakeDudeClick(Sender: TObject);
    procedure CBGen_C_CodeClick(Sender: TObject);
    procedure UpdateStatusVar();

  private
    { Private declarations }
    procedure BlinkBevelSettings();
    procedure TranslateST2Pas;

  public
    //MODBUS( MB_TAG ):
    TCP_Conn: TLConnection;
    stringRec:string;  //Batota

    ProgCyclesCount: integer;
    ScriptState : TScriptState;     //ProgRunning: boolean;
    ScriptStartTime, ScriptLastTime, ScriptTotalRunTime: LongWord;
    ProgramStartTime, ScriptCyclesCount: LongWord;
    SimLevel: Dword;
    StatusVarName, OldStatusVarName : string;
    SyntHighlRunTimeVarsIdx : integer;

    ModBusNEW : TModbus;

    procedure Compile;
    procedure RunOnce;
    procedure RunOnceIOAware(running: boolean);
    procedure StartRunningProgram;
    procedure StopRunningProgram;
    procedure PeriodicTimerEvent;
    procedure UpdateStatusLine;
    function  WMCommunication(App: string; Command, data: DWord): Dword;
    procedure DoFindText(Sender: TObject);
    procedure DoReplaceText(Sender: TObject);

    procedure FormSave(ProjMemIni : TMemIniFile);
    procedure FormLoad(ProjMemIni : TMemIniFile);
    procedure FormInit;
    procedure ReallyPrintLines;
    procedure FixSyntaxHighlAndCompletion();
    procedure refreshMB;
    //procedure ModbusEvent(command: byte);

  end;

  function MyGetTickCount() : Int64;

const
  SimTargetExe:
    array[0..4] of string=('..\3D_Park\Park3D.exe',
                           '..\3D_Park\Park3D.exe',
                           '..\3D_Park\Park3D.exe',
                           '..\3D_Thunderbird\Thunderbird3D.exe',
                           '..\3D_Gate\Gate3D.exe'
                           );

  SimTargetForm:
    array[0..4] of string=('TFMainPark3D',
                           'TFMainPark3D',
                           'TFMainPark3D',
                           'TFMainThunderbird3D',
                           'TFMainGate3D'
                           );

//type
//  TinPort = array[0..31] of integer;

var
  FMain: TFMain;
//  inPort: TinPort;
  VArr: Variant;

  GlobalMemIni: TMemIniFile;
  StartTic10HzTimer : cardinal;
resourcestring
  STR_RUNTIME_ERROR='[Runtime error] %s(%d:%d), bytecode(%d:%d): %s'; //Birb

const
  Timer10Hz = 16;

procedure CopyFromCoilsToInputs(const Coils: array of boolean);

implementation

uses Variables, IOLeds, MMTimer, ProjManage,
     Logger, Splash, G7Draw, Pas2C, ModBus_Utils,
     resource, versiontypes, versionresource, lCommon, strutils,
     character;

{$R *.lfm}

var MyQueryPerformanceFrequency : Int64;
var Startup, RunTimeBomb : boolean ;


function FixLineNumberErrWarn(const txt : string; const offset: integer): string;forward;


{FA_TAG:
procedure TFMain.dws2UnitFunctionsExternalFuncSumEval(Info: TProgramInfo);
begin
//  Info['Result'] := inttostr( strtoint(Info['a'])+ strtoint(Info['b']));
  Info['Result'] := Info['a']+ Info['b'];

end;

procedure TFMain.dws2UnitVariablesrunningReadVar(var Value: Variant);
begin
  value:=false;
end;


procedure TFMain.dws2UnitFunctionsTestVectEval(Info: TProgramInfo);
var i: integer;
  tmp: TData;
  txt: string;
begin

//  editDebug.text:=inttoStr(vartype( Info));
  Tmp:=Info.data['ip'];

  txt:='';
  for i:=0 to 31 do begin
    txt:=txt+inttostr(tmp[i]);
  end;
  MemoResult.Lines.add(txt);

  tmp:=Info.data['result'];
  tmp[1]:=10;
  Info.data['result']:=tmp;

  Info.data['result'][2]:=10;
end;


procedure TFMain.dws2SimpleDebuggerDebug(Prog: TProgram; Expr: TExpr);
begin
//  if MyGetTickCount()-ScriptStartTime > 250 then begin
  inc(ScriptCyclesCount);
  if ScriptCyclesCount > 2500 then begin
    Prog.Stop;
  end;

//  EditMsgdebug.tag:=EditMsgdebug.tag+1;
//  EditMsgdebug.text:=inttostr(MyGetTickCount()-ScriptStartTime);
//  EditMsgdebug.text:=inttostr(EditMsgdebug.tag);
//  if EditMsgdebug.tag>100000 then Prog.Stop;
//  Application.ProcessMessages;
end;


}


procedure MWrites(const s: String);
begin
  if FMain.MemoResult.Lines.Count=0 then FMain.MemoResult.Append('');
  FMain.MemoResult.lines[FMain.MemoResult.Lines.Count-1] :=
      FMain.MemoResult.lines[FMain.MemoResult.Lines.Count-1]+s;
end;

procedure MWritei(const i: Integer);
begin
  if FMain.MemoResult.Lines.Count=0 then FMain.MemoResult.Append('');
  FMain.MemoResult.lines[FMain.MemoResult.Lines.Count-1] :=
      FMain.MemoResult.lines[FMain.MemoResult.Lines.Count-1]+IntToStr(i);
end;

procedure MWriteb(const b: Boolean);
begin
  if FMain.MemoResult.Lines.Count=0 then FMain.MemoResult.Append('');
  FMain.MemoResult.lines[FMain.MemoResult.Lines.Count-1] :=
      FMain.MemoResult.lines[FMain.MemoResult.Lines.Count-1]+BoolToStr(b,'True','False');
end;

procedure MWritesln(const s: string);
begin
  MWrites(s);
  FMain.MemoResult.Append('');
end;
procedure MWriteiln(const i: Integer);
begin
  MWritei(i);
  FMain.MemoResult.Append('');
end;

procedure MWritebln(const b: Boolean);
begin
  MWriteb(b);
  FMain.MemoResult.Append('');
end;

// Script Function to ForceRestart of a given page
// Within a given page, initial steps are set, all others reset
// By setting and resetting of correspondig bits of the PLC, searched in SGVars
procedure PageStart(const PageNumber : integer);
begin
  FormG7.G7PageStart(PageNumber);
end;

// Script Function reset all steps of a given page to inactivity
// By reset of correspondig bits of the PLC, searched in SGVars
procedure PageClear(const PageNumber : integer);
begin
  FormG7.G7PageClear(PageNumber);
end;

// Script Function
function ZeroOne(n : word) : word;
begin
  if n>0 then result:=1 else result:=0;
end;





//PASCAL SCRIPT ON COMPILE
procedure TFMain.PSScript1Compile(Sender: TPSScript);
begin

//##############################################################################
//Registering  Registering  Registering  Registering  Registering  Registering
//##############################################################################
  try

  Sender.AddFunction(@MWrites, 'procedure Writes(const s: String)');
  Sender.AddFunction(@MWritei, 'procedure Writei(const i: Integer)');
  Sender.AddFunction(@MWriteb, 'procedure Writeb(const b: Boolean)');
  Sender.AddFunction(@MWritesln, 'procedure Writesln(const s: string)');
  Sender.AddFunction(@MWriteiln, 'procedure Writeiln(const i: integer)');
  Sender.AddFunction(@MWritebln, 'procedure Writebln(const b: Boolean)');

  Sender.AddFunction(@PageStart, 'procedure PageStart(const PageNumber : integer)'); // InitPage
  Sender.AddFunction(@PageClear, 'procedure PageClear(const PageNumber : integer)');
  Sender.AddFunction(@ZeroOne,   'function ZeroOne(n : word) : word');

  //IN_bits
  Sender.Comp.AddTypeS( 'TArray_InBits' ,  'array[0..'+IntToStr(MaxInBits)+'-1]   of boolean;' ).ExportName:=True ;
  Sender.AddRegisteredPTRVariable('_InBits','TArray_InBits');
  Sender.AddRegisteredPTRVariable('_RE_InBits','TArray_InBits');
  Sender.AddRegisteredPTRVariable('_FE_InBits','TArray_InBits');

  //OUT_bits
  Sender.Comp.AddTypeS( 'TArray_OutBits' ,  'array[0..'+IntToStr(MaxOutBits)+'-1]   of boolean;' ).ExportName:=True ;
  Sender.AddRegisteredPTRVariable('_OutBits','TArray_OutBits');
  Sender.AddRegisteredPTRVariable('_RE_OutBits','TArray_OutBits');
  Sender.AddRegisteredPTRVariable('_FE_OutBits','TArray_OutBits');

  //MEM_bits
  Sender.Comp.AddTypeS( 'TArray_MemBits' ,  'array[0..'+IntToStr(MaxMemBits)+'-1]   of boolean;' ).ExportName:=True ;
  Sender.AddRegisteredPTRVariable('_MemBits','TArray_MemBits');
  Sender.AddRegisteredPTRVariable('_RE_MemBits','TArray_MemBits');
  Sender.AddRegisteredPTRVariable('_FE_MemBits','TArray_MemBits');

  //SYS_bits
  Sender.Comp.AddTypeS( 'TArray_SysBits' ,  'array[0..'+IntToStr(MaxSysBits)+'-1]   of boolean;' ).ExportName:=True ;
  Sender.AddRegisteredPTRVariable('_SysBits','TArray_SysBits');
  Sender.AddRegisteredPTRVariable('_RE_SysBits','TArray_SysBits');
  Sender.AddRegisteredPTRVariable('_FE_SysBits','TArray_SysBits');

  //MEM_words
  Sender.Comp.AddTypeS( 'TArray_MemWords' ,  'array[0..'+IntToStr(MaxMemWords)+'-1]   of integer;' ).ExportName:=True ;
  Sender.AddRegisteredPTRVariable('_MemWords','TArray_MemWords');

  //SYS_words
  Sender.Comp.AddTypeS( 'TArray_SysWords' ,  'array[0..'+IntToStr(MaxSysWords)+'-1]   of integer;' ).ExportName:=True ;
  Sender.AddRegisteredPTRVariable('_SysWords','TArray_SysWords');

  //TIMERS
  Sender.Comp.AddTypeS( 'TTimerType','(TOn, TOff)').ExportName:=true;
  Sender.Comp.AddTypeS( 'TPLCTimerState','record '+
                        'P: Word; '+
                        'V: Word; '+
                        'Q: Boolean; end;' (*+
                        'Mode : TTimerType; end; '*)).ExportName:=true;
  Sender.Comp.AddTypeS( 'TArray_Timers' ,  'array[0..'+IntToStr(MaxTimers)+'-1]   of TPLCTimerState;' ).ExportName:=True ;
  Sender.AddRegisteredPTRVariable('_Timers','TArray_Timers');

  except
     LBErrors.Items.Append('Errors adding vars to compiler! contact asousa@fe.up.pt');
  end;

end;

procedure TFMain.PSScript1Execute(Sender: TPSScript);
begin

//##############################################################################
//Executing  Executing  Executing  Executing  Executing  Executing  Executing
//##############################################################################
  //IN_bits
  Sender.SetPointerToData('_InBits', @PLCState.InBits, Sender.FindNamedType('TArray_InBits'));
  Sender.SetPointerToData('_RE_InBits', @_RE_InBits, Sender.FindNamedType('TArray_InBits'));
  Sender.SetPointerToData('_FE_InBits', @_FE_InBits, Sender.FindNamedType('TArray_InBits'));

  //OUT_bits
  Sender.SetPointerToData('_OutBits', @PLCState.OutBits, Sender.FindNamedType('TArray_OutBits'));
  Sender.SetPointerToData('_RE_OutBits', @_RE_OutBits, Sender.FindNamedType('TArray_OutBits'));
  Sender.SetPointerToData('_FE_OutBits', @_FE_OutBits, Sender.FindNamedType('TArray_OutBits'));

  //MEM_bits
  Sender.SetPointerToData('_MemBits', @PLCState.MemBits, Sender.FindNamedType('TArray_MemBits'));
  Sender.SetPointerToData('_RE_MemBits', @_RE_MemBits, Sender.FindNamedType('TArray_MemBits'));
  Sender.SetPointerToData('_FE_MemBits', @_FE_MemBits, Sender.FindNamedType('TArray_MemBits'));

  //SYS_bits
  Sender.SetPointerToData('_SysBits', @PLCState.SysBits, Sender.FindNamedType('TArray_SysBits'));
  Sender.SetPointerToData('_RE_SysBits', @_RE_SysBits, Sender.FindNamedType('TArray_SysBits'));
  Sender.SetPointerToData('_FE_SysBits', @_FE_SysBits, Sender.FindNamedType('TArray_SysBits'));

  //MEM_words
  Sender.SetPointerToData('_MemWords', @PLCState.MemWords, Sender.FindNamedType('TArray_MemWords'));

  //SYS_words
  Sender.SetPointerToData('_SysWords', @PLCState.SysWords, Sender.FindNamedType('TArray_SysWords'));

  //TIMERS
  Sender.SetPointerToData('_Timers', @PLCState.Timers, Sender.FindNamedType('TArray_Timers')); // Estava errado! corrigido 2016 06 07

  // StructuredTextUtils   ///// Debug Code
  //  PLCState.Timers[0].Q := false;
  //  PLCState.Timers[0].V := 0;

end;

//MODBUS NOVO
procedure TFMain.TCPReceive(aSocket: TLSocket);
var msg : string;
begin
    //if aSocket.GetMessage(stringRec) > 0 then begin
    //  exit;
    //end;

  msg:='';
  TCP.GetMessage(msg);
  //if length(msg)>5 then
  ModbusNEW.MessageStateMachine(msg);
end;

procedure TFMain.refreshMB;
begin
  //Application.QueueAsyncCall(@PSScript1Execute,FCounter);
  Application.ProcessMessages;
end;


procedure UpdateAllSystemAndTimers(var PLC : TPLCState);
var
  i, Prev10Hz, delta_100ms : cardinal;
begin

  // First: Take care of 10 Hz Sys Timer
  if (StartTic10HzTimer=0) then begin
    StartTic10HzTimer:=MyGetTickCount; // starts up the var StartTic10HzTimer
    exit;
  end;

  Prev10Hz:=PLC.SysWords[Timer10Hz];

  PLC.SysWords[Timer10Hz]:=(MyGetTickCount()-StartTic10HzTimer) div 100;

  delta_100ms:=PLC.SysWords[Timer10Hz]-Prev10Hz;

  PLC.SysBits[0]:=not PLC.SysBits[0];  // flip each cycle

  if delta_100ms>0 then begin             // cycle ~ 10Hz bit
    PLC.SysBits[Timer10Hz]:=true;
  end else begin
    PLC.SysBits[Timer10Hz]:=false;
  end;

  // After: User Timers
  if delta_100ms>0 then begin
    for i:=0 to MaxTimers-1 do begin
      PLC.Timers[i].V := PLC.Timers[i].V+delta_100ms;
      //mode:=TOn;   ////////// TODO: Mode TOff
      //if mode=TOn then Q:=(V>=P) else Q:=(V<P);  // Alterado 2018 02 27
      PLC.Timers[i].Q := (PLC.Timers[i].V>=PLC.Timers[i].P);
    end;
  end;

  // Cycle Counter
  Inc(PLC.SysWords[0]);

end;

procedure TFMain.SynEditSTMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
    ScreenCoord: TPoint;
    BufCoord: TPoint;
    tmp: string;
    len:integer;
begin
  {FA_TAG: BufCoord    := SynEditST.DisplayToBufferPos(ScreenCoord); }

  //TODO: Percent names likely are no recognized!!!!!

  ScreenCoord := SynEditST.PixelsToRowColumn(Point(X,Y));
  tmp    := SynEditST.GetWordAtRowCol(ScreenCoord);
  LabelInspect.Caption := tmp;
  StatusVarName := tmp;

  //if (BufCoord.Y >= 1) and (BufCoord.Y <= SynEditST.Lines.Count) then  begin
    //Len := Length(SynEditST.Lines[BufCoord.Y - 1]);
    //if BufCoord.X <= Len then begin
    //  tmp:=SynEditST.GetWordAtRowCol(BufCoord);
      //if tmp<>'' then begin StatusVarName := tmp;
    //end;
  //end;

  UpdateStatusVar();
end;

procedure TFMain.FormCreate(Sender: TObject);
begin

  QueryPerformanceFrequency(MyQueryPerformanceFrequency);

  if MyQueryPerformanceFrequency=0 then ShowMessage('Using timer compatibility mode');

  GlobalMemIni:= TMemIniFile.Create(extractFilePath(Application.ExeName)+'config.ini');

  ScriptState:=ssUndefined;

  //DetectProjectFullDirAndStorage;  //TODO!!!
  TabPascal.TabVisible   := false; //AJS_C_
  TabValues.TabVisible   := false; //AJS_C_
  TabMakeMsgs.TabVisible := false; //AJS_C_
  Tab_C_.TabVisible      := false; //AJS_C_
  BST2C.Visible := false;
  BMake.Visible := false;
  BDude.Visible := false;

  TCP.SocketNet := LAF_INET;
  TCP_Conn:=TCP;        //MB_TAG

  {FA_Resolvido}
  with PrintDialog do begin
    Collate := True;
    Copies := 1;
    Options := [poPageNums];
  end;

  // AJS 201905
  //ModBusNEW := TModbus.Create(@ModbusEvent);
  ModBusNEW := TModbus.Create();

end;

procedure TFMain.MenuVariablesClick(Sender: TObject);
begin
  FVariables.show;
end;

procedure TFMain.MenuExitClick(Sender: TObject);
begin
  close;
end;

procedure TFMain.MenuCalculatorClick(Sender: TObject);
begin
   OpenDocument('Calc.exe'); //Converted from ShellExecute
end;

procedure TFMain.MenuInputsOutputsClick(Sender: TObject);
begin
  FIOLEds.show;
end;

procedure TFMain.BCompileClick(Sender: TObject);
begin
  Compile;
end;

procedure TFMain.TranslateST2Pas;
begin
  ScriptState:=ssUndefined;
  TranslateArrayInit(TranslationsST2Pas);
  {FA_Resolvido}
  Translate(SynEditST.Lines,SynEditPascal.Lines,TranslationsST2Pas);
end;

procedure TFMain.MenuCompileClick(Sender: TObject);
begin
  if ScriptState=ssRunning then exit;
  Compile;
end;

procedure TFMain.MenuRunClick(Sender: TObject);
//var msg : TForm;
begin

  if Project.Grafcet then begin  // // Grafcet Modified ...
    if copy(SynEditST.Lines[0],1,14)='// Grafcet Mod' then begin
//      msg := CreateMessageDialog('Warning: Running Obsolete ST (Grafcet changed...)',mtinformation,[mbok]);
      LabelWarnObsoleteSt.Visible:=True;
//      msg.Show;
//      Application.ProcessMessages();
//      sleep(200);
//      Application.ProcessMessages();
//      sleep(100);
//      msg.Hide;
//      sleep(100);
//      Application.ProcessMessages();
//      msg.Free;
    end else  LabelWarnObsoleteSt.Visible := False;
  end else    LabelWarnObsoleteSt.Visible := False;



  if (ScriptState=ssRunning) then exit;
  if (CBModBus.Checked) then BSetParamsClick(Sender);

  Compile;

  if ScriptState=ssReadyToRun then begin
    StartRunningProgram;
  end;

end;

procedure TFMain.Compile;
var
  i64_start, i64_end, i64_freq: int64;
  Messages: string;
  compiled: boolean;
  i:integer;
begin
  {FA_RESOLVIDO:Passagem de dws para PascalScript}
  ScriptState:=ssUndefined;
  queryperformancecounter(i64_start);
  TranslateST2Pas();

  //PSScript1.Script.Text:=SynMemoHeader.Text+'begin '+CRLF+SynEditPascal.Text+CRLF+' end.'; //Juntar HeaderSt+Pascal_Gerado
  PSScript1.Script.Text:=SynMemoHeader.Text+CRLF+SynEditPascal.Text+CRLF+' end.'; //Juntar HeaderSt+Pascal_Gerado
  SynEditPascal.Text := PSScript1.Script.Text;

  Compiled := PSScript1.Compile; //compilar Programa

  if (Compiled) then begin //SUCESS Compiling
    Queryperformancecounter(i64_end);
    QueryPerformanceFrequency(i64_freq);
    LBErrors.Items.clear;
    LBErrors.Items.Append(format('Compile OK in %f ms',[1000*(i64_end-i64_start)/i64_freq]));
    ScriptState:=ssReadyToRun;
  end
  else begin               //ERRORS Compiling
    LabelWarnObsoleteSt.Visible := False;
    Messages := Messages + 'Compiled with Errors:' + CRLF;
    LBErrors.Items.clear;
    for i := 0 to PSScript1.CompilerMessageCount -1 do  begin  //Get messages  both hints or errors
      Messages:=trim(PSScript1.CompilerMessages[i].MessageToString);
      Messages:=FixLineNumberErrWarn(Messages, -SynMemoHeader.Lines.count-1);
      LBErrors.Items.Add(Messages);
    end;
    FMain.BringToFront;
    PageControl.ActivePage := TabST;
    PageControlBottom.ActivePage := TabErrors; // Select Errors Tab
  end;

end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Timer Zone ~~~~~~~~~~~~~~~~~~~~

function MyGetTickCount() : Int64;
begin
  if (MyQueryPerformanceFrequency>0) then begin
    QueryPerformanceCounter(result);
    result := round( (result / MyQueryPerformanceFrequency) *1000);
  end else
    result:=GetTickCount;
end;

procedure Reset10HzTimer;
begin
  StartTic10HzTimer:=0;
end;

//´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´
//                                     Active System Stuff:
// SysBit[0] - flip each cycle
// SysBit[Timer10Hz:=16] - active 1 cycle each 100 ms (100 ms approx)
// SysWord[0] - cycle count (increment each cycle)
// SysWord[Timer10Hz:=16] - system 10Hz timer (resettable, unstoppable)
//,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   User timers   ~~~~~~~~~~~~~~~~~~~~


procedure TFMain.RunOnce;
var
  i64_start, i64_end, i64_freq: int64;
  execResult:boolean;
  tempstring : string;
begin

  if (not (PSScript1.Exec.Status in [isLoaded])) then exit;

  FMain.MemoResult.Clear;

  ScriptCyclesCount:=0;
  queryperformancecounter(i64_start);
  tempstring := IntToStr( PLCState.Timers[0].V ) + ' ' ;
  UpdateAllSystemAndTimers(PLCState);
//  MemoDebugMB.Append( tempstring + IntToStr(PLCState.Timers[0].V ));

  try
    //PSScript1.Exec.Run;
    execResult := PSScript1.Execute;
  except
    on E: Exception do begin
      StopRunningProgram;
      StatusBar.Panels[3].Text:=E.Message;
      StatusBar.Panels[4].Text:=E.Message;
      if LBErrors.Count=0 then LBErrors.Items.Append('x');
      LBErrors.Items[0]:='Run-time error:'+ PSScript1.ExecErrorToString+'|'+ E.Message;
      FMain.BringToFront;
      PageControl.ActivePage := TabST;
      PageControlBottom.ActivePage := TabErrors;
    end;
  end;

  PLCStateToScriptState(PLCState, PrevPLCState);
  DoLogging(PLCState);
  // PrevPLCState := PLCState;  // Problema da falta do RE e FE Raising Edge  ???!??!??!??!!
  Move(PLCState,PrevPLCState,sizeof(PLCState));

  i64_end:=-1;
  i64_freq:=-1;
  queryperformancecounter(i64_end);
  QueryPerformanceFrequency(i64_freq);
  inc(ProgCyclesCount);

  if (not execResult) then begin
    LBErrors.Items.clear;
    LBErrors.Items.Add(
         Format(STR_RUNTIME_ERROR, ['NoFicheiro', PSScript1.ExecErrorRow,
         PSScript1.ExecErrorCol,PSScript1.ExecErrorProcNo,
         PSScript1.ExecErrorByteCodePosition,PSScript1.ExecErrorToString])); //Birb

    //LBErrors.Items.Add('RunTime Errors:'+ PSScript1.ExecErrorToString);
    //LBErrors.Items.Add( 'code pos='+inttostr(PSScript1.ExecErrorByteCodePosition));
    //LBErrors.Items.Add( 'Proc_name='+PSScript1.ExecErrorFileName);

    ScriptState:=ssReadyToRun;  // What happens if runtime error ???
    PageControlBottom.TabIndex:=1;  // Select Errors Tab
    BBRun.Enabled  := True;
    BBStop.Enabled := False;
    exit;
  end;

  //MemoResult.Text := Tdws2DefaultResult( Prog.Result).Text;
  PageControlBottom.TabIndex:=0;  // Select Output tab

{FA_Copia_antes_ediçao_1:
   if (not (Prog.ProgramState in [psReadyToRun, psTerminated])) then exit;

  prog.Debugger:=dws2SimpleDebugger;
  ScriptCyclesCount:=0;
  queryperformancecounter(i64_start);
  prog.BeginProgram;
  UpdateAllSystemAndTimers(PLCState);
  PLCStateToScriptState(Prog, PLCState, PrevPLCState);

  DoLogging(PLCState);
//  PLCStateHist[PLCStateHistCursor]:=PLCState;
  PrevPLCState:=PLCState;

  //TProgramState = (psUndefined, psReadyToRun, psRunning, psRunningStopped, psTerminated);
  try
    prog.RunProgram;
  except
    on E: Exception do begin
      StopRunningProgram;
      StatusBar.Panels[3].Text:=E.Message;
      StatusBar.Panels[4].Text:=E.Message;
      //showmessage(E.Message);  // DANGER
    end;
  end;

  if prog.ProgramState = psRunningStopped then begin
    StopRunningProgram;
    //StatusBar.Panels[3].Text:='Timeout';
    StatusBar.Panels[4].Text:='Timeout/Break';
    //ScriptState:=ssUndefined;
  end;

  ScriptStateToPLCState(Prog, PLCState);
  prog.EndProgram;
  queryperformancecounter(i64_end);

  inc(ProgCyclesCount);
//    MemoResult.Text := Tdws2DefaultResult( Prog.Result).Text;

  QueryPerformanceFrequency(i64_freq);
  //EditDebug.Text:=format('%f',[1000*(i64_end-i64_start)/i64_freq]);

  if Prog.Msgs.HasExecutionErrors then begin
    LBErrors.Items.clear;
    LBErrors.Items.Add('RunTime Errors:'+ inttostr(Prog.msgs.count));
    LBErrors.Items.Add(trim(Prog.msgs.asstring));
    ScriptState:=ssReadyToRun;  // What happens if runtime error ???
    PageControlBottom.ActivePageIndex:=1;  // Select Errors Tab
    BBRun.Enabled  := True;
    BBStop.Enabled := False;
    exit;
  end;

//  if ScriptState<>ssRunning then begin
    MemoResult.Text := Tdws2DefaultResult( Prog.Result).Text;
    PageControlBottom.ActivePageIndex:=0;  // Select Output tab
//  end;
  }

end;


procedure debug_PLC_Bits(const aMemo : TMemo; aBitArray : array of boolean);
var
  i : integer;
  s : string;
begin
  s:='';
  for i:=low(aBitArray) to High(aBitArray) do begin
    if (i mod 8)=0 then s:=s+'|' else if (i mod 4)=0 then s:=s+' ';
    if (aBitArray[i]) then s:=s+'1' else s:=s+'0';
  end;
  aMemo.Append(s);
end;

//RunOnceIOAware
Var ReEntering : boolean;
Var ToggleReadTurn : boolean;
procedure TFMain.RunOnceIOAware(running: boolean);
var
  recData: DWord;
  tempDWORD : DWORD;
  DataBuf: array of Boolean;
  WordsBuf: array of Word;
  i : integer;
  MBReadResult : boolean;
  msg : RawByteString;
  HighOfCommsArray : integer;
begin

  if ReEntering then begin
    StatusBar.Panels[4].Text:='Cycle Time Error (re-entering!)';
    exit;
  end;

  ReEntering := true;
  ToggleReadTurn := not ToggleReadTurn;
  try

    // Bug AJS Março2017
    ////    MemoDebugMB.Clear;
    ////    debug_PLC_Bits(MemoDebugMB,PLCState.InBits);
    ////    debug_PLC_Bits(MemoDebugMB,PLCState.OutBits);

    // GetHardInputs;
    FIOLeds.ILedsToPLCState(PLCState);
    ////    debug_PLC_Bits(MemoDebugMB,PLCState.InBits);
    FIOLeds.OLedsToPLCState(PLCState);
    ////    debug_PLC_Bits(MemoDebugMB,PLCState.InBits);

    if running then RunOnce;
    // If forced then force manual Outputs
    FIOLeds.ILedsToPLCState(PLCState);
    ////    debug_PLC_Bits(MemoDebugMB,PLCState.InBits);
    FIOLeds.OLedsToPLCState(PLCState);
    ////    debug_PLC_Bits(MemoDebugMB,PLCState.InBits);

    // SetHardOutPuts

    recData:=$FFFFFFFF;

    if Project.WinMsg then begin
      try
        tempDWORD := bitsToDWord(PLCState.OutBits);
        ////        MemoDebugMB.Append(Format('T=%X',[tempDWORD]));
        recData:=WMCommunication(pchar(SimTargetForm[SimLevel]), cmwLevel+SimLevel, tempDWORD); // working
        ////        MemoDebugMB.Append(Format('T=%X',[tempDWORD]));
        ////        MemoDebugMB.Append(Format('R=%X',[recData]));
        if recData<>$FFFFFFFF Then
            DWordToBits(PLCState.InBits,recData); //// working:
            ////        MemoDebugMB.Append(Format('T=%X',[tempDWORD]));
            ////        MemoDebugMB.Append(Format('R=%X',[recData]));
            ////        MemoDebugMB.Append(Format('In =%X',[bitsToDWord(PLCState.InBits )]));
            ////        MemoDebugMB.Append(Format('Out=%X',[bitsToDWord(PLCState.OutBits)]));
      except
      end;
    end;

    // Application.ProcessMessages(); // Ver se nã necessário AJS 201905

    /////////////////////////////////
    //////// MODBUS SEND
    //MB_TAG
    /////////////////////////////////
    if Project.ModBus and TCP.Connected then begin
      // write Modbus outputs
      // For andre restivo simulator => WriteCoils
      SetLength(DataBuf,Project.MBNWrite);
      FillChar(DataBuf[0], Length(DataBuf), 0);
      SetLength(WordsBuf,1+(Project.MBNWrite div 16));
      FillChar(WordsBuf[0], Length(WordsBuf), 0);

      MBReadResult := false;
      if not ToggleReadTurn then begin
        HighOfCommsArray := min(high(PLCState.OutBits), Project.MBNWrite-1);
        if (Project.MBFunc < 2) then begin  // Time to write
          for i:=low(PLCState.OutBits) to HighOfCommsArray do begin
            DataBuf[i]:=PLCState.OutBits[i];  // Melhorar...   WRITING MB
            ModBusNEW.Coils[Project.MBOffs_O + i] := PLCState.OutBits[i]; //AJS 201905
          end;
          //MBReadResult := MBWriteCoils(Project.MBOffs_O+1, Project.MBNWrite, DataBuf);
          //AJS 201905
          msg := ModBusNEW.WriteMultipleCoils(1,Project.MBOffs_O, Project.MBNWrite);
          TCP.SendMessage(msg);
          //Application.ProcessMessages;
        end
        else if Project.MBFunc = 2 then begin
          BitsToWords(PLCState.OutBits,WordsBuf);
          MBReadResult := MBWriteRegisters(Project.MBOffs_O+1, WordsBuf); // to be improved... Pre 201905 Stuff
        end;
      end;

      //if MBReadResult then
      //  EditMsgdebug.Text:='MB Wr OK'
      //else  begin
      //  EditMsgdebug.Text:='MB Wr  Err'; // return False => error
      //  //Project.ModBus:=false; //MB_TAG
      //end;

      /////////////////////////////////
      // Read Modbus Input Bits
      /////////////////////////////////

      // 201905 To be done async
      if ToggleReadTurn then begin
        ////msg := ModBusNEW.ReadMultipleCoils(1, Project.MBOffs_I, Project.MBNRead); //// AJS 2020
        msg := ModBusNEW.RequestReadMultiple(1, Project.MBOffs_I, Project.MBNRead); //// AJS 2020
        TCP.SendMessage(msg);
      end;

      {OLD MODBus AJS 201905
      SetLength(DataBuf,Project.MBNRead);
      FillChar(DataBuf[0], Length(DataBuf), 0);
      SetLength(WordsBuf,Project.MBNRead);
      FillChar(WordsBuf[0], Length(WordsBuf), 0);
      }
      // For andre restivo simulator => ReadInputBits
      // For STB                     => ReadHoldingRegs

      // AJS 201905
      //if Project.MBFunc = 0 then begin
      // AJS 201905        MBReadResult := MBReadCoils(Project.MBOffs_I+1, Project.MBNRead, DataBuf);
      //end else
      //if Project.MBFunc = 1 then begin
      // AJS 201905       MBReadResult := MBReadInputBits(Project.MBOffs_I+1, Project.MBNRead, DataBuf);
      //end else if Project.MBFunc = 2 then begin
      //  MBReadResult := MBReadHoldingRegisters(Project.MBOffs_I+1, Project.MBNRead, WordsBuf);
      //end;

      // 201905 To be done async
      //if MBReadResult then begin
      //  EditMsgdebug.Text := EditMsgdebug.Text + '; MB Rd OK';
      //  recData:=0;  // Flag receive OK for compatibility with prev version
      //  {FA_Resolvido}
      //  FIOLeds.ILedsToPLCState(PLCState);

      //  if Project.MBFunc < 2 then begin
      //    for i:=low(dataBuf) to high(dataBuf) do PLCState.InBits[i]:=DataBuf[i];
      //  end else begin
      //    WordsToBits(WordsBuf, PLCState.InBits);
      //  end;
      //end
      //else begin
      //  EditMsgdebug.Text := EditMsgdebug.Text + '; MB Rd Err'; // return False => error
      //  recData:=$FFFFFFFF;  // Flag error for compatibility with prev resion
      //end;

      // Application.ProcessMessages(); // Ver se nã necessário AJS 201905
    end;

////    debug_PLC_Bits(MemoDebugMB,PLCState.InBits);
    FIOLeds.PLCStateToIOLeds(PLCState);
////    debug_PLC_Bits(MemoDebugMB,PLCState.InBits);

    //StatusBar.Panels[3].Text := '';
    if running and (ScriptState=ssRunning) then  StatusBar.Panels[3].Text := 'Run';
    if running and (ScriptState<>ssRunning) Then StatusBar.Panels[3].Text := 'Run__1__';
    if not running Then StatusBar.Panels[3].Text := 'NotRun';

    if Project.WinMsg and Project.ModBus then begin
      StatusBar.Panels[3].Text := StatusBar.Panels[3].Text + ' WinMsg+MB'
    end else begin
      if Project.WinMsg then
        StatusBar.Panels[3].Text := StatusBar.Panels[3].Text + ' WinMsg'
      else
        if Project.ModBus then
          StatusBar.Panels[3].Text := StatusBar.Panels[3].Text + ' MB'
        else
          StatusBar.Panels[3].Text := StatusBar.Panels[3].Text + ' No Targ!'
    end;

    // AJS 201905 Make connection visible
//    if recData=$FFFFFFFF then begin
//      StatusBar.Panels[3].Text := StatusBar.Panels[3].Text + ' NO Sim';
//      FIOLeds.LabelConnected.Caption:='NOT Connected';
//      FIOLeds.LabelConnected.Font.Color:=clRed and $555555;
//    end else begin
//      StatusBar.Panels[3].Text := StatusBar.Panels[3].Text + ' Sim_OK';
//      FIOLeds.LabelConnected.Font.Color:=clDkGray;
//      FIOLeds.LabelConnected.Caption:='connected ok';
//    end;

    if Project.ModBus and not TCP.Connected then
      StatusBar.Panels[3].Text := StatusBar.Panels[3].Text + ' MB Conn Err';


  except
    StatusBar.Panels[3].Text := StatusBar.Panels[3].Text + ' MB ERR 999';
  end;
  Application.ProcessMessages();
  ReEntering := False;

end;


procedure CopyFromCoilsToInputs(const Coils: array of boolean);
var i : integer;
begin
  for i:=low(PLCState.InBits) to high(PLCState.InBits) do begin
    PLCState.InBits[i]:=Coils[i];  // RUNIOAware AJS 201905
  end
end;

//StartRunningProgram
procedure TFMain.StartRunningProgram;
begin

  if (ScriptState=ssReadyToRun) then begin
    BBRun.Enabled  := False;
    BBStop.Enabled := True;
    FormG7.BBRun_GR7.Enabled:= False;
    FormG7.BBStop_GR7.Enabled:= True;

    BBStop.Enabled := True;
    LBErrors.Items.Clear;

    ScriptState:=ssRunning;  //in  RunOnceIOAware();
    ProgramStartTime:=MyGetTickCount();

    SynEditST.ReadOnly:=True;
    SynEditST.Gutter.Color    := clLtGray or clRed;
    SynEditST.Color           := clLtGray or clRed;

    FormG7.SynEditST_G7.ReadOnly:=True;
    FormG7.SynEditST_G7.Gutter.Color := clLtGray or clRed;
    FormG7.SynEditST_G7.Color        := clLtGray or clRed;

    if RunTimeBomb then TimerRunTimeBomb.Enabled := True;
  end;
end;

//StopRunningProgram
procedure TFMain.StopRunningProgram;
begin
  BBRun.Enabled  := True;
  BBStop.Enabled := False;
  FormG7.BBRun_GR7.Enabled:= True;
  FormG7.BBStop_GR7.Enabled:= False;
  LabelWarnObsoleteSt.Visible := False;

  ScriptState:=ssReadyToRun;  // HOT BUG

  SynEditST.ReadOnly:=False;
  SynEditST.Gutter.Color    := clBtnFace;
  SynEditST.Color           := clWindow;
  FormG7.SynEditST_G7.ReadOnly:=False;
  FormG7.SynEditST_G7.Gutter.Color  := clBtnFace;
  FormG7.SynEditST_G7.Color         := clWindow;

  StatusBar.Panels[3].text:='';
  TimerRunTimeBomb.Enabled := false;
end;

//ApplicationEventsMessage
//procedure TFMain.ApplicationEventsMessage(var Msg: tagMSG; var Handled: Boolean);
//begin
    (*
  if Msg.message = $8FFF{CM_EXECPROC} then begin
    PeriodicTimerEvent;
    Handled:=true;
  end;
   *)
//end;

//TIMER FEUPAutom
procedure TFMain.FA_TimerTimer(Sender: TObject);
begin
  (*  PERIODIC TIMER to run all the stuff  *)
  if( ScriptState=ssRunning)then begin
    if (PLCState.SysWords[0] and 1)>0 then begin
      if (EditAnimation.Text[1]='|') then EditAnimation.Text:='/'
      else
        if (EditAnimation.Text[1]='/') then EditAnimation.Text:='-'
      else
        if (EditAnimation.Text[1]='-') then EditAnimation.Text:='\'
      else
        EditAnimation.Text:='|';
      EditAnimation.Invalidate;
    end;
    if (Project.Grafcet) then begin
      FormG7.EditAnimation.Text:=EditAnimation.Text;
      FormG7.EditAnimation.Invalidate;
    end;
    Application.ProcessMessages;
    PeriodicTimerEvent;
    //Application.ProcessMessages;
  end;
end;

//PeriodicTimerEvent
procedure TFMain.PeriodicTimerEvent;
var InterCallTime, RunTime : Longword;
begin
  ScriptStartTime:=MyGetTickCount();
  InterCallTime:= ScriptStartTime - ScriptLastTime;

  RunOnceIOAware(ScriptState=ssRunning);

  RunTime:=MyGetTickCount()-ScriptStartTime;
  ScriptTotalRunTime:=ScriptTotalRunTime + RunTime;
  if ProgCyclesCount mod 10 = 0 then
    EditDebug.text:=Format('%.4d, %f',[InterCallTime, ScriptTotalRunTime/max(1,ProgCyclesCount)]);
  ScriptLastTime:=ScriptStartTime;
end;


procedure TFMain.MenuAboutClick(Sender: TObject);
begin
  FormSplash.FormStyle:=fsNormal;
  FormSplash.Hide;
  Sleep(20);
  FormSplash.Left := FMain.Left + 20;
  FormSplash.top  := FMain.top + 20;
  FormSplash.Show;
  FormSplash.SetFocus;
end;

procedure TFMain.UpdateStatusLine;
begin
  SynEditSTStatusChange(FMain,[scCaretX, scCaretY,scInsertMode,scModified]);
  StatusBar.Invalidate;
end;

procedure TFMain.MenuStopClick(Sender: TObject);
begin
  StopRunningProgram;
end;

procedure TFMain.MenuRunOnceClick(Sender: TObject);
begin
  if (ScriptState=ssRunning) then exit;

  Compile;

  if (ScriptState=ssReadyToRun) then RunOnceIOAware(true);
end;



procedure TFMain.SynEditSTStatusChange(Sender: TObject;  Changes: TSynStatusChanges);
begin

if (sender.ClassName<>'TSynEdit') then exit;

  with (sender as TSynEdit) do
    if (scCaretX in Changes) or (scCaretY in Changes) then
      StatusBar.Panels[0].Text := format('%6d: %3d',[CaretY, CaretX]);

  if scInsertMode in Changes then begin
    if SynEditST.InsertMode then begin
      StatusBar.Panels[2].Text := 'Ins';
    end else begin
      StatusBar.Panels[2].Text := 'Ovwr';
    end;
  end;

  if scModified in Changes then begin
    ScriptState:=ssUndefined;
    if (SynEditST.Modified) or (Project.Modified) then begin
      Project.Modified:=true;
      StatusBar.Panels[1].Text := 'M*';
    end else begin
      StatusBar.Panels[1].Text := '';
    end;
  end;

  StatusBar.Invalidate;

end;


function FixLineNumberErrWarn(const txt : string; const offset: integer): string;
var p1, p2, p3 : integer;
    s,outstr: string;
begin
  p1:= max(pos('[Error] (',txt),pos('[Warning] (',txt));
  if (p1=0) then exit;
  if (copy(txt,1,4)='[Err') then
    outstr:='[Error] (Ln:'
  else
    outstr:=' [Warn] (Ln:';
  p1:= pos('(',txt)+1;
  p2:= pos(':',txt);
  p3:= pos('):',txt);
  if ((p1>0) and (p2>0) and (p3>0)) then begin
    s:=copy(txt,p1,p2-p1);
    outstr:=outstr+IntToStr(strToIntdef(s,-1)+offset);
    s:=copy(txt,p3,Length(txt)-p3+1);
    outstr:=outstr+s;
    result:=outstr;
  end;
end;


function GetErrWarnLine(const txt : string) : integer ;
var p1, p3 : integer;
    s: string;
begin
  result:=-1;

  p1:= pos(':',txt);
  p3:= pos(')',txt);
  if (p1>0) and (p3>0) then begin
    s:=copy(txt,p1+1,p3-p1-1);
    result:=strToIntdef(s,-1);
  end;
end;


procedure TFMain.LBErrorsClick(Sender: TObject);
var txt: string;
    i: integer;
begin
  i:= LBErrors.ItemIndex;
  if i<0 then exit;
  txt:=LBErrors.Items[i];

  {FA_Resolvido}
  SynEditST.caretX:=0;
  SynEditST.caretY:=GetErrWarnLine(txt);
  SynEditST.SetFocus;
end;

procedure TFMain.MenuUndoClick(Sender: TObject);
begin
  SynEditST.Undo;
end;

procedure TFMain.MenuRedoClick(Sender: TObject);
begin
  SynEditST.Redo;
end;


procedure TFMain.BTestWMClick(Sender: TObject);
var recData: DWord;
begin
  {FA_Resolvido}
  FIOLeds.OLedsToPLCState(PLCState);
  recData:=WMCommunication(pchar(SimTargetForm[SimLevel]), cmwData , bitsToDWord(PLCState.OutBits));
  DWordToBits(PLCState.InBits,recData);
  FIOLeds.PLCStateToIOLeds(PLCState);
  EditDebug.text:=inttohex(recdata,8);
end;


function TFMain.WMCommunication(App: string; Command, data: DWord): DWord;
var destH: THandle;
   copyDataStruct : TCopyDataStruct;
begin
  result:=$FFFFFFFF;  // HOT BUG FIX AJS
  destH := FindWindow(pchar(App), nil);
  if destH = 0 then exit;

  copyDataStruct.dwData := Command;  // MArço 2017
  copyDataStruct.cbData := data;
  copyDataStruct.lpData := nil;

  result := SendMessage(destH, WM_COPYDATA, PtrInt(Handle), PtrInt(@copyDataStruct));
end;

function KillApp(const sApp: PChar) : boolean;
var AppHandle:THandle;
begin
  result:=false;
  AppHandle:=FindWindow(sApp, Nil) ;
  if AppHandle=0 then exit;
  Result:=PostMessage(AppHandle, WM_QUIT, 0, 0) ;
  Sleep(50);
end;


procedure TFMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  KillApp(pchar(SimTargetForm[SimLevel]));
  GlobalMemIni.WriteString('Project','ActiveProject',Project.FileName);
  GlobalMemIni.UpdateFile;
end;

procedure TFMain.MenuGrafcetViewClick(Sender: TObject);
begin
  if (not FormViewG7.Visible) then begin
    FormViewG7.Caption := 'View Grafcet';
    FormViewG7.Visible:=True;
    FormViewG7.PairSplitRight.Color:=clYellow;
    FormViewG7.Panel2Right.Width := 0;
    //FormViewG7.Panel2Right.Resize := 0; // TODO - prevent resizing!!!
  end;
  FormViewG7.BringToFront;
end;

procedure TFMain.MenuShowSelfGradClick(Sender: TObject);
begin
  FormG7.MenuShowSelfGradeClick(Sender);
end;

procedure TFMain.MenuWindowSelfGradeGr7Click(Sender: TObject);
begin
  MenuGrafcetClick(Sender);
  FormG7.MenuShowSelfGradeClick(Sender);
end;

procedure TFMain.MenuStartGradingClick(Sender: TObject);
begin
  MenuGrafcetClick(Sender);
  FormG7.MenuStartStopGradingClick(Sender);
end;

procedure TFMain.TCPAccept(aSocket: TLSocket);
begin

end;

procedure TFMain.TCPConnect(aSocket: TLSocket);
begin
  MemoDebugMB.Append('Connected');
end;

procedure TFMain.TCPDisconnect(aSocket: TLSocket);
begin
    MemoDebugMB.Append('Disconnected :( ');
end;

procedure TFMain.TCPError(const msg: string; aSocket: TLSocket);
begin
    MemoDebugMB.Append(msg);
end;


procedure TFMain.BIniRunClick(Sender: TObject);
begin
  MenuClearAllClick(Sender);
  MenuRunClick(Sender);
end;

procedure TFMain.BMBSampleReadClick(Sender: TObject);
var
  recData: DWord;
  tempDWORD : DWORD;
  DataBufBoolArray: array of Boolean;
  WordsBuf: array of Word;
  i : integer;
  MBReadResult : boolean;
begin


  if not TCP.Connected then begin
    MemoDebugMB.Append('Begin try to connect');
    bFactioClick(nil);
    Application.ProcessMessages;
    if not TCP.Connected then begin
      MemoDebugMB.Append('Not Connected xxxxxx');
      exit;
    end;
  end;

  application.ProcessMessages();

  // Sample Read Modbus Input Bits
  MBReadResult := false;
  SetLength(DataBufBoolArray,Project.MBNRead);
  FillChar(DataBufBoolArray[0], Length(DataBufBoolArray), 0);
  MBReadResult := MBReadCoils(Project.MBOffs_I+1, Project.MBNRead, DataBufBoolArray);
  MemoDebugMB.Append(BoolToStr(MBReadResult,'ReadCoils OK', 'Err ReadCoils NOK xx'));
//  MBReadResult := MBReadInputBits(Project.MBOffs_I+1, Project.MBNRead, DataBufBoolArray);
//  MemoDebugMB.Append(BoolToStr(MBReadResult,'ReadInpBits OK', 'Err ReadInpBits NOK xx'));
  for i:=low(DataBufBoolArray) to high(DataBufBoolArray) do PLCState.InBits[i]:=DataBufBoolArray[i];
  debug_PLC_Bits(MemoDebugMB,PLCState.InBits);
  application.ProcessMessages();

end;

procedure TFMain.Button2Click(Sender: TObject);
var
        msg : RawByteString;
        i , HighOfCommsArray : integer;
begin

  //AJS 201905
  HighOfCommsArray := min(high(PLCState.OutBits), Project.MBNWrite-1);
  if (Project.MBFunc < 2) then begin
    for i:=low(PLCState.OutBits) to HighOfCommsArray do begin
      ModBusNEW.Coils[Project.MBOffs_O + i] := PLCState.OutBits[i]; //AJS 201905
    end;
    //AJS 201905
    msg := ModBusNEW.WriteMultipleCoils(1,Project.MBOffs_O, Project.MBNWrite);
    TCP.SendMessage(msg);
  end;
  Application.ProcessMessages;

end;


procedure DumpExceptionCallStack(E: Exception); // http://wiki.freepascal.org/Logging_exceptions
var
  I: Integer;
  Frames: PPointer;
  Report: string;
begin
  Report := 'Program exception! ' + LineEnding +
    'Stacktrace:' + LineEnding + LineEnding;
  if E <> nil then begin
    Report := Report + 'Exception class: ' + E.ClassName + LineEnding +
    'Message: ' + E.Message + LineEnding;
  end;
  Report := Report + BackTraceStrFunc(ExceptAddr);
  Frames := ExceptFrames;
  for I := 0 to ExceptFrameCount - 1 do
    Report := Report + LineEnding + BackTraceStrFunc(Frames[I]);
  ShowMessage(Report);
  Halt; // End of program execution
end;


procedure TFMain.bFactioClick(Sender: TObject);
var i : integer;
begin
  TCP.Disconnect;
  sleep(300);

  try // Copy Stuff
    Project.MBIP     := EditMBIP.Text;
    Project.MBPort   := StrToInt(EditMBPort.Text);
    Project.ModBus   := True;
    Project.MBNRead  := StrToInt(EditMBNRead.text);
    Project.MBNWrite := StrToInt(EditMBNWrite.text);
    Project.MBOffs_I := StrToInt(EditMBOffs_I.Text);
    Project.MBOffs_O := StrToInt(EditMBOffs_O.Text);
    Project.Period   := StrToInt(EditPeriodMiliSec.Text);
    Project.MBFunc   := RGMBReadFunc.ItemIndex;
  except
    on E : Exception do begin
      DumpExceptionCallStack(E);
      MemoDebugMB.Append('FactIO Exception'+E.Message);
      exit;
    end;
    on E : exception do exit;
  end;

  try // Try to connect
    if (Project.ModBus) then begin
      TCP.Host:=Project.MBIP;
      TCP.Port:=Project.MBPort;
      sleep(1);
      TCP.Connect (Project.MBIP,Project.MBPort);
      sleep(1);
      for i := 0 to 20 do begin
        sleep(50);
        Application.ProcessMessages;
        //Application.HandleMessage;
        if TCP.Connected then begin MemoDebugMB.Append('   Connect OK   '); break; end;
        MemoDebugMB.Append(IntToStr(i) +
                          BoolToStr(TCP.Connecting,' Connecting',  ' Not Connecting') +
                          BoolToStr(TCP.Connected,' / Connected',' / Not Connected'));
      end;
    end;
  except
    on E: Exception do begin
      DumpExceptionCallStack(E);
      MemoDebugMB.Append('FactIO Exception'+E.Message);
    end;
  end;
  RunOnceIOAware(false);
end;


procedure TFMain.BMBStatusCheckClick(Sender: TObject);
begin
  if TCP.Connected then MemoDebugMB.Append('Conn OK');
  if TCP.Connecting then MemoDebugMB.Append('...Connecting...');
  if not TCP.Connecting and
     not TCP.Connected  then MemoDebugMB.Append('Not connected xxx');
end;

procedure TFMain.BMBSampleWriteClick(Sender: TObject);
var
  recData: DWord;
  tempDWORD : DWORD;
  DataBufBoolArray: array of Boolean;
  WordsBuf: array of Word;
  i : integer;
  MBReadResult : boolean;
begin


  if not TCP.Connected then begin
    MemoDebugMB.Append('Begin try to connect');
    bFactioClick(nil);
    Application.ProcessMessages;
    if not TCP.Connected then begin
      MemoDebugMB.Append('Not Connected xxxxxx');
      exit;
    end;
  end;


  // Clean
  SetLength(DataBufBoolArray,Project.MBNWrite);
  FillChar(DataBufBoolArray[0], Length(DataBufBoolArray), 0);
  SetLength(WordsBuf,1+(Project.MBNWrite div 16));
  FillChar(WordsBuf[0], Length(WordsBuf), 0);

  //Read LEDs FEUPAutom
  //FIOLeds.ILedsToPLCState(PLCState);
  FIOLeds.OLedsToPLCState(PLCState);
  //debug_PLC_Bits(MemoDebugMB,PLCState.InBits);
  PLCState.OutBits[0] := not PLCState.OutBits[0];
  PLCState.OutBits[1] := not PLCState.OutBits[1];
  debug_PLC_Bits(MemoDebugMB,PLCState.OutBits);


  // Sample Write Modbus FEUPAutom Bits
  MBReadResult := false;
  for i:=low(DataBufBoolArray) to high(DataBufBoolArray) do begin
    DataBufBoolArray[i]:=PLCState.OutBits[i];  // Melhorar...   WRITING MB
  end;
  TCP.Timeout := 100;
  MBReadResult := MBWriteCoils(Project.MBOffs_O+1, Project.MBNWrite, DataBufBoolArray);
  MemoDebugMB.Append(BoolToStr(MBReadResult,'WriteCoils OK', 'WriteCoils NOK xx'));

  application.ProcessMessages();

end;



procedure TFMain.CBGrafcetChange(Sender: TObject);
begin
  MenuGrafcet.Enabled:=CBGrafcet.Checked;
  Project.Grafcet:=CBGrafcet.Checked;
end;

procedure TFMain.MenuLocalHelpClick(Sender: TObject);
begin
//FA_TAG:
   OpenDocument('help\FEUPAutom_help.pdf');
end;

procedure TFMain.MenuSelectTargetClick(Sender: TObject);
var destH: THandle;
begin
  MenuSimplePark.Checked:=false;
  MenuSimplePark2.Checked:=false;
  MenuParkTwoBarriers.Checked:=false;
  MenuThunderbird.Checked:=false;
  MenuGate.Checked:=false;
  SimLevel:=(Sender as TmenuItem).Tag;
  case simlevel of
    0 : MenuSimplePark.Checked:=True;
    1 : MenuSimplePark2.Checked:=True;
    2 : MenuParkTwoBarriers.Checked:=True;
    3 : MenuThunderbird.Checked:=True;
    4 : MenuGate.Checked:=True;
  end;

  CBModBus.Checked:=False;
  CBWinMessages.Checked:=True;
  BSetParamsClick(Sender);

  destH := FindWindow(pchar(SimTargetForm[SimLevel]), nil);

  if destH = 0 then begin
     OpenDocument(pchar(SimTargetExe[SimLevel])); //Converted from ShellExecute
  end;


end;

procedure TFMain.FormInit;
begin
  {FA_Resolvido}
  SynEditST.Text:='';
  LBErrors.Clear;
  MemoResult.Clear;
  SynEditPascal.Text:='';
  SynEditST.Modified:=False;
  EditPeriodMiliSec.Text := '39';
  CBGen_C_Code.Checked:=false;
  CBGrafcet.Checked:=false;
  BSetParamsClick(nil);
end;


procedure TFMain.MenuNewClick(Sender: TObject);
begin


  if Project.Modified and (trim(SynEditST.Text)<>'') then begin
    if MessageDlg('Old project was changed.'+crlf+
                  'Start a new project ?',
                  mtConfirmation , [mbOk,mbCancel], 0)
       = mrCancel then exit;
  end;


  ProjectNew;
end;



procedure TFMain.MenuOpenClick(Sender: TObject);
begin
  {FA_Resolvido}
  Sleep(1);
  if Project.Modified and (trim(SynEditST.Text)<>'') then  begin
    if MessageDlg('Project Modified.'+crlf+
                  'Loading will lose changes since last save.'+crlf+
                  'Open Project ?',
                  mtConfirmation , [mbOk,mbCancel], 0)
       = mrCancel then exit;
       if (not FileExists(OpenDialog.FileName)) then exit; // TODO: queixar ao utilizador
  end;

  Sleep(1);

  if OpenDialog.initialDir ='' then OpenDialog.initialDir:=extractFilePath(Application.ExeName);

  if (not OpenDialog.Execute) then exit;

  if (not ProjectOpen(OpenDialog.FileName)) then begin
    ProjectNew;
  end;

  UpdateStatusLine;

  if(CBGrafcet.Checked)then  begin
    FormG7.GenSTCode();
    FormG7.MenuG7STCompileClick(Sender);//FA_RESOLVIDO = problema dos enters, solução nao permanente (com o novo Save/LOAD já nao acontece o problema, mas mantevesse isto até encontrar a origem)
  end;

  FMain.MenuClearAllClick(Sender); //Ter a certeza que inicia com tudo limpo
  exit;

end;



procedure TFMain.MenuSaveClick(Sender: TObject);
var
  FileName: string;
begin
  FileName:= Project.FileName;
  if  FileName = 'Untitled' then begin
    if (SaveDialog.initialDir ='') then SaveDialog.initialDir:=extractFilePath(Application.ExeName);
    if (not SaveDialog.Execute) then exit;
    FileName := SaveDialog.FileName;
  end;
  BSetParamsClick(Sender);
  ProjectSaveFA5(FileName);
end;

procedure TFMain.MenuSaveAsClick(Sender: TObject);
begin
  if not SaveDialog.Execute then exit;
  BSetParamsClick(Sender);
  ProjectSaveFA5(SaveDialog.FileName);
end;


procedure TFMain.FormSave(ProjMemIni : TMemIniFile);
begin
  {FA_Resolvido}
  SaveStringsToMemIni(ProjMemIni, 'Main','STText',SynEditST.lines);


  ProjMemIni.WriteInteger('Main','ActiveTab',PageControl.ActivePageIndex);
  ProjMemIni.WriteInteger('Main','MessagesHeight',max(PageControlBottom.Height,Splitter1.MinSize));  // corrige bug splitter nulo

  ProjMemIni.WriteString('Main','ProjectAuthor',Project.Author);
  ProjMemIni.WriteString('Main','ProjectComments',Project.Comments);
  ProjMemIni.WriteInteger('Main','ProjectGrafcet',ord(Project.Grafcet));
  ProjMemIni.WriteInteger('Main','ProjectGen_C_Code',ord(Project.Gen_C_Code));

  ProjMemIni.WriteString ('Main','ModBusIP',    Project.MBIP);
  ProjMemIni.WriteInteger('Main','ModBusPort',  Project.MBPort);
  ProjMemIni.WriteInteger('Main','ModBusNRead', Project.MBNRead);
  ProjMemIni.WriteInteger('Main','ModBusNWrite',Project.MBNWrite);
  ProjMemIni.WriteInteger('Main','ModBusOffs_I',Project.MBOffs_I);
  ProjMemIni.WriteInteger('Main','ModBusOffs_O',Project.MBOffs_O);
  ProjMemIni.WriteInteger('Main','ModBusFunc',  Project.MBFunc);
  ProjMemIni.WriteBool   ('Main','ModBus',      CBModBus.Checked);
  ProjMemIni.WriteInteger('Main','Period',      Project.Period);
  ProjMemIni.WriteBool   ('Main','WinMsg',      CBWinMessages.Checked);

  SaveFormGeometryToMemIni(ProjMemIni,FMain);

end;

procedure TFMain.FormLoad(ProjMemIni : TMemIniFile);
begin

  LoadStringsFromMemIni(ProjMemIni, 'Main','STText',SynEditST.lines);


  PageControl.ActivePageIndex := ProjMemIni.ReadInteger('Main','ActiveTab',PageControl.ActivePageIndex);
  PageControlBottom.Height := ProjMemIni.ReadInteger('Main','MessagesHeight',PageControlBottom.Height);

  Project.Author     := ProjMemIni.ReadString('Main','ProjectAuthor',Project.Author);
  Project.Comments   := ProjMemIni.ReadString('Main','ProjectComments',Project.Comments);
  Project.Grafcet    := ProjMemIni.ReadBool('Main','ProjectGrafcet',True) ;
  Project.Gen_C_Code := ProjMemIni.ReadBool('Main','ProjectGen_C_Code',True) ;
  try
    if Project.Grafcet then FormG7.G7LoadXML(ChangeFileExt(Project.FileName, '.g7.xml'),true,nil);
  except
  end;

  Project.MBIP     := ProjMemIni.ReadString ('Main','ModBusIP',    '127.0.0.1');
  Project.MBPort   := ProjMemIni.ReadInteger('Main','ModBusPort',  502);
  Project.MBOffs_I := ProjMemIni.ReadInteger('Main','ModBusOffs_I',0);
  Project.MBOffs_O := ProjMemIni.ReadInteger('Main','ModBusOffs_O',0);

  {FA_Resolvido}
  Project.MBNRead  := ProjMemIni.ReadInteger('Main','ModBusNRead', MaxInBits);
  Project.MBNWrite := ProjMemIni.ReadInteger('Main','ModBusNWrite', MaxOutBits);

  Project.MBFunc   := ProjMemIni.ReadInteger('Main','ModBusFunc', 0);
  Project.ModBus   := ProjMemIni.ReadBool('Main','ModBus', False );
  Project.WinMsg   := ProjMemIni.ReadBool('Main','WinMsg', False );
  Project.Period   := ProjMemIni.ReadInteger('Main','Period', 500);

  EditMBIP.text     := Project.MBIP;
  EditMBPort.text   := IntToStr(Project.MBPort);
  EditMBNRead.text  := IntToStr(Project.MBNRead);
  EditMBNWrite.text := IntToStr(Project.MBNWrite);
  EditMBOffs_I.text := IntToStr(Project.MBOffs_I);
  EditMBOffs_O.text := IntToStr(Project.MBOffs_O);
  RGMBReadFunc.ItemIndex := Project.MBFunc;
  EditPeriodMiliSec.text := IntToStr(Project.Period);

  CBModBus.Checked := Project.ModBus;
  CBWinMessages.Checked:= Project.WinMsg;

  FormG7.Visible             := Project.Grafcet;
  FMain.CBGrafcet.Checked    := Project.Grafcet;
  FMain.MenuGrafcet.Enabled  := Project.Grafcet;
  FMain.CBGen_C_Code.Checked := Project.Gen_C_Code;
  CBGen_C_CodeClick(nil);

  LoadFormGeometryFromMemIni(ProjMemIni,FMain);

  //BSetParamsClick(nil); chamado mais tarde no fecho do splash screen, associado a um timer
end;


procedure TFMain.MenuOnlineHelpClick(Sender: TObject);
begin
  {FA_Resolvido}
  OpenURL('http://paginas.fe.up.pt/~asousa/wiki/doku.php?id=proj:feupautom'); //Converted from ShellExecute

end;

procedure TFMain.FormShow(Sender: TObject);
begin

  if not FileExists(extractFilePath(Application.ExeName)+'ST\ST_Header.pas') then begin
    ShowMessage('MUST unpack all files with directores!!!'+crlf+'(Error with    ST/ST_Header.PAS File  )');
    FMain.Close;
  end;

  if Startup Then begin
    try
       SynMemoHeader.Lines.LoadFromFile(extractFilePath(Application.ExeName)+'ST\ST_Header.pas');
    except
      on E: Exception do begin
       ShowMessage('Error with ST_Header File'+E.Message);
       ShowMessage('Please correctly unpack all files (keeping directories)... exiting...');
       Application.ProcessMessages;
       FMain.Close;
       Application.ProcessMessages;
       halt;
      end;
    end;
    MenuPascal.Visible := False;
  end;

  if ParamCount=0 then
    Project.FileName:= GlobalMemIni.ReadString('Project','ActiveProject','Untitled')
  else begin
    if UpperCase(ParamStr(1))='-R' then begin
      TimerStartParam.Enabled:=True;
      Project.FileName:=ParamStr(2);
    end else begin
      Project.FileName:=ParamStr(1);
    end;
  end;
  if Project.FileName='Untitled' then begin
    ProjectNew;
  end else begin
    if (not ProjectOpen(Project.FileName)) then begin
      showmessage('Could not open project '+Project.FileName);
      Project.FileName:='Untitled';
      ProjectNew;
    end;
  end;
  BSetParamsClick(Sender);
  Project.Modified := False;
  UpdateStatusLine;
end;

procedure TFMain.FormDestroy(Sender: TObject);
begin
  DestroyMMTimer;
  GlobalMemIni.Free;
end;

//-----------------------------------------------------------------------------
//  `´  `´ Search and replace area code `´  `´  `´  `´  `´  `´  `´  `´  `´  `´

procedure TFMain.DoFindText(Sender: TObject);
var
  {FA_Resolvido}

  rOptions: TSynSearchOptions;

  dlg: TFindDialog;
  sSearch: string;
begin
  if Sender = ReplaceDialog then
    dlg := ReplaceDialog
  else
    dlg := FindDialog;
  sSearch := dlg.FindText;
  if Length(sSearch) = 0 then begin
    Beep;
    StatusBar.Panels[3].Text := 'Can''t search for empty text!';
  end else begin
  {FA_Resolvido}
    rOptions := [];
    if not (frDown in dlg.Options) then
      Include(rOptions, ssoBackwards);
    if frMatchCase in dlg.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in dlg.Options then
      Include(rOptions, ssoWholeWord);
    if SynEditST.SearchReplace(sSearch, '', rOptions) = 0 then begin
      Beep;
      StatusBar.Panels[3].Text := 'SearchText ''' + sSearch + ''' not found!';
    end else
      StatusBar.Panels[3].Text := '';


  end;
end;

procedure TFMain.DoReplaceText(Sender: TObject);
var
  {FA_Resolvido}
  rOptions: TSynSearchOptions;

  sSearch: string;
begin
  sSearch := ReplaceDialog.FindText;
  if Length(sSearch) = 0 then begin
    Beep;
    StatusBar.Panels[3].Text := 'Can''t replace an empty text!';
  end else begin

      {FA_Resolvido}
    rOptions := [ssoReplace];
    if frMatchCase in ReplaceDialog.Options then
      Include(rOptions, ssoMatchCase);
    if frWholeWord in ReplaceDialog.Options then
      Include(rOptions, ssoWholeWord);
    if frReplaceAll in ReplaceDialog.Options then
      Include(rOptions, ssoReplaceAll);
    if SynEditST.SearchReplace(sSearch, ReplaceDialog.ReplaceText, rOptions) = 0
    then begin
      Beep;
      StatusBar.Panels[3].Text := 'SearchText ''' + sSearch +
        ''' could not be replaced!';
    end else
      StatusBar.Panels[3].Text := '';

  end;
end;

procedure TFMain.MenuFindClick(Sender: TObject);
begin
  FindDialog.Execute;


end;


procedure TFMain.MenuReplaceClick(Sender: TObject);
begin
  ReplaceDialog.Execute;
end;


procedure TFMain.ReplaceDialogFind(Sender: TObject);
begin
  DoFindText(Sender);
end;


procedure TFMain.ReplaceDialogReplace(Sender: TObject);
begin
  DoReplaceText(Sender);
end;


procedure TFMain.FindDialogFind(Sender: TObject);
begin
  DoFindText(Sender);
end;

procedure TFMain.FindDialogClose(Sender: TObject);
begin
  StatusBar.Panels[3].Text:='';
end;


procedure TFMain.ReplaceDialogClose(Sender: TObject);
begin
  StatusBar.Panels[3].Text:='';
end;


// ^ ^ Search and replace area code ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^ ^


procedure TFMain.MenuPrintSourceClick(Sender: TObject);
begin
  {FA_TAG:
  SynEditPrint.Title:=extractfilename(Project.FileName);
  if Project.Author<>'' then
    SynEditPrint.Title:=SynEditPrint.Title+' - '+Project.Author;
  SynEditPrint.Title:=SynEditPrint.Title + ' - ' +DateTimeToStr(Now);

  SynEditPrint.Header.Clear;
  SynEditPrint.Footer.Clear;
  SynEditPrint.Lines.Clear;
  SynEditPrint.Lines:=SynEditST.Lines;

  ReallyPrintLines;

}
end;

procedure TFMain.ReallyPrintLines;
begin
  // Using default fonts

  {FA_TAG:
     SynEditPrint.Header.Add( SynEditPrint.Title, nil, taCenter, 1 );
  with SynEditPrint.Footer do begin
    Add('Automação / MIEEC / FEUP', nil, taLeftJustify, 1);
    Add('$PAGENUM$/$PAGECOUNT$', nil, taRightJustify, 1);
  end;

  // show print setup dialog and print
  with PrintDialog do begin
    //Collate := True;
    //Copies := 1;
    //Options := [poPageNums];

    MinPage := 1;
    FromPage := 1;
    MaxPage := SynEditPrint.PageCount;
    ToPage := MaxPage;
    if Execute then begin
      SynEditPrint.Copies := Copies;
      case PrintRange of
        prAllPages: SynEditPrint.Print;
        prPageNums: SynEditPrint.PrintRange(FromPage, ToPage);
      end;
    end;
  end;
}

end;

procedure TFMain.FixSyntaxHighlAndCompletion();
var  i : integer;
     TmpStr : string;
//     StrLst: TStringList;
begin
  SynCompletion.ItemList.Clear;
  SynCompletion.ItemList.Add('if');
  SynCompletion.ItemList.Add('then');
  SynCompletion.ItemList.Add('else');
  SynCompletion.ItemList.Add('elsif');
  SynCompletion.ItemList.Add('end_if');
  SynCompletion.ItemList.Add('true');
  SynCompletion.ItemList.Add('false');
  SynCompletion.ItemList.Add('start');
  SynCompletion.ItemList.Add('writeB');
  SynCompletion.ItemList.Add('writeBln');
  SynCompletion.ItemList.Add('writeI');
  SynCompletion.ItemList.Add('writeILn');
  SynCompletion.ItemList.Add('writeB');
  SynCompletion.ItemList.Add('writeBLn');
  SynCompletion.ItemList.Add('and');
  SynCompletion.ItemList.Add('or');
  SynCompletion.ItemList.Add('not');
  SynCompletion.ItemList.Add('xor');
  SynCompletion.ItemList.Add('re');
  SynCompletion.ItemList.Add('fe');
  SynCompletion.ItemList.Add('PageStart(');
  SynCompletion.ItemList.Add('PageClear(');


  //SynAnySyn_ST.Objects.Clear;
  //SynAnySyn_ST.Objects.add('AAA');
  //SynAnySyn_ST.Objects.add('BBB');
  //SynAnySyn_ST.Objects.add('YYY');
  //SynAnySyn_ST.Objects.add('ZZZ');
  //
  //exit;  /////// HACK

//  StrLst := TStringList.Create;
//  StrLst.Sorted:=true;


  SynAnySyn_ST.Objects.BeginUpdate;
  SynAnySyn_ST.Objects.Clear;

  for i:=1 to FVariables.SGVars.RowCount-1 do begin
    TmpStr := FVariables.SGVars.Cells[1,i];
    if IsValidIdent(TmpStr) then begin  // Add UserName
      SynAnySyn_ST.Objects.Add(UpperCase(TmpStr));
      //StrLst.Add(UpperCase(TmpStr));
      SynCompletion.ItemList.Add(TmpStr);
    end;
  end;

  // Atualizar coisas do editor do FormG7 - Será de proteger?
  FormG7.SynCompletionG7.ItemList.Clear;
  FormG7.SynCompletionG7.ItemList.Text := SynCompletion.ItemList.Text;

  ////StrLst.Sort();
  //for i:=0 to StrLst.Count-1 do begin
  //  SynAnySyn_ST.Objects.Add(StrLst.Strings[i]);
  //end;
  ////SynAnySyn_ST.Objects.CommaText:=StrLst.CommaText;
  ////SynAnySyn_ST.Objects.CleanupInstance; ///??????

  //SynAnySyn_ST.Objects.Text:=StrLst.Text;
  //SynAnySyn_ST.Objects.CommaText:=StrLst.CommaText;
  SynAnySyn_ST.Objects.EndUpdate;
  //DEBUGGGG SynEditC.Text:=StrLst.Text;

  //SynEditST.Highlighter := SynAnySyn_ST; // obrigar a atualizar
  //FormG7.SynEditST_G7.Highlighter := SynAnySyn_ST; // obrigar a atualizar

  FMain.Invalidate;
  //StrLst.Free;
end;



procedure TFMain.MenuPrintVarListClick(Sender: TObject);
//var i,ColOff : integer;
begin
  {FA_TAG:
  SynEditPrint.Title:='FEUP Autom List of Variable Names '+DateTimeToStr(Now);  // TODO: better title Project name, date hour

  SynEditPrint.Header.Clear;
  SynEditPrint.Footer.Clear;
  SynEditPrint.Lines.Clear;

  ColOff:=((FVariables.SGVars.RowCount-1) div 4);
  for i:=0 to ColOff do
    SynEditPrint.Lines.Append(
      format('%-23s%-23s%-23s%-23s',[
        format('%6s = %s',[FVariables.SGVars.Cells[0,i],FVariables.SGVars.Cells[1,i]]),
        format('%6s = %s',[FVariables.SGVars.Cells[0,i+ColOff],FVariables.SGVars.Cells[1,i+ColOff]]),
        format('%6s = %s',[FVariables.SGVars.Cells[0,i+2*ColOff],FVariables.SGVars.Cells[1,i+2*ColOff]]),
        format('%6s = %s',[FVariables.SGVars.Cells[0,i+3*ColOff],FVariables.SGVars.Cells[1,i+3*ColOff]])
      ]));

  ReallyPrintLines;
}


end;


procedure TFMain.MenuPrintSourceVarListClick(Sender: TObject);
//var i,ColOff : integer;
begin
  {FA_TAG:
  // set all properties because this can affect pagination
  SynEditPrint.Title:='FEUP Autom Source Code and List of Variable Names '+DateTimeToStr(Now);  // TODO: better title Project name, date hour

  SynEditPrint.Header.Clear;
  SynEditPrint.Footer.Clear;
  SynEditPrint.Lines.Clear;
  SynEditPrint.Lines.Append('Source Code:');
  SynEditPrint.Lines.Append('============');
  SynEditPrint.Lines.AddStrings(SynEditST.Lines);

  SynEditPrint.Lines.Append('');
  SynEditPrint.Lines.Append('List of Variable Names:');
  SynEditPrint.Lines.Append('=======================');

  ColOff:=((FVariables.SGVars.RowCount-1) div 4);
  for i:=0 to ColOff do
    SynEditPrint.Lines.Append(
      format('%-23s%-23s%-23s%-23s',[
        format('%6s = %s',[FVariables.SGVars.Cells[0,i],FVariables.SGVars.Cells[1,i]]),
        format('%6s = %s',[FVariables.SGVars.Cells[0,i+ColOff],FVariables.SGVars.Cells[1,i+ColOff]]),
        format('%6s = %s',[FVariables.SGVars.Cells[0,i+2*ColOff],FVariables.SGVars.Cells[1,i+2*ColOff]]),
        format('%6s = %s',[FVariables.SGVars.Cells[0,i+3*ColOff],FVariables.SGVars.Cells[1,i+3*ColOff]])
      ]));

  ReallyPrintLines;

  }

end;

procedure TFMain.MenuPascalClick(Sender: TObject);
begin
  TabPascal.TabVisible := not TabPascal.TabVisible;  // CTRL Shift F2
  if TabPascal.TabVisible then PageControl.ActivePage:=TabPascal;
  TabCrypt.TabVisible := not TabCrypt.TabVisible;
end;

{
procedure TFMain.BPrintAllValuesClick(Sender: TObject);
//var i,coloff : integer;
begin

  MemoValues.Lines.Append('Cycle #:'+IntToStr(ProgCyclesCount));
  ColOff:=((FVariables.SGVars.RowCount-1) div 3);
  with FVariables.SGVars do
  for i:=1 to ColOff do
    MemoValues.Lines.Append(
      format('%-30s%-30s%-30s',[
        format('%6s = %s => %d',[Cells[0,i         ],Cells[1,i         ],GetIntegerValueFromAnyVarName(Cells[0,i         ])]),
        format('%6s = %s => %d',[Cells[0,i+ColOff  ],Cells[1,i+ColOff  ],GetIntegerValueFromAnyVarName(Cells[0,i+ColOff  ])]),
        format('%6s = %s => %d',[Cells[0,i+2*ColOff],Cells[1,i+2*ColOff],GetIntegerValueFromAnyVarName(Cells[0,i+2*ColOff])])
//        format('%6s = %s => %d',[Cells[0,i+3*ColOff],Cells[1,i+3*ColOff],GetIntegerValueFromAnyVarName(Cells[0,i+3*ColOff])])
      ]));

end;}

procedure TFMain.BClearListClick(Sender: TObject);
begin
  MemoValues.Clear;
end;

procedure TFMain.MenuVarValuesClick(Sender: TObject);
begin
  TabValues.TabVisible:= not TabValues.TabVisible; // CTRL Shift F11
end;

procedure TFMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  {FA_Resolvido}
  if Project.Modified and (trim(SynEditST.Text)<>'') then begin
    if MessageDlg('Active project was changed.'+crlf+
                  'Exit anyway?',
                  mtConfirmation , [mbOk,mbCancel], 0)
       = mrCancel then CanClose:=false;
  end;


end;

procedure TFMain.EditAuthorsChange(Sender: TObject);
begin
  Project.Author := EditAuthors.Text;
end;

procedure TFMain.EditCommentsChange(Sender: TObject);
begin
  Project.Comments:=EditComments.Text;
end;

procedure TFMain.MenuClearMemoryClick(Sender: TObject);
begin
  {FA_Resolvido}

  zeromemory(@(PLCState.MemWords[0]),sizeof(PLCState.MemWords));
  zeromemory(@(PLCState.MemBits[0]),sizeof(PLCState.MemBits));
end;

procedure TFMain.MenuClearAllIOsClick(Sender: TObject);
var i : integer;
begin
  {FA_Resolvido}
  for i:=0 to MaxInBits-1  do PLCState.InBits[i] :=False;
  for i:=0 to MaxOutBits-1 do PLCState.OutBits[i]:=False;

end;


procedure TFMain.MenuClearSystemClick(Sender: TObject);
var i : integer;
begin

  {FA_Resolvido}
  for i:=0 to MaxSysBits-1  do PLCState.SysBits[i] :=False;
  for i:=0 to MaxSysWords-1 do PLCState.SysWords[i]:=0;
  Reset10HzTimer;
  zeromemory(@(PLCState.Timers[0]),sizeof(PLCState.Timers));

end;


procedure TFMain.MenuClearAllClick(Sender: TObject);

begin
  MenuClearMemoryClick(Sender);
  MenuClearAllIOsClick(Sender);
  MenuClearSystemClick(Sender);
  PageClear(0);
  PageClear(1);
  PageClear(2);
  PageClear(3);
end;

procedure TFMain.Splitter1CanResize(Sender: TObject; var NewSize: Integer;
  var Accept: Boolean);
begin
  NewSize:=max(NewSize,Splitter1.MinSize+1);
  Accept:=True;
end;


procedure TFMain.MenuLogClick(Sender: TObject);
begin
  FLog.CLBSeries.Clear;
  FLog.Visible:= not FLog.Visible;
end;


procedure TFMain.FormActivate(Sender: TObject);
begin
  if StartUp then begin
    FormSplash.Show;
    Startup:=False;
  end;
  FixSyntaxHighlAndCompletion();
end;




procedure TFMain.TimerSplashTimer(Sender: TObject);
begin
  TimerSplash.Enabled:=False;
  //FMain.Update;
  //Application.ProcessMessages();
  //Sleep(5);
  //Application.ProcessMessages();
  //BSetParamsClick(Sender);
  //Application.ProcessMessages();
  //Sleep(5);
  //Application.ProcessMessages();
  //Application.ProcessMessages();
  FormSplash.Hide;
  //Application.ProcessMessages();
end;


procedure TFMain.UpdateStatusVar();
var
  VarValue, OldVarValue : string;
begin

  OldVarValue := GetStringValueFromAnyVarName(OldStatusVarName);
  VarValue    := GetStringValueFromAnyVarName(   StatusVarName);

  //AJS in a hurry   LabelInspect.Caption := StatusVarName+'='+VarValue;

  if VarValue<>'' then begin
    OldVarValue := VarValue;
    OldStatusVarName := StatusVarName;
  end else begin
    VarValue:=OldVarValue;
    StatusVarName := OldStatusVarName;
  end;

  if VarValue<>'' then begin
      StatusBar.Panels[4].text:=' '+StatusVarName+': '+VarValue;
      FormG7.StatusBarG7.Panels[0].Text:=StatusBar.Panels[4].Text;
  end else begin
    //StatusVarName:='';
    StatusBar.Panels[4].text:='';
  end;
end;

procedure TFMain.BlinkBevelSettings();
var i:integer;
begin

  for i:=1 to 3 do begin
    PageControl.TabIndex := 0; // Select Proj Properties visual tab
    FMain.Repaint;

    Bevel1.Visible := False;
    FMain.Repaint;

    sleep(200);
    Bevel1.Visible := True;
    FMain.Repaint;

  end;

end;
procedure TFMain.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key=vk_f8) or (key=vk_f9) then UpdateStatusVar();
end;


procedure TFMain.CBGrafcetClick(Sender: TObject);
begin
  MenuGrafcet.Enabled:=CBGrafcet.Checked;
  Project.Grafcet:=CBGrafcet.Checked;
end;


procedure TFMain.MenuGrafcetClick(Sender: TObject);
begin
  if (not FormG7.Visible) then FormG7.Visible:=True;
  FormG7.BringToFront;
end;

procedure TFMain.BSetParamsClick(Sender: TObject);
begin
  TCP.Disconnect;
  sleep(25);
  Application.ProcessMessages;
  sleep(25);
  // Copy to Project and then use things from project
  try
    //Project.Modified := True;
    Project.MBIP     := EditMBIP.Text;
    Project.MBPort   := StrToInt(EditMBPort.Text);
    Project.Grafcet  := CBGrafcet.checked;
    Project.Gen_C_Code  := CBGen_C_Code.checked;
    Project.ModBus   := CBModBus.Checked;
    Project.WinMsg   := CBWinMessages.Checked;
    Project.MBNRead  := StrToInt(EditMBNRead.text);
    Project.MBNWrite := StrToInt(EditMBNWrite.text);
    Project.MBOffs_I := StrToInt(EditMBOffs_I.Text);
    Project.MBOffs_O := StrToInt(EditMBOffs_O.Text);
    Project.Period   := StrToIntDef(EditPeriodMiliSec.Text,Project.Period); // massacrado 2019 06 02
    EditPeriodMiliSec.Text   := IntToStr(Project.Period);
    Project.MBFunc   := RGMBReadFunc.ItemIndex;
  except
    Project.MBNRead  := MaxInBits;
    Project.MBNWrite := MaxOutBits;

    Project.Period   := 500;
    MessageDlg('Check Parameters - Defaults used',mtError, [mbOK], 0);
                            // ToDO: really set defaults :|
    MemoDebugMB.Append('Check Parameters - Defaults used');
  end;

  if (Project.MBNRead > MaxInBits)  then begin
    ShowMessage('Max In Bit');
    Project.MBNRead:=MaxInBits;
  end;
  if (Project.MBNRead > MaxOutBits) then begin
    ShowMessage('Max Out Bit');
    Project.MBNWrite := MaxOutBits;
  end;


  try
    if (Project.ModBus) then begin
      TCP.Host:=Project.MBIP;
      TCP.Port:=Project.MBPort;
      sleep(1);
      Application.ProcessMessages;
      TCP.Connect;
      sleep(1);
      Application.ProcessMessages;
      sleep(1);
      Application.ProcessMessages;
    end;

  except
    TCP.Disconnect;
  end;

  if project.ModBus then begin
    if TCP.Connected then begin
      LabelMBStatus.Caption:='OK MBTCP: '+EditMBIP.Text+'/'+EditMBPort.Text;
      FIOLeds.LabelConnected.Caption:='MBTCP OK';
    end else begin
      LabelMBStatus.Caption:='No ModBusTCP Server...';
      FIOLeds.LabelConnected.Caption:='No MB Server...';
    end;
  end;

  StatusBar.Panels[3].Text:=LabelMBStatus.Caption;
  StatusBar.Panels[4].Text:=LabelMBStatus.Caption;

  UpdateStatusLine();
  FA_Timer.interval:=StrToInt(EditPeriodMiliSec.Text);

end;


procedure TFMain.Button1Click(Sender: TObject);
begin
  {FA_Resolvido}
  FontDialog1.Font := SynEditST.Font ;
  if (FontDialog1.Execute) then begin
    SynEditST.Font  := FontDialog1.Font; // todo: change all fonts
    MemoResult.Font := FontDialog1.Font;
    MemoValues.Font := FontDialog1.Font;
    LBErrors.Font   := FontDialog1.Font;
  end;
end;

procedure TFMain.TimerStartParamTimer(Sender: TObject);
begin
  TimerStartParam.Enabled:=False;
  CBWinMessages.Checked:=false;
  Application.ProcessMessages;
  sleep(5);
  EditPeriodMiliSec.Text := '60';
  if UpperCase(copy(ParamStr(ParamCount),1,2))='-T' then begin
    EditPeriodMiliSec.Text := copy(ParamStr(ParamCount),3,3);
  end;
  CBModBus.Checked  := true;
  EditMBIP.Text     := '127.0.0.1';
  EditMBOffs_I.Text := '0';
  EditMBOffs_O.Text := '64';
  EditMBNRead.Text  := '24';
  EditMBNWrite.Text := '24';
  RGMBReadFunc.ItemIndex   := 0;
  RGMBWriteFunc1.ItemIndex := 0;
  Application.ProcessMessages;
  Sleep(5);
  Application.ProcessMessages;
  BSetParamsClick(nil);
  Application.ProcessMessages;
  Sleep(5);
  Application.ProcessMessages;
  //FormG7.BIniRunClick(nil); // Compila o Grafcet ou corre o ST
  BIniRunClick(nil);   // corre o ST
  Application.ProcessMessages;
  Sleep(5);
  Application.ProcessMessages;
end;

var
  GlobalFirstLineMBit, GlobalLastLineMBit  (*, GlobalStartLineMW *)  : integer;


procedure TFMain.TimUpdtVarInfoTimer(Sender: TObject);
var
  li, n, idx : integer;
  s : string;
begin
  UpdateStatusVar();

  // Corrigido Maio 2018 - OLD CODE - mostly works
  //if Project.Grafcet then begin
  //  for i := 0 to MaxMemBits-1 do  begin
  //    FormG7.SetStepActivity(i,PLCState.MemBits[i]);
  //  end;
  //end;

  if GlobalFirstLineMBit=0 then begin
    for li:=1 to FVAriables.SGVars.RowCount-1  do begin
      if (PercentNameToType(FVAriables.SGVars.Cells[0,li])='m') and (GlobalFirstLineMBit=0) Then begin
        GlobalFirstLineMBit := li;
      end;
      if (PercentNameToType(FVAriables.SGVars.Cells[0,li])<>'m')
                and (GlobalFirstLineMBit>0) and (GlobalLastLineMBit=0) Then begin
        GlobalLastLineMBit  := li;
        break;
      end;
    end;
  end;

  ////// Prepare Variables  MW
  ////if GlobalStartLineMW=0 then
  ////  for i:=1 to FVAriables.SGVars.RowCount-1  do begin
  ////    if (PercentNameToType(FVAriables.SGVars.Cells[0,i])='M') and (StartLineMW=0) Then
  ////      StartLineMW:=i;
  ////  end;
  ////end;


  if Project.Grafcet then begin
    for li:=GlobalFirstLineMBit to GlobalLastLineMBit do begin
      s:=FVariables.SGVars.Cells[1,li];
      if (copy(s,1,1) = 'X') then begin
        n := StrToIntDef(copy(s,2,999),-1);
        if (n>=0) then begin
          idx := FormG7.G7GetIdXFromName(s,g7oStep); // Maio de 2018
          if (idx>=0) and (idx<MaxMemBits) then FormG7.SetStepActivity(idx, PLCState.MemBits[idx]);
        end;
      end;
    end;
  end;
end;


procedure TFMain.CBModBusClick(Sender: TObject);
begin
  if CBModBus.Checked and CBWinMessages.Checked and (UpperCase(ParamStr(1))<>'-R') then begin
    CBWinMessages.Checked := false;
    //ShowMessage('No double target: for now, inputs will only from modbus...');
  end;
end;

procedure TFMain.CBWinMessagesClick(Sender: TObject);
begin
  if CBModBus.Checked and CBWinMessages.Checked and (UpperCase(ParamStr(1))<>'-R') then begin
    CBModBus.Checked := false;
    //ShowMessage('No double target: for now, inputs will only from modbus...');
  end;
end;

procedure TFMain.BBRunClick(Sender: TObject);
begin
  MenuRunClick(Sender);
end;

procedure TFMain.BBStopClick(Sender: TObject);
begin
  MenuStopClick(Sender);
end;

procedure TFMain.IdModBusClient1Disconnected(Sender: TObject);
begin
  MenuStopClick(Sender);
end;

procedure TFMain.BResetWinPosClick(Sender: TObject);
begin
  with FVariables do begin Left := 200; Top := Left; width := 300; height:=200; end;
  with FIOLeds    do begin Left := 250; Top := Left; width := 300; height:=200; end;
  with FLog       do begin Left := 300; Top := Left; width := 300; height:=200; end;
  with FormG7     do begin Left := 350; Top := Left; width := 500; height:=400; end;
end;

procedure TFMain.BTestMBRdWrClick(Sender: TObject);
begin
  BSetParamsClick(Sender);
  MenuRunOnceClick(Sender);
end;

procedure TFMain.ResetPositions1Click(Sender: TObject);
begin
  BResetWinPosClick(Sender);
end;



procedure TFMain.MenuSFSClick(Sender: TObject);
begin
  CBModBus.Checked := True;
  CBWinMessages.Checked := False;
  EditMBIP.Text := '127.0.0.1';
  EditMBPort.Text := '5502';
  EditMBNRead.Text  := '24';
  EditMBNWrite.Text := '34';
  EditMBOffs_I.Text := '0';
  EditMBOffs_O.Text := '0';
  RGMBReadFunc.ItemIndex := 1;
  BSetParamsClick(Sender);

  BlinkBevelSettings();
end;

procedure TFMain.MenuSTBClick(Sender: TObject);
begin
  CBModBus.Checked := True;
  CBWinMessages.Checked := False;
  EditMBIP.Text := '192.168.105.196';
  EditMBPort.Text := '502';
  EditMBNRead.Text  := '48';
  EditMBNWrite.Text := '48';
  EditMBOffs_I.Text := '5391';
  EditMBOffs_O.Text := '0';
  RGMBReadFunc.ItemIndex := 2;
  BSetParamsClick(Sender);

  BlinkBevelSettings();
end;

procedure TFMain.TimerRunTimeBombTimer(Sender: TObject);
begin
  StopRunningProgram;
  ShowMessage('Max Run Time Exceeded... contact asousa@fe.up.pt');
end;

procedure TFMain.TimeBomb1Click(Sender: TObject);
begin
  ShowMessage('Time Bomb Dis...');
  RunTimeBomb := False;
end;




var AVRStuffPath : string;


procedure TFMain.BST2CClick(Sender: TObject);
var
  TempLines : TStrings;
begin
  PageControl.ActivePage:=Tab_C_;
  LabelCLangErr.Visible:=False;
  FormG7.GenSTCode();
  TranslateSt2Pas;
  {FA_Resolvido}
  SynEditC.ClearAll;
  MemoMakeMsgs.Clear;
  MemoErr.Clear;
  TempLines := TStringList.Create;
  try
    {FA_Resolvido}
    Pas2CTranslateArrayInit (TranslationsPas2C);
    Translate(SynEditST.Lines,SynEditC.Lines,TranslationsPas2C);
    Pas2CTranslateArrayInit2(TranslationsPas2C);
    Translate(SynEditC.Lines,TempLines,TranslationsPas2C);
    Pas2CTranslateArrayInit3(TranslationsPas2C);
    Translate(TempLines,SynEditC.Lines,TranslationsPas2C);
  finally
    TempLines.Free;
  end;


end;



procedure TFMain.BMakeClick(Sender: TObject);
var
  found : integer;
begin
  //MemoMakeMsgs.Clear;
  //MemoErr.Clear;
  LabelCLangErr.Visible:=False;
  LabelCLangErr.Caption:='C Language Errors... click in error message...';

  {FA_Resolvido}
  DeleteFile(AVRStuffPath+'feupautom.c'); //was DeleteFileUTF8 .... Converted from DeleteFile*
  DeleteFile(AVRStuffPath+'default\lf1.hex'); //Converted from DeleteFile*

  SynEditC.Lines.SaveToFile(AVRStuffPath+'feupautom.c');

  Sleep(50);
  PageControl.ActivePage:=TabMakeMsgs;
  MemoMakeMsgs.Lines.Append('-- Start FEUPAutomMake -- '+DateTimeToStr(Now));
  //RunDosInMemo(AVRStuffPath+'FEUPAutomMake.bat',MemoMakeMsgs,MemoErr);
  // rem del C:\!\proj\FEUPAutom4\avrgcc\default\stderr.txt
  //rem make -C C:\!\proj\FEUPAutom4\avrgcc\default -f C:\!\proj\FEUPAutom4\avrgcc\default\Makefile  2>C:\!\proj\FEUPAutom4\avrgcc\default\stderr.txt
  // make -C C:\!\proj\FEUPAutom4\avrgcc\default -f C:\!\proj\FEUPAutom4\avrgcc\default\Makefile
  RunDosInMemo('make ',['-C', AVRStuffPath +'default','-f',AVRStuffPath +'default\Makefile'],
               AVRStuffPath+'default', MemoMakeMsgs,MemoErr);


  MemoMakeMsgs.Lines.Append('');

  found:=0;
//  found := found + PosEx('erro',   MemoMakeMsgs.Lines.Text);
  found := found + PosEx('erro:',  MemoMakeMsgs.Lines.Text);
//  found := found +  PosEx('error',  MemoMakeMsgs.Lines.Text) ;
  found := found +  PosEx('error:', MemoMakeMsgs.Lines.Text) ;
  LabelCLangErr.Visible := (found>0);
end;

procedure TFMain.BDudeClick(Sender: TObject);
begin
  //LabelCLangErr.Visible:=False;
  PageControl.ActivePage:=TabMakeMsgs;
  //MemoMakeMsgs.Clear;
  MemoMakeMsgs.Lines.Append('-- Start FEUPAutomAvrDude -- '+DateTimeToStr(Now));
  // rem del C:\!\proj\FEUPAutom4\avrgcc\default\stderr.txt
  // rem avrdude -p m328p  -c avrispv2 -P COM13 -U flash:w:\!\proj\FEUPAutom4\avrgcc\default\lf1.hex  2>C:\!\proj\FEUPAutom4\avrgcc\default\stderr.txt
  // rem cmd /C
  // rem avrdude -p m328p  -c avrispv2 -P COM18 -U flash:w:\!\proj\FEUPAutom4\avrgcc\default\lf1.hex
  // avrdude -p m328p  -c avrispv2 -P COM13 -U flash:w:\!\proj\FEUPAutom4\avrgcc\default\lf1.hex

  //RunDosInMemo(AVRStuffPath+'FEUPAutomAvrDude.bat',MemoMakeMsgs,MemoErr);

  //TODO: Ver o problema de não poder ter ":" no caminho do lf1 => docmt do avrdude

  RunDosInMemo('avrdude',
               ['-p','m328p','-c','avrispv2', '-P', 'COM13', '-U',
               'flash:w:'+copy(AVRStuffPath,3,999)+'default\lf1.hex'],
               AVRStuffPath, MemoMakeMsgs, MemoErr);

  //TODO: Test for errors in make and in dude

  MemoMakeMsgs.Lines.Append('');
end;

procedure TFMain.SynEditCStatusChange(Sender: TObject; Changes: TSynStatusChanges);
begin
  SynEditSTStatusChange(Sender,Changes);
end;

procedure TFMain.MemoMakeMsgsClick(Sender: TObject);
var s:string;
begin
  if Sender.ClassName<>'TMemo' then exit;

  with sender as TMemo do begin
    s:=Lines[CaretPos.Y];
    if copy(s,1,15)='../feupautom.c:' then begin
      PageControl.ActivePage:=Tab_C_;
      s:=copy(s,16,999);
      {FA_Resolvido}
      SynEditC.CaretY:=StrToInt(copy(s,1,Pos(':',s)-1));
      SynEditC.CaretX:=0;//StrToInt(copy(s,1,Pos(':',s)-1));
      SynEditC.SetFocus;

      s:=copy(s,Pos(':',s)+1,999);
      s:=copy(s,Pos(':',s)+1,999);
      LabelCLangErr.Caption := s;
      LabelCLangErr.Visible := True;
    end else begin
      LabelCLangErr.Visible:=False;
    end;
  end;
end;

procedure TFMain.MenuNextG7STCmakeDudeClick(Sender: TObject);
begin
  if  PageControl.ActivePage = Tab_C_ then BMakeClick(Sender)
  else
    if  PageControl.ActivePage = TabMakeMsgs then BDudeClick(Sender);
end;

procedure TFMain.CBGen_C_CodeClick(Sender: TObject);
begin
  Project.Gen_C_Code := CBGen_C_Code.Checked;
  BST2C.Visible := Project.Gen_C_Code;
  BMake.Visible := Project.Gen_C_Code;
  BDude.Visible := Project.Gen_C_Code;
  TabPascal.TabVisible   := Project.Gen_C_Code;
  TabValues.TabVisible   := Project.Gen_C_Code;
  TabMakeMsgs.TabVisible := Project.Gen_C_Code;
  Tab_C_.TabVisible      := Project.Gen_C_Code;
end;



{ // AJS 201905
procedure TFMain.ModbusEvent(command: byte);
var i: integer;
    s: string;
begin
  //SendMessage('I', );
  s := 'I';
  for i := 0 to 3 do begin
    s := s + IntToHex(Modbus.getByteWith8Coils(i * 8), 2);
  end;
  Serial.WriteData(s);

  //SendMessage('J', );
  s := 'J';
  for i := 0 to 3 do begin
    s := s + IntToHex(Modbus.getByteWith8Coils(4 + i * 8), 2);
  end;
  Serial.WriteData(s);
end;
}


FUNCTION resourceVersionInfo: STRING;
//  http://wiki.freepascal.org/Show_Application_Title,_Version,_and_Company
(* Unlike most of AboutText (below), this takes significant activity at run-    *)
(* time to extract version/release/build numbers from resource information      *)
(* appended to the binary.                                                      *)

VAR     Stream: TResourceStream;
        vr: TVersionResource;
        fi: TVersionFixedInfo;

BEGIN
  RESULT:= '';
  TRY

(* This raises an exception if version info has not been incorporated into the  *)
(* binary (Lazarus Project -> Project Options -> Version Info -> Version        *)
(* numbering).                                                                  *)

    Stream:= TResourceStream.CreateFromID(HINSTANCE, 1, PChar(RT_VERSION));
    TRY
      vr:= TVersionResource.Create;
      TRY
        vr.SetCustomRawDataStream(Stream);
        fi:= vr.FixedInfo;
//        RESULT := 'Version ' + IntToStr(fi.FileVersion[0]) + '.' + IntToStr(fi.FileVersion[1]) +
//               ' release ' + IntToStr(fi.FileVersion[2]) + ' build ' + IntToStr(fi.FileVersion[3]) + ' - ' ;
        RESULT := IntToStr(fi.FileVersion[0]) + '.' +
                  IntToStr(fi.FileVersion[1]) + '.' +
                  IntToStr(fi.FileVersion[2]) + '.' + IntToStr(fi.FileVersion[3]) ;
        vr.SetCustomRawDataStream(nil)
      FINALLY
        vr.Free
      END
    FINALLY
      Stream.Free
    END
  EXCEPT
  END
END { resourceVersionInfo } ;





// Get OS version, etc
// https://forum.lazarus.freepascal.org/index.php?topic=34271.0
//   RtlGetVersion()
// https://stackoverflow.com/questions/57124/how-to-detect-true-windows-version
// https://wiki.lazarus.freepascal.org/Multiplatform_Programming_Guide#Detecting_bitness_at_runtime
// https://forum.lazarus.freepascal.org/index.php?topic=34271.0
// https://stackoverflow.com/questions/32378851/checking-windows-version-on-w10
// NetServerGetInfo()
// https://docs.microsoft.com/pt-pt/windows/win32/api/lmserver/nf-lmserver-netservergetinfo?redirectedfrom=MSDN
// https://forum.lazarus.freepascal.org/index.php/topic,12435.0.html
// https://wiki.lazarus.freepascal.org/WindowsVersion



initialization
  StartUp     := True;
  RunTimeBomb := True;
  AVRStuffPath:=ExtractFilePath(Application.ExeName)+'avrgcc\';
  VersionString:=VersionString + resourceVersionInfo + ' - ';
end.



