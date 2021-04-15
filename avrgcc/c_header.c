#define MaxInBits  48
#define MaxOutBits 48
#define MaxMemBits 128
#define MaxSysBits 128

#define MaxMemWords 128
#define MaxSysWords 128
#define MaxTimers   32

volatile unsigned char _InBits [MaxInBits];
volatile unsigned char _OutBits[MaxOutBits];
volatile unsigned char _MemBits[MaxMemBits];
volatile unsigned char _SysBits[MaxSysBits];

volatile unsigned int _MemWords[MaxMemWords];
volatile unsigned int _SysWords[MaxSysWords];


/*
type TTimerType = (TOn, TOffBad);

type
  TPLCTimerState = record
    V,P: integer;
    Q: boolean;
    Mode : TTimerType;
    Timebase_ms: Integer;
  end;

  
var _InBits:  array[0..MaxInBits-1] of boolean;
var _OutBits: array[0..MaxOutBits-1] of boolean;
var _MemBits: array[0..MaxMemBits-1] of boolean;
var _SysBits: array[0..MaxSysBits-1] of boolean;

var _MemWords: array[0..MaxMemWords-1] of integer;
var _SysWords: array[0..MaxSysWords-1] of integer;
var _Timers:   array[0..MaxTimers-1] of TPLCTimerState;

var _RE_InBits:  array[0..MaxInBits-1] of boolean;
var _FE_InBits:  array[0..MaxInBits-1] of boolean;
var _RE_OutBits: array[0..MaxOutBits-1] of boolean;
var _FE_OutBits: array[0..MaxOutBits-1] of boolean;
var _RE_MemBits: array[0..MaxMemBits-1] of boolean;
var _FE_MemBits: array[0..MaxMemBits-1] of boolean;
var _RE_SysBits: array[0..MaxSysBits-1] of boolean;
var _FE_SysBits: array[0..MaxSysBits-1] of boolean;

procedure __start_timer(i : integer);
begin
  _timers[i].v:=0;
  if _timers[i].mode=TOn then
    _timers[i].Q:=(_timers[i].V>=_timers[i].P)
  else
    _timers[i].Q:=(_timers[i].V<_timers[i].P);
end;

procedure _start_timer_0; begin  __start_timer(0);  end;
procedure _start_timer_1; begin  __start_timer(1);  end;
procedure _start_timer_2; begin  __start_timer(2);  end;
procedure _start_timer_3; begin  __start_timer(3);  end;
procedure _start_timer_4; begin  __start_timer(4);  end;
procedure _start_timer_5; begin  __start_timer(5);  end;
procedure _start_timer_6; begin  __start_timer(6);  end;
procedure _start_timer_7; begin  __start_timer(7);  end;
procedure _start_timer_8; begin  __start_timer(8);  end;
procedure _start_timer_9; begin  __start_timer(9);  end;

procedure _start_timer_10; begin  __start_timer(10);  end;
procedure _start_timer_11; begin  __start_timer(11);  end;
procedure _start_timer_12; begin  __start_timer(12);  end;
procedure _start_timer_13; begin  __start_timer(13);  end;
procedure _start_timer_14; begin  __start_timer(14);  end;
procedure _start_timer_15; begin  __start_timer(15);  end;
procedure _start_timer_16; begin  __start_timer(16);  end;
procedure _start_timer_17; begin  __start_timer(17);  end;
procedure _start_timer_18; begin  __start_timer(18);  end;
procedure _start_timer_19; begin  __start_timer(19);  end;

procedure _start_timer_20; begin  __start_timer(21);  end;
procedure _start_timer_21; begin  __start_timer(21);  end;
procedure _start_timer_22; begin  __start_timer(22);  end;
procedure _start_timer_23; begin  __start_timer(23);  end;
procedure _start_timer_24; begin  __start_timer(24);  end;
procedure _start_timer_25; begin  __start_timer(25);  end;
procedure _start_timer_26; begin  __start_timer(26);  end;
procedure _start_timer_27; begin  __start_timer(27);  end;
procedure _start_timer_28; begin  __start_timer(28);  end;
procedure _start_timer_29; begin  __start_timer(29);  end;

procedure _start_timer_30; begin  __start_timer(30);  end;
procedure _start_timer_31; begin  __start_timer(31);  end;


var _start_timers : array [0..MaxTimers-1] of procedure;

_start_timers[ 0]:=_start_timer_0;
_start_timers[ 1]:=_start_timer_1;
_start_timers[ 2]:=_start_timer_2;
_start_timers[ 3]:=_start_timer_3;
_start_timers[ 4]:=_start_timer_4;
_start_timers[ 5]:=_start_timer_5;
_start_timers[ 6]:=_start_timer_6;
_start_timers[ 7]:=_start_timer_7;
_start_timers[ 8]:=_start_timer_8;
_start_timers[ 9]:=_start_timer_9;

_start_timers[10]:=_start_timer_10;
_start_timers[11]:=_start_timer_11;
_start_timers[12]:=_start_timer_12;
_start_timers[13]:=_start_timer_13;
_start_timers[14]:=_start_timer_14;
_start_timers[15]:=_start_timer_15;
_start_timers[16]:=_start_timer_16;
_start_timers[17]:=_start_timer_17;
_start_timers[18]:=_start_timer_18;
_start_timers[19]:=_start_timer_19;

_start_timers[20]:=_start_timer_20;
_start_timers[21]:=_start_timer_21;
_start_timers[22]:=_start_timer_22;
_start_timers[23]:=_start_timer_23;
_start_timers[24]:=_start_timer_24;
_start_timers[25]:=_start_timer_25;
_start_timers[26]:=_start_timer_26;
_start_timers[27]:=_start_timer_27;
_start_timers[28]:=_start_timer_28;
_start_timers[29]:=_start_timer_29;

_start_timers[30]:=_start_timer_30;
_start_timers[31]:=_start_timer_31;

*/

