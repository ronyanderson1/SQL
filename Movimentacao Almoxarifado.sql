select p.prod_desc, t.* from SOLICITA_ITENS t, produto p
where t.soit_prod_id = p.prod_id
and t.soit_soli_emp_id = p.prod_emp_id
and t.soit_soli_id = 46019
