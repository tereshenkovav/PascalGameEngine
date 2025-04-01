unit ListZOrders;

interface
uses SfmlGraphics,
  Helpers ;

type
  TZSprite = record
    spr:TSfmlSprite ;
    z:Single ;
    tag:Integer ;
    class operator Equal(a: TZSprite; b: TZSprite): Boolean;
  end ;

  TListZOrders = class
  private
    list:TUniList<TZSprite> ;
  public
    constructor Create() ;
    destructor Destroy ; override ;
    procedure Clear() ;
    procedure Add(spr:TSfmlSprite; z:Single; tag:Integer=0) ;
    function getSortedZSprites():TUniList<TZSprite> ;
    procedure Render(target:TSfmlRenderTarget) ;
  end;

implementation

const EPS=0.001 ;
function compareZ(const a:TZSprite; const b:TZSprite):Integer ;
begin
  if a.z-b.z<-EPS then Result:=1 else
  if a.z-b.z>EPS then Result:=-1 else
  Result:=0 ;
end;

{ TListZOrders }

procedure TListZOrders.Add(spr: TSfmlSprite; z: Single; tag:Integer);
var zs:TZSprite ;
begin
  zs.spr:=spr ;
  zs.z:=z ;
  zs.tag:=tag ;
  list.Add(zs) ;
end;

procedure TListZOrders.Clear;
begin
  list.Clear() ;
end;

constructor TListZOrders.Create;
begin
  list:=TUniList<TZSprite>.Create() ;
end;

destructor TListZOrders.Destroy;
begin
  list.Free ;
  inherited Destroy ;
end;

procedure TListZOrders.Render(target: TSfmlRenderTarget);
var zs:TZSprite ;
begin
  list.Sort(compareZ) ;
  for zs in list do
    target.Draw(zs.spr) ;
end;

function TListZOrders.getSortedZSprites():TUniList<TZSprite> ;
begin
  list.Sort(compareZ) ;
  Result:=list ;
end ;

{ TZSprite }

class operator TZSprite.Equal(a, b: TZSprite): Boolean;
begin
  Result:=(a.spr=b.spr)and(a.z=b.z) ;
end;

end.
