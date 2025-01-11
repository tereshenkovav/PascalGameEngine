unit ScreenSaver;

interface

uses
  Classes, SysUtils, syncobjs,
  SfmlGraphics,SfmlWindow,
  Helpers, Scene ;

type
  TScreenSaver = class
    procedure Update(dt:Single; events:TUniList<TSfmlEventEx>) ; virtual ;
    procedure DealWithWindowIfNeed(window:TSfmlRenderWindow) ; virtual ;
  end;

  TScreenSaverNull = class(TScreenSaver)
  end;

  TScreenSaverStd = class(TScreenSaver)
  private
    fps:Integer ;
    gamecode:string ;
    keyonce,keystartrec,keystoprec:TSfmlKeyCode ;
    screenshots:TUniList<TSfmlImage> ;
    screenrect:TSfmlIntRect ;
    makescreenshot:Boolean ;
    recscreenshotseq:Boolean ;
    leftforscreenseq:Single ;
  public
    constructor Create(Agamecode:string; Akeyonce,Akeystartrec,Akeystoprec:TSfmlKeyCode) ;
    destructor Destroy ; override ;
    procedure setSeqFPS(value:Integer) ;
    procedure Update(dt:Single; events:TUniList<TSfmlEventEx>) ; override ;
    procedure DealWithWindowIfNeed(window:TSfmlRenderWindow) ; override ;
  end;

implementation
uses Math, StrUtils,
  commonproc, ScriptExecutor, waysearch, HomeDir ;

type

  { TFileSaverThread }

  TFileSaverThread = class(TThread)
  protected
    procedure Execute; override;
  private
    gamecode:string ;
    images:TUniList<TSfmlImage> ;
    nextidx:Integer ;
    function getFreeScreenshotFile: string;
  public
    constructor Create(Aimages:TUniList<TSfmlImage>; Agamecode:string) ;
  end;

{ TFileSaverThread }

function TFileSaverThread.getFreeScreenshotFile: string;
var idx:Integer ;
begin
  for idx := nextidx to High(nextidx) do begin
    Result:=Format('screen_%.6d.png',[idx]) ;
    if not FileExists(THomeDir.getFileNameInHome(gamecode,Result)) then begin
      nextidx:=idx+1 ;
      Exit ;
    end ;
  end;
end;

constructor TFileSaverThread.Create(Aimages:TUniList<TSfmlImage>; Agamecode:string);
begin
  inherited Create(True);
  images:=TUniList<TSfmlImage>.Create(Aimages) ;
  gamecode:=Agamecode ;
  nextidx:=0 ;
end;

procedure TFileSaverThread.Execute;
var i:Integer ;
begin
  i:=0 ;
  for i := 0 to images.Count-1 do begin
    images[i].SaveToFile(THomeDir.getFileNameInHome(gamecode,getFreeScreenshotFile())) ;
    images[i].Free ;
  end ;
  images.Free() ;
end;

{ TScreenSaver }

procedure TScreenSaver.DealWithWindowIfNeed(window: TSfmlRenderWindow);
begin
// Nothing
end;

procedure TScreenSaver.Update(dt:Single; events: TUniList<TSfmlEventEx>);
begin
// Nothing
end;

{ TScreenSaverStd }

constructor TScreenSaverStd.Create(Agamecode: string; Akeyonce, Akeystartrec,
  Akeystoprec: TSfmlKeyCode);
begin
  inherited Create() ;
  gamecode:=Agamecode ;
  keyonce:=Akeyonce ;
  keystartrec:=Akeystartrec ;
  keystoprec:=Akeystoprec ;

  fps:=15 ;
  screenshots:=TUniList<TSfmlImage>.Create() ;

  screenrect.Top:=0 ;
  screenrect.Left:=0 ;
  leftforscreenseq:=-1 ;

  makescreenshot:=False ;
end;

procedure TScreenSaverStd.DealWithWindowIfNeed(window: TSfmlRenderWindow);
var screenshot:TSfmlImage ;
    fs:TFileSaverThread ;
begin
  if not makescreenshot then Exit ;

  makescreenshot:=False ;
  screenrect.Width:=window.Size.X ;
  screenrect.Height:=window.Size.Y ;
  screenshot:=TSfmlImage.Create(window.Size.X,window.Size.Y) ;
  screenshot.CopyImage(window.Capture(),0,0,screenrect,False) ;
  screenshots.Add(screenshot) ;
  if not recscreenshotseq then begin
    fs:=TFileSaverThread.Create(screenshots,gamecode) ;
    fs.Start() ;
  end;
end;

destructor TScreenSaverStd.Destroy;
begin
  screenshots.Free ;
  inherited Destroy ;
end;

procedure TScreenSaverStd.setSeqFPS(value: Integer);
begin
  fps:=value ;
end;

procedure TScreenSaverStd.Update(dt:Single; events: TUniList<TSfmlEventEx>);
var eventex:TSfmlEventEx ;
    fs:TFileSaverThread ;
begin
  for eventex in events do
    if (eventex.event.EventType = sfEvtKeyPressed) then begin
      if (eventex.event.key.code = keyonce) and (not recscreenshotseq) then begin
        screenshots.Clear();
        makescreenshot:=True;
      end;
      if (eventex.event.key.code = keystartrec) and (not recscreenshotseq) then begin
        recscreenshotseq:=True;
        screenshots.Clear();
      end;
      if (eventex.event.key.code = keystoprec) and (recscreenshotseq) then begin
        fs := TFileSaverThread.Create(screenshots, gamecode);
        fs.Start();
        recscreenshotseq:=False;
      end;
    end;

  if recscreenshotseq then begin
    if leftforscreenseq<=0 then begin
      leftforscreenseq:=1.0/fps;
      makescreenshot:=True;
    end
    else
      leftforscreenseq:=leftforscreenseq-dt;
  end;
end;

end.
