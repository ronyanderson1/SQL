SELECT
    --DIMENSOES
/*    LQ.LIQU_EMP_ID                                                AS D_EMPRESA,
    RPAD(EM.EMP_NOME,40)                                          AS D_DESCR_EMPRESA,
    SUBSTR(TO_CHAR(LQ.LIQU_DTA_EMIS,'YYYYMMDD'),1,4)              AS D_ANO,
    SUBSTR(TO_CHAR(LQ.LIQU_DTA_EMIS,'YYYYMMDD'),5,2)              AS D_MES,
    SUBSTR(TO_CHAR(LQ.LIQU_DTA_EMIS,'YYYYMMDD'),7,2)              AS D_DIA,
    TO_CHAR(LQ.LIQU_DTA_EMIS,'WW')                                AS D_SEMANA,*/
    (SELECT N.PEDF_NFE_DTA_CAD fROM PEDIDO_FAT_NFE N
            WHERE N.PEDF_PEDF_ID = PF.PEDF_ID
            AND N.PEDF_PEDF_EMP_ID = PF.PEDF_EMP_ID
            )                                                     AS D_DATA_MOV, --LEANDRO MOURAO DATA DA EMISSAO NF
/*    SUBSTR(TO_CHAR(LQ.LIQU_DTA_LIB,'YYYYMMDD'),1,4)               AS D_ANO_LIB, -- Ano Liberacao Liquidacao
    SUBSTR(TO_CHAR(LQ.LIQU_DTA_LIB,'YYYYMMDD'),5,2)               AS D_MES_LIB, -- Mes Liberacao Liquidacao
    SUBSTR(TO_CHAR(LQ.LIQU_DTA_LIB,'YYYYMMDD'),7,2)               AS D_DIA_LIB, -- Dia Liberacao Liquidacao
    TO_CHAR(LQ.LIQU_DTA_LIB,'WW')                                 AS D_SEMANA_LIB,-- Dia Semana Liberacao Liquidacao
    LQ.LIQU_DTA_LIB                                               AS D_DATA_LIB, -- Data Liberacao Liquidacao
    G2.GEN_ID                                                     AS D_COD_AREA,
    RPAD(G2.GEN_DESCRICAO,30)                                     AS D_AREA,
    G3.GEN_ID                                                     AS D_COD_DISTRITO,
    RPAD(G3.GEN_DESCRICAO,30)                                     AS D_DISTRITO,
    G4.GEN_ID                                                     AS D_COD_SETOR,
    RPAD(G4.GEN_DESCRICAO,30)                                     AS D_SETOR,
    G5.GEN_ID                                                     AS D_COD_ROTA,
    RPAD(G5.GEN_DESCRICAO,30)                                     AS D_ROTA,
    RPAD(G6.GEN_DESCRICAO,30)                                     AS D_CANAL,
    RPAD(G7.GEN_DESCRICAO,30)                                     AS D_RAMO,
    RPAD(G15.GEN_DESCRICAO,30)                                    AS D_PROMOTOR,
    RPAD(G8.GEN_DESCRICAO,30)                                     AS D_SEGMENTO,
    PF.PEDF_CLI_ID                                                AS D_COD_CLIENTE,
    RPAD(CL.CLI_FANTASIA,40)                                      AS D_FANTASIA,
    RPAD(CL.CLI_RAZAO_SOCIAL,40)                                  AS D_RAZAO_SOCIAL,
    RPAD(G9.GEN_DESCRICAO,30)                                     AS D_CLASSE,
    RPAD(G10.GEN_DESCRICAO,30)                                    AS D_CADEIA,
    RPAD(CE.CLIE_ENDERECO,50)                                     AS D_ENDERECO,
    RPAD(CE.CLIE_COMPLEMENTO,50)                                  AS D_COMPLEMENTO,
    RPAD(G11.GEN_DESCRICAO,30)                                    AS D_CIDADE,
    RPAD(G12.GEN_DESCRICAO,30)                                    AS D_UF,
    'BR'                                                          AS D_PAIS,
    RPAD(G13.GEN_DESCRICAO,30)                                    AS D_GEOPOLITICO,
    RPAD(G14.GEN_DESCRICAO,30)                                    AS D_ZONA,
    DECODE(DS.DIA_SEM,1,'DOM')                                    AS D_LIVRO_DOM,
    DECODE(DS.DIA_SEM,2,'SEG')                                    AS D_LIVRO_SEG,
    DECODE(DS.DIA_SEM,3,'TER')                                    AS D_LIVRO_TER,
    DECODE(DS.DIA_SEM,4,'QUA')                                    AS D_LIVRO_QUA,
    DECODE(DS.DIA_SEM,5,'QUI')                                    AS D_LIVRO_QUI,
    DECODE(DS.DIA_SEM,6,'SEX')                                    AS D_LIVRO_SEX,
    DECODE(DS.DIA_SEM,7,'SAB')                                    AS D_LIVRO_SAB,*/
    PR.PROD_ID                                                    AS D_COD_PRODUTO,/*
    RPAD(PR.PROD_DESC,40)                                         AS D_PRODUTO,
    FS.PROF_GEN_ID                                                AS D_NCM_PRODUTO,
    NVL(PP.MA_PEDF_PERC_COMIS_REPRE,0)                            AS D_IND_COMISS_REPRES,
    NVL(PP.MA_PEDF_PERC_COMIS_GERENCIA,0)                         AS D_IND_COMISS_GERENC,
    RPAD(G17.GEN_DESCRICAO,30)                                    AS D_GRUPO,
    RPAD(G16.GEN_DESCRICAO,30)                                    AS D_SUB_GRUPO,
    TO_CHAR(G18.GEN_ID,'000000')                                  AS D_COD_ORIGEM,
    RPAD(G18.GEN_DESCRICAO,30)                                    AS D_ORIGEM,
    TO_CHAR(G19.GEN_ID,'000000')                                  AS D_COD_MARCA,
    RPAD(G19.GEN_DESCRICAO,30)                                    AS D_MARCA,
    TO_CHAR(G21.GEN_ID,'000000')                                  AS D_COD_EMBALAGEM,
    RPAD(G21.GEN_DESCRICAO,30)                                    AS D_EMBALAGEM,
    TO_CHAR(G20.GEN_ID,'000000')                                  AS D_COD_SABOR,
    RPAD(G20.GEN_DESCRICAO,30)                                    AS D_SABOR,
   -- RPAD(PFOR.PROF_REF_FORNECEDOR,30)                             AS D_FORNECEDOR,
*/
   /* RPAD((SELECT DISTINCT --PFOR.PROF_PROD_EMP_ID,
               --   PFOR.PROF_PROD_ID,
                  NVL(PFOR.PROF_REF_FORNECEDOR,0)
           FROM
               PRODUTO_FOR PFOR
           WHERE NVL(PFOR.PROF_ALTERNATIVO,'N') = 'S'
             AND PFOR.PROF_PROD_EMP_ID (+) = PR.PROD_EMP_ID
             AND PFOR.PROF_PROD_ID     (+) = PR.PROD_ID
             AND ROWNUM = 1),30)                  AS D_FORNECEDOR,



    RPAD(FR.FRO_PLACA || FR.FRO_MODELO,30)                        AS D_FROTA,
    LQ.LIQU_PES_ID_MOTORISTA_DE                                   AS D_COD_MOTORISTA,
    RPAD(PE.PES_NOME,30)                                          AS D_MOTORISTA,
    TO_CHAR(DC.PRAZO_CLI,'000')                                   AS D_PRAZO,
    TO_CHAR(MAX(DC.PRAZO_CLI),'000')                              AS D_PRAZO_CLI,
    DC.COND_VCTO                                                  AS D_COND_VCTO,
    RPAD(MAX(DC.FORMA_CLI),30)                                    AS D_FORMA_PGTO_CLI,
    DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1,'VENDA','BONIFICACAO') AS D_OPERACAO,
    '.'                                                           AS D_MOT_RETORNO,
    PP.PEDF_TPRC_GEN_ID                                           AS D_TAB_PRECO,
    RPAD(G22.GEN_DESCRICAO,30)                                    AS D_DESC_TAB_PRECO,
*/    PF.PEDF_NR_NF                                                 AS D_NUMERO_NF,
--    PF.PEDF_FLAG_EMIS                                             AS D_TIPO,
--MEDIDAS       ,0))                                                     AS M_QTDE_VDA,
--VLR_VENDA_BRUTA
      DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1, round( SUM(PP.PEDF_VLR_UNIT * PP.PEDF_QTDE) + SUM(PP.PEDF_QTDE * NVL(PP.PEDF_ADC_FINANC,0))
--       SUM(ROUND(PP.PEDF_QTDE / DECODE(NVL(PROC_CONV_4,0),0,1,PROC_CONV_4) ) * NVL(PP.PEDF_ADC_FINANC,0))
       - SUM(NVL(((PP.PEDF_VLR_UNIT * PP.PEDF_QTDE) * PP.PEDF_PERC_DESC / 100),0)+ NVL(PP.PEDF_VALOR_DESCONTO,0)) + SUM(NVL(PP.PEDF_VALOR_FRETE,0)) +
       SUM(NVL(PP.PEDF_VALOR_SEGURO,0)) + SUM(NVL(PP.PEDF_VALOR_DESP,0)) + SUM(NVL(PP.PEDF_VLR_IPI,0)) + SUM(NVL(PP.PEDF_VLR_SUBS,0)) -
       SUM(NVL(PP.PEDF_VLR_ICMS_DES,0)) ,2),0)                    AS M_VLR_BRUTO_VDA_OLD,
       ---- SEM O SUM
       DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1,round(PP.PEDF_VLR_UNIT * PP.PEDF_QTDE + (PP.PEDF_QTDE * NVL(PP.PEDF_ADC_FINANC,0)) - (NVL(((PP.PEDF_VLR_UNIT * PP.PEDF_QTDE) 
       * PP.PEDF_PERC_DESC / 100),0) +NVL(PP.PEDF_VALOR_DESCONTO,0)) + (NVL(PP.PEDF_VALOR_FRETE,0)) 
       + NVL(PP.PEDF_VLR_IPI,0)+ NVL(PP.PEDF_VLR_SUBS,0)-(NVL(PP.PEDF_VLR_ICMS_DES,0)),2),0)       AS M_VLR_BRUTO_VDA,
       -- FINAL
       PP.PEDF_VLR_UNIT,
       PP.PEDF_QTDE,
       PP.PEDF_ADC_FINANC,
       PP.PEDF_PERC_DESC,
       PP.PEDF_VALOR_DESCONTO,
       PP.PEDF_VALOR_FRETE,
       PP.PEDF_VALOR_SEGURO,
       PP.PEDF_VALOR_DESP,
       PP.PEDF_VLR_IPI,
       PP.PEDF_VLR_SUBS,
       PP.PEDF_VLR_ICMS_DES
