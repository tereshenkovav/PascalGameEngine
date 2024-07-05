unit Logger;

interface

type
  { TLogger }

  TLoggerClass = class of TLogger ;

  TLogger = class
  protected
    gamedir:string ;
    initok:Boolean ;
  public
    constructor Create(Agamedir:string) ;
    destructor Destroy ; override ;
    procedure InitLog() ; virtual ; abstract ;
    procedure CloseLog() ; virtual ; abstract ;
    procedure WriteLog(const s:string) ; virtual ; abstract ;
  end;

  TLoggerNull = class(TLogger)
  public
    procedure InitLog() ; override ;
    procedure CloseLog() ; override ;
    procedure WriteLog(const s:string) ; override ;
  end;

  TLoggerBasic = class(TLogger)
  private
    f:text ;
    function getLogFile():string ;
  public
    procedure InitLog() ; override ;
    procedure CloseLog() ; override ;
    procedure WriteLog(const s:string) ; override ;
  end;

implementation
uses SysUtils,
  Helpers ;

{ TLogger }

constructor TLogger.Create(Agamedir:string);
begin
  gamedir:=Agamedir ;
  initok:=False ;
  InitLog() ;
end;

destructor TLogger.Destroy();
begin
  if initok then CloseLog() ;
end;

{ TLoggerNull }

procedure TLoggerNull.WriteLog(const s:string) ;
begin
end;

procedure TLoggerNull.InitLog() ;
begin
end;

procedure TLoggerNull.CloseLog() ;
begin
end;

{ TLoggerBasic }

procedure TLoggerBasic.WriteLog(const s:string) ;
begin
  if not initok then InitLog() ;
  Writeln(f,s) ;
  Flush(f) ;
end;

procedure TLoggerBasic.InitLog() ;
begin
  if initok then Exit ;
  AssignFile(f,getLogFile()) ;
  ReWrite(f) ;
  initok:=True ;
end;

procedure TLoggerBasic.CloseLog() ;
begin
  if not initok then Exit ;
  Flush(f) ;
  CloseFile(f) ;
  initok:=False ;
end;

function TLoggerBasic.getLogFile(): string;
var dir:string ;
begin
  {$ifdef unix}
  dir:=GetEnvironmentVariable('HOME')+'/.local/share/'+gamedir ;
  {$else}
  dir:=GetEnvironmentVariable('LOCALAPPDATA')+PATH_SEP+gamedir ;
  {$endif}
  if not DirectoryExists(dir) then ForceDirectories(dir) ;
  Result:=dir+PATH_SEP+'start.log' ;
end;

end.

