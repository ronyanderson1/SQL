select        t.agdp_nr_nota            AS NR_NOTA, 
              t.agdp_cli_id             AS ID_CLT,
              c.cli_razao_social        AS RAZAO,
              T.AGDP_BCO_ID             AS ID_BANCO,
              b.bco_desc                AS BANCO,
              t.agdp_usr_id             AS ID_USUARIO, 
              u.usr_nome                AS USUARIO,
              T.AGDP_LIQU_ID            AS LIQUIDACAO,
              T.AGDP_NR_DOC             AS NR_DOC,
              T.AGDP_TDOC_TP_DOC        AS TIPO_DOC,
              T.AGDP_NR_BOLETO          AS NR_BOLETO,
              T.AGDP_VALOR              AS VALOR,
              T.AGDP_VALOR_ORIGINAL     AS VALOR_ORIGINAL,
              T.AGDP_LINHA_DIGITAVEL    AS CD_BARRA,
              T.AGDP_DTA_EMIS           AS DTA_EMISSAO,
              T.AGDP_DTA_CAD            AS DTA_CADASTRO,
              T.AGDP_TDOC_ENTR_SAI      AS ENTR_SAIDA,
              
              
t.rowid from AGRUP_DUPL t, usuario u, banco b, cliente c
              
where t.agdp_usr_id = u.usr_id
and t.agdp_bco_id = b.bco_id
and t.agdp_emp_id = b.bco_emp_id
and t.agdp_cli_emp_id = c.cli_emp_id
and t.agdp_cli_id = c.cli_id
and t.agdp_nr_nota in (166198, 166200, 166201)
