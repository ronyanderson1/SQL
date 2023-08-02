SELECT DISTINCT
       PF.PEDF_GEN_ID_MOT_ENTR_DE||' - '||DEV.GEN_DESCRICAO       AS "Operação", 
       PF.PEDF_CLI_ID||' - '||C.CLI_RAZAO_SOCIAL                  AS "Cliente",
       PF.PEDF_DTA_EMIS                                           AS "Emissão NFE Devolução",
       PF.PEDF_DTA_CAD                                            AS "Lançamento",
       PF.PEDF_NR_NF                                              AS "NFe Devolução",
       NVL(PF.PEDF_OBS,'NAO INFORMADO')                           AS "Motivo Devolução",
       PP.PEDF_PROD_ID||' - '||PR.PROD_DESC                       AS "Produto",
       ROUND(PP.PEDF_QTDE)                                        AS "Qtde Devolv",
       PP.PEDF_VLR_TOT + NVL(PP.PEDF_VLR_IPI,0)+NVL(PP.PEDF_VLR_SUBS,0) AS "Vlr Total",
       P.PEDF_NR_NF                                               AS "NFe Origem",
       P.PEDF_DTA_EMIS                                            AS "Emissão Nota Venda",
     

       U.USR_NOME                                                 AS "Usuário",
       ROTA.GEN_DESCRICAO                                         AS "Vendedor",
       ROTA.DESC_PROP_2                                           AS "Distrito",
       ROTA.DESC_PROP_3                                           AS "Regional"
       
FROM PEDIDO_FAT PF
INNER JOIN GENER DEV ON PF.PEDF_GEN_TGEN_ID_MOT_ENTR_DE = DEV.GEN_TGEN_ID AND PF.PEDF_GEN_EMP_ID_MOT_ENTR_DE = DEV.GEN_EMP_ID AND PF.PEDF_GEN_ID_MOT_ENTR_DE = DEV.GEN_ID
INNER JOIN CLIENTE C ON PF.PEDF_CLI_ID = C.CLI_ID AND PF.PEDF_CLI_EMP_ID = C.CLI_EMP_ID
INNER JOIN PEDIDO_FAT_PEDIDO_DEV DV ON DV.PEDF_PEDF_EMP_ID = PF.PEDF_EMP_ID AND DV.PEDF_PEDF_ID = PF.PEDF_ID
INNER JOIN PEDIDO_FAT P ON DV.PEDF_PEDF_EMP_ID_DEVOL = P.PEDF_EMP_ID AND DV.PEDF_PEDF_ID_DEVOL = P.PEDF_ID
INNER JOIN PEDIDO_FAT_P PP ON PF.PEDF_EMP_ID = PP.PEDF_PEDF_EMP_ID AND PF.PEDF_ID = PP.PEDF_PEDF_ID
INNER JOIN PRODUTO PR   ON PP.PEDF_PROD_EMP_ID = PR.PROD_EMP_ID AND PP.PEDF_PROD_ID = PR.PROD_ID
INNER JOIN USUARIO U    ON PF.PEDF_USR_ID = U.USR_ID
INNER JOIN GENER$V ROTA ON P.PEDF_GEN_TGEN_ID_ROTA_DE = ROTA.GEN_TGEN_ID AND P.PEDF_GEN_EMP_ID_ROTA_DE = ROTA.GEN_EMP_ID AND P.PEDF_GEN_ID_ROTA_DE = ROTA.GEN_ID
RIGHT JOIN PEDIDO_FAT_P PFP ON P.PEDF_EMP_ID = PFP.PEDF_PEDF_EMP_ID AND P.PEDF_ID = PFP.PEDF_PEDF_ID
WHERE PF.PEDF_GEN_ID_MOT_ENTR_DE IS NOT NULL
AND pf.pedf_dta_emis >= '01/01/2023'
--PF.PEDF_NR_NF = 173440
AND PF.PEDF_EMP_ID = 2



