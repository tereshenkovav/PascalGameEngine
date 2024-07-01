unit main ;

interface

procedure Run() ;

implementation
uses SfmlSystem, SfmlWindow, SfmlGraphics, 
  Game, Scene, Helpers, SfmlUtils ;

type
  TMyScene = class(TScene)
  private
    info:TSfmlText ;
    font:TSfmlFont ;
    logo:TSfmlSprite ;
    totaltime:Single ;
  public
    function Init():Boolean ; override ;
    function FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ; override ;
    procedure RenderFunc() ; override ;
    procedure UnInit() ; override ;
  end;

function TMyScene.Init():Boolean ;
begin
  font:=TSfmlFont.Create('arial.ttf');
  info:=createText(Font,'Press Escape to exit',28,SfmlWhite) ;
  logo:=loadSprite('logo.png',[sloCentered]) ;
  totaltime:=0 ;
  Result:=True ;
end ;

function TMyScene.FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ;
var event:TSfmlEventEx ;
begin
  Result:=Normal ;
  for event in events do
    if (event.event.EventType = sfEvtKeyPressed) then       
      if (event.event.key.code = sfKeyEscape) then 
        Exit(TSceneResult.Close) ;

  logo.ScaleFactor:=SfmlVector2f(1+0.5*Sin(totaltime),1+0.5*Cos(totaltime)) ;
  totaltime:=totaltime+dt ;
end ;

procedure TMyScene.RenderFunc() ;
begin
  DrawTextCentered(info,wwidth/2,50) ;
  DrawSprite(logo,wwidth/2,wheight/2) ;
end ;

procedure TMyScene.UnInit() ;
begin
  info.Free ;
  font.Free ;
  logo.Free ;
end ;

procedure Run() ;
var game:TGame ;
begin
  game:=TGame.Create(800,600,'Example','Pascal game engine') ;
  game.Run(TMyScene.Create()) ;
  game.Free ;
end ;

end.
