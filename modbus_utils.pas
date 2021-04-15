unit Modbus_Utils;
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,main,Forms;


// Define constants for the ModBus functions
const
  mbfReadCoils = $01;
  mbfReadInputBits = $02;
  mbfReadHoldingRegs = $03;
  mbfReadInputRegs = $04;
  mbfWriteOneCoil = $05;
  mbfWriteOneReg = $06;
  mbfWriteCoils = $0F;
  mbfWriteRegs = $10;
  mbfReadFileRecord = $14;
  mbfWriteFileRecord = $15;
  mbfMaskWriteReg = $16;
  mbfReadWriteRegs = $17;
  mbfReadFiFoQueue = $18;
  MB_PROTOCOL = 0;
  FUnitID=1;  // SlaveID
  //FTimeOut = 15000;
  FTimeOut = 250;

type
  TIdBytes = array of Byte;

type
  TModBusFunction = Byte;

type
  TModBusDataBuffer = array[0..260] of Byte;

type
  TModBusHeader = packed record
    TransactionID: Word;
    ProtocolID: Word;
    RecLength: Word;
    UnitID: Byte;
  end;

type
  TModBusRequestBuffer = packed record
    Header: TModBusHeader;
    FunctionCode: TModBusFunction;
    MBPData: TModBusDataBuffer;
  end;

//##############################################################################
//111111111111111111111111111111111111111111111111111111111111111111111111111111
//##############################################################################
function GetNewTransactionID: Word;
function RawToBytes(const AValue; const ASize: Integer): TIdBytes;
function Swap16(const DataToSwap: Word): Word;

//##############################################################################
//222222222222222222222222222222222222222222222222222222222222222222222222222222
//##############################################################################
procedure GetCoilsFromBuffer(const Buffer: PByte; const Count: Word; var Data: array of Word);
procedure PutCoilsIntoBuffer(const Buffer: PByte; const Count: Word; const Data: array of Word);
procedure GetRegistersFromBuffer(const Buffer: PWord; const Count: Word; var Data: array of Word);
procedure PutRegistersIntoBuffer(const Buffer: PWord; const Count: Word; const Data: array of Word);

//##############################################################################
//333333333333333333333333333333333333333333333333333333333333333333333333333333
//##############################################################################
//MBSendCommand
function MBSendCommand(const AModBusFunction: TModBusFunction;  const ARegNumber: Word; const ABlockLength: Word; var Data: array of Word):Boolean;
//MBWriteCoils  //MBWriteRegisters   //MBReadCoils
function MBWriteCoils(const RegNo, Blocks: Word; const RegisterData: array of Boolean): Boolean;
function MBWriteRegisters(const RegNo: Word;  const RegisterData: array of Word): Boolean;
function MBReadCoils(const RegNo, Blocks: Word; out RegisterData: array of Boolean): Boolean;
function MBReadInputBits(const RegNo, Blocks: Word;  out RegisterData: array of Boolean): Boolean;
function MBReadHoldingRegisters(const RegNo, Blocks: Word;  out RegisterData: array of Word): Boolean;

//VARs
var
  LastTransactionID: Word=0; //MB_TAG

implementation


//##############################################################################
//111111111111111111111111111111111111111111111111111111111111111111111111111111
//##############################################################################
function RawToBytes(const AValue; const ASize: Integer): TIdBytes;
begin
  SetLength(Result, ASize);
  Move(AValue, Result[0], ASize);
end;

function GetNewTransactionID: Word;
begin
  if (LastTransactionID = $FFFF) then
    LastTransactionID := 0
  else
    Inc(LastTransactionID);
  Result := LastTransactionID;
end;

function Swap16(const DataToSwap: Word): Word;
begin
  Result := (DataToSwap div 256) + ((DataToSwap mod 256)*256);
end;

//##############################################################################
//222222222222222222222222222222222222222222222222222222222222222222222222222222
//##############################################################################
procedure GetCoilsFromBuffer(const Buffer: PByte; const Count: Word; var Data: array of Word);
var
  BytePtr: PByte;
  BitMask: Byte;
  i: Integer;
