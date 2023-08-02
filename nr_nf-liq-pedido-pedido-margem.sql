select p.pedf_nr_nf, 
       p.pedf_liqu_id, 
       p.pedf_flag_emis, 
       P.PEDF_ID PEDIDO_FAT,
       F.PEDF_ID PEDIDO_MARGEM, 
       p.pedf_dta_cad, 
       p.pedf_cli_id


       FROM ma_pedido_fat f INNER JOIN PEDIDO_FAT p

       ON P.PEDF_ID_ORIGEM2 = F.PEDF_ID 
       AND P.PEDF_EMP_ID = F.PEDF_EMP_ID


where P.pedf_dta_emis >= '01/11/2022'
and F.PEDF_ID in (64479, 64628, 64629, 64666,64685, 64785, 64794, 64550, 64551, 64560)
