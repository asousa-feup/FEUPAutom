unit StructuredTextUtils;
{$MODE Delphi}          


interface

uses classes, Sysutils, Types;

{
const MaxMRegs  = 32;
const MaxMWRegs = 32;
const MaxSRegs  = 32;
const MaxTimers = 16;
const MaxSWRegs = 32;
}

const MaxInBits  = 48;
const MaxOutBits = 48;
const MaxMemBits = 128;
const MaxSysBits = 128;

const MaxMemWords = 128;
const MaxSysWords = 128;
const MaxTimers   = 32;



const  MAXIQSlots = 4;

const  MaxIChannels : array [0..MAXIQSlots-1] of integer
         = (0,MaxInBits,0,0);
const  MaxQChannels  : array [0..MAXIQSlots-1] of integer
         = (0,0,MaxOutBits,0);


type
  TTimerType = (TOn, TOff);

type
  TPLCTimerState = record
    P,V: word;  // Trocado para tentar contornar bug 2018 fev 207
    Q: boolean;
    //Mode : TTimerType;
  end;

  TArray_InBits  = array[0..MaxInBits-1]   of boolean;
  TArray_OutBits = array[0..MaxOutBits-1]  of boolean;
  TArray_MemBits = array[0..MaxMemBits-1]  of boolean;
  TArray_SysBits = array[0..MaxSysBits-1]  of boolean;

  TArray_MemWords= array[0..MaxMemWords-1] of integer;
  TArray_SysWords= array[0..MaxSysWords-1] of integer;
  TArray_Timers  = array[0..MaxTimers-1]   of TPLCTimerState;

  TPLCState = record
    InBits  : TArray_InBits;
    OutBits : TArray_OutBits;
    MemBits : TArray_MemBits;
    SysBits : TArray_SysBits;

    MemWords: TArray_MemWords;
    SysWords: TArray_SysWords;
    Timers  : TArray_Timers;
  end;


var
  PLCState, PrevPLCState,Int_PLCState: TPLCState;
  Bool2Str   : array[boolean] of string;
  _RE_InBits : TArray_InBits;
  _FE_InBits : TArray_InBits;
  _RE_OutBits: TArray_OutBits;
  _FE_OutBits: TArray_OutBits;
  _RE_MemBits: TArray_MemBits;
  _FE_MemBits: TArray_MemBits;
  _RE_SysBits: TArray_SysBits;
  _FE_SysBits: TArray_SysBits;


procedure GeneratePLCVarList( vtype: char; maxItems: integer; SL: TStrings);
function  BitsToDWord(const bits: array of boolean): DWord;
procedure DWordToBits(var bits: array of boolean; dw: DWord);
procedure WordsToBits(var words_in: array of word; var bits_in_out: array of boolean);
procedure BitsToWords(const bits_in : array of boolean; var words_in_out: array of word);


implementation

uses math;

//function ValidateIndex( idx: integer; var Variable: TPLCVar): boolean;
function ValidateIndex( idx: integer; vtype: char): boolean;
begin
  result:=false;
//  case Variable.vtype do begin
  case vtype of
    'i': if (idx >= 0) and (idx < MaxIQSlots)  then result:=True;
    'q': if (idx >= 0) and (idx < MaxIQSlots)  then result:=True;
    'm': if (idx >= 0) and (idx < MaxMemBits)  then result:=True;
    'M': if (idx >= 0) and (idx < MaxMemWords) then result:=True;
    's': if (idx >= 0) and (idx < MaxSysBits ) then result:=True;
    'S': if (idx >= 0) and (idx < MaxSysWords) then result:=True;
    't': if (idx >= 0) and (idx < MaxTimers)   then result:=True;
  end;
end;

procedure GeneratePLCVarList( vtype: char; maxItems: integer; SL: TStrings);
var i,b: integer;
begin
  for i:=0 to maxItems-1 do begin
    if ValidateIndex(i,vtype) then begin
      case vtype of
        'i': for b:=0 to MaxIChannels[i]-1 do begin
               SL.add(format('%%I%d.%d',[i,b]));
             end;

        'q': for b:=0 to MaxQChannels[i]-1 do begin
               SL.add(format('%%Q%d.%d',[i,b]));
             end;

        'm': SL.add(format('%%M%d',[i]));

        'M': SL.add(format('%%MW%d',[i]));

        's': SL.add(format('%%S%d',[i]));

        'S': SL.add(format('%%SW%d',[i]));

        't': SL.add(format('%%TM%d',[i]));
      end;
    end;
  end;

end;

function BitsToDWord(const bits: array of boolean): DWORD;
var i: integer;
begin
  result:=0;
  for i :=0 to min(high(bits),31) do begin
    if bits[i] then
      result:=result or DWORD(DWORD(1) shl i);
  end;
end;

procedure DWordToBits(var bits: array of boolean; dw: DWord);
var i: integer;
begin
  for i :=0 to min(high(bits),31) do begin
    bits[i]:= (dw and (DWORD(DWORD(1) shl i))) <> 0;
  end;
end;

procedure WordsToBits(var words_in: array of word; var bits_in_out: array of boolean);
var i: integer;
begin
  for i := 0 to min(high(words_in),high(bits_in_out)) do begin
    bits_in_out[i]:= (words_in[i div 16] and (1 shl i)) <> 0;
  end;
end;


procedure BitsToWords(const bits_in : array of boolean; var words_in_out: array of word);
var i: integer;
begin
  FillChar(words_in_out[0], Length(words_in_out), 0);
  for i := 0 to min((high(words_in_out)+1)*16-1,high(bits_in)) do begin
    words_in_out[i div 16] := words_in_out[i div 16] or (integer(bits_in[i]) shl (i mod 16));
  end;
end;


end.