--VLR_VENDA_LIQUIDA
/*      DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1, round( SUM(PP.PEDF_VLR_UNIT * PP.PEDF_QTDE) +  SUM(PP.PEDF_QTDE * NVL(PP.PEDF_ADC_FINANC,0))
--       SUM(ROUND(PP.PEDF_QTDE / DECODE(NVL(PROC_CONV_4,0),0,1,PROC_CONV_4) ) * NVL(PP.PEDF_ADC_FINANC,0))
       - SUM(NVL(((PP.PEDF_VLR_UNIT * PP.PEDF_QTDE) * PP.PEDF_PERC_DESC / 100),0) + NVL(PP.PEDF_VALOR_DESCONTO,0)) +
       SUM(NVL(PP.PEDF_VALOR_FRETE,0)) + SUM(NVL(PP.PEDF_VALOR_SEGURO,0)) + SUM(NVL(PP.PEDF_VALOR_DESP,0)) + SUM(NVL(PP.PEDF_VLR_IPI,0))
       + SUM(NVL(PP.PEDF_VLR_SUBS,0))  - SUM(NVL(PP.PEDF_VLR_ICMS_DES,0))
       ---AILTON INCLUIU DESCONTO MARGEM ITENS
       - SUM(NVL(PP.MA_PEDF_VLR_TOT_DESC_BOLETO,0)) - SUM(NVL(PP.MA_PEDF_VLR_TOT_DESC_FINAN,0))
---AILTON INCLUIU DESCONTO MARGEM ITENS
       ,2),0)                                                     AS M_VLR_LIQ_VDA*/

