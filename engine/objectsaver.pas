unit ObjectSaver;

interface

uses
  Classes, SysUtils,
  Helpers,
  {$ifdef fpc}
  fpjson,jsonparser,jsonscanner
  {$else}
  System.JSON
  {$endif} ;

type
  TWriterAPI = class
  private
    jsvars:TJSONObject ;
    constructor Create(Ajsvars:TJSONObject) ;
  public
    procedure WriteInteger(name:string; value:Integer) ;
    procedure WriteSingle(name:string; value:Single) ;
    procedure WriteBoolean(name:string; value:Boolean) ;
    procedure WriteString(name:string; value:string) ;
  end ;

  TReaderAPI = class
  private
    jsvars:TJSONObject ;
    constructor Create(Ajsvars:TJSONObject) ;
  public
    function isNameExist(name:string):Boolean ;
    function ReadInteger(name:string; def:Integer=0):Integer ;
    function ReadSingle(name:string; def:Single=0):Single ;
    function ReadBoolean(name:string; def:Boolean=False):Boolean ;
    function ReadString(name:string; def:string=''):string ;
  end ;

  TProcWriter = function (obj:TObject; store:TWriterAPI):Boolean of object ;
  TProcReader = function (obj:TObject; store:TReaderAPI):Boolean of object ;

  TProcWriterRecord = function(rec:Pointer; store:TWriterAPI):Boolean of object ;
  TProcReaderRecord = function (rec:Pointer; store:TReaderAPI):Boolean of object ;

  TObjectSaver = class
  private
    jsroot:TJSONObject ;
    writers:TUniDictionary<string,TWriterAPI> ;
    procedure AddToRoot(name:string; jsarr:TJSONArray) ; overload ;
    procedure AddToRoot(name:string; jsarr:TJSONObject) ; overload ;
  public
    constructor Create() ;
    destructor Destroy; override ;
    function SystemSection():TWriterAPI ;
    function Section(name:string):TWriterAPI ;
    function WriteObject(name:string; obj:TObject; writer:TProcWriter):Boolean ;
    function WriteRecord<T>(name:string; rec:T; writer:TProcWriterRecord):Boolean ;
    function WriteObjectList(name:string; list:TUniList<TObject>; writer:TProcWriter):Boolean ;
    function WriteRecordList<T>(name:string; list:TUniList<T>; writer:TProcWriterRecord):Boolean ;
    function WriteStringList(name:string; list:TStringList):Boolean ;
    function WriteStringDictionary(name:string; dict:TUniDictionary<string,string>):Boolean ;
    function WriteArrayInteger(name:string; arr:TArray<Integer>):Boolean ;
    function WriteArrayString(name:string; arr:TArray<String>):Boolean ;
    function getData():string ;
  end;

  TObjectLoader = class
  private
    jsroot:TJSONObject ;
    readers:TUniDictionary<string,TReaderAPI> ;
    function getObjectFromRoot(name:string):TJSONObject ;
    function getArrayFromRoot(name:string):TJSONArray ;
  public
    constructor Create(const data:string) ;
    destructor Destroy; override ;
    function Section(name:string):TReaderAPI ;
    function SystemSection():TReaderAPI ;
    function ReadObject(name:string; obj:TObject; reader:TProcReader):Boolean ;
    function ReadRecord<T>(name:string; recp:Pointer; reader:TProcReaderRecord):Boolean ;
    function ReadObjectList(name:string; list:TUniList<TObject>; reader:TProcReader;
      objclass:TClass):Boolean ;
    function ReadRecordList<T>(name:string; list:TUniList<T>; reader:TProcReaderRecord):Boolean ;
    function ReadStringList(name:string; list:TStringList):Boolean ;
    function ReadStringDictionary(name:string; dict:TUniDictionary<string,string>):Boolean ;
    function ReadArrayInteger(name:string; var arr:TArray<Integer>):Boolean ;
    function ReadArrayString(name:string; var arr:TArray<string>):Boolean ;
  end;

implementation

const
// Случайная секция для системных переменных
  SYSTEM_SECTION_NAME='systemsection_x0yivoa604' ;
// Случайный ключ для версии сериализатора
  OBJECTSAVER_VERSION_KEY = 'objectsaver_version_4fnga9qt7o';
// Версия сериализатора, вшивается в каждый сохраненный JSON
  OBJECTSAVER_VERSION = 1 ;

{ TWriterAPI }

