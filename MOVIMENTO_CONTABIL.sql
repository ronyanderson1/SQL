select t.movc_lote_id,
       t.movc_lote_cp,
       t.movc_pcta_ref,
       t.movc_pcta_conta,
       t.movc_nr_lancam,
       t.movc_valor,
       t.movc_dta_cad
from MOV_CONTAB t
where t.movc_dta_cad >= '01/01/2023'
and t.movc_valor like '%36517,74%'
