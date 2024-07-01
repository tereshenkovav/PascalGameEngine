unit SpriteEffects;

interface

uses
  Classes, SysUtils,
  SfmlGraphics, SfmlSystem,
  Helpers ;

type
  { TSpriteEffect }

  TSpriteEffect = class
  protected
    spr:TSfmlSprite ;
    tag:Integer ;
  public
    constructor Create(Aspr:TSfmlSprite; Atag:Integer) ;
    procedure Draw(render:TSfmlRenderTarget) ; virtual ; abstract ;
    procedure Update(dt:Single) ; virtual ; abstract ;
    function getSprite():TSfmlSprite ;
  end;

  TSpriteEffectPool = class
  private
    list:TUniList<TSpriteEffect> ;
  public
    constructor Create ;
    destructor Destroy ; override ;
    procedure Clear() ;
    procedure addEffect(effect:TSpriteEffect) ;
    function findEffect(tag:Integer):TSpriteEffect ;
    procedure Update(dt:Single) ;
  end ;

  TSEMoveHarmonicVert = class(TSpriteEffect)
  private
    dy:Integer ;
    period:Single ;
    a0:Single ;
    t:Single ;
  public
    constructor Create(Aspr:TSfmlSprite; Atag:Integer; 
      Ady:Integer; Aperiod:Single; Aa0:Single) ;
    procedure Draw(render:TSfmlRenderTarget) ; override ;
    procedure Update(dt:Single) ; override ;
  end ;

implementation

{ TSpriteEffect }

constructor TSpriteEffect.Create(Aspr: TSfmlSprite; Atag: Integer);
begin
  spr:=Aspr ;
  tag:=Atag ;
end;

function TSpriteEffect.getSprite: TSfmlSprite;
begin
  Result:=spr ;
end;

{ TSpriteEffectPool }

procedure TSpriteEffectPool.Clear;
begin
  list.Clear() ;
end;

constructor TSpriteEffectPool.Create;
begin
  list:=TUniList<TSpriteEffect>.Create() ;
end;

destructor TSpriteEffectPool.Destroy;
begin
  list.Free ;
  inherited Destroy;
end;

procedure TSpriteEffectPool.addEffect(effect: TSpriteEffect);
begin
  list.Add(effect) ;
end;

function TSpriteEffectPool.findEffect(tag: Integer): TSpriteEffect;
var effect:TSpriteEffect ;
begin
  Result:=nil ;
  for effect in list do
    if effect.tag=tag then Exit(effect) ;
end;

procedure TSpriteEffectPool.Update(dt: Single);
var effect:TSpriteEffect ;
begin
  for effect in list do
    effect.Update(dt) ;
end;

{ TSEMoveHarmonicVert }

constructor TSEMoveHarmonicVert.Create(Aspr: TSfmlSprite; Atag, Ady: Integer;
  Aperiod, Aa0: Single);
begin
  inherited Create(Aspr,Atag) ;
  dy:=Ady ;
  period:=Aperiod ;
  a0:=Aa0 ;
  t:=0 ;
end;

procedure TSEMoveHarmonicVert.Draw(render: TSfmlRenderTarget);
begin
  spr.Position := SfmlVector2f(spr.Position.X,
    spr.Position.Y + dy*Sin(2*PI*(a0+t/period))) ;
  render.Draw(spr) ;
end;

procedure TSEMoveHarmonicVert.Update(dt: Single);
begin
  t:=t+dt ;
end;

end.

