select
               cod_ger,
               gerente,
               SUM(qtd_total) QTD_TOTAL,
               SUM(VALOR_BRUTO) VLR_BRUTO,
               SUM(VALOR_LIQUIDO) VLR_LIQUIDO,
               mes, 
               ANO
      from(select
               ger.gen_descricao                    as gerente
              ,fat.pedf_gen_id                      as cod_ger
              ,p.pedf_prod_id                       as codigo
              ,po.prod_desc                         as produto
              ,TRUNC(sum(p.pedf_qtde))              as qtd_total 
              ,ROUND(SUM((P.PEDF_VLR_TOT 
                + nvl(p.pedf_vlr_ipi,0) 
                + nvl(p.pedf_vlr_subs,0)) 
                - nvl(p.pedf_valor_desconto,0)
      --          - nvl(p.ma_pedf_vlr_tot_desc_boleto,0)
                - nvl(p.pedf_vlr_icms_des,0)),2)       as VALOR_BRUTO
              ,ROUND(SUM((P.PEDF_VLR_TOT 
                + nvl(p.pedf_vlr_ipi,0) 
                + nvl(p.pedf_vlr_subs,0)) 
                - nvl(p.pedf_valor_desconto,0)
                - nvl(p.ma_pedf_vlr_tot_desc_boleto,0)
                - nvl(p.pedf_vlr_icms_des,0)),2)       as VALOR_LIQUIDO
      
      --        ,Decode(extract(month from sysdate),1,'Janeiro',2,'Fevereiro',3,'Marco',4,'Abril',5,'Maio',6,'Junho',7,'Julho',8,'Agosto',9,'Setembro',10,'Outubro',11,'Novembro',12,'Dezembro') as MES
                ,extract(month from nf.pedf_nfe_dta_cad)          as MES
                ,extract(year from nf.pedf_nfe_dta_cad)           as ANO
           from Pedido_Fat_Nfe nf
             inner join pedido_fat_p p    on p.pedf_pedf_id     = nf.pedf_pedf_id 
                                         and p.pedf_pedf_emp_id = nf.pedf_pedf_emp_id
             inner join produto      po   on po.prod_emp_id     = p.pedf_prod_emp_id
                                         and po.prod_id         = p.pedf_prod_id
             inner join produto_tp   pt   on pt.prot_prod_emp_id = po.prod_emp_id
                                         and pt.prot_prod_id     = po.prod_id                            
             inner join pedido_fat   fat  on fat.pedf_id        = p.pedf_pedf_id 
                                         and fat.pedf_emp_id    = p.pedf_pedf_emp_id
             inner join  gener       ger  on ger.gen_tgen_id    = fat.pedf_gen_tgen_id
                                         and ger.gen_emp_id     = fat.pedf_gen_emp_id
                                         and ger.gen_id         = fat.pedf_gen_id
             inner join operacao_fat op   on op.oper_id         = fat.pedf_oper_id 
                                         and op.oper_emp_id     = fat.pedf_oper_emp_id
           where 
              --extract(month from nf.pedf_nfe_dta_cad)    = extract(month from sysdate)
              extract(month from nf.pedf_nfe_dta_cad)    >= 12 -- extract(month from sysdate) 
              and extract(year from nf.pedf_nfe_dta_cad) = 2021 -- extract(year from sysdate) 
              and op.oper_oper_e_id                      = 10
              and fat.pedf_situacao                      = 0
              and pt.prot_gen_id                         = 3
      ---filtros para analise
      --        and fat.pedf_gen_id                        = 16
      --        and p.pedf_prod_id                         = 11
      --final de analise
          group by p.pedf_prod_id,fat.pedf_gen_id,ger.gen_descricao,po.prod_desc,nf.pedf_nfe_dta_cad
          )
          group by cod_ger,gerente,mes,ano
          order by gerente
