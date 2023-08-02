SELECT  DISTINCT
        T.GEN_EMP_ID          AS EMP,
        T.GEN_ID              AS ID_ROTA,
        T.GEN_DESCRICAO       AS ROTA,
        T.PROP_ID_1           AS ID_SETOR,
        T.DESC_PROP_1         AS SETOR,
        T.PROP_ID_2           AS ID_DIST, 
        T.DESC_PROP_2         AS DISTRITO,
        T.PROP_ID_3           AS ID_AREA,
        T.DESC_PROP_3         AS AREA        
        
FROM GENER$V t
WHERE T.GEN_TGEN_ID = 920
AND T.GEN_EMP_ID = 2
ORDER BY 2
