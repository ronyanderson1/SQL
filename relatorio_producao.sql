select t.mpro_prod_id, 
       p.prod_desc, 
       to_char(t.mpro_data,'MM/YYYY') AS DATA,
       t.mpro_tot_produzido 
       from MAPA_PROD t, 
       produto p
       
where t.mpro_prod_id = p.prod_id
and   t.mpro_prod_emp_id = p.prod_emp_id
and   t.mpro_data >= '01/01/2021'
and   t.mpro_etpr_id = 4 /* Etapa de produção - 4 Suco - 5 Agua*/
order by 3
