SELECT 
    AC.ACEI_NR_ORDEM,
    SUM(AC.ACEI_QUANTIDADE) QTD,
    MIN(ACEI_DTA_CAD) DATA_INICIO,
    MAX(ACEI_DTA_CAD) ULTIMA_ENTRADA    
 FROM (

SELECT 
                    ACEI_EMP_ID,
                    ACEI_NR_ORDEM,
                    ACEI_NR_SEQUENCIA,
                    ACEI_NR_LOTE,
                    ACEI_QUANTIDADE,
                    ACEI_DTA_CAD,
                    ACEI_USR_ID,
                    ACEI_ORIGEM,
                    ACEI_NR_LOTE_ETIQ                                                        

 FROM               ACEITE_ORDEM_PRODUCAO A
 
 WHERE A.ACEI_EMP_ID = 2
   AND A.ACEI_NR_ORDEM >= 19945
  -- AND A.ACEI_DTA_CAD >= '02/06/2022'
  -- AND A.ACEI_DTA_CAD < '03/06/2022'   
) AC
GROUP BY 
  AC.ACEI_NR_ORDEM
--  ACEI_DTA_CAD
