select to_char(s.sdal_data,'yyyy') as ano, to_char(s.sdal_data,'mm') as mes,

       s.sdal_oper_alm_id,
       o.oper_desc,
       t.sdal_prod_id,
       sum(t.sdal_qtde)
       from SAIDA_ALM_E t,
       saida_alm s,
       operacao_alm o

where t.sdal_sdal_emp_id = s.sdal_emp_id
and t.sdal_sdal_id = s.sdal_id
and s.sdal_oper_alm_emp_id = o.oper_emp_id
and s.sdal_oper_alm_id = o.oper_id
and t.sdal_prod_id = 717
and s.sdal_data >= '01/01/2019'
and s.sdal_oper_alm_id in (50,80)
    group by
       to_char(s.sdal_data,'mm') ,
       s.sdal_oper_alm_id,
       o.oper_desc,
       t.sdal_prod_id,
       to_char(s.sdal_data,'yyyy')

order by 1,2
