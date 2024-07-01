unit MenuKeyboardText;

interface

uses
  Classes, SysUtils,
  SfmlSystem,SfmlWindow,SfmlGraphics,
  Helpers, Scene ;

type
  { MenuKeyboardText }

  TMenuKeyboardText = class(TScene)
  private
    font:TSfmlFont ;
    size:Integer ;
    color:TSfmlColor ;
    x,y,h:Integer ;
    selector:TSfmlSprite ;
    items:TUniList<TSfmlText> ;
    selindex:Integer ;
    allowedevents:Boolean;
  protected
  public
    constructor Create(Aselector:TSfmlSprite; Ax,Ay,Ah:Integer; Afont:TSfmlFont;
      Asize:Integer; Acolor:TSfmlColor) ;
    procedure clearItems() ;
    function addItem(str:string):Integer ;
    function getSelIndex():Integer ;
    procedure setIndex(idx:Integer) ;
    function Init():Boolean ; override ;
    function FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ; override ;
    procedure RenderFunc() ; override ;
    procedure UnInit() ; override ;
    procedure AllowEvents(Aallowedevents:Boolean) ;
  end;

implementation
uses sfmlutils ;

{ TMenuKeyboardText }

function TMenuKeyboardText.Init():Boolean ;
begin
  Result:=True ;
end ;

function TMenuKeyboardText.addItem(str: string):Integer;
begin
  Result:=items.Add(createText(font,str,size,color)) ;
end;

procedure TMenuKeyboardText.AllowEvents(Aallowedevents: Boolean);
begin
  allowedevents:=Aallowedevents ;
end;

procedure TMenuKeyboardText.clearItems;
var i:Integer ;
begin
  for i := 0 to items.Count-1 do
    items[i].Free ;
  items.Clear() ;
end;

constructor TMenuKeyboardText.Create(Aselector: TSfmlSprite; Ax, Ay,
  Ah: Integer; Afont: TSfmlFont; Asize: Integer; Acolor: TSfmlColor);
begin
  selector:=Aselector ;
  x:=Ax ;
  y:=Ay ;
  h:=Ah ;
  font:=Afont ;
  color:=Acolor ;
  size:=Asize ;
  selindex:=0 ;
  allowedevents:=True ;
  items:=TUniList<TSfmlText>.Create() ;
end;

function TMenuKeyboardText.FrameFunc(dt:Single; events:TUniList<TSfmlEventEx>):TSceneResult ;
var event:TSfmlEventEx ;
begin
  Result:=TSceneResult.Normal ;
  if not allowedevents then Exit ;

  for event in events do
    if (event.event.EventType = sfEvtKeyPressed) then begin
      if (event.event.key.code = sfKeyUp) then
        if selindex>0 then Dec(selindex) ;
      if (event.event.key.code = sfKeyDown) then
        if selindex<items.Count-1 then Inc(selindex) ;
    end ;
end ;

function TMenuKeyboardText.getSelIndex: Integer;
begin
  Result:=selindex ;
end;

procedure TMenuKeyboardText.RenderFunc() ;
var i:Integer ;
begin
  for i := 0 to items.Count-1 do
    drawText(items[i],x,y+i*h) ;
  drawSprite(selector,x,y+selindex*h) ;
end ;

procedure TMenuKeyboardText.setIndex(idx: Integer);
begin
  selindex:=idx ;
end;

procedure TMenuKeyboardText.UnInit() ;
begin
  clearItems() ;
  items.Free ;
end ;

end.

