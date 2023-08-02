--CREATE OR REPLACE VIEW MOVIMENTACAO_PALLETS AS
SELECT
        PF.PEDF_NR_NF                       AS NOTA
       ,PF.PEDF_ID                          AS PEDIDO
       ,TO_CHAR(NF.PEDF_NFE_DTA_CAD,'MM')   AS MES_EMISSAO
       ,TO_DATE(NF.PEDF_NFE_DTA_CAD,'DD/MM/YYYY')                 AS DATA_EMISSAO
       ,OP.OPER_ID||'-'||OP.OPER_DESC       AS OPERACAO
       ,OE.OPER_INC_EMB_2                   AS INCIDENCIA
       ,PF.PEDF_CLI_ID                      AS COD_CLI_FOR
       ,CL.CLI_RAZAO_SOCIAL                 AS CLIENTE_FORNECEDOR
       ,CID.GEN_DESCRICAO                   AS CIDADE
       ,UF.GEN_DESCRICAO                    AS "UF"
       ,PP.PEDF_PROD_ID||'-'||PR.PROD_DESC  AS PRODUTO
       ,CASE WHEN OE.OPER_INC_EMB_2 = '-'
         THEN -PP.PEDF_QTDE
          ELSE PP.PEDF_QTDE END             AS QTD
  FROM PEDIDO_FAT_P       PP
      ,PEDIDO_FAT         PF
      ,PRODUTO            PR
      ,OPERACAO_FAT       OP
      ,OPERACAO_EST       OE
      ,PEDIDO_FAT_NFE     NF
      ,CLIENTE            CL
      ,CLIENTE_E          CLE
      ,GENER              CID
      ,GENER_A            CIDA
      ,GENER              UF
WHERE PF.PEDF_EMP_ID                 = PP.PEDF_PEDF_EMP_ID
 AND  PF.PEDF_ID                     = PP.PEDF_PEDF_ID
 AND  PP.PEDF_PROD_EMP_ID            = PR.PROD_EMP_ID
 AND  PP.PEDF_PROD_ID                = PR.PROD_ID
 AND  PF.PEDF_OPER_EMP_ID            = OP.OPER_EMP_ID
 AND  PF.PEDF_OPER_ID                = OP.OPER_ID
 AND  PF.PEDF_EMP_ID                 = NF.PEDF_PEDF_EMP_ID
 AND  PF.PEDF_ID                     = NF.PEDF_PEDF_ID
 AND  PF.PEDF_CLI_EMP_ID             = CL.CLI_EMP_ID
 AND  PF.PEDF_CLI_ID                 = CL.CLI_ID
 AND  CL.CLI_EMP_ID                  = CLE.CLIE_CLI_EMP_ID
 AND  CL.CLI_ID                      = CLE.CLIE_CLI_ID
 AND  CLE.CLIE_GEN_TGEN_ID_CIDADE_DE = CID.GEN_TGEN_ID
 AND  CLE.CLIE_GEN_EMP_ID_CIDADE_DE  = CID.GEN_EMP_ID
 AND  CLE.CLIE_GEN_ID_CIDADE_DE      = CID.GEN_ID
 AND  CID.GEN_TGEN_ID                = CIDA.GENA_GEN_TGEN_ID
 AND  CID.GEN_EMP_ID                 = CIDA.GENA_GEN_EMP_ID
 AND  CID.GEN_ID                     = CIDA.GENA_GEN_ID
 AND   UF.GEN_TGEN_ID                = CIDA.GENA_GEN_TGEN_ID_PROPRIETARIO_
 AND   UF.GEN_EMP_ID                 = CIDA.GENA_GEN_EMP_ID_PROPRIETARIO_D
 AND   UF.GEN_ID                     = CIDA.GENA_GEN_ID_PROPRIETARIO_DE
 AND   OP.OPER_OPER_E_ID             = OE.OPER_ID
 AND   CLE.CLIE_GEN_ID               = 2
--INICIO DOS FILTROS
AND   PR.PROD_ID                     = 52
AND   NF.PEDF_NFE_DTA_CAD            >= SYSDATE - 180

UNION ALL

SELECT
        E.ENTR_NR_DOC                       AS NOTA
       ,E.ENTR_ID                           AS PEDIDO
       ,TO_CHAR(E.ENTR_DTA_EMIS,'MM')       AS MES_EMISSAO
       ,E.ENTR_DTA_EMIS                     AS DATA_EMISSAO
       ,OP.OPER_ID||'-'||OP.OPER_DESC       AS OPERACAO
       ,OP.OPER_ESTQ_ATUAL                  AS INCIDENCIA
       ,E.ENTR_FORN_ID                      AS COD_CLI_FOR
       ,F.FORN_RAZAO                        AS CLIENTE_FORNECEDOR
       ,CID.GEN_DESCRICAO                   AS CIDADE
       ,UF.GEN_DESCRICAO                    AS "UF"
       ,ee.entr_prod_id||'-'||PR.PROD_DESC  AS PRODUTO
       ,CASE WHEN OP.OPER_ESTQ_ATUAL  = '-'
         THEN -ee.entr_qtde
           ELSE ee.entr_qtde END            AS QTD
FROM
     ENTRADA_ALM     E
    ,ENTRADA_ALM_E   EE
    ,PRODUTO         PR
    ,OPERACAO_ALM    OP
    ,FORNECEDOR      F
    ,GENER           CID
    ,GENER_A         CIDA
    ,GENER           UF
where
      e.entr_emp_id          = ee.entr_entr_emp_id
  and e.entr_id              = ee.entr_entr_id
  and ee.entr_prod_emp_id    = pr.prod_emp_id
  and ee.entr_prod_id        = pr.prod_id
  and e.entr_oper_alm_emp_id = op.oper_emp_id
  and e.entr_oper_alm_id     = op.oper_id
  and e.entr_forn_id         = f.forn_id
  AND f.forn_gen_tgen_id     = CID.GEN_TGEN_ID
  AND F.FORN_GEN_EMP_ID      = CID.GEN_EMP_ID
  AND F.FORN_GEN_ID          = CID.GEN_ID
  AND CID.GEN_TGEN_ID        = CIDA.GENA_GEN_TGEN_ID
  AND CID.GEN_EMP_ID         = CIDA.GENA_GEN_EMP_ID
  AND CID.GEN_ID             = CIDA.GENA_GEN_ID
  AND UF.GEN_TGEN_ID         = CIDA.GENA_GEN_TGEN_ID_PROPRIETARIO_
  AND UF.GEN_EMP_ID          = CIDA.GENA_GEN_EMP_ID_PROPRIETARIO_D
  AND UF.GEN_ID              = CIDA.GENA_GEN_ID_PROPRIETARIO_DE
--  INICIO FILTROS
  AND PR.PROD_ID             = 52
  AND E.ENTR_DTA_LANC        >= SYSDATE -180
--  AND E.ENTR_OPER_ALM_ID     NOT IN 13

ORDER BY
3,6,4,5
;
