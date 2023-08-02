select t.pedf_nr_nf, t.pedf_oper_id, op.oper_desc as operacao_faturamento, t.pedf_id as pedido, t.pedf_vlr_tot_ped as valor_tot ,t.pedf_dta_emis
from PEDIDO_FAT t inner join operacao_fat op on t.pedf_oper_id = op.oper_id and t.pedf_oper_emp_id = t.pedf_oper_emp_id and t.pedf_emp_id = op.oper_emp_id
where t.pedf_dta_emis >= '01/06/2021' and t.pedf_dta_emis < '01/07/2021'
and t.pedf_oper_id not in ( 35, 258, 259, 68, 993, 500,99, 58, 82, 907, 39, 703, 690, 704, 905, 27, 52 )
order by 1
