unit ActionConfig;

interface

uses
  Classes, SysUtils,
  SfmlWindow,
  Helpers ;

type
  TActionType = (atKey,atMouseButton) ;

  TActionInfo = record
  private
  public
    actionname:string ;
    actiontype:TActionType ;
    def_key:TSfmlKeyCode ;
    def_mousebutton:TSfmlMouseButton ;
    key:TSfmlKeyCode ;
    mousebutton:TSfmlMouseButton ;
    isset:Boolean ;
    function getView():string ;
    function getPacked():string ;
    procedure setFromPacked(str:string) ;
    function isMatchTypeAndValue(const action:TActionInfo):Boolean ;
    class operator Equal(a: TActionInfo; b: TActionInfo): Boolean;
  end;

  { TActionConfig }

  TActionConfig = class
  private
    actions:TUniList<TActionInfo> ;
  public
    procedure addAction(actionname:string; key:TSfmlKeyCode) ; overload ;
    procedure addAction(actionname:string; mousebutton:TSfmlMouseButton) ; overload ;
    procedure setActionByEvent(i:Integer; event:TSfmlEvent) ;
    function isMatchEvent(const event:TSfmlEvent; var actionname:string):Boolean ;
    function Count():Integer ;
    function getActionName(i:Integer):string ;
    function getActionView(i:Integer):string ;
    function getActionPacked(i:Integer):string ;
    procedure unsetAction(i:Integer) ;
    function formatTextWithActionCodes(const str:string):string ;
    procedure setActionFromPacked(i:Integer; str:string) ;
    constructor Create() ;
    destructor Destroy() ; override ;
  end;

implementation
uses Math ;

{ TActionConfig }

function TActionConfig.Count: Integer;
begin
  Result:=actions.Count ;
end;

constructor TActionConfig.Create();
begin
  actions:=TUniList<TActionInfo>.Create() ;
end ;

destructor TActionConfig.Destroy();
begin
  actions.Free ;
  inherited Destroy();
end;

function TActionConfig.formatTextWithActionCodes(const str: string): string;
var action:TActionInfo ;
begin
  Result:=str ;
  for action in actions do
    Result:=Result.Replace('{action_'+action.actionname+'}',action.getView()) ;
end;

function TActionConfig.getActionName(i: Integer): string;
begin
  Result:=actions[i].actionname ;
end;

function TActionConfig.getActionView(i: Integer): string;
begin
  Result:=actions[i].getView() ;
end;

function TActionConfig.getActionPacked(i: Integer): string;
begin
  Result:=actions[i].getPacked() ;
end;

function TActionConfig.isMatchEvent(const event: TSfmlEvent;
  var actionname: string): Boolean;
var action:TActionInfo ;
begin
  Result:=False ;
  for action in actions do begin
    if not action.isset then Continue ;
    case action.actiontype of
      atKey:
        if event.EventType=sfEvtKeyPressed then
          if event.Key.Code=action.key then begin
            actionname:=action.actionname ;
            Exit(True) ;
          end;
      atMouseButton:
        if event.EventType=sfEvtMouseButtonPressed then
          if event.MouseButton.Button=action.mousebutton then begin
            actionname:=action.actionname ;
            Exit(True) ;
          end;
    end;
  end;
end;

procedure TActionConfig.setActionByEvent(i: Integer; event: TSfmlEvent);
var action:TActionInfo ;
    j:Integer ;
begin
  action:=actions[i] ;
  if event.EventType=TSfmlEventType.sfEvtKeyPressed then begin
    action.actiontype:=TActionType.atKey ;
    action.key:=event.Key.Code ;
    action.isset:=True ;
    actions[i]:=action ;
    for j := 0 to actions.Count-1 do
      if (i<>j)and(actions[j].isMatchTypeAndValue(action)) then
        unsetAction(j) ;
  end;
  if event.EventType=TSfmlEventType.sfEvtMouseButtonPressed then begin
    action.actiontype:=TActionType.atMouseButton ;
    action.mousebutton:=event.MouseButton.Button ;
    action.isset:=True ;
    actions[i]:=action ;
    for j := 0 to actions.Count-1 do
      if (i<>j)and(actions[j].isMatchTypeAndValue(action)) then
        unsetAction(j) ;
  end;
