unit G7Project;
{$MODE Delphi}          

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Grids;

type

  { TFG7Project }

  TFG7Project = class(TForm)
    BOK: TButton;
    BCancel: TButton;
    PageControl: TPageControl;
    TabConfig: TTabSheet;
    TabIOModules: TTabSheet;
    TabVariables: TTabSheet;
    CBVarType: TComboBox;
    SGVariables: TStringGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FG7Project: TFG7Project;

implementation

{$R *.dfm}

procedure TFG7Project.FormCreate(Sender: TObject);
begin
  with SGVariables do begin
    Cells[0,0]:='Name';
    Cells[1,0]:='Type';
    Cells[2,0]:='Mode';
    Cells[3,0]:='Binding';
    Cells[4,0]:='Comment';
  end;
end;


end.
