unit IOLeds;
{$MODE Delphi}          

interface

uses
   SysUtils, Classes, Graphics, Controls, Forms, Dialogs,   StdCtrls,StructuredTextUtils,
  inifiles, ProjManage, ExtCtrls, Buttons, SynEdit, SynEditHighlighter  ;

{NotUsed:
 Windows, Messages, Main,    ImgList,
}
{FA_TAG:   , SynHighlighterSTStructuredTextDWS,  }
type

  { TFIOLeds }

  TFIOLeds = class(TForm)
    GroupBox1: TGroupBox;
    ImageListLedsOut: TImageList;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    Image1: TImage;
    Label1: TLabel;
    RadioGroup1: TRadioGroup;
    GroupBox2: TGroupBox;
    Image2: TImage;
    Label2: TLabel;
    RadioGroup2: TRadioGroup;
    GroupBox3: TGroupBox;
    Image3: TImage;
    Label3: TLabel;
    RadioGroup3: TRadioGroup;
    GroupBox4: TGroupBox;
    Image4: TImage;
    Label4: TLabel;
    RadioGroup4: TRadioGroup;
    GroupBox5: TGroupBox;
    Image5: TImage;
    Label5: TLabel;
    RadioGroup5: TRadioGroup;
    GroupBox6: TGroupBox;
    Image6: TImage;
    Label6: TLabel;
    RadioGroup6: TRadioGroup;
    GroupBox7: TGroupBox;
    Image7: TImage;
    Label7: TLabel;
    RadioGroup7: TRadioGroup;
    GroupBox8: TGroupBox;
    Image8: TImage;
    Label8: TLabel;
    RadioGroup8: TRadioGroup;
    GroupBox9: TGroupBox;
    Image9: TImage;
    Label9: TLabel;
    RadioGroup9: TRadioGroup;
    GroupBox10: TGroupBox;
    Image10: TImage;
    Label10: TLabel;
    RadioGroup10: TRadioGroup;
    GroupBox11: TGroupBox;
    Image11: TImage;
    Label11: TLabel;
    RadioGroup11: TRadioGroup;
    GroupBox12: TGroupBox;
    Image12: TImage;
    Label12: TLabel;
    RadioGroup12: TRadioGroup;
    GroupBox13: TGroupBox;
    Image13: TImage;
    Label13: TLabel;
    RadioGroup13: TRadioGroup;
    GroupBox14: TGroupBox;
    Image14: TImage;
    Label14: TLabel;
    RadioGroup14: TRadioGroup;
    GroupBox15: TGroupBox;
    Image15: TImage;
    Label15: TLabel;
    RadioGroup15: TRadioGroup;
    GroupBox16: TGroupBox;
    Image16: TImage;
    Label16: TLabel;
    RadioGroup16: TRadioGroup;
    GroupBox17: TGroupBox;
    Image17: TImage;
    Label17: TLabel;
    RadioGroup17: TRadioGroup;
    GroupBox18: TGroupBox;
    Image18: TImage;
    Label18: TLabel;
    RadioGroup18: TRadioGroup;
    GroupBox19: TGroupBox;
    Image19: TImage;
    Label19: TLabel;
    RadioGroup19: TRadioGroup;
    GroupBox20: TGroupBox;
    Image20: TImage;
    Label20: TLabel;
    RadioGroup20: TRadioGroup;
    GroupBox21: TGroupBox;
    Image21: TImage;
    Label21: TLabel;
    RadioGroup21: TRadioGroup;
    GroupBox22: TGroupBox;
    Image22: TImage;
    Label22: TLabel;
    RadioGroup22: TRadioGroup;
    GroupBox23: TGroupBox;
    Image23: TImage;
    Label23: TLabel;
    RadioGroup23: TRadioGroup;
    GroupBox24: TGroupBox;
    Image24: TImage;
    Label24: TLabel;
    RadioGroup24: TRadioGroup;
    GroupBox25: TGroupBox;
    Image25: TImage;
    Label25: TLabel;
    RadioGroup25: TRadioGroup;
    GroupBox26: TGroupBox;
    Image26: TImage;
    Label26: TLabel;
    RadioGroup26: TRadioGroup;
    GroupBox27: TGroupBox;
    Image27: TImage;
    Label27: TLabel;
    RadioGroup27: TRadioGroup;
    GroupBox28: TGroupBox;
    Image28: TImage;
    Label28: TLabel;
    RadioGroup28: TRadioGroup;
    GroupBox29: TGroupBox;
    Image29: TImage;
    Label29: TLabel;
    RadioGroup29: TRadioGroup;
    GroupBox30: TGroupBox;
    Image30: TImage;
    Label30: TLabel;
    RadioGroup30: TRadioGroup;
    GroupBox31: TGroupBox;
    Image31: TImage;
    Label31: TLabel;
    RadioGroup31: TRadioGroup;
    GroupBox32: TGroupBox;
    Image32: TImage;
    Label41: TLabel;
    RadioGroup32: TRadioGroup;
    ImageListLedsIn: TImageList;
    CBShowPercentNames: TCheckBox;
    LabelConnected: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RadioGroupsClick(Sender: TObject);
    procedure CBShowPercentNamesClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure PLCStateToIOLeds(var PLCState : TPLCState);

    procedure ILedsToPLCState(var PLCState: TPLCState);
    procedure OLedsToPLCState(var PLCState: TPLCState);
    procedure UpdateNames;
    procedure CreateLeds;
    procedure FormInit;
    procedure FormLoad(proj: TMemIniFile);
    procedure FormSave(proj: TMemIniFile);
  end;