end;

procedure TActionConfig.setActionFromPacked(i: Integer; str: string);
var action:TActionInfo ;
begin
  action:=actions[i] ;
  action.setFromPacked(str) ;
  actions[i]:=action ;
end;

procedure TActionConfig.unsetAction(i: Integer);
var action:TActionInfo ;
begin
  action:=actions[i] ;
  action.isset:=False ;
  actions[i]:=action ;
end;

procedure TActionConfig.addAction(actionname:string; key:TSfmlKeyCode) ;
var keyinfo:TActionInfo ;
begin
  keyinfo.actionname:=actionname ;
  keyinfo.actiontype:=TActionType.atKey ;
  keyinfo.def_key:=key ;
  keyinfo.key:=key ;
  keyinfo.isset:=True ;
  actions.Add(keyinfo) ;
end;

procedure TActionConfig.addAction(actionname:string; mousebutton:TSfmlMouseButton) ;
var keyinfo:TActionInfo ;
begin
  keyinfo.actionname:=actionname ;
  keyinfo.actiontype:=TActionType.atMouseButton ;
  keyinfo.def_mousebutton:=mousebutton ;
  keyinfo.mousebutton:=mousebutton ;
  keyinfo.isset:=True ;
  actions.Add(keyinfo) ;
end ;

{ TActionInfo }

class operator TActionInfo.Equal(a: TActionInfo; b: TActionInfo): Boolean;
begin
  Result:=a.actionname=b.actionname ;
end;

function TActionInfo.getPacked: string;
begin
  if not isset then
    Result:='Null'
  else begin
    if actiontype=TActionType.atKey then
      Result:='Key_'+IntToStr(ord(key))
    else
    if actiontype=TActionType.atMouseButton then
      Result:='MouseButton_'+IntToStr(ord(mousebutton))
    else
      Result:='Null' ;
  end;
end;

