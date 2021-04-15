unit Editor;
{$MODE Delphi}          

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SynHighlighterST, SynEditHighlighter,
  SynHighlighterGeneral, SynEdit;

type
  TFEditor = class(TForm)
    SynEdit: TSynEdit;
    SynGeneralSyn1: TSynGeneralSyn;
    SynSTSyn1: TSynSTSyn;
    BOk: TButton;
    BCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FEditor: TFEditor;

implementation

{$R *.dfm}

end.
