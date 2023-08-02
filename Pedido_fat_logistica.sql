select t.*, t.rowid from PEDIDO_FAT_LOGISTICA t
where t.pedl_placa like '%2405%'
order by t.pedl_placa asc
