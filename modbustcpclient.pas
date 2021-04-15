unit modbustcpclient;

{$MODE Delphi}

interface


const
  ModBusBits = $10000;

type
  TModbusState = (mbsIdle, mbsHeader, msbLen, msbUnitId, msbFunctionCode,
                  msbBytesNum, msbBytes, msbError);

  TModbusEvent = procedure(command: byte) of object;

  TModbusFrame = record
    TransactionIdentifier: integer;  // 2 bytes - For synchronization between messages of server & client
    ProtocolIdentifier: integer;     // 2 bytes - Zero for Modbus/TCP
    LengthField: word;            // 2 bytes - Number of remaining bytes in this frame
    UnitIdentifier: byte;         // 1 byte - Slave Address (255 if not used)
    FunctionCode: byte;           // 1 byte - Function codes as in other variants
    BytesNum: byte;
    Address: word;
    Num: word;
  end;

  { TModbus }

  TModbus = class
    Inputs: array[0..ModBusBits - 1] of boolean;
    Coils: array[0..ModBusBits - 1] of boolean;
    msg: RawByteString;
    Frame: TModbusFrame;

    State: TModbusState;
    byteCount: integer;

    curTransactionIdentifier: word;
    //pending: integer;
    reqStartAddress, reqCount: word;

    ReceivedMessagesCount: integer;
    OnReceiveEvent: TModbusEvent;
  private
  public
    function BigEndianWord(bytes: word): RawByteString;

    procedure MessageStateMachine(mess: RawByteString);

    constructor Create(newReceiveEvent: TModbusEvent = nil);
    destructor Destroy; override;

    function WriteMultipleCoils(UnitId: byte; StartAddress, Count: word): RawByteString;
    function RequestReadMultiple(UnitId: byte; StartAddress, CoilCount: word
      ): RawByteString;

    function getByteWith8Coils(coilAddr: integer): byte;
    procedure write8Coils(coilAddr: integer; eightCoils: byte);
  end;


implementation

uses SysUtils, main, math;

{ TModbus }

// Receive State Machine
//  State = (mbsIdle, mbsHeader, msbLen, msbUnitId, msbFunctionCode,
//           msbBytesNum, msbBytes, msbError);

procedure TModbus.MessageStateMachine(mess: RawByteString);
var b: integer;
    i, len, ibit, bitIdx, value: integer;
begin

  if mess = '' then exit;
  msg := msg + mess;
  if Length(msg)<5 then exit;

  len := length(msg);

  //while not (msg = '') do begin

  for i := 1 to len do begin
    b := ord(msg[i]);
    case State of
      mbsIdle: begin
        if b = $B1 then begin
          State := mbsHeader;
          byteCount := 1;
          Frame.TransactionIdentifier := $B1 shl 8;
        end;
      end;

      mbsHeader: begin     // B1 6E 00 00
        if (byteCount = 1) and (b = $6E) then begin
          Frame.TransactionIdentifier := Frame.TransactionIdentifier or $6E;
          inc(byteCount);
        end else if (byteCount = 2) and (b = 0) then begin
          Frame.ProtocolIdentifier := 0;
          inc(byteCount);
        end else if (byteCount = 3) and (b = 0) then begin
          Frame.ProtocolIdentifier := 0;
          State := msbLen;
          byteCount := 0;
        end else begin   // There was an error: resync
          State := mbsIdle;
          Frame.TransactionIdentifier := -1;
          continue;
        end;
      end;

      msbLen: begin
        if (byteCount = 0) then begin
          Frame.LengthField := b shl 8;
          inc(byteCount);
        end else if (byteCount = 1) then begin
          Frame.LengthField := Frame.LengthField or b;
          State := msbUnitId;
        end;
      end;

      msbUnitId: begin
        Frame.UnitIdentifier := b;
        State := msbFunctionCode;
      end;

      msbFunctionCode: begin
        Frame.FunctionCode := b;
        // MB Func     02 Read InpBits    and     01 Read Coils
        if (Frame.FunctionCode = $02) or (Frame.FunctionCode = $01) then begin        // AJS 2020
          State := msbBytesNum;
          byteCount := 0;
        end else begin  // Unrecognized Function Code: Resync
          State := mbsIdle;
          Frame.TransactionIdentifier := -1;
          continue;
        end;
      end;

      msbBytesNum: begin
        Frame.BytesNum := b;
        State := msbBytes;
        byteCount := 0;
      end;

      msbBytes: begin
        ibit := byteCount * 8;
        for bitIdx := 0 to 7 do begin
          value := b and (1 shl bitIdx);
          Coils[reqStartAddress + ibit + bitIdx] := value <> 0;
        end;
        if assigned(OnReceiveEvent) then OnReceiveEvent(1);

        CopyFromCoilsToInputs(Coils);   // AJS 201905

        if byteCount + 1 >= Frame.BytesNum  then begin  // All bytes read: Resync
          inc(ReceivedMessagesCount);
          State := mbsIdle;
          Frame.TransactionIdentifier := -1;
          continue;
        end;
        inc(byteCount);
      end;

      //msbItemAddress: begin
      //  if (byteCount = 0) then begin
      //    Frame.LengthField := b shl 8;
      //    inc(byteCount);
      //  end else if (byteCount = 1) then begin
      //    Frame.LengthField := Frame.LengthField or b;
      //    State := msbUnitId;
      //  end;
      //end;
    end;
  end;

  msg := '';
