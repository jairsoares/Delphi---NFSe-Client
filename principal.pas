unit principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,inifiles;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    verifica_servico: TTimer;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public

  end;

var
  Form1: TForm1; comeca_servico:string;

implementation
 uses
  dm_nota_nfse,preeche_ini;

{$R *.dfm}


procedure TForm1.FormCreate(Sender: TObject);
 var
  qt: TIniFile;
 begin
  qt         := TIniFile.Create('./config_nfse.ini');
  Form1.Visible := False;

   if  qt.ReadString('configuracoes','operacao','') = 'C' then  //CONSUTAR//
       BEGIN
            if busca_ini_config_nfse = true then
    begin
      if busca_ini_dados_nfse = true then
      begin
        if dm_nfse.configuracoes_preeche = true then
        begin
          if dm_nfse.servicos_preeche = true then
          begin
            if dm_nfse.tomador_preeche = true then
            begin
              if dm_nfse.emitente_preeche = true then
              begin
                dm_nfse.consulta_xml;
              end
              else
              begin
                Application.Terminate;
              end;
            end
            else
            begin
              Application.Terminate;
            end;
          end
          else
          begin
            application.terminate;
          end;
        end
        else
        begin
          application.terminate;
        end;
      end
      else
      begin
        application.terminate;
      end;
    end
    else
    begin
      application.terminate;
    end;
       END;

   if  qt.ReadString('configuracoes','operacao','') = 'T' then //TRANSMINTIR}//
  begin
    if busca_ini_config_nfse = true then
    begin
      if busca_ini_dados_nfse = true then
      begin
        if dm_nfse.configuracoes_preeche = true then
        begin
          if dm_nfse.servicos_preeche = true then
          begin
            if dm_nfse.tomador_preeche = true then
            begin
              if dm_nfse.emitente_preeche = true then
              begin
                if dm_nfse.gerar_NFSE = true then
                   begin
                    dm_nfse.consulta_nota;
                   end else
                         begin
                          Application.Terminate;
                         end;
              end
              else
              begin
                Application.Terminate;
              end;
            end
            else
            begin
              Application.Terminate;
            end;
          end
          else
          begin
            application.terminate;
          end;
        end
        else
        begin
          application.terminate;
        end;
      end
      else
      begin
        application.terminate;
      end;
    end
    else
    begin
      application.terminate;
    end;
  end;

   if  qt.ReadString('configuracoes','operacao','') = 'A' then //CANCELAR//
       BEGIN
    if busca_ini_config_nfse = true then
    begin
      if busca_ini_dados_nfse = true then
      begin
        if dm_nfse.configuracoes_preeche = true then
        begin

          dm_nfse.cancela_nfse;
          Application.Terminate;
        end
        else
        begin
          application.terminate;
        end;
      end
      else
      begin
        application.terminate;
      end;
    end
    else
    begin
      application.terminate;
    end;
  end;
  Application.Terminate;
 end;



end.
