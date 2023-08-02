CREATE OR REPLACE VIEW VIEW_AUDITORIA_CONTABIL_FABIO AS
SELECT distinct
DECODE(MOVC_PROCEDENCIA,0,'MANUAL'
                              ,1,'FATURAMENTO'
                              ,2,'FOLHA DE PAGAMENTO'
                              ,3,'CUSTOS'
                              ,4,'PATRIMONIAL'
                              ,5,'ENTR. DESPESAS'
                              ,6,'ORCAMENTO'
                              ,7,'CAIXA E BANCOS'
                              ,8,'ALMOXARIFADO'
                              ,9,'TRANSF. RESULTADO'
                              ,10,'APROP. DAS DESPESAS'
                              ,11,'MOV. MATERIAIS'
                              ,12,'ESTOQ. CONSIGNADO'
                              ,13,'FRETE'
                              ,14,'DEV. FORNECEDOR') PROCEDENCIA
      ,TRIM(RPAD(TO_CHAR(DECODE(MOVC_NR_NF, NULL, EA.ENTR_NR_DOC, MOVC_NR_NF),'000000000000000')||'/'||DECODE(MOVC_NR_NF, NULL, EA.ENTR_SERIE, MOVC_NR_SERIE),20)) DOCUMENTO
      ,MOV.LANC LANCAMENTO
      ,MOV.EMP EMPRESA
      ,TO_DATE(MOV.DATA, 'DD/MM/YYYY') DATA
      ,TO_CHAR(MOV.DATA, 'DD') DIA
      ,TO_CHAR(MOV.DATA, 'MM') MES
      ,TO_CHAR(MOV.DATA, 'YYYY') ANO
      ,CTA.PCTA_REF   REFERENCIA
      ,CTA.PCTA_CONTA CONTA
      ,CTA.PCTA_DESC  DESC_CONTA
      ,GRP.GEN_ID        COD_GRP_DESP
      ,GRP.GEN_DESCRICAO GRUPO_DESPESAS
      ,HISTORICO COD_HISTORICO
      ,RPAD(HST.GEN_DESCRICAO,35) HISTORICO
      ,RPad(Nvl(HC, ' '),60) As COMPLEMENTO

      ,DECODE(MOVC_TIPO,'D','DEBITO','C','CREDITO') TIPO
      ,MOV.DEBITO  VLR_DEBITO
      ,MOV.CREDITO VLR_CREDITO
      ,MOV.MOVC_PCTA_REF_CONTA_CTB_CONTRA REF_CP
      ,MOV.MOVC_PCTA_CONTA_CONTA_CTB_CONT CONT_CP
      ,CTA_CP.PCTA_DESC DESC_CTRA_PART
      ,MOV.MOVC_EMP_ID_EMPRESA_CONTRA_PAR EMPRESA_CP
      ,DECODE(MOVC_NR_NF, NULL, EA.ENTR_NR_DOC, MOVC_NR_NF) MOVC_NR_NF
      ,U.USR_NOME  USUARIO
      ,DECODE(F.FORN_RAZAO, NULL, C.CLI_RAZAO_SOCIAL, F.FORN_RAZAO) RAZAO_SOCIAL
  FROM (
        (
      Select
             MOVC_EMP_ID                                EMP
            ,MOVC_PCTA_REF                              REF
            ,MOVC_PCTA_CONTA                            CONTA
            ,MOVC_EMP_ID_EMPRESA_CONTRA_PAR             EMP_CP
            ,MOVC_PCTA_REF_CONTA_CTB_CONTRA             REF_CP
            ,MOVC_PCTA_GEN_ID
            ,MOVC_PCTA_GEN_TGEN_ID
            ,MOVC_PCTA_GEN_EMP_ID
            ,MOVC_GEN_TGEN_ID
            ,MOVC_GEN_EMP_ID
            ,MOVC_GEN_ID
            ,MOVC_DATA                                  DATA
            ,To_Char(MOVC_DATA, 'MM/RRRR')              MES_ANO
            ,MOVC_PROCEDENCIA                           PROC
            ,MOVC_NR_LANCAM                             LANC
            ,MOVC_HC_COMPL                              HC
            ,MOVC_GEN_ID                                HISTORICO
            ,(MOVC_PROCEDENCIA || '/' ||MOVC_NR_LANCAM) PROC_LANC
            ,MOVC_USR_ID
            ,M.MOVC_GEN_ID_GRP_DESP_DE      GRUPO_DESP
            ,M.MOVC_GEN_TGEN_ID_GRP_DESP_DE GRUPO_DESP_TGEN
            ,M.MOVC_GEN_EMP_ID_GRP_DESP_DE  GRUPO_DESP_EMP
            ,MOVC_ENTR_C_ENTR_EMP_ID
            ,MOVC_ENTR_C_ENTR_ID
            ,MOVC_NR_NF
            ,M.MOVC_NR_SERIE
            ,MOVC_PROCEDENCIA
            ,MOVC_TIPO
            ,M.MOVC_PCTA_REF_CONTA_CTB_CONTRA
            ,M.MOVC_PCTA_CONTA_CONTA_CTB_CONT
            ,M.MOVC_PCTA_GEN_TGEN_ID_CONTA_CT
            ,M.MOVC_PCTA_GEN_EMP_ID_CONTA_CTB
            ,M.MOVC_PCTA_GEN_ID_CONTA_CTB_CON
            ,M.MOVC_EMP_ID_EMPRESA_CONTRA_PAR
            ,DECODE(MOVC_TIPO,'D',ROUND(MOVC_VALOR,2))           DEBITO
            ,DECODE(MOVC_TIPO,'C',ROUND(MOVC_VALOR,2))           CREDITO

           From
             MOV_CONTAB M
           Where
                 (MOVC_EMP_ID = (SELECT MA_BUSCA_STR((SELECT PAR_EMPRESAS_VIEW_EXCEL FROM MA_PARAMETROS WHERE PAR_EMP_ID = 2), 1, ',') FROM DUAL) OR
                  MOVC_EMP_ID = (SELECT MA_BUSCA_STR((SELECT PAR_EMPRESAS_VIEW_EXCEL FROM MA_PARAMETROS WHERE PAR_EMP_ID = 2), 2, ',') FROM DUAL) OR
                  MOVC_EMP_ID = (SELECT MA_BUSCA_STR((SELECT PAR_EMPRESAS_VIEW_EXCEL FROM MA_PARAMETROS WHERE PAR_EMP_ID = 2), 3, ',') FROM DUAL) OR
                  MOVC_EMP_ID = (SELECT MA_BUSCA_STR((SELECT PAR_EMPRESAS_VIEW_EXCEL FROM MA_PARAMETROS WHERE PAR_EMP_ID = 2), 4, ',') FROM DUAL))
--                 m.movc_emp_id                  in (2,3,4)
--             And Trunc(MOVC_DATA)               >= To_Date('01/01/2021')
--             And Trunc(MOVC_DATA)               <= To_Date('31/07/2021')
             AND TRUNC(MOVC_DATA) >= TO_DATE((SELECT PAR_DATA_INI_VIEW_EXCEL FROM MA_PARAMETROS WHERE PAR_EMP_ID = 2), 'DD/MM/RRRR')
             AND TRUNC(MOVC_DATA) <= TO_DATE((SELECT PAR_DATA_FIM_VIEW_EXCEL FROM MA_PARAMETROS WHERE PAR_EMP_ID = 2), 'DD/MM/RRRR')
          --   And MOVC_PCTA_REF                  = &CONTA_REF
        )
        Union All
        ------------------------------
        --------Contra Partida--------
        ------------------------------
        (
           Select
             Decode(MOVC_EMP_ID_EMPRESA_CONTRA_PAR, Null, MOVC_EMP_ID, MOVC_EMP_ID_EMPRESA_CONTRA_PAR) EMP
            ,MOVC_PCTA_REF_CONTA_CTB_CONTRA                                                            REF
            ,MOVC_PCTA_CONTA_CONTA_CTB_CONT                                                            CONTA
            ,MOVC_EMP_ID                                                                               EMP_CP
            ,MOVC_PCTA_REF                                                                             REF_CP
            ,MOVC_PCTA_GEN_ID_CONTA_CTB_CON                                                            MOVC_PCTA_GEN_ID
            ,MOVC_PCTA_GEN_TGEN_ID_CONTA_CT                                                            MOVC_PCTA_GEN_TGEN_ID
            ,MOVC_PCTA_GEN_EMP_ID_CONTA_CTB                                                            MOVC_PCTA_GEN_EMP_ID
            ,MOVC_GEN_TGEN_ID
            ,MOVC_GEN_EMP_ID
            ,MOVC_GEN_ID
            ,MOVC_DATA                                                                                 DATA
            ,To_Char(MOVC_DATA, 'MM/YYYY')                                                             MES_ANO
            ,MOVC_PROCEDENCIA                                                                          PROC
            ,MOVC_NR_LANCAM                                                                            LANC
            ,MOVC_HC_COMPL                                                                             HC
            ,MOVC_GEN_ID                                                                               HISTORICO
            ,(MOVC_PROCEDENCIA || '/' ||MOVC_NR_LANCAM)                                                PROC_LANC
            ,MOVC_USR_ID
            ,M.MOVC_GEN_ID_GRP_DESP_CP                    GRUPO_DESP
            ,M.MOVC_GEN_TGEN_ID_GRP_DESP_CP               GRUPO_DESP_TGEN
            ,M.MOVC_GEN_EMP_ID_GRP_DESP_CP                GRUPO_DESP_EMP
            ,MOVC_ENTR_C_ENTR_EMP_ID
            ,MOVC_ENTR_C_ENTR_ID
            ,MOVC_NR_NF
            ,M.MOVC_NR_SERIE
            ,MOVC_PROCEDENCIA
            ,MOVC_TIPO
            ,M.MOVC_PCTA_REF_CONTA_CTB_CONTRA
            ,M.MOVC_PCTA_CONTA_CONTA_CTB_CONT
            ,M.MOVC_PCTA_GEN_TGEN_ID_CONTA_CT
            ,M.MOVC_PCTA_GEN_EMP_ID_CONTA_CTB
            ,M.MOVC_PCTA_GEN_ID_CONTA_CTB_CON
            ,M.MOVC_EMP_ID_EMPRESA_CONTRA_PAR
            ,Decode(MOVC_TIPO,'C',ROUND(MOVC_VALOR,2))                                                          DEBITO
            ,Decode(MOVC_TIPO,'D',ROUND(MOVC_VALOR,2))                                                          CREDITO
           From
             MOV_CONTAB M
           Where
--                 (MOVC_EMP_ID = (SELECT MA_BUSCA_STR((SELECT PAR_EMPRESAS_VIEW_EXCEL FROM MA_PARAMETROS WHERE PAR_EMP_ID = 2), 1, ',') FROM DUAL) OR
--                  MOVC_EMP_ID = (SELECT MA_BUSCA_STR((SELECT PAR_EMPRESAS_VIEW_EXCEL FROM MA_PARAMETROS WHERE PAR_EMP_ID = 2), 2, ',') FROM DUAL) OR
--                  MOVC_EMP_ID = (SELECT MA_BUSCA_STR((SELECT PAR_EMPRESAS_VIEW_EXCEL FROM MA_PARAMETROS WHERE PAR_EMP_ID = 2), 3, ',') FROM DUAL) OR
--                  MOVC_EMP_ID = (SELECT MA_BUSCA_STR((SELECT PAR_EMPRESAS_VIEW_EXCEL FROM MA_PARAMETROS WHERE PAR_EMP_ID = 2), 4, ',') FROM DUAL))
                 M.MOVC_EMP_ID                  IN (2,3,4)
             And Trunc(MOVC_DATA)               >= To_Date('01/01/2021')
             And Trunc(MOVC_DATA)               <= To_Date('31/07/2021')
--             AND TRUNC(MOVC_DATA) >= TO_DATE((SELECT PAR_DATA_INI_VIEW_EXCEL FROM MA_PARAMETROS WHERE PAR_EMP_ID = 2), 'DD/MM/YYYY')
--             AND TRUNC(MOVC_DATA) <= TO_DATE((SELECT PAR_DATA_FIM_VIEW_EXCEL FROM MA_PARAMETROS WHERE PAR_EMP_ID = 2), 'DD/MM/YYYY')
             And MOVC_PCTA_REF_CONTA_CTB_CONTRA Is Not Null
          --   And MOVC_PCTA_REF_CONTA_CTB_CONTRA = &CONTA_REF
        )
      )          MOV
     ,PLANO_CTAS CTA
     ,PLANO_CTAS CTA_CP
     ,GENER      HST
     ,USUARIO    U
     ,ENTRADA_ALM EA
     ,GENER      GRP
     ,PEDIDO_FAT FAT
     ,FORNECEDOR F
     ,CLIENTE    C
 WHERE
       CTA.PCTA_GEN_TGEN_ID      = MOV.MOVC_PCTA_GEN_TGEN_ID
   AND CTA.PCTA_GEN_EMP_ID       = MOV.MOVC_PCTA_GEN_EMP_ID
   AND CTA.PCTA_GEN_ID           = MOV.MOVC_PCTA_GEN_ID
   AND CTA.PCTA_REF              = MOV.REF
   AND CTA.PCTA_CONTA            = MOV.CONTA
   AND CTA_CP.PCTA_GEN_TGEN_ID  (+) = MOV.MOVC_PCTA_GEN_TGEN_ID_CONTA_CT
   AND CTA_CP.PCTA_GEN_EMP_ID   (+) = MOV.MOVC_PCTA_GEN_EMP_ID_CONTA_CTB
   AND CTA_CP.PCTA_GEN_ID       (+) = MOV.MOVC_PCTA_GEN_ID_CONTA_CTB_CON
   AND CTA_CP.PCTA_REF          (+) = MOV.MOVC_PCTA_REF_CONTA_CTB_CONTRA
   AND CTA_CP.PCTA_CONTA        (+) = MOV.MOVC_PCTA_CONTA_CONTA_CTB_CONT
   AND HST.GEN_TGEN_ID      (+)  = MOV.MOVC_GEN_TGEN_ID
   AND HST.GEN_EMP_ID       (+)  = MOV.MOVC_GEN_EMP_ID
   AND HST.GEN_ID           (+)  = MOV.MOVC_GEN_ID
   AND MOV.GRUPO_DESP            = GRP.GEN_ID      (+)
   AND MOV.GRUPO_DESP_TGEN       = GRP.GEN_TGEN_ID (+)
   AND MOV.GRUPO_DESP_EMP        = GRP.GEN_EMP_ID  (+)
   AND U.USR_ID                  = MOVC_USR_ID
   AND EA.ENTR_EMP_ID        (+) = MOVC_ENTR_C_ENTR_EMP_ID
   AND EA.ENTR_ID            (+) = MOVC_ENTR_C_ENTR_ID
   AND EA.ENTR_FORN_ID           = F.FORN_ID     (+)
   AND MOVC_NR_NF                = FAT.PEDF_NR_NF     (+)
   AND MOVC_NR_SERIE = FAT.PEDF_SERIE_NF  (+)
   AND EMP           = FAT.PEDF_EMP_ID    (+)
   AND FAT.PEDF_CLI_ID     = C.CLI_ID     (+)
   AND FAT.PEDF_CLI_EMP_ID = C.CLI_EMP_ID (+)

ORDER BY
      DATA
;
