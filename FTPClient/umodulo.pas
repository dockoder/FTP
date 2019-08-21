unit umodulo;

interface

uses
  SysUtils, Classes, scktcomp, ComCtrls, forms, winsock;

var gDiretorios : TstringList;
    versao : string = '0.0.1';

const

  CONN_DCL  = '$dcl ';
  CONN_FILE = '$file';
  CONN_MSG  = '$msg ';
  CONN_INFO = '$info';


type
  {header do arquivo de dclist.dat}
  TDLHeader = record
    size,
    wDirs : cardinal;
    share : int64;
    strDirs  : string;
  end;

  TUserDef = record
    nick : string[8];
    email : string[50];
    conx,
    defaultdir,
    dirlist : string[255];
    ups,
    downs,
    listenport : integer;
  end;

  TOtherUser = record
    nick : string[8];
    email : string[50];
    ip : string[15];
    share : int64;
  end;

  TOthers = record
    items : array of TOtherUser;
  end;

  TFileDown = record
    fonte : string[15];
    nick,
    nome,
    apath, 
    fontes : string[255];
    tamanho : int64;
    status,
    prioridade : integer;
  end;

  TDowns = record
    items : array of TFileDown;
  end;

  TConnexao = record
    RemoteHost,
    RemoteIp,
    RemoteUser,
    atividade : string;
    Inicio : TDateTime;
  end;

  TConexoes = record
    conexoes : array of TConnexao;
  end;



  TConns = class (TList);

  TDataModule2 = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure PopTreeView(pathfile:string; treev : TTreeview; panel :  TStatusPanel);
function GetSizeOfHDR(hdr: TDLHeader): cardinal;
procedure SetDownsList(filetodown:TFileDown);
function GetDownsList : TDowns;
function GetLocalIP : string;

var
  DataModule2: TDataModule2;

implementation

uses Unit5;

{$R *.dfm}


procedure TDataModule2.DataModuleCreate(Sender: TObject);
var f : textfile;
begin
   if not FileExists('greetings.txt') then
   begin
     assignfile(f, 'greetings.txt');
     try
       rewrite(f);
     finally
       closefile(f);
     end;
   end;

  if not FileExists('greetto.txt') then
  begin
     assignfile(f, 'greetto.txt');
     try
       rewrite(f);
     finally
       closefile(f);
     end;
  end;

   gDiretorios := TstringList.Create;
   with Tform5.Create(self) do showmodal;
end;

procedure TDataModule2.DataModuleDestroy(Sender: TObject);
begin  
   gdiretorios.free;
end;

function GetSizeOfHDR(hdr: TDLHeader): cardinal;
begin
  result := sizeof(hdr.size)+
            sizeof(hdr.wDirs)+
            sizeof(hdr.share);
end;