var
  FIOLeds: TFIOLeds;

implementation

{$R *.lfm}

uses Variables;


type TLed = class
  public
    procedure AssignImages (const img : TImage; const lst : TImageList);
  private
    PrivImage : TImage;
    PrivImageList : TImageList;
    PrivStatus : boolean;
    procedure ChangeStatusTo(const NewStat : boolean);
  published
    property  Status : boolean read PrivStatus write ChangeStatusTo;
end;

var
  InLeds  : array [0..15] of TLed;
  OutLeds : array [0..15] of TLed;
  InLedsLabels    : array [0..15] of TLabel;
  OutLedsLabels   : array [0..15] of TLabel;
  RGForcingsIn    : array [0..15] of TRadioGroup;
  RGForcingsOut   : array [0..15] of TRadioGroup;


procedure TLed.ChangeStatusTo(const NewStat : boolean);
begin
  if PrivStatus=NewStat then exit;
  PrivStatus:=NewStat;
  PrivImageList.GetBitmap(ord(NewStat),PrivImage.Picture.Bitmap);
  //PrivImage.Repaint;
  PrivImage.Invalidate;
end;


procedure TLed.AssignImages(const img : TImage; const lst : TImageList);
begin
  PrivImage:=img;
  PrivImageList:=lst;
  PrivStatus:=True;
  ChangeStatusTo(False); // Force initial FALSE Redraw
end;

procedure TFIOLeds.FormInit;
var i : integer;
begin

  for i:=0 to 15 do InLeds[i].Status:=False;
  for i:=0 to 11 do OutLeds[i].Status:=False;
  for i:=0 to 15 do  RGForcingsIn[i].ItemIndex:=0;
  for i:=0 to 11 do RGForcingsOut[i].ItemIndex:=0;
  UpdateNames;
  FIOLeds.Visible:=False;
  // TODO: Impor Geometria Default
end;

procedure TFIOLeds.FormLoad(proj : TMemIniFile);
begin
  FormInit;
  UpdateNames;
  LoadFormGeometryFromMemIni(Proj,FIOLeds);
  FIOLeds.Visible:=Proj.ReadBool('FIOLeds','Visible',False);