--ACRESCIMO
/*    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1,
           NVL(PP.PEDF_VALOR_DESP,0),0))                          AS M_VLR_ACRES_VDA,
--DESCONTO BOLETO
    SUM(NVL(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1,
       NVL((PP.PEDF_VLR_TOT * NVL(PP.PEDF_PERC_DESC,0) / 100),0),0), 0))
     + /*RATEIO DO DESCONTO FINACEIRO DO BOLETO 
       ROUND(NVL((sum(DISTINCT NVL(PF.Pedf_Vlr_Desc_Boleto,0))* --VALOR DESCONTO BOLETO
                ((round( SUM(PP.PEDF_VLR_UNIT * PP.PEDF_QTDE)
                 +
     SUM(PP.PEDF_QTDE * NVL(PP.PEDF_ADC_FINANC,0))
       -
       SUM(NVL((     (PP.PEDF_VLR_UNIT * PP.PEDF_QTDE) * PP.PEDF_PERC_DESC / 100),0) + NVL(PP.PEDF_VALOR_DESCONTO,0))
       +
       SUM(NVL(PP.PEDF_VALOR_FRETE,0))
       +
       SUM(NVL(PP.PEDF_VALOR_SEGURO,0))
       +
       SUM(NVL(PP.PEDF_VALOR_DESP,0))
       +
       SUM(NVL(PP.PEDF_VLR_IPI,0))
       +
       SUM(NVL(PP.PEDF_VLR_SUBS,0))
     ,2) * 100) / sum(  DECODE(NVL(PF.Pedf_Vlr_Tot_Ped,0),0,1,PF.Pedf_Vlr_Tot_Ped)))) / 100,0),2)    AS M_VLR_DESC_BOL,
 --DESCONTO VENDA
    SUM(NVL(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1,NVL((PP.PEDF_VLR_TOT * NVL(PP.PEDF_PERC_DESC,0) / 100),0),0), 0))

     + /*RATEIO DO DESCONTO FINACEIRO DO BOLETO 
       ROUND(NVL((sum(DISTINCT NVL(PF.Pedf_Vlr_Desc,0))* --VALOR DESCONTO BOLETO
                ((round( SUM(PP.PEDF_VLR_UNIT * PP.PEDF_QTDE)
                 +
     SUM(PP.PEDF_QTDE * NVL(PP.PEDF_ADC_FINANC,0))
       -
       SUM(NVL((     (PP.PEDF_VLR_UNIT * PP.PEDF_QTDE) * PP.PEDF_PERC_DESC / 100),0) + NVL(PP.PEDF_VALOR_DESCONTO,0))
       +
       SUM(NVL(PP.PEDF_VALOR_FRETE,0))
       +
       SUM(NVL(PP.PEDF_VALOR_SEGURO,0))
       +
       SUM(NVL(PP.PEDF_VALOR_DESP,0))
       +
       SUM(NVL(PP.PEDF_VLR_IPI,0))
       +
       SUM(NVL(PP.PEDF_VLR_SUBS,0))
     ,2) * 100) / sum(  DECODE(NVL(PF.Pedf_Vlr_Tot_Ped,0),0,1,PF.Pedf_Vlr_Tot_Ped)))) / 100,0),2)    AS M_VLR_DESC_VDA,
    --DESCONTO SUFRAMA
       SUM(NVL(PP.PEDF_VLR_ICMS_DES,0))              AS M_VLR_DESC_SUFRAMA,

    --- INICIO CALCULO DE FRETE PREVISTO
    ROUND(
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1
       ,DECODE(OP.OPER_ESTATISTICA,'-',0,DECODE(PC.PROC_ESTATISTICA_QTDE,'S',0,PF.PROF_PESO_B))
       ,0)) *
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1
       ,DECODE(OP.OPER_ESTATISTICA,'-',0,DECODE(PC.PROC_ESTATISTICA_QTDE,'S',0,PP.PEDF_QTDE))
       ,0)) *
    SUM(NVL(G14.GEN_NUMBER5,0))
    ,2)                                                                                               AS M_VLR_FRT_PRE_VDA,
    --- FIM CALCULO DE FRETE PREVISTO
    -- DE VENDA
    ROUND(SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1,
                     DECODE(NVL(OP.OPER_ESTATISTICA,'S'),'S',NVL(FRT_PG.VLR_FRT_PG,0),0),0
                     )
              ),2)                                                                                    AS M_VLR_FRETE_VDA,
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1,NVL(PP.PEDF_VLR_IPI,0),0))                             AS M_VLR_IPI_VDA,
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1,NVL(PP.PEDF_VLR_ICMS,0),0))                            AS M_VLR_ICMS_VDA,
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1,NVL(PP.PEDF_VLR_SUBS,0),0))                            AS M_VLR_SUBST_VDA,
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1,NVL(PP.PEDF_BASE_SUBS,0),0))                           AS M_BASE_SUBST_VDA,
    --Bonificacoes
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,2
       ,DECODE(OP.OPER_ESTATISTICA,'-',0,DECODE(PC.PROC_ESTATISTICA_QTDE,'S',0,PP.PEDF_QTDE))
       ,0))                                                       AS M_QTDE_BONIF,
     SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,2,
         NVL(PP.PEDF_VLR_TOT,0)
         +
         (ROUND(PP.PEDF_QTDE) * NVL(PP.PEDF_ADC_FINANC,0))
         -
         ((NVL(PP.PEDF_VLR_TOT,0) * NVL(PP.PEDF_PERC_DESC,0) / 100) + NVL(PP.PEDF_VALOR_DESCONTO,0) + NVL(PP.PEDF_VLR_DESC_ESP_DUPL,0))
         +
         NVL(PP.PEDF_VALOR_FRETE,0)
         +
         NVL(PP.PEDF_VALOR_SEGURO,0)
         +
         NVL(PP.PEDF_VALOR_DESP,0)
         +
         NVL(PP.PEDF_VLR_IPI,0)
         +
         NVL(PP.PEDF_VLR_SUBS,0)
       ,0))
        -
        DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,2,
           ROUND(NVL((sum(NVL(PF.Pedf_Vlr_Desc_Boleto,0))* --VALOR DESCONTO BOLETO
            ((SUM(   PP.PEDF_VLR_TOT -
                     NVL((PP.PEDF_VLR_TOT * NVL(PP.PEDF_PERC_DESC,0) / 100),0) + NVL(PP.PEDF_VALOR_DESCONTO,0) +
                     ROUND(PP.PEDF_QTDE / DECODE(NVL(PROC_CONV_4,0),0,1,PROC_CONV_4) ) * NVL(PP.PEDF_ADC_FINANC,0)+
                     NVL(PP.PEDF_VLR_IPI,0)+
                     NVL(PP.PEDF_VALOR_FRETE,0)+
                     NVL(PP.PEDF_VALOR_SEGURO,0)+
                     NVL(PP.PEDF_VALOR_DESP,0)+
                     NVL(PP.PEDF_VLR_SUBS,0) --MONTA VALOR TOTAL ITEM
                                --VALOR TOTAL PEDIDO
                 ) * 100) / sum(DECODE( NVL(PF.Pedf_Vlr_Tot_Ped,0),0,1,PF.Pedf_Vlr_Tot_Ped)))) / 100,0),2),0)
        AS M_VLR_BRUTO_BONIF, 
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,2,NVL(PP.PEDF_VALOR_DESP,0),0))                          AS M_VLR_ACRES_BONIF,
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,2,NVL((PP.PEDF_VLR_TOT * NVL(PP.PEDF_PERC_DESC,0) / 100),0),0)) AS M_VLR_DESC_BONIF,
    --- INICIO CALCULO DE FRETE PREVISTO
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,2
       ,DECODE(OP.OPER_ESTATISTICA,'-',0,DECODE(PC.PROC_ESTATISTICA_QTDE,'S',0,PF.PROF_PESO_B))
       ,0)) *
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,2
       ,DECODE(OP.OPER_ESTATISTICA,'-',0,DECODE(PC.PROC_ESTATISTICA_QTDE,'S',0,PP.PEDF_QTDE))
       ,0)) *
    SUM(NVL(G14.GEN_NUMBER5,0))                                                                       AS M_VLR_FRT_PRE_BNF,
    --- FIM CALCULO DE FRETE PREVISTO
    -- DE BONIFICACAO

    ROUND(SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,2,
                     DECODE(NVL(OP.OPER_ESTATISTICA,'S'),'S',NVL(FRT_PG.VLR_FRT_PG,0),0),0
                     )
              ),2)                                                                                    AS M_VLR_FRETE_BONIF,
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,2,NVL(PP.PEDF_VLR_IPI,0),0))                             AS M_VLR_IPI_BONIF,
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,2,NVL(PP.PEDF_VLR_ICMS,0),0))                            AS M_VLR_ICMS_BONIF,
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,2,NVL(PP.PEDF_VLR_SUBS,0),0))                            AS M_VLR_SUBST_BONIF,
    SUM(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,2,NVL(PP.PEDF_BASE_SUBS,0),0))                           AS M_BASE_SUBST_BONIF,
    0                                                                                                 AS M_PESO_BRUTO,
    0                                                                                                 AS M_CUBAGEM,
    0                                                                                                 AS M_LITRAGEM,
    MAX(G11.GEN_NUMBER5)                                           AS M_POPULACAO_CIDADE,
    SUM(NVL(PM.PRECO_MEDIO,0) * PP.PEDF_QTDE)                      AS M_VLR_CUSTO,
    0                                                              AS M_NR_VISITAS,     -- Alimentar View Clientes
    0                                                              AS M_NR_CLIENTES,    -- Alimentar View Clientes

    0                                                              AS M_OBJ_FISICO,     -- Alimentar View Metas
    0                                                              AS M_OBJ_FINANCEIRO, -- Alimentar View Meta

    0                                                              AS M_QTDE_RETORNO,   -- Alimentar View Retorno
    0                                                              AS M_VLR_RETORNO,    -- Alimentar View Retorno
    0                                                              AS M_VLR_DESC_FIN_RETORNO,

    PF.PEDF_CLI_ID                                                 AS M_CLI_COMPRA,
--    PF.PEDF_CLI_ID || SUBSTR(TO_CHAR(LQ.LIQU_DTA_LIB,'DDMM'),1,4)  AS M_NR_PEDIDO,
    to_char(PF.PEDF_LIQU_ID) || '-' || to_char(PF.PEDF_ID) || '-' || to_char(PF.PEDF_NR_NF)   AS M_NR_PEDIDO,
    SUM(PP.PEDF_VALOR_SEGURO)                                      AS M_VLR_SEGURO,
    0                                                              AS M_VLR_COMISSAO,
    0                                                              AS M_VLR_INADIMPLENTE,
    MAX(NVL(DC.LIMITE_CLI,0))                                      AS M_LIMITE_CRED,
    --Pis / Cofins
    DECODE(NVL(SUM(DECODE(NVL((NVL(PP.PEDF_VLR_PIS,0) + NVL(PP.PEDF_VLR_COFINS,0)),0),0,
                                  PM.TPRC_PIS_COFINS * ((NVL(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1
                                                                        ,DECODE(OP.OPER_ESTATISTICA,'S',ROUND(PP.PEDF_QTDE ),0)),0)))
                     ,(NVL(PP.PEDF_VLR_PIS,0) + NVL(PP.PEDF_VLR_COFINS,0))
                 )),0),0,DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1,  --ENTRA SOMENTE VENDA
                                  ((SUM(PP.PEDF_VLR_TOT) -
                                   SUM((PP.PEDF_VLR_TOT * NVL(PP.PEDF_PERC_DESC,0) / 100) + NVL(PP.PEDF_VALOR_DESCONTO,0) + NVL(PF.PEDF_VLR_DESC_ESP_DUPL,0))+
                                   SUM(NVL(PP.PEDF_VALOR_FRETE,0))+
                                   SUM(NVL(PP.PEDF_VALOR_SEGURO,0))+
                                   SUM(NVL(PP.PEDF_VALOR_DESP,0))
                              ) * AVG(NVL(PIS.PERC_PIS,0))/100),0),

                SUM(DECODE( NVL((NVL(PP.PEDF_VLR_PIS,0) + NVL(PP.PEDF_VLR_COFINS,0)),0),0,
                                    PM.TPRC_PIS_COFINS * ((NVL(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1
                                                           ,DECODE(OP.OPER_ESTATISTICA,'S',ROUND(PP.PEDF_QTDE),0)),0)))
             ,(PP.PEDF_VLR_PIS + PP.PEDF_VLR_COFINS)))) - -- MENOS PIS_CONFINS ENTRADA
             DECODE(NVL(SUM(DECODE(NVL((PP.PEDF_VLR_PIS + PP.PEDF_VLR_COFINS),0),0,
                                  PM.TPRC_PIS_COFINS * ((NVL(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,3
                                                                        ,DECODE(OP.OPER_ESTATISTICA,'S',ROUND(PP.PEDF_QTDE ),0)),0)))
                     ,(PP.PEDF_VLR_PIS + PP.PEDF_VLR_COFINS)
                 )),0),0,DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,3,
                                  ((SUM(PP.PEDF_VLR_TOT) -
                                   SUM((PP.PEDF_VLR_TOT * NVL(PP.PEDF_PERC_DESC,0) / 100) + NVL(PP.PEDF_VALOR_DESCONTO,0) + NVL(PF.PEDF_VLR_DESC_ESP_DUPL,0))+
                                   SUM(NVL(PP.PEDF_VALOR_FRETE,0))+
                                   SUM(NVL(PP.PEDF_VALOR_SEGURO,0))+
                                   SUM(NVL(PP.PEDF_VALOR_DESP,0))
                              ) * AVG(NVL(PIS.PERC_PIS,0)) /100),0),
                SUM(DECODE( NVL((PP.PEDF_VLR_PIS + PP.PEDF_VLR_COFINS),0),0,
                                    PM.TPRC_PIS_COFINS * ((NVL(DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,3
                                                           ,DECODE(OP.OPER_ESTATISTICA,'S',ROUND(PP.PEDF_QTDE ),0)),0)))
             ,(PP.PEDF_VLR_PIS + PP.PEDF_VLR_COFINS))))
      AS M_VLR_PIS_COFINS   */

