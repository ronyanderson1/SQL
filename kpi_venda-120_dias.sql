SELECT 
       RPAD(DI.GEN_DESCRICAO,20)                         GERENTE
      ,RPAD(ST.GEN_DESCRICAO,30)                         REPRESENTANTE
      ,RPAD(RT.GEN_DESCRICAO,30)                         VENDEDOR
      ,P.PEDF_CLI_ID                                     COD_CLIENTE
      ,RPAD(C.CLI_RAZAO_SOCIAL,35)                       CLIENTE
      ,RPAD(CAD.GEN_DESCRICAO,25)                        CADEIA
      ,P.PEDF_ID                                         PEDIDO
      ,TO_CHAR(C.CLI_DTA_CAD,'dd/mm/yyyy')               DATA_CADASTRO
      ,P.PEDF_NR_NF                                      NOTA_FISCAL
      ,TO_CHAR(P.PEDF_DTA_EMIS,'DD/MM/YYYY')             DATA_EMISSAO
      ,P.PEDF_VLR_TOT_PED                                VALOR_PEDIDO 
 FROM PEDIDO_FAT P
     ,CLIENTE C
     ,GENER   DI
     ,GENER   ST
     ,GENER   RT
     ,GENER   CAD 
 WHERE 
       P.PEDF_CLI_EMP_ID = C.CLI_EMP_ID  
   AND P.PEDF_CLI_ID = C.CLI_ID
   AND C.CLI_GEN_TGEN_ID_CADEIA_DE = CAD.GEN_TGEN_ID
   AND C.CLI_GEN_EMP_ID_CADEIA_DE  = CAD.GEN_EMP_ID
   AND C.CLI_GEN_ID_CADEIA_DE      = CAD.GEN_ID
   AND (P.PEDF_ID, P.PEDF_CLI_ID) IN  
       (SELECT MIN(P.PEDF_ID), P.PEDF_CLI_ID 
          FROM PEDIDO_FAT P
              ,OPERACAO_FAT OP
             ,(SELECT P.PEDF_CLI_ID
                  FROM PEDIDO_FAT P
                      ,OPERACAO_FAT OP
                 WHERE P.PEDF_EMP_ID = 2
                   AND P.PEDF_OPER_EMP_ID = OP.OPER_EMP_ID
                   AND P.PEDF_OPER_ID     = OP.OPER_ID
                   AND OP.OPER_GEN_ID_TP_OPERACAO_DE = 1
                   AND P.PEDF_SITUACAO = 0
                   AND P.PEDF_NR_NF IS NOT NULL
                   --AND TRUNC(P.PEDF_DTA_EMIS) < TO_DATE('01/11/2022')) PED_ANTIGOS
                   AND TRUNC(P.PEDF_DTA_EMIS) < TO_DATE('01/11/2022') - 120) PED_ANTIGOS
         WHERE P.PEDF_EMP_ID = 2
           AND TRUNC(P.PEDF_DTA_EMIS) >= TO_DATE('01/11/2022')
           AND TRUNC(P.PEDF_DTA_EMIS) <= TO_DATE('30/11/2022')
           
           AND PED_ANTIGOS.PEDF_CLI_ID = P.PEDF_CLI_ID 
           
           AND P.PEDF_OPER_EMP_ID = OP.OPER_EMP_ID
           AND P.PEDF_OPER_ID     = OP.OPER_ID
--RELACIONAMENTO DISTRITO
           AND P.PEDF_GEN_TGEN_ID = DI.GEN_TGEN_ID
           AND P.PEDF_GEN_EMP_ID  = DI.GEN_EMP_ID
           AND P.PEDF_GEN_ID      = DI.GEN_ID
--RELACIONAMENTO SETOR
           AND P.PEDF_GEN_TGEN_ID_SETOR_DE = ST.GEN_TGEN_ID
           AND P.PEDF_GEN_EMP_ID_SETOR_DE  = ST.GEN_EMP_ID
           AND P.PEDF_GEN_ID_SETOR_DE      = ST.GEN_ID
--RELACIONAMENTO ROTA
           AND P.PEDF_GEN_TGEN_ID_ROTA_DE = RT.GEN_TGEN_ID
           AND P.PEDF_GEN_EMP_ID_ROTA_DE  = RT.GEN_EMP_ID
           AND P.PEDF_GEN_ID_ROTA_DE      = RT.GEN_ID
           
           AND OP.OPER_GEN_ID_TP_OPERACAO_DE = 1
           AND P.PEDF_SITUACAO = 0
           AND P.PEDF_NR_NF IS NOT NULL
           
           AND P.PEDF_CLI_ID NOT IN (SELECT P.PEDF_CLI_ID
                                       FROM PEDIDO_FAT P
                                           ,OPERACAO_FAT OP
                                      WHERE P.PEDF_EMP_ID = 2
                                        AND P.PEDF_OPER_EMP_ID = OP.OPER_EMP_ID
                                        AND P.PEDF_OPER_ID     = OP.OPER_ID
                                        AND OP.OPER_GEN_ID_TP_OPERACAO_DE = 1
                                        AND P.PEDF_SITUACAO = 0
                                        AND P.PEDF_NR_NF IS NOT NULL
                                        AND TRUNC(P.PEDF_DTA_EMIS) <  TO_DATE('01/11/2022')
                                        --AND TRUNC(P.PEDF_DTA_EMIS) >= TO_DATE('30/11/2022'))
                                        AND TRUNC(P.PEDF_DTA_EMIS) >= TO_DATE('30/11/2022') - 120)
         GROUP BY 
             P.PEDF_CLI_ID) 
ORDER BY
1,2,3
            
