unit structuredtext2pas;
{$MODE Delphi}          

interface

uses Classes, StructuredTextUtils
  {FA_TAG:  ,dws2Exprs, dws2Stack }
;

const
  MAXTranslations = 4095;

type
  TTranslation = record
    orig,dest     : string;
    IgnoreWhites  : Boolean; // Defaults to FALSE
    JoinWithNext  : Boolean; // Defaults to FALSE
  end;
  TTranslations = record
    Data : array  [0..MAXTranslations (*-1*) ] of TTranslation;
    count : integer;
  end;


type                // Inspiracao:   println(_TIMERS(0).v);_START_TIMERS(0); _START_TIMERS(1); _STARTERR;
  TTimers = class
    public
    Timer : array [0 .. MaxTimers-1] of TPLCTimerState;
    //property Timer
  end;


procedure PLCStateToScriptState(var CurState: TPLCState; const PrevState: TPLCState);

{FA_TAG:
procedure ScriptStateToPLCState( var prog: TProgram; var PLCState: TPLCState);
}

procedure GetAllVarNames(var Tr : TTranslations);
function  IsVar(const varname:string) : boolean;


procedure Translate(InpStrings, OutStrings : TStrings; const Trans : TTranslations);
procedure TranslateArrayInit(var Trans : TTranslations);
procedure AddTranslation(var MyTranls : TTranslations; const orig, dest : string;
                         const IgnoreWhites : boolean =False;
                         const JoinWithNext : boolean =False);
function  PercentNameToType(const s : string) : char; {devolve: i q m M s S t }
function  PercentNameToInternalNameInFunc (const PercentName:string) : string;
function  PercentNameToInternalNameInArray(const PercentName:string) : string;
//function  GetIntegerValueFromAnyVarName(const s : string) : integer;
function GetStringValueFromAnyVarName(const s: string): string;
function SearchVarInSGVars(const VarName:string) : integer;

var
  TranslationsST2Pas : TTranslations;
  TranslationsPas2C : TTranslations;

implementation

uses SysUtils,Variables, dialogs;


function RiseEdge(const CurStateBit,PrevStateBit : boolean) : boolean;
begin
  result:=(PrevStateBit=False) and (CurStateBit=True);
end;

function FallEdge(const CurStateBit,PrevStateBit : boolean) : boolean;
begin
  result:=(PrevStateBit=True) and (CurStateBit=False);
end;

{FA_RESOLVIDO: ou não! }
// Calcular Rising Edges e Falling Edges
procedure PLCStateToScriptState( var CurState: TPLCState; const PrevState: TPLCState);
var  i: integer;
begin
  // Rising & Falling edges for bit variables
  //IN_bits
  for i:=0 to MaxInBits-1 do begin
   _RE_InBits[i] := RiseEdge(CurState.InBits[i],PrevState.InBits[i]); // or True; // For Test
   _FE_InBits[i] := FallEdge(CurState.InBits[i],PrevState.InBits[i]); // or True; // For Test
  end;

  //OUT_bits
  for i:=0 to MaxOutBits-1 do begin
    _RE_OutBits[i]:=RiseEdge(CurState.OutBits[i],PrevState.OutBits[i]); // or true;
    _FE_OutBits[i]:=FallEdge(CurState.OutBits[i],PrevState.OutBits[i]); // or true;
  end;

  //MEM_bits
  for i:=0 to MaxMemBits-1 do begin
   _RE_MemBits[i]:=RiseEdge(CurState.MemBits[i],PrevState.MemBits[i]);
   _FE_MemBits[i]:=FallEdge(CurState.MemBits[i],PrevState.MemBits[i]);
  end;

  //SYS_bits
  for i:=0 to MaxSysBits-1 do begin
    _RE_SysBits[i]:=RiseEdge(CurState.SysBits[i],PrevState.SysBits[i]);
    _FE_SysBits[i]:=FallEdge(CurState.SysBits[i],PrevState.SysBits[i]);
  end;

end;


