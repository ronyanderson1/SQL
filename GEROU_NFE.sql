select distinct
      mpf.pedf_id       as "PEDIDO MARGEM",
      mpf.pedf_dta_cad  as "CADASTRO MARGEM",
      mpf.pedf_usr_id||' - '||umpf.usr_nome as "USUARIO_MAGEM",
      pf.pedf_id        as "PEDIDO",
      pf.pedf_nr_nf     as "NFE",
      pf.pedf_usr_id||' - '||up.usr_nome as criou_pedido,
      pf.pedf_dta_cad  as data_cadastro,
      t.pedf_nfe_dta_cad   as data_emissao,
      t.pedf_nfe_usr_id||' - '||u.usr_nome as gerou_nfe
from PEDIDO_FAT_NFE t, 
     usuario u, 
     pedido_fat pf, 
     usuario up,
     ma_pedido_fat mpf,
     usuario umpf
where t.pedf_nfe_usr_id = u.usr_id
and t.pedf_pedf_emp_id = pf.pedf_emp_id and t.pedf_pedf_id = pf.pedf_id
and pf.pedf_usr_id = up.usr_id
and pf.pedf_id_origem2 = mpf.pedf_id
and mpf.pedf_usr_id = umpf.usr_id
and t.pedf_pedf_id = 204489
