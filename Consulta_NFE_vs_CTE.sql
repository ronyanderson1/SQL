SELECT 
    PF.PEDF_NR_NF             AS NFE,
    T.PEDF_NFE_CHAVE          AS CHAVE_NFE,
    T.PEDF_NFE_DTA_CAD        AS DATA_NFE,
    T.PEDF_PEDF_ID            AS PEDIDO,
    NVL(CTE.CP_NUMERO_CTE,0)  AS CTE,
    NVL(IE.IT_CHAVE_CTE,0)    AS CHAVE_CTE
    
FROM PEDIDO_FAT_NFE T, PEDIDO_FAT PF, ITENS_CTE IE, CAPA_CTE CTE
WHERE T.PEDF_PEDF_EMP_ID = PF.PEDF_EMP_ID AND T.PEDF_PEDF_ID = PF.PEDF_ID
AND   T.PEDF_NFE_CHAVE = IE.IT_CHAVE_NFE
AND   CTE.CP_CHAVE_CTE = IE.IT_CHAVE_CTE
AND   T.PEDF_NFE_DTA_CAD >= '01/01/2020'
ORDER BY PF.PEDF_NR_NF, T.PEDF_NFE_DTA_CAD
