unit umain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Sockets, Menus, ComCtrls, StdCtrls, Spin, Buttons, ExtCtrls, umodulo,CommCtrl,
  ShellApi;

var user :TUserDef;
    Conexoes : TConexoes;
    Connexoes : TList;
    Conns : TConns;
    Outros : TOthers;
    downs : TDowns;
    filedown :  TFileDown;
    ServerThreads : TList;

type
  TForm4 = class(TForm)
    Splitter1: TSplitter;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    txtIP: TEdit;
    cmdConectar: TBitBtn;
    Button1: TButton;
    txtPorta: TSpinEdit;
    Panel2: TPanel;
    PageControl1: TPageControl;
    TabSheet2: TTabSheet;
    lvConns: TListView;
    TabSheet3: TTabSheet;
    lvTrans: TListView;
    page: TPageControl;
    Status: TTabSheet;
    TabSheet1: TTabSheet;
    ListView2: TListView;
    TabSheet4: TTabSheet;
    Splitter2: TSplitter;
    lvArquivos: TListView;
    Panel3: TPanel;
    Label4: TLabel;
    TreeView: TTreeView;
    StatusBar: TStatusBar;
    dlg: TOpenDialog;
    MainMenu1: TMainMenu;
    aRQUIVOS1: TMenuItem;
    mnureiniciar: TMenuItem;
    mnuferramentas: TMenuItem;
    mnuopcoes: TMenuItem;
    popmenu: TPopupMenu;
    mnureconectar: TMenuItem;
    mnudesconectar: TMenuItem;
    popArquivos: TPopupMenu;
    mnuDownArquivo: TMenuItem;
    mnuDownArquivoPara: TMenuItem;
    N2: TMenuItem;
    mnuDownAgenda: TMenuItem;
    server: TTcpServer;
    client: TTcpClient;
    mnuiniciar: TMenuItem;
    Splitter3: TSplitter;
    lvOutros: TListView;
    Timer: TTimer;
    statusbarArquivos: TStatusBar;
    memo: TRichEdit;
    N1: TMenuItem;
    mnuAbrirDirPadrao: TMenuItem;
    Label3: TLabel;
    cmbIPs: TComboBox;
    procedure cmdConectarClick(Sender: TObject);
    procedure serverAccept(Sender: TObject; ClientSocket: TCustomIpClient);
    procedure mnuopcoesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure lvArquivosSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure mnuDownArquivoClick(Sender: TObject);
    procedure lvTransCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure TimerTimer(Sender: TObject);
    procedure mnudesconectarClick(Sender: TObject);
    procedure mnuiniciarClick(Sender: TObject);
    procedure mnureiniciarClick(Sender: TObject);
    procedure serverCreateHandle(Sender: TObject);
    procedure mnuAbrirDirPadraoClick(Sender: TObject);
  private
    procedure AddConnListView(ou : TOtherUser; status, porta, activo : string);
    procedure NewOnStatusClient (sender:TObject; msg : string);
    procedure NewOnBytesTransClient (sender:Tobject; way: integer;
                                     Abytes : int64; velocidade : single);
    procedure NewOnGetInfo(sender:TObject; ou : TOtherUser);
    procedure NewOnDestroy(sender:TObject);
    procedure NewOnErrorServer(Sender: TObject; SocketError: Integer);
  public
    procedure NewOnStatus (sender: TObject; msg:string; status:integer);
  end;

  TSNotifyEvent = procedure (sender: TObject; msg:string; status:integer)of object;

  TServerThread = class (TThread)
  private
    fOnStatus : TSNotifyEvent;
    fMSG,
    fBuffer : string;
    fStatus : integer;
    procedure Action;
    procedure SendFile(path:string;ClientSocket: TCustomIpClient; aPos:int64);
    procedure SendInfoUser(ClientSocket: TCustomIpClient);
    function analiseCmd(cmd : string; var i:int64) : integer;

  public
    constructor Create(Suspended : boolean);
    procedure Execute;override;
  published
    property OnStatus : TSNotifyEvent read fOnStatus write fOnStatus;
  end;

var
  Form4: TForm4;

implementation

uses uclientthread, uoptions, Unit5;

{$R *.dfm}


{begin Funções de ajuda}