end;

procedure TFIOLeds.FormSave(proj : TMemIniFile);
begin
  SaveFormGeometryToMemIni(Proj,FIOLeds);
  Proj.WriteBool('FIOLeds','Visible',FIOLeds.Visible);
end;


function ForcingIn(const i : integer) : boolean;
begin
  result:=(RGForcingsIn[i].ItemIndex>0);
end;


function ForcingOut(const i : integer) : boolean;
begin
  result:=(RGForcingsOut[i].ItemIndex>0);
end;


procedure TFIOLeds.CreateLeds;
var i : integer;
begin

  for i:=low(InLeds)  to high(InLeds)  do InLeds[i] :=TLed.Create;
  for i:=low(OutLeds) to high(OutLeds) do OutLeds[i]:=TLed.Create;

  InLeds[00].AssignImages(Image1,ImageListLedsIn);
  InLeds[01].AssignImages(Image2,ImageListLedsIn);
  InLeds[02].AssignImages(Image3,ImageListLedsIn);
  InLeds[03].AssignImages(Image4,ImageListLedsIn);

  InLeds[04].AssignImages(Image5,ImageListLedsIn);
  InLeds[05].AssignImages(Image6,ImageListLedsIn);
  InLeds[06].AssignImages(Image7,ImageListLedsIn);
  InLeds[07].AssignImages(Image8,ImageListLedsIn);

  InLeds[08].AssignImages(Image9,ImageListLedsIn);
  InLeds[09].AssignImages(Image10,ImageListLedsIn);
  InLeds[10].AssignImages(Image11,ImageListLedsIn);
  InLeds[11].AssignImages(Image12,ImageListLedsIn);

  InLeds[12].AssignImages(Image13,ImageListLedsIn);
  InLeds[13].AssignImages(Image14,ImageListLedsIn);
  InLeds[14].AssignImages(Image15,ImageListLedsIn);
  InLeds[15].AssignImages(Image16,ImageListLedsIn);

  OutLeds[00].AssignImages(Image17,ImageListLedsOut);
  OutLeds[01].AssignImages(Image18,ImageListLedsOut);
  OutLeds[02].AssignImages(Image19,ImageListLedsOut);
  OutLeds[03].AssignImages(Image20,ImageListLedsOut);

  OutLeds[04].AssignImages(Image21,ImageListLedsOut);
  OutLeds[05].AssignImages(Image22,ImageListLedsOut);
  OutLeds[06].AssignImages(Image23,ImageListLedsOut);
  OutLeds[07].AssignImages(Image24,ImageListLedsOut);

  OutLeds[08].AssignImages(Image25,ImageListLedsOut);
  OutLeds[09].AssignImages(Image26,ImageListLedsOut);
  OutLeds[10].AssignImages(Image27,ImageListLedsOut);
  OutLeds[11].AssignImages(Image28,ImageListLedsOut);

  OutLeds[12].AssignImages(Image29,ImageListLedsOut);
  OutLeds[13].AssignImages(Image30,ImageListLedsOut);
  OutLeds[14].AssignImages(Image31,ImageListLedsOut);
  OutLeds[15].AssignImages(Image32,ImageListLedsOut);

  InLedsLabels[00]:=Label1;
  InLedsLabels[01]:=Label2;
  InLedsLabels[02]:=Label3;
  InLedsLabels[03]:=Label4;

  InLedsLabels[04]:=Label5;
  InLedsLabels[05]:=Label6;
  InLedsLabels[06]:=Label7;
  InLedsLabels[07]:=Label8;

  InLedsLabels[08]:=Label9;
  InLedsLabels[09]:=Label10;
  InLedsLabels[10]:=Label11;
  InLedsLabels[11]:=Label12;

  InLedsLabels[12]:=Label13;
  InLedsLabels[13]:=Label14;
  InLedsLabels[14]:=Label15;
  InLedsLabels[15]:=Label16;

  OutLedsLabels[00]:=Label17;
  OutLedsLabels[01]:=Label18;
  OutLedsLabels[02]:=Label19;
  OutLedsLabels[03]:=Label20;

  OutLedsLabels[04]:=Label21;
  OutLedsLabels[05]:=Label22;
  OutLedsLabels[06]:=Label23;
  OutLedsLabels[07]:=Label24;

  OutLedsLabels[08]:=Label25;
  OutLedsLabels[09]:=Label26;
  OutLedsLabels[10]:=Label27;
  OutLedsLabels[11]:=Label28;

  OutLedsLabels[12]:=Label25;
  OutLedsLabels[13]:=Label26;
  OutLedsLabels[14]:=Label27;
  OutLedsLabels[15]:=Label28;

  GroupBox29.Visible:=False;
  GroupBox30.Visible:=False;
  GroupBox31.Visible:=False;
  GroupBox32.Visible:=False;

  RGForcingsIn[0]:=RadioGroup1;
  RGForcingsIn[1]:=RadioGroup2;
  RGForcingsIn[2]:=RadioGroup3;
  RGForcingsIn[3]:=RadioGroup4;

  RGForcingsIn[4]:=RadioGroup5;
  RGForcingsIn[5]:=RadioGroup6;
  RGForcingsIn[6]:=RadioGroup7;
  RGForcingsIn[7]:=RadioGroup8;

  RGForcingsIn[8]:=RadioGroup9;
  RGForcingsIn[9]:=RadioGroup10;
  RGForcingsIn[10]:=RadioGroup11;
  RGForcingsIn[11]:=RadioGroup12;

  RGForcingsIn[12]:=RadioGroup13;
  RGForcingsIn[13]:=RadioGroup14;
  RGForcingsIn[14]:=RadioGroup15;
  RGForcingsIn[15]:=RadioGroup16;

  RGForcingsOut[0]:=RadioGroup17;
  RGForcingsOut[1]:=RadioGroup18;
  RGForcingsOut[2]:=RadioGroup19;
  RGForcingsOut[3]:=RadioGroup20;

  RGForcingsOut[4]:=RadioGroup21;
  RGForcingsOut[5]:=RadioGroup22;
  RGForcingsOut[6]:=RadioGroup23;
  RGForcingsOut[7]:=RadioGroup24;

  RGForcingsOut[8]:=RadioGroup25;
  RGForcingsOut[9]:=RadioGroup26;
  RGForcingsOut[10]:=RadioGroup27;
  RGForcingsOut[11]:=RadioGroup28;

  RGForcingsOut[12]:=RadioGroup29;
  RGForcingsOut[13]:=RadioGroup30;
  RGForcingsOut[14]:=RadioGroup31;
  RGForcingsOut[15]:=RadioGroup32;

  for i := 0 to 15 do begin
    (RGForcingsIn[i].Components[0] as TRadioButton).ShowHint:=True;
    (RGForcingsIn[i].Components[1] as TRadioButton).ShowHint:=True;
    (RGForcingsIn[i].Components[2] as TRadioButton).ShowHint:=True;
    (RGForcingsIn[i].Components[0] as TRadioButton).Hint:='Not Forced (read from simulation)';
    (RGForcingsIn[i].Components[1] as TRadioButton).Hint:='Force to 0';
    (RGForcingsIn[i].Components[2] as TRadioButton).Hint:='Force to 1';
  end;

  for i := 0 to 15 do begin
    (RGForcingsOut[i].Components[0] as TRadioButton).ShowHint:=True;
    (RGForcingsOut[i].Components[1] as TRadioButton).ShowHint:=True;
    (RGForcingsOut[i].Components[2] as TRadioButton).ShowHint:=True;
    (RGForcingsOut[i].Components[0] as TRadioButton).Hint:='Not Forced (controlled by script)';
    (RGForcingsOut[i].Components[1] as TRadioButton).Hint:='Force to 0';
    (RGForcingsOut[i].Components[2] as TRadioButton).Hint:='Force to 1';
  end;

  UpdateNames;

