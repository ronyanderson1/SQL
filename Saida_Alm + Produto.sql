select p.prod_desc, t.* from saida_alm_e t, produto p
where t.sdal_sdal_emp_id = p.prod_emp_id
and t.sdal_prod_id = p.prod_id
and t.sdal_soit_soli_id = 44973
