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
    procedure WriteLogFmt(const fmt:string; params:array of const) ;
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
  public
    procedure InitLog() ; override ;
    procedure CloseLog() ; override ;
    procedure WriteLog(const s:string) ; override ;
  end;

implementation
uses SysUtils,
  HomeDir ;

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

procedure TLogger.WriteLogFmt(const fmt:string; params:array of const) ;
begin
  WriteLog(Format(fmt,params)) ;
end ;

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
  THomeDir.createDirInHomeIfNeed(gamedir) ;
  AssignFile(f,THomeDir.getFileNameInHome(gamedir,'start.log')) ;
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

end.