end;


{
procedure TFIOLeds.Timer1Timer(Sender: TObject);
var i : integer;
begin
  with timer1 do begin
    Tag:=(tag+1) mod 16;

    for i:=0 to 15 do
      InLeds[i].status:=(((3 shl tag) AND (1 shl i)) > 0);

    for i:=0 to 11 do
      OutLeds[i].status:=(((3 shl tag) AND (1 shl i)) > 0);

    for i:=0 to 15 do InLedsLabels[i].Caption:=format('%%%02d.%02d - %d',[1,i,(((3 shl tag) AND (1 shl i)))]);
    for i:=0 to 11 do OutLedsLabels[i].Caption:=format('%%%02d.%02d - %d',[2,i,(((3 shl tag) AND (1 shl i)))]);

  end;
end;
}

procedure TFIOLeds.FormShow(Sender: TObject);
begin
  CreateLeds;

end;

procedure TFIOLeds.PLCStateToIOLeds(var PLCState : TPLCState);
var i : integer;
begin
  for i:=0 to 15 do if not ForcingIn(i)  then InLeds[i].Status :=PLCState.InBits[i];
  for i:=0 to 11 do if not ForcingOut(i) then OutLeds[i].Status:=PLCState.OutBits[i];
end;

procedure TFIOLeds.ILedsToPLCState(var PLCState : TPLCState);
var i : integer;
begin
  for i:=0 to 15 do if ForcingIn(i) then PLCState.InBits[i] :=InLeds[i].Status;