function AddDowns(fd : TFileDown) : TFileDown;
var i : integer;
    fonteOk, nomeOk, tamOK : boolean;
begin
  fonteOk := false;
  nomeOk := false;
  tamOK := false;

  for i := 0  to length(Downs.items) - 1  do
  begin
    if downs.items[i].fonte = fd.fonte then
    begin
       fonteOk := true;
       if downs.items[i].nome = fd.nome then
       begin
         nomeOk := true;
         if downs.items[i].tamanho  = fd.tamanho then tamOK := true;
       end;
    end;
  end;

  if fonteOk and nomeOk and tamOk then begin
    fd.prioridade := -100; //download já em curso
    result := fd;
    exit;
  end;

  if nomeok then begin
       if ( not tamOK) then fd.nome := '@'+ trim(fd.nome);
       SetLength (downs.items, length(downs.items) + 1);
       downs.items[ length(downs.items)-1 ] := fd;
  end;

  result := fd;


end;

procedure MemoAddMesssage(msg:string; status:integer);
var s , f : integer;
begin

  with form4.memo.SelAttributes do begin
     case status of
        {normal a preto e branco}
        0: begin
              Color := 0;
              Name := 'MS Sans Serif';
              size := 10;
              form4.memo.Lines.Append(msg);
           end;

           {mensagens do servidor}
        1: begin
              Charset := OEM_CHARSET;
              Color := cllime;
              Name := 'Terminal';
              form4.memo.Lines.Append(msg);
           end;

           {messagens de erro}
        2: begin
              Charset := OEM_CHARSET;
              Color := clred;
              Name := 'Terminal';
              form4.memo.Lines.Append('');
              form4.memo.Lines.Append('--------Servidor Erro---------');
              form4.memo.Lines.Append(msg);
              form4.memo.Lines.Append('------------------------------');
              form4.memo.Lines.Append('');
         end;
     end;
   end;



end;


{end Funções de ajuda}

procedure TForm4.cmdConectarClick(Sender: TObject);
var msg : string;
    buf : array [0..8192-1] of char;
    amt : integer;
    fs : TFileStream;
   outemp : TOtherUser;
begin
  outemp.ip := txtip.text;
  outemp.email :='desconhecido';
  outemp.nick := 'generico';
  outemp.share := 0;

  AddConnListView(outemp, 'conectando', txtporta.Text, 'yes');

  with TClientThread.Create(false,txtip.text,
                            CONN_INFO, trim(txtip.text) + '.nfo',
                            '', 0) do
  begin
    OnStatus := NewOnStatusClient;
    OnGetInfo := NewOnGetInfo;
    OnBytesTrans := NewOnBytesTransClient;
  end;

  with TClientThread.Create(false,txtip.text,
                            CONN_DCL, trim(txtip.text) + '.dcl',
                            '', 0) do
  begin
    OnStatus := NewOnStatusClient;
    OnBytesTrans := NewOnBytesTransClient;
  end;

end;

procedure TForm4.NewOnBytesTransClient(sender: Tobject; way: integer;
  Abytes: int64; velocidade : single);

   function CalcTemp (size, rest:int64; vel : single)  : string;
   var t : single;
       h, ht, m, mt, s, st : single;
       hi, mi, si : integer;
   begin
      t :=  (size-rest) / vel;

      m := (t / 60); mt := trunc(m);
      s := (m-mt) * 60;

      h := mt / 60; ht := trunc(h);
      m:= ((h - ht) *60);

      hi := trunc(h);
      mi := trunc(m);
      si := trunc(s);

      result := inttostr(hi)+':'+
                inttostr(mi)+':'+
                inttostr(si);
   end;

var i : integer;
    s : int64;
    pb : TProgressBar;                  
    color : integer;
    pct : single;
begin

  for i := 0 to lvTrans.Items.Count -1 do
    if lvTrans.Items[i].SubItems[2] = TClientThread(sender).FilePath then
    begin
         pb := TprogressBar(lvTrans.Items[i].Data);
         pb.Position := Abytes ;
         pct :=  Abytes / pB.Max * 100;
         case trunc(pct) of
            0..16  : color := clred;
            17..33 : color := $000080FF;
            34..50 : color := $00ECE113;
            51..65 : color := $00A87200;
            66..82 : color := $00E38E1C;
            83..100: color := clblue;
         end;
         SendMessage(PB.Handle, PBM_SETBARCOLOR, 0, color);
         s := StrToInt64(lvTrans.Items[i].SubItems[4]);
         lvTrans.Items[i].SubItems[3] := CalcTemp( s, abytes, velocidade);
         lvTrans.Items[i].SubItems[5] := floattostrf (velocidade, ffnumber, 4, 2) + ' kb/s';
         break;
    end;
