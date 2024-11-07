unit Scene;

interface

uses
  Classes, SysUtils,
  SfmlSystem,SfmlWindow,SfmlGraphics,
  Helpers, SpriteEffects, Profile, Logger ;

type

  TSceneResult = (Normal,Close,Switch,SetSubScene,ExitSubScene,RebuildWindow,SetWindowTitle) ;

  TSfmlEventEx = record
    event:TSfmlEvent ;
    constructor Create(event:TSfmlEvent) ;
    class operator Equal(a: TSfmlEventEx; b: TSfmlEventEx): Boolean;
  end;

  TMirrorType = (MirrorHorz,MirrorVert) ;
  TMirrorTypeSet = set of TMirrorType ;

  { TScene }

  TScene = class
  private
  protected
    window:TSfmlRenderTarget ;
    profile:TProfile ;
    logger:TLogger ;
    wwidth:Integer ;
    wheight:Integer ;
    nextscene:TScene ;
    subscene:TScene ;
    overscene:TScene ;
    newwindowtitle:string ;
    mousex,mousey:Integer ;
    procedure drawSprite(spr:TSfmlSprite; x,y:Single) ;
    procedure drawSpriteEffect(se:TSpriteEffect; x,y:Single) ;
    procedure drawSpriteMirr(spr:TSfmlSprite; x,y:Single; mirrors:TMirrorTypeSet) ;
    procedure drawText(text:TSfmlText; x,y:Single) ;
    procedure drawTextCentered(text:TSfmlText; x,y:Single) ;
    procedure drawTextInBlockWidth(text: TSfmlText; str:string;
      x, y: Single; width:Integer; redlinewidth:Integer);
  public
    procedure setWindow(Awindow:TSfmlRenderTarget; Awidth,Aheight:Integer);
    procedure setProfile(Aprofile:TProfile) ;
    procedure setLogger(Alogger:TLogger) ;
    procedure setMousePos(Ax,Ay:Integer) ;
    function getNextScene():TScene ;
    function getSubScene():TScene ;
    function getOverScene():TScene ;
    function getNewWindowTitle():string ;
    procedure exitSubScene() ;
    function Init():Boolean ; virtual ;
    function FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ; virtual ;
    procedure RenderFunc() ; virtual ;
    procedure UnInit() ; virtual ;
    destructor Destroy() ; override ;
  end;

function IfThen(b:Boolean; v1,v2:TMirrorTypeSet):TMirrorTypeSet ; overload ;
function IfThen(b:Boolean; c1,c2:TSfmlColor):TSfmlColor ; overload ;

implementation

var
  scale_mirr_none,scale_mirr_horz,scale_mirr_vert,scale_mirr_both:TSfmlVector2f ;

function IfThen(b:Boolean; v1,v2:TMirrorTypeSet):TMirrorTypeSet ; overload ;
begin
  if b then Result:=v1 else Result:=v2 ;
end;

function IfThen(b:Boolean; c1,c2:TSfmlColor):TSfmlColor ; overload ;
begin
  if b then Result:=c1 else Result:=c2 ;
end ;

{ TScene }

function TScene.Init():Boolean ;
begin
  Result:=True ;
end ;

function TScene.FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ;
begin
  Result:=TSceneResult.Normal ;
end ;

function TScene.getNewWindowTitle: string;
begin
  Result:=newwindowtitle ;
end;

function TScene.getNextScene: TScene;
begin
  Result:=nextscene ;
end;

function TScene.getOverScene: TScene;
begin
  Result:=overscene ;
end;

function TScene.getSubScene: TScene;
begin
  Result:=subscene ;
end;

procedure TScene.exitSubScene() ;
begin
  subscene:=nil ;
end ;

procedure TScene.RenderFunc() ;
begin
end ;

procedure TScene.setLogger(Alogger: TLogger);
begin
  logger:=Alogger ;
end;

procedure TScene.setProfile(Aprofile: TProfile);
begin
  profile:=Aprofile ;
