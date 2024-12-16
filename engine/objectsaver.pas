﻿unit ObjectSaver;

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
  public
    constructor Create() ;
    destructor Destroy; override ;
    function Section(name:string):TWriterAPI ;
    function WriteObject(name:string; obj:TObject; writer:TProcWriter):Boolean ;
    function WriteRecord<T>(name:string; rec:T; writer:TProcWriterRecord):Boolean ;
    function WriteObjectList(name:string; list:TUniList<TObject>; writer:TProcWriter):Boolean ;
    function WriteRecordList<T>(name:string; list:TUniList<T>; writer:TProcWriterRecord):Boolean ;
    function WriteStringList(name:string; list:TStringList):Boolean ;
    function WriteArrayInteger(name:string; arr:TArray<Integer>):Boolean ;
    function WriteArrayString(name:string; arr:TArray<String>):Boolean ;
    function getData():string ;
  end;

  TObjectLoader = class
  private
    jsroot:TJSONObject ;
    readers:TUniDictionary<string,TReaderAPI> ;
  public
    constructor Create(const data:string) ;
    destructor Destroy; override ;
    function Section(name:string):TReaderAPI ;
    function ReadObject(name:string; obj:TObject; reader:TProcReader):Boolean ;
    function ReadRecord<T>(name:string; recp:Pointer; reader:TProcReaderRecord):Boolean ;
    function ReadObjectList(name:string; list:TUniList<TObject>; reader:TProcReader;
      objclass:TClass):Boolean ;
    function ReadRecordList<T>(name:string; list:TUniList<T>; reader:TProcReaderRecord):Boolean ;
    function ReadStringList(name:string; list:TStringList):Boolean ;
    function ReadArrayInteger(name:string; var arr:TArray<Integer>):Boolean ;
    function ReadArrayString(name:string; var arr:TArray<string>):Boolean ;
  end;

implementation

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
begin

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

constructor TObjectSaver.Create;
begin
  jsroot:=TJSONObject.Create() ;
  writers:=TUniDictionary<string,TWriterAPI>.Create() ;
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
    {$ifdef fpc}
    jsroot.Add(name,jsobj) ;
    {$else}
    jsroot.AddPair(name,jsobj) ;
    {$endif}
  end;
  Result:=writers[name] ;
end;

function TObjectSaver.WriteArrayInteger(name: string; arr: TArray<Integer>): Boolean;
var jsarr:TJsonArray ;
    v:Integer ;
begin
  jsarr:=TJSONArray.Create() ;
  for v in arr do
     jsarr.Add(v) ;
  {$ifdef fpc}
  jsroot.Add(name,jsarr) ;
  {$else}
  jsroot.AddPair(name,jsarr) ;
  {$endif}
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
  {$ifdef fpc}
  jsroot.Add(name,jsarr) ;
  {$else}
  jsroot.AddPair(name,jsarr) ;
  {$endif}
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
  {$ifdef fpc}
  jsroot.Add(name,jsarr) ;
  {$else}
  jsroot.AddPair(name,jsarr) ;
  {$endif}
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
  {$ifdef fpc}
  jsroot.Add(name,jsarr) ;
  {$else}
  jsroot.AddPair(name,jsarr) ;
  {$endif}
  Result:=True ;
end;

function TObjectSaver.WriteStringList(name: string; list: TStringList): Boolean;
var jsarr:TJsonArray ;
    s:string ;
begin
  jsarr:=TJSONArray.Create() ;
  for s in list do
    jsarr.Add(s) ;
  {$ifdef fpc}
  jsroot.Add(name,jsarr) ;
  {$else}
  jsroot.AddPair(name,jsarr) ;
  {$endif}
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
end;

destructor TObjectLoader.Destroy;
begin
  jsroot.Free ;
  readers.Free ;
  inherited Destroy ;
end;

function TObjectLoader.ReadArrayInteger(name: string;
  var arr: TArray<Integer>): Boolean;
var jsarr:TJSONArray ;
    i:Integer ;
begin
  {$ifdef fpc}
  jsroot.Find(name,jsarr) ;
  {$else}
  jsarr:=jsroot.Values[name] as TJSONArray ;
  {$endif}

  SetLength(arr,jsarr.Count) ;
  for i:=0 to jsarr.Count-1 do
    arr[i]:=StrToInt(jsarr.Items[i].Value) ;
end;

function TObjectLoader.ReadArrayString(name: string;
  var arr: TArray<string>): Boolean;
var jsarr:TJSONArray ;
    i:Integer ;
begin
  {$ifdef fpc}
  jsroot.Find(name,jsarr) ;
  {$else}
  jsarr:=jsroot.Values[name] as TJSONArray ;
  {$endif}

  SetLength(arr,jsarr.Count) ;
  for i:=0 to jsarr.Count-1 do
    arr[i]:=jsarr.Items[i].Value ;
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
  {$ifdef fpc}
  jsroot.Find(name,jsarr) ;
  {$else}
  jsarr:=jsroot.Values[name] as TJSONArray ;
  {$endif}

  list.Clear() ;
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
  {$ifdef fpc}
  jsroot.Find(name,jsarr) ;
  {$else}
  jsarr:=jsroot.Values[name] as TJSONArray ;
  {$endif}

  list.Clear() ;
  for i:=0 to jsarr.Count-1 do begin
    rapi:=TReaderAPI.Create(jsarr.Items[i] as TJSONObject) ;
    reader(@rec,rapi) ;
    rapi.Free ;
    list.Add(rec) ;
  end;

  Result:=True ;
end;

function TObjectLoader.ReadStringList(name: string; list: TStringList): Boolean;
var jsarr:TJSONArray ;
    i:Integer ;
begin
  {$ifdef fpc}
  jsroot.Find(name,jsarr) ;
  {$else}
  jsarr:=jsroot.Values[name] as TJSONArray ;
  {$endif}

  list.Clear() ;
  for i:=0 to jsarr.Count-1 do
    list.Add(jsarr.Items[i].Value) ;
end;

function TObjectLoader.Section(name: string): TReaderAPI;
var jsobj:TJSONObject ;
begin
  if not readers.ContainsKey(name) then begin
    {$ifdef fpc}
    jsroot.Find(name,jsobj) ;
    {$else}
    jsobj:=jsroot.Values[name] as TJSONObject ;
    {$endif}

    readers.Add(name,TReaderAPI.Create(jsobj)) ;
  end;
  Result:=readers[name] ;
end;

end.
