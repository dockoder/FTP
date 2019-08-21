unit uclientthread;

interface

uses
   windows, Classes, Sockets, umodulo, SysUtils;

type
  TC_OnStatus = procedure (sender:TObject; msg : string) of object;
  TC_OnGetInfo = procedure (sender:TObject; ou : TOtherUser) of object;
  TC_OnBytesTrans = procedure (sender:Tobject; way: integer; Abytes : int64;
                             velocidade : single) of object;
  TC_OnDestroy = procedure (sender : TObject) of Object;


  TClientThread = class(TThread)
  private
    FCommand, FFilePath, FFileToGet : string;
    FHost,FPort : string;
    FChatMessage : string;
    FBuFFerSize : integer;

    FPos  : int64;

    fClient : TTcpClient;
    fBytesTrans : int64;
    fVelocidade : single;
    fWay : integer;

    fMsgStatus : string;

         FOnStatus     : TC_OnStatus;
         FOnGetInfo    : TC_OnGetInfo;
         FOnBytesTrans : TC_OnBytesTrans;
         FOnDestroy    : TC_OnDestroy;

    OutroUser : TOtherUser;


  protected
    procedure Execute; override;

    procedure SetPort (value : string);
    procedure SetBufferSize(value : integer);

    procedure DoStatus;
    procedure DoBytesTrans;
    procedure DoDestroy;
    procedure Connect (Sender: TObject);
    procedure Disconnect (Sender: TObject);


    procedure AddOutros;
    procedure updatePage;

  public
    constructor Create(suspended : boolean; _Host,
                      _Command, _FilePath, _FileToGet : string; _pos:int64);  overload;
    destructor Destroy; override;

    procedure Conectar(Ahost,APort:string );
    procedure Reconectar;
    procedure Desconectar;

    procedure velocidade(var timeI : cardinal; const timeF : cardinal; var amount : integer);


  published

    property Command : string read fCommand write fCommand;
    property FilePath : string read fFilePath write fFilePath;
    property FileToGet : string read fFileToGet write fFileToGet;
    property Pos : int64 read fPos write fPos;

    property Host : string read FHost write fHost;
    property Port : string read fPort write setport;

    property ChatMessage : string read fChatMessage write fChatMessage;
    property BufferSize : integer read fBufferSize write SetBufferSize default 2048;

    property OnStatus:TC_OnStatus read FOnStatus write FOnStatus;
    property OnGetInfo:TC_OnGetInfo read FOnGetInfo write FOnGetInfo;
    property OnBytesTrans:TC_OnBytesTrans read FOnBytesTrans write FOnBytesTrans;
    property OnDestroy : TC_OnDestroy read FOnDestroy write FOnDestroy;
  end;

implementation

uses umain;

{ TClientThread }

procedure TClientThread.AddOutros;
var i : integer;
    achou : boolean;
    fs : TFileStream;
    ou : TOtherUser;
begin
  achou := false;
  if not FileExists(fclient.RemoteHost + '.nfo') then exit;

  fs := TFileStream.Create(fclient.RemoteHost + '.nfo', fmOpenRead)  ;
  try
    fs.Read(ou, sizeof(ou));
  finally
    fs.Free;
  end;

  for i := 0 to length(outros.items) - 1 do
     if outros.items[i].ip = Ou.ip then
       if outros.items[i].email = Ou.email then
          achou := true;

  if not achou then begin
    SetLength (outros.items, Length (outros.items) + 1);
    outros.items[Length (outros.items)-1] := Ou;
  end;

  DeleteFile(fclient.RemoteHost + '.nfo');

  if assigned(FOnGetInfo) then FOnGetInfo (self, ou);

end;

procedure TClientThread.Conectar;
begin
  if fclient.Connected then exit;
  fclient.RemoteHost := Ahost;
  fclient.RemotePort := Aport;
  fclient.Open;
  fPort := aport;
  fhost := ahost;
end;

procedure TClientThread.Connect(Sender: TObject);
begin
  fMsgStatus := 'conectado';
  Synchronize(DoStatus);
end;

constructor TClientThread.Create(suspended : boolean; _Host,
                      _Command, _FilePath, _FileToGet : string; _pos:int64);
begin
  inherited create(suspended);

  FreeOnTerminate := true;
  fclient := TTcpClient.Create(nil);
  fclient.OnConnect := Connect;
  fclient.OnDisconnect := Disconnect; 

  fHost := _Host;
  fPort := '50001';
  BufferSize := 2048;

  Command   := _Command;
  FileToGet := _FileToGet;
  FilePath  := _FilePath;
  Pos := _pos;

end;

procedure TClientThread.Desconectar;
begin
  fclient.close;
end;  

destructor TClientThread.Destroy;
begin
  fclient.close;
  fclient.Free;
  fclient := nil;
  Synchronize(DoDestroy);
  inherited;
end;

procedure TClientThread.Disconnect(Sender: TObject);
begin
  fMsgStatus := 'desconectado';
  Synchronize(DoStatus);
end;

