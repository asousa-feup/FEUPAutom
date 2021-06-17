unit G7Draw;
{$MODE Delphi}

interface

uses
  {$IFDEF Windows}
    Windows,
  {$ENDIF}
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Printers, ComCtrls, Buttons,
  math, Grids, ValEdit, Menus, PairSplitter,

  //XML (by BrunoAugusto)
  laz2_DOM, laz2_XMLRead, laz2_XMLWrite, laz2_XMLUtils,

  //SYN
  SynEdit,
  SynEditHighlighter,
  SynHighlighterPas, SynHighlighterAny, SynHighlighterMulti, SynCompletion,

  //OUTROS:
  PrintersDlgs,FileUtil ;



type
  TPrinterParmeters = record
    X_resolution : Integer;  // horizontal printer resolution, in dpi
    Y_resolution : Integer;  // vertical printer resolution, in dpi
    pagerect : TRect;    // total page, in paper coordinates
    printorigin : TPoint;
  end;

  TBarType = (btUnknown, btHigh, btLow);

  TG7Flag = (g7fInitial, g7fLinkVisible, g7fActive);
  TG7Type = (g7oEmpty, g7oStep, g7oTransition, g7oComment, {g7oUpLink,} g7oJumpStart, g7oJumpFinish);

  TG7Flags = set of TG7Flag;

const
  G7TypeNames: array[TG7Type] of string =('Empty', 'Step', 'Transition', 'Comment', {'UpLink',} 'JumpStart', 'JumpFinish');


type
  TG7Object = record
    Page, CellX, CellY: integer;
    BarInIdx, BarOutIdx: integer;
    Name: string;
    Flags: TG7Flags;
    Text, Code : string;
    G7Type: TG7Type;
    // Cache Variables
    JumpIdx: integer;
  end;


  TG7Bar = record
    Connections : integer;
    Cxi, Cxf, Cy, CyMax : integer; // sempre horizontal
    BarType: TBarType;
    InCount, OutCount: integer;
    Page : integer;
  end;


  TG7Comment = record
    CellX,CellY : integer;
    Tag : integer;
    Comment : string
  end;

  TRectOffs = record
    Left, Top, Right, Bottom, OffX, OffY : integer;
  end;

