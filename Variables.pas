unit Variables;
{$MODE Delphi}          

interface

uses
  {$IFDEF Windows}
    Windows,
  {$ENDIF}
   Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Grids, main, iniFiles, structuredtext2pas;

type
  TFVariables = class(TForm)
    EditPercentName: TEdit;
    EditUserName: TEdit;
    BOK: TButton;
    BCancel: TButton;
    CBNextVar: TCheckBox;
    BDefaultNames: TButton;
    BClear: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    SGVars: TStringGrid;
    CBTypes: TComboBox;
    BIns8Line: TButton;
    BDelLine: TButton;
    BInsLine: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SGVarsSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure FormShow(Sender: TObject);
    procedure BOKClick(Sender: TObject);
    procedure BCancelClick(Sender: TObject);
    procedure CBTypesChange(Sender: TObject);
    procedure BDefaultNamesClick(Sender: TObject);
    procedure BClearClick(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure BIns8LineClick(Sender: TObject);
    procedure BDelLineClick(Sender: TObject);
    procedure EditUserNameKeyDown(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure BInsLineClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ClearAllNames;
    procedure SetDefaultNames(IncludeIOVars : Boolean = TRUE);
    procedure FormLoad(const Proj : TMemIniFile);
    procedure FormSave(var Proj : TMemIniFile);
    procedure FormInit;
  end;

var
  FVariables: TFVariables;

function GetUserNameFromPercentName(const PercentName: string): string;
function GetPercentNameFromUserName( const UserName : string ) : string;
function PercentNameToSimplexName(const PercentName:string) : string;


implementation

{$R *.lfm}

uses StructuredTextUtils, IOLeds, ProjManage, Math;


var EditingRow : integer;

procedure TFVariables.FormCreate(Sender: TObject);
var
  TS: TStringList;
begin

  SGVars.ColWidths[1]:=SGVars.DefaultColWidth*2;
  TS:=TStringList.create;
  try

    TS.Add('HeaderLine');
    GeneratePLCVarList('m', MaxMemBits, TS);
    GeneratePLCVarList('i', MaxInBits, TS);
    GeneratePLCVarList('q', MaxOutBits, TS);
    GeneratePLCVarList('s', MaxSysBits, TS);
    GeneratePLCVarList('M', MaxMemWords, TS);
    GeneratePLCVarList('S', MaxSysWords, TS);
    GeneratePLCVarList('t', MaxTimers, TS);

    SGVars.RowCount:=TS.Count;
    SGVars.Cols[0].AddStrings(TS);

    EditingRow:=1;

  finally
    TS.Free;
  end;

end;

procedure TFVariables.SGVarsSelectCell(Sender: TObject;
            ACol, ARow: Integer; var CanSelect: Boolean);
var
   newsel: TGridRect;
begin

  EditingRow:=arow;

  if (EditingRow<1)                then EditingRow:=1;
  if (EditingRow>=SGVars.RowCount) then EditingRow:=1;

  while (SGVars.RowHeights[EditingRow]<1) and (EditingRow<(SGVars.RowCount-1)) do
    EditingRow:=EditingRow+1;
  if (EditingRow>=SGVars.RowCount) then EditingRow:=1;
  while (SGVars.RowHeights[EditingRow]<1) and (EditingRow<(SGVars.RowCount-1)) do
    EditingRow:=EditingRow+1;

  //newsel.Left:=0;
  //newsel.Right:=1;
  //newsel.Top:=EditingRow;
  //newsel.Bottom:=EditingRow;
  //SGVars.Selection:=newsel;
  //ACol:=1;
  //ARow:=EditingRow;
  //CanSelect:=True;
  //FVariables.Invalidate;
  ////FVariables.Repaint;



  if EditingRow < (SGVars.TopRow+2) then begin
    SGVars.TopRow:=max(1,EditingRow-SGVars.VisibleRowCount div 2);
  end;

  if EditingRow > (SGVars.TopRow+SGVars.VisibleRowCount-3) then begin
    SGVars.TopRow:=max(1,EditingRow-SGVars.VisibleRowCount div 2);
  end;

  EditPercentName.Text:=SGVars.Cells[0,EditingRow];
  EditUserName.Text   :=SGVars.Cells[1,EditingRow];
  EditUserName.SelectAll;
  //FVariables.EditUserName.SetFocus; // Corre mal no formcreate
  FVariables.ActiveControl:=EditUserName;




end;

procedure TFVariables.FormShow(Sender: TObject);
begin
  SGVars.Cells[0,0]:='%Name';
  SGVars.Cells[1,0]:='UserName';
  //SGVars.Cells[2,0]:='';
  CBTypesChange(Sender);
end;

function InteractiveGoodVarName(const Name : string) : boolean;
var
  s:string;
begin
  result:=False;
  if Name<>trim(name) then begin
    ShowMessage('Ilegal beginning/trailing spaces in variable name');
    exit;
  end;
  if not IsValidIdent(name) then begin
    ShowMessage('Ilegal Variable Name');
    exit;
  end;
  s:=GetPercentNameFromUserName(Name);
  if (s<>'') then begin
    ShowMessage('Variable Name Already Used ('+s+')' );
    exit;
  end;
  result:=True;
end;


procedure TFVariables.BOKClick(Sender: TObject);
var
  dummy : boolean;
  NewEditingRow : integer;
//  newsel: TGridRect;

begin
  EditUserName.Text:=trim(EditUserName.Text);

  // Var Name change allowed if:
  //    Clear => OK
  //    Change in case => OK
  //    General Name Change => double check new good name

  if  (EditUserName.Text<>'') and
      (UpperCase(EditUserName.Text)<>UpperCase(SGVars.Cells[1,EditingRow])) and
      (SGVars.Cells[1,EditingRow]<>EditUserName.Text) then
    if not InteractiveGoodVarName(EditUserName.Text) then exit;

  SGVars.Cells[1,EditingRow]:=EditUserName.Text;
  FIOLeds.UpdateNames;

  if CBNextVar.Checked then begin
    NewEditingRow:=EditingRow;
    inc(NewEditingRow);
    NewEditingRow := Min(NewEditingRow,SGVars.RowCount-1);
    SGVars.Row:=NewEditingRow;
    SGVars.Col:=1;
    dummy:=true;
    SGVarsSelectCell(Sender,1,NewEditingRow,dummy);
    //StringGrid1.SetFocus;
    SGVars.invalidate;
  end;

  Project.Modified:=True;
  FMain.FixSyntaxHighlAndCompletion;
  FMain.UpdateStatusLine;
end;

procedure TFVariables.BCancelClick(Sender: TObject);
begin
  //EditPercentName.Text:=SGVars.Cells[0,EditingRow];
  EditUserName.Text   :=SGVars.Cells[1,EditingRow];
end;

procedure TFVariables.CBTypesChange(Sender: TObject);
var
  i : integer;
  FilterLetter : char;
begin

{All,Filled, I - Input, Q - Output, M - Memory Bits, MW - Memory Words,
 S - System Bits, SW - System Words, TM - Timers }

  if SGVars.Row >= SGVars.RowCount then SGVars.Row:=0;
  if SGVars.Col >= SGVars.ColCount then SGVars.Col:=0;

  if CBTypes.Text[1]='A' then begin
    for i:=1 to SGVars.RowCount-1 do begin
      SGVars.RowHeights[i]:=SGVars.DefaultRowHeight-1;
    end;
    exit;
  end;

  if CBTypes.Text[1]='F' then begin
    for i:=1 to SGVars.RowCount-1 do begin
      if (SGVars.Cells[1,i]<>'') and (SGVars.Cells[1,i]<>' ') then
         SGVars.RowHeights[i]:=SGVars.DefaultRowHeight-1
       else
         if SGVars.RowHeights[i-1]<1 then begin
           SGVars.RowHeights[i]:=0;//-1
         end else begin
           SGVars.RowHeights[i]:=0;
         end;
      end;
    exit;
  end;

  FilterLetter:=PercentNameToType('%'+CBTypes.Text);
  for i:=1 to SGVars.RowCount-1  do begin
    if PercentNameToType(SGVars.Cells[0,i])=FilterLetter then begin
      SGVars.RowHeights[i]:=SGVars.DefaultRowHeight-1
    end else begin
      SGVars.RowHeights[i]:=0; //-1
    end;
  end;

end;

procedure TFVariables.FormSave(var Proj : TMemIniFile);
begin
  SaveStringsToMemIni(Proj, 'Variables','Names',SGVars.Cols[1]);
  SaveFormGeometryToMemIni(Proj,FVariables);
  Proj.WriteBool('Variables','Visible',FVariables.Visible);
  Proj.WriteBool('Variables','NextVar',CBNextVar.Checked);
  Proj.WriteInteger('Variables','Filter',CBTypes.ItemIndex);
end;

procedure TFVariables.FormLoad(const Proj : TMemIniFile);
var dummycanselect : boolean;
    i: integer;
begin
  LoadStringsFromMemIni(Proj, 'Variables','Names',SGVars.Cols[1]);
  for i:=1 to SGVars.rowcount-1 do begin
    SGVars.Cells[1,i]:=trim(SGVars.Cells[1,i]);
  end;
  LoadFormGeometryFromMemIni(Proj,FVariables);
  CBNextVar.Checked:=Proj.ReadBool('Variables','NextVar',True);
  CBTypes.ItemIndex:=Proj.ReadInteger('Variables','Filter',0);
  CBTypesChange(FVariables);
  FVariables.Visible:=Proj.ReadBool('Variables','Visible',False);
  Project.Modified:=False;
  EditingRow:=1;
  while SGVars.RowHeights[EditingRow]<=0 do begin
    inc(EditingRow);
    if EditingRow>=SGVars.RowCount then begin EditingRow:=1;break;end;
  end;
  SGVarsSelectCell(FVariables,1,EditingRow,dummycanselect);
end;

procedure TFVariables.FormInit;
begin
  //SetDefaultNames;
  ClearAllNames;
  //TODO: Geometria default
  CBNextVar.Checked:=True;
  CBTypes.ItemIndex:=0;
  CBTypesChange(FVariables);
  FVariables.Visible:=False;
  FMain.FixSyntaxHighlAndCompletion;
end;


function PercentNameToSimplexName(const PercentName:string) : string;
begin

  case PercentNameToType(PercentName) of  {i q m M s S t }
    'i' : if PercentName[3]='1' then
             result:= 'I'+ copy(PercentName,pos('.',PercentName)+1,999);
    'q' : if PercentName[3]='2' then
             result:='Q'+ copy(PercentName,pos('.',PercentName)+1,999);
    'm' : result:='M'  +copy(PercentName,3,999);
    'M' : result:='MW' +copy(PercentName,4,999);
    's' : result:='S'  +copy(PercentName,3,999);
    'S' : result:='SW' +copy(PercentName,4,999);
    't' : result:='TM' +copy(PercentName,4,999);
  else
    result:='SimplexNameError:'+PercentName;
  end;

end;

procedure TFVariables.SetDefaultNames(IncludeIOVars : Boolean = TRUE);
var i : integer;
begin
  if IncludeIOVars then begin
    for i:=1 to SGVars.RowCount-1 do begin
      SGVars.Cells[1,i] := PercentNameToSimplexName(SGVars.Cells[0,i]);
    end;
  end else begin
    for i:=1 to SGVars.RowCount-1 do begin
      if  (PercentNameToType(FVAriables.SGVars.Cells[0,i])<>'i') AND
          (PercentNameToType(FVAriables.SGVars.Cells[0,i])<>'q') then
             SGVars.Cells[1,i] := PercentNameToSimplexName(SGVars.Cells[0,i]);
    end;
  end;

  FIOLeds.UpdateNames;
  Project.Modified:=True;
  FVariables.Invalidate;
end;


procedure TFVariables.BDefaultNamesClick(Sender: TObject);
var dummy : boolean;
begin
  if MessageDlg('Really Reset ALL variable names to default values ?', mtConfirmation , [mbOk,mbCancel], 0)
    =mrCancel then exit;
  SetDefaultNames;
  SGVarsSelectCell(Sender,1,1,dummy);
  FVariables.Invalidate;
  FMain.FixSyntaxHighlAndCompletion;
  FMain.UpdateStatusLine;
end;


procedure TFVariables.ClearAllNames;
var
  i : integer;
begin
  for i:=1 to SGVars.RowCount-1 do begin
    SGVars.Cells[1,i]:='';
  end;
  FIOLeds.UpdateNames;
  Project.Modified:=True;
  FVariables.Invalidate;
end;


procedure TFVariables.BClearClick(Sender: TObject);
var dummy : boolean;
begin
  if MessageDlg('Really Clear ALL variable names ?', mtConfirmation , [mbOk,mbCancel], 0)
    =mrCancel then exit;
  ClearAllNames;
  SGVarsSelectCell(Sender,1,1,dummy);
  FVariables.Invalidate;
  FMain.FixSyntaxHighlAndCompletion;
  FMain.UpdateStatusLine;
end;

function GetUserNameFromPercentName( const PercentName : string ) : string;
var i : integer;
begin
  result:='';
  for i:=1 to FVariables.SGVars.RowCount-1 do  // TODO: interpret 01=1 ...
    if FVariables.SGVars.Cells[0,i]=PercentName then begin
      result:=FVariables.SGVars.Cells[1,i];
      exit;
    end;
end;

function GetPercentNameFromUserName( const UserName : string ) : string;
var i : integer;
begin
  result:='';
  for i:=1 to FVariables.SGVars.RowCount-1 do
    if UpperCase(FVariables.SGVars.Cells[1,i])=UpperCase(UserName) then begin
      result:=FVariables.SGVars.Cells[0,i];
      exit;
    end;
end;


procedure TFVariables.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  dummy : boolean;
  NewEditingRow : integer;
begin
  NewEditingRow := EditingRow - Sign(WheelDelta);
  SGVarsSelectCell(Sender,1,NewEditingRow,dummy);
  Handled := True;
end;

procedure TFVariables.BIns8LineClick(Sender: TObject);
var i:integer;
begin
  for i:=1 to 8 do BInsLineClick(Sender);
end;

procedure TFVariables.BDelLineClick(Sender: TObject);
var i:integer;
begin
  for i:=EditingRow to SGVars.RowCount-2 do SGVars.Cells[1,i]:=SGVars.Cells[1,i+1];
  Project.Modified:=True;
  FMain.FixSyntaxHighlAndCompletion;
  FMain.UpdateStatusLine;
end;

procedure TFVariables.EditUserNameKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var dummy_canselect: boolean;
begin
  if key = VK_UP then begin
    EditingRow:=EditingRow-1;
  end;
  if key = VK_DOWN then begin
    EditingRow:=EditingRow+1;
  end;
  if (key = VK_DOWN) or (key=VK_UP) then begin
    SGVars.Row:=EditingRow;
    SGVars.Col:=1;
    dummy_canselect:=true;
    SGVarsSelectCell(Sender,1,EditingRow,dummy_canselect);
  end;
end;

procedure TFVariables.BInsLineClick(Sender: TObject);
var i:integer;
begin
  for i:=SGVars.RowCount-2 downto EditingRow do SGVars.Cells[1,i+1]:=SGVars.Cells[1,i];
  SGVars.Cells[1,EditingRow]:='';

  Project.Modified:=True;
  FMain.FixSyntaxHighlAndCompletion;
  FMain.UpdateStatusLine;
end;

end.