{FA_RESOLVIDO: não é necessario porque as vars já lá estão!!!
procedure ScriptStateToPLCState( var prog: TProgram; var PLCState: TPLCState);
var A: TData;
    i: integer;
begin
  // TODO: test if someone messed with the inputs

//  A:=prog.Info.Data['inBits'];
//  for i:=0 to MaxInBits-1 do begin
//    PLCState.inBits[i]:=A[i];
//  end;

  A:=prog.Info.Data['_OutBits'];
  for i:=0 to MaxOutBits-1 do begin
    PLCState.OutBits[i]:=A[i];
  end;

  A:=prog.Info.Data['_MemBits'];
  for i:=0 to MaxMemBits-1 do begin
    PLCState.MemBits[i]:=A[i];
  end;

  A:=prog.Info.Data['_SysBits'];
  for i:=0 to MaxSysBits-1 do begin
    PLCState.SysBits[i]:=A[i];
  end;

  A:=prog.Info.Data['_MemWords'];
  for i:=0 to MaxMemWords-1 do begin
    PLCState.MemWords[i]:=A[i];
  end;

  A:=prog.Info.Data['_SysWords'];
  for i:=0 to MaxSysWords-1 do begin
    PLCState.SysWords[i]:=A[i];
  end;

  A:=prog.Info.Data['_Timers'];
  for i:=0 to MaxTimers-1 do begin
    PLCState.Timers[i].V:=A[i*5];
    PLCState.Timers[i].P:=A[i*5+1];
    PLCState.Timers[i].Q:=A[i*5+2];
    PLCState.Timers[i].mode:=A[i*5+3];
//    PLCState.Timers[i].timebase_ms:=A[i*5+4];
  end;

end;

}


function AbsolutePos(const SubStr, FullStr : string ; const StartScan : integer) : integer;
begin
  result:=pos(SubStr,LowerCase(copy(FullStr,StartScan,length(FullStr))));
  if result>0 then result:=result+StartScan-1;
end;

function IsSpaceOrTab(const ch : char) : boolean;
begin
  result := (ch=' ') or (ord(ch)=9);
end;

function IsValidIdentChar(const ch : char) : boolean;
begin
  result := ( (ord(ch)>=ord('a')) AND (ord(ch)<=ord('z')) ) OR
            ( (ord(ch)>=ord('A')) AND (ord(ch)<=ord('Z')) ) OR
            ( (ord(ch)>=ord('0')) AND (ord(ch)<=ord('9')) ) OR
            ( (ch='_') );
end;

procedure Replace(var s:string; const transl : TTranslation);
var
  WordStart,WordEnd : integer;
begin
  WordEnd:=0;
  while TRUE do begin
    WordStart:=AbsolutePos(transl.orig,s,WordEnd+1);
    if WordStart=0 then break;                   // not found, exit NOW!
    WordEnd:=WordStart+length(transl.orig)-1;    // WordSart till WordEnd INCLUSIVE

    if not transl.IgnoreWhites then begin
      if WordStart>1 then                          // word start = 1 => start validated
        if IsValidIdentChar(s[WordStart-1]) then
          continue; // part of larger identifier => not valid

      if Length(s)>=(WordEnd+1) then               // if eol => end validated => word is valid
        if (IsValidIdentChar(s[WordEnd+1])) then
          continue; // part of larger identifier => not valid
    end; // ignore whites

    if transl.JoinWithNext then begin
      while TRUE do begin
        inc(WordEnd);
        if WordEnd>Length(s) then break;              // ?! invalid
        if not IsSpaceOrTab(s[WordEnd]) then break;   // found something
      end;
      if (WordEnd>Length(s)) then begin
        s:=Copy(s,1,WordStart-1)+'Invalid_end_of_line_after_'+transl.orig+Copy(s,WordEnd+1,length(s));
        break; // give up translation
      end;
      if (not IsValidIdentChar(s[WordEnd])) then begin
        s:=Copy(s,1,WordStart-1)+'Only_spaces_can_separate_'+transl.orig+'_and_argument'+Copy(s,WordEnd+1,length(s));
        break; // give up translation
      end;
      dec(WordEnd);
    end;
    s:=Copy(s,1,WordStart-1)+transl.dest+Copy(s,WordEnd+1,length(s));     // replace
    WordEnd:=WordStart+length(transl.dest)-1;
  end;
end;


procedure Translate(InpStrings, OutStrings : TStrings; const Trans : TTranslations);
var
  ThisLine :string;
  ln,tr : integer;
  pos1,pos2 : integer;
