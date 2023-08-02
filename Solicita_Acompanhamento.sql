select 
       T.SOIT_SOLI_ID                              AS SOLICITA ,
       T.SOIT_ID                                   AS SEQUENCIA,
       T.SOIT_USR_ID_USUARIO_DE||' - '||U.USR_NOME AS "SOLICITANTE",
       T.SOIT_PROD_ID||' - '|| P.PROD_DESC         AS PRODUTO,
       ROUND(T.SOIT_QTDE,3)                        AS QTDE_SOLIC,
       ROUND(T.SOIT_PRC_REPOSICAO,3)               AS REPOSICAO,
       ROUND(T.SOIT_QTD_ATENDIDA,3)                AS QTDE_ATEND,
       T.SOIT_QTDE_ATENDIDA_REQ                    AS QTDE_ATEND_REQRID,
       T.SOIT_UND                                  AS UNID,
       T.SOIT_DTA_CAD                              AS "DATA CADASTRO",
       T.SOIT_USR_ID_USUARIO_ALMOX_DE||' - '|| U1.USR_NOME AS "ATENDENTE ALMOX",
       T.SOIT_SITUACAO                             AS "SITUACAO"


FROM SOLICITA_ITENS t
              ,PRODUTO P
              ,USUARIO U
              ,USUARIO U1
WHERE T.SOIT_PROD_ID = P.PROD_ID AND T.SOIT_SOLI_EMP_ID = P.PROD_EMP_ID
AND T.SOIT_USR_ID_USUARIO_DE = U.USR_ID
AND T.SOIT_USR_ID_USUARIO_ALMOX_DE = U1.USR_ID
AND T.SOIT_PROD_ID = 717
AND T.SOIT_DTA_CAD BETWEEN '01/05/2023' AND '31/05/2023'
ORDER BY T.SOIT_SOLI_ID
--AND T.SOIT_SOLI_ID IN (48510, 48511)
