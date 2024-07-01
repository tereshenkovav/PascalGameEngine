unit MenuKeyboardTextIcon;

interface

uses
  Classes, SysUtils,
  SfmlSystem,SfmlWindow,SfmlGraphics,
  Helpers, Scene ;

type
  { MenuKeyboardTextIcon }

  TMenuKeyboardTextIcon = class(TScene)
  private
    font:TSfmlFont ;
    size:Integer ;
    color:TSfmlColor ;
    x,y,h,w:Integer ;
    cols:Integer ;
    items:TUniList<TSfmlText> ;
    icons:TUniList<TSfmlSprite> ;
    rect:TSfmlRectangleShape ;
    selindex:Integer ;
  protected
  public
    constructor Create(Ax,Ay,Aw,Ah:Integer; Acols:Integer;
      Afont:TSfmlFont; Asize:Integer; Acolor:TSfmlColor) ;
    procedure clearItems() ;
    procedure addItem(str:string; icon:TSfmlSprite) ;
    function getSelIndex():Integer ;
    function Init():Boolean ; override ;
    function FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ; override ;
    procedure RenderFunc() ; override ;
    procedure UnInit() ; override ;
  end;

implementation
uses sfmlutils, Math ;

{ TMenuKeyboardTextIcon }

function TMenuKeyboardTextIcon.Init():Boolean ;
begin
  Result:=True ;
end ;

procedure TMenuKeyboardTextIcon.addItem(str: string; icon:TSfmlSprite);
begin
  items.Add(createText(font,str,size,color)) ;
  icons.Add(icon) ;
end;

procedure TMenuKeyboardTextIcon.clearItems;
var i:Integer ;
begin
  for i := 0 to items.Count-1 do
    items[i].Free ;
  items.Clear() ;
  icons.Clear() ;
end;

constructor TMenuKeyboardTextIcon.Create(Ax,Ay,Aw,Ah:Integer; Acols:Integer;
      Afont:TSfmlFont; Asize:Integer; Acolor:TSfmlColor);
begin
  x:=Ax ;
  y:=Ay ;
  w:=Aw ;
  h:=Ah ;
  cols:=Acols ;
  font:=Afont ;
  color:=Acolor ;
  size:=Asize ;
  selindex:=0 ;
  items:=TUniList<TSfmlText>.Create() ;
  icons:=TUniList<TSfmlSprite>.Create() ;
  rect:=TSfmlRectangleShape.Create() ;
  rect.OutlineThickness:=1;
  rect.FillColor:=SfmlColorFromRGBA(0,0,0,0) ;
  rect.OutlineColor:=AColor ;
end;

function TMenuKeyboardTextIcon.FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ;
var event:TSfmlEventEx ;
begin
  Result:=TSceneResult.Normal ;
  for event in events do
    if (event.event.EventType = sfEvtKeyPressed) then begin
      if (event.event.key.code = sfKeyLeft) then
        if selindex>0 then Dec(selindex) ;
      if (event.event.key.code = sfKeyRight) then
        if selindex<items.Count-1 then Inc(selindex) ;
      if (event.event.key.code = sfKeyUp) then
        selindex:=Max(0,selindex-cols) ;
      if (event.event.key.code = sfKeyDown) then
        selindex:=Min(items.Count-1,selindex+cols) ;
    end ;
end ;

function TMenuKeyboardTextIcon.getSelIndex: Integer;
begin
  Result:=selindex ;
end;

procedure TMenuKeyboardTextIcon.RenderFunc() ;
var i:Integer ;
    maxh:Single ;
begin
  maxh:=0 ;
  for i := 0 to items.Count-1 do
    maxh:=Max(items[i].LocalBounds.Height,maxh) ;

  for i := 0 to items.Count-1 do begin
    items[i].Color:=ConvertSFMLColorBright(Color,IfThen(i=selindex,1.0,0.66)) ;
    icons[i].Color:=CreateSFMLColor(IfThen(i=selindex,$FFFFFF,$A0A0A0)) ;

    drawTextCentered(items[i],x+(i mod cols)*w,y+(i div cols)*h) ;
    drawSprite(icons[i],x+(i mod cols)*w,y+(i div cols)*h+maxh+15) ;
    if i=selindex then begin
      rect.Position:=SfmlVector2f(icons[i].Position.X-5,icons[i].Position.Y-5) ;
      rect.Origin:=SfmlVector2f(icons[i].LocalBounds.Width/2,0) ;
      rect.Size:=SfmlVector2f(icons[i].LocalBounds.Width+10,icons[i].LocalBounds.Height+10) ;
      window.Draw(rect) ;
    end;
  end;
end ;

procedure TMenuKeyboardTextIcon.UnInit() ;
begin
  clearItems() ;
  items.Free ;
  icons.Free ;
  rect.Free ;
end ;

end.