begin
  OutStrings.Clear;
  for ln:=0 to InpStrings.Count-1 do begin    // ToDo: devia procurar o maior token válido
    ThisLine:=InpStrings.Strings[ln];         //       e devia transformá-lo antes dos outros
    if (copy(TrimLeft(ThisLine),1,2)<>'//') then begin
      //for tr:=Trans.count-1 downto 0 do begin  // ToDo:  perigo tokens maiores 1º
      for tr:=0 to Trans.count-1 do begin    // Exemplo %Q2.3 onde Q2 é válido e %Q2.3 tb
        Replace(ThisLine,Trans.Data[tr]);
      end;
    end;
    // Special hack for start Stimers
    // TIMER0 => above transformed into => _start_timers[0]
    // must still be transformed into   => _start_timers[0]()
    // _Start_Timers[0]()
    pos1 := pos(UpperCase('_Start_Timers'),UpperCase(ThisLine));
    if (pos1 > 0) Then begin
      pos2 := pos1+pos(']',copy(ThisLine,pos1,9999));
      if (pos2>0) then begin
        ThisLine := copy(ThisLine,1,pos2-1)+'()'+copy(ThisLine,pos2,9999);
      end else ThisLine:=ThisLine+' error:_no_]_;';
    end;
    OutStrings.Add(ThisLine);
  end;
end;


procedure AddTranslation(var MyTranls : TTranslations; const orig, dest : string;
                         const IgnoreWhites : boolean =False;
                         const JoinWithNext : boolean =False);
begin
  with MyTranls do begin
    Data[count].orig:=LowerCase(orig);
    Data[count].dest:=dest;
    Data[count].IgnoreWhites:=IgnoreWhites;
    Data[count].JoinWithNext:=JoinWithNext;
    inc(count);
    if (count>=MAXTranslations) then begin showmessage('BlowUp!'); dec(count);end;
  end;
end;

procedure TranslateArrayInit(var Trans : TTranslations);
begin
  TranslationsST2Pas.count:=0;    // Obs: sequence is VERY IMPORTANT
  AddTranslation(Trans,'do','do begin');
  AddTranslation(Trans,'end_for','end');
  AddTranslation(Trans,'end_while','end');
  AddTranslation(Trans,'end_if','end');
  AddTranslation(Trans,'else','end else begin');
  AddTranslation(Trans,'elsif','end else if');
  AddTranslation(Trans,'then','then begin');
  AddTranslation(Trans,'(*','{',True);
  AddTranslation(Trans,'*)','}',True);
  AddTranslation(Trans,'set','_set_not_implemented_');
  AddTranslation(Trans,'reset','_reset_not_implemented_');
  //AddTranslation(Trans,'RE','_RE_not_implemented_');
  //AddTranslation(Trans,'FE','_FE_not_implemented_');
  AddTranslation(Trans,'rol','_rol_not_implemented_');
  AddTranslation(Trans,'ror','_ror_not_implemented_');
  AddTranslation(Trans,'inc','_inc_not_implemented_');
  AddTranslation(Trans,'dec','_dec_not_implemented_');

  GetAllVarNames(Trans);

  AddTranslation(Trans,'RE','_RE',False,True);  // Must be after vars
  AddTranslation(Trans,'FE','_FE',False,True);
  AddTranslation(Trans,'start','_Start',False,True);

end;

function PercentNameToType(const s : string) : char; {devolve: i q m M s S t }
begin
  if length(s)<3 then begin result:=#0;exit; end;

  case (LowerCase(s[2])) of
    'i' : result := 'i';
    'q' : result := 'q';
    'm' : if (LowerCase(s[3]))='w' then result := 'M' else result := 'm';
    's' : if (LowerCase(s[3]))='w' then result := 'S' else result := 's';
    't' : result:='t';
  else result:=#0;
  end;
end;

procedure GetAllVarNames(var Tr : TTranslations);
var i : integer;
begin
  for i:=1 to FVariables.SGVars.RowCount-1 do
    with FVariables.SGVars do begin
      AddTranslation(Tr,Cells[0,i],PercentNameToInternalNameInFunc(Cells[0,i]));
      if (Cells[1,i]<>'') and (Cells[1,i]<>' ') then
        AddTranslation(Tr,Cells[1,i],PercentNameToInternalNameInFunc(Cells[0,i]));
    end;
end;

function IsVar(const VarName:string) : boolean;
var
  i : integer;
  aName : string;
begin
  IsVar := False;
  aName := Trim(UpperCase(VarName));
  for i:=1 to FVariables.SGVars.RowCount-1 do begin
    if (UpperCase(trim(FVariables.SGVars.Cells[1,i])) = aName) Then begin
      IsVar := True;
      exit;
    end;
  end;
end;



function SearchVarInSGVars(const VarName:string) : integer;
// Returns line in SGVars, -1 Not Found
var
  i : integer;
  aName : string;
begin
  result := -1;
  aName := Trim(UpperCase(VarName));
  for i:=1 to FVariables.SGVars.RowCount-1 do begin
    if (UpperCase(trim(FVariables.SGVars.Cells[1,i])) = aName) Then begin
      result:=i;
      exit;
    end;
  end;