type

  { TFormG7 }

  TFormG7 = class(TForm)
    BBRun_GR7: TBitBtn;
    BBStop_GR7: TBitBtn;
    BCompile: TButton;
    BDebug: TButton;
    BDebugActivateRandom: TButton;
    BDumpBars: TButton;
    BDumpObjs: TButton;
    BIniRun: TBitBtn;
    BPrintTransPage0: TButton;
    BPrintTransPage1: TButton;
    BPrintTransPage2: TButton;
    BPrintTransPage3: TButton;
    BStepsPage1: TButton;
    BStepsPage2: TButton;
    BStepsPage3: TButton;
    BStepsPage4: TButton;
    CBBarNum: TCheckBox;
    CBConfirmDel: TCheckBox;
    CBCursors: TCheckBox;
    CBDebugStuff: TCheckBox;
    CBEliminateNewLine: TCheckBox;
    CBRoundStates: TCheckBox;
    CBShowCode: TCheckBox;
    EditAnimation: TEdit;
    EditDebugVar: TEdit;
    ImageHelpToolBar: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    LabelSteps: TLabel;
    LabelTransitions: TLabel;
    Label9: TLabel;
    LabelCodeAreaSize: TLabel;
    LabelCodeAreaSize1: TLabel;
    LabelPage0: TLabel;
    LabelPage1: TLabel;
    LabelPage2: TLabel;
    LabelPage3: TLabel;
    LabelZoom: TLabel;
    Memo1: TMemo;
    MenuIOs: TMenuItem;
    MenuItem1: TMenuItem;
    MenuG7STCompileRunOnce: TMenuItem;
    MenuItem2: TMenuItem;
    MenuDebugMode: TMenuItem;
    MenuCBResetOutsAtStartCycle: TMenuItem;
    MenuItem3: TMenuItem;
    MenuRoundStates: TMenuItem;
    MenuNewLineContinuous: TMenuItem;
    MenuShowCode: TMenuItem;
    MenuItem4: TMenuItem;
    MenuStartQAtPg2: TMenuItem;
    MenuItem5: TMenuItem;
    MenuRedraw: TMenuItem;
    MenuStartGradingProcess: TMenuItem;
    MenuSelfGrade: TMenuItem;
    MenuVars: TMenuItem;
    PairSplitBottom: TPairSplitterSide;
    PairSplitRight: TPairSplitter;
    PairSplitUp: TPairSplitterSide;
    Panel2Right: TPanel;
    SPComment: TSpeedButton;
    SPConnector: TSpeedButton;
    SPEdit: TSpeedButton;
    SPJump: TSpeedButton;
    SPStepTransition: TSpeedButton;
    SPUpLink: TSpeedButton;
    SynCompletionG7: TSynCompletion;
    SynEditST_G7: TSynEdit;
    TBCodeAreaSize: TTrackBar;
    TBFont: TTrackBar;
    TBFontCodeEditor: TTrackBar;
    TBPage: TTrackBar;
    TBStepHeight: TTrackBar;
    TBZoom: TTrackBar;
    Timer1: TTimer;
    PrintDialog1: TPrintDialog;     //ja da

    G7_MainMenu: TMainMenu;
    MenuEdit: TMenuItem;
    MenuFile: TMenuItem;
    G7_PopupMenu: TPopupMenu;
    PopMenuInsertRow: TMenuItem;
    PopMenuShiftRow: TMenuItem;
    MenuUndo: TMenuItem;
    PopMenuInsertCol: TMenuItem;
    PopMenuShiftCol: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    MenuView: TMenuItem;
    ToolBar: TToolBar;
    ToolBar1: TToolBar;
    VLEPropEdit: TValueListEditor;
    Zoom1: TMenuItem;
    MenuZoom200: TMenuItem;
    MenuZoom100: TMenuItem;
    MenuZoom50: TMenuItem;
    MenuZoom25: TMenuItem;
    MenuZoom20: TMenuItem;
    N3: TMenuItem;
    MenuZoomIn: TMenuItem;
    MenuZoomOut: TMenuItem;
    N4: TMenuItem;
    MenuAbout: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    N5: TMenuItem;
    MenuExit: TMenuItem;
    N6: TMenuItem;
    MenuPrint: TMenuItem;
    MenuNew: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    MenuDelete: TMenuItem;
    MenuZoom33: TMenuItem;
    MenuProject: TMenuItem;
    MenuProjectEdit: TMenuItem;
    Label3: TLabel;
    Label4: TLabel;
    PopMenuClearRow: TMenuItem;
    PopupMenuClearCol: TMenuItem;
    PopMenuUndo: TMenuItem;
    N9: TMenuItem;
    PopMenuDelete: TMenuItem;
    Label5: TLabel;
    MenuGenCod: TMenuItem;
    UndoLastCodeGeneration1: TMenuItem;
    MenuSaveProject: TMenuItem;
    N10: TMenuItem;
    MenuG7STCompile: TMenuItem;
    MenuG7STRun: TMenuItem;
    StatusBarG7: TStatusBar;
    Splitter1: TSplitter;
    Panel1Left: TPanel;
    ScrollBox1: TScrollBox;
    ImageG7: TImage;
    N13: TMenuItem;
    MenuedrawAll: TMenuItem;
    MenuWindow: TMenuItem;
    MenuST: TMenuItem;
    LabelZones: TLabel;
    N15: TMenuItem;
    MenuG7STC: TMenuItem;
    procedure BBRun_GR7Click(Sender: TObject);
    procedure BBStop_GR7Click(Sender: TObject);
    procedure BIniRunClick(Sender: TObject);
    procedure BPrintTransPage0Click(Sender: TObject);
    procedure BPrintTransPage_x_Click(Sender: TObject);
    procedure CBDebugStuffChange(Sender: TObject);
    procedure CBEliminateNewLineChange(Sender: TObject);
    procedure EditDebugVarChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BRedrawAllClick(Sender: TObject);
    procedure ImagesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageG7MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ImageG7MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BDebugClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MenuCBResetOutsAtStartCycleClick(Sender: TObject);
    procedure MenuedrawAllClick(Sender: TObject);
    procedure MenuIOsClick(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuG7STCompileRunOnceClick(Sender: TObject);
    procedure MenuItem3Click(Sender: TObject);
    procedure MenuNewLineContinuousClick(Sender: TObject);
    procedure MenuRedrawClick(Sender: TObject);
    procedure MenuSelfGradeClick(Sender: TObject);
    procedure MenuShowSelfGradeClick(Sender: TObject);
    procedure MenuStartQAtPg2Click(Sender: TObject);
    procedure MenuStartStopGradingClick(Sender: TObject);
    procedure MenuVarsClick(Sender: TObject);
    procedure PairSplitUpMouseEnter(Sender: TObject);
    procedure PairSplitUpResize(Sender: TObject);
    procedure SynEditST_G7MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TBFontCodeEditorChange(Sender: TObject);
    procedure SPModesClick(Sender: TObject);
    procedure BInsertRowClick(Sender: TObject);
    procedure BInsertColClick(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure MenuUndoClick(Sender: TObject);
    procedure TBStepHeightChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    //procedure VLEPropEditEditButtonClick(Sender: TObject);
    procedure VLEPropEditValidate(Sender: TObject; ACol, ARow: Integer;
      const KeyName, KeyValue: String);
    procedure VLEPropEditKeyPress(Sender: TObject; var Key: Char);
    procedure PopMenuInsertRowClick(Sender: TObject);
    procedure PopMenuShiftRowClick(Sender: TObject);
    procedure PopMenuInsertColClick(Sender: TObject);
    procedure PopMenuShiftColClick(Sender: TObject);
    procedure MenuZoomClick(Sender: TObject);
    procedure MenuZoomInClick(Sender: TObject);
    procedure MenuZoomOutClick(Sender: TObject);
    procedure TBZoomChange(Sender: TObject);
    procedure MenuExitClick(Sender: TObject);
//    procedure MenuLoadClick(Sender: TObject);
//    procedure MenuSaveASClick(Sender: TObject);
    procedure MenuPrintClick(Sender: TObject);
    procedure MenuNewClick(Sender: TObject);
    procedure MenuSaveClick(Sender: TObject);
    procedure MenuDeleteClick(Sender: TObject);
    procedure CBRoundStatesClick(Sender: TObject);
    procedure CBEliminateNewLineClick(Sender: TObject);
    procedure MenuProjectEditClick(Sender: TObject);
    procedure TBPageChange(Sender: TObject);
    procedure CBShowCodeClick(Sender: TObject);
    procedure PopMenuClearRowClick(Sender: TObject);
    procedure PopupMenuClearColClick(Sender: TObject);
    procedure PopMenuDeleteClick(Sender: TObject);
    procedure BCompileClick(Sender: TObject);
    procedure BDebugActivateRandomClick(Sender: TObject);
    procedure BDumpObjsClick(Sender: TObject);
    procedure BDumpBarsClick(Sender: TObject);
    procedure BUndoGenCodeClick(Sender: TObject);
    procedure CBDebugStuffClick(Sender: TObject);
    procedure MenuGenCodClick(Sender: TObject);
    procedure UndoLastCodeGeneration1Click(Sender: TObject);
    procedure BStepsPage_x_Click(Sender: TObject);
    function  G7LoadXML(const fn: string; onlyG7:boolean; SaveProjDoc:TDOMNode;
                        ImportGr7Page3Mode : Boolean = FALSE): boolean;
    function  G7SaveXML(const fn: string; onlyG7:boolean; SaveProjDoc:TXMLDocument):boolean;
    procedure g7Print;
    procedure ZapClick(Sender: TObject);
    procedure SynEditST_G7Change(Sender: TObject);
    procedure SynEditST_G7Exit(Sender: TObject);
    procedure MenuSaveProjectClick(Sender: TObject);
    procedure MenuSaveproject1Click(Sender: TObject);
    procedure MenuG7STCompileClick(Sender: TObject);
    procedure MenuG7STRunClick(Sender: TObject);
    procedure TBFontChange(Sender: TObject);
    procedure TBCodeAreaSizeChange(Sender: TObject);
    procedure MenuAboutClick(Sender: TObject);
    procedure FormInit;
    procedure ImageHelpCodeAreaClick(Sender: TObject);
    procedure MenuSTClick(Sender: TObject);
    procedure MenuG7STCClick(Sender: TObject);
    function  DeleteObjectsInPage(DelPage : integer) : integer; // No Cleaning :(

  private
    procedure G7CleanUpForImport;

    //procedure StopFlicker(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;

    function G7CreateObj(const pg, cx, cy : integer): integer;
    function G7CreateStep(const  pg, cx, cy: integer): integer;
    function G7CreateTr(const  pg, cx, cy: integer): integer;
    function G7CreateJumpFinish(const pg, cx, cy: integer): integer;
    function G7CreateJumpStart(const pg, cx, cy: integer): integer;
    function G7CreateComment(const pg, cx, cy: integer): integer;

    procedure G7DrawGrid;
    procedure G7DrawStep(idx: integer);
    procedure G7DrawTr(idx: integer);
    procedure G7DrawJumpStart(idx: integer);
    procedure G7DrawJumpFinish(idx: integer);
    procedure G7DrawComment(idx: integer);
    procedure G7DrawObject(i: integer);
    procedure G7ShowModeInStatusBar();
    procedure G7TextWrap( const r : trect; const TheText : string; const SubstituteNewLine:boolean=False) ;

    procedure G7PixToCells(const x, y: integer; out CellX, CellY: integer);
    function  G7GetObjectAtPix(const clickX,clickY : integer; out G7ObjIdx : integer) : boolean;

    function G7CellToRect(const xcell,ycell:integer; const R : TRect; const xoff : integer=0; const yoff: integer=0) : Trect; overload;
    function G7CellToRect(const xcell,ycell:integer; const R : TRectOffs) : Trect; overload;
    function G7CellToRect(const xcell,ycell, xi,yi, xf, yf:integer; const xoff : integer=0; const yoff: integer=0):Trect; overload;

//    procedure UnselectAll;
//    procedure AddToSelection(TheTr : TG7Tr); overload;
//    procedure AddToSelection(TheStep: TG7Step); overload;
    function  G7GetFreeIndex: integer;
    procedure G7SelectObject(ObjIdx: integer);
    function IsMoveValid(Cx, Cy, G7ObjIdx: Integer): boolean;
    function  G7GetFreeBar: integer;
    procedure G7Clear;
    function  IsDoubleLine(idx: integer): boolean;
    procedure SetTemporaryTool(const shift : TShiftState);
    function  IsOverlappingAnotherBar(idx : integer) : boolean;
    procedure G7DeleteObj(idx: integer);
    function G7ObjIsStepLike(objIdx: integer): boolean;
    function G7ObjIsTransitionLike(objIdx: integer): boolean;
    function FindG7Name(theName: String; TheG7Type: TG7Type): integer;
    function  G7FlagsToInteger(TheFlags: TG7Flags): integer;
    function  G7IntegerToG7Flags(TheInt: integer): TG7Flags;
    procedure G7InitCursors;
    procedure DupG7Objects;
    procedure G7UndoDupG7Objects;
    function  G7InsertRow(const TheRow : integer =-1) : boolean;
    function  G7InsertCol(const TheCol : integer =-1) : boolean;
    function  G7ShiftRow(const TheRow : integer =-1) : boolean;
    function  G7ShiftCol(const TheCol : integer =-1) : boolean;
    function  G7ClearCol(const TheCol : integer =-1; const ThePage : integer =-1) : boolean;
    function  G7ClearRow(const TheRow : integer =-1): boolean;
    function  G7GetObjectAtCell(const cx, cy : integer; out G7ObjIdx : integer) : boolean;
    function  G7GetZoomPercent: integer;
    procedure G7SetZoomPercent(const WantZoom: integer);
    procedure G7DrawaGridHoriz(const SubCellY : integer);
    procedure G7DrawaGridVert(const SubCellX: integer);
    function  G7IsPhantom(const idx: integer): boolean;
    function  G7IsSelected(const idx: integer): boolean;
    procedure G7DrawLine(const obj_i, obj_f, cxi,cyi,cxf,cyf : integer; DoubleLine : Boolean = False; UpLinkLine : boolean =False );
    procedure G7GetDrawPix(idx: integer; below: boolean; out pixX, pixY: integer);

    function IsValidCreateLink(const ConStartObjIdx, ConFinishObjIdx : integer) : boolean;
    function IsValidAddToLink(const ConStartObjIdx, ConFinishObjIdx,
      BarIdx: integer): boolean;
    function IsCompatibleBar(const ConStartObjIdx, ConFinishObjIdx,
      BarIdx: integer): boolean;
    procedure G7ShowModeInStatursBar;
    procedure VLEPropEditValidateAndSet(ObjIdx: Integer; const KeyName, KeyValue: String);
    procedure G7ResetGUI;
    procedure CalculateRectangles;
    procedure CalculateDependents;
    function  GetStepIdx(const SearchName: string): integer;
    function  GetObjIdx(const SearchName: string): integer;
//    procedure FlickerMode(const FullDrawWithFlicker: boolean);

  public
    MouseDownX, MouseDownY : integer;
    ElasticXi,ElasticYi,ElasticXf,ElasticYf : integer;
    CurG7Canvas : TCanvas;
    g7Zoom : Double;
    actPage, FontZoom: integer;

    UpStartObj, UpFinishObj : TG7Object;
    UpValid : boolean;
    UpCurLabel : string;

    MoveCellXOrigin, MoveCellYOrigin: integer;
    MoveCellXOffset, MoveCellYOffset: integer;
    MoveCellYMinLimit, MoveCellYMaxLimit, MoveCellYQuantum: integer;
    MoveActive, MoveValid: boolean;

    ConStartObjIdx, ConFinishObjIdx: integer;

    TemporaryToolStatus : integer;
    StepPrefix, TrPrefix,JumpPrefix, CommentPrefix: string;
    StepCount, TrCount, JumpStartCount, JumpFinishCount, CommentCount : integer;

    crG7Edit, crG7Move, crG7Step, crG7Tr, crG7Connect, crG7Disconnect, crG7Uplink,
    crG7Delete, crG7Jumps: integer;

    MouseMoveOldCX, MouseMoveOldCY : integer;

    LabelPages : array [0..3] of TLabel;

  published
    function  G7GetIdxFromName(theLabel: String; TheG7Type: TG7Type): integer;
    procedure SetStepActivity(aStepIdx: integer; activeStep: boolean);
    procedure G7RedrawAll;
    function GenSTCode(InteratctiveMode: Boolean=True): Boolean;
    procedure G7PageStart(const ThePage: integer);
    procedure G7PageClear(const ThePage: integer);

  end;


function GetStudentNumbers : string;

procedure ShowMessageOrLog(TheText : string);
Function SpecialSGFixAllG7Obj() : integer;

var
  FormG7, FormViewG7 : TFormG7;


implementation

uses StrUtils, Types, G7Project, Main, G7Editor, StructuredTextUtils,
     Variables, IOLeds, structuredtext2pas, ProjManage, Splash, SelfGrade;

{$R *.lfm}

//---------------------------------------------------------------------
// Global to this unit
//---------------------------------------------------------------------

var
  // SubCell size (in pixels)
  SubCellHeight,
  SubCellWidth   : integer;

  // Object size (in subcells)
  SizeX          ,
  StepSizeX      ,
  StepSizeY      ,
  TrSizeX        ,
  TrSizeY        ,
  BarSizeY       ,
  CellWidth      ,
  BlockHeight    ,
  BlockHeightPix :  integer;

  // Size of Sheet (in cells)
  MaxCellsX      ,
  MaxCellsY      ,
  FullX          ,
  FullY          :  integer;

  // Size of Sheet (in Pixels)
  FullXPix       ,
  FullYPix       : integer;

  // Rectangles with offset - for each object (rect in subcells, offs in pixels)
  StepOuterRect      ,
  StepInnerRect      ,
  StepRect_1         ,
  StepRect_2         ,
  StepRect_3         ,
  StepLeftHalf       ,
  StepRightHalf      ,

  TrRect             ,
  TrRect_1           ,
  TrLeftHalf         ,
  TrRightHalf        ,

  BarRect            ,

  JumpStartRect      ,
  JumpStartLeftHalf  ,

  JumpFinishRect     ,
  JumpFinishLeftHalf ,

  CommentRect        ,
  InnerCommentRect   : TRectOffs;

  // Colors
  clStep             ,
  clTr               ,
  clBkg              ,
  clCellGrid         ,
  clSubCellGrid      ,
  clCoded            ,
  clDistroUnconn     ,
  clDistroConn       ,
  clSelected         ,
  ClComment          ,

  clPhantom          ,
  clMove             ,
  clJumpStart        ,
  clJumpFinish       ,
  clElastic          : TColor;

const
  MAXG7Objects = 2048;
  MAXG7Bars = 2048;

  crlf=#13#10;

type
  TG7Objects = array [0..MAXG7Objects+2] of TG7Object;  // Last 2 are phantom objects
  TG7Bars = array [0..MAXG7Bars-1] of TG7Bar;

var
  SequenceYY   : array [0..3] of integer;
  ThresholdsYY : array [0..3] of integer;

  G7Objects, G7ObjectsDup: TG7Objects;
  G7ObjectsCount, G7ObjectsCountDup: integer;
  SelectedG7Obj, SelectedG7ObjCount, SelectedG7ObjDup, SelectedG7ObjCountDup, G7BarsCountDup: integer;

  G7Bars: TG7Bars;
  G7BarsCount: integer;



//CREATE FORM:
procedure TFormG7.FormCreate(Sender: TObject);
//var xy:Boolean;
//  kw: TSynHighlighterAttributes;
begin
  //MenuZoomOut.ShortCut := ShortCut(Word('-'), [ssCtrl]);

  FormG7.KeyPreview := True; //To keys work

  FormG7.DoubleBuffered:=True;
  ScrollBox1.DoubleBuffered:=True;

  FormG7.MouseMoveOldCX:=-1;
  FormG7.MouseMoveOldCY:=-1;

  G7InitCursors();


  StepPrefix := 'X';
  TrPrefix := 't';
  JumpPrefix:='Jump';
  CommentPrefix:='Comment';

  G7Clear;

  MoveCellYQuantum := 4;

  SequenceYY[0] := StepSizeY;
  SequenceYY[1] := BarSizeY;
  SequenceYY[2] := TrSizeY;
  SequenceYY[3] := BarSizeY;

  ThresholdsYY[0]:=StepSizeY;
  ThresholdsYY[1]:=StepSizeY + BarSizeY;
  ThresholdsYY[2]:=StepSizeY + BarSizeY + TrSizeY;
  ThresholdsYY[3]:=StepSizeY + BarSizeY + TrSizeY + BarSizeY;

  ImageG7.Height := 2048;
  ImageG7.Width  := 2048;

  CurG7Canvas := ImageG7.Canvas;

  G7ResetGUI;

  SynEditST_G7.Tag:=-1;

  LabelPages[0] := LabelPage0;
  LabelPages[1] := LabelPage1;
  LabelPages[2] := LabelPage2;
  LabelPages[3] := LabelPage3;

end;

procedure TFormG7.BBStop_GR7Click(Sender: TObject);
begin
    FMain.BBStopClick(Sender);
end;

procedure TFormG7.BIniRunClick(Sender: TObject);
begin
  if (GenSTCode()) then begin
    MenuG7STCompileClick(Sender);
    FMain.MenuClearAllClick(Sender);
    BBRun_GR7Click(Sender);
  end;
end;

procedure TFormG7.BPrintTransPage0Click(Sender: TObject);
begin

end;


procedure TFormG7.BStepsPage_x_Click(Sender: TObject);
var i : integer;
begin
//   FontZoom:=FontZoom+1;
//   if FontZoom>4 then FontZoom:=-4;
//   SynEditST_G7.Font.Size := 9+FontZoom;
//   BRedrawAllClick(Sender);
  if SelectedG7Obj<0 then begin beep;exit; end;
  for i:=0 to high(G7Objects) do begin
    if (G7Objects[i].Page=(sender as TButton).tag) and
       (G7Objects[i].G7Type=g7oStep) and
       (length(trim(G7Objects[i].Name))>0) then begin
      SynEditST_G7.Append(G7Objects[i].Name+':=False;');
    end;
  end;
  SynEditST_G7Change(Sender);
end;


procedure TFormG7.BPrintTransPage_x_Click(Sender: TObject);
var
  i : integer;
begin
  if SelectedG7Obj<0 then begin beep;exit; end;
  for i:=0 to high(G7Objects) do begin
    if (G7Objects[i].Page=(sender as TButton).tag) and
       (G7Objects[i].G7Type=g7oTransition) and
       (length(trim(G7Objects[i].Name))>0) then begin
      SynEditST_G7.Append(G7Objects[i].Name+':=False;');
    end;
  end;
  SynEditST_G7Change(Sender);
end;


procedure TFormG7.CBDebugStuffChange(Sender: TObject);
begin
  Memo1.Visible := CBDebugStuff.Checked;
  CBCursors.Visible := CBDebugStuff.Checked;
  BDumpObjs.Visible := CBDebugStuff.Checked;
  BDumpBars.Visible := CBDebugStuff.Checked;
  BDebugActivateRandom.Visible := CBDebugStuff.Checked;
  BCompile.Visible := CBDebugStuff.Checked;
  BDebug.Visible := CBDebugStuff.Checked;
  //EditDebug.Visible := CBDebugStuff.Checked;
  BStepsPage1.Visible:=not CBDebugStuff.Checked;
  BStepsPage2.Visible:=not CBDebugStuff.Checked;
  BStepsPage3.Visible:=not CBDebugStuff.Checked;
  BStepsPage4.Visible:=not CBDebugStuff.Checked;
  BPrintTransPage0.Visible:=not CBDebugStuff.Checked;
  BPrintTransPage1.Visible:=not CBDebugStuff.Checked;
  BPrintTransPage2.Visible:=not CBDebugStuff.Checked;
  BPrintTransPage3.Visible:=not CBDebugStuff.Checked;
  LabelSteps.Visible:=not CBDebugStuff.Checked;
  LabelTransitions.Visible:=not CBDebugStuff.Checked;
end;

procedure TFormG7.CBEliminateNewLineChange(Sender: TObject);
begin
end;

procedure TFormG7.EditDebugVarChange(Sender: TObject);
begin
  FMain.StatusVarName  := EditDebugVar.Text;
  FMain.UpdateStatusVar();
end;

procedure TFormG7.FormActivate(Sender: TObject);
begin
  PairSplitUp.Repaint;
end;

procedure TFormG7.BBRun_GR7Click(Sender: TObject);
begin
  if (GenSTCode()) then begin
    MenuG7STCompileClick(Sender);
    FMain.BBRunClick(Sender);
  end;
end;



function TFormG7.G7CellToRect(const xcell,ycell:integer; const R : TRect; const xoff : integer=0; const yoff: integer=0) : Trect;
begin
  with R do
    result:=G7CellToRect(xcell, ycell, left, top, right, bottom, xoff, yoff);
end;

function TFormG7.G7CellToRect(const xcell,ycell:integer; const R : TRectOffs) : Trect;
begin
  with R do
    result:=G7CellToRect(xcell, ycell, left, top, right, bottom, OffX, OffY);
end;

function TFormG7.G7CellToRect(const xcell,ycell, xi,yi, xf, yf:integer; const xoff : integer=0; const yoff: integer=0):Trect;
var VertBlocks, remainder : integer;
begin
  with result do begin
//    Left:=    xoff + round((xCell * CellWidth  + SubCellWidth * xi) * G7Zoom);
//    Right:=  -xoff + round((xCell * CellWidth  + SubCellWidth * xf) * G7Zoom );
//    Top :=    yoff + round((yCell * CellHeight + SubCellHeight * yi) * G7Zoom);
//    Bottom:= -yoff + round((yCell * CellHeight + SubCellHeight * yf) * G7Zoom );

    Left:=    xoff + round((xCell * SizeX * SubCellWidth + SubCellWidth * xi) * G7Zoom);
    Right:=  -xoff + round((xCell * SizeX * SubCellWidth + SubCellWidth * xf) * G7Zoom );

    VertBlocks := ycell div 4;
    remainder := ycell - (VertBlocks*4);

    Top := round ( VertBlocks * BlockHeight * SubCellHeight * G7Zoom ) ;

    if remainder>2  then
      top:=top+round(ThresholdsYY[2]*SubCellHeight*g7Zoom)
    else
    if remainder>1  then
      top:=top+round(ThresholdsYY[1]*SubCellHeight*g7Zoom)
    else
    if remainder>0  then
      top:=top+round(ThresholdsYY[0]*SubCellHeight*g7Zoom);

    Bottom := -yoff + Top + round(SubCellHeight * yf * G7Zoom);
    Top    :=  yoff + Top + round(SubCellHeight * yi * G7Zoom);

  end;
end;


function TFormG7.G7GetFreeIndex: integer;
begin
  result := -1;
  if G7ObjectsCount >= MAXG7Objects-1 then exit;

  result:=0;
  while G7Objects[result].G7Type <> g7oempty do begin
    inc(result);
    if result >= G7ObjectsCount then break;
  end;
end;


procedure TFormG7.G7ResetGUI;
begin
  actPage:=0;
  G7SetZoomPercent(75);
end;



procedure TFormG7.G7Clear;
var i:integer;
begin
  zeromemory(@G7Objects,sizeof(G7Objects));

  G7ObjectsCount:= 0;
  SelectedG7Obj := -1;
  SelectedG7ObjCount := 0;

  zeromemory(@G7Bars, sizeof(G7Bars));
  G7BarsCount := 0;

  StepCount := 0;
  TrCount:=0;
  CommentCount:=0;
  JumpStartCount:=0;
  JumpFinishCount:=0;

  for i:=0 to high(G7Objects) do with G7Objects[i] do begin
    BarInIdx  := -1;
    BarOutIdx := -1;
    JumpIdx   := -1;
  end;

  with UpStartObj do begin
    BarInIdx  := -1;
    BarOutIdx := -1;
    JumpIdx   := -1;
  end;

  with UpFinishObj do begin
    BarInIdx  := -1;
    BarOutIdx := -1;
    JumpIdx   := -1;
  end;

end;


function TFormG7.DeleteObjectsInPage(DelPage : integer) : integer; // No Cleaning :(
var
  i,cnt : integer;
begin
  cnt := 0;
  for i:=0 to high(G7Objects) do begin
    if (G7Objects[i].G7Type <> g7oEmpty) AND
       (G7Objects[i].Page = DelPage) then begin
  //      G7DeleteObj(i);
      inc(cnt);
    end;
  end;
  result := cnt;
  for i:=0 to MaxCellsX-1 do begin
    G7ClearCol(i, DelPage);
  end;
end;

function TFormG7.G7IsSelected(const idx : integer) : boolean;
begin
  result:=(idx = SelectedG7Obj);
end;

function TFormG7.G7IsPhantom(const idx : integer) : boolean;
begin
  result:=(idx >= MAXG7Objects);
end;


procedure TFormG7.G7GetDrawPix(idx : integer; below : boolean; out pixX, pixY : integer);
var r : TRect;
begin

  if idx=-1 then exit;

  with G7Objects[idx] do begin

    if G7Type = g7oStep then begin
      r:=G7CellToRect(CellX,CellY,StepInnerRect);
    end else
    if G7Objects[idx].G7Type = g7oTransition then begin
      r:=G7CellToRect(CellX,CellY,TrRect);
    end else
    if G7Objects[idx].G7Type = g7oJumpStart then begin
      r:=G7CellToRect(CellX,CellY,JumpStartRect);
    end else
    if G7Objects[idx].G7Type = g7oJumpFinish then begin
      r:=G7CellToRect(CellX,CellY,JumpFinishRect);
    end else
    if G7Objects[idx].G7Type = g7oComment then begin
      r:=G7CellToRect(CellX,CellY,TrRect);
    end else
    if G7Objects[idx].G7Type = g7oEmpty then begin
      r:=G7CellToRect(CellX,CellY,TrRect);     // disfarçador de bugs  !!!!!!!
    end;

    pixX := CenterPoint(r).X;

    if below then begin
      pixY := r.Bottom;
    end else begin                                              // ABOVE
      pixY := r.Top;
    end;
  end;

end;


procedure TFormG7.G7DrawLine(const obj_i, obj_f, cxi,cyi,cxf,cyf : integer; DoubleLine : Boolean = False; UpLinkLine : boolean =False );
var
  xi,xf,yi,yf: integer;
  r : TRect;
begin

  //if G7GetObjectAtCell(cxi,cyi,obj_i) then begin
  if obj_i <> -1 then begin
    G7GetDrawPix(obj_i, True, xi, yi);
  end else begin
    r:=G7CellToRect(cxi,cyi,BarRect);
    with CenterPoint(r) do begin
      xi := X;
      yi := Y;
    end;
  end;

  //if G7GetObjectAtCell(cxf,cyf,obj_f) then
  if obj_f <> -1 then
    G7GetDrawPix(obj_f, False, xf, yf)
  else begin
    r:=G7CellToRect(cxf,cyf,BarRect);
    with CenterPoint(r) do begin
      xf := X;
      yf := Y;
    end;
  end;

  if DoubleLine then begin
    CurG7Canvas.MoveTo(xi,yi-1);
    CurG7Canvas.LineTo(xf,yf-1);
    CurG7Canvas.MoveTo(xi,yi+1);
    CurG7Canvas.LineTo(xf,yf+1);
  end else begin
    CurG7Canvas.MoveTo(xi,yi);
    CurG7Canvas.LineTo(xf,yf);
  end;

  if UpLinkLine and (yi<yf) then
    if (cxi=cxf) then begin // uplink    Rever ->  UPARROW
      //Brush.Style:=bsClear;
      //CurG7Canvas.TextOut(xi-4, (yi+yf) div 2, '^');
      with CurG7Canvas do begin
        yi:=(yi+yf) div 2;
        MoveTo(xi,yi);
        LineTo(xi-round(4*g7Zoom)-2,yi+round(9*g7Zoom)+2);
        MoveTo(xi,yi);
        LineTo(xi+round(4*g7Zoom)+2,yi+round(9*g7Zoom)+2);
      end;

    end;

end;


procedure TFormG7.G7DrawStep(idx: integer);
var
  r, r_step : TRect;
  cx, cy, w: integer;
  ShortName : String;
begin
  with CurG7Canvas, G7Objects[idx] do begin         // Magic numbers dependentes de SubCellCnt

    Brush.Style:=bsClear;

    if (g7fActive in flags) then Pen.Width:=3;

    if g7fInitial in flags then begin
      if G7IsSelected(idx) then begin
        if MoveActive then begin
          Pen.Color:=clMove;
        end else Pen.Color:=ClSelected;
      end else Pen.Color:=ClStep;
      r:=G7CellToRect(Cellx,Celly,StepOuterRect);
      if CBRoundStates.Checked then
        Ellipse( r )
      else
        Rectangle( r );
    end else Pen.Color:=clBkg;

    cx := CellX;
    cy := CellY;

    if G7IsPhantom(idx) then
      Pen.Color:=clPhantom
    else
    if G7IsSelected(idx) then begin
      if MoveActive then begin
        Pen.Color:=clMove;
        cx := CellX + MoveCellXOffset;
        cy := CellY + MoveCellYOffset;
      end else Pen.Color:=ClSelected;
    end else Pen.Color:=ClStep;
    Font.Color := Pen.Color;

    r := G7CellToRect(Cx,Cy,StepInnerRect);
    if CBRoundStates.Checked then
      Ellipse( r )
    else
      Rectangle( r );

    r_step := r; // save for latter (in a hurry!)

    if code<>'' then Brush.Color:=clCoded else Brush.Color:=clBkg;
    (* // Turn off or on 3 small empty or blue squares
    Rectangle( G7CellToRect(Cx,Cy,StepRect_1) );
    //if code<>'' then Brush.Color:=clCoded else Brush.Color:=clBkg;
    Rectangle( G7CellToRect(Cx,Cy,StepRect_2) );
    //if code<>'' then Brush.Color:=clCoded else Brush.Color:=clBkg;
    Rectangle( G7CellToRect(Cx,Cy,StepRect_3) );
    *)

    if BarOutIdx <> -1 then begin
      G7DrawLine(idx , -1, Cx,Cy,Cx,G7Bars[BarOutIdx].Cy);
    end;

    if BarInIdx <> -1 then begin
      G7DrawLine(-1, idx, Cx,G7Bars[BarInIdx].Cy,Cx,Cy);
    end;


    Brush.Style:=bsClear;
    pen.Style:=psSolid;
    Font.Size:=10+FontZoom;

    if UpperCase(copy(Name,1,1))='X' then ShortName := copy(Name,2,99) else ShortName := Name;
    w := TextWidth(ShortName);
    TextRect(r,((r.Left+r.Right) div 2) - (w div 2),r.top+1, ShortName);

    Font.Size:=9+FontZoom;
    w := TextWidth(text);
    TextRect(r,((r.Left+r.Right) div 2) - (w div 2),r.bottom - TextHeight(text)-1,text);
    //Rectangle(r);

    if CBBarNum.Checked then begin
      Font.Size  := 8+FontZoom;
      Font.Color := clFuchsia;
      ShortName  := '|' + IntToStr(BarinIdx) + '|';
      w := TextWidth(ShortName);
      TextRect(r,((r.Left+r.Right) div 2) - (w div 2),r.bottom - TextHeight(ShortName)*3-1,ShortName);
      ShortName := '|' + IntToStr(BarOutIdx) + '|';
      w := TextWidth(ShortName);
      TextRect(r,((r.Left+r.Right) div 2) - (w div 2),r.bottom - TextHeight(ShortName)*2-1,ShortName);
      Font.Color := pen.Color;
    end;

    ////////////////// ACTIONS ///////////////////////

    if code<>'' then begin
      if not CBRoundStates.Checked then begin
        r:=G7CellToRect(cx, cy,StepRightHalf);
        Rectangle(r.Left-2, r.Top-1,r.Right+1,r.Bottom+1);
        Rectangle(r_step.Right  , ((r.Top+r.Bottom) div 2)-1,
                       r.Left -2, ((r.Top+r.Bottom) div 2)+1);
        G7TextWrap(r,Code,CBEliminateNewLine.Checked);
      end else begin
        // OK for 1 line
        // r.Top:=r.Top+Font.Height+4;
        // TextRect(r,((r.Left+r.Right) div 2) - (w div 2),(r.Top+r.Bottom) div 2,Code);
        w:=pos(chr(13),code);
        if w=0 then
          w:=TextWidth(Code)
        else begin
          w:=TextWidth(copy(Code,1,w-1));
        end;
        r.Top:=(r.Top+r.Bottom) div 2-SubCellHeight;
        r.Left:=max(r.left,((r.Left+r.Right) div 2) - (w div 2));
        G7TextWrap(r,Code);
      end;
    end;
    Brush.Style:=bsSolid;

    if (g7fActive in flags) then Pen.Width:=1;

  end;
end;


procedure TFormG7.G7DrawTr(idx: integer);
var
  r, r_temp : TRect;
  cx, cy, w : integer;
  s : string;
begin
  with CurG7Canvas, G7Objects[idx] do begin          // Magic numbers dependentes de SubCellCnt

    cx := CellX;
    cy := CellY;

    brush.Style:=bsSolid;
    brush.Color:=clBkg;
    if G7IsPhantom(idx) then
      Pen.Color:=clPhantom
    else
    if G7IsSelected(idx) then
      if MoveActive then begin
        Pen.Color:=ClMove;
        cx := CellX + MoveCellXOffset;
        cy := CellY + MoveCellYOffset;
      end else Pen.Color:=ClSelected
    else Pen.Color:=ClTr;

    if BarInIdx <> -1 then begin
      G7DrawLine(-1, idx, Cx,G7Bars[BarInIdx].Cy,Cx,Cy);
    end;

    if BarOutIdx <> -1 then begin
      G7DrawLine(idx, -1, Cx,Cy,Cx,G7Bars[BarOutIdx].Cy);
    end;

    r:=G7CellToRect(cx, cy, TrRect);
    Rectangle(r);
    Brush.Style:=bsSolid;
    if Code<>'' then Brush.Color:=clCoded else Brush.Color:=clBkg;
    // Rectangle(G7CellToRect(cx, cy, TrRect_1));  // Turn off or on small empty or blue square

    CurG7Canvas.Font.Size:=8+FontZoom;
    Brush.Color:=clBkg;
    Brush.Style:=bsClear;
    r_temp:=G7CellToRect(cx, cy,TrLeftHalf);
    r_temp.Left := r_temp.Left-5;
    TextRect ( r_temp,
               r.Left-TextWidth(Name) , ((r.top + r.Bottom) div 2) - (TextHeight(Name) div 2) , Name);
    r:=G7CellToRect(cx, cy,TrRightHalf);
    G7TextWrap(r,code,CBEliminateNewLine.Checked);
    Brush.Style:=bsSolid;

    if CBBarNum.Checked then begin
      Font.Size  := 8+FontZoom;
      Font.Color := clFuchsia;
      s := '|' + IntToStr(BarInIdx) + '|';
      TextRect ( r_temp, r_temp.Left , r_temp.top, s);
      s := '|' + IntToStr(BarOutIdx) + '|';
      TextRect ( r_temp, r_temp.Left , r_temp.Bottom - TextHeight(s), s);
      Font.Color := pen.Color;
    end;

  end;
end;


procedure TFormG7.G7DrawJumpStart(idx: integer);
var
  r : TRect;
  cx, cy, w: integer;
  s : string;
begin
  with CurG7Canvas, G7Objects[idx] do begin         // Magic numbers dependentes de SubCellCnt

    if G7IsPhantom(idx) then begin   // Check Phantom object
      CurG7Canvas.Pen.Style:=psDot;
    end else begin
      CurG7Canvas.Pen.Style:=psSolid;
    end;

    if g7fInitial in flags then
      Pen.Color:=clJumpStart
    else
      Pen.Color:=clBkg;

    cx := CellX;
    cy := CellY;
    if G7IsSelected(idx) then begin
      if MoveActive then begin
        Pen.Color:=ClGray;
        cx := CellX + MoveCellXOffset;
        cy := CellY + MoveCellYOffset;
      end else Pen.Color:=ClSelected;
    end else Pen.Color:=ClStep;

    if g7fLinkVisible in flags then begin
      if JumpIdx >= 0 then begin
         // Default is draw link line when possible!
         if (G7Objects[JumpIdx].CellX = CellX) and (G7Objects[JumpIdx].Page = Page) then begin
          G7DrawLine(JumpIdx, idx, cx,cy,cx,G7Objects[JumpIdx].CellY,false,True); // uplink
          Pen.Color:=clSkyBlue;
          //Font.Color:=Pen.Color;
        end;
      end;
    end;

    Brush.Style:=bsClear;

    r:=G7CellToRect(Cx,Cy,JumpStartRect);
    //rectangle(r);
    moveto(r.Left,r.Top);
    lineto(r.Right,r.Top);
    lineto((r.Left + r.Right)div 2, (r.Top + r.Bottom) div 2);
    lineto(r.Left,r.Top);

    // object has no bar out

    if BarInIdx <> -1 then begin
      G7DrawLine(-1, idx, cx,G7Bars[BarInIdx].Cy,cx,cy);
    end;

    Font.Size:=8+FontZoom;
    Font.Color:=pen.Color;
    w:=TextWidth(Name);
    TextRect(G7CellToRect(Cx,Cy,JumpStartLeftHalf),((r.Left+r.Right) div 2) - (w div 2), ((r.Top + r.Bottom) div 2) , Name);
    Brush.Style:=bsSolid;
    Font.Color:=clBlack;

    if JumpIdx >= 0 then begin  // confirm good link
      MoveTo(r.Right+2 ,r.top);
      with PenPos do LineTo(x+2,y+2);
      with PenPos do LineTo(x+3,y-7-FontZoom);
    end;


    if CBBarNum.Checked then begin
      r.Right := r.Right+100;
      Font.Color := clFuchsia;
      s := '|' + IntToStr(BarInIdx) + '|';
      TextRect ( r, r.Left+30 , r.top, s);
      s := '|' + IntToStr(BarOutIdx) + '|';
      TextRect ( r, r.Left+30 , r.Bottom - TextHeight(s), s);
      Font.Color := pen.Color;
    end;

  end;
end;


procedure TFormG7.G7DrawJumpFinish(idx: integer);
var
  r : TRect;
  cx, cy, xmid, ymid, w, jmpstartidx : integer;
  s : string;
begin
  with CurG7Canvas, G7Objects[idx] do begin         // Magic numbers dependentes de SubCellCnt

    if G7IsPhantom(idx) then begin   // Check Phantom object
      CurG7Canvas.Pen.Style:=psDot;
    end else begin
      CurG7Canvas.Pen.Style:=psSolid;
    end;

    if g7fInitial in flags then
      Pen.Color:=clStep
    else
      Pen.Color:=clBkg;

    cx := CellX;
    cy := CellY;
    if G7IsSelected(idx) then begin
      if MoveActive then begin
        Pen.Color:=ClGray;
        cx := CellX + MoveCellXOffset;
        cy := CellY + MoveCellYOffset;
      end else Pen.Color:=ClSelected;
    end else Pen.Color:=ClStep;


    if BarOutIdx <> -1 then begin
      G7DrawLine(idx, -1, cx,cy,cx,G7Bars[BarOutIdx].Cy);
    end;

    // (object has no bar in)

    jmpstartidx:=G7GetIdXFromName(name,g7oJumpStart);
    if jmpstartidx>=0 then begin
      if (g7fLinkVisible in G7Objects[jmpstartidx].flags)
          and (G7Objects[jmpstartidx].cellx=cx)
          and (G7Objects[jmpstartidx].Page=actPage) then begin
        Pen.Color:=clSkyBlue;
        //Font.Color:=Pen.Color;
      end;
    end;

    r := G7CellToRect(Cx,Cy,JumpFinishRect);

    r.Top:=r.Top+1;
    r.Bottom:=r.Bottom+1;

    //Rectangle( r );
    xmid := (r.Left + r.Right) div 2;
    ymid := (r.Top + r.Bottom) div 2;

    moveto(r.Left,r.Top);
    lineto(xmid, r.Bottom);
    lineto(r.Right,r.Top);
    //lineto(r.Left,r.Top);


    Font.Size:=8+FontZoom;
    Font.Color:=pen.Color;
    Brush.Style:=bsClear;
    w:=TextWidth(Name);
    TextRect(G7CellToRect(Cx,Cy,JumpStartLeftHalf),((r.Left+r.Right) div 2) - (w div 2),r.top - TextHeight(Name) +1, Name);
    Brush.Style:=bsSolid;

    if jmpstartidx >= 0 then begin  // confirm good link
      //MoveTo(r.Right+2 ,r.bottom);
      MoveTo(R.Right+2, R.Top);
      with PenPos do LineTo(x+2,y+2);
      with PenPos do LineTo(x+3,y-7-FontZoom);
    end;

    if CBBarNum.Checked then begin
      Font.Color := clFuchsia;
      s := '|' + IntToStr(BarInIdx) + '|';
      r.Right   := r.Right+100;
      r.Top     := r.top-TextHeight(s);
      r.Bottom  := r.Bottom+TextHeight(s);
      //Rectangle( r );
      TextRect ( r, r.Left+30 , r.top, s);
      s := '|' + IntToStr(BarOutIdx) + '|';
      TextRect ( r, r.Left+30 , r.Bottom-TextHeight(s)-1, s);
      Font.Color := pen.Color;
    end;

  end;
end;

function Pos2Ex(const find1, find2, bigstring :string; offset : integer) : integer;
var r1,r2 : integer;
begin
  r1:=PosEx(find1,bigstring,offset);
  r2:=PosEx(find2,bigstring,offset);
  if r1=0 then result:=r2 else
  if r2=0 then result:=r1 else
    result:=min(r1,r2);
end;


procedure TFormG7.G7TextWrap( const r : trect; const TheText : string; const SubstituteNewLine : boolean=False) ;
var
  StartChar, EndChar, SpaceChar, EnterChar, prevEndChar, dy, w, rh,rw, wordcnt : integer;
  s,ts : string;
begin

  if TheText='' then exit;

  s:=TheText; //////////// Bug: Does not print 1st letter

  StartChar:=1;
  if SubstituteNewLine then
    while StartChar<length(s) do begin
      if (s[StartChar]=#13) then s[StartChar]:=';';
      // if (s[StartChar+1]=#10) then s:=copy(s,1,StartChar)+copy(s,StartChar+2,999);
      if (copy(s,StartChar+1,1)=#10) then s[StartChar+1]:=' ';
      inc(StartChar);
    end;


  dy:=0;                         // uses previouly defined font size & color
  StartChar:=1;
  EndChar:=0;

  rw:=r.Right-r.Left;
  rh:=r.Bottom-r.Top;

  EnterChar:=1;

  with curg7Canvas do begin
    Brush.Style:=bsClear;
    while (dy < rh) and (StartChar < Length(s)) do begin
      wordcnt:=0;
      while (EndChar < Length(s)) do begin
        prevEndChar:=EndChar;
        SpaceChar:=PosEx(' ',s, EndChar+1);
        if SpaceChar=0 then SpaceChar:=length(s);
        EnterChar:=PosEx(#13#10,s, EndChar+1);

        // Found Enter ?
        if (EnterChar>0) and (EnterChar<SpaceChar) {and EnterAsNewLine} then begin
          EndChar:=EnterChar-1;
        end else EndChar:=SpaceChar;

        ts:=copy(s,StartChar,EndChar-StartChar+1);
        w:=TextWidth(ts);

        // Out of margin ? => fall back one word before exit
        if (w>=rw) then begin
          if wordcnt>0 then begin
            ts:=copy(s,StartChar,PrevEndChar-StartChar+1);
            EndChar:=prevEndChar;
            break;
          end else break;
        end;

        if EndChar=EnterChar-1 then break;

        Inc(wordcnt);
      end;

      if EndChar=EnterChar-1 then begin
        EndChar:=EndChar+2;
      end;

      TextRect(r,r.left,r.top+dy,ts);
      dy:=dy+TextHeight(ts);
      StartChar:=EndChar+1;
      EndChar:=StartChar;
    end;
  end;
end;



procedure TFormG7.G7DrawComment(idx: integer);
var
  r : TRect;
  cx, cy : integer;
begin
  with G7Objects[idx], CurG7Canvas do begin

    cX := CellX;
    cY := CellY;

    Brush.Style:=bsSolid;
    Brush.Color:=clbkg;

    if G7IsPhantom(idx) then begin
      font.Color:=clPhantom;
    end else begin
      if G7IsSelected(idx) then begin // Check Phantom object
        if MoveActive then begin
          Font.Color:=ClMove;
          cx := CellX + MoveCellXOffset;
          cy := CellY + MoveCellYOffset;
        end else Font.Color:=ClSelected;
      end else Font.Color:=ClComment;
    end;
    pen.Color:=Font.Color;
    Font.Size:=8+FontZoom;
    r:=G7CellToRect(cx,cy,CommentRect);
    //Rectangle(r);
    with r do RoundRect(Left, Top, Right, Bottom, 8+FontZoom,8+FontZoom);
    r:=G7CellToRect(cx,cy,InnerCommentRect);
    G7TextWrap(r,text);
  end;
end;


procedure TFormG7.G7DrawAGridHoriz(const SubCellY : integer);
var y : integer;
begin
  with CurG7Canvas do begin
    y := round(SubCellY * SubCellHeight * g7Zoom);
    MoveTo(0,y);
    LineTo(round(FullXPix * g7Zoom), y);
  end;
end;

procedure TFormG7.G7DrawAGridVert(const SubCellX : integer);
var x : integer;
begin
  with CurG7Canvas do begin
    x := round(SubCellX * SubCellWidth * g7Zoom);
    MoveTo(x,0);
    LineTo(x,round(FullYPix * g7Zoom));
  end;
end;

procedure TFormG7.G7DrawGrid;
var
  SubCellY,CellY,SubCellX,partial : integer;
begin
  with CurG7Canvas do begin

    Brush.color := clBkg;
    Brush.Style := bsSolid;
    Pen.Style:=psClear;

    //FlickerMode(True);
    CurG7Canvas.Rectangle(ClipRect); //Clear work area
    //FormG7.Repaint;
    //FlickerMode(False);


    Pen.Style:=psSolid;

    CellY:=0;
    SubCellY:=0;

    while SubCellY < FullY do begin
      Pen.Color:=clCellGrid;  // Draw Step Lines
      G7DrawAGridHoriz(SubCellY);
      partial:=0;
      Pen.Color:=clSubCellGrid;
      while true do begin
        if (SubCellY = FullY) or (partial = SequenceYY[CellY mod 4]) then break;
        Inc(partial);
        Inc(SubCellY);
        G7DrawAGridHoriz(SubCellY);
      end;
      inc(CellY);
    end;

    SubCellX:=0;
    while SubCellX < FullX do begin
      Pen.Color:=clCellGrid;  // Draw Step Lines
      G7DrawAGridVert(SubCellX);
      partial:=0;
      Pen.Color:=clSubCellGrid;
      while true do begin
        if (SubCellX = FullX) or (partial = SizeX) then break;
        Inc(partial);
        Inc(SubCellX);
        G7DrawAGridVert(SubCellX);
      end;
    end;
  end;
end;

procedure TFormG7.G7PixToCells(const x,y: integer; out CellX,CellY : integer);
var yTemp : integer;
begin

  CellX := x div round((SubCellWidth * SizeX  * g7Zoom));

  ytemp:=y;
  CellY:=0;

  while ytemp >= BlockHeightPix*g7zoom do begin
    ytemp:=ytemp-round(BlockHeightPix*g7zoom);
    inc(CellY,4);
  end;

  if yTemp >= (ThresholdsYY[2]*SubCellHeight*g7Zoom) then
    inc(CellY,3)
  else
  if yTemp >= (ThresholdsYY[1]*SubCellHeight*g7Zoom) then
    inc(CellY,2)
  else
  if yTemp >= (ThresholdsYY[0]*SubCellHeight*g7Zoom) then
    inc(CellY,1);

  //EditDebug.Text:=Format('%d,%d = %d,%d',[x,y,cellx,celly]);
end;


// --------------------------------------------------------------------

procedure TFormG7.g7Print;
var tempzoom : integer;
begin
  Screen.Cursor:=crHourGlass;
  Printer.BeginDoc;
  CurG7Canvas:=Printer.canvas;
  Printer.Title:='Grafcet Printout '+DateToStr(Now);
  //FormG7.PrintScale:=poPrintToFit;
  tempzoom:= G7GetZoomPercent();  // DPIs ????????????????????????
  G7SetZoomPercent(200);
  FontZoom:=-2;
  G7RedrawAll;
  Printer.EndDoc;
  CurG7Canvas:=ImageG7.Canvas;
  G7SetZoomPercent(tempzoom);  // DPIs ????????????????????????
  Screen.Cursor:=crDefault;
end;

function RandBool:boolean;
begin
  if Random(2)=1 then result:=true else result:=false;
end;

//Get resolution, paper size and non-printable margin from
//      printer driver.
function GetPrinterParameters: TPrinterParmeters;
begin
  with Printer.Canvas, result do begin
    X_resolution := GetDeviceCaps(Handle, LOGPIXELSX);
    Y_resolution := GetDeviceCaps(Handle, LOGPIXELSY);
    printorigin.X := GetDeviceCaps(Handle, PHYSICALOFFSETX);
    printorigin.Y := GetDeviceCaps(Handle, PHYSICALOFFSETY);
    pagerect.Left := 0;
    pagerect.Right := GetDeviceCaps(Handle, PHYSICALWIDTH);
    pagerect.Top := 0;
    pagerect.Bottom := GetDeviceCaps(Handle, PHYSICALHEIGHT);
  end;
end;

procedure TFormG7.G7InitCursors;
begin
  crG7Edit:=crArrow;

  crG7Move:=1;
  crG7Step:=2;
  crG7Tr:=3;
  crG7Connect:=4;
  crG7Disconnect:=5;
  crG7Uplink:=6;
  crG7Delete:=7;
  crG7Jumps :=8;

  Screen.Cursors[crG7Move]       := LoadCursorFromFile('cur\Move.cur');
  Screen.Cursors[crG7Step]       := LoadCursorFromFile('cur\step.cur');
  Screen.Cursors[crG7Tr]         := LoadCursorFromFile('cur\transition.cur');
  Screen.Cursors[crG7Connect]    := LoadCursorFromFile('cur\Connect.cur');
  Screen.Cursors[crG7Disconnect] := LoadCursorFromFile('cur\disconnect.cur');
  Screen.Cursors[crG7Uplink]     := LoadCursorFromFile('cur\Uplink.cur');
  Screen.Cursors[crG7Delete]     := LoadCursorFromFile('cur\Delete.cur');
  Screen.Cursors[crG7Jumps]      := LoadCursorFromFile('cur\Jumps.cur');


end;

function TFormG7.IsDoubleLine(idx: integer): boolean;
begin
  result := false;
  if G7Bars[idx].BarType = btHigh then begin
    if G7Bars[idx].InCount > 1 then result := true;
  end;
  if G7Bars[idx].BarType = btLow then begin
    if G7Bars[idx].outCount > 1 then result := true;
  end;
end;

function TFormG7.IsOverlappingAnotherBar(idx : integer) : boolean;
var i,cnt : integer;
begin

  result:=False;

  cnt:=0;
  for i:=0 to MAXG7Bars-1 do begin
    if (i=idx) or (G7Bars[i].Connections = 0) then continue;
    if cnt >= G7BarsCount then break;
    if (G7Bars[i].Cy <> G7Bars[idx].Cy) or (G7Bars[i].Page <> G7Bars[idx].Page) then continue;
    if ( (G7Bars[i].Cxf >= G7Bars[idx].Cxi) and (G7Bars[i].Cxf <= G7Bars[idx].Cxf))  or
       ( (G7Bars[idx].Cxf >= G7Bars[i].Cxi) and (G7Bars[idx].Cxf <= G7Bars[i].Cxf) ) then begin
       result:=true;
       exit;
    end;
    inc(cnt);
  end;

end;

procedure TFormG7.G7DrawObject(i:integer);
begin
  if (G7Objects[i].Page = actPage) or G7IsPhantom(i) then begin
    case G7Objects[i].G7Type of
      g7oEmpty : ;
      g7oStep: G7DrawStep(i);
      g7oTransition: G7DrawTr(i);
      g7oJumpStart: G7DrawJumpStart(i);
      g7oJumpFinish: G7DrawJumpFinish(i);
      g7oComment  : G7DrawComment(i);
    end;
  end;
end;

procedure TFormG7.G7RedrawAll;
var barIdx: integer;
    i, cnt : integer;
    PageIsUsed : array[0..3] of Boolean;
    PageHasActiveStep : array[0..3] of Boolean;
begin

  BeginFormUpdate;

  ImageG7.Canvas.AutoRedraw:=false;  // ToDo

  for i:=Low(LabelPages) to High(LabelPages) do begin
   PageIsUsed[i]:=False;
   PageHasActiveStep[i]:=False;
  end;

  for i:=0 to MAXG7Objects-1 do begin     // Update Used Pages
    if G7Objects[i].G7Type = g7oEmpty then continue;
    PageIsUsed[G7Objects[i].Page]:=True;
    if (g7fActive in G7Objects[i].Flags) then PageHasActiveStep[G7Objects[i].Page]:=True;
  end;

  for i:=Low(LabelPages) to High(LabelPages) do begin    // Show Used Pages
    with LabelPages[i].Font do begin
      if PageIsUsed[i] then Color := clBlack else Color := clGray;
      if PageHasActiveStep[i] then Style := [fsBold] else Style := [];
    end;
  end;

  G7DrawGrid;

  // Initialize Bar dependent variables
////  cnt := 0;                                //// Horripilantis bug!!!
  for i:=0 to MAXG7Bars-1 do begin
////    if cnt >= G7BarsCount then break;
    //if G7Bars[i].Connections = 0 then continue;  // removida para descobre bug do delete

    with G7Bars[i] do begin
      Cxi := maxint;
      Cxf := -1;
      Cy := -1;
      CyMax := maxint;
      BarType :=  btUnknown;
      InCount := 0;
      OutCount:= 0;
      Connections := 0;
    end;
////    inc(cnt);
  end;

  // Calc Bar and Jump dependent variables
  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
    if cnt >= G7ObjectsCount then break;
    if G7Objects[i].G7Type = g7oEmpty then continue;

    if G7Objects[i].BarInIdx <> -1 then begin
      barIdx := G7Objects[i].BarInIdx;
      with G7Bars[barIdx] do begin
        if BarType = btUnknown then begin
          if G7ObjIsTransitionLike(i) then BarType := btHigh;
        end;
        inc(OutCount);
        Cxi   := min(Cxi, G7Objects[i].CellX);
        Cxf   := max(Cxf, G7Objects[i].CellX);
        CyMax := min(CyMax,G7Objects[i].CellY - 1);
        page  := G7Objects[i].Page;
      end;
    end;

    if G7Objects[i].BarOutIdx <> -1 then begin
      barIdx := G7Objects[i].BarOutIdx;
      with G7Bars[barIdx] do begin
        if BarType = btUnknown then begin
          if G7ObjIsTransitionLike(i) then BarType := btLow;
        end;
        inc(InCount);
        Cxi   :=  min(Cxi, G7Objects[i].CellX);
        Cxf   :=  max(Cxf, G7Objects[i].CellX);
        Cy    :=  max(Cy,  G7Objects[i].CellY + 1);
      end;
    end;

    // Refresh Jump Links
    if G7Objects[i].G7Type = g7oJumpStart then begin
      G7Objects[i].JumpIdx := G7GetIdXFromName(G7Objects[i].Name, g7oJumpFinish);
      if G7Objects[i].JumpIdx <> -1 then begin
        G7Objects[G7Objects[i].JumpIdx].JumpIdx := i;
      end;
    end;

    inc(cnt);
  end;

  // Draw Horizontal Bars
  cnt := 0;
  for i:=0 to MAXG7Bars-1 do begin
    if cnt >= G7BarsCount then break;
    with G7Bars[i] do Connections:=InCount+OutCount;
    if (G7Bars[i].Connections = 0) or (G7Bars[i].Page <> actPage) then continue;

    with G7Bars[i] do begin
      CurG7Canvas.Pen.Style := psSolid;
      if IsOverlappingAnotherBar(i) then
        CurG7Canvas.Pen.Color := ClRed
      else
        CurG7Canvas.Pen.Color := ClBlack;

      G7DrawLine(-1, -1, cxi,cy,cxf,cy,IsDoubleLine(i));

    end;
    inc(cnt);
  end;

  CurG7Canvas.Pen.Color := ClBlack;

  // Draw Objects
  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
    if cnt >= G7ObjectsCount then break;

    if G7Objects[i].G7Type <> g7oEmpty then begin
      g7DrawObject(i);
      inc(cnt);
    end;

  end;
  g7DrawObject(MAXG7Objects);  // Draw Phantoms
  g7DrawObject(MAXG7Objects+1);

  ImageG7.Invalidate;
  ImageG7.Canvas.AutoRedraw := True;

  PairSplitUp.Invalidate;

  EndFormUpdate;

end;

procedure TFormG7.BRedrawAllClick(Sender: TObject);
begin
  G7RedrawAll;
end;

function TFormG7.G7GetFreeBar: integer;
begin
  result := -1;
  if G7BarsCount >= MAXG7Bars-1 then exit;

  result:=0;
  while G7Bars[result].Connections <> 0 do begin
    inc(result);
    if result >= G7BarsCount then break;
  end;
end;

procedure DeleteBar(const BarIdx : integer);
var
  i, cnt: integer;
begin
  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
    if cnt >= G7ObjectsCount then break;
    if G7Objects[i].G7Type = g7oEmpty then continue;
    inc(cnt);

    if G7Objects[i].BarInIdx = BarIdx then begin
      G7Objects[i].BarInIdx := -1;
      dec(G7Bars[BarIdx].Connections);
      dec(G7Bars[BarIdx].InCount);
    end else

    if G7Objects[i].BarOutIdx = BarIdx then begin
      G7Objects[i].BarOutIdx := -1;
      dec(G7Bars[BarIdx].Connections);
      dec(G7Bars[BarIdx].OutCount);
    end;

    if G7Bars[BarIdx].Connections = 0 then break;
  end;
  dec(G7BarsCount);
end;

procedure TFormG7.G7DeleteObj(idx : integer);
var BarIn, BarOut : integer;
begin
  if idx < 0 then exit;
  if G7Objects[idx].G7Type = g7oEmpty then exit;

  G7Objects[idx].G7Type := g7oEmpty;
  dec(G7ObjectsCount);    ///// rever - Maio 2018  -- este conceito é para cair :(
  G7Objects[idx].Name := '';
  G7Objects[idx].Code := '';
  G7Objects[idx].Text := '';

  BarIn  := G7Objects[idx].BarInIdx;
  BarOut := G7Objects[idx].BarOutIdx;

  if BarIn >= 0 then begin

    dec(G7Bars[BarIn].Connections);    ///// rever - Maio 2018
    dec(G7Bars[BarIn].OutCount);       ///// rever - Maio 2018

    //    if (G7Bars[BarIdx].OutCount = 1) then begin
    if (G7Bars[BarIn].Connections = 1) or (G7Bars[BarIn].OutCount=0) then begin
      DeleteBar(BarIn);
    end;

    G7Objects[idx].BarInIdx := -1;
  end;


  if BarOut >= 0 then begin

    dec(G7Bars[BarOut].Connections);
    dec(G7Bars[BarOut].InCount);

    //    if (G7Bars[BarIdx].InCount = 1) then begin
    if (G7Bars[BarOut].Connections = 1) or (G7Bars[BarOut].InCount=0) then begin
      DeleteBar(BarOut);
    end;

    G7Objects[idx].BarOutIdx := -1;
  end;

  idx := -1;                          // Deve corrigir bug delete esquisito Maio 2013 
  SelectedG7Obj := -1;
  SelectedG7ObjCount := 0;
  G7RedrawAll;
end;

function TFormG7.G7CreateObj(const pg, cx, cy : integer): integer;
begin
  result := G7GetFreeIndex();
  if result = -1 then exit;

  with G7Objects[result] do begin
    Page := pg;
    CellX:=CX;
    CellY:=CY;
    BarInIdx:=-1;
    BarOutIdx:=-1;
    Name:='';
    text:='';
    code:='';
    flags := [];
    Inc(G7ObjectsCount);
  end;
end;

function TFormG7.G7CreateStep(const pg, cx, cy : integer): integer;
begin
  result := G7CreateObj(pg, cx, cy);
  if result = -1 then exit;

  with G7Objects[result] do begin
    G7Type := g7ostep;
    Name := StepPrefix + IntToStr(StepCount);
    inc(StepCount);
  end;
end;

function TFormG7.G7CreateTr(const pg, cx, cy : integer): integer;
begin
  result := G7CreateObj(pg, cx, cy);
  if result = -1 then exit;

  with G7Objects[result] do begin
    G7Type := g7oTransition;
    Name := TrPrefix + IntToStr(TrCount);
    inc(TrCount);
  end;
end;

function TFormG7.G7CreateJumpStart(const pg, cx, cy : integer): integer;
begin
  result := G7CreateObj(pg, cx, cy);
  if result = -1 then exit;

  with G7Objects[result] do begin
    G7Type := g7oJumpStart;
    Name := 'Jump'+inttostr(JumpStartCount);
    inc(JumpStartCount);
    flags:=[g7fLinkVisible];
  end;
end;

function TFormG7.G7CreateJumpFinish(const pg, cx, cy : integer): integer;
begin
  result := G7CreateObj(pg, cx, cy);
  if result = -1 then exit;

  with G7Objects[result] do begin
    G7Type := g7oJumpFinish;
    Name := 'Jump'+inttostr(JumpFinishCount);
    inc(JumpFinishCount);
  end;
end;

function TFormG7.G7CreateComment(const pg, cx, cy : integer): integer;
begin
  result := G7CreateObj(pg, cx, cy);
  if result = -1 then exit;

  with G7Objects[result] do begin
    G7Type := g7oComment;
    Name :=CommentPrefix+IntToStr(CommentCount);
    text:='';
    inc(CommentCount);
  end;
end;

function TFormG7.G7FlagsToInteger(TheFlags: TG7Flags): integer;
var i: TG7Flag;
    b: boolean;
begin
  result := 0;
  for i :=low(TG7Flag) to high(TG7Flag) do begin
    b := i in TheFlags;
    if b then result := result or (1 shl ord(i));
  end;
end;

function TFormG7.G7IntegerToG7Flags(TheInt: integer): TG7Flags;
var i: TG7Flag;
    b: boolean;
begin
  result := [];
  for i :=low(TG7Flag) to high(TG7Flag) do begin
    b := ((1 shl ord(i)) and TheInt) <> 0;
    if b then result := result + [i];
  end;
end;

// SAVE/LOAD XML     SAVE/LOAD XML     SAVE/LOAD XML
// SAVE/LOAD XML     SAVE/LOAD XML     SAVE/LOAD XML



procedure TFormG7.G7CleanUpForImport;
begin
  SelectedG7Obj := -1;
  SelectedG7ObjCount := 0;

  with UpStartObj do begin
    BarInIdx  := -1;
    BarOutIdx := -1;
    JumpIdx   := -1;
  end;
  with UpFinishObj do begin
    BarInIdx  := -1;
    BarOutIdx := -1;
    JumpIdx   := -1;
  end;
end;

//LOAD LOAD LOAD LOAD LOAD LOAD LOAD LOAD LOAD LOAD LOAD LOAD
function  TFormG7.G7LoadXML(const fn: string; onlyG7:boolean; SaveProjDoc:TDOMNode;
                    ImportGr7Page3Mode : Boolean = FALSE): boolean;
var
  {FA_Resolvido
    Item, ObjItem, PropItem: TXMLItem;
  }
    i, v, len, BaseG7Obj , tempN : integer;
    TempString,s : string;
    Doc: TXMLDocument;    // variable to document
    RootNode,GraphNode,ObjectsNode: TDOMNode; // BIG NODES
    ObjNode:TDOMNode;//Object,Code,Text
begin
  result:=false;
  DupG7Objects;
  if not ImportGr7Page3Mode then
    G7Clear()
  else
    G7CleanUpForImport;

  try

    if (onlyG7)then begin
      ReadXMLFile(Doc, fn);

      RootNode:=Doc.FirstChild;
      //Verificação 1
      if (RootNode.NodeName<>'G7Project') then begin
        result:=false;
      end;
    end
    else begin
      RootNode:=SaveProjDoc;
    end;

    //Verificação 2
    GraphNode:=RootNode.FirstChild;
    if (GraphNode.NodeName<>'Graph') then begin
        result:=false;
        exit;
      end;
    //Verificação 3
    ObjectsNode:=GraphNode.FirstChild;
    if (ObjectsNode.NodeName<>'Objects') then begin
        result:=false;
        exit;
      end;

    //Inicio LOAD
    if not ImportGr7Page3Mode then begin
      G7ObjectsCount := 0;
      BaseG7Obj := 0;
    end else  begin
      //BaseG7Obj := G7ObjectsCount;
      for BaseG7Obj:=high(G7Objects)-3 downto 0 do begin
        if G7Objects[BaseG7Obj].G7Type <> g7oEmpty then break;
      end;
      inc(BaseG7Obj); // Point to a free object
    end;

    //for i:=0 to ObjectsNode.GetChildNodes.Count  do begin
    for i:=0 to ObjectsNode.GetChildCount-1  do begin
      ObjNode := ObjectsNode.ChildNodes[i];

      if ImportGr7Page3Mode AND
          ((strtointdef((ObjNode.Attributes.GetNamedItem('Page').TextContent),0))<3) then
      continue;

      s := ObjNode.Attributes.GetNamedItem('Name').TextContent;
      tempN := GetObjIdx(s);
      if (TempN=-1) or not ImportGr7Page3Mode then begin
        G7Objects[BaseG7Obj+i].Name:=s
      end else begin
        if (UpperCase(copy(s,1,4))='JUMP') OR (UpperCase(copy(s,1,4))='J777') then
            G7Objects[BaseG7Obj+i].Name:=s
        else begin
            //G7Objects[BaseG7Obj+i].Name:=s[1]+'9'+copy(s,2,999);
          FormSelfGrade.Log('Esquiza Var Repet => '+s+' => ' + IntToStr(TempN)+' =?= '+IntToStr(BaseG7Obj+i)+' ie. ' +
          G7Objects[TempN].Name+' =?= '+G7Objects[BaseG7Obj+i].Name);
        end;
      end;

      G7Objects[BaseG7Obj+i].Page := strtointdef((ObjNode.Attributes.GetNamedItem('Page').TextContent),0);
      G7Objects[BaseG7Obj+i].CellX := strtointdef((ObjNode.Attributes.GetNamedItem('CellX').TextContent),0);
      G7Objects[BaseG7Obj+i].CellY := strtointdef((ObjNode.Attributes.GetNamedItem('CellY').TextContent),0);
      G7Objects[BaseG7Obj+i].BarInIdx := strtointdef((ObjNode.Attributes.GetNamedItem('BarInIdx').TextContent),-1);
      G7Objects[BaseG7Obj+i].G7Type := TG7Type(strtointdef((ObjNode.Attributes.GetNamedItem('Type').TextContent),0));
      v := G7Objects[BaseG7Obj+i].BarInIdx;
      if v <> -1 then begin
        if G7Bars[v].Connections = 0 then inc(G7BarsCount);
        inc(G7Bars[v].Connections);
      end;
      G7Objects[BaseG7Obj+i].BarOutIdx := strtointdef((ObjNode.Attributes.GetNamedItem('BarOutIdx').TextContent),-1);
      v := G7Objects[BaseG7Obj+i].BarOutIdx;
      if v <> -1 then begin
        if G7Bars[v].Connections = 0 then inc(G7BarsCount);
        inc(G7Bars[v].Connections);
      end;

      len := length(G7Objects[BaseG7Obj+i].Name);
      case G7Objects[BaseG7Obj+i].G7Type of

        g7oStep         : if pos(StepPrefix, G7Objects[BaseG7Obj+i].Name)=1 then
          StepCount := max(StepCount,           1+StrToIntDef(copy(G7Objects[BaseG7Obj+i].Name,length(StepPrefix)+1,len),0));

        g7oTransition   : if pos(TrPrefix, G7Objects[BaseG7Obj+i].Name)=1 then
          TrCount   := max(TrCount,             1+StrToIntDef(copy(G7Objects[BaseG7Obj+i].Name,length(TrPrefix)+1,len),0));

        g7oJumpStart    : if pos(JumpPrefix, G7Objects[BaseG7Obj+i].Name)=1 then
          JumpStartCount := max(JumpStartCount, 1+StrToIntDef(copy(G7Objects[BaseG7Obj+i].Name,length(JumpPrefix)+1,len),0));

        g7oJumpFinish   : if pos(JumpPrefix, G7Objects[BaseG7Obj+i].Name)=1 then
          JumpFinishCount := max(JumpFinishCount,1+StrToIntDef(copy(G7Objects[BaseG7Obj+i].Name,length(JumpPrefix)+1,len),0));

        g7oComment      : if pos(CommentPrefix, G7Objects[BaseG7Obj+i].Name)=1 then
          CommentCount := max(CommentCount,     1+StrToIntDef(copy(G7Objects[BaseG7Obj+i].Name,length(CommentPrefix)+1,len),0));

      end;

      v:=StrToIntDef((ObjNode.Attributes.GetNamedItem('Flags').TextContent) ,0);
      G7Objects[BaseG7Obj+i].Flags := G7IntegerToG7Flags(v);


      TempString := ObjNode.ChildNodes[0].TextContent;  //CODE
      if (Copy(TempString,1,1)='~') then TempString := copy(TempString,2,9999);
      G7Objects[BaseG7Obj+i].code := TempString; //CODE
      G7Objects[BaseG7Obj+i].Text := ObjNode.ChildNodes[1].TextContent; //TEXT

      inc(G7ObjectsCount);
    end;

    result:=true;  // load successfully
  finally
    if (onlyG7)then begin
      Doc.Free;
    end;
  end;

{FA_Resolvido
  SL := TStringList.Create;

  result:=false;

  DupG7Objects;
  G7Clear();
  try
    // Enter basic data in xml-file
    XML.LoadFromFile(fn);
    if XML.Root.Name <> 'G7Project' then exit;

    i := XML.Root.IndexOfName('Graph');
    if i < 0 then exit;
    Item := XML.Root.SubItems[i];

    i := Item.IndexOfName('Objects');
    if i < 0 then exit;
    Item := Item.SubItems[i];

    G7ObjectsCount := 0;
    for i:=0 to Item.SubItemCount-1 do begin
      ObjItem := Item.SubItems[i];

      G7Objects[i].Page := strtointdef(ObjItem.Params.Values['Page'],0);
      //G7Objects[i].Number := strtointdef(ObjItem.Params.Values['Number'],0);
      G7Objects[i].Name := ObjItem.Params.Values['Name'];
      G7Objects[i].CellX := strtointdef(ObjItem.Params.Values['CellX'],0);
      G7Objects[i].CellY := strtointdef(ObjItem.Params.Values['CellY'],0);
      G7Objects[i].BarInIdx := strtointdef(ObjItem.Params.Values['BarInIdx'],-1);
      v := G7Objects[i].BarInIdx;
      if v <> -1 then begin
        if G7Bars[v].Connections = 0 then inc(G7BarsCount);
        inc(G7Bars[v].Connections);
      end;
      G7Objects[i].BarOutIdx := strtointdef(ObjItem.Params.Values['BarOutIdx'],-1);
      v := G7Objects[i].BarOutIdx;
      if v <> -1 then begin
        if G7Bars[v].Connections = 0 then inc(G7BarsCount);
        inc(G7Bars[v].Connections);
      end;
      G7Objects[i].G7Type := TG7Type(strtointdef(ObjItem.Params.Values['Type'],0));

      len := length(G7Objects[i].Name);
      case G7Objects[i].G7Type of

        g7oStep         : if pos(StepPrefix, G7Objects[i].Name)=1 then
          StepCount := max(StepCount, 1+StrToIntDef(copy(G7Objects[i].Name,length(StepPrefix)+1,len),0));

        g7oTransition   : if pos(TrPrefix, G7Objects[i].Name)=1 then
          TrCount   := max(TrCount, 1+StrToIntDef(copy(G7Objects[i].Name,length(TrPrefix)+1,len),0));

        g7oJumpStart    : if pos(JumpPrefix, G7Objects[i].Name)=1 then
          JumpStartCount := max(JumpStartCount, 1+StrToIntDef(copy(G7Objects[i].Name,length(JumpPrefix)+1,len),0));

        g7oJumpFinish   : if pos(JumpPrefix, G7Objects[i].Name)=1 then
          JumpFinishCount := max(JumpFinishCount, 1+StrToIntDef(copy(G7Objects[i].Name,length(JumpPrefix)+1,len),0));

        g7oComment      : if pos(CommentPrefix, G7Objects[i].Name)=1 then
          CommentCount := max(CommentCount, 1+StrToIntDef(copy(G7Objects[i].Name,length(CommentPrefix)+1,len),0));
          
      end;

      v:=strtointdef(ObjItem.Params.Values['Flags'],0);
      G7Objects[i].Flags := G7IntegerToG7Flags(v);
      //if v = 1 then G7Objects[i].Flags := [g7fInitial]
      //else G7Objects[i].Flags := [];

      PropItem := ObjItem.NamedItem['Code'];
      G7Objects[i].code := PropItem.Text;

      PropItem := ObjItem.NamedItem['Text'];
      G7Objects[i].Text := PropItem.Text;
      inc(G7ObjectsCount);
    end;

    result:=true;  // saved successfully

  finally
    SL.Free;
  end;


}

  G7RedrawAll;
end;

//SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE SAVE
function TFormG7.G7SaveXML(const fn: string; onlyG7:boolean; SaveProjDoc:TXMLDocument):boolean;
var
    i, cnt: integer;
    Doc: TXMLDocument;    // variable to document
    RootNode,GraphNode,ObjectsNode: TDOMNode; // BIG NODES
    ObjNode,CodeNode,TextNode,aNode:TDOMNode;//Object,Code,Text
begin

  result:=false;

    try
      // Create a document
      Doc := TXMLDocument.Create;
      if (not onlyG7)then begin
        Doc:=SaveProjDoc;
      end;

      // Create a root node
      if (onlyG7)then begin    //OnlyG7
        RootNode := Doc.CreateElement('G7Project');
        Doc.Appendchild(RootNode); // save root node
      end
      else begin
        RootNode := Doc.CreateElement('G7Project');
        Doc.FirstChild.Appendchild(RootNode); // save root node
      end;
      GraphNode := Doc.CreateElement('Graph');
      RootNode.Appendchild(GraphNode);
      ObjectsNode := Doc.CreateElement('Objects');
      GraphNode.Appendchild(ObjectsNode);

      cnt := 0;
      for i:=0 to MAXG7Objects-1 do begin
        if cnt >= G7ObjectsCount then break;
        if G7Objects[i].G7Type = g7oEmpty then continue;

        ObjNode := Doc.CreateElement('Obj');  // create a Object Node
        TDOMElement(ObjNode).SetAttribute('Name', (G7Objects[i].Name));
        TDOMElement(ObjNode).SetAttribute('Page', IntToStr(G7Objects[i].Page));
        TDOMElement(ObjNode).SetAttribute('CellX', IntToStr(G7Objects[i].CellX));
        TDOMElement(ObjNode).SetAttribute('CellY', IntToStr(G7Objects[i].CellY));
        TDOMElement(ObjNode).SetAttribute('BarInIdx', IntToStr(G7Objects[i].BarInIdx));
        TDOMElement(ObjNode).SetAttribute('BarOutIdx', IntToStr(G7Objects[i].BarOutIdx));
        TDOMElement(ObjNode).SetAttribute('Type', IntToStr(ord(G7Objects[i].G7Type)));
        TDOMElement(ObjNode).SetAttribute('Flags', IntToStr(G7FlagsToInteger(G7Objects[i].flags)));

        CodeNode := Doc.CreateElement('Code');        //Create a CODE Node
        aNode:=Doc.CreateTextNode('~'+G7Objects[i].code); //Get text of CODE
        CodeNode.AppendChild(aNode);                  //Insert text in CODE

        TextNode := Doc.CreateElement('Text');        //Create a TEXT Node
        aNode:=Doc.CreateTextNode(G7Objects[i].Text); //Get text of TEXT
        TextNode.AppendChild(aNode);                  //Insert text in TEXT


        ObjNode.AppendChild(CodeNode);//insert codeNode in  ObjNode -> child=0
        ObjNode.AppendChild(TextNode);//insert codeNode in  ObjNode -> child=1
        ObjectsNode.AppendChild(ObjNode);//insert objNode in  ObjectsNode


        inc(cnt); //incrementa contador
      end;

      if (onlyG7)then begin
        writeXMLFile(Doc, fn); // write to XML
      end;

      result:=true;
    finally
      if (onlyG7)then begin
        Doc.Free; // free memory
      end;
    end;

 {FA_Resolvido
  with XML do begin

    SL := TStringList.Create;
    try
      // Enter basic data in xml-file
      XML.Clear;
      XML.Root.Name := 'G7Project';

      Item := XML.Root.New;
      Item.Name := 'Graph';
      //Item.Text := 'text';

      Item:= Item.New;
      Item.Name := 'Objects';

      cnt := 0;
      for i:=0 to MAXG7Objects-1 do begin
        if cnt >= G7ObjectsCount then break;
        if G7Objects[i].G7Type = g7oEmpty then continue;

        ObjItem := Item.New;
        ObjItem.Name := 'Obj';

        PropItem := ObjItem.New;
        PropItem.Name := 'Code';
        PropItem.Text := G7Objects[i].code;

        PropItem := ObjItem.New;
        PropItem.Name := 'Text';
        PropItem.Text := G7Objects[i].Text;

        SL.Clear;
        //SL.Add(format('Number=%d',[G7Objects[i].number]));
        SL.Add(format('Name=%s',[G7Objects[i].Name]));
        SL.Add(format('Page=%d',[G7Objects[i].Page]));
        SL.Add(format('CellX=%d',[G7Objects[i].CellX]));
        SL.Add(format('CellY=%d',[G7Objects[i].CellY]));
        SL.Add(format('BarInIdx=%d',[G7Objects[i].BarInIdx]));
        SL.Add(format('BarOutIdx=%d',[G7Objects[i].BarOutIdx]));
        SL.Add(format('Type=%d',[ord(G7Objects[i].G7Type)]));
        SL.Add(format('Flags=%d',[G7FlagsToInteger(G7Objects[i].flags)]));
        ObjItem.Params.AddStrings(SL);

        inc(cnt);
      end;

      XML.SaveToFile(fn);
      result:=true;
    finally
      SL.Free;
    end;
  end;



}
end;

{Save bruno a funcionar:
  function TFormG7.G7SaveXML(const fn: string):boolean;
var
    i, cnt: integer;
    Doc: TXMLDocument;    // variable to document
    RootNode,GraphNode,ObjectsNode: TDOMNode; // BIG NODES
    ObjNode,CodeNode,TextNode,aNode:TDOMNode;//Object,Code,Text
begin

  result:=false;

    try
      // Create a document
      Doc := TXMLDocument.Create;

      // Create a root node   -> FEUPSim
      RootNode := Doc.CreateElement('G7Project');
      Doc.Appendchild(RootNode); // save root node
      GraphNode := Doc.CreateElement('Graph');
      RootNode.Appendchild(GraphNode);
      ObjectsNode := Doc.CreateElement('Objects');
      GraphNode.Appendchild(ObjectsNode);

      cnt := 0;
      for i:=0 to MAXG7Objects-1 do begin
        if cnt >= G7ObjectsCount then break;
        if G7Objects[i].G7Type = g7oEmpty then continue;

        ObjNode := Doc.CreateElement('Obj');  // create a Object Node
        TDOMElement(ObjNode).SetAttribute('Name', (G7Objects[i].Name));
        TDOMElement(ObjNode).SetAttribute('Page', IntToStr(G7Objects[i].Page));
        TDOMElement(ObjNode).SetAttribute('CellX', IntToStr(G7Objects[i].CellX));
        TDOMElement(ObjNode).SetAttribute('CellY', IntToStr(G7Objects[i].CellY));
        TDOMElement(ObjNode).SetAttribute('BarInIdx', IntToStr(G7Objects[i].BarInIdx));
        TDOMElement(ObjNode).SetAttribute('BarOutIdx', IntToStr(G7Objects[i].BarOutIdx));
        TDOMElement(ObjNode).SetAttribute('Type', IntToStr(ord(G7Objects[i].G7Type)));
        TDOMElement(ObjNode).SetAttribute('Flags', IntToStr(G7FlagsToInteger(G7Objects[i].flags)));

        CodeNode := Doc.CreateElement('Code');        //Create a CODE Node
        aNode:=Doc.CreateTextNode(G7Objects[i].code); //Get text of CODE
        CodeNode.AppendChild(aNode);                  //Insert text in CODE

        TextNode := Doc.CreateElement('Text');        //Create a TEXT Node
        aNode:=Doc.CreateTextNode(G7Objects[i].Text); //Get text of TEXT
        TextNode.AppendChild(aNode);                  //Insert text in TEXT


        ObjNode.AppendChild(CodeNode);//insert codeNode in  ObjNode -> child=0
        ObjNode.AppendChild(TextNode);//insert codeNode in  ObjNode -> child=1
        ObjectsNode.AppendChild(ObjNode);//insert objNode in  ObjectsNode


        inc(cnt); //incrementa contador
      end;

      writeXMLFile(Doc, fn); // write to XML

    finally
      Doc.Free; // free memory
    end;

 (*FA_Resolvido
  with XML do begin

    SL := TStringList.Create;
    try
      // Enter basic data in xml-file
      XML.Clear;
      XML.Root.Name := 'G7Project';

      Item := XML.Root.New;
      Item.Name := 'Graph';
      //Item.Text := 'text';

      Item:= Item.New;
      Item.Name := 'Objects';

      cnt := 0;
      for i:=0 to MAXG7Objects-1 do begin
        if cnt >= G7ObjectsCount then break;
        if G7Objects[i].G7Type = g7oEmpty then continue;

        ObjItem := Item.New;
        ObjItem.Name := 'Obj';

        PropItem := ObjItem.New;
        PropItem.Name := 'Code';
        PropItem.Text := G7Objects[i].code;

        PropItem := ObjItem.New;
        PropItem.Name := 'Text';
        PropItem.Text := G7Objects[i].Text;

        SL.Clear;
        //SL.Add(format('Number=%d',[G7Objects[i].number]));
        SL.Add(format('Name=%s',[G7Objects[i].Name]));
        SL.Add(format('Page=%d',[G7Objects[i].Page]));
        SL.Add(format('CellX=%d',[G7Objects[i].CellX]));
        SL.Add(format('CellY=%d',[G7Objects[i].CellY]));
        SL.Add(format('BarInIdx=%d',[G7Objects[i].BarInIdx]));
        SL.Add(format('BarOutIdx=%d',[G7Objects[i].BarOutIdx]));
        SL.Add(format('Type=%d',[ord(G7Objects[i].G7Type)]));
        SL.Add(format('Flags=%d',[G7FlagsToInteger(G7Objects[i].flags)]));
        ObjItem.Params.AddStrings(SL);

        inc(cnt);
      end;

      XML.SaveToFile(fn);
      result:=true;
    finally
      SL.Free;
    end;
  end;
       *)


end;
}

{XML NOVO:
<?xml version="1.0" encoding="UTF-8"?>
<G7Project>
  <Graph>
    <Objects>
      <Obj Name="X0" Page="0" CellX="0" CellY="0" BarInIdx="-1" BarOutIdx="4" Type="1" Flags="0">
        <Code></Code>
        <Text></Text>
      </Obj>
      </Obj>
    </Objects>
  </Graph>
</G7Project>

:XML NOVO}


///////////////////////////////////////////////////////////////////////////////
//       GUI
///////////////////////////////////////////////////////////////////////////////
function TFormG7.G7GetObjectAtPix(const clickX, clickY : integer; out G7ObjIdx : integer) : boolean;
var cx,cy : integer;
begin
  G7PixToCells(clickX,clicky,cx,cy);
  result:=G7GetObjectAtCell(cx, cy, G7ObjIdx);
end;

function TFormG7.G7GetObjectAtCell(const cx, cy : integer; out G7ObjIdx : integer) : boolean;
var i, cnt: integer;
begin
  result:=false;
  G7ObjIdx:=-1;

  i:=0;
  cnt:=0;
  while (cnt < G7ObjectsCount) and (i < MAXG7Objects) do begin
    if G7Objects[i].G7Type = g7oEmpty then begin
      inc(i);
      continue;
    end;

    if (G7Objects[i].CellX = cx) and (G7Objects[i].Celly = cy) and (actPage = G7Objects[i].Page) then begin
      G7ObjIdx := i;
      result:=true;
      exit;
    end;

    inc(i);
    inc(cnt);
  end;

  if (cnt < G7ObjectsCount) then
      Screen.Cursor:=crG7Delete;

end;

procedure TFormG7.G7SelectObject(ObjIdx: integer);
var TIP: TItemProp;
    KeyName, value: string;
    oldSelectedG7Obj: integer;
begin

  if ObjIdx<0 then begin
    SelectedG7Obj:=-1;
    SelectedG7ObjCount:=0;
    VLEPropEdit.Strings.Clear;

    SynEditST_G7.Tag:=-1;
    SynEditST_G7.ClearAll;
    SynEditST_G7.ReadOnly := true;
    exit;
  end;

  if not(FMain.ScriptState=ssRunning)Then SynEditST_G7.ReadOnly := False;

  oldSelectedG7Obj := SelectedG7Obj;
  SelectedG7Obj := ObjIdx;
  SelectedG7ObjCount := 1;
  MoveCellXOrigin := G7Objects[ObjIdx].CellX;
  MoveCellYOrigin := G7Objects[ObjIdx].CellY;

  MoveCellXOffset := 0;
  MoveCellYOffset := 0;

  if G7Objects[ObjIdx].G7Type = g7oStep then begin // Selected a Step
    KeyName := VLEPropEdit.Cells[0,VLEPropEdit.Row];
    value := VLEPropEdit.Cells[1,VLEPropEdit.Row];
    VLEPropEditValidateAndSet(oldSelectedG7Obj, KeyName, Value);

    VLEPropEdit.Refresh;
    VLEPropEdit.Strings.BeginUpdate;
    VLEPropEdit.Strings.Clear;
    VLEPropEdit.Strings.Add(format('Name=%s',[G7Objects[ObjIdx].Name]));
    VLEPropEdit.Strings.Add(format('Comment=%s',[G7Objects[ObjIdx].text]));
    VLEPropEdit.Strings.Add(format('Initial=%s',[BoolToStr(g7fInitial in G7Objects[ObjIdx].flags, true)]));
    VLEPropEdit.Strings.EndUpdate;
    TIP := VLEPropEdit.ItemProps['Initial'];
    if(Assigned(TIP))then begin
      TIP.PickList.Add('False');
      TIP.PickList.Add('True');
    end;

    // New ST editor stuff
    SynEditST_G7.Lines.Text:=G7Objects[ObjIdx].code;
    SynEditST_G7.Tag := ObjIdx;


  end else if G7Objects[ObjIdx].G7Type = g7oTransition then begin
    KeyName := VLEPropEdit.Cells[0,VLEPropEdit.Row];
    value := VLEPropEdit.Cells[1,VLEPropEdit.Row];
    VLEPropEditValidateAndSet(oldSelectedG7Obj, KeyName, Value);

    //VLEPropEdit.Refresh;
    VLEPropEdit.Strings.BeginUpdate;
    VLEPropEdit.Strings.Clear;
    VLEPropEdit.Strings.Add(format('Name=%s',[G7Objects[ObjIdx].Name]));
    VLEPropEdit.Strings.Add(format('Comment=%s',[G7Objects[ObjIdx].text]));

    // New ST editor stuff
    SynEditST_G7.Text := G7Objects[ObjIdx].code;
    SynEditST_G7.Tag := ObjIdx;


  end else if G7Objects[ObjIdx].G7Type in [g7oJumpStart, g7oJumpFinish] then begin
    KeyName := VLEPropEdit.Cells[0,VLEPropEdit.Row];
    value := VLEPropEdit.Cells[1,VLEPropEdit.Row];
    VLEPropEditValidateAndSet(oldSelectedG7Obj, KeyName, Value);

    VLEPropEdit.Refresh;
    VLEPropEdit.Strings.BeginUpdate;
    VLEPropEdit.Strings.Clear;
    VLEPropEdit.Strings.Add(format('Label=%s',[G7Objects[ObjIdx].Name]));
    if G7Objects[ObjIdx].G7Type = g7oJumpStart then begin
      VLEPropEdit.Strings.Add(format('DrawConnection=%s',[BoolToStr(g7fLinkVisible in G7Objects[ObjIdx].flags, true)]));
      VLEPropEdit.Strings.EndUpdate;
      TIP := VLEPropEdit.ItemProps['DrawConnection'];
      if(Assigned(TIP))then begin
        TIP.PickList.Add('False');
        TIP.PickList.Add('True');
      end;
    end;

  end else if G7Objects[ObjIdx].G7Type = g7oComment then begin
    KeyName := VLEPropEdit.Cells[0,VLEPropEdit.Row];
    value := VLEPropEdit.Cells[1,VLEPropEdit.Row];
    VLEPropEditValidateAndSet(oldSelectedG7Obj, KeyName, Value);

    VLEPropEdit.Refresh;
    VLEPropEdit.Strings.BeginUpdate;
    VLEPropEdit.Strings.Clear;
    VLEPropEdit.Strings.Add(format('Comment=%s',[G7Objects[ObjIdx].text]));

    SynEditST_G7.ClearAll;   {FA_Resolvido}
    SynEditST_G7.ReadOnly := true;
  end;

  if FMain.ScriptState=ssRunning then SynEditST_G7.ReadOnly := true;

  VLEPropEdit.Strings.EndUpdate;
  VLEPropEdit.Refresh;
end;

procedure TFormG7.ImagesMouseDown(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
var ObjIdx : integer;
    cxi,cyi, rem : integer;
begin


  if ssRight in Shift then exit;

  MouseDownX:=X;
  MouseDownY:=Y;

  if (FMain.ScriptState=ssRunning)Then begin
    if G7GetObjectAtPix(x,y, ObjIdx) then begin // Select targeted obj
      G7SelectObject(ObjIdx);
    end;
    exit;
  end;

  Panel1Left.SetFocus;

  SetTemporaryTool(Shift - [ssleft]);  // left mouse button prevents temp tool change

  if SPEdit.Down then begin // Selection Tool
    if G7GetObjectAtPix(x,y, ObjIdx) then begin // Select targeted obj
      G7SelectObject(ObjIdx);
    end else begin  // empty -> deselect all
      SelectedG7Obj := -1;
      SelectedG7ObjCount := 0;
    end;

  end else if SPStepTransition.Down then begin // Create Step/Transition Tool

    if not G7GetObjectAtPix(x,y, ObjIdx) then begin // empty -> create new
      G7PixToCells(MouseDownX,MouseDownY,Cxi,Cyi);
      rem := cyi mod MoveCellYQuantum;
      if rem=0 then begin
        DupG7Objects;
        ObjIdx := G7CreateStep(actPage,cxi,cyi);  // empty => create step
      end else if rem = 2 then begin
        DupG7Objects;
        ObjIdx := G7CreateTr(actPage,cxi,cyi);   // empty => create Tr
      end;

      if ObjIdx <> -1 then begin
        G7SelectObject(ObjIdx);
      end;

    end else begin // non empty click
      G7SelectObject(ObjIdx);
    end;

  end else if SPConnector.Down then begin // Create/Delete Connection Tool
    if G7GetObjectAtPix(x,y, ObjIdx) then begin // Must target obj
      if G7Objects[ObjIdx].G7Type in [g7oStep, g7oTransition, g7oJumpStart, g7oJumpFinish] then begin
          ConStartObjIdx := ObjIdx;
          ConFinishObjIdx:=-1;
      end;
    end else begin
      ConStartObjIdx:=-1;
      ConFinishObjIdx:=-1;
    end;

  end else if SPJump.Down then begin // Create Jump Tool

    if not G7GetObjectAtPix(x,y, ObjIdx) then begin // empty -> create new
      G7PixToCells(MouseDownX,MouseDownY,Cxi,Cyi);
      rem := cyi mod MoveCellYQuantum;
      if rem=0 then begin
        DupG7Objects;
        ObjIdx := G7CreateJumpStart(actPage,cxi,cyi);  // empty => create Jump Start
      end else if rem = 2 then begin
        DupG7Objects;
        ObjIdx := G7CreateJumpFinish(actPage,cxi,cyi);   // empty => create Jump Finish
      end;

      if ObjIdx <> -1 then begin
        G7SelectObject(ObjIdx);
      end;

    end else begin // non empty click
      G7SelectObject(ObjIdx);
    end;

  end else if SPUpLink.Down then begin // Uplink Tool

    G7PixToCells(MouseDownX,MouseDownY,Cxi,Cyi);
    rem := cyi mod MoveCellYQuantum;
    UpStartObj.G7Type  := g7oEmpty;
    UpFinishObj.G7Type := g7oEmpty;
    UpStartObj.flags   := UpStartObj.flags  - [g7fInitial];
    UpFinishObj.flags  := UpFinishObj.flags - [g7fInitial];

    G7GetObjectAtPix(x,y, ObjIdx);

    if ObjIdx>=0 then begin // Select targeted obj
      G7SelectObject(ObjIdx);
    end else begin
      if ((rem=0) or (rem=2)) then begin // must be empty
        if rem=0 then begin
          UpStartObj.G7Type  := g7oJumpStart;
          UpStartObj.CellX   := cxi;
          UpStartObj.CellY   := cyi;
          UpStartObj.flags   := UpStartObj.flags+[g7fInitial];
          G7Objects[MAXG7Objects]:=UpStartObj;
        end else if rem = 2 then begin
          UpFinishObj.G7Type := g7oJumpFinish;
          UpFinishObj.CellX  := cxi;
          UpFinishObj.CellY  := cyi;
          UpFinishObj.flags  := UpFinishObj.flags+[g7fInitial];
          G7Objects[MAXG7Objects]:=UpFinishObj;
        end;
      end;
    end;
  end else if SPComment.Down then begin // Comment Tool

    if not G7GetObjectAtPix(x,y, ObjIdx) then begin // empty -> create new
      G7PixToCells(MouseDownX,MouseDownY,Cxi,Cyi);
      rem := cyi mod MoveCellYQuantum;
      if rem=0 then begin
        DupG7Objects;
        ObjIdx := G7CreateComment(actPage,cxi,cyi);  // empty => create Jump Start
        if ObjIdx <> -1 then begin
          G7SelectObject(ObjIdx);
        end;
      end;
    end else begin // non empty click
      G7SelectObject(ObjIdx);
    end;
  end;

  G7RedrawAll;

  ElasticXi:=0;
  ElasticYi:=0;
  ElasticXf:=0;
  ElasticYf:=0;

end;

function TFormG7.IsMoveValid(Cx, Cy, G7ObjIdx: Integer): boolean;
begin

  Result := ((G7ObjIdx = -1) or (G7ObjIdx = SelectedG7Obj)) and
            (((Cy - MoveCellYOrigin) mod MoveCellYQuantum) = 0);

  // prevent object going above its InBar
  if result and (G7Objects[SelectedG7Obj].BarInIdx >= 0) then begin
    result := (cy >= G7Bars[G7Objects[SelectedG7Obj].BarInIdx].Cy);
  end;

  // prevent object going below its OutBar -> CyMax
  if result and (G7Objects[SelectedG7Obj].BarOutIdx >= 0) then begin
    result := (cy <= G7Bars[G7Objects[SelectedG7Obj].BarOutIdx].CyMax);
  end;

end;



procedure TFormG7.ImageG7MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  BarIdx : integer;
  Cx,Cy,rem,ObjIdx, xi,yiAbove,yiBelow : integer;
  AskRedraw, ValidConnect, ValidDisconnect : boolean;
begin

  SetTemporaryTool(Shift);

{
 //TODO Verificar a validade de X,Y
  if (x < 0) or (y < 0) then begin
    inc(MouseMoveOldCX);
    exit;
    dec(MouseMoveOldCX);
  end;
}

  G7GetObjectAtPix(X,Y, ObjIdx);
  G7PixToCells(X, Y, Cx,Cy);

  if (MouseMoveOldCX=CX) and (MouseMoveOldCY=CY) and
      not(SPConnector.down and (ssLeft in Shift) and (ConStartObjIdx>=0)) then
         exit;

  MouseMoveOldCX:=CX;
  MouseMoveOldCY:=CY;

  AskRedraw:=False;

  if SPEdit.Down or SPStepTransition.Down then begin // Selection Tool
    if ssLeft in Shift then begin
      MoveActive := (SelectedG7Obj<>-1) and not ((Cx = MoveCellXOrigin) and (Cy = MoveCellYOrigin)) and (ssleft in shift);
    end else begin
      MoveActive := false;
      MoveValid  := false;
    end;
  end;

  if MoveActive or ((ObjIdx <> -1) and (ObjIdx = SelectedG7Obj)) then begin

    MoveValid := IsMoveValid(Cx,Cy, ObjIdx);

    if MoveValid then begin
      MoveCellXOffset:= Cx - MoveCellXOrigin;
      MoveCellYOffset:= Cy - MoveCellYOrigin;
      AskRedraw:=True;
    end;
  end;

  // Create S&T + Jump + Comment => Create PHANTOMs
  if not(ssleft in shift) and not(MoveActive) and
        (SPStepTransition.down or SPJump.down or SPComment.down or SPUpLink.down)  then begin

    G7PixToCells(X,Y,Cx,Cy);
    if not G7GetObjectAtPix(x,y, ObjIdx) then begin

      G7Objects[MAXG7Objects].CellX:=cX;
      G7Objects[MAXG7Objects].CellY:=cY;

      rem := cy mod MoveCellYQuantum;

      if SPStepTransition.down then begin
        if rem=0 then begin
          G7Objects[MAXG7Objects].G7Type:=g7oStep;
        end else if rem = 2 then begin
          G7Objects[MAXG7Objects].G7Type:=g7oTransition;
        end else begin
           G7Objects[MAXG7Objects].G7Type:=g7oEmpty;
        end;
      end else

      if SPJump.Down or SPUpLink.down then begin
        if rem=0 then begin
          G7Objects[MAXG7Objects].G7Type:=g7oJumpStart;
        end else if rem = 2 then begin
          G7Objects[MAXG7Objects].G7Type:=g7oJumpFinish;
        end else begin
           G7Objects[MAXG7Objects].G7Type:=g7oEmpty;
        end;
      end else begin // Comment Tool
        if rem=0 then begin
           G7Objects[MAXG7Objects].G7Type:=g7oComment;
        end else begin
           G7Objects[MAXG7Objects].G7Type:=g7oEmpty;
        end;
      end;
      AskRedraw:=True;
      //G7RedrawAll;
    end;

  end else begin  // remove old phantom from screen
    if G7Objects[MAXG7Objects].G7Type<>g7oEmpty then begin
      G7Objects[MAXG7Objects].G7Type:=g7oEmpty;
      AskRedraw:=True;
    end;
  end;

  // Uplinks

  if SPUpLink.down then begin

    UpValid:=((UpStartObj.G7Type<>G7oEmpty) or (UpFinishObj.G7Type<>G7oEmpty));

    if (ssLeft in Shift) and UpValid then begin

      // There is a drag and a valid start or finish point

      if UpStartObj.G7Type<>G7oEmpty then  // Improve the UpValid Concept
        UpValid := (cx=UpStartObj.CellX)
      else
        UpValid := (cx=UpFinishObj.CellX);

      if (UpStartObj.G7Type<>G7oEmpty) and (UpFinishObj.G7Type<>G7oEmpty) then begin
        UpValid := UpValid and ( UpStartObj.CellY > UpFinishObj.CellY );
      end;

      if (not G7GetObjectAtPix(x,y, ObjIdx)) and UpValid then begin

        rem := cy mod MoveCellYQuantum;
        if (rem=0) and (g7finitial in UpFinishObj.flags) then begin
          if ( cy > UpFinishObj.CellY ) then begin
            UpStartObj.G7Type:=g7oJumpStart;
            UpStartObj.CellX := cx;
            UpStartObj.CellY := cy;
          end;
        end else if (rem = 2) and (g7finitial in UpStartObj.flags) then begin
          if ( UpStartObj.CellY > cy ) then begin
            UpFinishObj.G7Type:=g7oJumpFinish;
            UpFinishObj.CellX := cx;
            UpFinishObj.CellY := cy;
          end;
        end else begin
        end;
      end;

      // if there was ever a valid start, then PHANTOM draw it
      if UpStartObj.G7Type<>G7oEmpty then begin
        G7Objects[MAXG7Objects]:=UpStartObj;
      end;

      // if there was ever a valid finish, then PHANTOM draw it
      if UpFinishObj.G7Type<>G7oEmpty then begin
        G7Objects[MAXG7Objects+1]:=UpFinishObj;
      end;

      // se mudou de posição
      //G7RedrawAll;
      //AskRedraw:=True;     // repetido

      // Draw last valid line, if it ever existed
      if (UpStartObj.G7Type<>G7oEmpty) and (UpFinishObj.G7Type<>G7oEmpty) then begin
        if G7Objects[MAXG7Objects].CellY < G7Objects[MAXG7Objects+1].CellY then
          g7DrawLine( MAXG7Objects, MAXG7Objects+1,
                    G7Objects[MAXG7Objects].CellX,   G7Objects[MAXG7Objects].CellY,
                    G7Objects[MAXG7Objects+1].CellX, G7Objects[MAXG7Objects+1].CellY,
                    false, true)
          else
          g7DrawLine( MAXG7Objects+1, MAXG7Objects,
                    G7Objects[MAXG7Objects+1].CellX, G7Objects[MAXG7Objects+1].CellY,
                    G7Objects[MAXG7Objects].CellX,   G7Objects[MAXG7Objects].CellY,
                    false, true);
      end;

      //exit; ////// CAREFULL !!!   ////// CAREFULL !!!  ////// CAREFULL !!!  ////// CAREFULL !!!

    end;
  end;


  Screen.Cursor:=crDefault;
  if SPConnector.down then begin
    if (ssLeft in Shift) and (ConStartObjIdx>=0) then begin    // Prepare draw ELASTIC

      G7RedrawAll;                     // remove last ELASTIC line
                                       // Must be redrawall
      with CurG7Canvas do begin
{
        if ElasticXi > 0 then begin
          pen.Style:=psDot;
          pen.Mode:=pmXor;
          pen.Color := clElastic;
          MoveTo(ElasticXi,ElasticYi); // remove last line with pen in XOR mode
          LineTo(ElasticXf,ElasticYf);
          pen.Style:=psSolid;
          pen.Mode:=pmCopy;
        end;
}
        //--------

        ValidConnect:=false;
        ValidDisconnect:=false;

        if G7GetObjectAtPix(x,y, ObjIdx) and (ConStartObjIdx >= 0)  then begin // Must target obj
          ConFinishObjIdx:=ObjIdx;
          if G7Objects[ConStartObjIdx].CellY < G7Objects[ConFinishObjIdx].CellY then begin // Create Link

            if IsValidCreateLink(ConStartObjIdx,ConFinishObjIdx) then begin

              if (G7Objects[ConStartObjIdx].BarOutIdx = -1) and (G7Objects[ConFinishObjIdx].BarInIdx = -1) then begin  // A new Bar must be created
                ValidConnect:=true;
              end else begin // A existing Bar must be used
                if G7Objects[ConStartObjIdx].BarOutIdx = -1 then begin //New object is above
                  BarIdx := G7Objects[ConFinishObjIdx].BarInIdx;

                  // Verify if the bar is compatible
                  if IsValidAddToLink(ConStartObjIdx,ConFinishObjIdx, BarIdx) then begin
                    ValidConnect:=true;
                  end;

                end else if G7Objects[ConFinishObjIdx].BarInIdx = -1 then begin //New object is bellow
                  BarIdx := G7Objects[ConStartObjIdx].BarOutIdx;

                  // Verify if the bar is compatible
                  if IsCompatibleBar(ConStartObjIdx,ConFinishObjIdx, BarIdx) then begin
                    ValidConnect:=true;
                  end;
                end;
              end;
            end;
          end else begin // Delete Link
            BarIdx := G7Objects[ConStartObjIdx].BarInIdx;
            if (BarIdx <> -1) and (BarIdx = G7Objects[ConFinishObjIdx].BarOutIdx) then begin
              ValidDisConnect:=true;
            end;
          end;
        end;


        //--------

        G7GetDrawPix(ConStartObjIdx,false,xi,yiAbove);
        G7GetDrawPix(ConStartObjIdx,true, xi,yiBelow);

        if ((Y-yiAbove)<0) then begin //  disconnect
          Screen.Cursor:=crG7Disconnect;
          ElasticXi:=xi;
          ElasticYi:=yiAbove;
          if ValidDisconnect then begin
            G7GetDrawPix(ConFinishObjIdx,true, ElasticXf,ElasticYf);
          end else begin
            ElasticXf:=x;
            ElasticYf:=y;
          end;
        end else
        if ((Y-yiBelow)>0) then begin //  Connect
          Screen.Cursor:=crG7Connect;
          ElasticXi:=xi;
          ElasticYi:=yiBelow;
          if ValidConnect then begin
            G7GetDrawPix(ConFinishObjIdx,False, ElasticXf,ElasticYf);
          end else begin
            ElasticXf:=x;
            ElasticYf:=y;
          end;
        end else begin
          ElasticXi:=0;
          ElasticYi:=0;
          ElasticXf:=0;
          ElasticYf:=0;
          Screen.Cursor:=crDefault;
        end;

        if ValidConnect or ValidDisconnect then begin
          //G7RedrawAll;
          //AskRedraw:=True; // repetido
          pen.Width:=3;
          G7DrawObject(ConStartObjIdx);
          G7DrawObject(ConFinishObjIdx);
          pen.Width:=1;
        end;

        pen.Style:=psDot;          // Draw new ELASTIC
        pen.Mode:=pmXor;
        pen.Color := clElastic;
        pen.Color := clSkyBlue;
        CurG7Canvas.MoveTo(ElasticXi,ElasticYi);
        CurG7Canvas.LineTo(ElasticXf,ElasticYf);
        pen.Style:=psSolid;
        pen.Mode:=pmCopy;
      end;
    end;
    AskRedraw:=False;
  end;

  if (AskRedraw) then G7RedrawAll;

  //StatusBarG7.Panels[0].Text := Format('(%d,%d) ObjIdx=%3d ; Move: %d (%d,%d)',[x,y,ObjIdx, ord(MoveActive), MoveCellXOffset, MoveCellYOffset]);
  //StatusBarG7.Panels[0].Text :='zzz';
  //'('+intToStr(x)+','+intToStr(y)+'ObjIdx='+intToStr(ObjIdx)+'; Move:'+intToStr(ord(MoveActive))+' ('+intToStr(MoveCellXOffset)+','+intToStr(MoveCellYOffset)+')';

end;

procedure TFormG7.SetTemporaryTool(const shift : TShiftState);
begin
  //EditDebug.Text:=Format('%d',[TemporaryToolStatus]);

  if (ssLeft in shift) then exit;

  if shift = [] then begin
    if TemporaryToolStatus>0 then begin
      SPEdit.Down           := boolean (TemporaryToolStatus and  1);
      SPStepTransition.Down := boolean((TemporaryToolStatus and  2) shr 1);
      SPConnector.Down      := boolean((TemporaryToolStatus and  4) shr 2);
      SPUpLink.Down         := boolean((TemporaryToolStatus and  8) shr 3);
      SPJump.Down           := boolean((TemporaryToolStatus and 16) shr 4);
      TemporaryToolStatus:=0;
    end;
  end else
  if (ssCtrl in shift) and (TemporaryToolStatus=0)  then begin
    TemporaryToolStatus  :=   ord(SPEdit.Down)+
                             (ord(SPStepTransition.Down) shl 1) +
                             (ord(SPConnector.Down)      shl 2) +
                             (ord(SPUplink.Down)         shl 3) +
                             (ord(SPJump.Down)           shl 4);
    SPConnector.down:=True;
  end;
  G7ShowModeInStatursBar();
end;

function TFormG7.G7ObjIsStepLike(objIdx: integer): boolean;
begin
  result := false;
  if objIdx < 0 then exit;
  result := G7Objects[objIdx].G7Type in [g7oStep, g7oJumpStart];
end;

function TFormG7.G7ObjIsTransitionLike(objIdx: integer): boolean;
begin
  result := false;
  if objIdx < 0 then exit;
  result := G7Objects[objIdx].G7Type in [g7oTransition, g7oJumpFinish];
end;

function TFormG7.IsValidCreateLink(const ConStartObjIdx, ConFinishObjIdx : integer) : boolean;
begin
  result:= ((G7Objects[ConStartObjIdx].G7Type = g7oTransition) and G7ObjIsStepLike(ConFinishObjIdx)) or
           ((G7Objects[ConStartObjIdx].G7Type = g7oStep)       and (G7Objects[ConFinishObjIdx].G7Type = g7oTransition)) or
           ((G7Objects[ConStartObjIdx].G7Type = g7oJumpFinish) and (G7Objects[ConFinishObjIdx].G7Type = g7oStep));
end;

function TFormG7.IsValidAddToLink(const ConStartObjIdx, ConFinishObjIdx, BarIdx : integer) : boolean;
begin
  result:= ((G7Bars[BarIdx].BarType = bthigh) and IsDoubleLine(BarIdx) and G7ObjIsStepLike(ConStartObjIdx)) or
           ((G7Bars[BarIdx].BarType = btLow) and (not IsDoubleLine(BarIdx)) and G7ObjIsTransitionLike(ConStartObjIdx)) or
            (G7Bars[BarIdx].Connections = 2) ;
end;

function TFormG7.IsCompatibleBar(const ConStartObjIdx, ConFinishObjIdx, BarIdx : integer) : boolean;
begin
  result:= ((G7Bars[BarIdx].BarType = bthigh) and (not IsDoubleLine(BarIdx)) and G7ObjIsTransitionLike(ConFinishObjIdx)) or
                 ((G7Bars[BarIdx].BarType = btLow) and IsDoubleLine(BarIdx) and G7ObjIsStepLike(ConFinishObjIdx)) or
                 (G7Bars[BarIdx].Connections = 2)
end;

procedure TFormG7.G7ShowModeInStatursBar;
begin

end;



procedure TFormG7.ImageG7MouseUp(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
var
  ObjIdx, BarIdx : integer;
begin

  if (FMain.ScriptState=ssRunning) Then exit;


  SetTemporaryTool(Shift);

  G7GetObjectAtPix(X,Y, ObjIdx);

  if MoveActive then begin
    DupG7Objects;
    G7Objects[SelectedG7Obj].CellX := G7Objects[SelectedG7Obj].CellX + MoveCellXOffset;
    G7Objects[SelectedG7Obj].CellY := G7Objects[SelectedG7Obj].CellY + MoveCellYOffset;
    G7SelectObject(SelectedG7Obj);
    MoveActive:=false;
  end;

  if SPConnector.Down then begin // Create/Delete Connection Tool
    if G7GetObjectAtPix(x,y, ObjIdx) and (ConStartObjIdx >= 0)  then begin // Must target obj
      ConFinishObjIdx:=ObjIdx;
      if G7Objects[ConStartObjIdx].CellY < G7Objects[ConFinishObjIdx].CellY then begin // Create Link

        if IsValidCreateLink(ConStartObjIdx,ConFinishObjIdx) then begin

          if (G7Objects[ConStartObjIdx].BarOutIdx = -1) and (G7Objects[ConFinishObjIdx].BarInIdx = -1) then begin  // A new Bar must be created
            DupG7Objects;
            BarIdx:=G7GetFreeBar();
            if BarIdx = -1 then exit;
            G7Bars[BarIdx].Connections := 2;
            G7Objects[ConStartObjIdx].BarOutIdx := BarIdx;
            G7Objects[ConFinishObjIdx].BarInIdx := BarIdx;
            inc(G7BarsCount);
          end else begin // A existing Bar must be used
            if G7Objects[ConStartObjIdx].BarOutIdx = -1 then begin //New object is above
              BarIdx := G7Objects[ConFinishObjIdx].BarInIdx;

              // Verify if the bar is compatible
              if IsValidAddToLink(ConStartObjIdx,ConFinishObjIdx, BarIdx) then begin
              end else exit;

            end else if G7Objects[ConFinishObjIdx].BarInIdx = -1 then begin //New object is bellow
              BarIdx := G7Objects[ConStartObjIdx].BarOutIdx;

              // Verify if the bar is compatible
              if IsCompatibleBar(ConStartObjIdx,ConFinishObjIdx, BarIdx) then begin
              end else exit;
            end else exit;

            DupG7Objects;
            inc(G7Bars[BarIdx].Connections);
            G7Objects[ConStartObjIdx].BarOutIdx := BarIdx;
            G7Objects[ConFinishObjIdx].BarInIdx := BarIdx;
          end;
        end;
      end else begin // Delete Link
        BarIdx := G7Objects[ConStartObjIdx].BarInIdx;
        if (BarIdx = -1) or (BarIdx <> G7Objects[ConFinishObjIdx].BarOutIdx) then exit; // there is no connection to be deleted
        DupG7Objects;
        if G7Bars[BarIdx].Connections = 2 then begin  // Delete simple connection
          G7Bars[BarIdx].Connections := 0;
          G7Objects[ConStartObjIdx].BarInIdx := -1;
          G7Objects[ConFinishObjIdx].BarOutIdx := -1;
        end else begin   // Delete multiple connection
          if G7Bars[BarIdx].InCount > 1 then begin
            G7Objects[ConFinishObjIdx].BarOutIdx := -1;
            dec(G7Bars[BarIdx].Connections);
          end;
          if G7Bars[BarIdx].outCount > 1 then begin
            G7Objects[ConStartObjIdx].BarInIdx := -1;
            dec(G7Bars[BarIdx].Connections);
          end;
        end;
      end;
    end;
    ConStartObjIdx := -1;
    ConFinishObjIdx:= -1;
  end;

  // Uplinks

  if SPUpLink.down then begin

    if ((UpStartObj.G7Type<>G7oEmpty) and (UpFinishObj.G7Type<>G7oEmpty)) and
       ( UpStartObj.CellY > UpFinishObj.CellY) and (UpStartObj.CellX = UpFinishObj.CellX )then begin
      DupG7Objects;
      JumpStartCount :=max(JumpStartCount,JumpFinishCount);
      JumpFinishCount:=JumpStartCount;
      with UpStartObj  do G7CreateJumpStart (actPage,CellX,CellY);
      with UpFinishObj do G7CreateJumpFinish(actPage,CellX,CellY);
    end;

    G7Objects[MAXg7objects  ].G7Type:=g7oEmpty;
    G7Objects[MAXg7objects+1].G7Type:=g7oEmpty;

    with G7Objects[MAXg7objects  ] do flags := flags - [g7fInitial];
    with G7Objects[MAXg7objects+1] do flags := flags - [g7fInitial];
  end;

  G7RedrawAll;
  Project.Modified:=true;

  if copy (FMain.SynEditST.Text,1,10)<>'// Grafcet' then
    FMain.SynEditST.Text := '// Grafcet Modified ...' + FMain.SynEditST.Text;

end;

//const
//  crMyCursor = 5;

procedure TFormG7.BDebugClick(Sender: TObject);
begin
  //  Memo1.Lines.add(format('%d,%d [%d]',[G7Objects[0].CellX, G7Objects[0].Celly , ord(MoveActive)]));
  // Screen.Cursor:=(Screen.Cursor+1) mod (crG7Jumps+1);
  // VLEPropEdit.SetFocus;

end;

procedure TFormG7.FormKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
var confirmBool:boolean;
begin

  if (Key = VK_PRIOR) then begin
    TBPage.Position := max(TBPage.Position - 1,TBPage.Min) ;
    key:=0;
  end;
  if (Key = VK_NEXT)  then begin
    TBPage.Position := min(TBPage.Position + 1,TBPage.Max) ;
    key:=0;
  end;

if(not(FMain.ScriptState=ssRunning))then begin
  if SynEditST_G7.Focused then exit;
  if VLEPropEdit.Focused  then exit;
  if key = VK_Shift then SetTemporaryTool(shift);
  if ((key = VK_Delete)and(SelectedG7Obj<>-1)) then begin
    if(CBConfirmDel.Checked) then begin
      confirmBool:=MessageDlg('Really Delete Object?', mtConfirmation, [mbYes, mbNo], 0) = mrYes
    end
    else begin
       confirmBool:=true;
    end;

    if (confirmBool) then begin
      DupG7Objects;
      G7DeleteObj(SelectedG7Obj);
    end;
    G7RedrawAll;
  end;
end;
end;

procedure TFormG7.FormKeyUp(Sender: TObject; var Key: Word;  Shift: TShiftState);
begin
  if key = VK_Control then SetTemporaryTool(shift);
end;

procedure TFormG7.MenuCBResetOutsAtStartCycleClick(Sender: TObject);
begin
end;

procedure TFormG7.MenuedrawAllClick(Sender: TObject);
begin
  G7RedrawAll;
  PairSplitUp.Repaint;
end;


procedure TFormG7.MenuIOsClick(Sender: TObject);
begin
  FIOLEds.show;
end;

procedure TFormG7.MenuItem1Click(Sender: TObject);
begin
  ImageHelpCodeAreaClick(sender);
end;

procedure TFormG7.MenuG7STCompileRunOnceClick(Sender: TObject);
begin
  if not(GenSTCode()) then exit;
  MenuG7STCompileClick(Sender);
  FMain.MenuRunOnceClick(Sender);
  if FMain.LBErrors.Items.Count>0 then begin // Compile Error
    FMain.BringToFront;
    FMain.LBErrors.ItemIndex:=0;
    FMain.LBErrorsClick(nil);
  end;
end;

procedure TFormG7.MenuItem3Click(Sender: TObject);
begin
  FMain.MenuGrafcetViewClick(Sender);
end;

procedure TFormG7.MenuNewLineContinuousClick(Sender: TObject);
begin

end;

procedure TFormG7.MenuRedrawClick(Sender: TObject);
begin
  BRedrawAllClick(Sender);
end;

procedure TFormG7.MenuSelfGradeClick(Sender: TObject);
begin
  FormSelfGrade.Visible:=True;
  FormSelfGrade.BringToFront;
end;

function GetStudentNumbers : string;
var i, CharPos : integer;
begin
  result:='';

  // Search as it should be, comment no cell 0,0
  for i:=0 to MAXG7Objects-1 do begin
    if (G7Objects[i].CellX<>0) OR
       (G7Objects[i].CellY<>0) OR
       (G7Objects[i].G7Type = g7oEmpty) then continue;
    if (G7Objects[i].G7Type = g7oComment) then begin
       result := G7Objects[i].Text;
       break;
    end;
  end;
  if result='' then  begin // Search any comment, return first comment
    for i:=0 to MAXG7Objects-1 do begin
      if (G7Objects[i].G7Type = g7oComment) then begin
         result := G7Objects[i].Text;
         break;
      end;
    end;
  end;

  if UpperCase(copy(Result,1,2))='UP' then result := Copy(result,3,999);
  if Result='' then Result:=Project.Author;
  CharPos:=Pos(',',Result);   // Make sure that result always has a comma (for two students)
  if (CharPos=0) then begin
    CharPos:=Pos(' ',Result);
    if (charpos=0) then begin
      result:=result+' , ';
    end else begin
      result[CharPos]:=',';
    end;
  end;

end;




procedure TFormG7.MenuShowSelfGradeClick(Sender: TObject);
begin
  FormSelfGrade.Visible := True;
  Application.ProcessMessages;
  FormSelfGrade.BringToFront;
  Application.ProcessMessages;
end;

procedure TFormG7.MenuStartQAtPg2Click(Sender: TObject);
begin
  MenuStartQAtPg2.Checked := not MenuStartQAtPg2.Checked;
end;

procedure TFormG7.MenuStartStopGradingClick(Sender: TObject);
begin
  //if FormSelfGrade.MemoSelfGrade.Lines.Count=0 then begin
  //  FormSelfGrade.LoadSelfGradeTxt();
  //  FormSelfGrade.BLdPage3Click(sender);
  //  MenuStartQAtPg2.Checked := true;
  //end;
  //FormSelfGrade.Visible := True;
  //if not FormSelfGrade.CBSelfGradingRunning.Checked then begin
  //  Application.ProcessMessages;
  //  StartGradingGr7();
  //  Application.ProcessMessages;
  //end else begin
  //  Application.ProcessMessages();
  //  FormSelfGrade.BEndedGradingClick(Sender);
  //  Application.ProcessMessages();
  //  FormSelfGrade.BringToFront();
  //  Application.ProcessMessages();
  //end;
end;

procedure TFormG7.MenuVarsClick(Sender: TObject);
begin
  FVariables.show;
end;

procedure TFormG7.PairSplitUpMouseEnter(Sender: TObject);
begin
  PairSplitUp.Repaint;
end;

procedure TFormG7.PairSplitUpResize(Sender: TObject);
begin
  PairSplitUp.Repaint;
end;

procedure TFormG7.SynEditST_G7MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  ScreenCoord: TPoint;
  tmp: string;
begin
  ScreenCoord := SynEditST_G7.PixelsToRowColumn(Point(X,Y));
  tmp    := SynEditST_G7.GetWordAtRowCol(ScreenCoord);
  //FMain.LabelInspect.Caption := tmp;
  //FMain.LabelInspect.visible := True;
  FMain.StatusVarName  := tmp;
  FMain.UpdateStatusVar();
end;



procedure TFormG7.TBFontCodeEditorChange(Sender: TObject);
begin
  SynEditST_G7.Font.Size := 10 + TBFontCodeEditor.Position;
end;


// returns an index
function TFormG7.G7GetIdxFromName(theLabel: String; TheG7Type: TG7Type): integer;
var i, cnt: integer;
begin
  result := -1;
  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
    //if cnt >= G7ObjectsCount then break;
    //if G7Objects[i].G7Type = g7oEmpty then continue;
    if G7Objects[i].G7Type <> TheG7Type then continue;
    if UpperCase(G7Objects[i].Name) = UpperCase(theLabel) then begin
      result := i;
      exit;
    end;
    inc(cnt);
  end;
end;


function TFormG7.FindG7Name(theName: String; TheG7Type: TG7Type): integer;
var i, cnt: integer;
begin
  result := -1;
  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
    if cnt >= G7ObjectsCount then break;
    //if G7Objects[i].G7Type = g7oEmpty then continue;
    if G7Objects[i].G7Type <> TheG7Type then continue;
    if UpperCase(G7Objects[i].Name) = UpperCase(theName) then begin
      result := i;
      exit;
    end;
    inc(cnt);
  end;
end;


procedure TFormG7.DupG7Objects;
var i, cnt: integer;
begin
////  cnt := 0;                            //// Horripilantis bug
  for i:=0 to MAXG7Objects-1 do begin
////    if cnt > G7ObjectsCount then break;
    //if G7Objects[i].G7Type = g7oEmpty then continue;
    G7ObjectsDup[i] := G7Objects[i];

////    inc(cnt);
  end;
  G7ObjectsCountDup := G7ObjectsCount;

//  SelectedG7ObjDup := SelectedG7Obj;
//  SelectedG7ObjCountDup := SelectedG7ObjCount;

  G7BarsCountDup := G7BarsCount;

  MenuUndo.Enabled := true;
end;


procedure TFormG7.G7UndoDupG7Objects;
var i, cnt: integer;
begin
////  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
////    if cnt > G7ObjectsCount then break;             Horripilantis Bug
    //if G7Objects[i].G7Type = g7oEmpty then continue;
    G7Objects[i] := G7ObjectsDup[i];

////    inc(cnt);
  end;

  G7ObjectsCount := G7ObjectsCountDup;

  G7BarsCount := G7BarsCountDup;

  MenuUndo.Enabled := false;

  SelectedG7Obj := -1;
  SelectedG7ObjCount := 0;
end;


////procedure TFormG7.VLEPropEditEditButtonClick(Sender: TObject);
////var Key, value: string;
//////    b: boolean;
////begin
////  if SelectedG7Obj < 0 then exit;
////  Key   := VLEPropEdit.Cells[0,VLEPropEdit.Row];
////  value := VLEPropEdit.Cells[1,VLEPropEdit.Row];
////
////  if (Key='Condition') or (Key='Code') then begin
////    if FG7Editor.ShowModal = mrOK then begin
////      G7Objects[SelectedG7Obj].code := FG7Editor.SynEdit.Text;
////      VLEPropEdit.Cells[1,VLEPropEdit.Row] := G7Objects[SelectedG7Obj].code;
////      G7RedrawAll;
////    end;
////  end;
////end;

procedure TFormG7.G7ShowModeInStatusBar();
begin

  with StatusBarG7.Panels[1] do

  if SPEdit.Down           then Text:='Edit'
  else
  if SPStepTransition.Down then Text:='Create Step / Transition'
  else
  if SPConnector.Down      then Text:='Connect / Disconnect'
  else
  if SPUpLink.Down         then Text:='UpLink'
  else
  if SPJump.Down           then Text:='Jump';

  if not CBCursors.Checked then begin
    ImageG7.Cursor:=crDefault;
    exit;
  end;

end;


procedure TFormG7.SPModesClick(Sender: TObject);
begin
  G7ShowModeInStatursBar();
end;


function TFormG7.G7InsertRow(const TheRow : integer =-1) : boolean;
var
  cnt,i,ln : integer;
  s : string;
begin

  result:=False;

  if TheRow=-1 then begin // if no params then go interactive
    s:='0';
    if InputQuery('', 'Insert before Row number ?', s) then exit;
    Ln:=StrToIntDef(s,-1);
    if Ln < 0 then exit;
  end else Ln:=TheRow;

  // ToDo: Previously check that objects do not go over maxYY
  result:=True;
  DupG7Objects;


  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
    if cnt >= G7ObjectsCount then break;
    if (G7Objects[i].G7Type <> g7oEmpty) and (G7Objects[i].CellY >= Ln) and (actPage=G7Objects[i].Page) then begin
      inc(G7Objects[i].CellY,4);
    end;
    inc(cnt);
  end;
  G7RedrawAll;
end;


function TFormG7.G7ClearRow(const TheRow : integer =-1) : boolean;
var
  cnt,i,ln : integer;
  s : string;
begin

  result:=False;

  if TheRow=-1 then begin // if no params then go interactive
    s:='0';
    if not InputQuery('', 'Delete Row Number ?', s) then exit;
    Ln:=StrToIntDef(s,-1);
    if Ln < 0 then exit;
  end else Ln:=TheRow;

  result:=True;
  DupG7Objects;

////  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
////    if cnt >= G7ObjectsCount then break;
    if (G7Objects[i].G7Type <> g7oEmpty) and (G7Objects[i].CellY = Ln) and (actPage=G7Objects[i].Page) then begin
      G7DeleteObj(i);
////      dec(cnt);
    end;
////    inc(cnt);
  end;
  // G7ShiftRow(Ln); // causa duplo DupG7Objects => fica sem undo
  G7RedrawAll;

end;

function TFormG7.G7ClearCol(const TheCol : integer =-1; const ThePage : integer =-1) : boolean;
var
  cnt,i,ColToDel, PageToDel : integer;
  s : string;
begin

  result:=False;

  if TheCol=-1 then begin // if no params then go interactive
    s:='0';
    if not InputQuery('', 'Delete Col Number ?', s) then exit;
    ColToDel:=StrToIntDef(s,-1);
    if ColToDel < 0 then exit;
  end else ColToDel:=TheCol;

  if ThePage=-1 then begin // if no params then go interactive
    s:='0';
    if InputQuery('', 'Of Page Number ?', s) then exit;
    PageToDel:=StrToIntDef(s,-1);
    if ThePage < 0 then exit;
  end else PageToDel:=ThePage;

  result:=True;
  DupG7Objects;

////  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
////    if cnt > G7ObjectsCount then break;
    if (G7Objects[i].G7Type <> g7oEmpty) and
       (G7Objects[i].CellX = ColToDel)   and
       (G7Objects[i].Page  = PageToDel) then begin
      G7DeleteObj(i);
////      dec(cnt);
    end;
////    inc(cnt);
  end;
  //G7ShiftCol(ColToDel); // causa duplo DupG7Objects => fica sem undo
  G7RedrawAll;

end;


function TFormG7.G7ShiftRow(const TheRow : integer =-1) : boolean;
var
  cnt,i,ln, dummy : integer;
  s : string;
begin

  result:=False;

  if TheRow=-1 then begin // if no params then go interactive
    s:='0';
    if InputQuery('', 'Insert before Row number ?', s) then exit;
    Ln:=StrToIntDef(s,-1);
    if Ln < 0 then exit;
  end else Ln:=TheRow;

  // Check that objects do not overlap and do not cause up flow (Bar.Cy and Bar.MaxCy)
  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
    if cnt >= G7ObjectsCount then break;
    if (G7Objects[i].G7Type <> g7oEmpty) and (G7Objects[i].CellY>ln) and (actPage=G7Objects[i].Page) then begin
      if (G7Objects[i].CellY<4) then begin
        ShowMessage('Unable to delete Line' + crlf + 'Object '+G7Objects[i].Name+' would be out of screen');
        exit;
      end;
      if (G7Objects[i].CellY > Ln) and ((G7Objects[i].CellY < (Ln+5))) then begin
        if G7GetObjectAtCell(G7Objects[i].CellX,G7Objects[i].CellY-4,dummy) then begin
          ShowMessage('Unable to delete Line' + crlf + 'Object '+G7Objects[i].Name+' is not adjacent to free cell');
          exit;
        end;
      end;
      if (G7Objects[i].BarInIdx<>-1) then begin
        if G7GetObjectAtCell(G7Bars[G7Objects[i].BarInIdx].Cy,Ln,dummy) then begin
          ShowMessage('Unable to delete Line' + crlf + 'Object '+G7Objects[i].Name+' Would be higher then incomming objects');
          exit;
        end;
      end;
    end;
    inc(cnt);
  end;

  result:=True;

  DupG7Objects;

  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
    if cnt >= G7ObjectsCount then break;
    if (G7Objects[i].G7Type <> g7oEmpty) and (G7Objects[i].CellY > Ln) and (actPage=G7Objects[i].Page) then begin
      G7Objects[i].CellY:=max(0,G7Objects[i].CellY-4);
    end;
    inc(cnt);
  end;
  G7RedrawAll;
end;



function TFormG7.G7InsertCol(const TheCol : integer =-1) : boolean;
var
  cnt,i,col : integer;
  s : string;
begin

  result:=False;

  if TheCol=-1 then begin // if no params then go interactive
    s:='0';
    if InputQuery('', 'Insert before Row number ?', s) then exit;
    col:=StrToIntDef(s,-1);
    if col < 0 then exit;
  end else col:=TheCol;

  // ToDo: Previously check that objects do not go over maxYY
  result:=True;
  DupG7Objects;


  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
    if cnt >= G7ObjectsCount then break;
    if (G7Objects[i].G7Type <> g7oEmpty) and (G7Objects[i].CellX >= col) and (actPage=G7Objects[i].Page) then begin
      inc(G7Objects[i].CellX);
    end;
    inc(cnt);
  end;
  G7RedrawAll;
end;


function TFormG7.G7ShiftCol(const TheCol : integer =-1) : boolean;
var
  cnt,i,col, dummy : integer;
  s : string;
begin

  result:=False;

  if TheCol=-1 then begin // if no params then go interactive
    s:='0';
    if InputQuery('', 'Insert before Row number ?', s) then exit;
    col:=StrToIntDef(s,-1);
    if col < 0 then exit;
  end else col:=TheCol;

  // Check that objects do not overlap
  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
    if cnt >= G7ObjectsCount then break;
    if (G7Objects[i].G7Type <> g7oEmpty) and (G7Objects[i].CellX = (col+1)) and (actPage=G7Objects[i].Page) then begin
      if G7GetObjectAtCell(col,G7Objects[i].CellY,dummy) then begin
        ShowMessage('Unable to delete Column' + crlf + 'Object '+G7Objects[i].Name+' is not adjacent to free cell');
        exit;
      end;
    end;
    inc(cnt);
  end;

  result:=True;
  DupG7Objects;

  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
    if cnt >= G7ObjectsCount then break;
    if (G7Objects[i].G7Type <> g7oEmpty) and (G7Objects[i].CellX > col) and (actPage=G7Objects[i].Page) then begin
      G7Objects[i].CellX := max(0,G7Objects[i].CellX-1);
    end;
    inc(cnt);
  end;
  G7RedrawAll;
end;


procedure TFormG7.MenuUndoClick(Sender: TObject);
begin
  G7UndoDupG7Objects;
  G7RedrawAll;
end;

procedure TFormG7.TBStepHeightChange(Sender: TObject);
begin
  StepSizeY  := TBStepHeight.Position;

  TrSizeY := 3 + ord(TBStepHeight.Position>9) +  // 3 this is the original TrSizeY size... it should be a var!!!
                 ord(TBStepHeight.Position>15);  // 3 this is the original TrSizeY size... it should be a var!!!

  FormG7.CalculateRectangles();
  FormG7.CalculateDependents();

  SequenceYY[0] := StepSizeY;
  SequenceYY[1] := BarSizeY;
  SequenceYY[2] := TrSizeY;
  SequenceYY[3] := BarSizeY;

  ThresholdsYY[0]:=StepSizeY;
  ThresholdsYY[1]:=StepSizeY + BarSizeY;
  ThresholdsYY[2]:=StepSizeY + BarSizeY + TrSizeY;
  ThresholdsYY[3]:=StepSizeY + BarSizeY + TrSizeY + BarSizeY;

  G7RedrawAll();
end;

procedure TFormG7.Timer1Timer(Sender: TObject);
begin
  G7RedrawAll();
end;

procedure TFormG7.VLEPropEditValidateAndSet(ObjIdx: Integer; const KeyName, KeyValue: String);
var Key, value: string;
    b: boolean;
    idx: integer;
begin
  if ObjIdx < 0 then exit;
  Key := VLEPropEdit.Cells[0,VLEPropEdit.Row];
  value := VLEPropEdit.Cells[1,VLEPropEdit.Row];

  //EditDebug.Text := VLEPropEdit.Cells[1,VLEPropEdit.Row];

  if Key = 'Name' then begin
    //G7Objects[ObjIdx].Number := strtointdef(Value, G7Objects[ObjIdx].Number);
    if IsValidIdent(Value) then begin
      idx := FindG7Name(value, G7Objects[ObjIdx].G7Type);
      if (idx < 0) or (idx = ObjIdx) then begin
        G7Objects[ObjIdx].Name := Value;
      end else begin
        ShowMessage('Already in use:'+Value);
        VLEPropEdit.RestoreCurrentRow;
      end;
    end else begin
      ShowMessage('Invalid identifier:'+Value);
      VLEPropEdit.RestoreCurrentRow;
    end;
    G7RedrawAll;
  end;


  if Key='Comment' then begin
    G7Objects[ObjIdx].text := Value;
    G7RedrawAll;
  end;

  if Key = 'Initial' then begin
    b := strTobooldef(value, g7fInitial in G7Objects[ObjIdx].flags);
    if b then begin
      G7Objects[ObjIdx].flags := G7Objects[ObjIdx].flags + [g7fInitial];
    end else begin
      G7Objects[ObjIdx].flags := G7Objects[ObjIdx].flags - [g7fInitial];
    end;
    G7RedrawAll;
  end;

  if Key = 'DrawConnection' then begin
    b := strTobooldef(value, g7fLinkVisible in G7Objects[ObjIdx].flags);
    if b then begin
      G7Objects[ObjIdx].flags := G7Objects[ObjIdx].flags + [g7fLinkVisible];
    end else begin
      G7Objects[ObjIdx].flags := G7Objects[ObjIdx].flags - [g7fLinkVisible];
    end;
    G7RedrawAll;
  end;

  if key ='Label' then begin
    // Verify if the label is valid
    idx := G7GetIdXFromName(value, G7Objects[ObjIdx].G7Type);
    if IsValidIdent(value) then begin
      if (idx < 0) or (idx = ObjIdx) then begin
        G7Objects[ObjIdx].Name := value;
      end else begin
        ShowMessage('Already in use:'+Value);
        VLEPropEdit.RestoreCurrentRow;
      end;
    end else begin
      ShowMessage('Invalid identifier:'+Value);
      VLEPropEdit.RestoreCurrentRow;
    end;
    G7RedrawAll;
  end;


end;


procedure TFormG7.VLEPropEditValidate(Sender: TObject; ACol, ARow: Integer;  const KeyName, KeyValue: String);
begin
  if SelectedG7Obj < 0 then exit;
  VLEPropEditValidateAndSet(SelectedG7Obj,KeyName, KeyValue);
end;




procedure TFormG7.VLEPropEditKeyPress(Sender: TObject; var Key: Char);
var KeyName, value: string;
begin
  if SelectedG7Obj < 0 then exit;
  if key = Chr(13) then begin
    KeyName := VLEPropEdit.Cells[0,VLEPropEdit.Row];
    value := VLEPropEdit.Cells[1,VLEPropEdit.Row];
    VLEPropEditValidate(Sender, VLEPropEdit.Col, VLEPropEdit.Row, KeyName, Value);
  end;

end;

procedure TFormG7.BInsertRowClick(Sender: TObject);
begin
  G7InsertRow();
end;

procedure TFormG7.BInsertColClick(Sender: TObject);
begin
  G7InsertCol();
end;



procedure TFormG7.PopMenuInsertRowClick(Sender: TObject);
var
  cx, cy : integer;
begin
  G7PixToCells(MouseDownX,MouseDownY,cx,cy);
  G7InsertRow(cy);
end;

procedure TFormG7.PopMenuShiftRowClick(Sender: TObject);
var
  cx, cy : integer;
begin
  G7PixToCells(MouseDownX,MouseDownY,cx,cy);
  G7ShiftRow(cy);
end;

procedure TFormG7.PopMenuInsertColClick(Sender: TObject);
var
  cx, cy : integer;
begin
  G7PixToCells(MouseDownX,MouseDownY,cx,cy);
  G7InsertCol(cx);
end;



procedure TFormG7.PopMenuShiftColClick(Sender: TObject);
var
  cx, cy : integer;
begin
  G7PixToCells(MouseDownX,MouseDownY,cx,cy);
  G7ShiftCol(cx);
end;


procedure TFormG7.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
 if WheelDelta<0 then
   MenuZoomOutClick(Sender)
 else
   MenuZoomInClick(Sender);
end;


procedure TFormG7.MenuZoomClick(Sender: TObject);
begin
  G7SetZoomPercent((Sender as TMenuItem).tag);
  G7RedrawAll;
end;

function TFormG7.G7GetZoomPercent : integer;
begin
  result := round(g7Zoom*100);
end;

procedure TFormG7.G7SetZoomPercent(const WantZoom : integer);
begin
  g7Zoom:=WantZoom/100;

  if g7Zoom>1.2 then
    FontZoom:=1
  else
  if g7Zoom<0.8 then
    FontZoom:=-1
  else
    FontZoom:=0;

  case WantZoom of
    200 : MenuZoom200.Checked := true;
    100 : MenuZoom100.Checked := true;
    50  : MenuZoom50.Checked  := true;
    33  : MenuZoom33.Checked  := true;
    25  : MenuZoom25.Checked  := true;
    10  : MenuZoom20.Checked  := true;
    else begin
      MenuZoom200.Checked := false;
      MenuZoom100.Checked := false;
      MenuZoom50.Checked  := false;
      MenuZoom33.Checked  := false;
      MenuZoom25.Checked  := false;
      MenuZoom20.Checked  := false;
    end;
  end;

  if WantZoom=0.66 then g7Zoom:=2/3;
  if WantZoom=0.33 then g7Zoom:=1/3;

  TBZoom.Position:=round(g7Zoom*100);

  ImageG7.Width  := round( FullXPix * G7Zoom );
  ImageG7.Height := round( FullYPix * G7Zoom );

end;


procedure TFormG7.MenuZoomInClick(Sender: TObject);
begin
  case G7GetZoomPercent() of
    200 : ;
    100 : G7SetZoomPercent(200);
    50  : G7SetZoomPercent(100);
    33  : G7SetZoomPercent(50);
    25  : G7SetZoomPercent(33);
    20  : G7SetZoomPercent(25);
  end;
  G7RedrawAll;
end;



procedure TFormG7.MenuZoomOutClick(Sender: TObject);
begin
  case G7GetZoomPercent() of
    200 : G7SetZoomPercent(100);
    100 : G7SetZoomPercent(50);
    50  : G7SetZoomPercent(33);
    33  : G7SetZoomPercent(25);
    25  : G7SetZoomPercent(20);
    20  : ;
  end;
  G7RedrawAll;
end;



procedure TFormG7.TBZoomChange(Sender: TObject);
begin
  G7SetZoomPercent(TBZoom.Position);
//  FlickerMode(True);
  G7RedrawAll();
//  Repaint;
//  FlickerMode(False);
end;

procedure TFormG7.MenuExitClick(Sender: TObject);
begin
  FormG7.Close;
  FMain.Close;
end;

(*
procedure TFormG7.MenuLoadClick(Sender: TObject);
begin
  ShowMessage('Open only the Grafcet part of the project');
  OpenDialog.FileName:=ChangeFileExt(Project.FileName, '.G7.xml');
  if not OpenDialog.Execute then exit;
  if (not G7LoadXML(OpenDialog.FileName,true,nil)) then begin
     ShowMessage('Error loading only Grafcet file');
  end;

end;

procedure TFormG7.MenuSaveASClick(Sender: TObject);
begin
  ShowMessage('Save only the Grafcet part of the project');
  SaveDialog.FileName:=ChangeFileExt(Project.FileName, '.G7.xml');
  if (not SaveDialog.execute) then exit;
  G7SaveXML(SaveDialog.FileName, true, nil);
end;
*)

procedure TFormG7.MenuPrintClick(Sender: TObject);
begin
 if not PrintDialog1.Execute then exit;

 g7print; //faz isto se executar
end;


procedure TFormG7.MenuNewClick(Sender: TObject);
begin
 FMain.MenuNewClick(Self);
end;


procedure TFormG7.FormInit;
begin
  G7Clear;
  G7RedrawAll;
end;


procedure TFormG7.MenuSaveClick(Sender: TObject);
begin
  G7SaveXML(ChangeFileExt(Project.FileName, '.G7.xml'), true, nil);
end;

procedure TFormG7.MenuDeleteClick(Sender: TObject);
begin
  DupG7Objects;
  G7DeleteObj(SelectedG7Obj);
  G7SelectObject(-1);
  G7RedrawAll;
end;

procedure TFormG7.CBRoundStatesClick(Sender: TObject);
begin
  G7RedrawAll;
end;

procedure TFormG7.CBEliminateNewLineClick(Sender: TObject);
begin
  G7RedrawAll;
end;


procedure TFormG7.MenuProjectEditClick(Sender: TObject);
begin
//  if (Sender as TForm).Name =  ;
//  FG7Project.Close;
  FG7Project.Show;
end;

procedure TFormG7.TBPageChange(Sender: TObject);
begin
  actPage:=TBPage.Position;
  G7RedrawAll;
  G7SelectObject(-1);
end;


procedure TFormG7.CBShowCodeClick(Sender: TObject);
begin
  if not CBShowCode.Checked then
    SizeX:=8
  else
    SizeX:=24;
  CalculateRectangles;
  CalculateDependents;
  G7RedrawAll;
end;



procedure TFormG7.CalculateRectangles;
begin
  with StepOuterRect   do begin Left:=0           ; Top:=0 ; Right:=StepSizeX   ; Bottom:=StepSizeY ; OffX:=0; OffY:=0; end;
  with StepInnerRect   do begin Left:=0           ; Top:=0 ; Right:=StepSizeX   ; Bottom:=StepSizeY ; OffX:=2; OffY:=2; end;
  with StepRect_1      do begin Left:=StepSizeX   ; Top:=1 ; Right:=StepSizeX+1 ; Bottom:=2         ; OffX:=1; OffY:=1; end;
  with StepRect_2      do begin Left:=StepSizeX   ; Top:=3 ; Right:=StepSizeX+1 ; Bottom:=4         ; OffX:=1; OffY:=1; end;
  with StepRect_3      do begin Left:=StepSizeX   ; Top:=5 ; Right:=StepSizeX+1 ; Bottom:=6         ; OffX:=1; OffY:=1; end;
  with StepLeftHalf    do begin Left:= 0          ; Top:=0 ; Right:=StepSizeX   ; Bottom:=StepSizeY ; OffX:=0; OffY:=0; end;
  with StepRightHalf   do begin Left:=StepSizeX+1 ; Top:=0 ; Right:=SizeX       ; Bottom:=StepSizeY ; OffX:=0; OffY:=0; end;

  with TrRect          do begin Left:=2           ; Top:=1 ; Right:=2+TrSizeX   ; Bottom:=2         ; OffX:=0; OffY:=0; end;
  with TrRect_1        do begin Left:=2+TrSizeX   ; Top:=1 ; Right:=2+TrSizeX+1 ; Bottom:=2         ; OffX:=1; OffY:=1; end;
  with TrLeftHalf      do begin Left:=0           ; Top:=0 ; Right:=2+TrSizeX   ; Bottom:=TrSizeY   ; OffX:=0; OffY:=0; end;
  with TrRightHalf     do begin Left:=2+TrSizeX+1 ; Top:=0 ; Right:=SizeX       ; Bottom:=TrSizeY   ; OffX:=0; OffY:=0; end;

  with BarRect         do begin Left:=0           ; Top:=0 ; Right:=StepSizeX   ; Bottom:=BarSizeY  ; OffX:=1; OffY:=1; end;

  with JumpStartRect   do begin Left:=2           ; Top:=2 ; Right:=StepSizeX-2 ; Bottom:=StepSizeY-2;OffX:=0; OffY:=0; end; // StepLike
  with JumpFinishRect  do begin Left:=2           ; Top:=1 ; Right:=2+TrSizeX   ; Bottom:=2         ; OffX:=0; OffY:=1; end; // Tr Like

  with JumpStartLeftHalf  do begin Left:=0        ; Top:=0 ; Right:=StepSizeX   ; Bottom:=StepSizeY  ; OffX:=0; OffY:=0; end; // Like StepLeftHalf
  with JumpFinishLeftHalf do begin Left:=0        ; Top:=0 ; Right:=2+TrSizeX   ; Bottom:=TrSizeY    ; OffX:=0; OffY:=0; end; // Like TrLeftHalf

  with CommentRect        do begin Left:=0        ; Top:=0 ; Right:=SizeX       ; Bottom:=StepSizeY ; OffX:=1; OffY:=1; end; // StepLike
  with InnerCommentRect   do begin Left:=0        ; Top:=0 ; Right:=SizeX       ; Bottom:=StepSizeY ; OffX:=3; OffY:=3; end; // StepLike
end;

procedure TFormG7.CalculateDependents;
begin
  CellWidth := (SizeX * SubCellWidth);
  BlockHeight := (StepSizeY + TrSizeY + BarSizeY*2);
  BlockHeightPix := (StepSizeY + TrSizeY + BarSizeY*2)*SubCellHeight;

  FullX := (MaxCellsX * SizeX) ;
  FullY := (MaxCellsY * (StepSizeY + TrSizeY + BarSizeY + BarSizeY) div 4);
  FullXPix := (FullX * SubCellWidth);
  FullYPix := (FullY * SubCellHeight);
end;


procedure TFormG7.PopMenuClearRowClick(Sender: TObject);
var
  cx, cy : integer;
begin
  G7PixToCells(MouseDownX,MouseDownY,cx,cy);
  G7ClearRow(cy);
end;

procedure TFormG7.PopupMenuClearColClick(Sender: TObject);
var
  cx, cy : integer;
begin
  G7PixToCells(MouseDownX,MouseDownY,cx,cy);
  G7ClearCol(cx, actPage);
end;

procedure TFormG7.PopMenuDeleteClick(Sender: TObject);
var
  cx, cy, idx : integer;
begin
  G7PixToCells(MouseDownX,MouseDownY,cx,cy);
  G7GetObjectAtCell(cx,cy,idx);
  if idx>=0 then begin
    DupG7Objects;
    G7DeleteObj(idx);
    G7RedrawAll;
  end;
end;

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//                          Compilation stuff
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


const
  MAXCompiledStepsToSameTr = 10;
type
  TCompiledTr = record
    Above, Below : Array [0..MAXCompiledStepsToSameTr-1] of integer;
    AboveCount, BelowCount : integer;
    Valid : boolean;
  end;
  TCompiledG7 = array [0..MAXG7Objects-1] of TCompiledTr;


procedure ShowMessageOrLog(TheText : string);
begin
  if FormSelfGrade.CBSelfGradingRunning.Checked then begin
    FormSelfGrade.Log(TheText);
  end else begin
    ShowMessage(TheText);
  end;
end;

procedure FindStepsofTr(const TrIdx : integer; var OutTr : TCompiledTr);
var
  i,j, cnt1, cnt2, BarAbove, BarBelow, BarTemp : integer;
begin

  BarAbove := G7Objects[TrIdx].BarInIdx;
  BarBelow := G7Objects[TrIdx].BarOutIdx;

  cnt1 := 0;
  for i:=0 to MAXG7Objects-1 do begin
    if cnt1 >= G7ObjectsCount then break;
    if G7Objects[i].G7Type = g7oEmpty then continue;
    inc(cnt1);
    if (G7Objects[i].G7Type = g7oStep) then begin
      if (G7Objects[i].BarInIdx  = BarBelow) and (BarBelow>=0) then begin //add Below
        OutTr.Below[OutTr.BelowCount]:=i;                  // ERROR TO CORRECT!?!!!!!!!!!!!!
        if OutTr.BelowCount < high(OutTr.Below) then
          inc(OutTr.BelowCount)
        else
          ShowMessageOrLog('Too Many Steps Coming Out of Transition:'+G7Objects[TrIdx].Name+ ' Page:'+IntToStr(G7Objects[TrIdx].Page));
      end;
      if (G7Objects[i].BarOutIdx = BarAbove) and (BarAbove>=0) then begin //add Above
        OutTr.Above[OutTr.AboveCount]:=i;
        if OutTr.AboveCount < high(OutTr.Below) then
          inc(OutTr.AboveCount)
        else
          ShowMessageOrLog('Too Many Steps Into Transition:'+G7Objects[TrIdx].Name+ ' Page:'+IntToStr(G7Objects[TrIdx].Page));
      end;
    end {if step} else
    if G7Objects[i].G7Type = g7oJumpStart then begin
      if G7Objects[i].BarInIdx  = BarBelow then begin //add Below all steps below jumpfinish
        if G7Objects[i].JumpIdx<0 then begin
          ShowMessageOrLog('Unconnected Start Jump:'+G7Objects[i].Name+ ' Page:'+IntToStr(G7Objects[TrIdx].Page));
          continue;
        end;
        BarTemp:=G7Objects[G7Objects[i].JumpIdx].BarOutIdx;
        if BarTemp<0 then continue;
        cnt2 := 0;
        for j:=0 to MAXG7Objects-1 do begin
          if cnt2 >= G7ObjectsCount then break;
          if G7Objects[j].G7Type = g7oEmpty then continue;
          inc(cnt2);
          if   (G7Objects[j].G7Type = g7oStep) and
               (G7Objects[j].BarInIdx = BarTemp) then begin //add Below
            OutTr.Below[OutTr.BelowCount]:=j;
            if OutTr.BelowCount < high(OutTr.Below) then
              inc(OutTr.BelowCount)
            else
              ShowMessageOrLog('Too Many Steps Coming Out of Transition:'+G7Objects[TrIdx].Name+ ' Page:'+IntToStr(G7Objects[TrIdx].Page));
          end;
        end;
      end;
    end {if JumpStart} else
    if G7Objects[i].G7Type = g7oJumpFinish then begin
      if G7Objects[i].BarOutIdx  = BarAbove then begin //add Above all steps leading to JumpStart
        if G7Objects[i].JumpIdx<0 then begin
          ShowMessageOrLog('Unconnected Finish Jump:'+G7Objects[i].Name+ ' Page:'+IntToStr(G7Objects[TrIdx].Page));
          continue;
        end;
        BarTemp:=G7Objects[G7Objects[i].JumpIdx].BarInIdx;
        if BarTemp<0 then continue;
        cnt2 := 0;
        for j:=0 to MAXG7Objects-1 do begin
          if cnt2 >= G7ObjectsCount then break;
          if G7Objects[j].G7Type = g7oEmpty then continue;
          inc(cnt2);
          if   (G7Objects[j].G7Type = g7oStep) and
               (G7Objects[j].BarOutIdx  = BarTemp) then begin //add Below
            OutTr.Above[OutTr.BelowCount]:=j;
            if OutTr.AboveCount < high(OutTr.Above) then
              inc(OutTr.AboveCount)
            else
              ShowMessageOrLog('Too Many Steps Into Transition:'+G7Objects[TrIdx].Name+ ' Page:'+IntToStr(G7Objects[TrIdx].Page));
          end;
        end;
      end;
    end; {if JumpFinish}
  end;
end;

function G7Compile() : TCompiledG7;
var
  i,j,cnt : integer;
  s:string;
begin

  ZeroMemory(@result,sizeof(result));

  SetLength(VarSearchTable,0); // Clear ST2pas var number optimization Table

  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
    if cnt >= G7ObjectsCount then break;
    if G7Objects[i].G7Type = g7oEmpty then continue;
    if G7Objects[i].G7Type = g7oTransition then begin
      FindStepsofTr(i,Result[i]);
      Result[i].Valid:=True;
    end;
    inc(cnt);
  end;

// Print for debug purposes
  cnt := 0;
  for i:=0 to MAXG7Objects-1 do begin
    if cnt >= G7ObjectsCount then break;
    if G7Objects[i].G7Type = g7oEmpty then continue;
    if G7Objects[i].G7Type = g7oTransition then begin
      FormG7.Memo1.Lines.Append(Format('ObjIdx=%d=>Tr"%s"',[i,G7Objects[i].name]));
      s:='  Above: ';
      for j:=0 to result[i].AboveCount-1 do s:=s+G7Objects[result[i].Above[j]].Name+'; ';
      FormG7.Memo1.Lines.Append(s);
      s:='  Below: ';
      for j:=0 to result[i].BelowCount-1 do s:=s+G7Objects[result[i].Below[j]].Name+'; ';
      FormG7.Memo1.Lines.Append(s);
    end;
    inc(cnt);
  end;



end;


procedure TFormG7.BCompileClick(Sender: TObject);
begin
  G7Compile;
end;

procedure TFormG7.BDebugActivateRandomClick(Sender: TObject);
begin
  if random(2)=1 then
    G7Objects[random(20)].flags := G7Objects[random(20)].flags + [g7fActive]
  else
    G7Objects[random(20)].flags := G7Objects[random(20)].flags - [g7fActive];
  G7RedrawAll;
end;

procedure TFormG7.BDumpObjsClick(Sender: TObject);
var
  i, cnt : integer;
  SL : TStrings;
  s : string;
begin

  SL:=Memo1.Lines;

  cnt := 0;
  SL.Add(format('------------%d ',[G7ObjectsCount]));
  for i:=0 to MAXG7Objects-1 do begin
    with G7Objects[i] do begin
      if G7Objects[i].G7Type=g7oempty then continue;
      if cnt >= G7ObjectsCount then break;
      SL.Add(format('Obj N%2d -> %s -> %s',[i,Name,G7TypeNames[G7Type]]));
      SL.Add(format('  Cell=(%d,%d)',[G7Objects[i].CellX,G7Objects[i].CellY]));
      SL.Add(format('  BarInIdx=%d ; BarOutIdx=%d',[G7Objects[i].BarInIdx,G7Objects[i].BarOutIdx]));
//      SL.Add(format('  Flags=%d',[G7FlagsToInteger(G7Objects[i].flags)]));
      SL.Add(format('  Code=%s',[copy(Code,1,20)]));
//      SL.Add(format('  Text=%s',[copy(Text,1,10)]));
      SL.Add('');
      if G7Objects[i].G7Type<>g7oempty then inc(cnt);
    end;
  end;
end;

procedure TFormG7.BDumpBarsClick(Sender: TObject);
var
  i, cnt : integer;
  SL : TStrings;
  s : string;
begin

  SL:=Memo1.Lines;

  SL.Add(format('------------%d ',[G7BarsCount]));

  cnt:=0;
  for i:=0 to MAXG7Bars-1 do begin
    if cnt >= G7BarsCount then break;
    with G7Bars[i] do begin
      if Connections<>(InCount+OutCount) then
        SL.Add(format('  ERROR: Conns=%d (InCnt=%d + OutCnt=%d)',[Connections,InCount,OutCount]));
      if Connections=0 then continue;
      SL.Add(format('Bar Nº=%d (page %d) Type=%d',[i, page, integer(BarType)]));
      SL.Add(format('  Cxi=%d, Cxf=%d, Cy=%d, CyMax=%d',[Cxi and $ff, Cxf and $ff, Cy and $ff, Cymax and $ff]));
      SL.Add(format('  Conns=%d (InCnt=%d + OutCnt=%d)',[Connections,InCount,OutCount]));
      SL.Add('');
      if G7Bars[i].Connections = 0 then continue;
      inc(cnt);
    end;
  end;
end;







function TFormG7.GetStepIdx(const SearchName : string) : integer;
var i:integer;
begin
  result:=-1;
  for i:=0 to MAXG7Objects-1 do begin
    if (G7Objects[i].G7Type = g7oStep) and
        (UpperCase(G7Objects[i].Name)=UpperCase(SearchName)) then begin
      result:=i;
      exit;
    end;
  end;
end;


function TFormG7.GetObjIdx(const SearchName : string) : integer;
var i:integer;
begin
  result:=-1;
  for i:=0 to MAXG7Objects-1 do begin
    if (UpperCase(G7Objects[i].Name)=UpperCase(SearchName)) then begin
      result:=i;
      exit;
    end;
  end;
end;

var SavedCode : TStrings;




procedure MySpecialAppend(const TS : TStrings; const Txt : string; const IndentPrefix:string);
var start,j : integer;
begin

  start:=1;
  for j := 2 to length(txt) do begin
    if (Txt[j]=#13) or (Txt[j]=#10) Then begin
      TS.append(IndentPrefix+copy(txt,start,j-start));
      if ((copy(Txt,j+1,1)=#13) or (copy(Txt,j+1,1)=#10)) then start:=j+2 else start:=j+1;
    end else
    if j=length(Txt)Then begin
      TS.append(IndentPrefix+copy(Txt,start,j-start+1));
      start:=j+2;
    end;
  end;


end;



function TFormG7.GenSTCode(InteratctiveMode: Boolean = True) : Boolean;
var
  CompilGr7 : TCompiledG7;
  cnt,i,j,start, li, CurPage : integer;
  s, maybevar : string;
  source : TStrings;
  StartLineMBit,StartLineMW : integer;
  WarnNoIniStep : boolean;
begin

  result:=false;

  if FormSelfGrade.CBSelfGradingRunning.Checked then InteratctiveMode:=False;

  WarnNoIniStep:=InteratctiveMode;

  CompilGr7 := G7Compile();

  SavedCode := FMain.SynEditST.Lines;
  source := FMain.SynEditST.Lines;

  source.clear;

  if not FMain.CBGrafcet.Checked then begin
    FMain.CBGrafcet.Checked := True;
    ShowMessageOrLog('Grafcet Automatically enabled');
  end;

  // Prepare Variables  m
  StartLineMBit := -1;
  for i:=1 to FVAriables.SGVars.RowCount-1  do begin
    if (PercentNameToType(FVAriables.SGVars.Cells[0,i])='m') and (StartLineMBit=-1) Then begin
      StartLineMBit:=i;
      break;
    end;
  end;

  // Prepare Variables  MW
  StartLineMW := -1;
  for i:=1 to FVAriables.SGVars.RowCount-1  do begin
    if (PercentNameToType(FVAriables.SGVars.Cells[0,i])='M') and (StartLineMW=-1) Then begin
      StartLineMW:=i;
      break;
    end;
  end;


  // Setup Pretty Names for Transitions, Steps and Step_Times
  ////FVariables.SetDefaultNames(FALSE);  // Maio de 2018 // does not fix
  for i:=0 to MAXG7Objects-1 do begin
    if G7Objects[i].G7Type = g7oStep then begin
      // May 2018 - Carefully delete old (may be obsolete) var names
      // and recreate them in the correct place
      li := SearchVarInSGVars(G7Objects[i].name);
      if li>-1 then with FVAriables do
        SGVars.Cells[1,li] := PercentNameToSimplexName(SGVars.Cells[0,li]);
      li := SearchVarInSGVars(G7Objects[i].name+'_t');
      if li>-1 then with FVAriables do
        SGVars.Cells[1,li] := PercentNameToSimplexName(SGVars.Cells[0,li]);
      // Assign new names as usual
      // ToDo: create variables pretty, one after the other, together, no "waste"
      FVAriables.SGVars.Cells[1,StartLineMbit+i] := G7Objects[i].name;
      FVAriables.SGVars.Cells[1,StartLineMW+i]   := G7Objects[i].name+'_t';
    end else
    if G7Objects[i].G7Type = g7oTransition then begin
      li := SearchVarInSGVars(G7Objects[i].name);
      if li>-1 then with FVAriables do
        SGVars.Cells[1,li] := PercentNameToSimplexName(SGVars.Cells[0,li]);
      FVAriables.SGVars.Cells[1,StartLineMbit+i] := G7Objects[i].name;
    end;
    if (i>=MaxMemBits) and
       ((G7Objects[i].G7Type = g7oTransition) or (G7Objects[i].G7Type = g7oStep)) then begin
      source.Append('');
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('// ' + VersionString);
      source.Append('// Out of memory starting on '+G7Objects[i].name);
      source.Append('////////////////////////////////////////////////////////////');
      FMain.LBErrors.Items.Append('Out of memory starting on '+G7Objects[i].name);
      if InteratctiveMode and (UpperCase(ParamStr(1))<>'-R') then ShowMessage('Out of memory starting on '+G7Objects[i].name);
      exit;
    end;
  end;



  source.Append('');
  source.Append('////////////////////////////////////////////////////////////');
  source.Append('// ' + VersionString);
  source.Append('// Code Automatically Generated:'+DateTimeToStr(Now));
  source.Append('////////////////////////////////////////////////////////////');

  for CurPage:=TBPage.Max DownTo TBPage.Min do begin
    source.Append('');
    source.Append(       '//######################################//');
    source.Append(Format('//################ Page%2d ##############//',[CurPage]));
    source.Append(       '//######################################//');

    i := GetStepIdx('Zone1');
    if (i>=0) and (G7Objects[i].Page=CurPage) then begin
      source.Append('');
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('////////////////////////// Zone1 ///////////////////////////');
      source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('');

      MySpecialAppend(source,G7Objects[i].Code,' ');
      //source.Append(G7Objects[i].Code);
    end;




    source.Append('');
    source.Append('////////////////////////////////////////////////////////////');
    source.Append('///////////// If boot => Set Initial Steps /////////////////');
    source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
    source.Append('////////////////////////////////////////////////////////////');
    source.Append('');


    source.Add('  If (sw0=0) Then');
    for i:=0 to MAXG7Objects-1 do begin
      if  (G7Objects[i].Page<>CurPage) then Continue;
      if G7Objects[i].G7Type = g7oStep then begin
        if g7fInitial in G7Objects[i].Flags then begin
          WarnNoIniStep := False;
          source.Add(Format('  // ObjIdx=%d => INI_Step "%s"',[i,G7Objects[i].name]));
          source.Add('    '+G7Objects[i].name+' := True;');
        end;
      end;
    end;
    source.Add('  End_If;');


    i := GetStepIdx('Zone2');
    if (i>=0) and (G7Objects[i].Page=CurPage) then begin
      source.Append('');
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('////////////////////////// Zone2 ///////////////////////////');
      source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('');
      MySpecialAppend(source,G7Objects[i].Code,' ');
      //source.Append(G7Objects[i].Code);
    end;


    // ** Allow action for ini step with below true transition');
    source.Append('if (sw0>0) then  // ** Prevent evolution in initial cycle');

    source.Append('');
    source.Append('////////////////////////////////////////////////////////////');
    source.Append('///////////////// Calc Fired Transitions ///////////////////');
    source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
    source.Append('////////////////////////////////////////////////////////////');
    source.Append('');

    for i:=0 to MAXG7Objects-1 do begin
      if  (G7Objects[i].Page<>CurPage) then Continue;
      if G7Objects[i].G7Type = g7oTransition then begin
        source.Add(Format('// ObjIdx=%d => Transition "%s"',[i,G7Objects[i].name]));
        s:='  // Steps Above: ';
        for j:=0 to CompilGr7[i].AboveCount-1 do
          s:=s+ format('id=%d => %s ;',[CompilGr7[i].Above[j], G7Objects[CompilGr7[i].Above[j]].Name]);
        source.Append(s);
        s:='  // Steps Below: ';
        for j:=0 to CompilGr7[i].BelowCount-1 do //s:=s+G7Objects[MyGr7[i].Below[j]].Name+'; ';
          s:=s+ format('id=%d => %s ;',[CompilGr7[i].Below[j], G7Objects[CompilGr7[i].Below[j]].Name]);
        source.Append(s);

        if (Trim(G7Objects[i].Code)='') then begin
          if not InteratctiveMode then G7Objects[i].Code:='True' else begin
            if (MessageDlg('Empty Transition ('+G7Objects[i].name+') is not allowed...'+crlf+
                        'Set condition to "True"?',
                         mtConfirmation, [mbYes, mbNo], 0) = mrYes) then begin  // If not interactive mode
              G7Objects[i].Code:='True';
              G7RedrawAll;
            end;
          end;
        end;

        // Build transition code
        s:=  '  '+G7Objects[i].name+' := (not '+'%s10' + IntToStr(CurPage) + ') AND ( '; // prettify and open parentesis for freezing grafcet page
        for j:=0 to CompilGr7[i].AboveCount-1 do begin
          s:=s+' '+G7Objects[compilGr7[i].Above[j]].Name+' AND ';    // _MemBits[5] :=  _MemBits[2] AND  ((_InBitsFunc[1]()))
        end;
        if  ((CompilGr7[i].AboveCount-1)>0) and
            (UpperCase(trim(G7Objects[i].Code))='TRUE') then begin  // a ver para deixar de dar warnings
          s := MidStr(s,1,length(s)-5);
        end else begin
          s:=s+' ('+trim(G7Objects[i].Code)+')';
        end;
        s:=s+' ) ;';  // close parentesis for freezing grafcet page
        source.Append(s);
      end;
    end;

    // ** Allow action for ini step with below true transition');
    source.Append('end_if; //** Prevent evolution in initial cycle');

    i := GetStepIdx('Zone3');
    if (i>=0) and (G7Objects[i].Page=CurPage) then begin
      source.Append('');
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('////////////////////////// Zone3 ///////////////////////////');
      source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('');
      MySpecialAppend(source,G7Objects[i].Code,' ');   ////// Has a bug from Delphi, strange lines count
      //source.Append(G7Objects[i].Code);
    end;



    source.Append('');
    source.Append('////////////////////////////////////////////////////////////');
    source.Append('///////////////// ReSet Steps Above fired Tr ///////////////');
    source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
    source.Append('////////////////////////////////////////////////////////////');
    source.Append('');

    cnt := 0;
    for i:=0 to MAXG7Objects-1 do begin
      if  (G7Objects[i].Page<>CurPage) then Continue;
      if cnt >= G7ObjectsCount then break;
      if G7Objects[i].G7Type = g7oEmpty then continue;
      //if G7Objects[i].G7Type = g7oTransition then begin
      if G7Objects[i].G7Type = g7oTransition then begin
        source.Add(Format('// ObjIdx=%d => Transition "%s"',[i,G7Objects[i].name]));
        s:='  // Steps Above: ';
        for j:=0 to CompilGr7[i].AboveCount-1 do
          s:=s+ format('id=%d => %s ;',[CompilGr7[i].Above[j], G7Objects[CompilGr7[i].Above[j]].Name]);
        source.Append(s);
        s:='  // Steps Below: ';
        for j:=0 to CompilGr7[i].BelowCount-1 do //s:=s+G7Objects[MyGr7[i].Below[j]].Name+'; ';
          s:=s+ format('id=%d => %s ;',[CompilGr7[i].Below[j], G7Objects[CompilGr7[i].Below[j]].Name]);
        source.Append(s);

        // If Tr fired, then
        s:=  '  If ('+G7Objects[i].name+') Then';
        source.Append(s);
        // Reset Steps Above
        s:='    ';
        for j:=0 to CompilGr7[i].AboveCount-1 do
          s := s + ' '+G7Objects[CompilGr7[i].Above[j]].name+':=False; ';
        source.Append(s);
        source.Append('  End_If;');

      end;
      inc(cnt);
    end;

    i := GetStepIdx('Zone4');
    if (i>=0) and (G7Objects[i].Page=CurPage) then begin
      source.Append('');
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('////////////////////////// Zone4 ///////////////////////////');
      source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('');
      MySpecialAppend(source,G7Objects[i].Code,' ');
      //source.append(G7Objects[i].Code);
    end;



    source.Append('');
    source.Append('////////////////////////////////////////////////////////////');
    source.Append('///////////////// Set Steps below fired Tr /////////////////');
    source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
    source.Append('////////////////////////////////////////////////////////////');
    source.Append('');

    cnt := 0;
    for i:=0 to MAXG7Objects-1 do begin
      if  (G7Objects[i].Page<>CurPage) then Continue;
      if cnt >= G7ObjectsCount then break;
      if G7Objects[i].G7Type = g7oEmpty then continue;
      if G7Objects[i].G7Type = g7oTransition then begin
        source.Add(Format('// ObjIdx=%d => Transition "%s"',[i,G7Objects[i].name]));
        s:='  // Steps Above: ';
        for j:=0 to CompilGr7[i].AboveCount-1 do
          s:=s+ format('id=%d => %s ;',[CompilGr7[i].Above[j], G7Objects[CompilGr7[i].Above[j]].Name]);
        source.Append(s);
        s:='  // Steps Below: ';
        for j:=0 to CompilGr7[i].BelowCount-1 do //s:=s+G7Objects[MyGr7[i].Below[j]].Name+'; ';
          s:=s+ format('id=%d => %s ;',[CompilGr7[i].Below[j], G7Objects[CompilGr7[i].Below[j]].Name]);
        source.Append(s);


        // If Tr fired, then
        s:=  '  If ('+G7Objects[i].name+') Then ';
        source.Append(s);
        // Set Steps Below
        s:='   ';
        for j:=0 to CompilGr7[i].BelowCount-1 do begin
          s := s + ' '+G7Objects[CompilGr7[i].Below[j]].name+' := True; ';
        end;
        source.Append(s);
        s:='    ';
        for j:=0 to CompilGr7[i].BelowCount-1 do begin
          //s := s + 'mw'+inttostr(CompilGr7[i].Below[j])+':=0; ';
          s := s + G7Objects[CompilGr7[i].Below[j]].name+'_T := 0; ';
        end;
        source.Append(s);
        source.Append('  End_If;');

      end;
      inc(cnt);
    end;

    i := GetStepIdx('Zone5');
    if (i>=0) and (G7Objects[i].Page=CurPage) then begin
      source.Append('');
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('////////////////////////// Zone5 ///////////////////////////');
      source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('');
      MySpecialAppend(source,G7Objects[i].Code,' ');
      //source.append(G7Objects[i].Code);
    end;



    if MenuCBResetOutsAtStartCycle.Checked then
      if ((CurPage=TBPage.Max) AND not(MenuStartQAtPg2.Checked))  or
         ((CurPage=2)          AND    (MenuStartQAtPg2.Checked)) then begin

      source.Append('');
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('////////// Unset (Clear) all Outputs (once for all pages) //////////');
      source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('');

      for i:=1 to FVAriables.SGVars.RowCount-1  do begin
        if (PercentNameToType(FVAriables.SGVars.Cells[0,i])='q') then begin
          if (FVAriables.SGVars.Cells[1,i]<>'') then
            source.Append('  '+FVAriables.SGVars.Cells[1,i]+':=False;')
          else
            source.Append('  '+FVAriables.SGVars.Cells[0,i]+':=False;')
        end;
      end;

      source.Append('');
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('////////// Unset (Clear) Freeze System Bits       //////////');
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('');

      source.Append('  %s100:=False;');
      source.Append('  %s101:=False;');
      source.Append('  %s102:=False;');
      source.Append('  %s103:=False; // Should not be used');

    end;



    i := GetStepIdx('Zone6');
    if (i>=0) and (G7Objects[i].Page=CurPage) then begin
      source.Append('');
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('////////////////////////// Zone6 ///////////////////////////');
      source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('');
      MySpecialAppend(source,G7Objects[i].Code,' ');
      //source.append(G7Objects[i].Code);
    end;





    source.Append('');
    source.Append('////////////////////////////////////////////////////////////');
    source.Append('///// If step active increment MW timer of step @ %s16 /////');
    source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
    source.Append('////////////////////////////////////////////////////////////');
    source.Append('');


    for i:=0 to MAXG7Objects-1 do begin
      if  (G7Objects[i].Page<>CurPage) then Continue;
      if G7Objects[i].G7Type = g7oStep then begin
        source.Append(Format('  // ObjIdx=%d => Step "%s"',[i,G7Objects[i].name]));
        // SysBit[Timer10Hz:=16] - active 1 cycle each 100 ms (100 ms approx)
        source.Append('  If (s16) and ('+G7Objects[i].name+') Then ');
        source.Append('    '+G7Objects[i].name+'_T := '+G7Objects[i].name+'_T+1'+';');
        source.Append('  end_if;');
      end;
    end;


    i := GetStepIdx('Zone7');
    if (i>=0) and (G7Objects[i].Page=CurPage) then begin
      source.Append('');
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('////////////////////////// Zone7 ///////////////////////////');
      source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('');
      MySpecialAppend(source,G7Objects[i].Code,' ');
      //source.append(G7Objects[i].Code);
    end;



    source.Append('');
    source.Append('////////////////////////////////////////////////////////////');
    source.Append('//////// If step active, execute its action code ///////////');
    source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
    source.Append('////////////////////////////////////////////////////////////');
    source.Append('');

    for i:=0 to MAXG7Objects-1 do begin
      if (G7Objects[i].G7Type <> g7oStep) then continue;
      if (G7Objects[i].Page<>CurPage) then Continue;

      // If RoundStates
      if (CBRoundStates.Checked and (trim(G7Objects[i].Code)<>'')) then begin
        source.Append(Format('  // ObjIdx=%d => RoundState "%s" (var)',[i,G7Objects[i].name])); // bug here (solved <<code...>>)
        source.Append('  If '+G7Objects[i].name+' Then ');
        if (copy(G7Objects[i].Code,length(G7Objects[i].Code),1)<>chr(13)) and
           (copy(G7Objects[i].Code,length(G7Objects[i].Code),1)<>chr(10)) then
          G7Objects[i].Code := G7Objects[i].Code+chr(13)+chr(10);
        start:=1;
        for j := 2 to length(G7Objects[i].Code) do begin
          if (G7Objects[i].Code[j]<>chr(13)) Then continue;
          maybeVar:=copy(G7Objects[i].Code,start,j-start);
          start:=j+2;
          if IsVar(maybeVar) then begin
            source.append('    '+maybeVar+' :=True;');
          end else begin
            ShowMessage('Syntx error => State='+G7Objects[i].name+' => "'+maybeVar+'" Is strange');
          end;
        end;
        source.Append('  End_If;');
        continue;
      end;

      // if not round_states
      if (G7Objects[i].G7Type = g7oStep) and (trim(G7Objects[i].Code)<>'') then begin
        //source.Append(Format('  // ObjIdx=%d => Step "%s" => Cod="%s"',[i,G7Objects[i].name,G7Objects[i].Code])); // bug here
        source.Append(Format('  // ObjIdx=%d => Step "%s" (code...)',[i,G7Objects[i].name])); // bug here (solved <<code...>>)
        //if (trim(G7Objects[i].Code)='') then Continue;
        source.Append('  If '+G7Objects[i].name+' Then ');
        // To prevent bugs, enters must be removed and
        // each line appended to the TStrings of the code
            //start:=1;
            //for j := 2 to length(G7Objects[i].Code) do begin
            //  if (G7Objects[i].Code[j]=chr(13)) Then begin
            //    source.append(' '+copy(G7Objects[i].Code,start,j-start{+1}));
            //    if ((copy(G7Objects[i].Code,j+1,1)=#13) or
            //        (copy(G7Objects[i].Code,j+1,1)=#10)) then start:=j+2 else start:=j+1;
            //  end else
            //  if j=length(G7Objects[i].Code)Then begin
            //    source.append(' '+copy(G7Objects[i].Code,start,j-start+1));
            //    start:=j+2;
            //  end;
            //end;
        MySpecialAppend(source, G7Objects[i].Code, '    ');
        source.Append('  End_If;');
      end;
    end;

    i := GetStepIdx('Zone8');
    if (i>=0) and (G7Objects[i].Page=CurPage) then begin
      source.Append('');
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('////////////////////////// Zone8 ///////////////////////////');
      source.Append(Format('//####################### Page%2d ########################//',[CurPage]));
      source.Append('////////////////////////////////////////////////////////////');
      source.Append('');

      MySpecialAppend(source,G7Objects[i].Code,' ');
    end;

  end; // __end_cur_page___


  if WarnNoIniStep then ShowMessageOrLog('Warning: no initial step in any page... strange...');

////    if  (G7Objects[i].Page<>CurPage) then Continue;
////    if (i>=0) and (G7Objects[i].Page=CurPage) then begin

  source.Append('');
  source.Append('(*************** End of ST Code ****************)');

  result:=True;
  Project.Modified := True;

  FormG7.G7RedrawAll();
  FMain.FixSyntaxHighlAndCompletion;
  FMain.UpdateStatusLine;
end;


procedure TFormG7.BUndoGenCodeClick(Sender: TObject);
begin
  FMain.SynEditST.Lines := SavedCode;
end;

procedure TFormG7.CBDebugStuffClick(Sender: TObject);
begin
end;

procedure TFormG7.MenuGenCodClick(Sender: TObject);
begin
  GenSTCode();
end;

procedure TFormG7.UndoLastCodeGeneration1Click(Sender: TObject);
begin
  BUndoGenCodeClick(Sender);
end;

procedure TFormG7.ZapClick(Sender: TObject);
begin
  G7Clear();
end;

procedure TFormG7.SynEditST_G7Change(Sender: TObject);
begin
  if(FMain.ScriptState=ssRunning) then exit;
  SynEditST_G7.SetFocus;
  if SynEditST_G7.Tag>=0 then begin
    G7Objects[SynEditST_G7.Tag].Code:=SynEditST_G7.Text;
    G7RedrawAll();
  end else begin
    SynEditST_G7.Text:='';
  end;
end;

procedure TFormG7.SynEditST_G7Exit(Sender: TObject);
begin
  G7RedrawAll();
end;

procedure TFormG7.MenuSaveProjectClick(Sender: TObject);
begin
  FMain.MenuSaveClick(Sender);
end;

procedure TFormG7.MenuSaveproject1Click(Sender: TObject);
begin
  MenuSaveProjectClick(Sender);
end;

procedure TFormG7.MenuG7STCompileClick(Sender: TObject);
begin
  if (GenSTCode()) then begin
    FMain.MenuCompileClick(Sender);
    //FMain.BringToFront;
  end;
end;

procedure TFormG7.MenuG7STRunClick(Sender: TObject);
begin
  if GenSTCode() then begin
    MenuG7STCompileClick(Sender);
    FMain.MenuRunClick(Sender);
    if FMain.LBErrors.Items.Count>0 then begin // Compile Error
      FMain.BringToFront;
      FMain.LBErrors.ItemIndex:=0;
      FMain.LBErrorsClick(nil);
    end;
  end;
end;

procedure TFormG7.SetStepActivity(aStepIdx : integer; activeStep : boolean);
begin
  if G7Objects[aStepIdx].G7Type=g7oStep then begin
    if activeStep XOR (g7fActive in G7Objects[aStepIdx].flags) then begin
      if activeStep then
        G7Objects[aStepIdx].flags := G7Objects[aStepIdx].flags + [g7fActive]
      else
        G7Objects[aStepIdx].flags := G7Objects[aStepIdx].flags - [g7fActive];
      G7RedrawAll();
    end;
  end;
end;

procedure TFormG7.TBFontChange(Sender: TObject);
begin
   FontZoom:=TBFont.Position;
   if FontZoom>4 then FontZoom:=4;
   if FontZoom<-4 then FontZoom:=-4;
   SynEditST_G7.Font.Size := 9+FontZoom;
   VLEPropEdit.Font.Size := 8 + FontZoom div 2;
   VLEPropEdit.DefaultRowHeight := 8 + 20 + FontZoom;
   BRedrawAllClick(Sender);
end;

procedure TFormG7.TBCodeAreaSizeChange(Sender: TObject);
begin
  if not CBShowCode.Checked then begin
    SizeX:=8;
    exit;
  end;

  SizeX:=TBCodeAreaSize.Position*8;
  CalculateRectangles;
  CalculateDependents;
  G7RedrawAll;
end;

procedure TFormG7.MenuAboutClick(Sender: TObject);
begin
  FMain.MenuAboutClick(Sender);
    //FormSplash.Show;
    //FormSplash.BringToFront;
    //FormSplash.SetFocus;
end;

//const crlf = string(chr(13)+chr(10))

procedure TFormG7.ImageHelpCodeAreaClick(Sender: TObject);
var msg:string;
begin
  msg:='Draw Grid Area:'+crlf+'Seperate alternate lines for Steps and for Transitions'+crlf+
        'Right click for context options'+crlf+
        'Editable object properties and associated code in right pane'+crlf+
        'Press F2 to swap FAGrafcet and ST code'+crlf+crlf;
  msg:=msg+'Tool: Place Steps + Transitions'+crlf+SPStepTransition.Hint+crlf+crlf;
  msg:=msg+'Tool: Connect (draw connections)'+crlf+SPConnector.Hint+crlf+crlf;
  msg:=msg+'Tool: Jump (or uplink)'+crlf+SPJump.Hint+crlf+crlf;
  msg:=msg+'Code area: Press CTRL+SPACE for completion menu'+crlf;
  msg:=msg+crlf;
  msg:=msg+crlf+'Aditionally, all code is produced on a per page basis, page 0 Last'+crlf;
  msg:=msg+crlf;
  msg:=msg+'Hierarchy :'+crlf;
  msg:=msg+'*  %s100/1/2 to Freeze Page 0/1/2 of Grafcet - Caution!'+crlf;
  msg:=msg+'*  PageStart(i) - INIT of grafcet of page i={0,1,2}'+crlf;
  msg:=msg+'*  PageClear(i) - de-activate all steps of grafcet of page i={0,1,2} - allows evolution imediately after'+crlf;
  msg:=msg+'*  You can set and or clear steps (X_step) and transitions (T_trnsition)'+crlf;
  ShowMessage(msg);

  ShowMessage(LabelZones.Caption);

end;

procedure TFormG7.MenuSTClick(Sender: TObject);
begin
  FMain.BringToFront;
end;

procedure TFormG7.MenuG7STCClick(Sender: TObject);
begin
  FMain.BST2CClick(Sender);
  FMain.SetFocus();
end;


procedure TFormG7.G7PageStart(const ThePage : integer);
var
  i, li : integer;
begin
  for i:=0 to MAXG7Objects-1 do begin
    //if G7Objects[i].G7Type = g7oEmpty then continue;
    if (G7Objects[i].G7Type <> g7oStep) OR (G7Objects[i].Page<>thePage) then continue;
    li := SearchVarInSGVars(G7Objects[i].name);
    if li=-1 then
       ShowMessage('PgSt li=-1');
    if li>-1 then begin
      PLCState.MemWords[li-1] := 0;
      PLCState.MemBits[li-1]  := (g7fInitial in G7Objects[i].Flags); //// Wrong
    end;
    if (g7fInitial in G7Objects[i].Flags) then
      G7Objects[i].Flags    := G7Objects[i].Flags + [g7fActive]
    else
      G7Objects[i].Flags    := G7Objects[i].Flags - [g7fActive];
  end;
  FMain.TimUpdtVarInfoTimer(nil);
  G7RedrawAll();
end;


procedure TFormG7.G7PageClear(const ThePage : integer);
// Clears Steps only
// Clear Active_Flag and PLCBit and PLCWord (via SGVars)
var
  i, li : integer;
begin
  for i:=0 to MAXG7Objects-1 do begin
    if (G7Objects[i].G7Type <> g7oStep) OR (G7Objects[i].Page<>thePage) then continue;
    G7Objects[i].Flags    := G7Objects[i].Flags - [g7fActive];
    li := SearchVarInSGVars(G7Objects[i].name);
    if (li>-1) and (li<MaxMemBits) then begin // if found (not found is not a problem)
      PLCState.MemWords[li-1] := 0;
      PLCState.MemBits[li-1]  := false;  //// Wrong
    end;
    FMain.TimUpdtVarInfoTimer(nil);
    G7RedrawAll();
  end;
end;

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
/////////////// Self Grade    [Name + Bar] + Code     Fixing
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
//
//
// Obs:   Magic offset for SelfGradeStuff is 777
//
//


procedure SpecialSGFixBarsInAndOut(const idx : integer);
begin
  if (G7Objects[idx].BarInIdx >-1) and (G7Objects[idx].BarInIdx <777) then inc(G7Objects[idx].BarInIdx, 777);
  if (G7Objects[idx].BarOutIdx>-1) and (G7Objects[idx].BarOutIdx<777) then inc(G7Objects[idx].BarOutIdx,777);
end;

function MyIsWhiteSpaceSeparator(const s : string) : boolean;
var c : char;
begin
  if s='' then  begin
    result := true;
  end else begin
    c:=s[1];
    result := (c=' ') OR (c=chr(10)) or (c=chr(13))  or (c='(')
               or (c='+') or (c='-') or (c='*') or (c='/');
  end;
end;

function MyIsDigit(const s : string) : boolean;
var c : char;
begin
    if s='' then  begin
      result := true;
    end else begin
    c:=s[1];
    result := (c>='0') AND (c<='9');
  end;
end;

var trace:string;

function SpecialSGFixStepOrTr(const idx : integer) : integer;
var
  startchr, endchr, i ,cnt, targetidx : integer;
  c : char;
  tmpstr : string;
begin
  result:=0;
  if   (LowerCase(G7Objects[idx].Name[1])<>'x') and
       (LowerCase(G7Objects[idx].Name[1])<>'t') then begin
         ShowMessage(G7Objects[idx].Name+' must start with "x" or "t"');
         exit;
  end;
  if  (copy(G7Objects[idx].Name,2,3) <> '777') then begin
    G7Objects[idx].Name := G7Objects[idx].Name[1] + '777' + copy(G7Objects[idx].Name,2,999);
  end;

  SpecialSGFixBarsInAndOut(idx);        // FixBars

  startchr:=1;
  cnt:=1;
  c:='x';
  trace:='';
  while(true) do begin
    startchr := NPos(c, LowerCase(G7Objects[idx].Code),cnt);
    if (startchr>0) then inc(cnt);
    trace:=trace+c;
    if (startchr=0) and (c='x') then begin startchr:=1; cnt:=1; c:='t'; continue; end;
    if (startchr=0) and (c='t') then break;
    if (copy(G7Objects[idx].Code,startchr+1,3)='777') then continue;
    trace:=trace+c;
    if not(MyIsDigit(copy(G7Objects[idx].Code,startchr+1,1))) then continue;
    trace:=trace+c;
    if (startchr>1) then begin
      trace:=trace+c;
      if not MyIsWhiteSpaceSeparator(copy(G7Objects[idx].Code[startchr-1],1,1) ) then continue;
      trace:=trace+c;
    end;
    trace:=trace+c;
    for i := startchr+1 to length(G7Objects[idx].Code) do begin
      endchr := i;
      if not MyIsDigit(copy(G7Objects[idx].Code,i,1)) then break;
    end;
    trace:=trace+c;
    tmpstr := copy(G7Objects[idx].Code,startchr,endchr-startchr);
    trace:=trace+c;
    targetidx := FormG7.GetObjIdx(tmpstr);
    trace:=trace+c;
    if targetidx=-1 then begin
      Insert('777',tmpstr,2);    // check both names
      targetidx := FormG7.GetObjIdx(tmpstr);
    end;
    if targetidx=-1 then continue;
    trace:=trace+c;
    if (G7Objects[targetidx].Page>=0) and
       (G7Objects[targetidx].Page <3) then continue;
    trace:=trace+c;
    Insert('777',G7Objects[idx].Code,startchr+1);
    inc(result);
    trace:=trace+c+' 1 ';
  end;
  FormSelfGrade.MemoSGLog.Append('Debug code: '+trace);
end;

procedure SpecialSGFixJmp(const i : integer);
begin
  if   (LowerCase(G7Objects[i].Name[1])<>'j') then begin
    ShowMessage(G7Objects[i].Name+' must start with "j"');
    exit
  end;
  if  copy(G7Objects[i].Name,2,3) = '777' then exit;
  G7Objects[i].Name[2] := '7';
  G7Objects[i].Name[3] := '7';
  G7Objects[i].Name[4] := '7';
  SpecialSGFixBarsInAndOut(i);
end;

Function SpecialSGFixAllG7Obj() : integer;
var i : integer;
begin
  result := 0;
  for i:=0 to MAXG7Objects-3 do begin
    if (G7Objects[i].G7Type = g7oEmpty) or
       (G7Objects[i].Page <> 3) then continue;
    if (G7Objects[i].G7Type = g7oStep) OR
       (G7Objects[i].G7Type = g7oTransition)  then inc(result, SpecialSGFixStepOrTr(i));
    if (G7Objects[i].G7Type = g7oJumpStart) OR
       (G7Objects[i].G7Type = g7oJumpFinish)    then SpecialSGFixJmp(i);
  end;
end;








initialization

  SubCellHeight  := 10;
  SubCellWidth   := 10;

  SizeX      := 24; // subcell counts
  StepSizeX  := 7;
  StepSizeY  := 9;
  TrSizeX    := 3;
  TrSizeY    := 3;
  BarSizeY   := 1;

  MaxCellsX:=20;
  MaxCellsY:=80;

  FormG7.CalculateRectangles();
  FormG7.CalculateDependents();

  clStep := clBlack;
  clTr   := clBlack;
  clBkg  := $FFF7F7;
  clCellGrid := $E0E0E0;
  clSubCellGrid  := $F0F0F0;
  clCoded := clBlue;
  clDistroUnconn := ClTeal;
  clDistroConn := ClTeal or $f00000 ;
  clSelected := clPurple; //TColor($1010A0);
  ClComment  := clgray;

  clPhantom := TColor($00B800);
  clMove := $E0E000;
  clJumpStart  := clStep or $ff;
  clJumpFinish := clTr   or $ff;
  clElastic := clSkyBlue;
end.


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

procedure TFormG7.Button1Click(Sender:TObject);
var
  I, Start, Stop: Integer;
begin
PrintDialog1.Options := [poPageNums, poSelection];
PrintDialog1.FromPage := 1;
PrintDialog1.MinPage := 1;
PrintDialog1.ToPage := PageControl1.PageCount;
PrintDialog1.MaxPage := PageControl1.PageCount;
if PrintDialog1.Execute then
  begin
    { determine the range the user wants to print }
    with PrintDialog1 do
    begin
      if PrintRange = prAllPages then

        begin
        Start := MinPage - 1;
        Stop := MaxPage - 1;
      end
      else if PrintRange = prSelection then
      begin
        Start := PageControl1.ActivePage.PageIndex;
        Stop := Start;
        end
      else  { PrintRange = prPageNums }
      begin
        Start := FromPage - 1;
        Stop := ToPage - 1;
      end;
    end;
    { now, print the pages }

    with Printer do
    begin
      BeginDoc;
      for I := Start to Stop do
      begin
        PageControl1.Pages[I].PaintTo(Handle, 10, 10);
        if I <> Stop then
          NewPage;
      end;
      EndDoc;
    end;
  end;

end;

// Fixola
cnt := 0;
for i:=0 to MAXG7Objects-1 do begin
  if cnt >= G7ObjectsCount then break;
  if G7Objects[i].G7Type = g7oEmpty then continue;

  inc(cnt);
end;



