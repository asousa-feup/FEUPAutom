unit ProjManage;
{$mode objfpc}{$H+}

interface

uses Forms, Classes, SysUtils, IniFiles, Dialogs,

  //XML (by BrunoAugusto)
  laz2_DOM, laz2_XMLRead, laz2_XMLWrite, laz2_XMLUtils ;

type
  TProjectConfig = record
    FileName : string;
    Modified: boolean; // Always compile
    //ChangedSinceCompile: boolean; // Always compile !
    Author: string;
    Comments: string;
    Grafcet : boolean;
    Gen_C_Code : boolean;
    MBNRead, MBNWrite : integer;
    MBIP: string;
    MBPort, MBOffs_I, MBOffs_O, MBFunc, Period : integer;
    ModBus, WinMsg : boolean;
  end;


var Project: TProjectConfig;

procedure ProjectNew;
function  ProjectOpen(aFileName: string):boolean;
function  ProjectOpenFA5(aFileName: string; ImportGr7Page3Mode : boolean = FALSE) : boolean;
function  ProjectSaveFA5(aFileName: string):boolean;

procedure QuoteSTTextInIniFile(aFileName: string);
procedure SaveStringsToMemIni( MemIni: TMemIniFile; section, Ident: string; SL: TStrings);
procedure LoadStringsFromMemIni( MemIni: TMemIniFile; section, Ident: string; SL: TStrings);
procedure SaveFormGeometryToMemIni( MemIni: TMemIniFile; const aForm: TForm);
procedure LoadFormGeometryFromMemIni( MemIni: TMemIniFile; aForm: TForm);


implementation

uses Main,Variables,IOLeds, G7Draw,Logger, StructuredTextUtils, SelfGrade, Windows;

  //\\    //\\    //\\     //\\  //\\    //\\     //\\    //\\
 //||\\  //||\\  //   Encript & Disk Stuff  \\   //||\\  //||\\
//||||\\//||||\\//||||\\//||||\\//||||\\//||||\\//||||\\//||||\\


