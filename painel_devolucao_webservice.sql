SELECT
P.PEDF_ID                                            AS PEDIDO
    ,P.PEDF_NR_NF                                         AS NOTA_FISCAL
    ,AR.GEN_DESCRICAO                                     AS AREA
    ,P.PEDF_GEN_ID                                        AS COD_GER
    ,GER.GEN_DESCRICAO                                    AS GERENTE
    ,P.PEDF_GEN_ID_SETOR_DE                               AS COD_REP
    ,REP.GEN_DESCRICAO                                    AS REPRESENTANTE
    ,P.PEDF_GEN_ID_ROTA_DE                                AS COD_VEND
    ,VEN.GEN_DESCRICAO                                    AS VENDEDOR
    ,P.PEDF_CLI_ID                                        AS COD_CLI
    ,CL.CLI_RAZAO_SOCIAL                                  AS CLIENTE
    ,CID.GEN_DESCRICAO                                    AS CIDADE
    ,UF.GEN_DESCRICAO                                     AS UF
    ,EMB.GEN_ID                                           AS COD_EMB
    ,EMB.GEN_DESCRICAO                                    AS EMBALAGEM
    ,PP.PEDF_PROD_ID                                      AS COD_PROD
    ,PR.PROD_DESC                                         AS PRODUTO
    ,DECODE(TO_CHAR(P.PEDF_DTA_EMIS,'MM'),1,'JANEIRO'
  ,2,'FEVEREIRO',3,'MARCO',4,'ABRIL',5,'MAIO'
  ,6,'JUNHO',7,'JULHO',8,'AGOSTO',9,'SETEMBRO'
  ,10,'OUTUBRO',11,'NOVEMBRO',12,'DEZEMBRO')         AS MES
    ,TO_CHAR(P.PEDF_DTA_EMIS,'YYYY')                      AS ANO
    ,SUM((PP.PEDF_VLR_TOT + NVL(PP.PEDF_VLR_IPI,0)
  + NVL(PP.PEDF_VLR_SUBS,0))
  - NVL(PP.PEDF_VALOR_DESCONTO,0))                   AS VALOR
    ,SUM(PP.PEDF_QTDE)                                    AS QUANTIDADE
FROM PEDIDO_FAT P
INNER JOIN OPERACAO_FAT O   ON O.OPER_ID                = P.PEDF_OPER_ID
INNER JOIN LIQUIDACAO LQ    ON LQ.LIQU_EMP_ID           = P.PEDF_LIQU_EMP_ID
                           AND LQ.LIQU_ID               = P.PEDF_LIQU_ID
INNER JOIN GENER     AR     ON AR.GEN_TGEN_ID           = P.PEDF_GEN_TGEN_ID_AREA_DE
                           AND AR.GEN_EMP_ID            = P.PEDF_GEN_EMP_ID_AREA_DE
                           AND AR.GEN_ID                = P.PEDF_GEN_ID_AREA_DE
INNER JOIN GENER     GER    ON GER.GEN_TGEN_ID          = P.PEDF_GEN_TGEN_ID
                           AND GER.GEN_EMP_ID           = P.PEDF_GEN_EMP_ID
                           AND GER.GEN_ID               = P.PEDF_GEN_ID
INNER JOIN GENER     REP    ON REP.GEN_TGEN_ID          = P.PEDF_GEN_TGEN_ID_SETOR_DE
                           AND REP.GEN_EMP_ID           = P.PEDF_GEN_EMP_ID_SETOR_DE
                           AND REP.GEN_ID               = P.PEDF_GEN_ID_SETOR_DE
INNER JOIN GENER     VEN    ON VEN.GEN_TGEN_ID          = P.PEDF_GEN_TGEN_ID_ROTA_DE
                           AND VEN.GEN_EMP_ID           = P.PEDF_GEN_EMP_ID_ROTA_DE
                           AND VEN.GEN_ID               = P.PEDF_GEN_ID_ROTA_DE
INNER JOIN PEDIDO_FAT_P PP  ON PP.PEDF_PEDF_EMP_ID      = P.PEDF_EMP_ID
                           AND PP.PEDF_PEDF_ID          = P.PEDF_ID
INNER JOIN PRODUTO PR       ON PR.PROD_EMP_ID           = PP.PEDF_PROD_EMP_ID
                           AND PR.PROD_ID               = PP.PEDF_PROD_ID

INNER JOIN PRODUTO_TP PTP   ON PTP.PROT_PROD_EMP_ID  = PP.PEDF_PROD_EMP_ID
                           AND PTP.PROT_PROD_ID      = PP.PEDF_PROD_ID

INNER JOIN PRODUTO_C   PC   ON PC.PROC_PROD_EMP_ID      = PR.PROD_EMP_ID
                           AND PC.PROC_PROD_ID          = PR.PROD_ID
