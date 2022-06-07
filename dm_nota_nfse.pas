unit dm_nota_nfse;

interface

uses
  System.SysUtils, System.Classes, ACBrBase, ACBrDFe, ACBrNFSe, ACBrDFeReport, ACBrNFSeDANFSeClass, ACBrNFSeDANFSeFR, inifiles, vcl.dialogs, Vcl.ExtCtrls, Vcl.ExtDlgs, pcnConversao, pnfsConversao, blcksock, TypInfo, ACBrDFeSSL, vcl.forms,
  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc;

type
  Tdm_nfse = class(TDataModule)
    NFSE: TACBrNFSe;
    DANFE: TACBrNFSeDANFSeFR;
    XMLDocument1: TXMLDocument;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    function  emitente_preeche:Boolean;
    function  tomador_preeche:boolean;
    function  configuracoes_preeche:Boolean;
    function  servicos_preeche:boolean;
    function  gerar_NFSE: Boolean;
    function  consulta_nota: boolean;
    procedure cancela_nfse;
    procedure gerar_arquivos;
    procedure retorno_servidor;
    procedure consulta_xml;
    procedure retorno_xml;
  end;

var
  dm_nfse: Tdm_nfse;
  comeca_servico: string;
  resultado: Boolean;

implementation

uses
  preeche_ini;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ Tdm_nfse }

 {CANCELA NOTA FISCAL}
 procedure Tdm_nfse.cancela_nfse;
begin
  try
       NFSe.NotasFiscais.LoadFromFile(configuracao.caminho_nota_cancelamento);
    if NFSe.CancelarNFSe('1', '', 'cancelamento NFS-e') = True  then
        begin
          dados_retorno.Aprovado    := 'S';
          dados_retorno.nota_envida := 'S';
          dados_retorno.Descricao   := 'Nota cancelada com sucesso..';
          preeche_ini.retornar_ini;
          Application.Terminate;
        end;
   except
    on E: Exception do
    begin
     dados_retorno.Aprovado  := 'N';
     dados_retorno.Descricao := 'Erro ao cancelar Nota fiscal.. '+e.Message;
     preeche_ini.retornar_ini;
     Application.Terminate;
    end;
  end;
end;

 {PREECHE CONFIGURAÇÕES}
 function Tdm_nfse.configuracoes_preeche:boolean;
var
  PathMensal: string;
