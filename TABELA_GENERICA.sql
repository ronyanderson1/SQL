SELECT         GM.GEN_ID                
              ,GM.GEN_DESCRICAO
              ,GM.GEN_EMP_ID
              ,GM.GEN_DTA_CAD
              ,GM.GEN_TGEN_ID   
----------------------------------
               ,GM.GEN_USR_ID,
               GM.GEN_DTA_CAD,
               GM.GEN_NUMBER1,
               GM.GEN_NUMBER2,
               GM.GEN_NUMBER3,
               GM.GEN_NUMBER4,
               GM.GEN_NUMBER5,
               GM.GEN_NUMBER6,
               GM.GEN_TEXT1,
               GM.GEN_TEXT2,
               GM.GEN_TEXT3,
               GM.GEN_TEXT4,
               GM.GEN_FLAG_REP                

FROM GENER GM
WHERE GM.GEN_TGEN_ID = 9005
--AND GM.GEN_ID    = 24