INNER JOIN GENER    EMB     ON EMB.GEN_TGEN_ID          = PC.PROC_GEN_TGEN_ID_EMBALAGEM_DE
                           AND EMB.GEN_EMP_ID           = PC.PROC_GEN_EMP_ID_EMBALAGEM_DE
                           AND EMB.GEN_ID               = PC.PROC_GEN_ID_EMBALAGEM_DE
INNER JOIN CLIENTE   CL     ON CL.CLI_EMP_ID            = P.PEDF_CLI_EMP_ID
                           AND CL.CLI_ID                = P.PEDF_CLI_ID
INNER JOIN CLIENTE_E  CE    ON CE.CLIE_CLI_EMP_ID       = CL.CLI_EMP_ID
                           AND CE.CLIE_CLI_ID           = CL.CLI_ID
                           AND CE.CLIE_GEN_ID           = 2
INNER JOIN GENER     CID    ON CID.GEN_TGEN_ID          = CE.CLIE_GEN_TGEN_ID_CIDADE_DE
                           AND CID.GEN_EMP_ID           = CE.CLIE_GEN_EMP_ID_CIDADE_DE
                           AND CID.GEN_ID               = CE.CLIE_GEN_ID_CIDADE_DE
INNER JOIN GENER_A   CIDA   ON CIDA.GENA_GEN_TGEN_ID    = CID.GEN_TGEN_ID
                           AND CIDA.GENA_GEN_EMP_ID     = CID.GEN_EMP_ID
                           AND CIDA.GENA_GEN_ID         = CID.GEN_ID
INNER JOIN GENER     UF     ON UF.GEN_TGEN_ID           = CIDA.GENA_GEN_TGEN_ID_PROPRIETARIO_
                           AND UF.GEN_EMP_ID            = CIDA.GENA_GEN_EMP_ID_PROPRIETARIO_D
                           AND UF.GEN_ID                = CIDA.GENA_GEN_ID_PROPRIETARIO_DE
INNER JOIN PEDIDO_FAT_NFE NFE  ON NFE.PEDF_PEDF_ID      = P.PEDF_ID
                               AND NFE.PEDF_PEDF_EMP_ID = P.PEDF_EMP_ID
WHERE P.PEDF_SITUACAO                            = 0
  AND NFE.PEDF_NFE_DTA_CAD                       >= TO_DATE('01/04/2023 00:00:00','DD/MM/YYYY HH24:MI:SS')
  AND NFE.PEDF_NFE_DTA_CAD                       <= TO_DATE('30/04/2023 23:59:59','DD/MM/YYYY HH24:MI:SS')
  AND P.PEDF_EMP_ID                                     = O.OPER_EMP_ID
  AND P.PEDF_OPER_ID                                    IN (88,90,990,988,913)
  AND P.PEDF_ID                                         NOT IN (SELECT T.PEDF_PEDF_ID
                                                                  FROM PEDIDO_FAT_P T
                                                                WHERE T.PEDF_PROD_ID = 52)
  AND PTP.PROT_GEN_ID = 3
    GROUP BY
 AR.GEN_DESCRICAO
,P.PEDF_GEN_ID
,GER.GEN_DESCRICAO
,P.PEDF_GEN_ID_SETOR_DE
,REP.GEN_DESCRICAO
,P.PEDF_GEN_ID_ROTA_DE
,VEN.GEN_DESCRICAO
,P.PEDF_ID
,P.PEDF_NR_NF
,P.PEDF_CLI_ID
,CL.CLI_RAZAO_SOCIAL
,CID.GEN_DESCRICAO
,UF.GEN_DESCRICAO
,EMB.GEN_ID
,EMB.GEN_DESCRICAO
,PP.PEDF_PROD_ID
,PR.PROD_DESC
,P.PEDF_DTA_EMIS
,O.OPER_GEN_ID_TP_OPERACAO_DE
,PP.MA_PEDF_VLR_TOT_DESC_BOLETO
UNION ALL