begin
   result := True;
  try
    DANFE.FastFile := configuracao.arquivo_rf3;
    with NFSE.Configuracoes.Geral do
    begin
      SSLLib := libCapicom;
      SSLCryptLib := cryCapicom;
      SSLHttpLib := httpIndy;
      SSLXmlSignLib := xsMsXmlCapicom;
    end;

    if configuracao.tipo_ambiente = 'H' then
    begin
      NFSE.Configuracoes.WebServices.Ambiente := tahomologacao;
    end
    else
    begin
      NFSE.Configuracoes.WebServices.Ambiente := taProducao;
    end;

    NFSE.Configuracoes.Certificados.ArquivoPFX      := configuracao.arquivo_pfx;
    NFSE.Configuracoes.Certificados.Senha           := configuracao.senha_certificado;
    NFSE.Configuracoes.Certificados.NumeroSerie     := configuracao.serie_certificado;
    NFSE.Configuracoes.WebServices.Visualizar       := False;

    NFSE.Configuracoes.Arquivos.AdicionarLiteral    := True;
    NFSE.Configuracoes.Arquivos.EmissaoPathNFSe     := True;
    NFSE.Configuracoes.Arquivos.SepararPorMes       := True;
    NFSE.Configuracoes.Arquivos.SepararPorCNPJ      := False;
    NFSE.Configuracoes.Arquivos.PathGer             := configuracao.path_arquivos_retorno;
    NFSE.Configuracoes.Arquivos.PathSchemas         := configuracao.path_schemas;

    PathMensal := NFSE.Configuracoes.Arquivos.GetPathGer(0);
    NFSE.Configuracoes.Arquivos.PathCan              := PathMensal;
    NFSE.Configuracoes.Arquivos.PathSalvar           := PathMensal;
    NFSE.Configuracoes.Arquivos.Salvar               := True;

    NFSE.Configuracoes.Geral.Salvar                  := true;
    NFSE.Configuracoes.Geral.PathIniCidades          := configuracao.path_ini_cidades;
    NFSE.Configuracoes.Geral.PathIniProvedor         := configuracao.path_ini_provedor;
    NFSE.Configuracoes.Geral.SenhaWeb                := configuracao.senha_web;
    NFSE.Configuracoes.Geral.UserWeb                 := configuracao.login_web;
    NFSE.Configuracoes.WebServices.TimeOut           := StrToInt(configuracao.timeout);
    NFSE.Configuracoes.Geral.CodigoMunicipio         := StrToInt(dado_emitente.COD_CIDADE);
    NFSE.Configuracoes.Geral.Emitente.WebChaveAcesso := 'A001.B0001.C0001-1';

    NFSE.Configuracoes.Geral.Emitente.CNPJ      := dado_emitente.CNPJ;
    NFSE.Configuracoes.Geral.Emitente.InscMun   := dado_emitente.IM;
    NFSE.Configuracoes.Geral.Emitente.RazSocial := dado_emitente.RAZAO;
    NFSE.Configuracoes.WebServices.UF           := dado_emitente.UF;

    with NFSE.Configuracoes.Geral.Emitente.DadosSenhaParams.Add do
    begin
      Param := 'ChaveAutorizacao';
      Conteudo := 'A001.B0001.C0001-1';
    end;
    NFSE.Configuracoes.Geral.SetConfigMunicipio;
    NFSE.Configuracoes.Geral.Salvar := true;
  except
    on E: Exception do
    begin
      dados_retorno.Aprovado := 'N';
      dados_retorno.Descricao := 'Erro ao inserir as configurações...' + e.Message;
      preeche_ini.retornar_ini;
      result := false;
    end;
  end;
end;

 {CONSULTA NOTA FISCAL}
 function Tdm_nfse.consulta_nota: boolean;
  var
   i:Integer;
begin
  try
    if NFSE.ConsultarSituacao(dados_retorno.protocolo, dado_nfse.numero_lote) = false then
    begin
      retorno_servidor;
      Application.Terminate;
    end
    else
    begin
      try
        if NFSe.ConsultarNFSe(now, now, dado_nfse.numero_nota) = True then
        begin
          Result                  := true;
          dados_retorno.Aprovado  := 'S';
          dados_retorno.Descricao := 'Nota aprovada com sucesso..';
          retorno_servidor;
          preeche_ini.retornar_ini;
        end
        else

        begin
          result := false;
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'Nota Fiscal: ' + dado_nfse.numero_nota + ' não encontrada..';
          preeche_ini.retornar_ini;

          try
            if NFSE.ConsultarSituacao(dados_retorno.protocolo, dado_nfse.numero_lote) = false then
            begin
              retorno_servidor;
              Application.Terminate;
            end;
          except
          end;
        end;
      except
        on E: Exception do
        begin
          dados_retorno.Aprovado := 'N';
          retorno_servidor;
          result := false;
        end;
      end;

    end;
  except
    on E: Exception do
    begin
      dados_retorno.Aprovado := 'N';
      retorno_servidor;
      result := false;
      Application.Terminate;
    end;
  end;
end;

 {CONSULTA ML}
 procedure Tdm_nfse.consulta_xml;
  var
   i:Integer;