procedure TClientThread.DoBytesTrans;
begin
  if assigned(FOnBytesTrans) then FOnBytesTrans(self,fWay,fBytesTrans, fVelocidade);
end;

procedure TClientThread.DoDestroy;
begin
  if assigned (FOnDestroy) then FOnDestroy(self);
end;

procedure TClientThread.DoStatus;
begin
  if assigned(FOnStatus) then   FOnStatus(self,fMsgStatus);
end;

procedure TClientThread.Execute;
var msg : string;
    buf : array of char;
    amt, amtTemp : integer;
    fs : TFileStream;
    ti, tf, tp : cardinal;
begin

  SetLength (buf, BufferSize);

  fMsgStatus := 'iniciando...';
  Synchronize(DoStatus);

  while (not terminated) or  (fclient.Connected)  do
  begin
      try
        Conectar(fHost, fPort);

        if fclient.Connected then
        begin

          if (fCommand = CONN_FILE) then
             msg := fCommand + inttostr(fpos) + '|' + fFileToGet
          else
            if (fCommand = CONN_DCL) then
              begin
                 msg := fCommand;
                 fpos := 0;
              end
            else if (fcommand = CONN_INFO) then
              msg := fCommand;

          fclient.SendBuf(msg[1], length(msg));

          if FileExists(fFilePath) then
            begin
               fs := TFileStream.Create(fFilePath, fmOpenWrite);
               fs.Position := fPos;
            end
          else
            fs := TFileStream.Create(fFilePath, fmCreate);

          if fclient.WaitForData(10000) then
            begin
              fWay := 0;
              ti := GetTickCount; //abre a contagem do relogio
              try                                             
                repeat
                  amt := fclient.ReceiveBuf(buf[0], BufferSize);
                  if amt > 0 then
                  begin
                    fBytesTrans := fBytesTrans + amt; //fbytestrans = total transmitido
                    fs.Write(buf[0], amt); //escreve para o ficheiro
                    //amtTemp é o total transmitido dentro do intervalo do relógio +- 1 segundo.
                    amtTemp := amtTemp + amt;
                  end;

                  tf := GetTickCount;  //tf : final da contagem do relogio
                  if (tf - ti >= 1000) then velocidade(ti, tf, amtTemp);

                until (amt = 0);//( amt < BuFFerSize );
              finally
                Synchronize(DoBytesTrans);
                fs.free;
                fclient.Close;
                terminate;
              end;
            end
          else
            begin
               fMsgStatus := 'tempo excedido';
               Synchronize(DoStatus);
            end; //if wait
        end; //if

      except
        fclient.close;
      end;

      sleep(1);

  end; //while

  if FCommand = CONN_INFO then Synchronize(AddOutros);
  if FCommand = CONN_DCL then Synchronize(updatePage);


  fMsgStatus := 'finalizado';
  Synchronize(DoStatus);

end;


procedure TClientThread.Reconectar;
begin
  fMsgStatus := 'reconectando';
  Synchronize(DoStatus);

  if fclient.Active then fclient.close;
  fclient.Open;
end;

procedure TClientThread.SetBufferSize(value: integer);
begin
  if fclient.Connected then exit;

  if value > 8192 then value := 8192;

  fBufferSize := value;

  fMsgStatus := 'Tamanho Buffer = ' + inttostr(fBufferSize);
  Synchronize(DoStatus);

end;

procedure TClientThread.SetPort(value: string);
begin
  if fclient.Connected then exit;
  fclient.RemotePort := fport;
end;

procedure TClientThread.updatePage;
var fs : TFileStream;
    dh : TDLHeader;
    i : integer;
begin
{  fillchar(dh, sizeof(TDLHeader), 0);
  fs := TFileStream.Create(fclient.RemoteHost + '.dcl', fmOpenRead);
  try
    fs.read(dh, sizeof(TDLHeader));
    for i := 0  to length(outros.items) - 1 do
     if outros.items[i].ip = fclient.RemoteHost then begin
      outros.items[i].share := dh.share;
      if assigned(FOnGetInfo) then FOnGetInfo (self, outros.items[i]);
     end;
  finally
    fs.Free;
  end; }

  with form4 do //form4 = form principal
  begin
    TabSheet4.Caption := 'Atualizando lista de arquivos de ' + fclient.RemoteHost+ '...';
    PopTreeView(fclient.RemoteHost + '.dcl', TreeView, statusbarArquivos.Panels[1]   );
    TabSheet4.Caption := fclient.RemoteHost;
    StatusBar.Panels[0].Text:='Lista de arquivos de '+fclient.RemoteHost+' foi atualizada.';
  end;  // with
end;

procedure TClientThread.velocidade(var timeI : cardinal; const timeF : cardinal; var amount : integer);
begin
  fVelocidade :=  amount / (timeF - timeI);

  Synchronize(DoBytesTrans);

  amount := 0;         //reinicia a contagem dos bytes transferidos.
  timeI := GetTickCount;   //reinicia a contagem do relogio.

end;

end.