-- DEVOLUCOES ALMOXARIFADO
SELECT DISTINCT
  AL.ENTR_ENTR_ID                                      AS PEDIDO
 ,EA.ENTR_NR_DOC                                       AS NOTA_FISCAL
 ,AR.GEN_DESCRICAO                                     AS AREA
 ,P.PEDF_GEN_ID                                        AS COD_GER
 ,GER.GEN_DESCRICAO                                    AS GERENTE
 ,P.PEDF_GEN_ID_SETOR_DE                               AS COD_REP
 ,REP.GEN_DESCRICAO                                    AS REPRESENTANTE
 ,P.PEDF_GEN_ID_ROTA_DE                                AS COD_VEND
 ,VEN.GEN_DESCRICAO                                    AS VENDEDOR
 ,P.PEDF_CLI_ID                                        AS COD_CLI
 ,CL.CLI_RAZAO_SOCIAL                                  AS CLIENTE
 ,CID.GEN_DESCRICAO                                    AS CIDADE
 ,UF.GEN_DESCRICAO                                     AS UF
 ,EMB.GEN_ID                                           AS COD_EMB
 ,EMB.GEN_DESCRICAO                                    AS EMBALAGEM
 ,PP.PEDF_PROD_ID                                      AS COD_PROD
 ,PR.PROD_DESC                                         AS PRODUTO
 ,DECODE(TO_CHAR(EA.ENTR_DTA_LANC,'MM'),1,'JANEIRO'
      ,2,'FEVEREIRO',3,'MARCO',4,'ABRIL',5,'MAIO',6
      ,'JUNHO',7,'JULHO',8,'AGOSTO',9,'SETEMBRO',10
      ,'OUTUBRO',11,'NOVEMBRO',12,'DEZEMBRO')          AS MES
 ,TO_CHAR(EA.ENTR_DTA_LANC,'YYYY')                     AS ANO
 ,SUM(EE.ENTR_PRECO+ NVL(EI.ENTR_VLR_IMP,0) + NVL(EP.ENTR_VLR_IMP,0) + EE.ENTR_DESPESA)AS DEVOLUCOES
 ,SUM(EE.ENTR_QTDE)                                    AS QUANTIDADE
FROM PEDIDO_FAT P
INNER JOIN OPERACAO_FAT O        ON O.OPER_ID                  = P.PEDF_OPER_ID
INNER JOIN LIQUIDACAO LQ         ON LQ.LIQU_EMP_ID             = P.PEDF_LIQU_EMP_ID
                                AND LQ.LIQU_ID                 = P.PEDF_LIQU_ID
INNER JOIN ENTRADA_ALM_PEDIDO AL ON AL.ENTR_PEDF_EMP_ID        = P.PEDF_EMP_ID
                                AND AL.ENTR_PEDF_ID            = P.PEDF_ID
INNER JOIN ENTRADA_ALM EA        ON EA.ENTR_EMP_ID             = AL.ENTR_ENTR_EMP_ID
                                AND EA.ENTR_ID                 = AL.ENTR_ENTR_ID
INNER JOIN GENER     AR          ON AR.GEN_TGEN_ID             = P.PEDF_GEN_TGEN_ID_AREA_DE
                                AND AR.GEN_EMP_ID              = P.PEDF_GEN_EMP_ID_AREA_DE
                                AND AR.GEN_ID                  = P.PEDF_GEN_ID_AREA_DE
INNER JOIN ENTRADA_ALM_E  EE     ON EE.ENTR_ENTR_EMP_ID        = EA.ENTR_EMP_ID
                                AND EE.ENTR_ENTR_ID            = EA.ENTR_ID
LEFT JOIN ENTRADA_ALM_EI  EI    ON EI.ENTR_ENTR_E_ENTR_EMP_ID = EE.ENTR_ENTR_EMP_ID
                                AND EI.ENTR_ENTR_E_ENTR_ID     = EE.ENTR_ENTR_ID
                                AND EI.ENTR_ENTR_E_ID          = EE.ENTR_ID
                                AND EI.ENTR_TP_IMPOSTO         = 3
LEFT JOIN ENTRADA_ALM_EI  EP    ON EP.ENTR_ENTR_E_ENTR_EMP_ID = EE.ENTR_ENTR_EMP_ID
                                AND EP.ENTR_ENTR_E_ENTR_ID     = EE.ENTR_ENTR_ID
                                AND EP.ENTR_ENTR_E_ID          = EE.ENTR_ID
                                AND EP.ENTR_TP_IMPOSTO         = 2
INNER JOIN GENER     GER    ON GER.GEN_TGEN_ID                 = P.PEDF_GEN_TGEN_ID
                           AND GER.GEN_EMP_ID                  = P.PEDF_GEN_EMP_ID
                           AND GER.GEN_ID                      = P.PEDF_GEN_ID
INNER JOIN GENER     REP    ON REP.GEN_TGEN_ID                 = P.PEDF_GEN_TGEN_ID_SETOR_DE
                           AND REP.GEN_EMP_ID                  = P.PEDF_GEN_EMP_ID_SETOR_DE
                           AND REP.GEN_ID                      = P.PEDF_GEN_ID_SETOR_DE
INNER JOIN GENER     VEN    ON VEN.GEN_TGEN_ID                 = P.PEDF_GEN_TGEN_ID_ROTA_DE
                           AND VEN.GEN_EMP_ID                  = P.PEDF_GEN_EMP_ID_ROTA_DE
                           AND VEN.GEN_ID                      = P.PEDF_GEN_ID_ROTA_DE