end;


// returns inputs as return from func, adequate for code translation
function PercentNameToInternalNameInFunc(const PercentName:string) : string;
begin
  result:='';
  if length(PercentName)<3 then exit;
  if PercentName[1]<>'%' then exit;

  case PercentNameToType(PercentName) of  // i q m M s S t
    'i' : if PercentName[3]='1' then
             result:= '_InBits['+ copy(PercentName,pos('.',PercentName)+1,999)+']';
             //result:= '_InBitsFunc['+ copy(PercentName,pos('.',PercentName)+1,999)+']()';//FA_REsolvido
    'q' : if PercentName[3]='2' then
             result:='_OutBits['+ copy(PercentName,pos('.',PercentName)+1,999)+']';
    'm' : result:='_MemBits['+ copy(PercentName,3,999)+']';
    'M' : result:='_MemWords['+copy(PercentName,4,999)+']';
    's' : result:='_SysBits['+ copy(PercentName,3,999)+']';
    'S' : result:='_SysWords['+copy(PercentName,4,999)+']';
    //'t' : result:='_Timer_'+  copy(PercentName,4,999); // Pascal Script Lazarus style
    't' : result:='_Timers['+  copy(PercentName,4,999)+']'; // DWS Delphi style
  end;
end;

// returns inputs as name from true internal mem array, adequate for debug
function PercentNameToInternalNameInArray(const PercentName:string) : string;
begin
  result:=PercentNameToInternalNameInFunc(PercentName);

  if (PercentNameToType(PercentName)='i') and (PercentName[3]='1') then
    result:= '_InBits['+ copy(PercentName,pos('.',PercentName)+1,999)+']';

end;




{function GetIntegerValueFromAnyVarName(const s : string) : integer;
var
  PercName, varstr : string;
  Channel : integer;
begin

 result:=-9999;

  try
    if s[1]='%' then begin
      Percname:=s;
    end else begin
      PercName:=GetPercentNameFromUserName(s);
    end;

    varstr:=PercentNameToInternalName(PercName);
    varstr:=copy(varstr,1,length(varstr)-1);  // drop last ']'
    channel:=StrToInt(Copy(varstr,pos('[',varstr)+1,length(varstr)));

    case (PercentNameToType(PercName)) of   // devolve i q m M s S t
      'i' : result:=-ord(PLCState.InBits  [Channel]);
      'q' : result:=-ord(PLCState.OutBits [Channel]);
      'm' : result:=-ord(PLCState.MemBits [Channel]);
      'M' : result:=     PLCState.MemWords[Channel];
      's' : result:=-ord(PLCState.SysBits [Channel]);
      'S' : result:=     PLCState.SysWords[Channel];
      //'t' : //TODO Timer
    end;
  except
  end;
end;
}

function GetStringValueFromAnyVarName(const s: string): string;
var
  PercName, varstr : string;
  Channel, i : integer;
begin

  result:='';

  if length(s)<1 then exit;

  if s[1]='%' then begin
    Percname:=s;
  end else begin
    PercName:=GetPercentNameFromUserName(s);
  end;

  varstr:=PercentNameToInternalNameInArray(PercName);
  varstr:=copy(varstr,1,length(varstr)-1);  // drop last ']'
  if length(varstr)=0 then exit;
  i:= pos('[',varstr);
  if i=0 then i:= pos('(',varstr);
  if i=0 then exit;
  channel:=StrToInt(Copy(varstr,i+1,length(varstr)));

  case (PercentNameToType(PercName)) of   { devolve i q m M s S t }
    'i' : result:= Bool2Str[PLCState.InBits  [Channel]];
    'q' : result:= Bool2Str[PLCState.OutBits [Channel]];
    'm' : result:= Bool2Str[PLCState.MemBits [Channel]];
    'M' : result:= inttostr(PLCState.MemWords[Channel]);
    's' : result:= Bool2Str[PLCState.SysBits [Channel]];
    'S' : result:= inttostr(PLCState.SysWords[Channel]);
    't' : result:= format('v:%d p:%d Q:%d',[PLCState.Timers[Channel].v, PLCState.Timers[Channel].p, ord(PLCState.Timers[Channel].Q)]);
  end;
end;







/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

//      http://forum.lazarus.freepascal.org/index.php?topic=18511.0

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////


type
  TStringArray = array of string;