begin
  BytePtr := Buffer;
  BitMask := 1;

  for i := 0 to (Count - 1) do
  begin
    if (i < Length(Data)) then
    begin
      if ((BytePtr^ and BitMask) <> 0) then
        Data[i] := 1
      else
        Data[i] := 0;
      if (BitMask = $80) then
      begin
        BitMask := 1;
        Inc(BytePtr);
      end
      else
        BitMask := (Bitmask shl 1);
    end;
  end;
end;

procedure PutCoilsIntoBuffer(const Buffer: PByte; const Count: Word; const Data: array of Word);
var
  BytePtr: PByte;
  BitMask: Byte;
  i: Word;
begin
  BytePtr := Buffer;
  BitMask := 1;
  for i := 0 to (Count - 1) do
  begin
    if (i < Length(Data)) then
    begin
      if (BitMask = 1) then
        BytePtr^ := 0;
      if (Data[i] <> 0) then
        BytePtr^ := BytePtr^ or BitMask;
      if (BitMask = $80) then
      begin
        BitMask := 1;
        Inc(BytePtr);
      end
      else
        BitMask := (Bitmask shl 1);
    end;
  end;
end;

procedure GetRegistersFromBuffer(const Buffer: PWord; const Count: Word; var Data: array of Word);
var
  WPtr: PWord;
  i: Word;
begin
  WPtr := Buffer;

  for i := 0 to (Count - 1) do
  begin
    Data[i] := Swap16(WPtr^);
    Inc(WPtr);
  end;
end;

procedure PutRegistersIntoBuffer(const Buffer: PWord; const Count: Word; const Data: array of Word);
var
  WordPtr: PWord;
  i: Word;
begin
  WordPtr := Buffer;
  for i := 0 to (Count - 1) do
  begin
    WordPtr^ := Swap16(Data[i]);
    Inc(WordPtr);
  end;
end;

//##############################################################################
//333333333333333333333333333333333333333333333333333333333333333333333333333333
//##############################################################################
//MBSendCommand
function MBSendCommand(const AModBusFunction: TModBusFunction; const ARegNumber: Word; const ABlockLength: Word; var Data: array of Word):Boolean;
var
    i: Integer;
    SendBuffer: TModBusRequestBuffer;
    ReceiveBuffer: TModBusRequestBuffer;
    BlockLength: Word;
    RegNumber: Word;
    dtTimeOut: TDateTime;
    Buffer: TIdBytes;
    RecBuffer: TIdBytes;

    //tempByte:byte;
    msgOut:string='';
    msgIn:string='';
    //msgRecomposta:string='';
