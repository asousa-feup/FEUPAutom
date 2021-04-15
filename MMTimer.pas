unit MMTimer;
{$MODE Delphi}          

interface

uses
  {$IFDEF Windows}
    Windows,
  {$ENDIF}
  MMSystem, Sysutils, Messages, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

procedure CreateMMTimer(adelay_us: integer; aTarget_hwnd: HWND);
procedure DestroyMMTimer;


implementation

uses main;

{
  The timeSetEvent function starts a specified timer event.
  The multimedia timer runs in its own thread. After the event is activated,
  it calls the specified callback function or sets or pulses the spe
  cified event object.

  MMRESULT timeSetEvent(
  UINT           uDelay,
  UINT           uResolution,
  LPTIMECALLBACK lpTimeProc,
  DWORD_PTR      dwUser,
  UINT           fuEvent
  );

  uDelay:
   Event delay, in milliseconds

  uResolution:
   Resolution of the timer event, in milliseconds.
   A resolution of 0 indicates periodic events should occur with the
   greatest possible accuracy.
   You should use the use the maximum value appropriate to reduce system overhead.

  fuEvent:
   TIME_ONESHOT Event occurs once, after uDelay milliseconds.
   TIME_PERIODIC Event occurs every uDelay milliseconds.
}


//in;

var
  mmResult: Integer;
  Target_hwnd: HWND;


// callback function
procedure TimeCallBack(TimerID, Msg: Uint; dwUser, dw1, dw2: DWORD); pascal;
begin
  PostMessage(Target_hwnd,$8FFF{CM_EXECPROC}, 0,0);
  inc(FMain.ProgCyclesCount);
end;

// Set a new timer with a delay of 10 ms
procedure CreateMMTimer(adelay_us: integer; aTarget_hwnd: HWND);
begin

  if mmResult<>0 then
    raise Exception.Create('Cannot create second multimedia timer');

  Target_hwnd:=aTarget_hwnd;
  mmResult := TimeSetEvent(adelay_us, 0, @TimeCallBack, 0, TIME_PERIODIC);
end;


// Cancel the timer event.
procedure DestroyMMTimer;
begin
  TimeKillEvent(mmResult);
  mmResult:=0;
end;

initialization

mmResult:=0;

end.