end;

procedure TForm4.NewOnStatus(sender: TObject; msg: string;
  status: integer);
begin
  if msg = '' then exit;
  MemoAddMesssage(msg, status);
end;

procedure TForm4.NewOnStatusClient(sender: TObject; msg: string);
var i : integer;
begin

  for i := 0 to lvConns.Items.Count -1 do
    if lvConns.Items[i].Caption = TClientThread(sender).Host then
    begin
         lvConns.Items[i].SubItems[1] := msg;
         break;
    end;

end;

procedure TForm4.serverAccept(Sender: TObject;
  ClientSocket: TCustomIpClient);
var amt : Integer;
    buf : array [0..4096-1] of char;
    st : TServerThread;
    i64: int64;
    i : integer;
begin
 //  if user.ups = ServerThreads.Count then exit;
    fillchar(buf, sizeof(buf), 0);

    st := TServerThread.Create(false);
                                      ServerThreads.Add(st); 
    st.OnStatus := NewOnStatus;
    with st do
    begin          
        repeat
           amt := ClientSocket.ReceiveBuf(buf, sizeof(buf));
           fbuffer := fbuffer + string(buf);
           fillchar(buf, sizeof(buf), 0);
        until( amt <= sizeof(buf));
        fMSG := fbuffer;
        fBuffer := '';

        case analiseCmd(fmsg, i64) of
          0, 1: SendFile(fmsg, clientsocket, i64);
          2: Synchronize (Action );
          3: SendInfoUser(clientsocket);
        end;  //case

    end;//with

end;


{ TServerThread }

function TServerThread.analiseCmd(cmd: string; var i : int64): integer;
var str : string;
begin
  i := 0;
  result := 1;

  str :=  Copy(cmd, 1, 5);

  if str = CONN_DCL then
    begin
      fMsg := 'dclist.dat';
      i := 0;
      exit;
    end;

  if str = CONN_FILE then
    begin
      try
        i := strtoint64( copy(cmd, 6, pos('|', cmd)-7) );
      except  end;
      fMsg := copy(cmd, pos('|', cmd)+1, length(cmd));
    end;


  if str = trim(CONN_MSG) then
    begin
      fMsg := Copy(fMsg, 6, length(fMsg));
      fStatus := 2;
      result := 2;
    end;

  if str = CONN_INFO then
    begin
      fMsg := Copy(fMsg, 6, length(fMsg));
      fStatus := 3;
      result := 3;
    end;

end;

procedure TServerThread.SendInfoUser;
var ou : TOtherUser;
begin
  fillchar(ou, sizeof(ou), 0);

  ou.nick := user.nick;
  ou.email := user.email;
  ou.ip := GetLocalIP;

  ClientSocket.SendBuf(ou, sizeof(ou));
end;

procedure TServerThread.SendFile(path: string;
  ClientSocket: TCustomIpClient; APos:int64);
var fs : TFileStream;
    buffer : array [0..8192-1] of char;
    amt, amtTrf : integer;
begin
  if not FileExists(path) then exit;

  amt := 0;
  amtTRF := 0;

  fstatus := 1;

  fs := TFileStream.Create (path, fmOpenRead);
  try
     fs.Position := Apos;
     fMSG := 'Iniciando envio do arquivo '+ path + #13#10 +
             'Destino: ' + clientsocket.RemoteHost + #13#10 +
             'Posição de leitura: ' + inttostr(APos) + ' bytes.';
     Synchronize(Action);


      try
        repeat
          amt := fs.Read(buffer, sizeof(buffer));
          amtTrf := amttrf + clientsocket.SendBuf (buffer, amt);
        until fs.Position = fs.Size; //amt < 8192;
      except
         fMsg := 'Algum erro ocorreu no envio para...' + clientsocket.RemoteHost+
                 'Total de bytes : ' + inttostr( amttrf);
         fStatus := 1;
         Synchronize(Action);
      end; //exc

      fMsg := 'Finalizando tranferência para ...' + clientsocket.RemoteHost+
                 'Total de bytes : ' + inttostr( amttrf);
      fStatus := 1;
      Synchronize(Action);
  finally
    fs.Free;
  end;//fin

