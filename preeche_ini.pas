unit preeche_ini;

 interface


 uses system.classes,inifiles;

 function  busca_ini_dados_nfse:Boolean;
 function  busca_ini_config_nfse:Boolean;
 procedure retornar_ini;



type

  dados_clientes = record
    CNPJ,
    IM,
    RAZAO,
    FANTASIA,
    FONE,
    CEP,
    RUA,
    COMPLEMENTO,
    BAIRRO,
    COD_CIDADE,
    CIDADE,
    UF,
    NUMERO,
    IE:string;
  end;

  dados_nfse = record
    numero_lote,
    numero_nota:string;
  end;

  dados_emitente = record
   CNPJ,
   IM,
   RAZAO,
   FANTASIA,
   FONE,
   CEP,
   RUA,
   COMPLEMENTO,
   BAIRRO,
   COD_CIDADE,
   CIDADE,
   UF,
   NUMERO,
   IE,
   CODIGO_UF:string;
  end;

  servico = record
    descricao,
    valor,
    codigo_tributacao,
    valor_iss,
    iss_retido,
    aliquota,
    valor_bc,
    aliquota_pis,
    aliquota_confis,
    info_adcionais:string;
  end;

  configuracoes = record
  arquivo_pfx,
  senha_certificado,
  serie_certificado,
  arquivo_rf3,
  path_ini_cidades,
  path_ini_provedor,
  path_schemas,
  path_arquivos_retorno,
  caminho_nota_cancelamento,
  timeout,
  serie_nfse,
  operacao,
  senha_web,
  login_web,
  tipo_ambiente,
  XML,
  caminho_logo_danfe,
  protocolo_consulta,
  PDF:string;
  end;

  retorno = record
   Aprovado,
   Numero_NF,
   Chave_NF,
   nota_envida,
   protocolo,
   Descricao:string;
  end;


  var
   dado_clientes  : dados_clientes;
   dado_nfse      : dados_nfse;
   dado_emitente  : dados_emitente;
   servicos       : servico;
   configuracao   : configuracoes;
   dados_retorno  : retorno;


 implementation

   {busca ini }
  function busca_ini_dados_nfse:Boolean;
   var
    dados_nfse : TIniFile;

   begin
    Result     := True;

    dados_nfse := TIniFile.Create('./dados_nfse.ini');
     try
      dado_clientes.CNPJ          := dados_nfse.ReadString('dados_cliente','CNPJ','');
      dado_clientes.IM            := dados_nfse.ReadString('dados_cliente','IM','');
      dado_clientes.RAZAO         := dados_nfse.ReadString('dados_cliente','RAZAO','');
      dado_clientes.FANTASIA      := dados_nfse.ReadString('dados_cliente','FANTASIA','');
      dado_clientes.FONE          := dados_nfse.ReadString('dados_cliente','FONE','');
      dado_clientes.CEP           := dados_nfse.ReadString('dados_cliente','CEP','');
      dado_clientes.RUA           := dados_nfse.ReadString('dados_cliente','RUA','');
      dado_clientes.COMPLEMENTO   := dados_nfse.ReadString('dados_cliente','COMPLEMENTO','');
      dado_clientes.BAIRRO        := dados_nfse.ReadString('dados_cliente','BAIRRO','');
      dado_clientes.COD_CIDADE    := dados_nfse.ReadString('dados_cliente','COD_CIDADE','');
      dado_clientes.CIDADE        := dados_nfse.ReadString('dados_cliente','CIDADE','');
      dado_clientes.UF            := dados_nfse.ReadString('dados_cliente','UF','');
      dado_clientes.NUMERO        := dados_nfse.ReadString('dados_cliente','NUMERO','');
      dado_clientes.IE            := dados_nfse.ReadString('dados_cliente','IE','');

      dado_emitente.CNPJ          := dados_nfse.ReadString('dados_emitente','CNPJ','');
      dado_emitente.IM            := dados_nfse.ReadString('dados_emitente','IM','');
      dado_emitente.RAZAO         := dados_nfse.ReadString('dados_emitente','RAZAO','');
      dado_emitente.FANTASIA      := dados_nfse.ReadString('dados_emitente','FANTASIA','');
      dado_emitente.FONE          := dados_nfse.ReadString('dados_emitente','FONE','');
      dado_emitente.CEP           := dados_nfse.ReadString('dados_emitente','CEP','');
      dado_emitente.RUA           := dados_nfse.ReadString('dados_emitente','RUA','');
      dado_emitente.COMPLEMENTO   := dados_nfse.ReadString('dados_emitente','COMPLEMENTO','');
      dado_emitente.BAIRRO        := dados_nfse.ReadString('dados_emitente','BAIRRO','');
      dado_emitente.COD_CIDADE    := dados_nfse.ReadString('dados_emitente','COD_CIDADE','');
      dado_emitente.CIDADE        := dados_nfse.ReadString('dados_emitente','CIDADE','');
      dado_emitente.UF            := dados_nfse.ReadString('dados_emitente','UF','');
      dado_emitente.NUMERO        := dados_nfse.ReadString('dados_emitente','NUMERO','');
      dado_emitente.IE            := dados_nfse.ReadString('dados_emitente','IE','');

      servicos.descricao          := dados_nfse.ReadString('servico','descricao','');
      servicos.valor              := dados_nfse.ReadString('servico','valor','');
      servicos.codigo_tributacao  := dados_nfse.ReadString('servico','codigo_tributacao','');
      servicos.valor_iss          := dados_nfse.ReadString('servico','valor_iss','');
      servicos.iss_retido         := dados_nfse.ReadString('servico','iss_retido','');
      servicos.aliquota           := dados_nfse.ReadString('servico','aliquota','');
      servicos.valor_bc           := dados_nfse.ReadString('servico','valor_bc','');
      servicos.aliquota_pis       := dados_nfse.ReadString('servico','aliquota_pis','');
      servicos.aliquota_confis    := dados_nfse.ReadString('servico','aliquota_confis','');
      servicos.info_adcionais     := dados_nfse.ReadString('servico','info_adcionais','');

      dado_nfse.numero_lote       := dados_nfse.ReadString('dados_nfse','numero_lote','');
      dado_nfse.numero_nota       := dados_nfse.ReadString('dados_nfse','numero_nota','');



     if dado_nfse.numero_lote = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'numero do lote vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;

     if dado_nfse.numero_nota= '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'numero da nota vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;         end;


     if servicos.descricao = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'descriçãodo serviço vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;

     if servicos.valor ='' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'valor do serviço vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;

     if servicos.codigo_tributacao = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'cód de tributação vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;

     if servicos.valor_iss = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'valor do ISS vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;

     if servicos.iss_retido = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'ISS retido vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;

      if servicos.aliquota = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'aliquota vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;

     if servicos.valor_bc = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'BC calculo vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;

     if servicos.aliquota_pis = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'aliquota PIS vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;

     if servicos.aliquota_confis = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'aliquota CONFIS vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;


     if dado_emitente.CNPJ = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'CNPJ vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;
     if dado_emitente.IM = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'IM vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;
     if dado_emitente.RAZAO = '' then
        begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'RAZAO vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
        end;

     if dado_emitente.FANTASIA ='' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'FANTASIA vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     if dado_emitente.FONE  = '' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'FONE vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;
     if dado_emitente.CEP = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'CEP vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;

     if dado_emitente.RUA = '' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'RUA vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;
     if dado_emitente.COMPLEMENTO = '' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'COMPLEMENTO vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     if dado_emitente.BAIRRO ='' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'BAIRRO vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     if dado_emitente.COD_CIDADE ='' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'COD CIDADE vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     if dado_emitente.CIDADE ='' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'CIDADE vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     if dado_emitente.UF= '' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'UF do lote vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     if dado_emitente.NUMERO = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'numero  vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     if dado_clientes.CNPJ = '' then
         begin
           dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'CNPJ vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;
     if dado_clientes.IM = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'IM vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;
     if dado_clientes.RAZAO = '' then
        begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'RAZAO vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
        end;

     if dado_clientes.FANTASIA ='' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'FANTASIA vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     if dado_clientes.FONE  = '' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'FONE vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;
     if dado_clientes.CEP = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'CEP vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     if dado_clientes.RUA = '' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'RUA vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;
     if dado_clientes.COMPLEMENTO = '' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'COMPLEMENTO vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     if dado_clientes.BAIRRO ='' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'BAIRRO vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     if dado_clientes.COD_CIDADE ='' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'COD CIDADE vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
         end;

     if dado_clientes.CIDADE ='' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'CIDADE vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     if dado_clientes.UF= '' then
          begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'UF vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     if dado_clientes.NUMERO = '' then
         begin
          dados_retorno.Aprovado  := 'N';
          dados_retorno.Descricao := 'numero vazio em dados_nfse';
          retornar_ini;
          Result := False;
          Exit;
          end;

     finally

     end;
   end;

  function busca_ini_config_nfse:Boolean;
   var
    config : TIniFile;
   begin
     config := TIniFile.Create('./config_nfse.ini');
     try
      Result                                  := True;
      configuracao.arquivo_pfx                := config.ReadString('configuracoes','arquivo_pfx','');
      configuracao.senha_certificado          := config.ReadString('configuracoes','senha_certificado','');
      configuracao.serie_certificado          := config.ReadString('configuracoes','serie_certificado','');
      configuracao.arquivo_rf3                := config.ReadString('configuracoes','arquivo_rf3','');
      configuracao.path_ini_cidades           := config.ReadString('configuracoes','path_ini_cidades','');
      configuracao.path_ini_provedor          := config.ReadString('configuracoes','path_ini_provedor','');
      configuracao.path_schemas               := config.ReadString('configuracoes','path_schemas','');
      configuracao.path_arquivos_retorno      := config.ReadString('configuracoes','path_arquivos_retorno','');
      configuracao.caminho_nota_cancelamento  := config.ReadString('configuracoes','caminho_nota_cancelamento','');
      configuracao.timeout                    := config.ReadString('configuracoes','timeout','');
      configuracao.serie_nfse                 := config.ReadString('configuracoes','serie_nfse','');
      configuracao.operacao                   := config.ReadString('configuracoes','operacao','');
      configuracao.senha_web                  := config.ReadString('configuracoes','senha_web','');
      configuracao.login_web                  := config.ReadString('configuracoes','login_web','');
      configuracao.tipo_ambiente              := config.ReadString('configuracoes','tipo_ambiente','');
      configuracao.XML                        := config.ReadString('configuracoes','XML','');
      configuracao.PDF                        := config.ReadString('configuracoes','PDF','');
      configuracao.caminho_logo_danfe         := config.ReadString('configuracoes','caminho_logo_danfe','');
      configuracao.protocolo_consulta         := config.ReadString('configuracoes','protocolo_consulta','');
     finally

     end;
   end;

  {FAZ RETORNO INI}
  procedure retornar_ini;
   var
    parametros : TStringList;
   begin
     parametros := TStringList.Create;
    try
      parametros.Add('[Retorno]');
      parametros.Add('enviada='+dados_retorno.nota_envida);
      parametros.Add('Aprovado='+dados_retorno.Aprovado);
      parametros.Add('Numero_NF='+dado_nfse.numero_nota);
      parametros.Add('protocolo='+dados_retorno.protocolo);
      parametros.Add('Chave_NF='+dados_retorno.Chave_NF);
      parametros.Add('tipo_operacao='+configuracao.operacao);
      parametros.Add('Descricao='+dados_retorno.Descricao);
      parametros.SaveToFile('./retorno.ini');
    finally
     parametros.Free;
    end;
   end;






end.
