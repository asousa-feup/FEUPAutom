///////////// ST_Header - FEUPAutom 2018 02 27   ///////////////////



const MaxInBits  = 48;
const MaxOutBits = 48;
const MaxMemBits = 128;
const MaxSysBits = 128;

const MaxMemWords = 128;
const MaxSysWords = 128;
const MaxTimers   = 32;


procedure __start_timer(i : integer);
begin
 _timers[i].v := 0;
 _timers[i].Q := (_timers[i].V >= _timers[i].P);
 //writes('St T');writei(i);
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

procedure _start_timer_20; begin  __start_timer(20);  end;
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

//procedure initialize;
begin
//start_timers start_timers
_start_timers[ 0] := @_start_timer_0;
_start_timers[ 1] := @_start_timer_1;
_start_timers[ 2] := @_start_timer_2;
_start_timers[ 3] := @_start_timer_3;
_start_timers[ 4] := @_start_timer_4;
_start_timers[ 5] := @_start_timer_5;
_start_timers[ 6] := @_start_timer_6;
_start_timers[ 7] := @_start_timer_7;
_start_timers[ 8] := @_start_timer_8;
_start_timers[ 9] := @_start_timer_9;

_start_timers[10] := @_start_timer_10;
_start_timers[11] := @_start_timer_11;
_start_timers[12] := @_start_timer_12;
_start_timers[13] := @_start_timer_13;
_start_timers[14] := @_start_timer_14;
_start_timers[15] := @_start_timer_15;
_start_timers[16] := @_start_timer_16;
_start_timers[17] := @_start_timer_17;
_start_timers[18] := @_start_timer_18;
_start_timers[19] := @_start_timer_19;

_start_timers[20] := @_start_timer_20;
_start_timers[21] := @_start_timer_21;
_start_timers[22] := @_start_timer_22;
_start_timers[23] := @_start_timer_23;
_start_timers[24] := @_start_timer_24;
_start_timers[25] := @_start_timer_25;
_start_timers[26] := @_start_timer_26;
_start_timers[27] := @_start_timer_27;
_start_timers[28] := @_start_timer_28;
_start_timers[29] := @_start_timer_29;

_start_timers[30] := @_start_timer_30;
_start_timers[31] := @_start_timer_31;
//end;