(*   https://forum.lazarus.freepascal.org/index.php?topic=33013.0 *)
function SimpleCrypt(const InpText : string): string;
const
  InitialPassword = '2020_05_04_coisa_comprida';
var
  i, len: integer;
  Password : String;
begin
  len := Length(InpText);
  Password := '';
  repeat
    Password := Password+InitialPassword;
  until Length(Password) > len;

  if len > Length(Password) then
    len := Length(Password);
  SetLength(result, len);
  for i := 1 to len do
      result[i] := Chr(Ord(InpText[i]) xor Ord(Password[i]));
end;


(*  // https://forum.lazarus.freepascal.org/index.php/topic,30007.msg251561.html#msg251561  *)

const
  IOCTL_STORAGE_BASE = $2d;
  METHOD_BUFFERED = 0;
  FILE_ANY_ACCESS = 0;
  IOCTL_STORAGE_QUERY_PROPERTY = (IOCTL_STORAGE_BASE shl 16) or
    (FILE_ANY_ACCESS shl 14) or ($500 shl 2) or METHOD_BUFFERED;

type
  STORAGE_QUERY_TYPE = (
    PropertyStandardQuery,     // Retrieves the descriptor
    PropertyExistsQuery,       // Used to test whether the descriptor is supported
    PropertyMaskQuery,         // Used to retrieve a mask of writeable fields in the descriptor
    PropertyQueryMaxDefined    // use to validate the value
  );

  STORAGE_PROPERTY_ID = (
    StorageDeviceProperty,
    StorageAdapterProperty,
    StorageDeviceIdProperty,
    StorageDeviceUniqueIdProperty,
    StorageDeviceWriteCacheProperty,
    StorageMiniportProperty,
    StorageAccessAlignmentProperty,
    StorageDeviceSeekPenaltyProperty,
    StorageDeviceTrimProperty,
    StorageDeviceWriteAggregationProperty
  );

  STORAGE_PROPERTY_QUERY = record
    PropertyId: STORAGE_PROPERTY_ID;
    QueryType: STORAGE_QUERY_TYPE;
    AdditionalParameters: array[0..0] of Byte;
  end;

  STORAGE_DESCRIPTOR_HEADER = record
    Version: DWORD;
    Size: DWORD;
  end;

  STORAGE_DEVICE_DESCRIPTOR = record
    Version: DWORD;
    Size: DWORD;
    DeviceType: Byte;
    DeviceTypeModifier: Byte;
    RemovableMedia: Boolean;
    CommandQueueing: Boolean;
    VendorIdOffset: DWORD;
    ProductIdOffset: DWORD;
    ProductRevisionOffset: DWORD;
    SerialNumberOffset: DWORD;
    BusType: DWORD;
    RawPropertiesLength: DWORD;
    RawDeviceProperties: array[0..0] of Byte;
  end;

function GetDeviceSerial(const Device: string): string;
var
  hDevice: THandle;
  Info: STORAGE_PROPERTY_QUERY;
  Header: STORAGE_DESCRIPTOR_HEADER;
  Buffer: PAnsiChar;
  Descriptor: ^STORAGE_DEVICE_DESCRIPTOR;
  BytesNeed: DWORD;
begin
  Result := '';
  hDevice := CreateFile(PChar(Device), 0, FILE_SHARE_READ or FILE_SHARE_WRITE,
    nil, OPEN_EXISTING, 0, 0);
  if hDevice = INVALID_HANDLE_VALUE then
    Exit;
  Info.PropertyId := StorageDeviceProperty;
  Info.QueryType := PropertyStandardQuery;
  Header.Size := 0;
  Header.Version := 0;
  if not DeviceIoControl(hDevice, IOCTL_STORAGE_QUERY_PROPERTY, @Info,
    SizeOf(Info), @Header, SizeOf(Header), {%H-}BytesNeed, nil) then
  begin
    CloseHandle(hDevice);
    Exit;
  end;
  GetMem(Buffer, Header.Size);
  if DeviceIoControl(hDevice, IOCTL_STORAGE_QUERY_PROPERTY, @Info,
    SizeOf(Info), Buffer, Header.Size, BytesNeed, nil) then
  begin
    Descriptor := Pointer(Buffer);
    if Descriptor^.SerialNumberOffset <> 0 then
      Result := Buffer + Descriptor^.SerialNumberOffset;
  end;
  FreeMem(Buffer);
  CloseHandle(hDevice);
end;

function HexToStr(const Src: string): string;
var
  iSrc, iDst: Integer;
  SrcLen: Integer;
  Code: Integer;
begin
  SrcLen := Length(Src);
  iSrc := 2;
  iDst := 1;
  SetLength(Result, SrcLen div 2);
  while iSrc <= SrcLen do
  begin
    Code := (Ord(Src[iSrc - 1]) - Ord('0')) shl 4 + Ord(Src[iSrc]) - Ord('0');
    Result[iDst] := Chr(Code);
    Inc(iDst);
    Inc(iSrc, 2);
  end;
end;

function GetDisk0Serial : string;
begin
  try
    ////raise Exception.Create('Test error');
    //Writeln('Serial PhysicalDrive0 is ASCII "', GetDeviceSerial('\\.\PhysicalDrive0'), '"');
    //Writeln('Serial PhysicalDrive0 is "', HexToStr(GetDeviceSerial('\\.\PhysicalDrive0')), '"');
    //Readln;
    result := GetDeviceSerial('\\.\PhysicalDrive0');
  except
    on e : exception do begin
      result := 'Exception';
      //Writeln('Exception :( ');
      //Readln;
    end;
  end;
end;

procedure SimpleCryptFile(const FNIn, FNOut : string);
var
  TmpStr : String;
  aFile : File;
  Buf : Array[1..2048] of byte;
  NumRead, NumWritten, Total : integer;
begin

  TmpStr := '';
  Assign(aFile, FNIn);
  Reset(aFile,1);
  buf[1] := 0;
  NumRead:=0;
  Repeat
    BlockRead (aFile,buf,1,NumRead);
    if NumRead>0 then TmpStr := TmpStr + chr(buf[1]);
  Until (NumRead=0);

  TmpStr := SimpleCrypt(FMain.MemoCrypt1.Lines.Text);

  Assign(aFile, FNOut);
  rewrite(aFile,1);
  NumWritten:=0;
  Total := 1;
  Repeat
    BlockWrite (aFile,TmpStr[Total],1,NumWritten);
    inc(Total,NumWritten);
  Until (NumWritten=0) or (Total=length(TmpStr)) ;
  Close(aFile);

end;




  //\\    //\\    //\\     //\\  //\\    //\\     //\\    //\\
 //||\\  //||\\  //   Encript & Disk Stuff  \\   //||\\  //||\\
//||||\\//||||\\//||||\\//||||\\//||||\\//||||\\//||||\\//||||\\


//##########################################################################
//Project NEW
procedure ProjectNew;
begin
  with Project do begin
    FileName:='Untitled';
    Author:='';
    Comments:='';
  end;

  FVariables.FormInit;  //FVariables.LoadVariables(nil);
  FVariables.SetDefaultNames;
  FIOLEDs.FormInit;
  FMain.FormInit;
  FormG7.FormInit;

  FMain.EditAuthors.text:=Project.Author;
  FMain.EditComments.Text:=Project.Comments;
  FMain.SynEditST.ReadOnly:=False;
  FMain.SynEditST.Modified:=False;

  FMain.UpdateStatusLine;
  FMain.caption := VersionString + ExtractFileName(Project.FileName);
  FormG7.Caption := 'Grafcet - ' + VersionString+ExtractFileName(Project.FileName);

  Project.Modified:=False;
  Project.Grafcet:=True;
  Project.Gen_C_Code:=True;
  FMain.MenuGrafcet.Enabled:=Project.Grafcet;

  FMain.FixSyntaxHighlAndCompletion;

  FMain.MenuClearAllClick(nil); //Ter a certeza que inicia com tudo limpo

end;

//##########################################################################
//Project SAVE FA5
function ProjectSaveFA5(aFileName: string):boolean;
var
  msg : TForm;
  cnt: integer;
  Doc: TXMLDocument;    // variable to document
  RootNode,GraphNode,ObjectsNode: TDOMNode; // BIG NODES
  nestedNode1,nestedNode2,nestedNode3:TDOMNode;//Object,Code,Text
  TmpStr : String;
begin

    // Disk BreadCrumb
  TmpStr := GetDisk0Serial();
  if FMain.MemoDiskBreadCrumbs.Lines.Count=0 then FMain.MemoDiskBreadCrumbs.Append(';)');
  with FMain.MemoDiskBreadCrumbs do
      if Lines[Lines.Count-1] <> TmpStr then Lines.Append(TmpStr);

  if(ExtractFileExt(aFileName)<>'.FA5') then begin    //GArantir que guarda em novo formato
     aFileName:=ChangeFileExt(aFileName, '.xml.FA5');
  end;
  msg := CreateMessageDialog('Saving '+aFileName,mtinformation,[mbok]);
  msg.Show;
  Application.ProcessMessages();
  sleep(80);
  result:=false;

  try
    with Project do begin
      FileName:=aFileName;
      Modified:=false;
    end;

    // Create a document
    Doc := TXMLDocument.Create;

    // Create a root node   -> FEUPAutom
    RootNode := Doc.CreateElement('FEUPAutom');
    Doc.Appendchild(RootNode); // save root node
    GraphNode := Doc.CreateElement('FAProject');
    RootNode.Appendchild(GraphNode);

    //##########################################################################
    //FMain FMain FMain FMain FMain FMain FMain FMain FMain FMain FMain FMain
    // FMain.FormSave(ProjMemIni);//ANTES
    ObjectsNode := Doc.CreateElement('FMain');
    GraphNode.Appendchild(ObjectsNode);

    //Main/Props1
    nestedNode1 := Doc.CreateElement('Props1');
    TDOMElement(nestedNode1).SetAttribute('ActiveTab',    IntToStr(FMain.PageControl.ActivePageIndex));
    TDOMElement(nestedNode1).SetAttribute('MessagesHeight',    IntToStr(max(FMain.PageControlBottom.Height,FMain.Splitter1.MinSize))); // corrige bug splitter nulo
    ObjectsNode.AppendChild(nestedNode1);

    //Main/Props2
    nestedNode1 := Doc.CreateElement('Props2');
    TDOMElement(nestedNode1).SetAttribute('ModBusIP', Project.MBIP);
    TDOMElement(nestedNode1).SetAttribute('ModBusPort', IntToStr(Project.MBPort));
    TDOMElement(nestedNode1).SetAttribute('ModBusNRead', IntToStr(Project.MBNRead));
    TDOMElement(nestedNode1).SetAttribute('ModBusNWrite', IntToStr(Project.MBNWrite));
    TDOMElement(nestedNode1).SetAttribute('ModBusOffs_I', IntToStr(Project.MBOffs_I));
    TDOMElement(nestedNode1).SetAttribute('ModBusOffs_O', IntToStr(Project.MBOffs_O));
    TDOMElement(nestedNode1).SetAttribute('ModBusFunc', IntToStr(Project.MBFunc));
    TDOMElement(nestedNode1).SetAttribute('ModBus', BoolToStr(FMain.CBModBus.Checked));
    TDOMElement(nestedNode1).SetAttribute('Period', IntToStr(Project.Period));
    TDOMElement(nestedNode1).SetAttribute('WinMsg', BoolToStr(FMain.CBWinMessages.Checked));
    ObjectsNode.AppendChild(nestedNode1);

    //Main/Props3
    nestedNode1 := Doc.CreateElement('Props3');
    TDOMElement(nestedNode1).SetAttribute('ProjectAuthor', Project.Author);
    TDOMElement(nestedNode1).SetAttribute('ProjectComments', Project.Comments);
    TDOMElement(nestedNode1).SetAttribute('ProjectGrafcet', IntToStr(ord(Project.Grafcet)));
    TDOMElement(nestedNode1).SetAttribute('ProjectGen_C_Code', IntToStr(ord(Project.Gen_C_Code)));
    ObjectsNode.AppendChild(nestedNode1);

    //Main/Geometry
    nestedNode1 := Doc.CreateElement('Geometry');
    TDOMElement(nestedNode1).SetAttribute('top',    IntToStr(FMain.top));
    TDOMElement(nestedNode1).SetAttribute('left',   IntToStr(FMain.left));
    TDOMElement(nestedNode1).SetAttribute('height', IntToStr(FMain.height));
    TDOMElement(nestedNode1).SetAttribute('width',  IntToStr(FMain.width));
    ObjectsNode.AppendChild(nestedNode1);

    //Main/ST_Code
    nestedNode1 := Doc.CreateElement('ST_Code');
    TDOMElement(nestedNode1).SetAttribute('count',    IntToStr(FMain.SynEditST.lines.Count));
    for cnt:=0 to FMain.SynEditST.lines.Count-1 do begin
      nestedNode2:= Doc.CreateElement('line'+IntToStr(cnt+1));
      nestedNode3:=Doc.CreateTextNode('~'+FMain.SynEditST.lines[cnt]); //Get text of CODE
      nestedNode2.AppendChild(nestedNode3);
      nestedNode1.AppendChild(nestedNode2);
    end;
    ObjectsNode.AppendChild(nestedNode1);

    //Main/BreadCrumbs
    nestedNode1 := Doc.CreateElement('Interesting');
    TDOMElement(nestedNode1).SetAttribute('count',    IntToStr(FMain.MemoDiskBreadCrumbs.lines.Count));
    for cnt:=0 to FMain.MemoDiskBreadCrumbs.lines.Count-1 do begin
      nestedNode2:= Doc.CreateElement('line'+IntToStr(cnt+1));
      nestedNode3:=Doc.CreateTextNode('~'+FMain.MemoDiskBreadCrumbs.lines[cnt]); //Get text of CODE
      nestedNode2.AppendChild(nestedNode3);
      nestedNode1.AppendChild(nestedNode2);
    end;
    ObjectsNode.AppendChild(nestedNode1);


    //##########################################################################
    //FVariables FVariables FVariables FVariables FVariables FVariables FVariables
    ObjectsNode := Doc.CreateElement('FVariables');
    GraphNode.Appendchild(ObjectsNode);
    nestedNode1 := Doc.CreateElement('Props');
    TDOMElement(nestedNode1).SetAttribute('Visible', BoolToStr(FVariables.Visible));
    TDOMElement(nestedNode1).SetAttribute('NextVar', BoolToStr(FVariables.CBNextVar.Checked));
    TDOMElement(nestedNode1).SetAttribute('Filter', IntToStr(FVariables.CBTypes.ItemIndex));
    ObjectsNode.AppendChild(nestedNode1);//insert objNode in  ObjectsNode
    nestedNode1 := Doc.CreateElement('Geometry');  // create a Object Node
    TDOMElement(nestedNode1).SetAttribute('top',    IntToStr(FVariables.top));
    TDOMElement(nestedNode1).SetAttribute('left',   IntToStr(FVariables.left));
    TDOMElement(nestedNode1).SetAttribute('height', IntToStr(FVariables.height));
    TDOMElement(nestedNode1).SetAttribute('width',  IntToStr(FVariables.width));
    ObjectsNode.AppendChild(nestedNode1);//insert objNode in  ObjectsNode
    nestedNode1 := Doc.CreateElement('Vars_Names');
    TDOMElement(nestedNode1).SetAttribute('count',    IntToStr(FVariables.SGVars.Cols[1].Count));
    for cnt:=0 to FVariables.SGVars.Cols[1].Count-1 do begin
      nestedNode2:= Doc.CreateElement('var'+IntToStr(cnt+1));
      nestedNode3:=Doc.CreateTextNode(FVariables.SGVars.Cells[1,cnt]); //Get text of CODE
      nestedNode2.AppendChild(nestedNode3);
      nestedNode1.AppendChild(nestedNode2);
    end;
    ObjectsNode.AppendChild(nestedNode1);

    //##########################################################################
    //FIOLEDs FIOLEDs FIOLEDs FIOLEDs FIOLEDs FIOLEDs FIOLEDs FIOLEDs FIOLEDs
    ObjectsNode := Doc.CreateElement('FIOLEDs');
    GraphNode.Appendchild(ObjectsNode);
    nestedNode1 := Doc.CreateElement('Props');
    TDOMElement(nestedNode1).SetAttribute('Visible', BoolToStr(FIOLEDs.Visible));
    ObjectsNode.AppendChild(nestedNode1);
    nestedNode1 := Doc.CreateElement('Geometry');
    TDOMElement(nestedNode1).SetAttribute('top',    IntToStr(FIOLEDs.top));
    TDOMElement(nestedNode1).SetAttribute('left',   IntToStr(FIOLEDs.left));
    TDOMElement(nestedNode1).SetAttribute('height', IntToStr(FIOLEDs.height));
    TDOMElement(nestedNode1).SetAttribute('width',  IntToStr(FIOLEDs.width));
    ObjectsNode.AppendChild(nestedNode1);

    //##########################################################################
    //FLog FLog FLog FLog FLog FLog FLog FLog FLog FLog FLog FLog FLog FLog
    ObjectsNode := Doc.CreateElement('FLog');
    GraphNode.Appendchild(ObjectsNode);
    nestedNode1 := Doc.CreateElement('Props');
    TDOMElement(nestedNode1).SetAttribute('Visible', BoolToStr(FLog.Visible));
    ObjectsNode.AppendChild(nestedNode1);
    nestedNode1 := Doc.CreateElement('Geometry');
    TDOMElement(nestedNode1).SetAttribute('top',    IntToStr(FLog.top));
    TDOMElement(nestedNode1).SetAttribute('left',   IntToStr(FLog.left));
    TDOMElement(nestedNode1).SetAttribute('height', IntToStr(FLog.height));
    TDOMElement(nestedNode1).SetAttribute('width',  IntToStr(FLog.width));
    ObjectsNode.AppendChild(nestedNode1);

    //##########################################################################
    //FormG7 FormG7 FormG7 FormG7 FormG7 FormG7 FormG7 FormG7 FormG7
    //Não existia
    ObjectsNode := Doc.CreateElement('FormG7');
    GraphNode.Appendchild(ObjectsNode);
    nestedNode1 := Doc.CreateElement('Props');
    TDOMElement(nestedNode1).SetAttribute('Visible', BoolToStr(FormG7.Visible));
    TDOMElement(nestedNode1).SetAttribute('RoundStates', BoolToStr(FormG7.CBRoundStates.Checked));
    ObjectsNode.AppendChild(nestedNode1);
    nestedNode1 := Doc.CreateElement('Geometry');
    TDOMElement(nestedNode1).SetAttribute('top',    IntToStr(FormG7.top));
    TDOMElement(nestedNode1).SetAttribute('left',   IntToStr(FormG7.left));
    TDOMElement(nestedNode1).SetAttribute('height', IntToStr(FormG7.height));
    TDOMElement(nestedNode1).SetAttribute('width',  IntToStr(FormG7.width));
    ObjectsNode.AppendChild(nestedNode1);
    FormG7.G7SaveXML(ChangeFileExt(Project.FileName, '.G7.xml'), false, Doc);

    if FMain.CBExamMode.Checked then begin
      writeXMLFile(Doc, aFileName+'Exam'); // write to XML
      SimpleCryptFile( aFileName+'Exam',aFileName);    // Encrypt
    end else
      writeXMLFile(Doc, aFileName); // write to XML (no encrypt)

    FMain.SynEditST.Modified:=false;
    FMain.UpdateStatusLine;
    FMain.Caption := VersionString+ExtractFileName(Project.FileName);
    FormG7.Caption := 'Grafcet - ' + VersionString+ExtractFileName(Project.FileName);
    result:=true;
  finally
    Doc.Free; // free memory
  end;

  Application.ProcessMessages();
  sleep(100);
  msg.Hide;
  Application.ProcessMessages();
  msg.Free;


{
//FA_RESOLVIDO: ANTIGO SAVE:

function ProjectSave(aFileName: string):boolean;
var
  ProjMemIni : TMemIniFile;
  msg : TForm;
begin

  msg := CreateMessageDialog('Saving...',mtinformation,[mbok]);
  msg.Show;
  Application.ProcessMessages();
  sleep(50);

  result:=false;
  ProjMemIni:= TMemIniFile.Create(afileName);
  try
  try

    with Project do begin
      FileName:=aFileName;
      Modified:=false;
    end;


    FMain.FormSave(ProjMemIni);
    FVariables.FormSave(ProjMemIni);
    FIOLEDs.FormSave(ProjMemIni);
    if Project.Grafcet then FormG7.G7SaveXML(ChangeFileExt(Project.FileName, '.g7.xml'));

    ProjMemIni.UpdateFile;
    FMain.SynEditST.Modified:=false;
    FMain.UpdateStatusLine;
    FMain.Caption := VersionString+ExtractFileName(Project.FileName);
    result:=true;
  except

  end;
  finally
    ProjMemIni.Free;
  end;
  Application.ProcessMessages();
  sleep(100);
  msg.Hide;
  Application.ProcessMessages();
  msg.Free;
end;

}
end;



//##########################################################################
//Project OPEN FA5
function ProjectOpenFA5(aFileName: string; ImportGr7Page3Mode : boolean = FALSE) : boolean;
var
  cnt,maxcnt: integer;
  Doc: TXMLDocument;    // variable to document
  FAProjectNode,G7ProjectNode:TDOMNode;
  FEUPAutomNode,RootNode,ObjectsNode: TDOMNode; // BIG NODES
//const MaxInBits  = 48;
//const MaxOutBits = 48;
var TempString : string;
begin
  result:=false;
  try  //main load:
    //Project:
    if not ImportGr7Page3Mode then Project.fileName:=aFileName;

    Project.Modified:=False;

    if FMain.CBExamMode.Checked then begin
      SimpleCryptFile( aFileName, aFileName+'Exam');    // Encrypt = DeCrypt
      ReadXMLFile(Doc,aFileName+'Exam');
    end else
      ReadXMLFile(Doc,aFileName );

    FEUPAutomNode:=Doc.FirstChild;

    //XMLerror1: Name of first element <> 'FEUPAutom'
    if (FEUPAutomNode.NodeName<>'FEUPAutom') then begin
      Result:=false;
      ShowMessage('XML file corrupted: Not a FEUPAutom Project (1)');
      Exit;
    end;

    //XMLerror2.1: Name of first element of FEUPAutom <> 'FAProject'
    FAProjectNode := FEUPAutomNode.FindNode('FAProject'); //Get: FAProject
    if (not Assigned(FAProjectNode)) then begin
      result:=false;
      ShowMessage('XML file corrupted: Not a FEUPAutom Project(2.1)');
      Exit;
    end;

    //XMLerror2.2: Name of second element of FEUPAutom <> 'G7Project'
    G7ProjectNode := FEUPAutomNode.FindNode('G7Project'); //Get: G7Project
    if (not Assigned(G7ProjectNode)) then begin
      result:=false;
      ShowMessage('XML file corrupted: Not a FEUPAutom Project(2.2)');
      Exit;
    end;

    //##########################################################################
    //MAIN
    RootNode := FAProjectNode.FindNode('FMain'); //Get: FMain
    if (Assigned(RootNode)) then begin
      //Main/Props1
      ObjectsNode := RootNode.FindNode('Props1');
      if (Assigned(ObjectsNode)) then begin
        try        FMain.PageControl.ActivePageIndex:= strToInt(ObjectsNode.Attributes.GetNamedItem('ActiveTab').TextContent);
        except     FMain.PageControl.ActivePageIndex:=1;  end;
        try        FMain.PageControlBottom.Height:= strToInt(ObjectsNode.Attributes.GetNamedItem('MessagesHeight').TextContent);
        except     FMain.PageControlBottom.Height:=93;  end;
      end;
      //Main/Props2
      ObjectsNode := RootNode.FindNode('Props2');
      if (Assigned(ObjectsNode)) then begin
        try        Project.MBIP:= (ObjectsNode.Attributes.GetNamedItem('ModBusIP').TextContent);
        except     Project.MBIP:='localhost';  end;
        try        Project.MBPort:= strToInt(ObjectsNode.Attributes.GetNamedItem('ModBusPort').TextContent);
        except     Project.MBPort:=5502;  end;
        try        Project.MBNRead:= strToInt(ObjectsNode.Attributes.GetNamedItem('ModBusNRead').TextContent);
        except     Project.MBNRead:=MaxInBits;  end;
        try        Project.MBNWrite:= strToInt(ObjectsNode.Attributes.GetNamedItem('ModBusNWrite').TextContent);
        except     Project.MBNWrite:=MaxOutBits;  end;
        try        Project.MBOffs_I:= strToInt(ObjectsNode.Attributes.GetNamedItem('ModBusOffs_I').TextContent);
        except     Project.MBOffs_I:=0;  end;
        try        Project.MBOffs_O:= strToInt(ObjectsNode.Attributes.GetNamedItem('ModBusOffs_O').TextContent);
        except     Project.MBOffs_O:=0;  end;
        try        Project.MBFunc:= strToInt(ObjectsNode.Attributes.GetNamedItem('ModBusFunc').TextContent);
        except     Project.MBFunc:=0;  end;
        try        Project.Period:= strToInt(ObjectsNode.Attributes.GetNamedItem('Period').TextContent);
        except     Project.Period:=500;  end;
        try        Project.ModBus:= StrToBool(ObjectsNode.Attributes.GetNamedItem('ModBus').TextContent);
        except     Project.ModBus:=false;  end;
        try        Project.WinMsg:= StrToBool(ObjectsNode.Attributes.GetNamedItem('WinMsg').TextContent);
        except     Project.WinMsg:=false;  end;
        //Vars to Form:
        FMain.EditMBIP.text     := Project.MBIP;
        FMain.EditMBPort.text   := IntToStr(Project.MBPort);
        FMain.EditMBNRead.text  := IntToStr(Project.MBNRead);
        FMain.EditMBNWrite.text := IntToStr(Project.MBNWrite);
        FMain.EditMBOffs_I.text := IntToStr(Project.MBOffs_I);
        FMain.EditMBOffs_O.text := IntToStr(Project.MBOffs_O);
        FMain.RGMBReadFunc.ItemIndex := Project.MBFunc;
        FMain.EditPeriodMiliSec.text := IntToStr(Project.Period);
        FMain.CBModBus.Checked := Project.ModBus;
        FMain.CBWinMessages.Checked:= Project.WinMsg;
      end;
      //Main/Props3
      ObjectsNode := RootNode.FindNode('Props3');
      if (Assigned(ObjectsNode)) then begin
        try        Project.Author:= (ObjectsNode.Attributes.GetNamedItem('ProjectAuthor').TextContent);
        except     Project.Author:='';  end;
        try        Project.Comments:= (ObjectsNode.Attributes.GetNamedItem('ProjectComments').TextContent);
        except     Project.Comments:='';  end;
        try        Project.Grafcet:= StrToBool(ObjectsNode.Attributes.GetNamedItem('ProjectGrafcet').TextContent);
        except     Project.Grafcet:=true;  end;
        try        Project.Gen_C_Code:= StrToBool(ObjectsNode.Attributes.GetNamedItem('ProjectGen_C_Code').TextContent);
        except     Project.Gen_C_Code:=true;  end;
        //Vars to Form:
        //FormG7.Visible             := Project.Grafcet;
        FMain.CBGrafcet.Checked    := Project.Grafcet;
        FMain.MenuGrafcet.Enabled  := Project.Grafcet;
        FMain.CBGen_C_Code.Checked := Project.Gen_C_Code;
        FMain.CBGen_C_CodeClick(nil);

      end;
      //Main/Geometry
      ObjectsNode := RootNode.FindNode('Geometry');
      if (Assigned(ObjectsNode)) then begin
        try        FMain.top:= strToInt(ObjectsNode.Attributes.GetNamedItem('top').TextContent);
        except     FMain.top:=110;  end;
        try        FMain.left:= strToInt(ObjectsNode.Attributes.GetNamedItem('left').TextContent);
        except     FMain.left:=335;  end;
        try        FMain.height:= strToInt(ObjectsNode.Attributes.GetNamedItem('height').TextContent);
        except     FMain.height:=559;  end;
        try        FMain.width:= strToInt(ObjectsNode.Attributes.GetNamedItem('width').TextContent);
        except     FMain.width:=619;  end;
        while FMain.Top  > Screen.Height do FMain.Top := FMain.Top   div 2;
        while FMain.Left > Screen.Width  do FMain.Left:= FMain.Width div 2;
        while FMain.Top  < (Screen.Height div 10) do FMain.Top := Screen.Height div 10;
        while FMain.Left < (Screen.Width  div 10) do FMain.Left:= Screen.Width  div 10;
      end;
      //Main/ST_Code
      ObjectsNode := RootNode.FindNode('ST_Code');
      if (Assigned(ObjectsNode)) then begin
        FMain.SynEditST.lines.Clear;
        try        maxcnt:= strToInt(ObjectsNode.Attributes.GetNamedItem('count').TextContent);
        except     maxcnt:=0;  end;
        try  begin
          for cnt:=0 to maxcnt-1 do begin
            TempString := ObjectsNode.ChildNodes[cnt].TextContent;
            if (Copy(TempString,1,1)='~') then TempString := copy(TempString,2,9999);
            FMain.SynEditST.lines.Add(TempString);
          end;
        end;
        except
          //limpar?
        end;
      end;
      //Main/Interesting (BreadCrumbs)
      ObjectsNode := RootNode.FindNode('Interesting');
      if (Assigned(ObjectsNode)) then begin
        FMain.MemoDiskBreadCrumbs.lines.Clear;
        try        maxcnt:= strToInt(ObjectsNode.Attributes.GetNamedItem('count').TextContent);
        except     maxcnt:=0;  end;
        try  begin
          for cnt:=0 to maxcnt-1 do begin
            TempString := ObjectsNode.ChildNodes[cnt].TextContent;
            if (Copy(TempString,1,1)='~') then TempString := copy(TempString,2,9999);
            FMain.MemoDiskBreadCrumbs.lines.Add(TempString);
          end;
        end;
        except
          //limpar?
        end;


    end
    else begin
      //Zerar Condições
    end;
    end;

    //##########################################################################
    //FVariables
    RootNode := FAProjectNode.FindNode('FVariables'); //Get: FVariables
    if (Assigned(RootNode)) then begin
      //FVariables/Props
      ObjectsNode := RootNode.FindNode('Props');
      if (Assigned(ObjectsNode)) then begin
        try        FVariables.Visible:= StrToBool(ObjectsNode.Attributes.GetNamedItem('Visible').TextContent);
        except     FVariables.Visible:=false;  end;
        try        FVariables.CBNextVar.Checked:= StrToBool(ObjectsNode.Attributes.GetNamedItem('NextVar').TextContent);
        except     FVariables.CBNextVar.Checked:=true;  end;
        try        FVariables.CBTypes.ItemIndex:= StrToint(ObjectsNode.Attributes.GetNamedItem('Filter').TextContent);
        except     FVariables.CBTypes.ItemIndex:=0;  end;
      end;
      //FVariables/Geometry
      ObjectsNode := RootNode.FindNode('Geometry');
      if (Assigned(ObjectsNode)) then begin
        try        FVariables.top:= strToInt(ObjectsNode.Attributes.GetNamedItem('top').TextContent);
        except     FVariables.top:=48;  end;
        try        FVariables.left:= strToInt(ObjectsNode.Attributes.GetNamedItem('left').TextContent);
        except     FVariables.left:=746;  end;
        try        FVariables.height:= strToInt(ObjectsNode.Attributes.GetNamedItem('height').TextContent);
        except     FVariables.height:=456;  end;
        try        FVariables.width:= strToInt(ObjectsNode.Attributes.GetNamedItem('width').TextContent);
        except     FVariables.width:=269;  end;
      end;
      //FVariables/Vars_Names
      if not ImportGr7Page3Mode then begin
        ObjectsNode := RootNode.FindNode('Vars_Names');
        if (Assigned(ObjectsNode)) then begin
          try        maxcnt:= strToInt(ObjectsNode.Attributes.GetNamedItem('count').TextContent);
          except     maxcnt:=0;  end;
          try  begin
            for cnt:=0 to maxcnt-1 do begin
              FVariables.SGVars.Cells[1,cnt]:=(ObjectsNode.ChildNodes[cnt].TextContent);
            end;
          end;
          except
            //limpar?
          end;
        end;
      end
      else begin
        //Zerar Condições
      end;
    end;
    //##########################################################################
    //FIOLEDs
    RootNode := FAProjectNode.FindNode('FIOLEDs'); //Get: FIOLEDs
    if (Assigned(RootNode)) then begin
      FIOLeds.FormInit;
      FIOLeds.UpdateNames;

      //FIOLEDS/Props
      ObjectsNode := RootNode.FindNode('Props');
      if (Assigned(ObjectsNode)) then begin
        try        FIOLEDS.Visible:= StrToBool(ObjectsNode.Attributes.GetNamedItem('Visible').TextContent);
        except     FIOLEDS.Visible:=false;  end;
      end;
      //FIOLEDS/Geometry
      ObjectsNode := RootNode.FindNode('Geometry');
      if (Assigned(ObjectsNode)) then begin
        try        FIOLEDS.top:= strToInt(ObjectsNode.Attributes.GetNamedItem('top').TextContent);
        except     FIOLEDS.top:=4;  end;
        try        FIOLEDS.left:= strToInt(ObjectsNode.Attributes.GetNamedItem('left').TextContent);
        except     FIOLEDS.left:=485;  end;
        try        FIOLEDS.height:= strToInt(ObjectsNode.Attributes.GetNamedItem('height').TextContent);
        except     FIOLEDS.height:=665;  end;
        try        FIOLEDS.width:= strToInt(ObjectsNode.Attributes.GetNamedItem('width').TextContent);
        except     FIOLEDS.width:=207;  end;
      end;
    end
    else begin
      //Zerar Condições
    end;

    //##########################################################################
    //FLog
    RootNode := FAProjectNode.FindNode('FLog'); //Get: FIOLEDs
    if (Assigned(RootNode)) then begin

      //FLog/Props
      ObjectsNode := RootNode.FindNode('Props');
      if (Assigned(ObjectsNode)) then begin
        try        FLog.Visible:= StrToBool(ObjectsNode.Attributes.GetNamedItem('Visible').TextContent);
        except     FLog.Visible:=false;  end;
      end;
      //FLog/Geometry
      ObjectsNode := RootNode.FindNode('Geometry');
      if (Assigned(ObjectsNode)) then begin
        try        FLog.top:= strToInt(ObjectsNode.Attributes.GetNamedItem('top').TextContent);
        except     FLog.top:=130;  end;
        try        FLog.left:= strToInt(ObjectsNode.Attributes.GetNamedItem('left').TextContent);
        except     FLog.left:=400;  end;
        try        FLog.height:= strToInt(ObjectsNode.Attributes.GetNamedItem('height').TextContent);
        except     FLog.height:=412;  end;
        try        FLog.width:= strToInt(ObjectsNode.Attributes.GetNamedItem('width').TextContent);
        except     FLog.width:=207;  end;
      end;
    end
    else begin
      //Zerar Condições
    end;

    //##########################################################################
    //FormG7
    RootNode := FAProjectNode.FindNode('FormG7'); //Get: FormG7
    if (Assigned(RootNode)) then begin

      //FormG7/Props
      ObjectsNode := RootNode.FindNode('Props');
      if (Assigned(ObjectsNode)) then begin
        try        FormG7.Visible:= StrToBool(ObjectsNode.Attributes.GetNamedItem('Visible').TextContent);
        except     FormG7.Visible:=false;  end;
        try        FormG7.CBRoundStates.Checked := StrToBool(ObjectsNode.Attributes.GetNamedItem('RoundStates').TextContent);
        except     FormG7.CBRoundStates.Checked:=false;  end;
      end;
      //FormG7/Geometry
      ObjectsNode := RootNode.FindNode('Geometry');
      if (Assigned(ObjectsNode)) then begin
        try        FormG7.top:= strToInt(ObjectsNode.Attributes.GetNamedItem('top').TextContent);
        except     FormG7.top:=4;  end;
        try        FormG7.left:= strToInt(ObjectsNode.Attributes.GetNamedItem('left').TextContent);
        except     FormG7.left:=485;  end;
        try        FormG7.height:= strToInt(ObjectsNode.Attributes.GetNamedItem('height').TextContent);
        except     FormG7.height:=665;  end;
        try        FormG7.width:= strToInt(ObjectsNode.Attributes.GetNamedItem('width').TextContent);
        except     FormG7.width:=207;  end;
      end;
    end
    else begin
      //Zerar Condições
    end;
    if (not  FormG7.G7LoadXML('doesntmatter',false,G7ProjectNode,ImportGr7Page3Mode)) then begin
      result:=false;
      ShowMessage('Error loading Grafcet file');
      exit;
    end;
    result:=true;
  except
    on E: Exception do begin
      Doc.Free;
      result:=false;

      ShowMessage('FA5 file corrupted:'+E.Message);
      exit;
    end;
  end;
  if(result)then begin
    Doc.Free;
    FMain.SynEditST.ReadOnly:=False;
    Project.Modified:=False;
    FMain.UpdateStatusLine;
    FMain.Caption  :=                VersionString+ExtractFileName(Project.FileName);
    FormG7.Caption := 'Grafcet - ' + VersionString+ExtractFileName(Project.FileName);

    result:=true;
    Exit;
  end;

  if FMain.CBExamMode.Checked then begin
    RenameFile( aFileName+'Exam', aFileName+'Plain');    // Encrypt = DeCrypt
  end;
end;



//##########################################################################
//Project OPEN faproj2 -> oldopen
function ProjectOpen(aFileName: string):boolean;
var ProjMemIni : TMemIniFile;
begin
  result:=false;
  {FA_Resolvido}
  if (not FileExists(aFileName))   then exit;  //Converted from FileExists*

  if(ExtractFileExt(aFileName)='.FA5') then begin    //NEW FILES FA5
    result := ProjectOpenFA5(afileName);
    exit;
  end
  else begin  //OLD FILES faproj2
    QuoteSTTextInIniFile(aFileName);

    ProjMemIni:= TMemIniFile.Create(aFileName);
    try
      try

        with Project do begin
          fileName:=aFileName;
          FMain.EditAuthors.text:=Author;
          FMain.EditComments.Text:=Comments;
          Modified:=False;
        end;

        FMain.FormLoad(ProjMemIni);
        FVariables.FormLoad(ProjMemIni);
        FIOLEDs.FormLoad(ProjMemIni);
        if Project.Grafcet Then begin
           FormG7.G7LoadXML(ChangeFileExt(Project.FileName, '.g7.xml'),true,nil);
           FormG7.GenSTCode();
        end;
        FMain.SynEditST.ReadOnly:=False;
        Project.Modified:=False;
        result:=true;
      except

      end;
    finally
      //SynEditSTStatusChange(FMain,[scCaretX, scCaretY,scInsertMode,scModified]);
      FMain.UpdateStatusLine;
      FMain.Caption  := VersionString+ExtractFileName(Project.FileName);
      FormG7.Caption := 'Grafcet - ' + VersionString+ExtractFileName(Project.FileName);
      ProjMemIni.Free;
    end;
  end;
end;



//##########################################################################
//Project OTHER funcs
procedure QuoteSTTextInIniFile(aFileName: string);
var
  lines : TStringList;
  CurLine,StartLine,separator, NumLines : integer;

begin
  lines:=TStringList.Create;
    try
    lines.LoadFromFile(aFileName);

    StartLine:=0;
    NumLines:=lines.Count;
    while (lines.Strings[StartLine]<>'[Main\STText]') and (StartLine<NumLines-1) do
      Inc(StartLine);

    if (StartLine=NumLines-1) then begin  // not found, strange ! Empty File ?
      if UpperCase(ParamStr(1))<>'-R' then
        ShowMessage('Empty ST - strange... damaged file?');
    end else begin
      Inc(StartLine);
      if (Copy(lines.Strings[StartLine],1,6)<>'count=') then begin  // not found, strange !
        exit;
      end;

      NumLines:=StrToIntDef(copy(lines.Strings[StartLine],7,length(lines.Strings[StartLine])),0);

      CurLine:=StartLine+1;

      repeat
        separator:=pos('=',lines.Strings[curline]);
        if copy(lines.Strings[curline],separator+1,1)='"' then exit; // already quoted file...
        lines.Strings[CurLine]:=copy(lines.Strings[curline],1,separator)+'"'+copy(lines.Strings[curline],separator+1,9999)+'"';
        inc(CurLine);
      until CurLine=StartLine+NumLines+1;

    end;

    {FA_Resolvido}
    renameFile(aFileName,aFileName+'.bkp'); //renameUTF8 Converted from RenameFile* and in lazarus converted to renamefile

    lines.SaveToFile(aFileName);
  finally
    lines.Free;
  end;
end;

procedure SaveFormGeometryToMemIni( MemIni: TMemIniFile; const aForm: TForm);
begin
  MemIni.WriteInteger(aForm.Name,'top',aForm.Top);
  MemIni.WriteInteger(aForm.Name,'left',aForm.Left);
  MemIni.WriteInteger(aForm.Name,'height',aForm.Height);
  MemIni.WriteInteger(aForm.Name,'width',aForm.Width);
end;

procedure LoadFormGeometryFromMemIni( MemIni: TMemIniFile; aForm: TForm);
begin
  aForm.Top    := MemIni.ReadInteger(aForm.Name,'top',aForm.Top);
  aForm.Left   := MemIni.ReadInteger(aForm.Name,'left',aForm.Left);
  aForm.Height := MemIni.ReadInteger(aForm.Name,'height',aForm.Height);
  aForm.Width  := MemIni.ReadInteger(aForm.Name,'width',aForm.Width);
end;

procedure SaveStringsToMemIni( MemIni: TMemIniFile; section, Ident: string; SL: TStrings);
var i: integer;
    key: string;
begin
  key:=section+'\'+Ident;
  MemIni.WriteInteger(key,'count',SL.count);
  for i:=0 to SL.count-1 do begin
    MemIni.WriteString(key,'line'+inttostr(i), AnsiQuotedStr(SL.strings[i],'"'));
  end;
end;

procedure LoadStringsFromMemIni( MemIni: TMemIniFile; section, Ident: string; SL: TStrings);
var i, count: integer;
    key: string;
    txt: string;
begin
  key:=section+'\'+Ident;

  count := MemIni.ReadInteger(key,'count',-1);
  SL.Clear;
  for i:=0 to count-1 do begin
    txt:=MemIni.ReadString(key,'line'+inttostr(i),'');
    if txt='""' then txt:=''
    else txt:=AnsiDequotedStr(txt,'"');
    SL.Add(txt);
  end;
end;



end.

