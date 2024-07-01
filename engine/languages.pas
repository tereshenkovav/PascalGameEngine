unit Languages;

interface

uses
  Classes, SysUtils ;

type
  { Languages }

  TLanguages = class
  private
    alllang:TStringList ;
    tek:Integer ;
  protected
  public
    constructor Create() ;
    destructor Destroy ; override ;
    procedure loadFromFile(filename:string) ;
    procedure setCurrentByFile(filename:string) ;
    procedure setCurrentByValue(lang:string) ;
    procedure switchCurrent() ;
    function getCurrent():string ;
    function formatFileNameWithLang(filename:string):string ;
  end;

implementation
uses helpers ;

{ TLanguages }

constructor TLanguages.Create;
begin
  alllang:=TStringList.Create() ;
  alllang.Add('ru') ;
  tek:=0 ;
end;

destructor TLanguages.Destroy;
begin
  alllang.Free ;
  inherited Destroy;
end;

function TLanguages.formatFileNameWithLang(filename: string): string;
var i:integer ;
begin
  Result:=filename+'.'+alllang[tek] ;
  for i:=length(filename) downto 1 do
    if filename[i]='.' then
      Exit(Copy(filename,1,i-1)+'.'+alllang[tek]+'.'+
        Copy(filename,i+1,length(filename)-i+1)) ;
end;

function TLanguages.getCurrent: string;
begin
  Result:=alllang[tek] ;
end;

procedure TLanguages.loadFromFile(filename: string);
begin
  alllang.LoadFromFile(filename) ;
end;

procedure TLanguages.setCurrentByFile(filename: string);
begin
  if FileExists(filename) then
    setCurrentByValue(Helpers.readAllText(filename).Trim()) ;
end;

procedure TLanguages.setCurrentByValue(lang: string);
begin
  if alllang.IndexOf(lang)<>-1 then tek:=alllang.IndexOf(lang) else tek:=0 ;
end;

procedure TLanguages.switchCurrent;
begin
  Inc(tek) ;
  if tek>=alllang.Count then tek:=0 ;
end;

end.

