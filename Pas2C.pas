unit Pas2C;
{$MODE Delphi}          

interface

uses
  {$IFDEF Windows}
    Windows,
  {$ENDIF}
  StdCtrls, Forms, Classes, SysUtils, structuredtext2pas, Dialogs;




procedure Pas2CTranslateArrayInit(var Trans : TTranslations);
procedure Pas2CTranslateArrayInit2(var Trans : TTranslations);
procedure Pas2CTranslateArrayInit3(var Trans : TTranslations);

procedure RunDosInMemo(DosExe : String; DosParams:array of string; CurrentDir:String;AMemoStdOut,AMemoStdErr:TMemo);

implementation

uses process;

procedure Pas2CTranslateArrayInit(var Trans : TTranslations);
begin
  Trans.count:=0;                      // Obs: sequence is VERY IMPORTANT
  AddTranslation(Trans,'if','if(');
  AddTranslation(Trans,'end_for','}');
  AddTranslation(Trans,'end_while','}');
  AddTranslation(Trans,'end','}');
  AddTranslation(Trans,'end_if','}');
  AddTranslation(Trans,'else','} else {');
  AddTranslation(Trans,'elsif','} else if(');
  AddTranslation(Trans,'then',') {');
  AddTranslation(Trans,'(*','/*',True);
  AddTranslation(Trans,'*)','*/',True);
/////////////AJS_C_  AddTranslation(Trans,'set','_set_not_implemented_');
/////////////AJS_C_  AddTranslation(Trans,'reset','_reset_not_implemented_');
/////////////AJS_C_    AddTranslation(Trans,'rol','_rol_not_implemented_');
/////////////AJS_C_    AddTranslation(Trans,'ror','_ror_not_implemented_');
/////////////AJS_C_    AddTranslation(Trans,'inc','_inc_not_implemented_');
/////////////AJS_C_    AddTranslation(Trans,'dec','_dec_not_implemented_');

  GetAllVarNames(Trans);

  AddTranslation(Trans,'True', '1',True);
  AddTranslation(Trans,'False','0',True);
  AddTranslation(Trans,' and ', ' && ',True);
  AddTranslation(Trans,' or ',  ' || ',True);
  AddTranslation(Trans,':=',  '§§',True);
  AddTranslation(Trans,'>=',  '§>§',True);
  AddTranslation(Trans,'<=',  '§<§',True);
  AddTranslation(Trans,'not','!',True);

  AddTranslation(Trans,'RE','_RE',False,True);  // Must be after vars
  AddTranslation(Trans,'FE','_FE',False,True);
  AddTranslation(Trans,'start','_Start',False,True);

  AddTranslation(Trans,'(*','/*',False,True);
  AddTranslation(Trans,'*)','*/',False,True);

end;

procedure Pas2CTranslateArrayInit2(var Trans : TTranslations);
begin
  Trans.count:=0;                      // Obs: sequence is VERY IMPORTANT
  AddTranslation(Trans,'=',  '==',True);
end;


procedure Pas2CTranslateArrayInit3(var Trans : TTranslations);
begin
  Trans.count:=0;                      // Obs: sequence is VERY IMPORTANT
  AddTranslation(Trans,'§§',   '=', True);
  AddTranslation(Trans,'§>§',  '>=',True);
  AddTranslation(Trans,'§<§',  '<=',True);
end;




// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Start of RUN_DOS_IN_MEMO  stuff ...
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// http://wiki.freepascal.org/Executing_External_Programs#Reading_large_output
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


//////Possivelmente está certo mas espera pelo final...
////procedure RunDosInMemo(DosExe : String; DosParams:array of string; CurrentDir:String;AMemoStdOut,AMemoStdErr:TMemo);
////// http://wiki.freepascal.org/Executing_External_Programs#Reading_large_output
////// http://forum.lazarus.freepascal.org/index.php?topic=19643.0
////var i : integer;
////begin
////  AProcess := TProcess.Create(nil);
////  AProcess.CurrentDirectory:=CurrentDir;
////  AProcess.Executable := DosExe;
////  AProcess.ShowWindow := swoHIDE;
////  AProcess.Options :=  AProcess.Options + [poUsePipes, poWaitOnExit];
////  for i:=low(DosParams) to high(DosParams) do
////    AProcess.Parameters.Add(DosParams[i]);
////
////  sleep(1);
////  AProcess.Execute;
////  Sleep(50);
////
////  AMemoStdOut.Lines.LoadFromStream(AProcess.Output);
////  AMemoStdOut.Append('');
////
////  AMemoStdErr.Lines.LoadFromStream(AProcess.Stderr);
////  AMemoStdOut.Append('');
////
////  Sleep(50);
////
////  AProcess.Free;
////end;                     // ---- END_RUN_DOS_IN_MEMO


const
  BUF_SIZE = 2;//2048; // Buffer size for reading the output in chunks

var
  WeAreBusy : Boolean;


