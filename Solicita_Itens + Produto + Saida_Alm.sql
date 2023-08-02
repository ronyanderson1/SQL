select distinct t.soit_soli_id,
                e.sdal_sdal_id, 
                p.prod_id, 
                p.prod_desc,
                t.soit_qtde_atendida_req,
                t.soit_qtd_atendida,
                t.soit_qtde,
                t.soit_dta_cad
                
from            SOLICITA_ITENS t, produto p, saida_alm_e e
where           t.soit_soli_emp_id = e.sdal_sdal_emp_id    and t.soit_soli_id = e.sdal_soit_soli_id
and             t.soit_soli_emp_id = p.prod_emp_id         and t.soit_prod_id = p.prod_id
and             t.soit_soli_id = 44973 -- Solicita
--and    e.sdal_sdal_id = 67680 -- Requisição
--and    p.prod_id      = 1332  -- Produto
order by 1