FROM
    LIQUIDACAO      LQ,    --Liquidac?o
    PEDIDO_FAT      PF,    --Pedido de Faturamento
    PEDIDO_FAT_P    PP,    --Item do Pedido de Faturamento
--    MA_PEDIDO_FAT   MPF,   --MA_PEDIDO_FAT
--    MA_PEDIDO_FAT_P MPFP,  --MA_PEDIDO_FAT_P
    OPERACAO_FAT    OP,    --Operacao de Faturamento
    EMPRESA         EM,    --Empresa
    CLIENTE         CL,    --Cliente
    CLIENTE_E       CE,    --Endereco do Cliente
    PRODUTO         PR,    --Produto
    PRODUTO_C       PC,    --Produto_C
    PRODUTO_FAT     PF,    --Produto_Fat
    PRODUTO_FIS     FS,    --FISCAL
    PRODUTO_W       PW,    --Produto_W
    PESSOAL         PE,    --Pessoal / Motorista
    FROTA           FR,    --Frota
    GENER           G2,    --Area
    GENER           G3,    --Distrito
    GENER           G4,    --Setor
    GENER           G5,    --Rota
    GENER           G6,    --Canal
    GENER           G7,    --Ramo
    GENER           G8,    --Segmento
    GENER           G9,    --Classe
    GENER           G10,   --Cadeia
    GENER           G11,   --Cidade
    GENER_A         P_G11, --Prop.Cidade
    GENER           G12,   --UF
    GENER           G13,   --GeoPolitico
    GENER           G14,   --Zona Entrega
    GENER           G15,   --Promotor
    GENER           G16,   --SubGrupo de Produto
    GENER_A         P_G16, --Prop.Grupo de Produto
    GENER           G17,   --Grupo de Produto
    GENER           G18,   --Origem
    GENER           G19,   --Marca
    GENER           G20,   --Sabor
    GENER           G21,   --Embalagem
    GENER           G22,   --Tabela de Precos


     (SELECT
           PM.TPRC_PROD_EMP_ID           AS PROD_EMP_ID
          ,PM.TPRC_PROD_ID               AS PROD_ID
          ,MAX(PM.TPRC_PRECO_MD)         AS PRECO_MEDIO
          ,MAX(PM.TPRC_PIS_COFINS)       AS TPRC_PIS_COFINS
      FROM
           TAB_PRC_MD PM
      WHERE
           PM.TPRC_GEN_TGEN_ID = 959
      AND  PM.TPRC_GEN_EMP_ID  IN (SELECT EMP_ID FROM EMPRESA)
      AND  PM.TPRC_GEN_ID      = 100
      GROUP BY
           PM.TPRC_PROD_EMP_ID
          ,PM.TPRC_PROD_ID           -- VERIFICAR NR.TABELA DE PRECO MEDIO
     ) PM,
     (SELECT
           CLIV_CLI_EMP_ID,
           CLIV_CLI_ID,
           MIN(CLIV_GEN_ID_DIA_SEMANA_DE) AS DIA_SEM
      FROM CLIENTE_V
      WHERE
           CLIV_CLI_EMP_ID IN (SELECT EMP_ID FROM EMPRESA)
      GROUP BY
           CLIV_CLI_EMP_ID,
           CLIV_CLI_ID
     ) DS
   ,(SELECT
           CL.CLI_EMP_ID                  AS EMP_CLI
          ,CL.CLI_ID                      AS COD_CLI
          ,MAX(CV.CVTO_DIAS_VCTO)         AS PRAZO_CLI
          ,C.CVTO_DESC                    AS COND_VCTO
          ,MAX(RPAD(G1.GEN_DESCRICAO,30)) AS FORMA_CLI
          ,MAX(CL.CLI_LIMITE_CRED)        AS LIMITE_CLI
      FROM CLIENTE CL
          ,COND_VCTO_P CV
          ,COND_VCTO   C
          ,GENER       G1
      WHERE
          CV.CVTO_CVTO_EMP_ID = CL.CLI_CVTO_EMP_ID
      AND CV.CVTO_CVTO_ID     = CL.CLI_CVTO_ID
      AND G1.GEN_TGEN_ID      = CL.CLI_GEN_TGEN_ID_TP_DOCUM_DE
      AND G1.GEN_EMP_ID       = CL.CLI_GEN_EMP_ID_TP_DOCUM_DE
      AND G1.GEN_ID           = CL.CLI_GEN_ID_TP_DOCUM_DE
      AND CV.CVTO_CVTO_EMP_ID = C.CVTO_EMP_ID
      AND CV.CVTO_CVTO_ID     = C.CVTO_ID
      GROUP BY
           CL.CLI_EMP_ID
          ,CL.CLI_ID
          ,C.CVTO_DESC
     ) DC
   ,(SELECT
           GEN_EMP_ID  AS COD_EMP
          ,SUM(NVL(DECODE(NVL(G.GEN_NUMBER5,0),0,G.GEN_NUMBER1,G.GEN_NUMBER5),0)) PERC_PIS
      FROM GENER G
      WHERE
           G.GEN_TGEN_ID  = 945
      AND  G.GEN_ID      IN (55,66)
      GROUP BY
          GEN_EMP_ID
     ) PIS
     ,--- CURSOR INTERNO FRETE
