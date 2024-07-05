unit Profile;

interface
uses IniFiles,
  ActionConfig ;

type
  { TProfile }

  TProfileClass = class of TProfile ;

  TProfile = class
  private
    gamedir:string ;
    fullscr:Boolean ;
    soundon:Boolean ;
    actionconfig:TActionConfig ;
  protected
    procedure WriteExData(ini:TIniFile) ; virtual ;
    procedure ReadExData(ini:TIniFile) ; virtual ;
    procedure InitExData() ; virtual ;
  public
    constructor Create(Agamedir:string) ;
    procedure switchFullScreen() ;
    function isFullScreen():Boolean ;
    procedure switchSoundOn() ;
    function isSoundOn():Boolean ;
    function getActionConfig():TActionConfig ;
    procedure Load() ;
    procedure Save() ;
  end;

implementation
uses Classes, SysUtils,
  HomeDir ;

const
  PROFILE_FILE = 'profile.ini' ;

{ TProfile }

constructor TProfile.Create(Agamedir:string);
begin
  gamedir:=Agamedir ;
  actionconfig:=TActionConfig.Create() ;
end;

function TProfile.getActionConfig: TActionConfig;
begin
  Result:=actionconfig ;
end;

procedure TProfile.InitExData;
begin
end;

function TProfile.isFullScreen: Boolean;
begin
  Result:=fullscr ;
end;

function TProfile.isSoundOn: Boolean;
begin
  Result:=soundon ;
end;

procedure TProfile.Load;
var ini:TIniFile ;
    i:Integer ;
begin
  if FileExists(THomeDir.getFileNameInHome(gamedir,PROFILE_FILE)) then begin
    ini:=TIniFile.Create(THomeDir.getFileNameInHome(gamedir,PROFILE_FILE)) ;
    fullscr:=ini.ReadBool('Profile','Fullscr',False) ;
    soundon:=ini.ReadBool('Profile','SoundOn',True) ;
    for i := 0 to actionconfig.Count-1 do
      actionconfig.setActionFromPacked(i,
        ini.ReadString('Actions','Action_'+actionconfig.getActionName(i),'')) ;
    ReadExData(ini) ;
    ini.Free ;
  end
  else begin
    fullscr:=False ;
    soundon:=True ;
    InitExData() ;
  end;
end;

procedure TProfile.ReadExData(ini: TIniFile);
begin
end;

procedure TProfile.Save();
var ini:TIniFile ;
    i:Integer ;
begin
  THomeDir.createDirInHomeIfNeed(gamedir) ;
  ini:=TIniFile.Create(THomeDir.getFileNameInHome(gamedir,PROFILE_FILE)) ;
  ini.WriteBool('Profile','FullScr',fullscr) ;
  ini.WriteBool('Profile','SoundOn',soundon) ;
    for i := 0 to actionconfig.Count-1 do
      ini.WriteString('Actions','Action_'+actionconfig.getActionName(i),
        actionconfig.getActionPacked(i)) ;
  WriteExData(ini) ;
  ini.Free ;
end;

procedure TProfile.switchFullScreen;
begin
  fullscr:=not fullscr ;
  Save() ;
end;

procedure TProfile.switchSoundOn;
begin
  soundon:=not soundon ;
  Save() ;
end;

procedure TProfile.WriteExData(ini: TIniFile);
begin
end;

end.