end;


procedure TServerThread.Action;
begin
  if assigned (FONStatus) then fOnStatus(self, fmsg, fStatus);
end;

constructor TServerThread.Create(Suspended: boolean);
begin
  inherited; 
end;

procedure TServerThread.Execute;
begin
   Synchronize(Action);
end;


procedure TForm4.mnuopcoesClick(Sender: TObject);
begin
 with Tform2.Create(self) do showmodal;

end;

procedure TForm4.FormCreate(Sender: TObject);
var   f : file of TUserDef;
label opt;
begin
  server.OnError := NewOnErrorServer;
  conns := TConns.Create;

  cmbIps.Items.Text := GetLocalIP;
  cmbips.Text := cmbIPs.Items[0];

opt:
   //saca as opções do utilizador
   if FileExists('opt.dat') then
     begin
       assignfile(f, 'opt.dat');
       try
         Reset(f);
         Read(f, user);
       finally
         closefile(f);
       end;
     end
   else
     begin
       with Tform2.Create(self) do showmodal;
       goto opt;
     end;

  statusbar.Panels[2].Text := cmbIps.Text;
  application.ProcessMessages;

  if ( user.listenport = 0 ) then user.listenport := 50001;

  server.LocalPort := inttostr(user.listenport);
  server.open;

end;

procedure TForm4.FormDestroy(Sender: TObject);
var i : integer;
begin
 // for i := 0 to conns.Count -1 do TClientThread( conns[i] ).Terminate;
  conns.Clear;
  conns.Free;
  conns := nil;
end;


function GetPathNode(node : TTreeNode; var list : TStringList): boolean;
  var n : TTreeNode;
  begin
    try
      n := node.Parent;
      if n <> nil then begin
         list.Insert(0, n.Text);
        GetPathNode(n, list);
      end;
    except end;
 end;

procedure TForm4.TreeViewChange(Sender: TObject; Node: TTreeNode);
var list : TStringList;

  function PegaUltimoPonto(str : string) : integer;
  var i : integer;
  begin
     for i := 1 to length(str) do
       if str[i] = '.' then result := i;
  end;

  function PegaPrimeiroCifrao(str : string) : integer;
  var i : integer;
  begin
     for i := 1 to length(str) do
       if str[i] = '$' then result := i;
  end;

var i : integer;
    f : TextFile;
    path, strFile, ln, strSize : string;
