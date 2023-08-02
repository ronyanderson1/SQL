select dev.gen_id, dev.gen_descricao, t.*, t.rowid from PEDIDO_FAT t, gener dev
where t.pedf_gen_tgen_id_mot_entr_de = dev.gen_tgen_id
and   t.pedf_gen_emp_id_mot_entr_de  = dev.gen_emp_id
and   t.pedf_gen_id_mot_entr_de      = dev.gen_id
and   t.pedf_dta_cad               >= '01/01/2022'
