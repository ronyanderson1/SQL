SELECT
G1.GEN_ID
  ,SUBSTR(G1.GEN_DESCRICAO,1,255) GEN_DESCRICAO
  ,SUBSTR(G2.GEN_DESCRICAO,1,30) PROP1
  ,SUBSTR(G3.GEN_DESCRICAO,1,30) PROP2
  ,G3.GEN_ID                     ID_PAIS
  ,SUBSTR(G4.GEN_DESCRICAO,1,30) PROP3
  ,G1.GEN_EMP_ID
FROM
   GENER G1
  ,GENER_A GA1
  ,GENER G2
  ,GENER_A GA2
  ,GENER G3
  ,GENER_A GA3
  ,GENER G4
WHERE (GA1.GENA_GEN_TGEN_ID (+) = G1.GEN_TGEN_ID )
  AND (GA1.GENA_GEN_EMP_ID  (+) = G1.GEN_EMP_ID )
  AND (GA1.GENA_GEN_ID      (+) = G1.GEN_ID )
  AND (G2.GEN_TGEN_ID       (+) = GA1.GENA_GEN_TGEN_ID_PROPRIETARIO_ )
  AND (G2.GEN_EMP_ID        (+) = GA1.GENA_GEN_EMP_ID_PROPRIETARIO_D )
  AND (G2.GEN_ID            (+) = GA1.GENA_GEN_ID_PROPRIETARIO_DE )
  AND G2.GEN_TGEN_ID                       = GA2.GENA_GEN_TGEN_ID (+)
  AND G2.GEN_EMP_ID                        = GA2.GENA_GEN_EMP_ID  (+)
  AND G2.GEN_ID                            = GA2.GENA_GEN_ID      (+)
  AND GA2.GENA_GEN_TGEN_ID_PROPRIETARIO_   = G3.GEN_TGEN_ID       (+)
  AND GA2.GENA_GEN_EMP_ID_PROPRIETARIO_D   = G3.GEN_EMP_ID        (+)
  AND GA2.GENA_GEN_ID_PROPRIETARIO_DE      = G3.GEN_ID            (+)
  AND G3.GEN_TGEN_ID                       = GA3.GENA_GEN_TGEN_ID (+)
  AND G3.GEN_EMP_ID                        = GA3.GENA_GEN_EMP_ID  (+)
  AND G3.GEN_ID                            = GA3.GENA_GEN_ID      (+)
  AND GA3.GENA_GEN_TGEN_ID_PROPRIETARIO_   = G4.GEN_TGEN_ID       (+)
  AND GA3.GENA_GEN_EMP_ID_PROPRIETARIO_D   = G4.GEN_EMP_ID        (+)
  AND GA3.GENA_GEN_ID_PROPRIETARIO_DE      = G4.GEN_ID            (+)
  AND (G1.GEN_TGEN_ID =1211)
  AND (G1.GEN_EMP_ID  =2)
 AND G2.GEN_DESCRICAO != 'INATIVO'
ORDER BY G1.GEN_DESCRICAO
   
