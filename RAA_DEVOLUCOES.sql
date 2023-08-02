CREATE OR REPLACE VIEW RAA_DEVOLUCOES AS
SELECT
     NVL(EAP.ENTR_GEN_ID_MOTIVO,'0')||' - '||MTV.GEN_DESCRICAO  AS "Motivo",
     EA.ENTR_ID                                                 AS "Lancamento",
     EA.ENTR_DTA_EMIS                                           AS "Data Emissao",
     EA.ENTR_NR_DOC                                             AS "NFe Dev",
     EA.ENTR_DTA_CAD                                            AS "Data Cadastro Sistema",
     PF.PEDF_CLI_ID||' - '||C.CLI_RAZAO_SOCIAL                  AS "Cliente",
     EA.ENTR_OPER_ALM_ID||' - '||OA.OPER_DESC                   AS "Operação Entrada",
     ROUND(EA.ENTR_VLR_TOTAL,2)                                 AS "Total da Nota",
     ROUND(SUM(EAE.ENTR_PRECO),2)                               AS "Valor dos Produtos",
     ROUND(SUM(EAE.ENTR_QTDE))                                  AS "Qtd",
     PF.PEDF_NR_NF                                              AS "Nota Origem",
     PF.PEDF_DTA_EMIS                                           AS "Emissão Nota Venda",
     ROUND(PF.PEDF_VLR_TOT_PED,2)                               AS "Valor Venda",
     RT.PROP_ID_3||' - '||RT.DESC_PROP_3                        AS "Distrito",
     RT.PROP_ID_2||' - '||RT.DESC_PROP_2                        AS "Setor",
     RT.PROP_ID_1||' - '||RT.DESC_PROP_1                        AS "Rota"
     
     
FROM ENTRADA_ALM EA
JOIN ENTRADA_ALM_PEDIDO EAP ON EA.ENTR_ID = EAP.ENTR_ENTR_ID
JOIN ENTRADA_ALM_E EAE ON EA.ENTR_ID = EAE.ENTR_ENTR_ID
JOIN PEDIDO_FAT PF ON EAP.ENTR_PEDF_ID = PF.PEDF_ID
JOIN GENER MTV  ON EAP.ENTR_GEN_TGEN_ID_MOTIVO = MTV.GEN_TGEN_ID AND EAP.ENTR_GEN_EMP_ID_MOTIVO = MTV.GEN_EMP_ID AND EAP.ENTR_GEN_ID_MOTIVO = MTV.GEN_ID
JOIN CLIENTE C  ON PF.PEDF_CLI_EMP_ID = C.CLI_EMP_ID AND PF.PEDF_CLI_ID = C.CLI_ID
JOIN OPERACAO_ALM OA ON EA.ENTR_OPER_ALM_EMP_ID = OA.OPER_EMP_ID AND EA.ENTR_OPER_ALM_ID = OA.OPER_ID
JOIN GENER$V RT ON PF.PEDF_GEN_EMP_ID_ROTA_DE = RT.GEN_EMP_ID AND PF.PEDF_GEN_TGEN_ID_ROTA_DE = RT.GEN_TGEN_ID AND PF.PEDF_GEN_ID_ROTA_DE = RT.GEN_ID

WHERE EA.ENTR_OPER_ALM_ID IN (19,190)
AND EA.ENTR_DTA_CAD BETWEEN TO_DATE('01/07/2023', 'DD/MM/YYYY') AND SYSDATE
--AND TO_DATE('01/07/2023', 'DD/MM/YYYY')
GROUP BY 
      EA.ENTR_NR_DOC,                             EA.ENTR_ID, 
      EA.ENTR_FORN_ID,                            EA.ENTR_OPER_ALM_ID,                        
      MTV.GEN_DESCRICAO,                          NVL(EAP.ENTR_GEN_ID_MOTIVO,'0'), 
      EA.ENTR_VLR_TOTAL,                          PF.PEDF_NR_NF,
      C.CLI_RAZAO_SOCIAL,                         OA.OPER_DESC,
      EA.ENTR_DTA_CAD,                            EA.ENTR_DTA_EMIS,
      PF.PEDF_VLR_TOT_PED,                        PF.PEDF_CLI_ID,
      PF.PEDF_DTA_EMIS,                           PF.PEDF_GEN_ID_ROTA_DE,
      RT.PROP_ID_3,                               RT.DESC_PROP_3,
      RT.DESC_PROP_1,                             RT.DESC_PROP_2,
      RT.PROP_ID_1,                               RT.PROP_ID_2

