select t.*, t.rowid from SAIDA_ALM_E t, SAIDA_ALM s
where T.SDAL_SDAL_EMP_ID = S.SDAL_EMP_ID
AND T.SDAL_SDAL_ID = S.SDAL_ID
AND S.SDAL_DOCUM LIKE '%44937%'