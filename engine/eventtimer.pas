unit EventTimer;

interface

type
  TProc = reference to procedure ;

  { TEventTimer }

  TEventTimer = class
  private
    left:Single ;
    started:Boolean ;
    timerproc:TProc ;
  public
    constructor Create() ; overload ;
    constructor Create(value:Single; Atimerproc:TProc) ; overload ;
    function isActive():Boolean ;
    function isStarted():Boolean ;
    procedure Start(value:Single; Atimerproc:TProc) ;
    procedure Update(dt:Single) ;
  end;

implementation

{ TEventTimer }

constructor TEventTimer.Create;
begin
  left:=-1.0 ;
  started:=False ;
end;

constructor TEventTimer.Create(value: Single; Atimerproc: TProc);
begin
  Start(value,timerproc);
end;

function TEventTimer.isActive: Boolean;
begin
  Result:=left>0.0 ;
end;

function TEventTimer.isStarted: Boolean;
begin
  Result:=started ;
end;

procedure TEventTimer.Start(value: Single; Atimerproc: TProc);
begin
  left:=value ;
  timerproc:=Atimerproc ;
  started:=True ;
end;

procedure TEventTimer.Update(dt: Single);
begin
  if left>0.0 then begin
    left:=left-dt;
    if (left<=0.0) then timerproc();
  end ;
end;

end.