procedure ExtractDirs(const path : string;  var st:TstringList);
var temp : string;
begin
  temp := path;
  if pos(':', temp) > 0 then
    begin
      st.Append(copy (temp, 1,  pos(':', temp)));
      delete(temp, 1, pos(':', temp)+1 );
    end;

  if pos('\', temp) > 0 then
    begin
      while pos('\', temp) > 0 do
        begin
          st.Append(copy (temp, 1,  pos('\', temp)-1));
          delete( temp, 1,  pos('\', temp) );
        end ;
      if temp <> '' then  st.Append(temp);
    end
  else
    st.Append(copy (temp, 1,  length(temp)));

  st.Append('$$$');

end;

procedure PopTreeView(pathfile:string; treev : TTreeview; panel :  TStatusPanel);
var node : TTreeNode;
    hdr : TDLHeader;
    i,ii, idx : integer;
   // fs : TFileStream;
    st, stTemp : TstringList;
    achou : boolean;
    strshare : string;
label cont;
begin


 fillchar(hdr, sizeof(TDLheader), 0);

 if not FileExists(pathfile) then exit;

{ fs := TFileStream.Create(pathfile, fmOpenRead);
 if fs.size = 0 then
   begin
     fs.free;
     exit;
   end;

 try
   fs.Read(hdr, 16);
   setlength(hdr.strDirs, hdr.size -16);
   for i := 1 to hdr.size - 16 do  fs.Read(hdr.strDirs[i], 1);
 finally
   fs.free;
 end;
}
 with TFileStream.Create(pathfile, fmOpenRead) do
 begin
   if size = 0 then
     begin
       free;
       exit;
     end;

   try
     Read(hdr, 16);
     setlength(hdr.strDirs, hdr.size -16);
     for i := 1 to hdr.size - 16 do Read(hdr.strDirs[i], 1);
   finally
     free;
   end;
 end;    // with


 case hdr.share of
   0 : strshare := 'nada';
   1..9999 : strShare := inttostr(hdr.share) + ' bytes';
   10000..999999 : strShare := FloatToStrF(hdr.share / 1000, ffNumber, 5, 3) + ' Kb';
   1000000..999999999 : strShare := FloatToStrF(hdr.share / 1000000, ffNumber, 6, 3) + ' Mb';
 else strShare := FloatToStrF(hdr.share / 1000000000, ffFixed, 6, 3) + ' Gb';
 end;
 panel.Text := strShare;

 st := TstringList.Create;
 stTemp := TstringList.Create;
 try
   try
     stTemp.Text := hdr.strDirs;
     for i := 0 to stTemp.Count -1 do  ExtractDirs(stTemp[i], st);
   finally
     stTemp.Free;
   end;

   idx := 0;
   node := nil;

   for i := 0 to st.Count -1 do
   begin
    achou := false;

    if st[i] <> '$$$' then
    begin
      for ii := 0 to treev.Items.Count -1 do
            if treev.Items[ii].Text = st[i] then
              begin
                achou := true;
                node := treev.Items[ii];
              end;

      if idx = 0 then
        begin
          if not achou then
          begin
            node := nil;
            node := treev.Items.AddFirst(node, st[i]);
          end;
        end
      else
        begin
          if not achou then node := treev.Items.AddChild(node, st[i]);
        end;

      inc(idx);

    end

    else
      idx := 0;

          application.ProcessMessages;

   end;

 finally

   st.free;
 end;

end;

procedure SetDownsList(filetodown:TFileDown);
var f : File of TFileDown;
    fd : TFileDown;
    achou : boolean;
begin
  assignfile(f,'dwnlist.dat' );
  try
    if FileExists('dwnlist.dat') then
      reset(f)
    else
      rewrite(f);

    repeat
       read(f, fd);
       if ( fd.nome = filetodown.nome ) and
          (fd.tamanho = filetodown.tamanho) then achou := true;
    until eof(f);

    if not achou then write(f, filetodown);

  finally
    closefile(f);
  end;

end;

function GetDownsList : TDowns;
var f : File of TFileDown;
    fd : TFileDown;
    idx: integer;
begin
  idx := -1;
  if not FileExists('dwnlist.dat') then exit;

  assignfile(f,'dwnlist.dat' );
  try
    reset(f);
    repeat
       read(f, fd);
       if fd.nome <> '' then
         begin
          inc(idx);
          setlength(result.items, length(result.items)+1);
          result.items[idx] := fd;
         end;
    until eof(f);
  finally
    closefile(f);
  end;

end;

function GetLocalIP : string;
type
    TaPInAddr = array [0..10] of PInAddr;
    PaPInAddr = ^TaPInAddr;
var
  phe : PHostEnt;
  pptr : PaPInAddr;
  Buffer : array [0..63] of char;
  I : Integer;
  GInitData : TWSADATA;
  address  : string;
begin
    WSAStartup($101, GInitData);
    Result := '';
    GetHostName(Buffer, SizeOf(Buffer));
    phe :=GetHostByName(buffer);
    if phe = nil then Exit;
    pptr := PaPInAddr(Phe^.h_addr_list);
    I := 0;
    while pptr^[I] <> nil do
    begin
      address:=StrPas(inet_ntoa(pptr^[I]^)) + #13+#10;
      result :=  result + address;
      Inc(I);
    end;
    WSACleanup;
end;


end.