(SELECT PP.PEDF_PEDF_EMP_ID,
       PP.PEDF_PEDF_ID,
       PP.PEDF_ID,
       SUM(PP.PEDF_QTDE * PFAT.PROF_PESO_B) *  (SELECT CP.CP_VALOR_CTE / SUM(P.PEDF_QTDE * PFAT.PROF_PESO_B)
                       FROM  CAPA_CTE CP
                            ,ITENS_CTE I
                            ,PEDIDO_FAT_NFE NFE
                            ,PEDIDO_FAT     F
                            ,PEDIDO_FAT_P   P
                            ,PRODUTO_FAT    PFAT
                       WHERE CP.CP_EMP_ID    = CTE.CP_EMP_ID
                       AND   CP.CP_CHAVE_CTE = CTE.CP_CHAVE_CTE
                       AND   CP.CP_EMP_ID    = CTE.CP_EMP_ID
                       AND   CP.CP_CHAVE_CTE = CTE.CP_CHAVE_CTE
                       AND   CP.CP_EMP_ID    = I.IT_EMP_ID
                       AND   CP.CP_CHAVE_CTE = I.IT_CHAVE_CTE
                       AND   I.IT_EMP_ID     = NFE.PEDF_PEDF_EMP_ID
                       AND   I.IT_CHAVE_NFE  = NFE.PEDF_NFE_CHAVE
                       AND   NFE.PEDF_PEDF_EMP_ID = F.PEDF_EMP_ID
                       AND   NFE.PEDF_PEDF_ID     = F.PEDF_ID
                       AND   F.PEDF_OPER_EMP_ID   = OP.OPER_EMP_ID
                       AND   F.PEDF_OPER_ID       = OP.OPER_ID
                       AND   NFE.PEDF_PEDF_EMP_ID = P.PEDF_PEDF_EMP_ID
                       AND   NFE.PEDF_PEDF_ID     = P.PEDF_PEDF_ID
                       AND   PP.PEDF_PROD_EMP_ID  = PFAT.PROF_PROD_EMP_ID
                       AND   PP.PEDF_PROD_ID      = PFAT.PROF_PROD_ID
                       GROUP BY CP.CP_EMP_ID, CP.CP_CHAVE_CTE, CP.CP_VALOR_CTE, PP.PEDF_PROD_ID
                       ) VLR_FRT_PG
FROM CAPA_CTE       CTE,
     ITENS_CTE      IT,
     PEDIDO_FAT_NFE NFE,
     PEDIDO_FAT     PF,
     --
     OPERACAO_FAT   OP,
     LIQUIDACAO     L,
     PEDIDO_FAT_P   PP,
     --
     PRODUTO_C      PC,
     PRODUTO_FAT    PFAT
WHERE CTE.CP_EMP_ID         = IT.IT_EMP_ID
AND   CTE.CP_CHAVE_CTE      = IT.IT_CHAVE_CTE
AND   NFE.PEDF_PEDF_EMP_ID  = IT.IT_EMP_ID
AND   NFE.PEDF_NFE_CHAVE    = IT.IT_CHAVE_NFE
AND   NFE.PEDF_PEDF_EMP_ID  = PF.PEDF_EMP_ID
AND   NFE.PEDF_PEDF_ID      = PF.PEDF_ID
--
AND   PF.PEDF_OPER_EMP_ID   = OP.OPER_EMP_ID
AND   PF.PEDF_OPER_ID       = OP.OPER_ID
--
AND   PF.PEDF_LIQU_EMP_ID   = L.LIQU_EMP_ID
AND   PF.PEDF_LIQU_ID       = L.LIQU_ID
AND   TRUNC(L.LIQU_DTA_EMIS)>=  TO_DATE('01/' || to_char(sysdate -30,'mm/yyyy')  )
--AND   TRUNC(L.LIQU_DTA_EMIS)<= TO_DATE('31/01/2023','DD/MM/RRRR')
AND   PF.PEDF_EMP_ID        = PP.PEDF_PEDF_EMP_ID
AND   PF.PEDF_ID            = PP.PEDF_PEDF_ID
--
AND   PP.PEDF_PROD_EMP_ID   = PC.PROC_PROD_EMP_ID
AND   PP.PEDF_PROD_ID       = PC.PROC_PROD_ID

AND   PP.PEDF_PROD_EMP_ID   = PFAT.PROF_PROD_EMP_ID
AND   PP.PEDF_PROD_ID       = PFAT.PROF_PROD_ID
-- TESTES ACRESCENTADOS
AND PC.PROC_ESTATISTICA      = 'S'          --Produtos de Estatistica
AND PF.PEDF_SITUACAO         IN (0,2)       --Pedidos Normais OU DEVOLVIDOS
AND (PF.PEDF_NR_NF           IS NOT NULL
  OR PF.PEDF_NF_COBERT       IS NOT NULL)--PEGA VENDAS E PEDIDOS
AND OP.OPER_GEN_ID_TP_OPERACAO_DE IN (1,2)
---
    -- AND PF.PEDF_ID IN (202289,202537)

GROUP BY PF.PEDF_EMP_ID,
         PF.PEDF_ID,
         PF.PEDF_NR_NF,
         PF.PEDF_SERIE_NF,
         PP.PEDF_PROD_EMP_ID,
         PP.PEDF_PROD_ID,
         PP.PEDF_PEDF_EMP_ID,
         PP.PEDF_PEDF_ID,
         PP.PEDF_ID,
         CTE.CP_EMP_ID,
         CTE.CP_VALOR_CTE,
         CTE.CP_CHAVE_CTE,
         PFAT.PROF_PESO_B,
         PP.PEDF_QTDE,
         --
         OP.OPER_EMP_ID,
         OP.OPER_ID
        ) FRT_PG
