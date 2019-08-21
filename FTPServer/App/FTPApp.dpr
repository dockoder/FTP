program FTPApp;

{%File 'lista de respostas para os comandos.txt'}
{%File '..\RFC959.txt'}

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  DM in 'DM.pas' {Service2: TService};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TService2, Service2);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
