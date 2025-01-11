unit Game;

interface

uses
  Classes, SysUtils,
  SfmlGraphics,SfmlSystem,SfmlWindow,
  Scene, Profile, Logger, ScreenSaver;

type

  { TGame }

  TGame = class
  private
    window: TSfmlRenderWindow;
    clock:TSfmlClock ;
    mode: TSfmlVideoMode;
    tekscene: TScene ;
    subscene: TScene ;
    prevscene: TScene ;
    icon:TSfmlImage ;
    title:string ;
    gamecode:string ;
    closehandler:TScene ;
    profile:TProfile ;
    logger:TLogger ;
    screensaver:TScreenSaver ;
    tekfps:Integer ;
    showfpsintitle:Boolean ;
    procedure initNewScene(scene:TScene) ;
  public
    constructor Create(width,height:Integer; Agamecode,Atitle:string; iconfile:string='') ;
    procedure setCloseHandler(Ascene:TScene) ;
    procedure setCustomProfile(profileclass:TProfileClass) ;
    procedure setCustomLogger(loggerclass:TLoggerClass) ;
    procedure enableFPSInTitle(value:Boolean) ;
    procedure setCustomScreenSaver(Ascreensaver:TScreenSaver) ;
    function getProfile():TProfile ;
    function getLogger():TLogger ;
    function getGameCode():string ;
    procedure Run(initscene:TScene) ;
    destructor Destroy() ; override ;
  end;

implementation
uses Helpers, HomeDir ;

{ TGame }

constructor TGame.Create(width,height:Integer; Agamecode,Atitle:string; iconfile:string='');
begin
  Randomize() ;

  mode.Width := width;
  mode.Height := height;
  mode.BitsPerPixel := 32;
  {$ifndef Darwin}
  if not SfmlVideoModeIsValid(Mode) then
    raise Exception.Create('Invalid video mode');
  {$endif}

  title:=Atitle ;
  gamecode:=Agamecode ;
  profile:=TProfile.Create(gamecode) ;
  logger:=TLoggerNull.Create(gamecode) ;
  screensaver:=TScreenSaverNull.Create() ;
  showfpsintitle:=False ;

  if iconfile<>'' then icon:=TSfmlImage.Create(iconfile) else icon:=nil ;
end ;

procedure TGame.Run(initscene:TScene);
var lasttime,newtime,timefps:Single ;
    calcfps:Integer ;
    sr:TSceneResult ;
    event:TSfmlEvent ;
    events:TUniList<TSfmlEventEx> ;
    activescene:TScene ;
    closehandled:Boolean ;
    lastfocused:Boolean ;

label rebuild_window ;
begin
  profile.Load() ;
  prevscene:=nil ;
  subscene:=nil ;
  tekscene:=initscene ;
