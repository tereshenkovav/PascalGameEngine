unit TaskBGRunner;

interface

uses Classes ;

type
  IProgressGetter = interface
    procedure SetValue(v:Integer) ;
    procedure SetMessage(s:string) ;
  end ;

  TBackgroundTask = function(pg:IProgressGetter):TObject of object ;

  { TTaskBGRunner }

  TTaskBGRunner = class(TInterfacedObject,IProgressGetter)
  private
    res:TObject ;
    isready:Boolean ;
    thread:TThread ;
    v:Integer ;
    s:string ;
  public
    procedure RunTaskIfNot(task:TBackgroundTask) ;
    function isTaskReady():Boolean ;
    function getResult():TObject ;
    function getProgressValue():Integer ;
    function getProgressMessage():string ;
    procedure SetValue(v:Integer) ;
    procedure SetMessage(s:string) ;
  end;

implementation

{ TTaskBGRunner }

function TTaskBGRunner.getProgressMessage: string;
begin
  Result:=s ;
end;

function TTaskBGRunner.getProgressValue: Integer;
begin
  Result:=v ;
end;

function TTaskBGRunner.getResult: TObject;
begin
  Result:=res ;
end;

function TTaskBGRunner.isTaskReady: Boolean;
begin
  Result:=isready ;
end;

procedure TTaskBGRunner.RunTaskIfNot(task: TBackgroundTask);
begin
  if thread<>nil then Exit ;

  thread:=TThread.CreateAnonymousThread(procedure()
  begin
    isready:=False ;
    res:=task(Self) ;
    isready:=True ;
  end) ;
  thread.Start() ;
end;

procedure TTaskBGRunner.SetMessage(s: string);
begin
  Self.s:=s ;
end;

procedure TTaskBGRunner.SetValue(v: Integer);
begin
  Self.v:=v ;
end;

end.
