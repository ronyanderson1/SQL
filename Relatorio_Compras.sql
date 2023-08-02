SELECT      ENT.ENTR_EMP_ID                     AS ID_EMPRESA
            ,ENT.ENTR_DTA_EMIS                   AS EMISSAO_NFE
            ,ENT.ENTR_NR_DOC                     AS NFE
            ,ENT.ENTR_CHAVE_NFE                  AS CHAVE_XML 
            ,ENT.ENTR_ID                         AS N_LANC
            ,ENT.ENTR_OPER_ALM_ID                AS NAT_OPERACAO
            ,OAL.OPER_DESC                       AS DESC_OPERACAO
            ,ENT.ENTR_FORN_ID                    AS ID_FORNEC
            ,F.FORN_RAZAO                        AS FORNECEDOR
            ,ENT.ENTR_DTA_LANC
            ,ENT.ENTR_DTA_CAD                    AS DTA_CAD
            ,EE.ENTR_PROD_ID                     AS ID_PRODUTO
            ,P.PROD_DESC                         AS DESC_PRODUTO
            ,EE.ENTR_QTDE                        AS QTDE
            ,EE.ENTR_PRECO                       AS PRECO
            ,P.PROD_SITUACAO                     AS SITUACAO
            ,P.PROD_GEN_ID_GRP_DESP              AS GRUPO_DESPESA
            ,PAL.PROA_GEN_ID                     AS ID_SUBGRUPO

            
FROM
            ENTRADA_ALM ENT INNER JOIN          ENTRADA_ALM_E EE ON   ENT.ENTR_EMP_ID = EE.ENTR_ENTR_EMP_ID AND ENT.ENTR_ID = EE.ENTR_ENTR_ID
                            INNER JOIN          PRODUTO P        ON   P.PROD_ID = EE.ENTR_PROD_ID           AND P.PROD_EMP_ID = EE.ENTR_ENTR_EMP_ID
                            INNER JOIN          PRODUTO_AL PAL   ON   P.PROD_EMP_ID = PAL.PROA_PROD_EMP_ID  AND P.PROD_ID = PAL.PROA_PROD_ID
                            INNER JOIN          OPERACAO_ALM OAL ON   ENT.ENTR_EMP_ID = OAL.OPER_EMP_ID     AND ENT.ENTR_OPER_ALM_ID = OAL.OPER_ID
--                          INNER JOIN          KARDEX KAD       ON   ENT.ENTR_EMP_ID = KAD.KDEX_EMP_ID     AND ENT.ENTR_ID = KAD.KDEX_ENTR_ENTR_ID
                            INNER JOIN          FORNECEDOR F     ON   ENT.ENTR_FORN_ID = F.FORN_ID

WHERE P.PROD_SITUACAO = 'H'
--AND WHERE ENT.ENTR_ID = 139929
--AND ENT.ENTR_DTA_EMIS >= '01/06/2022'
AND EE.ENTR_PROD_ID in (7411, 7412, 7404, 7405, 7406, 7407, 6854, 6855, 6872, 7808)

