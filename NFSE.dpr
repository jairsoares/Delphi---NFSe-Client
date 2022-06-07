program NFSE;

uses
  Vcl.Forms,
  principal in 'principal.pas' {Form1},
  dm_nota_nfse in 'dm_nota_nfse.pas' {dm_nfse: TDataModule},
  preeche_ini in 'preeche_ini.pas',
  ACBrNFSeNotasFiscais in 'ACBrNFSeNotasFiscais.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tdm_nfse, dm_nfse);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