constructor TWriterAPI.Create(Ajsvars: TJSONObject);
begin
  jsvars:=Ajsvars ;
end;

procedure TWriterAPI.WriteBoolean(name: string; value: Boolean);
begin
  {$ifdef fpc}
  jsvars.Add(name,value) ;
  {$else}
  jsvars.AddPair(name,value) ;
  {$endif}
end;

procedure TWriterAPI.WriteInteger(name: string; value: Integer);
begin
  {$ifdef fpc}
  jsvars.Add(name,value) ;
  {$else}
  jsvars.AddPair(name,value) ;
  {$endif}
end;

procedure TWriterAPI.WriteSingle(name: string; value: Single);
begin
  {$ifdef fpc}
  jsvars.Add(name,value) ;
  {$else}
  jsvars.AddPair(name,value) ;
  {$endif}
end;

procedure TWriterAPI.WriteString(name, value: string);
begin
  {$ifdef fpc}
  jsvars.Add(name,value) ;
  {$else}
  jsvars.AddPair(name,value) ;
  {$endif}
end;

{ TReaderAPI }

constructor TReaderAPI.Create(Ajsvars: TJSONObject);
begin
  jsvars:=Ajsvars ;
end;

function TReaderAPI.isNameExist(name: string): Boolean;
{$ifdef fpc}
var v:TJSONData ;
{$endif}
begin
  {$ifdef fpc}
  Result:=jsvars.Find(name,v) ;
  {$else}
  Result:=jsvars.FindValue(name)<>nil ;
  {$endif}
end;

function TReaderAPI.ReadBoolean(name: string; def: Boolean): Boolean;
begin
  {$ifdef fpc}
  Result:=jsvars.Get(name,def) ;
  {$else}
  Result:=jsvars.GetValue(name,def) ;
  {$endif}
end;

function TReaderAPI.ReadInteger(name: string; def: Integer): Integer;
begin
  {$ifdef fpc}
  Result:=jsvars.Get(name,def) ;
  {$else}
  Result:=jsvars.GetValue(name,def) ;
  {$endif}
end;

function TReaderAPI.ReadSingle(name: string; def: Single): Single;
begin
  {$ifdef fpc}
  Result:=jsvars.Get(name,def) ;
  {$else}
  Result:=jsvars.GetValue(name,def) ;
  {$endif}
end;

function TReaderAPI.ReadString(name:string; def: string=''): string;
begin
  {$ifdef fpc}
  Result:=jsvars.Get(name,def) ;
  {$else}
  Result:=jsvars.GetValue(name,def) ;
  {$endif}
end;

{ TObjectSaver }

procedure TObjectSaver.AddToRoot(name:string; jsarr: TJSONObject);
begin
  {$ifdef fpc}
  jsroot.Add(name,jsarr) ;
  {$else}
  jsroot.AddPair(name,jsarr) ;
  {$endif}
end;

procedure TObjectSaver.AddToRoot(name:string; jsarr: TJSONArray);
begin
  {$ifdef fpc}
  jsroot.Add(name,jsarr) ;
  {$else}
  jsroot.AddPair(name,jsarr) ;
  {$endif}
end;

constructor TObjectSaver.Create;
begin
  jsroot:=TJSONObject.Create() ;
  writers:=TUniDictionary<string,TWriterAPI>.Create() ;
  SystemSection().WriteInteger(OBJECTSAVER_VERSION_KEY,OBJECTSAVER_VERSION) ;
end;

destructor TObjectSaver.Destroy;
begin
  jsroot.Free ;
  writers.Free ;
  inherited Destroy ;
end;

function TObjectSaver.getData: string;
begin
  {$ifdef fpc}
  Result:=jsroot.FormatJSON() ;
  {$else}
  Result:=jsroot.Format() ;
  {$endif}
end;

function TObjectSaver.Section(name: string): TWriterAPI;
var jsobj:TJSONObject ;
begin
  if not writers.ContainsKey(name) then begin
    jsobj:=TJSONObject.Create ;
    writers.Add(name,TWriterAPI.Create(jsobj)) ;
    AddToRoot(name,jsobj) ;
  end;
  Result:=writers[name] ;
end;

function TObjectSaver.SystemSection: TWriterAPI;
begin
  Result:=Section(SYSTEM_SECTION_NAME) ;
end;

function TObjectSaver.WriteArrayInteger(name: string; arr: TArray<Integer>): Boolean;
var jsarr:TJsonArray ;
    v:Integer ;
