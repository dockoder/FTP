unit DM;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  IdThreadMgr, IdThreadMgrDefault, IdUserAccounts, IdBaseComponent,
  IdComponent, IdTCPServer, IdFTPServer, IdFTPList;

const FTP_DIR_PATH = 'c:\FTP\';

type
  TService2 = class(TService)
    FTP: TIdFTPServer;
    UserManager: TIdUserManager;
    ThreadManager: TIdThreadMgrDefault;
    procedure FTPUserLogin(ASender: TIdFTPServerThread; const AUsername,
      APassword: String; var AAuthenticated: Boolean);
    procedure ServiceCreate(Sender: TObject);
    procedure FTPAfterUserLogin(ASender: TIdFTPServerThread);
    procedure FTPDeleteFile(ASender: TIdFTPServerThread;
      const APathName: String);
    procedure FTPChangeDirectory(ASender: TIdFTPServerThread;
      var VDirectory: String);
    procedure FTPGetFileSize(ASender: TIdFTPServerThread;
      const AFilename: String; var VFileSize: Int64);
    procedure FTPListDirectory(ASender: TIdFTPServerThread;
      const APath: String; ADirectoryListing: TIdFTPListItems);
    procedure FTPMakeDirectory(ASender: TIdFTPServerThread;
      var VDirectory: String);
    procedure FTPRemoveDirectory(ASender: TIdFTPServerThread;
      var VDirectory: String);
    procedure FTPRenameFile(ASender: TIdFTPServerThread;
      const ARenameFromFile, ARenameToFile: String);
    procedure FTPRetrieveFile(ASender: TIdFTPServerThread;
      const AFileName: String; var VStream: TStream);
    procedure FTPStoreFile(ASender: TIdFTPServerThread;
      const AFileName: String; AAppend: Boolean; var VStream: TStream);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  Service2: TService2;

implementation

uses IniFiles, IdRFCReply;

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  Service2.Controller(CtrlCode);
end;

procedure TService2.FTPAfterUserLogin(ASender: TIdFTPServerThread);
begin
   ASender.HomeDir := ASender.Username+ '\';
   ASender.CurrentDir := ASender.CurrentDir;
end;

procedure TService2.FTPDeleteFile(ASender: TIdFTPServerThread;
  const APathName: String);
var path : string;
begin
  path := FTP_DIR_PATH + APathName;
  if FileExists(path) then  DeleteFile(path);
end;

procedure TService2.FTPChangeDirectory(ASender: TIdFTPServerThread;
  var VDirectory: String);
var
  path: string;
begin
  path := FTP_DIR_PATH + asender.Username+ VDirectory ;
  if DirectoryExists(path) then
     ASender.CurrentDir := VDirectory;
end;

procedure TService2.FTPGetFileSize(ASender: TIdFTPServerThread;
  const AFilename: String; var VFileSize: Int64);
var
  f: file;
  path: string;
begin
  VFileSize := 0;

  path := FTP_DIR_PATH + AFilename ;

  if FileExists(path) then
    try
      AssignFile(f, path);
      Reset(f, 1);
      VFileSize := filesize(f);
    finally // wrap up
      closefile(f);
    end;    // try/finally

end;


function TService2.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TService2.FTPUserLogin(ASender: TIdFTPServerThread;
  const AUsername, APassword: String; var AAuthenticated: Boolean);

begin
   AAuthenticated :=  UserManager.AuthenticateUser(AUsername, APassword);
end;

procedure TService2.ServiceCreate(Sender: TObject);
const CHAR_USERACCOUNT_SEP_PROPERTY = '&';

  function FillUserAccountProperties(var ua : TIdUserAccount;
                                      values : string) : boolean;
  begin
    result := false;
    if UA = nil then exit;

    ua.RealName :=  Copy(values, 1, Pos(CHAR_USERACCOUNT_SEP_PROPERTY, values)-1);
    Delete(values, 1, Pos(CHAR_USERACCOUNT_SEP_PROPERTY, values));

    ua.UserName :=  Copy(values, 1, Pos(CHAR_USERACCOUNT_SEP_PROPERTY, values)-1);
    Delete(values, 1, Pos(CHAR_USERACCOUNT_SEP_PROPERTY, values));

    ua.Password :=  Copy(values, 1, Pos(CHAR_USERACCOUNT_SEP_PROPERTY, values)-1);
    Delete(values, 1, Pos(CHAR_USERACCOUNT_SEP_PROPERTY, values));

    ua.Attributes.Append (values);
    result := true;

  end;