unsigned char (*_InBitsFunc[MaxInBits])(void);

unsigned char _In00(void) { return(_InBits[0]); };
unsigned char _In01(void) { return(_InBits[1]); };
unsigned char _In02(void) { return(_InBits[2]); };
unsigned char _In03(void) { return(_InBits[3]); };
unsigned char _In04(void) { return(_InBits[4]); };
unsigned char _In05(void) { return(_InBits[5]); };
unsigned char _In06(void) { return(_InBits[6]); };
unsigned char _In07(void) { return(_InBits[7]); };
unsigned char _In08(void) { return(_InBits[8]); };
unsigned char _In09(void) { return(_InBits[9]); };

/*
function _In10 : boolean; begin result:=_InBits[10]; end;
function _In11 : boolean; begin result:=_InBits[11]; end;
function _In12 : boolean; begin result:=_InBits[12]; end;
function _In13 : boolean; begin result:=_InBits[13]; end;
function _In14 : boolean; begin result:=_InBits[14]; end;
function _In15 : boolean; begin result:=_InBits[15]; end;
function _In16 : boolean; begin result:=_InBits[16]; end;
function _In17 : boolean; begin result:=_InBits[17]; end;
function _In18 : boolean; begin result:=_InBits[18]; end;
function _In19 : boolean; begin result:=_InBits[19]; end;

function _In20 : boolean; begin result:=_InBits[20]; end;
function _In21 : boolean; begin result:=_InBits[21]; end;
function _In22 : boolean; begin result:=_InBits[22]; end;
function _In23 : boolean; begin result:=_InBits[23]; end;
function _In24 : boolean; begin result:=_InBits[24]; end;
function _In25 : boolean; begin result:=_InBits[25]; end;
function _In26 : boolean; begin result:=_InBits[26]; end;
function _In27 : boolean; begin result:=_InBits[27]; end;
function _In28 : boolean; begin result:=_InBits[28]; end;
function _In29 : boolean; begin result:=_InBits[29]; end;

function _In30 : boolean; begin result:=_InBits[30]; end;
function _In31 : boolean; begin result:=_InBits[31]; end;
function _In32 : boolean; begin result:=_InBits[32]; end;
function _In33 : boolean; begin result:=_InBits[33]; end;
function _In34 : boolean; begin result:=_InBits[34]; end;
function _In35 : boolean; begin result:=_InBits[35]; end;
function _In36 : boolean; begin result:=_InBits[36]; end;
function _In37 : boolean; begin result:=_InBits[37]; end;
function _In38 : boolean; begin result:=_InBits[38]; end;
function _In39 : boolean; begin result:=_InBits[39]; end;

function _In40 : boolean; begin result:=_InBits[40]; end;
function _In41 : boolean; begin result:=_InBits[41]; end;
function _In42 : boolean; begin result:=_InBits[42]; end;
function _In43 : boolean; begin result:=_InBits[43]; end;
function _In44 : boolean; begin result:=_InBits[44]; end;
function _In45 : boolean; begin result:=_InBits[45]; end;
function _In46 : boolean; begin result:=_InBits[46]; end;
function _In47 : boolean; begin result:=_InBits[47]; end;
*/