begin
    SendBuffer.Header.TransactionID := GetNewTransactionID;
    SendBuffer.Header.ProtocolID := MB_PROTOCOL;
    RegNumber := ARegNumber - 1;
    case AModBusFunction of
      mbfReadCoils,
      mbfReadInputBits:
        begin
          BlockLength := ABlockLength;
        { Don't exceed max length }
          if (BlockLength > 250) then
            BlockLength := 250;
        { Initialise the data part }
          SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
          SendBuffer.Header.UnitID := FUnitID;
          SendBuffer.MBPData[0] := Hi(RegNumber);
          SendBuffer.MBPData[1] := Lo(RegNumber);
          SendBuffer.MBPData[2] := Hi(BlockLength);
          SendBuffer.MBPData[3] := Lo(BlockLength);
          SendBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
        end;
      mbfReadHoldingRegs,
      mbfReadInputRegs:
        begin
          BlockLength := ABlockLength;
          if (BlockLength > 125) then
            BlockLength := 125; { Don't exceed max length }
        { Initialise the data part }
          SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
          SendBuffer.Header.UnitID := FUnitID;
          SendBuffer.MBPData[0] := Hi(RegNumber);
          SendBuffer.MBPData[1] := Lo(RegNumber);
          SendBuffer.MBPData[2] := Hi(BlockLength);
          SendBuffer.MBPData[3] := Lo(BlockLength);
          SendBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
        end;
     mbfWriteOneCoil:
        begin
        { Initialise the data part }
          SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
          SendBuffer.Header.UnitID := FUnitID;
          SendBuffer.MBPData[0] := Hi(RegNumber);
          SendBuffer.MBPData[1] := Lo(RegNumber);
          if (Data[0] <> 0) then
            SendBuffer.MBPData[2] := 255
          else
            SendBuffer.MBPData[2] := 0;
          SendBuffer.MBPData[3] := 0;
          SendBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
        end;
      mbfWriteOneReg:
        begin
        { Initialise the data part }
          SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
          SendBuffer.Header.UnitID := FUnitID;
          SendBuffer.MBPData[0] := Hi(RegNumber);
          SendBuffer.MBPData[1] := Lo(RegNumber);
          SendBuffer.MBPData[2] := Hi(Data[0]);
          SendBuffer.MBPData[3] := Lo(Data[0]);
          SendBuffer.Header.RecLength := Swap16(6); { This includes UnitID/FuntionCode }
        end;
      mbfWriteCoils:
        begin
          BlockLength := ABlockLength;
        { Don't exceed max length }
          if (BlockLength > 250) then
            BlockLength := 250;
        { Initialise the data part }
          SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
          SendBuffer.Header.UnitID := FUnitID;
          SendBuffer.MBPData[0] := Hi(RegNumber);
          SendBuffer.MBPData[1] := Lo(RegNumber);
          SendBuffer.MBPData[2] := Hi(BlockLength);
          SendBuffer.MBPData[3] := Lo(BlockLength);
          SendBuffer.MBPData[4] := Byte((BlockLength + 7) div 8);
          PutCoilsIntoBuffer(@SendBuffer.MBPData[5], BlockLength, Data);
          SendBuffer.Header.RecLength := Swap16(7 + SendBuffer.MBPData[4]);
        end;
      mbfWriteRegs:
        begin
          BlockLength := ABlockLength;
        { Don't exceed max length }
          if (BlockLength > 250) then
            BlockLength := 250;
        { Initialise the data part }
          SendBuffer.FunctionCode := Byte(AModBusFunction); { Write appropriate function code }
          SendBuffer.Header.UnitID := FUnitID;
          SendBuffer.MBPData[0] := Hi(RegNumber);
          SendBuffer.MBPData[1] := Lo(RegNumber);
          SendBuffer.MBPData[2] := Hi(BlockLength);
          SendBuffer.MBPData[3] := Lo(BlockLength);
          SendBuffer.MbpData[4] := Byte(BlockLength shl 1);
          PutRegistersIntoBuffer(@SendBuffer.MBPData[5], BlockLength, Data);
          SendBuffer.Header.RecLength := Swap16(7 + SendBuffer.MbpData[4]);
        end;
    end;

    Buffer := RawToBytes(SendBuffer, Swap16(SendBuffer.Header.RecLength) + 6);
    for i := Low(Buffer) to High(Buffer) do begin
      msgOut:=msgOut+Chr(Buffer[i]);
    end;

    //SEND MODBUS MSG
    FMain.TCP_Conn.SendMessage(msgOut);


    // AJS 201905 Tentar não esperar pela resposta mas não funciona
    //Application.ProcessMessages;
    //result:=false;
    //exit;

    //Wait for response:
    if (FTimeOut > 0) then begin
      dtTimeOut := Now + (FTimeOut / 86400000);

      while (Length(Fmain.stringRec)=0) do begin
      Application.ProcessMessages;
        if (Now > dtTimeOut) then begin
           Result := False;
          Exit;
        end;
      end;
    end;

(* Sem esperar:
    //WAIT FOR REPLY
    FMain.refreshMB;
    sleep(2);         // Ver melhor depois
    FMain.refreshMB;
    //Wait for response:
    if (FTimeOut > 0) then begin
      dtTimeOut := Now + (FTimeOut / 86400000);
      FMain.refreshMB;
      if (Length(Fmain.stringRec)=0) then begin
        Result := False;
        Fmain.stringRec:='';
        Exit;
      end;
    end;
   msgIn:=Fmain.stringRec;
   //Fmain.stringRec:='';
*)

   msgIn:=Fmain.stringRec;
   Fmain.stringRec:='';
   SetLength(RecBuffer, Length(msgIn));
   for i := 1 to Length(msgIn) do begin
     //msgRecomposta:= msgRecomposta+IntToStr(Ord(copy(msgIn,i,1)[1]))+ ' ';
     RecBuffer[i-1]:=Ord(copy(msgIn,i,1)[1]);
   end;

  Move(RecBuffer[0], ReceiveBuffer, Length(msgIn));
   { Check if the result has the same function code as the request }
  if (AModBusFunction = ReceiveBuffer.FunctionCode) then begin
    case AModBusFunction of
      mbfReadCoils,
      mbfReadInputBits:
        begin
          BlockLength := ReceiveBuffer.MBPData[0] * 8;
          if (BlockLength > 250) then
            BlockLength := 250;
          GetCoilsFromBuffer(@ReceiveBuffer.MBPData[1], BlockLength, Data);
        end;
      mbfReadHoldingRegs,
      mbfReadInputRegs:
        begin
          BlockLength := (ReceiveBuffer.MBPData[0] shr 1);
          if (BlockLength > 125) then
            BlockLength := 125;
          GetRegistersFromBuffer(@ReceiveBuffer.MBPData[1], BlockLength, Data);
        end;
    end;
  end;
    Result:=true;
end;

//WriteCoils
function MBWriteCoils(const RegNo, Blocks: Word; const RegisterData: array of Boolean): Boolean;
var
  i: Integer;
  iBlockLength: Integer;
  Data: array of Word;
begin
  iBlockLength := High(RegisterData) - Low(RegisterData) + 1;
  try
    SetLength(Data, Length(RegisterData));
    for i := Low(RegisterData) to High(RegisterData) do
    begin
      if RegisterData[i] then
        Data[i] := 1
      else
        Data[i] := 0;
    end;
    Result := MBSendCommand(mbfWriteCoils, RegNo, iBlockLength, Data);
  finally
    //exit;
  end;
end;

//MBWriteRegisters
function MBWriteRegisters(const RegNo: Word;  const RegisterData: array of Word): Boolean;
var
  i: Integer;
  iBlockLength: Integer;
  Data: array of Word;
begin
  iBlockLength := High(RegisterData) - Low(RegisterData) + 1;
  try
    SetLength(Data, Length(RegisterData));
    for i := Low(RegisterData) to High(RegisterData) do
      Data[i] := RegisterData[i];
    Result := MBSendCommand(mbfWriteRegs, RegNo, iBlockLength, Data);
  finally
    //exit;
  end;
end;

//MBReadCoils
function MBReadCoils(const RegNo, Blocks: Word; out RegisterData: array of Boolean): Boolean;
var
  i: Integer;
  Data: array of Word;
begin
  SetLength(Data, Blocks);
  FillChar(Data[0], Length(Data), 0);
  try
    Result := MBSendCommand(mbfReadCoils, RegNo, Blocks, Data);
    for i := 0 to (Blocks - 1) do
      RegisterData[i] := (Data[i] = 1);
  finally
    //exit;
  end;
end;

//MBReadInputBits
function MBReadInputBits(const RegNo, Blocks: Word;  out RegisterData: array of Boolean): Boolean;
var
  i: Integer;
  Data: array of Word;
begin
  SetLength(Data, Blocks);
  FillChar(Data[0], Length(Data), 0);
  try
    Result := MBSendCommand(mbfReadInputBits, RegNo, Blocks, Data);
    for i := 0 to (Blocks - 1) do
      RegisterData[i] := (Data[i] = 1);
  finally
    //exit;
  end;
end;

//MBReadHoldingRegisters
function MBReadHoldingRegisters(const RegNo, Blocks: Word;  out RegisterData: array of Word): Boolean;
var
  i: Integer;
  Data: array of Word;
begin
  try
    SetLength(Data, Blocks);
    FillChar(Data[0], Length(Data), 0);
    Result := MBSendCommand(mbfReadHoldingRegs, RegNo, Blocks, Data);
    for i := Low(Data) to High(Data) do
      RegisterData[i] := Data[i];
  finally
    //exit;
  end;
end;



end.

