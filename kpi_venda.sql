SELECT 
       RPAD(DI.GEN_DESCRICAO,20)                       GERENTE
      ,RPAD(ST.GEN_DESCRICAO,30)                       REPRESENTANTE
      ,RPAD(RT.GEN_DESCRICAO,30)                       VENDEDOR
      ,P.PEDF_CLI_ID                                   COD_CLIENTE
      ,RPAD(C.CLI_RAZAO_SOCIAL,35)                     CLIENTE
      ,to_char(C.CLI_DTA_CAD,'dd/mm/yyyy')             DATA_CADASTRO
      ,RPAD(CAD.GEN_DESCRICAO,25)                      CADEIA
      ,P.PEDF_ID                                       PEDIDO
      ,P.PEDF_NR_NF                                    NOTA_FISCAL
      ,to_char(P.PEDF_DTA_EMIS,'DD/MM/YYYY')           DATA_EMISSAO
      ,P.PEDF_VLR_TOT_PED                              VALOR_PEDIDO
 FROM 
      PEDIDO_FAT           P
     ,CLIENTE              C
     ,GENER                RT
     ,GENER                ST
     ,GENER                DI 
     ,OPERACAO_FAT         OP
     ,GENER                CAD
 WHERE 
       P.PEDF_EMP_ID                      = 2
   AND P.PEDF_CLI_EMP_ID                  = C.CLI_EMP_ID  
   AND P.PEDF_CLI_ID                      = C.CLI_ID
   AND P.PEDF_GEN_TGEN_ID                 = DI.GEN_TGEN_ID
   AND P.PEDF_GEN_EMP_ID                  = DI.GEN_EMP_ID
   AND P.PEDF_GEN_ID                      = DI.GEN_ID
   AND P.PEDF_GEN_TGEN_ID_SETOR_DE        = ST.GEN_TGEN_ID
   AND P.PEDF_GEN_EMP_ID_SETOR_DE         = ST.GEN_EMP_ID
   AND P.PEDF_GEN_ID_SETOR_DE             = ST.GEN_ID
   AND P.PEDF_GEN_TGEN_ID_ROTA_DE         = RT.GEN_TGEN_ID
   AND P.PEDF_GEN_EMP_ID_ROTA_DE          = RT.GEN_EMP_ID
   AND P.PEDF_GEN_ID_ROTA_DE              = RT.GEN_ID
   AND C.CLI_GEN_TGEN_ID_CADEIA_DE        = CAD.GEN_TGEN_ID
   AND C.CLI_GEN_EMP_ID_CADEIA_DE         = CAD.GEN_EMP_ID
   AND C.CLI_GEN_ID_CADEIA_DE             = CAD.GEN_ID
   AND P.PEDF_OPER_EMP_ID                 = OP.OPER_EMP_ID
   AND P.PEDF_OPER_ID                     = OP.OPER_ID
   AND OP.OPER_GEN_ID_TP_OPERACAO_DE      = 1
   AND P.PEDF_SITUACAO                    = 0
   AND P.PEDF_NR_NF                       IS NOT NULL
---INCLUIDO POR AILTON
--   AND P.PEDF_DTA_EMIS                      >= '01/10/2022'
----
   AND (P.PEDF_ID, P.PEDF_CLI_ID) IN  
       (SELECT MIN(P.PEDF_ID), P.PEDF_CLI_ID 
          FROM PEDIDO_FAT P
         WHERE P.PEDF_EMP_ID = 2
           AND TRUNC(P.PEDF_DTA_EMIS)    >= TO_DATE('01/11/2022')
           AND TRUNC(P.PEDF_DTA_EMIS)    <= TO_DATE('30/11/2022')
           AND P.PEDF_CLI_ID NOT IN (SELECT P.PEDF_CLI_ID
                                       FROM PEDIDO_FAT P
                                      WHERE P.PEDF_EMP_ID = 2
                                        AND TRUNC(P.PEDF_DTA_EMIS) < TO_DATE('01/11/2022'))
        GROUP BY 
             P.PEDF_CLI_ID) 
       order by
      1,2,3,4
