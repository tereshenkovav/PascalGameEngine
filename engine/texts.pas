unit Texts;

interface

uses
  Classes, SysUtils ;

type
  { Texts }

  TTexts = class
  private
    texts:TStringList ;
  protected
  public
    constructor Create() ;
    destructor Destroy ; override ;
    procedure loadFromFile(filename:string) ;
    function getText(name:string):string ;
  end;

implementation

{ TTexts }

constructor TTexts.Create;
begin
  texts:=TStringList.Create() ;
end;

destructor TTexts.Destroy;
begin
  texts.Free ;
  inherited Destroy ;
end;

function TTexts.getText(name: string): string;
begin
  if texts.IndexOfName(name.ToUpper())<>-1 then
    Result:=texts.Values[name.ToUpper()].Replace('\n',chr(10))
  else Result:='???';
end;

procedure TTexts.loadFromFile(filename: string);
begin
  texts.LoadFromFile(filename) ;
end;

end.

