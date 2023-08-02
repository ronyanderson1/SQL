SELECT      ENT.ENTR_EMP_ID                     AS ID_EMPRESA, 
            ENT.ENTR_ID                         AS N_LANC, 
            ENT.ENTR_OPER_ALM_ID                AS NAT_OPERACAO,
            ENT.ENTR_FORN_ID                    AS ID_FORNEC,
            ENT.ENTR_NR_DOC                     AS NFE,
            ENT.ENTR_DTA_EMIS                   AS EMISSAO_NFE,
            ENT.ENTR_DTA_LANC,
            ENT.ENTR_DTA_CAD                    AS DTA_CAD,
            EE.ENTR_PROD_ID                     AS ID_PRODUTO,
            P.PROD_DESC                         AS DESC_PRODUTO,
            EE.ENTR_QTDE                        AS QTDE,
            EE.ENTR_PRECO                       AS PRECO,
            P.PROD_SITUACAO                     AS SITUACAO,
            P.PROD_GEN_ID_GRP_DESP              AS GRUPO_DESPESA
FROM
            ENTRADA_ALM ENT INNER JOIN          ENTRADA_ALM_E EE ON   ENT.ENTR_EMP_ID = EE.ENTR_ENTR_EMP_ID AND ENT.ENTR_ID = EE.ENTR_ENTR_ID
                            INNER JOIN          PRODUTO P        ON   P.PROD_ID = EE.ENTR_PROD_ID           AND P.PROD_EMP_ID = EE.ENTR_ENTR_EMP_ID
                            INNER JOIN          PRODUTO_AL PAL   ON   P.PROD_EMP_ID = PAL.PROA_PROD_EMP_ID  AND P.PROD_ID = PAL.PROA_PROD_ID

WHERE ENT.ENTR_ID = 139929