var
  I: Integer;
  ua : TIdUserAccount;
begin
  with TStringList.Create  do
  try
    LoadFromFile('users.dat');
    for I := 0 to Count - 1 do    // Iterate
      begin
      ua := UserManager.Accounts.Add;
      FillUserAccountProperties(ua, Strings[i]);
      end;
  finally // wrap up
    Free;
  end;    // try/finally
end;

procedure TService2.FTPListDirectory(ASender: TIdFTPServerThread;
  const APath: String; ADirectoryListing: TIdFTPListItems);
var path : string;
    sr : TSearchRec;
    FileAttrs : integer;
begin

  ADirectoryListing.DirectoryName := APath;

  path := FTP_DIR_PATH + APath;
  if not DirectoryExists(path) then  Exit;

  FileAttrs := faDirectory + faArchive;

  {— - Permission omitted.
	L - Symbolic Link.
	D - Directory entry.
	R - Read permission granted.
	W - Write prmission granted
	X - Execute permission granted.}

  if FindFirst(path + '\*.*', FileAttrs, sr) = 0 then
    repeat
      with ADirectoryListing.add do
        begin
        FileName := sr.Name;
        Size := sr.Size;
        ModifiedDate := FileDateToDateTime(sr.Time);
        if sr.Attr and faDirectory = faDirectory then
          begin
          ItemType := ditDirectory;
          OwnerPermissions := '-DRW-';
          end
        else
          begin
          ItemType := ditFile;
          OwnerPermissions := '--RW-';
          end;
        end;
    until FindNext(sr) <> 0;
  FindClose(sr);

end;

procedure TService2.FTPMakeDirectory(ASender: TIdFTPServerThread;
  var VDirectory: String);
var
  path: string;
begin
  path := FTP_DIR_PATH + VDirectory ;
  if not DirectoryExists(path) then CreateDir(path);

end;
procedure TService2.FTPRemoveDirectory(ASender: TIdFTPServerThread;
  var VDirectory: String);
var
  path: string;
begin
  path := FTP_DIR_PATH + VDirectory ;
  if DirectoryExists(path) then RemoveDir(path);
end;

procedure TService2.FTPRenameFile(ASender: TIdFTPServerThread;
  const ARenameFromFile, ARenameToFile: String);
var
  path, path1: string;
begin
  path := FTP_DIR_PATH + ARenameFromFile ;
  path1 := FTP_DIR_PATH + ARenameToFile ;

  if FileExists(path) then RenameFile(path, path1);
end;
procedure TService2.FTPRetrieveFile(ASender: TIdFTPServerThread;
  const AFileName: String; var VStream: TStream);
var
  path: string;
  fs: TFileStream;
begin
  path := FTP_DIR_PATH + AFileName;
  if not FileExists(path) then
    VStream := nil
  else
    try
      fs := TFileStream.Create(path, fmOpenRead);
      VStream := fs;
    except end;
end;

procedure TService2.FTPStoreFile(ASender: TIdFTPServerThread;
  const AFileName: String; AAppend: Boolean; var VStream: TStream);
var
  path: string;
  fs: TFileStream;
  ErrReply : TIdRFCReply ;
begin
  if ExtractFileExt(AFileName) = '.exe' then
    begin
    ErrReply := TIdRFCReply.Create(nil);
    try
      ErrReply.Clear;
      ErrReply.SetReply(553, 'Ação não completada. Executáveis não são permitidos neste serviço.');
      ASender.Connection.WriteRFCReply(ErrReply);
    finally // wrap up
      FreeAndNil(ErrReply);
    end;    // try/finally
    exit;
    end;


  path := FTP_DIR_PATH + AFileName;

  fs := TFileStream.Create(path, fmOpenWrite);
  try
    if AAppend then
      begin
      fs.Seek(0, soFromEnd);
      fs.CopyFrom(VStream, VStream.Size);
      end
    else
      fs.CopyFrom(VStream, VStream.Size);
  finally // wrap up
    FreeAndNil(fs);
  end;    // try/finally
end;

end.