WHERE
--Pedido Fat
    PF.PEDF_LIQU_EMP_ID       = LQ.LIQU_EMP_ID
AND PF.PEDF_LIQU_ID           = LQ.LIQU_ID
--Item do Pedido Fat
AND PP.PEDF_PEDF_EMP_ID       = PF.PEDF_EMP_ID
AND PP.PEDF_PEDF_ID           = PF.PEDF_ID
-- FRETE PAGO
AND PP.PEDF_PEDF_EMP_ID    = FRT_PG.PEDF_PEDF_EMP_ID (+)
AND PP.PEDF_PEDF_ID        = FRT_PG.PEDF_PEDF_ID (+)
AND PP.PEDF_ID             = FRT_PG.PEDF_ID   (+)
-- MA_PEDIDO_FAT
--AND PF.PEDF_EMP_ID       (+)  = MPF.PEDF_EMP_ID
--AND PF.PEDF_ID_ORIGEM2  (+)   = MPF.PEDF_ID
-- ITEM MA_PEDIDO_FAT
--AND MPF.PEDF_EMP_ID        = MPFP.PEDF_PEDF_EMP_ID
--AND MPF.PEDF_ID            = MPFP.PEDF_PEDF_ID
--AND PP.PEDF_ID           (+)  = MPFP.PEDF_ID
--Operacao de Faturamento
AND OP.OPER_EMP_ID            = PF.PEDF_OPER_EMP_ID
AND OP.OPER_ID                = PF.PEDF_OPER_ID
--Empresa
AND EM.EMP_ID                 = LQ.LIQU_EMP_ID
--Cliente
AND CL.CLI_EMP_ID             = PF.PEDF_CLI_EMP_ID
AND CL.CLI_ID                 = PF.PEDF_CLI_ID
--Cliente Endereco
AND CE.CLIE_CLI_EMP_ID        = PF.PEDF_CLI_EMP_ID
AND CE.CLIE_CLI_ID            = PF.PEDF_CLI_ID
--Produto
AND PR.PROD_EMP_ID        (+) = PP.PEDF_PROD_EMP_ID
AND PR.PROD_ID            (+) = PP.PEDF_PROD_ID
--Produto_C
AND PC.PROC_PROD_EMP_ID   (+) = PR.PROD_EMP_ID
AND PC.PROC_PROD_ID       (+) = PR.PROD_ID
--Produto_Fat
AND PF.PROF_PROD_EMP_ID   (+) = PR.PROD_EMP_ID
AND PF.PROF_PROD_ID       (+) = PR.PROD_ID
--Produto_W
AND PW.PROW_PROD_EMP_ID   (+) = PR.PROD_EMP_ID
AND PW.PROW_PROD_ID       (+) = PR.PROD_ID
--PRODUTO_FIS
AND FS.PROF_PROD_EMP_ID   (+) = PR.PROD_EMP_ID
AND FS.PROF_PROD_ID       (+) = PR.PROD_ID
--Pessoal Motorista
AND PE.PES_EMP_ID         (+) = LQ.LIQU_PES_EMP_ID_MOTORISTA_DE
AND PE.PES_ID             (+) = LQ.LIQU_PES_ID_MOTORISTA_DE
--Frota
AND FR.FRO_EMP_ID         (+) = LQ.LIQU_FRO_EMP_ID
AND FR.FRO_ID             (+) = LQ.LIQU_FRO_ID
--Area
AND G2.GEN_TGEN_ID        (+) = PF.PEDF_GEN_TGEN_ID_AREA_DE
AND G2.GEN_EMP_ID         (+) = PF.PEDF_GEN_EMP_ID_AREA_DE
AND G2.GEN_ID             (+) = PF.PEDF_GEN_ID_AREA_DE
--Distrito
AND G3.GEN_TGEN_ID        (+) = PF.PEDF_GEN_TGEN_ID
AND G3.GEN_EMP_ID         (+) = PF.PEDF_GEN_EMP_ID
AND G3.GEN_ID             (+) = PF.PEDF_GEN_ID
--Setor
AND G4.GEN_TGEN_ID        (+) = PF.PEDF_GEN_TGEN_ID_SETOR_DE
AND G4.GEN_EMP_ID         (+) = PF.PEDF_GEN_EMP_ID_SETOR_DE
AND G4.GEN_ID             (+) = PF.PEDF_GEN_ID_SETOR_DE
--Rota
AND G5.GEN_TGEN_ID        (+) = PF.PEDF_GEN_TGEN_ID_ROTA_DE
AND G5.GEN_EMP_ID         (+) = PF.PEDF_GEN_EMP_ID_ROTA_DE
AND G5.GEN_ID             (+) = PF.PEDF_GEN_ID_ROTA_DE
--Estrutura Canal
AND G6.GEN_TGEN_ID        (+) = CL.CLI_GEN_TGEN_ID_CANAL_DE
AND G6.GEN_EMP_ID         (+) = CL.CLI_GEN_EMP_ID_CANAL_DE
AND G6.GEN_ID             (+) = CL.CLI_GEN_ID_CANAL_DE
--Estrutura Ramo ATV
AND G7.GEN_TGEN_ID        (+) = CL.CLI_GEN_TGEN_ID_RAMO_ATV_DE
AND G7.GEN_EMP_ID         (+) = CL.CLI_GEN_EMP_ID_RAMO_ATV_DE
AND G7.GEN_ID             (+) = CL.CLI_GEN_ID_RAMO_ATV_DE
--Estrutura Segmento
AND G8.GEN_TGEN_ID        (+) = CL.CLI_GEN_TGEN_ID_SEGMENTO_DE
AND G8.GEN_EMP_ID         (+) = CL.CLI_GEN_EMP_ID_SEGMENTO_DE
AND G8.GEN_ID             (+) = CL.CLI_GEN_ID_SEGMENTO_DE
--Estrutura Classe
AND G9.GEN_TGEN_ID        (+) = CL.CLI_GEN_TGEN_ID
AND G9.GEN_EMP_ID         (+) = CL.CLI_GEN_EMP_ID
AND G9.GEN_ID             (+) = CL.CLI_GEN_ID
--Estrutura Cadeia
AND G10.GEN_TGEN_ID       (+) = CL.CLI_GEN_TGEN_ID_CADEIA_DE
AND G10.GEN_EMP_ID        (+) = CL.CLI_GEN_EMP_ID_CADEIA_DE
AND G10.GEN_ID            (+) = CL.CLI_GEN_ID_CADEIA_DE
--Cidade
AND G11.GEN_TGEN_ID       (+) = CE.CLIE_GEN_TGEN_ID_CIDADE_DE
AND G11.GEN_EMP_ID        (+) = CE.CLIE_GEN_EMP_ID_CIDADE_DE
AND G11.GEN_ID            (+) = CE.CLIE_GEN_ID_CIDADE_DE
--Prop.Cidade
AND P_G11.GENA_GEN_TGEN_ID (+) = G11.GEN_TGEN_ID
AND P_G11.GENA_GEN_EMP_ID  (+) = G11.GEN_EMP_ID
AND P_G11.GENA_GEN_ID      (+) = G11.GEN_ID
--UF
AND G12.GEN_TGEN_ID       (+) = P_G11.GENA_GEN_TGEN_ID_PROPRIETARIO_
AND G12.GEN_EMP_ID        (+) = P_G11.GENA_GEN_EMP_ID_PROPRIETARIO_D
AND G12.GEN_ID            (+) = P_G11.GENA_GEN_ID_PROPRIETARIO_DE
--GEOPOLITICO
AND G13.GEN_TGEN_ID       (+) = CE.CLIE_GEN_TGEN_ID_GEOPOLITICO_D
AND G13.GEN_EMP_ID        (+) = CE.CLIE_GEN_EMP_ID_GEOPOLITICO_DE
AND G13.GEN_ID            (+) = CE.CLIE_GEN_ID_GEOPOLITICO_DE
--ZONA DE ENTREGA
AND G14.GEN_TGEN_ID       (+) = CL.CLI_GEN_TGEN_ID_ZONA_DE
AND G14.GEN_EMP_ID        (+) = CL.CLI_GEN_EMP_ID_ZONA_DE
AND G14.GEN_ID            (+) = CL.CLI_GEN_ID_ZONA_DE
--PROMOTOR
AND G15.GEN_TGEN_ID       (+) = CL.CLI_GEN_TGEN_ID_PROMOTOR_DE
AND G15.GEN_EMP_ID        (+) = CL.CLI_GEN_EMP_ID_PROMOTOR_DE
AND G15.GEN_ID            (+) = CL.CLI_GEN_ID_PROMOTOR_DE
--SubGrupo de Produto
AND G16.GEN_TGEN_ID       (+) = PC.PROC_GEN_TGEN_ID_CATEGORIA_DE
AND G16.GEN_EMP_ID        (+) = PC.PROC_GEN_EMP_ID_CATEGORIA_DE
AND G16.GEN_ID            (+) = PC.PROC_GEN_ID_CATEGORIA_DE
--Prop.SubGrupo de Produto
AND P_G16.GENA_GEN_TGEN_ID (+) = G16.GEN_TGEN_ID
AND P_G16.GENA_GEN_EMP_ID  (+) = G16.GEN_EMP_ID
AND P_G16.GENA_GEN_ID      (+) = G16.GEN_ID
--Grupo de Produto
AND G17.GEN_TGEN_ID       (+) = P_G16.GENA_GEN_TGEN_ID_PROPRIETARIO_
AND G17.GEN_EMP_ID        (+) = P_G16.GENA_GEN_EMP_ID_PROPRIETARIO_D
AND G17.GEN_ID            (+) = P_G16.GENA_GEN_ID_PROPRIETARIO_DE
--Origem
AND G18.GEN_TGEN_ID       (+) = PC.PROC_GEN_TGEN_ID_ORIGEM_DE
AND G18.GEN_EMP_ID        (+) = PC.PROC_GEN_EMP_ID_ORIGEM_DE
AND G18.GEN_ID            (+) = PC.PROC_GEN_ID_ORIGEM_DE
--Marca
AND G19.GEN_TGEN_ID       (+) = PC.PROC_GEN_TGEN_ID_MARCA_DE
AND G19.GEN_EMP_ID        (+) = PC.PROC_GEN_EMP_ID_MARCA_DE
AND G19.GEN_ID            (+) = PC.PROC_GEN_ID_MARCA_DE
--Sabor
AND G20.GEN_TGEN_ID       (+) = PC.PROC_GEN_TGEN_ID_SABOR_DE
AND G20.GEN_EMP_ID        (+) = PC.PROC_GEN_EMP_ID_SABOR_DE
AND G20.GEN_ID            (+) = PC.PROC_GEN_ID_SABOR_DE
--Embalagem
AND G21.GEN_TGEN_ID       (+) = PC.PROC_GEN_TGEN_ID_EMBALAGEM_DE
AND G21.GEN_EMP_ID        (+) = PC.PROC_GEN_EMP_ID_EMBALAGEM_DE
AND G21.GEN_ID            (+) = PC.PROC_GEN_ID_EMBALAGEM_DE
--Tab.Precos
AND G22.GEN_TGEN_ID       (+) = PP.PEDF_TPRC_GEN_TGEN_ID
AND G22.GEN_EMP_ID        (+) = PP.PEDF_TPRC_GEN_EMP_ID
AND G22.GEN_ID            (+) = PP.PEDF_TPRC_GEN_ID
AND PIS.COD_EMP           (+) = PF.PEDF_EMP_ID