UNION ALL

SELECT 
    PF.PEDF_OBS                                 AS "Motivo",
    PF.PEDF_ID                                  AS "Lancamento",
    PF.PEDF_DTA_EMIS                            AS "Data Emissao",
    PF.PEDF_NR_NF                               AS "NFe Dev",
    PF.PEDF_DTA_CAD                             AS "Data Cadastro Sistema",
    PF.PEDF_CLI_ID||' - '||C.CLI_RAZAO_SOCIAL   AS "Cliente",
    PF.PEDF_OPER_ID||' - '||OPF.OPER_DESC       AS "Operacao",
    ROUND(PF.PEDF_VLR_TOT_PED,2)                AS "Total da Nota",
    ROUND(SUM(PFP.PEDF_VLR_TOT),2)              AS "Valor dos Produtos",
    SUM(PFP.PEDF_QTDE)                          AS "Qtde",
    DEV.PEDF_NR_NF                              AS "NFe Origem",
    DEV.PEDF_DTA_EMIS                           AS "Emissao Nota Venda",
    ROUND(DEV.PEDF_VLR_TOT_PED,2)               AS "Valor Venda",
    RT.PROP_ID_3||' - '||RT.DESC_PROP_3         AS "Distrito",
    RT.PROP_ID_2||' - '||RT.DESC_PROP_2         AS "Setor",
    RT.PROP_ID_1||' - '||RT.DESC_PROP_1         AS "Rota"    

FROM PEDIDO_FAT PF
JOIN PEDIDO_FAT_P PFP ON PF.PEDF_EMP_ID = PFP.PEDF_PEDF_EMP_ID AND PF.PEDF_ID = PFP.PEDF_PEDF_ID
JOIN CLIENTE      C   ON PF.PEDF_CLI_EMP_ID = C.CLI_EMP_ID AND PF.PEDF_CLI_ID = C.CLI_ID
JOIN OPERACAO_FAT OPF ON PF.PEDF_OPER_EMP_ID = OPF.OPER_EMP_ID AND PF.PEDF_OPER_ID = OPF.OPER_ID
JOIN PEDIDO_FAT DEV   ON PF.Pedf_Id_Devol = DEV.PEDF_ID
JOIN GENER$V    RT    ON DEV.PEDF_GEN_EMP_ID_ROTA_DE = RT.GEN_EMP_ID AND DEV.PEDF_GEN_TGEN_ID_ROTA_DE = RT.GEN_TGEN_ID AND DEV.PEDF_GEN_ID_ROTA_DE = RT.GEN_ID
WHERE PF.PEDF_OBS IS NOT NULL
AND   PF.PEDF_DTA_EMIS >= '01/07/2023'
AND   PF.PEDF_OPER_ID IN (88,90)
AND   PF.PEDF_SITUACAO NOT IN (1)
GROUP BY
      PF.PEDF_OBS,                                   PF.PEDF_ID,
      PF.PEDF_DTA_EMIS,                              PF.PEDF_NR_NF,
      PF.PEDF_CLI_ID,                                PF.PEDF_OPER_ID,
      PF.PEDF_VLR_TOT_PED,                           PF.PEDF_DTA_CAD,
      C.CLI_RAZAO_SOCIAL,                            OPF.OPER_DESC,
      DEV.PEDF_NR_NF,                                DEV.PEDF_VLR_TOT_PED,
      DEV.PEDF_DTA_EMIS,                             RT.PROP_ID_1,RT.DESC_PROP_1,
      RT.PROP_ID_2,RT.DESC_PROP_2,                   RT.PROP_ID_3,RT.DESC_PROP_3
