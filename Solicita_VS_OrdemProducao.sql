select
    op.orpr_nr_ordem,
    nvl(op.orpr_soli_id,0) as solicita,
    opp.orpr_prod_id,
    p.prod_desc,
    op.orpr_dta_cad as Cadastro,    
    op.orpr_dta_programada as DataProgramada,
    decode(op.orpr_status,'A','ABERTA','R','REALIZADA','C','CANCELADA') AS STATUS,
    op.orpr_hora_ini_realizada as HoraInicio,
    op.orpr_hora_fim_realizada as HoraFim,
    op.orpr_nr_lote_etiq as LoteEtiqueta   
from ORDEM_DE_PRODUCAO op, ORDEM_PRODUCAO_P opp, produto p
where opp.orpr_orprod_emp_id = op.orpr_emp_id and opp.orpr_orprod_nr_ordem = op.orpr_nr_ordem
and opp.orpr_prod_emp_id = p.prod_emp_id and opp.orpr_prod_id = p.prod_id
and op.orpr_dta_cad >= '01/07/2023'
--and op.orpr_status = 'A'