end;

procedure TScene.setWindow(Awindow: TSfmlRenderTarget; Awidth,
  Aheight: Integer);
begin
  window:=Awindow ;
  wwidth:=Awidth ;
  wheight:=Aheight ;
end;

procedure TScene.UnInit() ;
begin
end ;

destructor TScene.Destroy();
begin
  inherited Destroy();
end;

procedure TScene.drawSprite(spr: TSfmlSprite; x,
  y: Single);
begin
  spr.Position:=SfmlVector2f(x,y) ;
  window.draw(spr) ;
end;

procedure TScene.drawSpriteEffect(se: TSpriteEffect; x, y: Single);
begin
  se.getSprite().Position:=SfmlVector2f(x,y) ;
  se.Draw(window) ;
end;

procedure TScene.drawSpriteMirr(spr: TSfmlSprite; x, y: Single;
  mirrors: TMirrorTypeSet);
begin
  if MirrorHorz in mirrors then begin
    if MirrorVert in mirrors then
      spr.ScaleFactor:=scale_mirr_both
    else
      spr.ScaleFactor:=scale_mirr_horz ;
  end
  else begin
    if MirrorVert in mirrors then
      spr.ScaleFactor:=scale_mirr_vert
    else
      spr.ScaleFactor:=scale_mirr_none ;
  end ;
  drawSprite(spr,x,y) ;
end;

procedure TScene.drawText(text: TSfmlText; x,
  y: Single);
begin
  text.Position:=SfmlVector2f(x,y) ;
  window.Draw(text) ;
end;

procedure TScene.drawTextCentered(text: TSfmlText; x,
  y: Single);
begin
  text.Position:=SfmlVector2f(x-text.LocalBounds.Width/2,y) ;
  window.Draw(text) ;
end;

// Для работы переноса строк нужно, чтобы после переноса \n был пробел
procedure TScene.drawTextInBlockWidth(text: TSfmlText; str:string;
  x, y: Single; width:Integer; redlinewidth:Integer);
var words:TArray<string> ;
    line:string ;
    i:Integer ;
    isnewline:Boolean ;
begin
  words:=str.Split([' '],TStringSplitOptions.ExcludeEmpty) ;

  if Length(words)=0 then Exit ;

  line:=StringOfChar(' ',redlinewidth)+words[0] ;
  for i := 1 to Length(words)-1 do begin
    text.UnicodeString:=UTF8Decode(line+' '+words[i]) ;
    isnewline:=line.EndsWith(#10) ;
    if (text.LocalBounds.Width>=width)or isnewline then begin
      line:=line.Replace(#10,'') ;
      text.UnicodeString:=UTF8Decode(line) ;
      text.Position:=SfmlVector2f(x,y) ;
      window.Draw(text) ;
      y:=y+SfmlFontGetLineSpacing(text.Font,text.CharacterSize) ;
      line:=words[i] ;
      if isnewline then line:=StringOfChar(' ',redlinewidth)+line ;
    end
    else
      line:=line+' '+words[i] ;
  end;
  if line.Length>0 then begin
    text.Position:=SfmlVector2f(x,y) ;
    window.Draw(text) ;
  end;
end;

procedure TScene.setMousePos(Ax,Ay:Integer) ;
begin
  mousex:=Ax ;
  mousey:=Ay ;
end ;

{ TSfmlEventEx }

constructor TSfmlEventEx.Create(event: TSfmlEvent);
begin
  Self.event:=event ;
end;

class operator TSfmlEventEx.Equal(a: TSfmlEventEx; b: TSfmlEventEx): Boolean;
begin
  Result:=False ;
end;

initialization

  scale_mirr_none:=SfmlVector2f(1.0,1.0) ;
  scale_mirr_horz:=SfmlVector2f(-1.0,1.0) ;
  scale_mirr_vert:=SfmlVector2f(1.0,-1.0) ;
  scale_mirr_both:=SfmlVector2f(-1.0,-1.0) ;

end.

