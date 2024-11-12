unit ListZOrders;

interface
uses SfmlGraphics,
  Helpers ;

type
  TListZOrders = class
  private
    type TZSprite = record
      spr:TSfmlSprite ;
      z:Single ;
      class operator Equal(a: TZSprite; b: TZSprite): Boolean;
    end ;
  private
    list:TUniList<TZSprite> ;
  public
    constructor Create() ;
    destructor Destroy ; override ;
    procedure Clear() ;
    procedure Add(spr:TSfmlSprite; z:Single) ;
    procedure Render(target:TSfmlRenderTarget) ;
  end;

implementation

const EPS=0.001 ;
function compareZ(const a:TListZOrders.TZSprite; const b:TListZOrders.TZSprite):Integer ;
begin
  if a.z-b.z<-EPS then Result:=1 else
  if a.z-b.z>EPS then Result:=-1 else
  Result:=0 ;
end;

{ TListZOrders }

procedure TListZOrders.Add(spr: TSfmlSprite; z: Single);
var zs:TZSprite ;
begin
  zs.spr:=spr ;
  zs.z:=z ;
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

{ TListZOrders.TZSprite }

class operator TListZOrders.TZSprite.Equal(a, b: TZSprite): Boolean;
begin
  Result:=(a.spr=b.spr)and(a.z=b.z) ;
end;

end.
