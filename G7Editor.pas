unit G7Editor;
{$MODE Delphi}          

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  {FA_TAG:

  SynHighlighterST,SynHighlighterGeneral,

    }
   SynEditHighlighter,  SynEdit;

type
  TFG7Editor = class(TForm)
{FA_TAG:
    SynGeneralSyn1: TSynGeneralSyn;
    SynSTSyn1: TSynSTSyn;

}

    SynEdit: TSynEdit;
    BOk: TButton;
    BCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FG7Editor: TFG7Editor;

implementation

{$R *.lfm}

end.