begin
  jsarr:=TJSONArray.Create() ;
  for v in arr do
     jsarr.Add(v) ;
  AddToRoot(name,jsarr) ;
  Result:=True ;
end;

function TObjectSaver.WriteArrayString(name: string;
  arr: TArray<String>): Boolean;
var jsarr:TJsonArray ;
    s:string ;
begin
  jsarr:=TJSONArray.Create() ;
  for s in arr do
     jsarr.Add(s) ;
  AddToRoot(name,jsarr) ;
  Result:=True ;
end;

function TObjectSaver.WriteObject(name: string; obj: TObject;
  writer: TProcWriter): Boolean;
begin
  Result:=writer(obj,Section(name)) ;
end;

function TObjectSaver.WriteObjectList(name: string; list: TUniList<TObject>;
  writer: TProcWriter): Boolean;
var jsarr:TJsonArray ;
    jsobj:TJSONObject ;
    obj:TObject ;
    wapi:TWriterAPI ;
begin
  jsarr:=TJSONArray.Create() ;
  for obj in list do begin
    jsobj:=TJSONObject.Create() ;
    wapi:=TWriterAPI.Create(jsobj) ;
    writer(obj,wapi) ;
    wapi.Free ;
    jsarr.Add(jsobj) ;
  end;
  AddToRoot(name,jsarr) ;
  Result:=True ;
end;

function TObjectSaver.WriteRecord<T>(name: string; rec: T;
  writer: TProcWriterRecord): Boolean;
begin
  Result:=writer(@rec,Section(name)) ;
end;

function TObjectSaver.WriteRecordList<T>(name: string; list: TUniList<T>;
  writer: TProcWriterRecord): Boolean;
var jsarr:TJsonArray ;
    jsobj:TJSONObject ;
    rec:T ;
    wapi:TWriterAPI ;
begin
  jsarr:=TJSONArray.Create() ;
  for rec in list do begin
    jsobj:=TJSONObject.Create() ;
    wapi:=TWriterAPI.Create(jsobj) ;
    writer(@rec,wapi) ;
    wapi.Free ;
    jsarr.Add(jsobj) ;
  end;
  AddToRoot(name,jsarr) ;
  Result:=True ;
end;

function TObjectSaver.WriteStringDictionary(name: string;
  dict: TUniDictionary<string, string>): Boolean;
var jsarr:TJsonArray ;
    jsobj:TJSONObject ;
    key:string ;
begin
  jsarr:=TJSONArray.Create() ;
  for key in dict.AllKeys do begin
    jsobj:=TJSONObject.Create() ;
    {$ifdef fpc}
    jsobj.Add('key',key) ;
    jsobj.Add('value',dict[key]) ;
    {$else}
    jsobj.AddPair('key',key) ;
    jsobj.AddPair('value',dict[key]) ;
    {$endif}
    jsarr.Add(jsobj) ;
  end;
  AddToRoot(name,jsarr) ;
  Result:=True ;
end;

function TObjectSaver.WriteStringList(name: string; list: TStringList): Boolean;
var jsarr:TJsonArray ;
    s:string ;
begin
  jsarr:=TJSONArray.Create() ;
  for s in list do
    jsarr.Add(s) ;
  AddToRoot(name,jsarr) ;
  Result:=True ;
end;

{ TObjectLoader }

constructor TObjectLoader.Create(const data: string);
begin
  readers:=TUniDictionary<string,TReaderAPI>.Create() ;
  {$ifdef fpc}
  jsroot:=TJSONParser.Create(data,[]).Parse() as TJSONObject ;
  {$else}
  jsroot:=TJSONObject.ParseJSONValue(data) as TJSONObject;
  {$endif}

  // ToDo: выдавать ошибку, если OBJECTSAVER_VERSION в файле выше, чем у самого класса
end;

destructor TObjectLoader.Destroy;
begin
  jsroot.Free ;
  readers.Free ;
  inherited Destroy ;
end;

function TObjectLoader.getArrayFromRoot(name: string): TJSONArray;
begin
  {$ifdef fpc}
  if not jsroot.Find(name,Result) then Result:=nil ;
  {$else}
  Result:=jsroot.Values[name] as TJSONArray ;
  {$endif}
end;

function TObjectLoader.getObjectFromRoot(name: string): TJSONObject;
begin
  {$ifdef fpc}
  if not jsroot.Find(name,Result) then Result:=nil ;
  {$else}
  Result:=jsroot.Values[name] as TJSONObject ;
  {$endif}
