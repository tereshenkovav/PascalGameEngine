unit SceneOpenGL;

interface

uses
  Classes, SysUtils,
  SfmlGraphics,
  Scene, Helpers ;

type

  TOpenGLRender = class
  public
    procedure Render() ; virtual ; abstract ;
  end;

  { TSceneOpenGL }

  TSceneOpenGL = class(TScene)
  private
    tex:TSfmlRenderTexture ;
    spr:TSfmlSprite ;
    prepared:Boolean ;
    w,h,x,y:Integer ;
    color:TSfmlColor ;
    render:TOpenGLRender ;
    procedure UpdateScene() ;
  public
    constructor Create(Ax,Ay,Aw,Ah:Integer; Acolor:TSfmlColor; Arender:TOpenGLRender) ;
    function Init():Boolean ; override ;
    function FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ; override ;
    procedure RenderFunc() ; override ;
    procedure UnInit() ; override ;
    procedure Reset() ;
  end;

implementation
uses SfmlUtils ;

constructor TSceneOpenGL.Create(Ax,Ay,Aw,Ah:Integer; Acolor:TSfmlColor;
  Arender:TOpenGLRender);
begin
  x:=Ax ;
  y:=Ay ;
  w:=Aw ;
  h:=Ah ;
  color:=Acolor ;
  render:=Arender ;
end;

function TSceneOpenGL.Init():Boolean ;
begin
  tex:=TSfmlRenderTexture.Create(w,h,true) ;
  spr:=TSfmlSprite.Create() ;
  prepared:=False ;
end ;

function TSceneOpenGL.FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ;
begin
  Result:=Normal ;
end ;

procedure TSceneOpenGL.RenderFunc() ;
begin
  if not prepared then UpdateScene() ;
  DrawSprite(spr,x,y) ;
end ;

procedure TSceneOpenGL.Reset;
begin
  prepared:=False ;
end;

procedure TSceneOpenGL.UnInit() ;
begin
  spr.Free ;
  tex.Free ;
end ;

procedure TSceneOpenGL.UpdateScene;
begin
  tex.clear(color) ;
  if Assigned(render) then render.Render() ;
  tex.Display() ;
  spr.SetTexture(tex.Texture,True) ;
  prepared:=True ;
end;

end.

