program FTP2;

uses
  Forms,
  umain in 'umain.pas' {Form4},
  umodulo in 'umodulo.pas' {DataModule2: TDataModule},
  uclientthread in 'uclientthread.pas',
  Unit5 in '..\..\RECURSIVE FIND\Unit5.pas' {Form5},
  udirs in '..\udirs.pas' {Form3},
  uoptions in '..\uoptions.pas' {Form2};

{$R *.res}


begin
  Application.Initialize;
  Application.CreateForm(TDataModule2, DataModule2);
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