rebuild_window:
  if profile.isFullScreen() then
    window := TSfmlRenderWindow.Create(mode, UTF8Decode(title),[sfFullscreen], nil)
  else
    window := TSfmlRenderWindow.Create(mode, UTF8Decode(title),[sfClose], nil);
  window.SetVerticalSyncEnabled(True);
  window.setFramerateLimit(60);
  window.SetKeyRepeatEnabled(False) ;
  window.SetMouseCursorVisible(False);
  if icon<>nil then window.SetIcon(icon.Size.X,icon.Size.Y,icon.getPixelsPtr());

  // Дублирование инициализации при смене окна
  initNewScene(closehandler) ;
  initNewScene(tekscene) ;
  initNewScene(tekscene.getOverScene()) ;

  events:=TUniList<TSfmlEventEx>.Create() ;

  clock:=TSfmlClock.Create() ;
  lasttime:=clock.ElapsedTime.AsSeconds() ;
  lastfocused:=True ;
  while window.IsOpen do begin
    closehandled:=False ;
    events.Clear ;
    while window.PollEvent(event) do begin
      if event.EventType = sfEvtClosed then begin
        closehandled:=True ;
      end
      else
        events.Add(TSfmlEventEx.Create(event)) ;
    end ;

    newtime:=clock.ElapsedTime.asSeconds() ;
    timefps:=timefps+(newtime-lasttime) ;
    Inc(calcfps) ;
    if timefps>=1 then begin
      tekfps:=calcfps ;
      calcfps:=0 ;
      timefps:=0 ;
      if showfpsintitle then window.SetTitle(UTF8Decode(title)+' FPS: '+IntToStr(tekfps)) ;
    end ;

    if subscene<>nil then activescene:=subscene else activescene:=tekscene ;

    if window.HasFocus() then begin

    if activescene.getOverScene()<>nil then begin
      activescene.getOverScene().setMousePos(window.MousePosition.X,window.MousePosition.Y) ;
      activescene.getOverScene().FrameFunc(newtime-lasttime,events) ;
    end ;
    activescene.setMousePos(window.MousePosition.X,window.MousePosition.Y) ;
    sr:=activescene.FrameFunc(newtime-lasttime,events) ;

    screensaver.Update(newtime-lasttime,events) ;

    if not lastfocused then begin
      if activescene.getOverScene()<>nil then
        activescene.getOverScene().FocusChanged(true) ;
      activescene.FocusChanged(true) ;
      lastfocused:=True ;
    end ;

    case sr of
      TSceneResult.Close: begin
        window.Close() ;
        break ;
      end;
      TSceneResult.Switch: begin
        if prevscene<>nil then begin
          tekscene:=prevscene ;
          prevscene:=nil ;
        end
        else begin
        if (subscene<>nil) then begin
          subscene.UnInit() ;
          subscene:=nil ;
        end;
        if tekscene.getOverScene()<>nil then tekscene.getOverScene().UnInit() ;
        tekscene.UnInit();
        tekscene:=activescene.getNextScene();
        initNewScene(tekscene) ;
        initNewScene(tekscene.getOverScene()) ;
        end ;
        continue ;
      end ;
      TSceneResult.RebuildWindow: begin
        tekscene.UnInit();
        tekscene:=activescene.getNextScene();
        window.Close() ;
        window.Free ;
        goto rebuild_window;
      end;
      TSceneResult.SetWindowTitle: begin
        title:=activescene.getNewWindowTitle() ;
        window.SetTitle(UTF8Decode(title)) ;
      end;
      TSceneResult.SetSubScene: begin
        subscene:=tekscene.getSubScene() ;
        initNewScene(subscene) ;
        continue ;
      end ;
      TSceneResult.ExitSubScene: begin
        subscene.UnInit() ;
        subscene:=nil ;
        tekscene.exitSubScene() ;
        continue ;
      end ;
    end ;

    end // window.hasFocus
    else begin
      if lastfocused then begin
        if activescene.getOverScene()<>nil then
          activescene.getOverScene().FocusChanged(false) ;
        activescene.FocusChanged(false) ;
        lastfocused:=False ;
      end;
    end;

    lasttime:=newtime ;

    if closehandled then begin
      if closehandler=nil then begin
        window.Close() ;
        break ;
      end
      else begin
        if tekscene<>closehandler then begin
          prevscene:=tekscene ;
          tekscene:=closehandler ;
        end;
      end;
    end ;

    window.Clear(SfmlBlack);
    tekscene.RenderFunc() ;
    if tekscene.getOverScene()<>nil then tekscene.getOverScene().RenderFunc() ;
    if subscene<>nil then subscene.RenderFunc() ;
    window.Display;

    screensaver.DealWithWindowIfNeed(window) ;
  end;
  logger.Free ;
  screensaver.Free ;
  if tekscene<>closehandler then tekscene.UnInit() ;
  if closehandler<>nil then closehandler.UnInit() ;
end;

procedure TGame.setCloseHandler(Ascene: TScene);
begin
  closehandler:=Ascene ;
end;

procedure TGame.setCustomProfile(profileclass: TProfileClass);
begin
  if profile<>nil then profile.Free ;
  profile:=profileclass.Create(gamecode) ;
end;

procedure TGame.setCustomLogger(loggerclass: TLoggerClass);
begin
  if logger<>nil then logger.Free ;
  logger:=loggerclass.Create(gamecode) ;
end;

destructor TGame.Destroy();
begin
  window.Free ;
  if icon<>nil then icon.Free ;
  
  inherited Destroy();
end;

procedure TGame.enableFPSInTitle(value: Boolean);
begin
  showfpsintitle:=value ;
end;

procedure TGame.setCustomScreenSaver(Ascreensaver:TScreenSaver) ;
begin
  screensaver:=Ascreensaver ;
end;

function TGame.getProfile: TProfile;
begin
  Result:=profile ;
end;

function TGame.getGameCode: string;
begin
  Result:=gamecode ;
end;

function TGame.getLogger: TLogger;
begin
  Result:=logger ;
end;

procedure TGame.initNewScene(scene: TScene);
begin
  if scene=nil then Exit ;

  scene.setWindow(window,mode.Width,mode.Height) ;
  scene.setProfile(profile) ;
  scene.setLogger(logger) ;
  scene.Init() ;
end;

end.

