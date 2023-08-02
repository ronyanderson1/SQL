select ac.*,op.orpr_prod_id,pp.orpr_lipr_id, pr.prod_desc,
extract(month from ac.acei_dta_cad) as MES, 
extract(year from ac.acei_dta_cad) as ANO,
(select u.usr_nome from usuario u where u.usr_id = ac.acei_usr_id) usuario_aceite,
(select u.usr_nome from usuario u where u.usr_id = ac.acei_usr_id_exclusao) usuario_exclusao
from aceite_ordem_producao ac 
inner join ordem_producao_p op on op.orpr_orprod_nr_ordem = ac.acei_nr_ordem and op.orpr_prod_emp_id = ac.acei_emp_id
inner join ordem_de_producao pp on pp.orpr_nr_ordem = op.orpr_orprod_nr_ordem and op.orpr_orprod_emp_id = pp.orpr_emp_id
inner join produto pr on pr.prod_id = op.orpr_prod_id and pr.prod_emp_id = op.orpr_prod_emp_id
order by ac.acei_dta_cad desc

