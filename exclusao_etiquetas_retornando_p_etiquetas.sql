select T.ROWID, T.PEDL_ORPR_NR_ORDEM, t.pedl_etqp_codigo_wms, t.* from PEDIDO_FAT_LOGISTICA_LOTE_AC t
WHERE T.PEDL_ORPR_NR_ORDEM = 18796
AND T.PEDL_ETQP_CODIGO_WMS LIKE ('%140014%')