function TActionInfo.getView: string;
begin
  if not isset then Exit('???') ;
  if actiontype=TActionType.atMouseButton then begin
    if mousebutton=TSfmlMouseButton.sfMouseLeft then Exit('LCM') ;
    if mousebutton=TSfmlMouseButton.sfMouseMiddle then Exit('MCM') ;
    if mousebutton=TSfmlMouseButton.sfMouseRight then Exit('RCM') ;
  end;
  if actiontype=TActionType.atKey then begin
                if (key = TSfmlKeyCode.sfKeyA) then Exit('A');
                if (key = TSfmlKeyCode.sfKeyB) then Exit('B');
                if (key = TSfmlKeyCode.sfKeyC) then Exit('C');
                if (key = TSfmlKeyCode.sfKeyD) then Exit('D');
                if (key = TSfmlKeyCode.sfKeyE) then Exit('E');
                if (key = TSfmlKeyCode.sfKeyF) then Exit('F');
                if (key = TSfmlKeyCode.sfKeyG) then Exit('G');
                if (key = TSfmlKeyCode.sfKeyH) then Exit('H');
                if (key = TSfmlKeyCode.sfKeyI) then Exit('I');
                if (key = TSfmlKeyCode.sfKeyJ) then Exit('J');
                if (key = TSfmlKeyCode.sfKeyK) then Exit('K');
                if (key = TSfmlKeyCode.sfKeyL) then Exit('L');
                if (key = TSfmlKeyCode.sfKeyM) then Exit('M');
                if (key = TSfmlKeyCode.sfKeyN) then Exit('N');
                if (key = TSfmlKeyCode.sfKeyO) then Exit('O');
                if (key = TSfmlKeyCode.sfKeyP) then Exit('P');
                if (key = TSfmlKeyCode.sfKeyQ) then Exit('Q');
                if (key = TSfmlKeyCode.sfKeyR) then Exit('R');
                if (key = TSfmlKeyCode.sfKeyS) then Exit('S');
                if (key = TSfmlKeyCode.sfKeyT) then Exit('T');
                if (key = TSfmlKeyCode.sfKeyU) then Exit('U');
                if (key = TSfmlKeyCode.sfKeyV) then Exit('V');
                if (key = TSfmlKeyCode.sfKeyW) then Exit('W');
                if (key = TSfmlKeyCode.sfKeyX) then Exit('X');
                if (key = TSfmlKeyCode.sfKeyY) then Exit('Y');
                if (key = TSfmlKeyCode.sfKeyZ) then Exit('Z');
                if (key = TSfmlKeyCode.sfKeyNum0) then Exit('Num0');
                if (key = TSfmlKeyCode.sfKeyNum1) then Exit('Num1');
                if (key = TSfmlKeyCode.sfKeyNum2) then Exit('Num2');
                if (key = TSfmlKeyCode.sfKeyNum3) then Exit('Num3');
                if (key = TSfmlKeyCode.sfKeyNum4) then Exit('Num4');
                if (key = TSfmlKeyCode.sfKeyNum5) then Exit('Num5');
                if (key = TSfmlKeyCode.sfKeyNum6) then Exit('Num6');
                if (key = TSfmlKeyCode.sfKeyNum7) then Exit('Num7');
                if (key = TSfmlKeyCode.sfKeyNum8) then Exit('Num8');
                if (key = TSfmlKeyCode.sfKeyNum9) then Exit('Num9');
                if (key = TSfmlKeyCode.sfKeyEscape) then Exit('Escape');
                if (key = TSfmlKeyCode.sfKeyLControl) then Exit('LControl');
                if (key = TSfmlKeyCode.sfKeyLShift) then Exit('LShift');
                if (key = TSfmlKeyCode.sfKeyLAlt) then Exit('LAlt');
                if (key = TSfmlKeyCode.sfKeyLSystem) then Exit('LSystem');
                if (key = TSfmlKeyCode.sfKeyRControl) then Exit('RControl');
                if (key = TSfmlKeyCode.sfKeyRShift) then Exit('RShift');
                if (key = TSfmlKeyCode.sfKeyRAlt) then Exit('RAlt');
                if (key = TSfmlKeyCode.sfKeyRSystem) then Exit('RSystem');
                if (key = TSfmlKeyCode.sfKeyMenu) then Exit('Menu');
                if (key = TSfmlKeyCode.sfKeyLBracket) then Exit('LBracket');
                if (key = TSfmlKeyCode.sfKeyRBracket) then Exit('RBracket');
                if (key = TSfmlKeyCode.sfKeySemicolon) then Exit('Semicolon');
                if (key = TSfmlKeyCode.sfKeyComma) then Exit('Comma');
                if (key = TSfmlKeyCode.sfKeyPeriod) then Exit('Period');
                if (key = TSfmlKeyCode.sfKeyQuote) then Exit('Quote');
                if (key = TSfmlKeyCode.sfKeySlash) then Exit('Slash');
                if (key = TSfmlKeyCode.sfKeyBackslash) then Exit('Backslash');
                if (key = TSfmlKeyCode.sfKeyTilde) then Exit('Tilde');
                if (key = TSfmlKeyCode.sfKeyEqual) then Exit('Equal');
                if (key = TSfmlKeyCode.sfKeyDash) then Exit('Dash');
                if (key = TSfmlKeyCode.sfKeySpace) then Exit('Space');
                if (key = TSfmlKeyCode.sfKeyBack) then Exit('BackSpace');
                if (key = TSfmlKeyCode.sfKeyReturn) then Exit('Enter');
                if (key = TSfmlKeyCode.sfKeyTab) then Exit('Tab');
                if (key = TSfmlKeyCode.sfKeyPageUp) then Exit('PageUp');
                if (key = TSfmlKeyCode.sfKeyPageDown) then Exit('PageDown');
                if (key = TSfmlKeyCode.sfKeyEnd) then Exit('End');
                if (key = TSfmlKeyCode.sfKeyHome) then Exit('Home');
                if (key = TSfmlKeyCode.sfKeyInsert) then Exit('Insert');
                if (key = TSfmlKeyCode.sfKeyDelete) then Exit('Delete');
                if (key = TSfmlKeyCode.sfKeyAdd) then Exit('Add');
                if (key = TSfmlKeyCode.sfKeySubtract) then Exit('Subtract');
                if (key = TSfmlKeyCode.sfKeyMultiply) then Exit('Multiply');
                if (key = TSfmlKeyCode.sfKeyDivide) then Exit('Divide');
                if (key = TSfmlKeyCode.sfKeyLeft) then Exit('Left');
                if (key = TSfmlKeyCode.sfKeyRight) then Exit('Right');
                if (key = TSfmlKeyCode.sfKeyUp) then Exit('Up');
                if (key = TSfmlKeyCode.sfKeyDown) then Exit('Down');
                if (key = TSfmlKeyCode.sfKeyNumpad0) then Exit('Numpad0');
                if (key = TSfmlKeyCode.sfKeyNumpad1) then Exit('Numpad1');
                if (key = TSfmlKeyCode.sfKeyNumpad2) then Exit('Numpad2');
                if (key = TSfmlKeyCode.sfKeyNumpad3) then Exit('Numpad3');
                if (key = TSfmlKeyCode.sfKeyNumpad4) then Exit('Numpad4');
                if (key = TSfmlKeyCode.sfKeyNumpad5) then Exit('Numpad5');
                if (key = TSfmlKeyCode.sfKeyNumpad6) then Exit('Numpad6');
                if (key = TSfmlKeyCode.sfKeyNumpad7) then Exit('Numpad7');
                if (key = TSfmlKeyCode.sfKeyNumpad8) then Exit('Numpad8');
                if (key = TSfmlKeyCode.sfKeyNumpad9) then Exit('Numpad9');
                if (key = TSfmlKeyCode.sfKeyF1) then Exit('F1');
                if (key = TSfmlKeyCode.sfKeyF2) then Exit('F2');
                if (key = TSfmlKeyCode.sfKeyF3) then Exit('F3');
                if (key = TSfmlKeyCode.sfKeyF4) then Exit('F4');
                if (key = TSfmlKeyCode.sfKeyF5) then Exit('F5');
                if (key = TSfmlKeyCode.sfKeyF6) then Exit('F6');
                if (key = TSfmlKeyCode.sfKeyF7) then Exit('F7');
                if (key = TSfmlKeyCode.sfKeyF8) then Exit('F8');
                if (key = TSfmlKeyCode.sfKeyF9) then Exit('F9');
                if (key = TSfmlKeyCode.sfKeyF10) then Exit('F10');
                if (key = TSfmlKeyCode.sfKeyF11) then Exit('F11');
                if (key = TSfmlKeyCode.sfKeyF12) then Exit('F12');
                if (key = TSfmlKeyCode.sfKeyF13) then Exit('F13');
                if (key = TSfmlKeyCode.sfKeyF14) then Exit('F14');
                if (key = TSfmlKeyCode.sfKeyF15) then Exit('F15');
                if (key = TSfmlKeyCode.sfKeyPause) then Exit('Pause');
  end ;
  Result:='???' ;
end;

function TActionInfo.isMatchTypeAndValue(const action: TActionInfo): Boolean;
begin
  if (not isset)or(not action.isset) then Exit(False) ;
  if (actiontype=TActionType.atKey)and(action.actiontype=TActionType.atKey) then
    if key=action.key then Exit(True) ;
  if (actiontype=TActionType.atMouseButton)and(action.actiontype=TActionType.atMouseButton) then
    if mousebutton=action.mousebutton then Exit(True) ;
  Result:=False ;
end;

procedure TActionInfo.setFromPacked(str: string);
var arr:TArray<string> ;
begin
  if str='' then Exit ;
  arr:=str.Split(['_']) ;
  isset:=False ;
  if arr[0]='Key' then begin
    actiontype:=TActionType.atKey ;
    key:=TSfmlKeyCode(StrToInt(arr[1])) ;
    isset:=True ;
  end ;
  if arr[0]='MouseButton' then begin
    actiontype:=TActionType.atMouseButton ;
    mousebutton:=TSfmlMouseButton(StrToInt(arr[1])) ;
    isset:=True ;
  end;
end;

end.