end;


constructor TModbus.Create(newReceiveEvent: TModbusEvent);
begin
  msg := '';
  curTransactionIdentifier := $B16E;

  State := mbsIdle;
  OnReceiveEvent := newReceiveEvent;

  Frame.ProtocolIdentifier := -1; //Bad Frame, for now
  Frame.LengthField := 0;
end;

destructor TModbus.Destroy;
begin

  inherited;
end;

function TModbus.BigEndianWord(bytes: word): RawByteString;
begin
  result := chr(bytes div 256) + chr(bytes mod 256);
end;

function TModbus.WriteMultipleCoils(UnitId: byte; StartAddress, Count: word): RawByteString;
var coilbits: array of byte;
    payloadCount, i, ibyte, ibit: integer;
begin
  //payloadCount := (1 + count div 8);
    payloadCount := ceil( count / 8);

  //inc(curTransactionIdentifier);  /////// TO DO LATER!!!!!!!!!!!!!
  result := BigEndianWord(curTransactionIdentifier) +
            BigEndianWord(0) +
            BigEndianWord(1 + 1 + 2 + 2 + 1 + payloadCount) +
            chr(UnitId) +
            chr(15) +
            BigEndianWord(StartAddress) +
            BigEndianWord(Count) +
            chr(payloadCount);

  SetLength(coilbits, payloadCount);
  for i := 0 to payloadCount - 1 do begin
    coilbits[i] := 0;
  end;

  for i := 0 to Count - 1 do begin
    ibyte := i div 8;
    ibit := i mod 8;
    if Coils[StartAddress + i] then begin
      coilbits[ibyte] := coilbits[ibyte] or (1 shl ibit);
    end;
  end;

  for i := 0 to payloadCount - 1 do begin
    result := result + chr(coilbits[i]);
  end;

end;

// Good Reference page:
// https://ipc2u.com/articles/knowledge-base/detailed-description-of-the-modbus-tcp-protocol-with-command-examples/

function TModbus.RequestReadMultiple(UnitId: byte; StartAddress, CoilCount: word): RawByteString;
begin
  reqStartAddress := StartAddress;
  reqCount := CoilCount;
  result := BigEndianWord(curTransactionIdentifier) +
            BigEndianWord(0) +                               // Protocol Identifier  // AJS 2020
            BigEndianWord(1 + 1 + 2 + 2) +
            chr(UnitId) +
            chr(02) +                                        // Function Code        // AJS 2020 MB Func 02 Read Bits
            BigEndianWord(reqStartAddress) +
            BigEndianWord(reqCount);
end;



function TModbus.getByteWith8Coils(coilAddr: integer): byte;
var i: integer;
begin
  result := 0;
  for i := 0 to 7 do begin
    if Coils[coilAddr + i] then result := result or (1 shl i);
  end;
end;


procedure TModbus.write8Coils(coilAddr: integer; eightCoils: byte);
var i: integer;
begin
  for i := 0 to 7 do begin
    Coils[coilAddr + i] := (eightCoils and (1 shl i)) <> 0;
  end;
end;


end.