begin
  dados_retorno.protocolo :=  configuracao.protocolo_consulta;

  try
    if NFSE.ConsultarSituacao(dados_retorno.protocolo, dado_nfse.numero_lote) = false then
    begin
      retorno_xml;
      Application.Terminate;
    end
    else
    begin
      try
        if NFSe.ConsultarNFSe(now, now, dado_nfse.numero_nota) = True then
        begin
          dados_retorno.Aprovado  := 'S';
          dados_retorno.Descricao := 'Nota aprovada com sucesso..';
          retorno_xml;
          preeche_ini.retornar_ini;
        end
        else

        begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'Nota Fiscal: ' + dado_nfse.numero_nota + ' não encontrada..';
          preeche_ini.retornar_ini;

          try
            if NFSE.ConsultarSituacao(dados_retorno.protocolo, dado_nfse.numero_lote) = false then
            begin
              retorno_xml;
              Application.Terminate;
            end;
          except
          end;
        end;
      except
        on E: Exception do
        begin
          dados_retorno.Aprovado := 'N';
          retorno_xml;
        end;
      end;

    end;
  except
    on E: Exception do
    begin
      dados_retorno.Aprovado := 'N';
      retorno_xml;
      Application.Terminate;
    end;
  end;
end;

procedure Tdm_nfse.DataModuleCreate(Sender: TObject);
begin

end;

 {PREECHE EMITENTE}
 function Tdm_nfse.emitente_preeche:boolean;
begin
  Result := True;
  try
    NFSE.NotasFiscais[0].NFSe.Prestador.Cnpj := dado_emitente.CNPJ;
    NFSE.NotasFiscais[0].NFSe.Prestador.InscricaoMunicipal := dado_emitente.IM;
    NFSE.NotasFiscais[0].NFSe.PrestadorServico.Endereco.CodigoMunicipio := dado_emitente.COD_CIDADE;
    NFSE.NotasFiscais[0].NFSe.PrestadorServico.RazaoSocial := dado_emitente.RAZAO;
    NFSE.NotasFiscais[0].NFSe.PrestadorServico.Endereco.Endereco := dado_emitente.RUA;
    NFSE.NotasFiscais[0].NFSe.PrestadorServico.Endereco.Numero := dado_emitente.NUMERO;
    NFSE.NotasFiscais[0].NFSe.PrestadorServico.Endereco.Complemento := dado_emitente.COMPLEMENTO;
    NFSE.NotasFiscais[0].NFSe.PrestadorServico.Endereco.Bairro := dado_emitente.BAIRRO;
    NFSE.NotasFiscais[0].NFSe.PrestadorServico.Endereco.UF := dado_emitente.UF;
    NFSE.NotasFiscais[0].NFSe.PrestadorServico.Endereco.CEP := dado_emitente.CEP;
    NFSE.NotasFiscais[0].NFSe.PrestadorServico.Endereco.xMunicipio := dado_emitente.CIDADE;
    NFSE.NotasFiscais[0].NFSe.PrestadorServico.Endereco.CodigoPais := 1058;
  except
    on E: Exception do
    begin
      dados_retorno.Aprovado  := 'N';
      dados_retorno.Descricao := 'Erro ao inserir o emitente...' + e.Message;
      preeche_ini.retornar_ini;
      result := false;
    end;
  end;
