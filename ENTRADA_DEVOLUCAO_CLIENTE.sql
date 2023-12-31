SELECT EA.ENTR_ID                 AS LANCAMENTO,
       EA.ENTR_NR_DOC             AS NFE,
       EA.ENTR_DTA_EMIS           AS EMISSAO_NFE,
       EA.ENTR_OPER_ALM_ID        AS ID_OPER,
       OP.OPER_DESC               AS OP_ENTRADA, 
       EP.ENTR_GEN_ID_MOTIVO      AS ID_MTV,
       MV.GEN_DESCRICAO           AS MOTIVO,
       EA.ENTR_FORN_ID            AS ID_FORN,
       F.FORN_RAZAO               AS RAZAO_SOCIAL,
       EA.ENTR_DTA_LANC           AS DATA_CADASTRO,
       EE.ENTR_PROD_ID            AS ID_PRODUTO,
       P.PROD_DESC                AS PRODUTO,
       EE.ENTR_QTDE               AS QTD,
       EE.ENTR_PRECO              AS TOTAL_PRODUTO,
       EP.ENTR_PEDF_ID            AS PEDIDO_ORIGEM,
       PF.PEDF_NR_NF              AS NFE_ORIGEM,
       PF.PEDF_DTA_EMIS           AS DATA_EMISSAO_NFE

FROM   ENTRADA_ALM EA
INNER JOIN ENTRADA_ALM_PEDIDO EP ON EA.ENTR_EMP_ID = EP.ENTR_ENTR_EMP_ID AND EA.ENTR_ID = EP.ENTR_ENTR_ID
INNER JOIN FORNECEDOR F          ON F.FORN_ID = EA.ENTR_FORN_ID
INNER JOIN GENER MV              ON EP.ENTR_GEN_TGEN_ID_MOTIVO = MV.GEN_TGEN_ID AND EP.ENTR_GEN_EMP_ID_MOTIVO = MV.GEN_EMP_ID AND EP.ENTR_GEN_ID_MOTIVO = MV.GEN_ID
INNER JOIN OPERACAO_ALM OP       ON EA.ENTR_OPER_ALM_EMP_ID = OP.OPER_EMP_ID AND EA.ENTR_OPER_ALM_ID = OP.OPER_ID
INNER JOIN ENTRADA_ALM_E EE      ON EA.ENTR_EMP_ID = EE.ENTR_ENTR_EMP_ID AND EA.ENTR_ID = EE.ENTR_ENTR_ID
INNER JOIN PRODUTO P             ON EE.ENTR_ENTR_EMP_ID = P.PROD_EMP_ID AND EE.ENTR_PROD_ID = P.PROD_ID
INNER JOIN PEDIDO_FAT PF         ON EP.ENTR_ENTR_EMP_ID = PF.PEDF_EMP_ID AND EP.ENTR_PEDF_ID = PF.PEDF_ID

WHERE EA.ENTR_OPER_ALM_ID = 19
AND   EP.ENTR_GEN_ID_MOTIVO = 35
AND   EA.ENTR_DTA_LANC >= '01/01/2022'
--AND   EA.ENTR_ID = 141251

ORDER BY 3
