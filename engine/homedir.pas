unit HomeDir;

interface

type
  { THomeDir }

  THomeDir = class
  private
    class function getDirInHome(const gamecode:string):string ;
  public
    class function getFileNameInHome(const gamecode:string; const filename:string):string ;
    class procedure createDirInHomeIfNeed(const gamecode:string) ;
  end;

implementation
uses SysUtils,
  Helpers ;

{ THomeDir }

class function THomeDir.getDirInHome(const gamecode:string):string ;
begin
  {$ifdef unix}
  Result:=GetEnvironmentVariable('HOME')+'/.local/share/'+gamecode ;
  {$else}
  Result:=GetEnvironmentVariable('LOCALAPPDATA')+PATH_SEP+gamecode ;
  {$endif}
end;

class function THomeDir.getFileNameInHome(const gamecode:string; const filename:string):string ;
begin
  Result:=getDirInHome(gamecode)+PATH_SEP+filename ;
end ;

class procedure THomeDir.createDirInHomeIfNeed(const gamecode:string) ;
begin
  if not DirectoryExists(getDirInHome(gamecode)) then 
    ForceDirectories(getDirInHome(gamecode)) ;
end ;

end.