end;

 {GERAR PDF E XML}
 procedure Tdm_nfse.gerar_arquivos;
  VAR
   xml :TStringList;
 begin
    xml := TStringList.Create;

  //GERAR PDF//
   DANFE.FastFile              := configuracao.arquivo_rf3;
   DANFE.RazaoSocial           := dado_emitente.RAZAO;
   DANFE.Endereco              := dado_emitente.RUA;
   DANFE.Complemento           := dado_emitente.COMPLEMENTO;
   DANFE.OutrasInformacaoesImp := servicos.info_adcionais;
   DANFE.UF                    := dado_emitente.UF;
   DANFE.Municipio             := dado_emitente.CIDADE;
   DANFE.InscMunicipal         := dado_emitente.IM;
   DANFE.Provedor              := proInfisc;

   if configuracao.caminho_logo_danfe <> '' then
      begin
       DANFE.Logo := configuracao.caminho_logo_danfe;
      end;

     NFSE.DANFSE.MostraPreview := false;
     NFSE.DANFSE.MostraStatus  := false;
     NFSE.DANFSE.PathPDF       := configuracao.PDF;
     DANFE.ImprimirDANFSePDF;

     try
     // XML//
      xml.Add(NFSE.WebServices.ConsNfse.RetWS);
      xml.SaveToFile(configuracao.XML+'/'+dado_nfse.numero_nota+'.xml');
     except
      dados_retorno.Descricao      := 'pasta para gerar o xml da aproação não encontrada...';
      preeche_ini.retornar_ini;
     end;
 end;

 {GERAR NF-SE}
 function Tdm_nfse.gerar_NFSE: Boolean;
begin
  try
       NFSE.GerarLote(dado_nfse.numero_lote);
   if  NFSE.Enviar(dado_nfse.numero_lote,true)= True then
       begin
        dados_retorno.Aprovado     := 'N';
        dados_retorno.nota_envida  := 'S';
        dados_retorno.protocolo    := NFSE.NotasFiscais[0].NFSe.Protocolo;
        Result                     := true;
       end;

   except
    on E: Exception do
    begin
      dados_retorno.protocolo      := NFSE.NotasFiscais[0].NFSe.Protocolo;
      dados_retorno.nota_envida    := 'N';
      dados_retorno.Aprovado       := 'N';
      dados_retorno.Descricao      := 'Erro ao enviar nota fiscal...' + e.Message;
      preeche_ini.retornar_ini;
      result                       := false;
      Application.Terminate;
    end;
  end;