INNER JOIN PEDIDO_FAT_P PP  ON PP.PEDF_PEDF_EMP_ID             = P.PEDF_EMP_ID
                           AND PP.PEDF_PEDF_ID                 = P.PEDF_ID
INNER JOIN PRODUTO PR       ON PR.PROD_EMP_ID                  = PP.PEDF_PROD_EMP_ID
                           AND PR.PROD_ID                      = PP.PEDF_PROD_ID
                           AND EE.ENTR_PROD_EMP_ID             = PR.PROD_EMP_ID
                           AND EE.ENTR_PROD_ID                 = PR.PROD_ID
INNER JOIN PRODUTO_TP PTP   ON PTP.PROT_PROD_EMP_ID  = PP.PEDF_PROD_EMP_ID
                           AND PTP.PROT_PROD_ID      = PP.PEDF_PROD_ID
INNER JOIN PRODUTO_C   PC   ON PC.PROC_PROD_EMP_ID             = PR.PROD_EMP_ID
                           AND PC.PROC_PROD_ID                 = PR.PROD_ID
INNER JOIN GENER    EMB     ON EMB.GEN_TGEN_ID                 = PC.PROC_GEN_TGEN_ID_EMBALAGEM_DE
                           AND EMB.GEN_EMP_ID                  = PC.PROC_GEN_EMP_ID_EMBALAGEM_DE
                           AND EMB.GEN_ID                      = PC.PROC_GEN_ID_EMBALAGEM_DE
INNER JOIN CLIENTE   CL     ON CL.CLI_EMP_ID                   = P.PEDF_CLI_EMP_ID
                           AND CL.CLI_ID                       = P.PEDF_CLI_ID
INNER JOIN CLIENTE_E  CE    ON CE.CLIE_CLI_EMP_ID              = CL.CLI_EMP_ID
                           AND CE.CLIE_CLI_ID                  = CL.CLI_ID
                           AND CE.CLIE_GEN_ID                  = 2
INNER JOIN GENER     CID    ON CID.GEN_TGEN_ID                 = CE.CLIE_GEN_TGEN_ID_CIDADE_DE
                           AND CID.GEN_EMP_ID                  = CE.CLIE_GEN_EMP_ID_CIDADE_DE
                           AND CID.GEN_ID                      = CE.CLIE_GEN_ID_CIDADE_DE
INNER JOIN GENER_A   CIDA   ON CIDA.GENA_GEN_TGEN_ID           = CID.GEN_TGEN_ID
                           AND CIDA.GENA_GEN_EMP_ID            = CID.GEN_EMP_ID
                           AND CIDA.GENA_GEN_ID                = CID.GEN_ID
INNER JOIN GENER     UF     ON UF.GEN_TGEN_ID                  = CIDA.GENA_GEN_TGEN_ID_PROPRIETARIO_
                           AND UF.GEN_EMP_ID                   = CIDA.GENA_GEN_EMP_ID_PROPRIETARIO_D
                           AND UF.GEN_ID                       = CIDA.GENA_GEN_ID_PROPRIETARIO_DE
WHERE P.PEDF_SITUACAO                         = 0
   AND   EA.ENTR_OPER_ALM_ID                  IN (19,190)
   AND EA.ENTR_DTA_LANC                       >= TO_DATE('01/04/2023 00:00:00','DD/MM/YYYY HH24:MI:SS')
   AND EA.ENTR_DTA_LANC                       <= TO_DATE('30/04/2023 23:59:59','DD/MM/YYYY HH24:MI:SS')

   AND P.PEDF_EMP_ID                          = O.OPER_EMP_ID
   AND AL.ENTR_ENTR_EMP_ID                    = 2
   AND AL.ENTR_PEDF_ID                        IS NOT NULL
   AND PTP.PROT_GEN_ID = 3
GROUP BY
    AR.GEN_DESCRICAO
   ,P.PEDF_GEN_ID
   ,GER.GEN_DESCRICAO
   ,P.PEDF_GEN_ID_SETOR_DE
   ,REP.GEN_DESCRICAO
   ,P.PEDF_GEN_ID_ROTA_DE
   ,VEN.GEN_DESCRICAO
   ,AL.ENTR_ENTR_ID
   ,EA.ENTR_NR_DOC
   ,P.PEDF_CLI_ID
   ,CL.CLI_RAZAO_SOCIAL
   ,CID.GEN_DESCRICAO
   ,UF.GEN_DESCRICAO
   ,EMB.GEN_ID
   ,EMB.GEN_DESCRICAO
   ,PP.PEDF_PROD_ID
   ,PR.PROD_DESC
   ,EA.ENTR_DTA_LANC
   ,O.OPER_GEN_ID_TP_OPERACAO_DE
    ORDER BY 1, 2