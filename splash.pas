unit splash;
{$MODE Delphi}          
interface

uses
  {$IFDEF Windows}
    Windows,
  {$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Win32Proc
  //,lazjpg
  ;

type

  { TFormSplash }

  TFormSplash = class(TForm)
    Image1: TImage;
    Label3: TLabel;
    Label4: TLabel;
    LabelVersionString: TLabel;
    LabelWinVerString: TLabel;
    Panel_Splash: TPanel;
    procedure FormClick(Sender: TObject);
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSplash: TFormSplash;

implementation

{$R *.lfm}

uses main;


procedure TFormSplash.FormClick(Sender: TObject);
begin
  FormSplash.Close;
end;

procedure TFormSplash.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FormSplash.Close;
end;



// https://wiki.lazarus.freepascal.org/WindowsVersion
Function  GetWinVer : string;
Begin
       if WindowsVersion = wv95 then   Result := 'Windows 95'
  else if WindowsVersion = wvNT4 then  Result := 'Windows NT v.4'
  else if WindowsVersion = wv98 then   Result := 'Windows 98'
  else if WindowsVersion = wvMe then   Result := 'Windows ME'
  else if WindowsVersion = wv2000 then Result := 'Windows 2000'
  else if WindowsVersion = wvXP then   Result := 'Windows XP'
  else if WindowsVersion = wvServer2003 then Result := 'Windows Server 2003/Windows XP64'
  else if WindowsVersion = wvVista then Result := 'Windows Vista'
  else if WindowsVersion = wv7 then Result := 'Windows 7'
  else if WindowsVersion = wv10 then Result := 'Windows 10'
  else Result := 'Windows Unknown Version!';
End;


//https://forum.lazarus.freepascal.org/index.php?topic=43030.0
procedure TFormSplash.FormCreate(Sender: TObject);
begin
  LabelVersionString.Caption:=VersionString+DateToStr(FileDateToDateTime(FileAge(Application.ExeName) ));
  LabelWinVerString.Caption :=
      {$ifdef mswindows}
      'Windows'
    {$else}
      {$i %FPCTargetOS%}
    {$endif}
      + Format(' %d-bit', [SizeOf(Pointer) * 8]);
  LabelWinVerString.Caption := 'Executable '+LabelWinVerString.Caption+' - ' +GetWinVer();

end;

procedure TFormSplash.FormKeyPress(Sender: TObject; var Key: Char);
begin
  FormSplash.Close;
end;

end.