end;

 {RETORNO}
 procedure Tdm_nfse.retorno_servidor;
 var
  i             : Integer;
  erro          : TStringList;
  chave_node    : IXMLNode;
  motivo        : IDOMNodeList;
  local_xml_sit : string;
  resultadp     : string;

 begin
     Sleep(5000);
     local_xml_sit := configuracao.path_arquivos_retorno+'\'+FormatDateTime('yyyymm',now)+'\NFSe\'+dados_retorno.protocolo+'-sit.xml';

   if FileExists(local_xml_sit) then
      begin
       erro                    := TStringList.Create;
       XMLDocument1.LoadFromFile(local_xml_sit);
       XMLDocument1.Active     := True;
       chave_node              := XMLDocument1.DocumentElement.ChildNodes.FindNode('NFSe');
       motivo                  := XMLDocument1.DOMDocument.getElementsByTagName('mot');
       dados_retorno.Chave_NF  := chave_node.ChildNodes['chvAcessoNFSe'].Text;
       dados_retorno.Aprovado  := chave_node.ChildNodes['sit'].Text;

       for I := 0 to motivo.length  - 1  do
            begin
             erro.Add(motivo.item[i].childNodes[0].nodeValue);
            end;
         dados_retorno.Descricao  := StringReplace(erro.Text, #13#10, '│', [rfReplaceAll])
      end else
           begin
             dados_retorno.Descricao := 'não foi possivel encontrar o XML do lote de retorno '+local_xml_sit;
           end;

    if dados_retorno.Aprovado   =  '100'  then
       begin
        NFSe.ConsultarNFSe(now, now, dado_nfse.numero_nota);
        gerar_arquivos;
        dados_retorno.Aprovado  := 'S';
        preeche_ini.retornar_ini;
       end
    else
       begin
         dados_retorno.Aprovado := 'N';
       end;

   preeche_ini.retornar_ini;
   Application.Terminate;
 end;

procedure Tdm_nfse.retorno_xml;
 var
  i             : Integer;
  erro          : TStringList;
  chave_node    : IXMLNode;
  motivo        : IDOMNodeList;
  local_xml_sit : string;
  resultadp     : string;

 begin
     Sleep(5000);
     local_xml_sit := configuracao.path_arquivos_retorno+'\'+FormatDateTime('yyyymm',now)+'\NFSe\'+dados_retorno.protocolo+'-sit.xml';

   if FileExists(local_xml_sit) then
      begin
        try
         erro                    := TStringList.Create;
         XMLDocument1.LoadFromFile(local_xml_sit);
         XMLDocument1.Active     := True;
         chave_node              := XMLDocument1.DocumentElement.ChildNodes.FindNode('NFSe');
         motivo                  := XMLDocument1.DOMDocument.getElementsByTagName('mot');
         dados_retorno.Chave_NF  := chave_node.ChildNodes['chvAcessoNFSe'].Text;
         dados_retorno.Aprovado  := chave_node.ChildNodes['sit'].Text;


         for I := 0 to motivo.length  - 1  do
           begin
            erro.Add(motivo.item[i].childNodes[0].nodeValue);
            end;
        dados_retorno.Descricao  := StringReplace(erro.Text, #13#10, '│', [rfReplaceAll])
         except
             dados_retorno.nota_envida := 'N';
             dados_retorno.Descricao   := 'NFS-e não encontrada';
             dados_retorno.Aprovado    := 'N';
             preeche_ini.retornar_ini;
       end;

         if (dados_retorno.Aprovado='100') or (dados_retorno.Aprovado ='200') and (dados_retorno.Chave_NF <> '')  then
            begin
             NFSe.ConsultarNFSe(StrToDate('01/01/2001')  ,StrToDate('01/01/2030'), dado_nfse.numero_nota);
             gerar_arquivos;
             dados_retorno.nota_envida := 'S';
             dados_retorno.Descricao   := 'NFS-e encontrada com sucesso';
             dados_retorno.Aprovado    := 'S';
             preeche_ini.retornar_ini;
            end
         else
           begin
            dados_retorno.nota_envida := 'N';
            dados_retorno.Aprovado    := 'N';
            dados_retorno.Descricao   := 'NFS-e não encontrada..';
           end;
      end;
 end;

{PREECHE SERVIÇOS}
 function Tdm_nfse.servicos_preeche : Boolean;
begin
  Result := True;
  with NFSE do
  begin
    NotasFiscais.Transacao := True;
    with NotasFiscais.Add.NFSe do
    begin
      try
        Numero                   := dado_nfse.numero_nota;
        NumeroLote               := dado_nfse.numero_lote;
        SeriePrestacao           := configuracao.serie_nfse;
        IdentificacaoRps.Serie   := 'NF';

        IdentificacaoRps.Tipo    := trRPS;
        ValoresNfse.Aliquota     := StrToFloat(Servicos.valor_iss);
        DataEmissao              := Now;
        DataEmissaoRPS           := Now;
        RegimeEspecialTributacao := retNenhum;
        OptanteSimplesNacional   := snsim;
        IncentivadorCultural     := snNao;
        Producao := snsim;
        Status                   := srNormal;
        OutrasInformacoes        := servicos.info_adcionais;
        RpsSubstituido.Tipo      := trRPS;
        Servico.Valores.ValorServicos := StrTofloat(servicos.valor);
        Servico.Valores.ValorInss := 0.00;
        Servico.Valores.IssRetido := stNormal;
        Servico.Valores.ValorIssRetido := StrToCurr(servicos.iss_retido);
        Servico.Valores.Aliquota := StrToCurr(servicos.aliquota);
        Servico.Valores.ValorDeducoes := 0.00;
        Servico.Valores.ValorPis    := StrToCurr(servicos.aliquota_pis);
        Servico.Valores.ValorCofins := StrToCurr(servicos.aliquota_confis);
        Servico.Valores.ValorIr     := 0.00;
        Servico.Valores.ValorCsll   := 0.00;

        Servico.Valores.OutrasRetencoes := 0.00;
        Servico.Valores.DescontoIncondicionado := 0.00;
        Servico.Valores.DescontoCondicionado := 0.00;

        Servico.Valores.BaseCalculo := Servico.Valores.ValorServicos - Servico.Valores.ValorDeducoes - Servico.Valores.DescontoIncondicionado;
        Servico.Valores.ValorLiquidoNfse := Servico.Valores.ValorServicos - Servico.Valores.ValorPis - Servico.Valores.ValorCofins - Servico.Valores.ValorInss - Servico.Valores.ValorIr - Servico.Valores.ValorCsll - Servico.Valores.OutrasRetencoes - Servico.Valores.ValorIssRetido - Servico.Valores.DescontoIncondicionado - Servico.Valores.DescontoCondicionado;

        Servico.ResponsavelRetencao := ptTomador;
        Servico.CodigoTributacaoMunicipio := servicos.codigo_tributacao;

        Servico.Discriminacao := servicos.descricao;
        Servico.MunicipioIncidencia := StrToInt(dado_emitente.COD_CIDADE);
        Servico.CodigoMunicipio := dado_emitente.COD_CIDADE;

        Servico.ExigibilidadeISS := exiExigivel;

        with Servico.ItemServico.Add do
        begin
          Descricao     :=  servicos.descricao;
          Quantidade    :=  1;
          ValorUnitario :=  StrTofloat(servicos.valor);
          ValorServicos :=  StrTofloat(servicos.valor);

          Unidade       :=  'UN';
          Tributavel    :=  snSim;
          CodServ       :=  servicos.codigo_tributacao;
        end;

       except
         on E: Exception do
           begin
             dados_retorno.Aprovado  :='N';
             dados_retorno.Descricao := 'Erro ao inserir o serviço...'+e.Message;
             preeche_ini.retornar_ini;
             result                  := false;
           end;
      end;
    end;
  end;
end;

 {PREECHE TOMADOR DE SERVIÇOS}
 function Tdm_nfse.tomador_preeche:boolean;
begin
  result := True;
  try
    NFSE.NotasFiscais[0].NFSe.Tomador.IdentificacaoTomador.CpfCnpj := dado_clientes.CNPJ;
    NFSE.NotasFiscais[0].NFSe.Tomador.RazaoSocial := dado_clientes.RAZAO;
    NFSE.NotasFiscais[0].NFSe.Tomador.Endereco.Endereco := dado_clientes.RUA;
    NFSE.NotasFiscais[0].NFSe.Tomador.Endereco.Numero := dado_clientes.NUMERO;
    NFSE.NotasFiscais[0].NFSe.Tomador.Endereco.Complemento := dado_clientes.COMPLEMENTO;
    NFSE.NotasFiscais[0].NFSe.Tomador.Endereco.Bairro := dado_clientes.BAIRRO;
    NFSE.NotasFiscais[0].NFSe.Tomador.Endereco.CodigoMunicipio := dado_clientes.COD_CIDADE;
    NFSE.NotasFiscais[0].NFSe.Tomador.Endereco.UF := dado_clientes.UF;
    NFSE.NotasFiscais[0].NFSe.Tomador.Endereco.CodigoPais := 1058;
    NFSE.NotasFiscais[0].NFSe.Tomador.Endereco.CEP := dado_clientes.CEP;
    NFSE.NotasFiscais[0].NFSe.Tomador.Endereco.xPais := 'BRASIL';
    NFSE.NotasFiscais[0].NFSe.Tomador.IdentificacaoTomador.InscricaoMunicipal := dado_clientes.IM;
  except
    on E: Exception do
    begin
      dados_retorno.Aprovado    := 'N';
      dados_retorno.Descricao   := 'Erro ao inserir o cliente...' + e.Message;
      preeche_ini.retornar_ini;
      result := false;
    end;
  end;
end;

end.