end;

procedure TFIOLeds.OLedsToPLCState(var PLCState : TPLCState);
var i : integer;
begin
  for i:=0 to 11 do
    if ForcingOut(i) then
      PLCState.OutBits[i]:=OutLeds[i].Status;
end;


procedure TFIOLeds.FormCreate(Sender: TObject);
begin
  CreateLeds;
end;


procedure TFIOLeds.UpdateNames;
var
 perc,user : string;
 i : integer;
begin
  for i:=0 to 15 do begin
    perc:=format('%%I%d.%d',[1,i]);
    user:=GetUserNameFromPercentName(perc);
    if (user<>'') and (user<>' ') then
      if not CBShowPercentNames.Checked then
        InLedsLabels[i].Caption := user
      else
        InLedsLabels[i].Caption:=format('%s = %s',[perc,user])
    else
      InLedsLabels[i].Caption:=perc;
  end;
  for i:=0 to 11 do begin
    perc:=format('%%Q%d.%d',[2,i]);
    user:=GetUserNameFromPercentName(perc);
    if (user<>'') and (user<>' ') then
      if not CBShowPercentNames.Checked then
        OutLedsLabels[i].Caption:=user
      else
        OutLedsLabels[i].Caption:=format('%s = %s',[perc,user])
    else
      OutLedsLabels[i].Caption:=perc;
  end;
end;



procedure TFIOLeds.FormDestroy(Sender: TObject);
var i : integer;
begin
  for i:=low(InLeds)  to High(InLeds ) do InLeds [i].Free;
  for i:=low(OutLeds) to High(OutLeds) do OutLeds[i].Free;
end;


procedure TFIOLeds.RadioGroupsClick(Sender: TObject);
var n : integer;
begin
  n:=(Sender as TRadioGroup).Tag;
  if (n<16) then begin
    InLeds[n].status:= (RGForcingsIn[n]. ItemIndex=2);
  end else begin
    n:=n-16;
    OutLeds[n].status:=(RGForcingsOut[n].ItemIndex=2);
  end;
end;

procedure TFIOLeds.CBShowPercentNamesClick(Sender: TObject);
begin
  UpdateNames;
end;

end.