--PRECO MEDIO
AND PM.PROD_EMP_ID        (+) = PP.PEDF_PROD_EMP_ID
AND PM.PROD_ID            (+) = PP.PEDF_PROD_ID
--DIA SEMANA
AND DS.CLIV_CLI_EMP_ID    (+) = PF.PEDF_CLI_EMP_ID
AND DS.CLIV_CLI_ID        (+) = PF.PEDF_CLI_ID
--DADOS DE CLIENTE
AND DC.EMP_CLI            (+) = PF.PEDF_CLI_EMP_ID
AND DC.COD_CLI            (+) = PF.PEDF_CLI_ID
--FILTRO
AND LQ.LIQU_EMP_ID          IN (SELECT EMP_ID FROM EMPRESA)
AND TRUNC(LQ.LIQU_DTA_EMIS) >= TO_DATE('01/01/2019','DD/MM/RRRR')-->>> SOMENTE A PARTIR DE 2014 FAZER A IMPORTAC?O--
--AND TRUNC(LQ.LIQU_DTA_EMIS) <= TO_DATE('01/06/2025','DD/MM/YYYY')-->>> SOMENTE A PARTIR DE 2014 FAZER A IMPORTAC?O--

--AND  DC.COD_CLI IN(15788,16547,16586,16734,16937,17099,17409,17520,17654,17794,17837,18200,18388,18509,18595,18645,18695,18813,19108)
--AND  PF.PEDF_NR_NF = 158989 -- 159458
--AND  PR.PROD_ID = 66