end;

function TObjectLoader.ReadArrayInteger(name: string;
  var arr: TArray<Integer>): Boolean;
var jsarr:TJSONArray ;
    i:Integer ;
begin
  jsarr:=GetArrayFromRoot(name) ;
  if jsarr=nil then Exit(False) ;
  
  SetLength(arr,jsarr.Count) ;
  for i:=0 to jsarr.Count-1 do
    arr[i]:=StrToInt(jsarr.Items[i].Value) ;
  Result:=True ;
end;

function TObjectLoader.ReadArrayString(name: string;
  var arr: TArray<string>): Boolean;
var jsarr:TJSONArray ;
    i:Integer ;
begin
  jsarr:=GetArrayFromRoot(name) ;
  if jsarr=nil then Exit(False) ;

  SetLength(arr,jsarr.Count) ;
  for i:=0 to jsarr.Count-1 do
    arr[i]:=jsarr.Items[i].Value ;
  Result:=True ;
end;

function TObjectLoader.ReadObject(name: string; obj: TObject;
  reader: TProcReader): Boolean;
begin
  Result:=reader(obj,Section(name)) ;
end;

function TObjectLoader.ReadObjectList(name: string; list: TUniList<TObject>;
  reader: TProcReader; objclass:TClass): Boolean;
var jsarr:TJsonArray ;
    i:Integer ;
    obj:TObject ;
    rapi:TReaderAPI ;
begin
  jsarr:=GetArrayFromRoot(name) ;

  list.Clear() ;
  if jsarr=nil then Exit(False) ;
  for i:=0 to jsarr.Count-1 do begin
    obj:=objclass.Create ;
    rapi:=TReaderAPI.Create(jsarr.Items[i] as TJSONObject) ;
    reader(obj,rapi) ;
    rapi.Free ;
    list.Add(obj) ;
  end;

  Result:=True ;
end;

function TObjectLoader.ReadRecord<T>(name: string; recp: Pointer;
  reader: TProcReaderRecord): Boolean;
begin
  Result:=reader(recp,Section(name)) ;
end;

function TObjectLoader.ReadRecordList<T>(name: string; list: TUniList<T>;
  reader: TProcReaderRecord): Boolean;
var jsarr:TJsonArray ;
    i:Integer ;
    rec:T ;
    rapi:TReaderAPI ;
begin
  jsarr:=GetArrayFromRoot(name) ;
  list.Clear() ;
  if jsarr=nil then Exit(false) ;

  for i:=0 to jsarr.Count-1 do begin
    rapi:=TReaderAPI.Create(jsarr.Items[i] as TJSONObject) ;
    reader(@rec,rapi) ;
    rapi.Free ;
    list.Add(rec) ;
  end;

  Result:=True ;
end;

function TObjectLoader.ReadStringDictionary(name: string;
  dict: TUniDictionary<string, string>): Boolean;
var jsarr:TJSONArray ;
    i:Integer ;
begin
  jsarr:=GetArrayFromRoot(name) ;

  dict.Clear() ;
  if jsarr=nil then Exit(False) ;
  for i:=0 to jsarr.Count-1 do
    {$ifdef fpc}
    dict.Add((jsarr.Items[i] as TJSONObject).Get('key',''),
      (jsarr.Items[i] as TJSONObject).Get('value','')) ;
    {$else}
    dict.Add((jsarr.Items[i] as TJSONObject).GetValue('key',''),
      (jsarr.Items[i] as TJSONObject).GetValue('value','')) ;
    {$endif}
  Result:=True ;
end;

function TObjectLoader.ReadStringList(name: string; list: TStringList): Boolean;
var jsarr:TJSONArray ;
    i:Integer ;
begin
  jsarr:=GetArrayFromRoot(name) ;

  list.Clear() ;
  if jsarr=nil then Exit(False) ;
  for i:=0 to jsarr.Count-1 do
    list.Add(jsarr.Items[i].Value) ;
  Result:=True ;
end;

function TObjectLoader.Section(name: string): TReaderAPI;
begin
  if not readers.ContainsKey(name) then
    readers.Add(name,TReaderAPI.Create(GetObjectFromRoot(name))) ;
  Result:=readers[name] ;
end;

function TObjectLoader.SystemSection: TReaderAPI;
begin
  Result:=Section(SYSTEM_SECTION_NAME) ;
end;

end.

