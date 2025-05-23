﻿unit helpers ;

interface

{$ifdef fpc}
uses fgl, classes, SysUtils ;
{$else}
uses Generics.Collections, Generics.Defaults, IOUtils, SysUtils, Classes ;
{$endif}

type

{$ifdef fpc}
TUniList<T> = class(TFPGList<T>)
private
public
  constructor Create() ; overload ;
  constructor Create(const src:TUniList<T>) ; overload ;
  procedure AddRange(src:TUniList<T>) ;
  function ExtractAt(idx:Integer):T ;
end;

TUniDictionary<K,V> = class(TFPGMap<K,V>)
private
  FKeys:TArray<K> ;
public
  function ContainsKey(const key:K):Boolean ;
  function AllKeys():TArray<K> ;
end;

{$else}
TSortFunc<T> = function(const a:T; const b:T):Integer ;

TUniList<T> = class(TList<T>)
private
public
  procedure Sort(func:TSortFunc<T>) ;
end;

TUniDictionary<K,V> = class(TDictionary<K,V>)
private
public
  function AllKeys():TArray<K> ;
end;
{$endif}

function readAllText(filename:string):string ;
procedure writeAllText(filename:string; const data:string) ;
function getAllFiles(dir:string):TStringList ;

// Конвертирует Int в Str с учетом нуля. Т.е., вернет '', если 0
function IntToStrWt0(a:Integer):string ;

// Конвертирует Str в Int с учетом нуля. Т.е., вернет 0, если ''
function StrToIntWt0(s:string):Integer ;

{$ifdef fpc}
function UTF8ToString(const S: string): string;
{$endif}

{$ifdef fpc}
{$ifdef unix}
const PATH_SEP = '/' ;
{$else}
const PATH_SEP = '\' ;
{$endif}
{$else}
const PATH_SEP = '\' ;
{$endif}

implementation

{$ifdef fpc}

constructor TUniList<T>.Create();
begin
  inherited Create() ;
end ;

constructor TUniList<T>.Create(const src:TUniList<T>);
begin
  inherited Create() ;
  AddRange(src) ;
end ;

procedure TUniList<T>.AddRange(src:TUniList<T>) ;
var el:T ;
begin
  for el in src do
    Self.Add(el) ;
end ;

function TUniList<T>.ExtractAt(idx:Integer):T ;
begin
  Result:=Items[idx] ;
  Remove(Items[idx]) ;
end ;

function TUniDictionary<K,V>.ContainsKey(const key:K):Boolean ;
begin
  Result:=IndexOf(key)<>-1 ;
end ;

function TUniDictionary<K,V>.AllKeys():TArray<K> ;
var i:Integer ;
begin
  SetLength(FKeys,Count) ;
  for i:=0 to Count-1 do
    FKeys[i]:=GetKey(i) ;
  Result:=FKeys ;
end ;

{$else}

procedure TUniList<T>.Sort(func: TSortFunc<T>);
begin
  inherited Sort(TComparer<T>.Construct(func));
end;

function TUniDictionary<K,V>.AllKeys():TArray<K> ;
begin
  Result:=Keys.ToArray() ;
end ;

{$endif}

function readAllText(filename:string):string ;
begin
  {$ifdef fpc}
  with TStringList.Create do begin
    LoadFromFile(FileName) ;
    Result:=Text ;
    Free ;
  end ;
  {$else}
  Result:=TFile.ReadAllText(filename) ;
  {$endif}
end ;

procedure writeAllText(filename:string; const data:string) ;
begin
  {$ifdef fpc}
  with TStringList.Create do begin
    Text:=data ;
    SaveToFile(FileName) ;
    Free ;
  end ;
  {$else}
  TFile.WriteAllText(filename,data) ;
  {$endif}
end ;

{$ifdef fpc}
function UTF8ToString(const S: string): string;
begin
  Result:=UTF8Decode(S) ;
end ;
{$endif}

function IntToStrWt0(a:Integer):string ;
begin
  if a=0 then Result:='' else Result:=IntToStr(a) ;
end ;

function StrToIntWt0(s:string):Integer ;
begin
  if Trim(s)='' then Result:=0 else Result:=StrToInt(s) ;
end ;

function getAllFiles(dir:string):TStringList ;
var {$ifdef fpc}
    searchRec: TSearchRec;
    {$else}
    s:string ;
    {$endif}
begin
  Result:=TStringList.Create ;
  {$ifdef fpc}
  if dir[dir.Length]<>PATH_SEP then dir:=dir+PATH_SEP ;
  if FindFirst(dir + '*.*', faAnyFile, searchRec) = 0 then begin
    repeat
      if (searchRec.Attr and faDirectory) = 0 then
        Result.Add(dir+searchRec.Name) ;
    until FindNext(searchRec) <> 0;
    FindClose(searchRec) ;
  end ;
  {$else}
  for s in TDirectory.GetFiles(dir) do
    Result.Add(s) ;
  {$endif}
end ;

end.