begin
    list := TStringList.Create;
    try
      list.Append(node.Text);
      GetPathNode(node, list);
      for i := 0 to (list.Count -1)  do path := path + list[i] + '\';
    finally
      list.free;
    end;



    //if not FileExists('dclist.dat') then exit;
    if not FileExists(page.ActivePage.Caption + '.dcl')  then  exit;

    //assignfile(f, 'dclist.dat');page.ActivePage.Caption + '.dcl'
     assignfile(f, page.ActivePage.Caption + '.dcl');
    try
     reset(f);
     lvArquivos.Clear;
     while not eof(f) do
       begin
          readln(f, ln);
          strSize := copy (ln, 1, PegaPrimeiroCifrao(ln)-1);
          strFile := copy (ln, PegaPrimeiroCifrao(ln) + 1 , length(ln) );

          if sametext (path, copy(strFile,1, length(path)) ) then
            begin
              strFile := copy (strFile, length(path)+ 1, length(strFile));
              if (pos('\', strFile ) = 0){ and (strSize <> '0') }then
                begin
                  lvArquivos.AddItem( copy(strFile, 1 , PegaUltimoPonto(strFile)-1), nil );
                  lvArquivos.Items[lvArquivos.Items.Count -1].SubItems.Append (
                                 copy(strFile,  PegaUltimoPonto(strFile)+1, length(strfile) ));

                  lvArquivos.Items[lvArquivos.Items.Count -1].SubItems.Append (strSize);
                end;

            end;
       end;
    finally
      closefile(f);
    end;


end;

procedure TForm4.lvArquivosSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var list : TStringList;
    i : integer;
    path : string;
begin
   if not selected then exit;
   list := TStringList.Create;
   try
     list.Append( TreeView.Selected.Text);
     GetPathNode(TreeView.Selected, list);
     for i := 0 to (list.Count -1)  do path := path + list[i] + '\';
   finally
     list.free;
   end;

   path := path + item.Caption + '.'+item.SubItems[0]  ;

   with filedown do
   begin
    fonte := TabSheet4.caption;
    nome := item.Caption + '.'+item.SubItems[0];
    apath := path;
    tamanho := strtoint(item.SubItems[1]);
    prioridade := 1;
    status := 0;
   end;

end;

procedure TForm4.mnuDownArquivoClick(Sender: TObject);

    procedure SetLvTrans;
    var i : integer;
        achou : boolean;
        pb : TProgressbar;
        r : Trect;
        ou : TOtherUser;
    begin
    for i := 0 to length(outros.items) - 1 do
      if outros.items[i].ip = filedown.fonte then ou := outros.items[i];

      for i := 0 to lvTrans.Items.Count -1 do
        if lvTrans.Items[i].SubItems[2]  =  filedown.nome then begin
          achou := true;
          break;
        end;

      if not achou then begin
       lvTrans.AddItem(filedown.fonte, nil);
       i := lvTrans.Items.Count -1;
      end else begin
        statusbar.Panels[0].Text := 'download ja iniciado';
      end;

      lvTrans.Items[i].SubItems.Append('download');
      lvTrans.Items[i].SubItems.Append('');
      lvTrans.Items[i].SubItems.Append(filedown.nome);
      lvTrans.Items[i].SubItems.Append('0');
      lvTrans.Items[i].SubItems.Append(inttostr(filedown.tamanho));
      lvTrans.Items[i].SubItems.Append('0,0 kb/s');

      r :=  lvTrans.Items[i].DisplayRect(drBounds);
      r.Left := r.Left + lvTrans.columns[0].Width + lvTrans.columns[1].Width;
      r.Right := r.Left + lvTrans.columns[2].Width;
      pb := Tprogressbar.Create(self);
      with pb do begin
         Parent := lvTrans;
         BoundsRect := r;
         Max := filedown.tamanho;
         Position := 0;
         Smooth := true;
         lvTrans.Items[i].Data := pb;
         SendMessage(PB.Handle, PBM_SETBARCOLOR, 0, $00FF0000);
      end;
    end;

var ct : TClientThread;
    i : integer;
    ip : string;
    fd : TFileDown;
begin

  fd.fonte := TabSheet4.Caption;
  fd := AddDowns(filedown);

  for i := 0 to conns.Count - 1 do
     if ( TClientThread( conns[i] ).Host = fd.fonte ) and
        ( TClientThread( conns[i] ).FilePath = fd.nome )  then exit;


    ct := TClientThread.Create(true, fd.fonte, CONN_FILE, fd.nome, fd.apath , 0) ;
    with ct do
    begin
      SetLvTrans;
      OnStatus := NewOnStatusClient;
      OnBytesTrans := NewOnBytesTransClient;
      OnDestroy := NewOnDestroy;
      resume;
    end;

    conns.Add(ct);  

end;


procedure TForm4.AddConnListView(ou : TOtherUser; status, porta, activo : string);
var i : integer;
    achou : boolean;
begin
  with lvConns do begin
     for i := 0 to lvconns.Items.Count -1 do
       if lvconns.Items[i].Caption  = ou.ip then begin
         achou := true;
         break;
       end;
     if not achou then begin
       AddItem(ou.ip, NIL);
       Items[Items.Count-1].SubItems.Append(ou.nick);
       Items[Items.Count-1].SubItems.Append(status);
       Items[Items.Count-1].SubItems.Append(porta);
       Items[Items.Count-1].SubItems.Append(activo);
       Items[Items.Count-1].SubItems.Append(ou.email);
       Items[Items.Count-1].SubItems.Append( IntToStr( ou.share) );
       with lvOutros do begin
         AddItem(ou.nick, NIL);
         Items[Items.Count-1].SubItems.Append(ou.ip);
         Items[Items.Count-1].SubItems.Append(ou.email);
       end;
     end else begin
       items[i].SubItems[0] := ou.nick;
       items[i].SubItems[1] := status;
       items[i].SubItems[2] := porta;
       items[i].SubItems[3] := activo;
       items[i].SubItems[4] := ou.email;
       items[i].SubItems[5] := IntToStr( ou.share);
       with lvOutros do begin
        items[i].SubItems[0] := ou.ip;
        items[i].SubItems[1] := ou.email;
       end;

     end;
  end;
end;

procedure TForm4.NewOnGetInfo(sender: TObject; ou: TOtherUser);
begin
   with ou do
   AddConnListView(ou, 'info', TClientThread(sender).Port, 'false');
end;

procedure TForm4.lvTransCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if item.Index mod 2 = 0 then
    LvTrans.Canvas.Brush.Color  := $00FFEFCE
  else
    LvTrans.Canvas.Brush.Color := $00E9E9E9;
end;

procedure TForm4.TimerTimer(Sender: TObject);
var i, ii : integer;
begin
  for i := 0 to lvTrans.Items.Count -1 do
    if TProgressbar( lvTrans.Items[i].Data ).Position =
       TProgressbar( lvTrans.Items[i].Data ).Max then begin
       TProgressbar( lvTrans.Items[i].Data ).Free;
       lvTrans.Items.Delete(i);
       break;
    end;

end;

procedure TForm4.mnudesconectarClick(Sender: TObject);
var i : integer;
begin

  if lvtrans.ItemIndex < 0 then exit;

  for i := 0 to conns.count -1 do
   if TClientThread(conns[i]).Host = lvTrans.Items[ lvtrans.ItemIndex ].caption then
     if TClientThread(conns[i]).FilePath =
         lvTrans.Items[ lvtrans.ItemIndex ].SubItems[2] then
             begin
              TProgressbar (lvTrans.Items[ lvtrans.ItemIndex ].Data ).Free;
              TClientThread(conns[i]).Desconectar;
              break;
             end;

end;

procedure TForm4.NewOnDestroy(sender: TObject);
var i : integer;
begin
   for i := 0 to conns.Count -1 do
     if  conns[i] = sender then
     begin
      conns.Delete(i);
      conns.Pack;
     end;
end;

procedure TForm4.mnuiniciarClick(Sender: TObject);
begin
  server.Open;
end;

procedure TForm4.mnureiniciarClick(Sender: TObject);
begin
  server.close;
  server.open;
end;

procedure TForm4.serverCreateHandle(Sender: TObject);
begin
  MemoAddMesssage('Iniciando servidor de ftp' + #13#10 +
                  'IP local: ' + cmbIps.Text + #13#10 +
                  'Data e hora: ' + DateTimeToStr(now)+ #13#10 +
                  'Servidor a escuta...', 1);

end;


procedure TForm4.NewOnErrorServer(Sender: TObject; SocketError: Integer);
var msg : string;
begin
  case SocketError of
    10048 : msg :=  'Address already in use';
    10053 : msg :=  'Software caused connection abort';
    10061 : msg :=  'Connection refused';
    10054 : msg :=  'Connection reset by peer';
    10039 : msg :=  'Destination address required';
    10065 : msg :=  'No route to host';
    10024 : msg :=  'Too many open files';
    10050 : msg :=  'Network is down';
    10052 : msg :=  'Network dropped connection';
    10055 : msg :=  'No buffer space available';
    10051 : msg :=  'Network is unreachable';
    10060 : msg :=  'Connection timed out';
    11001 : msg :=  'Host not found';
    10091 : msg :=  'Network sub-system is unavailable';
    10093 : msg :=  'WSAStartup not performed';
    11004 : msg :=  'Valid name, no data of that type';
    11003 : msg :=  'Non-recoverable query error';
    11002 : msg :=  'Non-authoritative host found';
    10092 : msg :=  'Wrong WinSock DLL version';
    else    msg :=  'Erro unknown';
  end;
  MemoAddMesssage(msg, 2);

end;

procedure TForm4.mnuAbrirDirPadraoClick(Sender: TObject);
begin
  ShellExecute(Application.Handle,
    PChar('explore'),
    PChar(user.defaultdir[0]),
    nil,
    nil, 
    SW_SHOWNORMAL);
end;

initialization
  ServerThreads := TList.Create;
finalization
  ServerThreads.free;

end.


