procedure arrayReserveFast(var a: TStringArray; const len: longint; const reserveLength: longint);
begin
  if reserveLength <= len then exit;
  if reserveLength <= length(a) then exit;
  if reserveLength <= 4  then SetLength(a, 4)
  else if reserveLength <= 16 then SetLength(a, 16)
  else if (len <= 1024) and (reserveLength <= 2*len) then SetLength(a, 2*len)
  else if (length(a) <= 1024) and (reserveLength <= 2*length(a)) then SetLength(a, 2*length(a))
  else if (reserveLength <= len+1024) then SetLength(a, len+1024)
  else if (reserveLength <= length(a)+1024) then SetLength(a, length(a)+1024)
  else SetLength(a, reserveLength);
end;

function arrayAddFast(var a: TStringArray; var len: longint; const e: string): longint;
begin
  if len >= length(a) then
    arrayReserveFast(a, len, len+1);
  result:=len;
  len:=len+1;
  a[result] := e;
end;                  

function strlsequal(p1,p2:pchar;l1,l2: longint):boolean;
var i:integer;
begin
  result:=l1=l2;
  if not result then exit;
  for i:=0 to l1-1 do
    if p1[i]<>p2[i] then begin  result:=false; exit; end;
end;

function strlsIndexOf(str, searched: pchar; l1, l2: longint): longint;
var last: pchar;
begin
  if l2<=0 then begin result:=0; exit;end;
  if l1<l2 then begin result:=-1;exit;end;
  last:=str+(l1-l2);
  result:=0;
  while str <= last do begin
    if str^ = searched^ then
      if strlsequal(str, searched, l2, l2) then
        exit;
    inc(str);
    result:=result+1;
  end;
  result:=-1;
end;

function strindexof(const str, searched: string; from: longint): longint;
begin
  if from > length(str) then begin result:=0;exit;end;
  result := strlsIndexOf(pchar(pointer(str))+from-1, pchar(pointer(searched)), length(str) - from + 1, length(searched));
  if result < 0 then begin result:=0;exit;end;
  result := result+from;
end;

function strcopyfrom(const s: string; start: longint): string; overload;
begin
  result:=copy(s,start,length(s)-start+1);
end;


procedure strSplit(out splitted: TStringArray; s, sep: string; includeEmpty: boolean); overload;
var p:longint;
    m: longint;
    reslen: longint;
begin
  SetLength(splitted,0);
  reslen := 0;
  if s='' then begin
    if includeEmpty then begin
      SetLength(splitted, 1);
      splitted[0] := '';
    end;
    exit;
  end;
  p:=pos(sep,s);
  m:=1;
  while p>0 do begin
    if p=m then begin
      if includeEmpty then
        arrayAddFast(splitted, reslen, '');
    end else
      arrayAddFast(splitted, reslen, copy(s,m,p-m));
    m:=p+length(sep);
    p:=strindexof(s, sep, m);
  end;
  if (m<>length(s)+1) or includeEmpty then
    arrayAddFast(splitted, reslen, strcopyfrom(s,m));
  SetLength(splitted, reslen);
end;


function strSplit(const s, sep: string; includeEmpty: boolean): TStringArray;overload;
begin
  strSplit(result, s, sep, includeEmpty);
end;



function Explode(delimiter:string; str:string; limit:integer=MaxInt):TStringArray;
var
  p,cc,dsize:integer;
begin
  cc := 0;
  dsize := length(delimiter);
  if dsize = 0 then
  begin
    setlength(result,1);
    result[0] := str;
    exit;
  end;
  while cc+1 < limit do
  begin
    p := pos(delimiter,str);
    if p > 0 then
    begin
      inc(cc);
      setlength(result,cc);
      result[cc-1] := copy(str,1,p-1);
      delete(str,1,p+dsize-1);
    end else break;
  end;
  inc(cc);
  setlength(result,cc);
  result[cc-1] := str;
end;


/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////








initialization

Bool2Str[false]:='false';
Bool2Str[true]:='true';

{

type
  TPLCTimerState = record
    V,P: integer;
    Q: boolean;
    Mode, Timebase_ms: Integer;
  end;

var InBits: array [0..MaxInBits-1] of boolean;
var OutBits: array[0..MaxOutBits-1] of boolean;
var MemBits: array[0..MaxMemBits-1] of boolean;
var SysBits: array[0..MaxSysBits-1] of boolean;

var MemWords: array[0..MaxMemWords-1] of integer;
var SysWords: array[0..MaxSysWords-1] of integer;
var Timers: array  [0..MaxTimers-1] of TPLCTimerState;


}

end.