procedure RunDosInMemo(DosExe : String; DosParams:array of string; CurrentDir:String;AMemoStdOut,AMemoStdErr:TMemo);
// http://wiki.freepascal.org/Executing_External_Programs#Reading_large_output
var
  i : integer;
  s : string;
var
  AProcess     : TProcess;
  AOutStream   : TStream;
  AErrStream   : TStream;
  BytesReadOut : longint;
  BufferOut    : array[1..BUF_SIZE] of byte;
  BufferErr    : array[1..BUF_SIZE] of byte;
  FormWeAreBusy : TForm;
begin

  if WeAreBusy then begin
    FormWeAreBusy := CreateMessageDialog('Busy,Please Wait... Then Retry',mtinformation,[mbok]);
    FormWeAreBusy.Show;
    for i:=1 to 50 do begin
      Application.ProcessMessages();
      sleep(10);
    end;
    FormWeAreBusy.Hide;
    Application.ProcessMessages();
    FormWeAreBusy.Free;
    Application.ProcessMessages();
    exit;
  end;

  WeAreBusy := True;

  FillChar(BufferOut,Sizeof(BufferOut),#0) ;
  FillChar(BufferErr,Sizeof(BufferErr),#0) ;

  AProcess := TProcess.Create(nil);
  AProcess.CurrentDirectory:=CurrentDir;
  AProcess.Executable := DosExe;
  AProcess.ShowWindow := swoHIDE;
  AProcess.Options :=  AProcess.Options + [poUsePipes, poNewConsole, poStderrToOutPut];
  for i:=low(DosParams) to high(DosParams) do
    AProcess.Parameters.Add(DosParams[i]);

  // Create a stream object to store the generated output in. This could
  // also be a file stream to directly save the output to disk.
  AOutStream := TMemoryStream.Create;
  AErrStream := TMemoryStream.Create;

  Sleep(1);
  AProcess.Execute;
  Sleep(50);

  i:=0;
  repeat
    // Get the new data from the process to a maximum of the buffer size that was allocated.
    // Note that all read(...) calls will block except for the last one, which returns 0 (zero).
    BytesReadOut := AProcess.Output.Read(BufferOut, BUF_SIZE);
    if (BytesReadOut>0) then s := chr(BufferOut[1]);
    if (BytesReadOut>1) then s := s + chr(BufferOut[2]);
    if (i mod 5)=0 then     AMemoStdOut.Lines.BeginUpdate;
    if (BytesReadOut>0) then AMemoStdOut.Lines.Text := AMemoStdOut.Lines.Text + s;
    if (i mod 5)=4 then begin
      SendMessage(AMemoStdOut.Handle, WM_VSCROLL, SB_BOTTOM, 0);
      AMemoStdOut.Lines.EndUpdate;
      Application.ProcessMessages;
    end;
    inc(i);
  until (BytesReadOut=0) or (i>10000) ;  // Stop if no more data is available or iter_timeout
  SendMessage(AMemoStdOut.Handle, WM_VSCROLL, SB_BOTTOM, 0);
  AMemoStdOut.Lines.EndUpdate;
  SendMessage(AMemoStdOut.Handle, WM_VSCROLL, SB_BOTTOM, 0);

  Sleep(1);
  AProcess.Free;
  WeAreBusy := False;


  ////AOutStream.Position := 0; // Required to make sure all data is copied from the start
  ////AMemoStdOut.Lines.LoadFromStream(AOutStream);
  //////AMemoStdOut.Append(AMemoStdOut.Text);
  ////AMemoStdOut.Append('');
  ////AMemoStdOut.Append('--- Number of Chars = ' + IntToStr(AOutStream.Position) + '  ----');
  ////AMemoStdOut.Append(DosExe);
  ////for i:=0 to high(DosParams) do AMemoStdOut.Append(DosParams[i]);
  ////
  ////AErrStream.Position := 0; // Required to make sure all data is copied from the start
  ////AMemoStdErr.Lines.LoadFromStream(AErrStream);
  //////AMemoStdErr.Append(AMemoStdErr.Text);
  ////AMemoStdOut.Append('');
  ////AMemoStdErr.Append('--- Number of Chars = ' + IntToStr(AErrStream.Position) + '  ----');

  // Clean up
  AOutStream.Free;
  AErrStream.Free;
end;                     // ---- END_RUN_DOS_IN_MEMO



(*


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// From:
// http://delphi.about.com/cs/adptips2001/a/bltip0201_2.htm
// http://stackoverflow.com/questions/16225025/pipes-in-delphi-for-command-prompt


function ReadPipeInput(InputPipe: THandle; var BytesRem: Integer): String;
{
  reads console output from InputPipe.  Returns the input in function
  result.  Returns bytes of remaining information to BytesRem
}
var
  TextBuffer: array[1..32767] of AnsiChar;// char;  // was 1..32767
  TextString: String;
  BytesRead: Cardinal;
  PipeSize: Integer;
begin
  Result := '';
  PipeSize := length(TextBuffer);
  FillChar(TextBuffer,Sizeof(TextBuffer),#0) ;

  // check if there is something to read in pipe
  PeekNamedPipe(InputPipe, nil, PipeSize, @BytesRead, @PipeSize, @BytesRem);
  ReadFile(InputPipe, TextBuffer, pipesize, bytesread, nil);
  if bytesread > 0 then begin
      //FileRead(InputPipe); //Converted from ReadFile
      //ReadFile(InputPipe, TextBuffer, pipesize, bytesread, nil);// a requirement for Windows OS system components
      OemToChar(@TextBuffer, @TextBuffer);
      TextString := String(TextBuffer);
      SetLength(TextString, BytesRead);
      Result := TextString;
    end;
end;


procedure _OLD_RunDosInMemo(DosApp:String;AMemoStdOut,AMemoStdErr:TMemo);
const
  ReadBuffer = 32767;
var
  Security : TSecurityAttributes;
  H_ReadPipe, H_WritePipe, H_ErrReadPipe, H_ErrWritePipe: THandle;
  start : TStartUpInfo;
  ProcessInfo : TProcessInformation;
  Buffer : Pchar;
  Apprunning : DWord;
  cnt, leftover : integer;
begin
  With Security do begin
    nlength := SizeOf(TSecurityAttributes) ;
    binherithandle := true;
    lpsecuritydescriptor := nil;
  end;
  if not Createpipe (H_ReadPipe, H_WritePipe, @Security, 0) then begin
    AMemoStdErr.Lines.Append('Error Pipe Create 1 ... exiting...');
    exit;
  end else
  //if not CreatePipe (H_ErrReadPipe, H_ErrWritePipe, @Security, 0) then begin
  if not CreatePipe (H_ErrReadPipe, H_ErrWritePipe, @Security, 0) then begin
    AMemoStdErr.Lines.Append('Error Pipe Create 2 ... exiting...');
    exit;
  end else begin
    Buffer := AllocMem(ReadBuffer + 1) ;
    FillChar(Buffer,Sizeof(Buffer),#0) ;
    FillChar(Start,Sizeof(Start),#0) ;
    start.cb := SizeOf(start) ;
    start.hStdOutput := H_WritePipe;
    start.hStdError := H_ErrWritePipe;
//    start.hStdError := H_ErrReadPipe;  /// que fazer ao  H_ErrReadPipe; ????????
    start.hStdInput := H_ReadPipe;
    start.dwFlags := STARTF_USESTDHANDLES +
                        STARTF_USESHOWWINDOW;
    start.wShowWindow := SW_HIDE;

    if not CreateProcess(nil,
           PChar(DosApp),
           @Security,
           @Security,
           true,
           NORMAL_PRIORITY_CLASS,
           nil,
           nil, { TODO: Pôr aqui o drive default, vendo se win se linux }
           start,
           ProcessInfo)
    then  begin
      AMemoStdErr.Lines.Append('Error 3 ... exiting...');
      exit;
    end else begin
      cnt:=0;
      Repeat
        Application.ProcessMessages;
        Apprunning := WaitForSingleObject(ProcessInfo.hProcess,100) ;
        Application.ProcessMessages;
        //Application.HandleMessages;  // Allows idle
        cnt:=cnt+1;

        AMemoStdOut.Text:=AMemoStdOut.Text+ReadPipeInput(H_ReadPipe,leftover);
        AMemoStdErr.Text:=AMemoStdErr.Text+ReadPipeInput(H_ErrReadPipe,leftover);
        SendMessage(AMemoStdOut.Handle, WM_VSCROLL, SB_BOTTOM, 0);
        SendMessage(AMemoStdErr.Handle, WM_VSCROLL, SB_BOTTOM, 0);

      until (Apprunning <> WAIT_TIMEOUT) or (cnt>200) ;

    end;
    FreeMem(Buffer) ;
    FileClose(ProcessInfo.hProcess); { *Converted from CloseHandle* }
    FileClose(ProcessInfo.hThread); { *Converted from CloseHandle* }
    FileClose(H_ReadPipe); { *Converted from CloseHandle* }
    FileClose(H_WritePipe); { *Converted from CloseHandle* }
    FileClose(H_ErrReadPipe); { *Converted from CloseHandle* }
    FileClose(H_ErrWritePipe); { *Converted from CloseHandle* }
    SendMessage(AMemoStdOut.Handle, WM_VSCROLL, SB_BOTTOM, 0);
    SendMessage(AMemoStdErr.Handle, WM_VSCROLL, SB_BOTTOM, 0);
  end;
end;

*)


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

{
procedure ScrollToEnd(ARichEdit: TRichEdit);
var
  isSelectionHidden: Boolean;
begin
  with ARichEdit do
  begin
    SelStart := Perform( EM_LINEINDEX, Lines.Count, 0);//Set caret at end
    isSelectionHidden := HideSelection;
    try
      HideSelection := False;
      Perform( EM_SCROLLCARET, 0, 0);  // Scroll to caret
    finally
      HideSelection := isSelectionHidden;
    end;
  end;
end;
}


end.