AND CE.CLIE_GEN_ID           = 2            --Endereco Normal
--and PF.PEDF_GEN_ID_ROTA_DE  = 17
AND PC.PROC_ESTATISTICA      = 'S'          --Produtos de Estatistica
AND PF.PEDF_SITUACAO         IN (0,2)       --Pedidos Normais OU DEVOLVIDOS
--AND PF.PEDF_NR_NF            = 129802  --Notas Emitidas
AND (PF.PEDF_NR_NF           IS NOT NULL
  OR PF.PEDF_NF_COBERT       IS NOT NULL)--PEGA VENDAS E PEDIDOS
AND OP.OPER_GEN_ID_TP_OPERACAO_DE IN (1,2)  --Operacoes de Vendas e Bonificacoes
--AND PF.PEDF_NR_NF                 IN (157542)
AND  LQ.LIQU_DTA_EMIS between '01/07/2023' and '31/07/2023'
AND PF.PEDF_OPER_ID NOT IN (2,22)
--AND PF.PEDF_NR_NF = 175341
GROUP BY
    LQ.LIQU_EMP_ID
    ,PP.PEDF_DESC_ATACADO
    ,PP.PEDF_VALOR_DESCONTO
    ,PF.PEDF_EMP_ID -- INCLUSAO LEANDRO PARA DATA NFE
    ,RPAD(EM.EMP_NOME,40)
    ,SUBSTR(TO_CHAR(LQ.LIQU_DTA_EMIS,'YYYYMMDD'),1,4)
    ,SUBSTR(TO_CHAR(LQ.LIQU_DTA_EMIS,'YYYYMMDD'),5,2)
    ,SUBSTR(TO_CHAR(LQ.LIQU_DTA_EMIS,'YYYYMMDD'),7,2)
    ,TO_CHAR(LQ.LIQU_DTA_EMIS,'WW')
    ,LQ.LIQU_DTA_EMIS
    ,SUBSTR(TO_CHAR(LQ.LIQU_DTA_LIB,'YYYYMMDD'),1,4)-- Liberacao Liquidacao
    ,SUBSTR(TO_CHAR(LQ.LIQU_DTA_LIB,'YYYYMMDD'),5,2)-- Liberacao Liquidacao
    ,SUBSTR(TO_CHAR(LQ.LIQU_DTA_LIB,'YYYYMMDD'),7,2)-- Liberacao Liquidacao
    ,TO_CHAR(LQ.LIQU_DTA_LIB,'WW')-- Liberacao Liquidacao
    ,LQ.LIQU_DTA_LIB
    ,G2.GEN_ID
    ,RPAD(G2.GEN_DESCRICAO,30)
    ,G3.GEN_ID
    ,RPAD(G3.GEN_DESCRICAO,30)
    ,G4.GEN_ID
    ,RPAD(G4.GEN_DESCRICAO,30)
    ,G5.GEN_ID
    ,FS.PROF_GEN_ID
    ,RPAD(G5.GEN_DESCRICAO,30)
    ,RPAD(G6.GEN_DESCRICAO,30)
    ,RPAD(G7.GEN_DESCRICAO,30)
    ,RPAD(G15.GEN_DESCRICAO,30)
    ,RPAD(G8.GEN_DESCRICAO,30)
    ,PF.PEDF_CLI_ID
    ,RPAD(CL.CLI_FANTASIA,40)
    ,RPAD(CL.CLI_RAZAO_SOCIAL,40)
    ,RPAD(CE.CLIE_ENDERECO,50)
    ,RPAD(CE.CLIE_COMPLEMENTO,50)
    ,RPAD(G9.GEN_DESCRICAO,30)
    ,RPAD(G10.GEN_DESCRICAO,30)
    ,RPAD(G11.GEN_DESCRICAO,30)
    ,RPAD(G12.GEN_DESCRICAO,30)
    ,RPAD(G13.GEN_DESCRICAO,30)
    ,RPAD(G14.GEN_DESCRICAO,30)
    ,DECODE(DS.DIA_SEM,1,'DOM')
    ,DECODE(DS.DIA_SEM,2,'SEG')
    ,DECODE(DS.DIA_SEM,3,'TER')
    ,DECODE(DS.DIA_SEM,4,'QUA')
    ,DECODE(DS.DIA_SEM,5,'QUI')
    ,DECODE(DS.DIA_SEM,6,'SEX')
    ,DECODE(DS.DIA_SEM,7,'SAB')
    ,PR.PROD_ID
    ,RPAD(PR.PROD_DESC,40)
    ,RPAD(G17.GEN_DESCRICAO,30)
    ,RPAD(G16.GEN_DESCRICAO,30)
    ,TO_CHAR(G18.GEN_ID,'000000')
    ,RPAD(G18.GEN_DESCRICAO,30)
    ,TO_CHAR(G19.GEN_ID,'000000')
    ,RPAD(G19.GEN_DESCRICAO,30)
    ,TO_CHAR(G21.GEN_ID,'000000')
    ,RPAD(G21.GEN_DESCRICAO,30)
    ,TO_CHAR(G20.GEN_ID,'000000')
    ,RPAD(G20.GEN_DESCRICAO,30)
   -- ,RPAD(PFOR.PROF_REF_FORNECEDOR,30)
    ,RPAD(FR.FRO_PLACA || FR.FRO_MODELO,30)
    ,LQ.LIQU_PES_ID_MOTORISTA_DE
    ,RPAD(PE.PES_NOME,30)
    ,DC.COND_VCTO
    ,TO_CHAR(DC.PRAZO_CLI,'000')
    ,DECODE(OP.OPER_GEN_ID_TP_OPERACAO_DE,1,'VENDA','BONIFICACAO')
    ,PP.PEDF_TPRC_GEN_ID
    ,RPAD(G22.GEN_DESCRICAO,30)
    ,PF.PEDF_NR_NF
    ,PF.PEDF_FLAG_EMIS
    ,PF.PEDF_LIQU_ID
    ,PR.PROD_EMP_ID
    ,PF.PEDF_ID
    ,PF.PEDF_NR_NF
    ,OP.OPER_GEN_ID_TP_OPERACAO_DE
    ,PP.MA_PEDF_PERC_COMIS_REPRE
    ,PP.MA_PEDF_PERC_COMIS_GERENCIA
    ,PP.PEDF_VALOR_FRETE
    ,PP.PEDF_VLR_UNIT
    ,PP.PEDF_QTDE
    ,PP.PEDF_ADC_FINANC
    ,PP.PEDF_PERC_DESC
    ,PP.PEDF_VALOR_SEGURO
    ,PP.PEDF_VALOR_DESP
    ,PP.PEDF_VLR_IPI
    ,PP.PEDF_VLR_SUBS
    ,PP.PEDF_VLR_ICMS_DES
 --   ,MPFP.PEDF_PERC_COMIS_REPRE
 --   ,MPFP.PEDF_PERC_COMIS_GERENCIA
;
