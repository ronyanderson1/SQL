SELECT
        VENDAS.AREA                                                         AS AREA
    ,VENDAS.COD_GER || '-' || VENDAS.GERENTE                                                      AS GERENTE
    ,VENDAS.COD_REP || '-' || VENDAS.REPRESENTANTE                                                AS REPRESENTANTE
    ,VENDAS.COD_VEND || '-' || VENDAS.VENDEDOR                                                     AS VENDEDOR
    ,VENDAS.COD_CLI || '-' || VENDAS.CLIENTE                                                      AS CLIENTE
    ,VENDAS.COD_EMB || '-' || VENDAS.EMBALAGEM                                                    AS EMBALAGEM

    ,VENDAS.COD_PROD || '-' || VENDAS.PRODUTO                                                      AS PRODUTO
    ,ROUND(SUM(NVL(VENDAS.VENDAS_GERAL,0)),2)                            AS VENDAS_GERAL
    ,SUM(NVL(VENDAS.DEVOLUCOES,0))                                       AS DEVOLUCOES
    ,SUM(NVL(VENDAS.VENDAS_GERAL,0) - NVL(VENDAS.DEVOLUCOES,0))          AS VLR_COMERCIAL
    ,ROUND(SUM(NVL(VENDAS.VALOR_ACORDO,0) /100 * VENDAS.VENDAS_GERAL),2) AS VLR_ACORDO
    ,SUM(NVL(VENDAS.VENDAS_GERAL,0) - NVL(VENDAS.DEVOLUCOES,0)) -
        ROUND(SUM(NVL(VENDAS.VALOR_ACORDO,0) /100 * VENDAS.VENDAS_GERAL),2) AS VLR_LIQUIDO
    ,SUM(NVL(VENDAS.DESC_BOLETO,0))                                      AS DESC_BOLETO
    ,SUM(NVL(VENDAS.DEV_DESC_BOLETO,0))                                  AS DEV_DESC_BOLETO
    ,SUM(NVL(VENDAS.VENDAS_GERAL,0) - NVL(VENDAS.DEVOLUCOES,0)) -
    ROUND(SUM(NVL(VENDAS.VALOR_ACORDO,0) /100 * VENDAS.VENDAS_GERAL),2)
        - SUM(NVL(VENDAS.DESC_BOLETO,0)) + SUM(NVL(VENDAS.DEV_DESC_BOLETO,0))           AS VLR_FINANCEIRO
    ,ROUND(SUM(NVL(VENDAS.CARTEIRA,0)),2)                                 AS CARTEIRA

    FROM
(
    select
    re.AREA          AREA,
    re.COD_GER       COD_GER,
    re.GERENTE       GERENTE,
    re.COD_REP       COD_REP,
    re.REPRESENTANTE REPRESENTANTE,
    re.COD_VEND      COD_VEND,
    re.VENDEDOR      VENDEDOR
,0                                     AS PEDIDO
,0                                     AS NOTA_FISCAL
,re.COD_CLI                            AS COD_CLI
,re.CLIENTE                            AS CLIENTE
,''                                    AS CIDADE
,''                                    AS UF
,re.COD_EMB                            AS COD_EMB
,re.EMBALAGEM                          AS EMBALAGEM
,re.COD_PROD                           AS COD_PROD
,re.PRODUTO                            AS PRODUTO
,0                                     AS VENDAS_GERAL
,''                                    AS MES
,''                                    AS ANO
,0                                     AS DEVOLUCOES
,0                                     AS VALOR_ACORDO
,0                                     AS DESC_BOLETO
,0                                     AS DEV_DESC_BOLETO
,0                                     AS A_FATURAR
,re.VALOR                              AS CARTEIRA

from detalhada_em_carteira re

union all
SELECT
    AR.GEN_DESCRICAO                                  AS AREA
    ,P.PEDF_GEN_ID                                     AS COD_GER
    ,GER.GEN_DESCRICAO                                 AS GERENTE
    ,P.PEDF_GEN_ID_SETOR_DE                            AS COD_REP
    ,REP.GEN_DESCRICAO                                 AS REPRESENTANTE
    ,P.PEDF_GEN_ID_ROTA_DE                             AS COD_VEND
    ,VEN.GEN_DESCRICAO                                 AS VENDEDOR
    ,P.PEDF_ID                                         AS PEDIDO
    ,P.PEDF_NR_NF                                      AS NOTA_FISCAL
    ,P.PEDF_CLI_ID                                     AS COD_CLI
    ,CL.CLI_RAZAO_SOCIAL                               AS CLIENTE
    ,CID.GEN_DESCRICAO                                 AS CIDADE
    ,UF.GEN_DESCRICAO                                  AS UF
    ,EMB.GEN_ID                                        AS COD_EMB
    ,EMB.GEN_DESCRICAO                                 AS EMBALAGEM
    ,PP.PEDF_PROD_ID                                   AS COD_PROD
    ,PR.PROD_DESC                                      AS PRODUTO
    ,SUM((PP.PEDF_VLR_TOT
        + NVL(PP.PEDF_VLR_IPI,0)
        + NVL(PP.PEDF_VLR_SUBS,0))
        - NVL(PP.PEDF_VALOR_DESCONTO,0)
        - NVL(PP.PEDF_VLR_ICMS_DES,0))               AS VENDAS_GERAL
    ,DECODE(TO_CHAR(P.PEDF_DTA_EMIS,'MM')
        ,1,'JANEIRO',2,'FEVEREIRO',3,'MARCO'
        ,4,'ABRIL',5,'MAIO',6,'JUNHO'
        ,7,'JULHO',8,'AGOSTO',9,'SETEMBRO'
        ,10,'OUTUBRO',11,'NOVEMBRO',12,'DEZEMBRO')    AS MES
    ,TO_CHAR(P.PEDF_DTA_EMIS,'YYYY')                   AS ANO
    ,0                                                 AS DEVOLUCOES
    ,(SELECT DISTINCT NVL(PF.CLIP_QUANTIDADE,0)
    FROM CLIENTE_PERFIL PF
        WHERE PF.CLIP_CLI_ID = P.PEDF_CLI_ID
        AND PF.CLIP_EMP_ID =  P.PEDF_CLI_EMP_ID
        AND PF.CLIP_GEN_ID = 5
        AND PF.CLIP_DTA_CAD <= P.PEDF_DTA_EMIS
        AND PF.CLIP_QUANTIDADE IS NOT NULL)         AS VALOR_ACORDO
,SUM(NVL(PP.MA_PEDF_VLR_TOT_DESC_BOLETO,0)
    + NVL(PP.MA_PEDF_VLR_TOT_DESC_FINAN,0))         AS DESC_BOLETO
,0                                                 AS DEV_DESC_BOLETO
,0                                                 AS A_FATURAR
,0                                                 AS CARTEIRA
    FROM PEDIDO_FAT P
    INNER JOIN OPERACAO_FAT O   ON O.OPER_ID             = P.PEDF_OPER_ID
    INNER JOIN PEDIDO_FAT_NFE N ON N.PEDF_PEDF_ID        = P.PEDF_ID
    INNER JOIN LIQUIDACAO LQ    ON LQ.LIQU_EMP_ID        = P.PEDF_LIQU_EMP_ID
                            AND LQ.LIQU_ID            = P.PEDF_LIQU_ID
    INNER JOIN GENER     AR     ON AR.GEN_TGEN_ID        = P.PEDF_GEN_TGEN_ID_AREA_DE
                            AND AR.GEN_EMP_ID         = P.PEDF_GEN_EMP_ID_AREA_DE
                            AND AR.GEN_ID             = P.PEDF_GEN_ID_AREA_DE
    INNER JOIN GENER     GER    ON GER.GEN_TGEN_ID       = P.PEDF_GEN_TGEN_ID
                            AND GER.GEN_EMP_ID        = P.PEDF_GEN_EMP_ID
                            AND GER.GEN_ID            = P.PEDF_GEN_ID
    INNER JOIN GENER     REP    ON REP.GEN_TGEN_ID       = P.PEDF_GEN_TGEN_ID_SETOR_DE
                            AND REP.GEN_EMP_ID        = P.PEDF_GEN_EMP_ID_SETOR_DE
                            AND REP.GEN_ID            = P.PEDF_GEN_ID_SETOR_DE
    INNER JOIN GENER     VEN    ON VEN.GEN_TGEN_ID       = P.PEDF_GEN_TGEN_ID_ROTA_DE
                            AND VEN.GEN_EMP_ID        = P.PEDF_GEN_EMP_ID_ROTA_DE
                            AND VEN.GEN_ID            = P.PEDF_GEN_ID_ROTA_DE
    INNER JOIN PEDIDO_FAT_P PP  ON PP.PEDF_PEDF_EMP_ID   = P.PEDF_EMP_ID
                            AND PP.PEDF_PEDF_ID       = P.PEDF_ID
    INNER JOIN PRODUTO_TP PTP   ON PTP.PROT_PROD_EMP_ID  = PP.PEDF_PROD_EMP_ID
                            AND PTP.PROT_PROD_ID      = PP.PEDF_PROD_ID
    INNER JOIN PRODUTO PR       ON PR.PROD_EMP_ID        = PP.PEDF_PROD_EMP_ID
                            AND PR.PROD_ID            = PP.PEDF_PROD_ID
    INNER JOIN PRODUTO_C   PC   ON PC.PROC_PROD_EMP_ID   = PR.PROD_EMP_ID
                            AND PC.PROC_PROD_ID       = PR.PROD_ID
    INNER JOIN GENER    EMB     ON EMB.GEN_TGEN_ID       = PC.PROC_GEN_TGEN_ID_EMBALAGEM_DE
                            AND EMB.GEN_EMP_ID        = PC.PROC_GEN_EMP_ID_EMBALAGEM_DE
                            AND EMB.GEN_ID            = PC.PROC_GEN_ID_EMBALAGEM_DE
    INNER JOIN CLIENTE   CL     ON CL.CLI_EMP_ID         = P.PEDF_CLI_EMP_ID
                            AND CL.CLI_ID             = P.PEDF_CLI_ID
    INNER JOIN CLIENTE_E  CE    ON CE.CLIE_CLI_EMP_ID    = CL.CLI_EMP_ID
                            AND CE.CLIE_CLI_ID        = CL.CLI_ID
                            AND CE.CLIE_GEN_ID        = 2
    INNER JOIN GENER     CID    ON CID.GEN_TGEN_ID       = CE.CLIE_GEN_TGEN_ID_CIDADE_DE
                            AND CID.GEN_EMP_ID        = CE.CLIE_GEN_EMP_ID_CIDADE_DE
                            AND CID.GEN_ID            = CE.CLIE_GEN_ID_CIDADE_DE
    INNER JOIN GENER_A   CIDA   ON CIDA.GENA_GEN_TGEN_ID = CID.GEN_TGEN_ID
                            AND CIDA.GENA_GEN_EMP_ID  = CID.GEN_EMP_ID
                            AND CIDA.GENA_GEN_ID      = CID.GEN_ID
    INNER JOIN GENER     UF     ON UF.GEN_TGEN_ID        = CIDA.GENA_GEN_TGEN_ID_PROPRIETARIO_
                            AND UF.GEN_EMP_ID         = CIDA.GENA_GEN_EMP_ID_PROPRIETARIO_D
                            AND UF.GEN_ID             = CIDA.GENA_GEN_ID_PROPRIETARIO_DE
    WHERE P.PEDF_SITUACAO                                = 0
        AND N.PEDF_PEDF_EMP_ID                           = P.PEDF_EMP_ID
        AND N.PEDF_NFE_DTA_CAD                       >= TO_DATE('04/08/2023 00:00:00','DD/MM/YYYY HH24:MI:SS')
        AND N.PEDF_NFE_DTA_CAD                       <= TO_DATE('05/08/2023 23:59:59','DD/MM/YYYY HH24:MI:SS')
        AND P.PEDF_NR_NF                                 IS NOT NULL
        AND N.PEDF_NFE_CHAVE                             IS NOT NULL
        AND P.PEDF_EMP_ID                                = O.OPER_EMP_ID
        AND O.OPER_GEN_ID_TP_OPERACAO_DE                 = 1
        AND O.OPER_ID                                    NOT IN (7,900)
        AND PTP.PROT_GEN_ID = 3
    GROUP BY
    AR.GEN_DESCRICAO
    ,P.PEDF_GEN_ID
    ,GER.GEN_DESCRICAO
    ,P.PEDF_GEN_ID_SETOR_DE
    ,REP.GEN_DESCRICAO
    ,P.PEDF_GEN_ID_ROTA_DE
    ,VEN.GEN_DESCRICAO
    ,P.PEDF_ID
    ,P.PEDF_NR_NF
    ,P.PEDF_CLI_ID
    ,CL.CLI_RAZAO_SOCIAL
    ,CID.GEN_DESCRICAO
    ,UF.GEN_DESCRICAO
    ,EMB.GEN_ID
    ,EMB.GEN_DESCRICAO
    ,PP.PEDF_PROD_ID
    ,PR.PROD_DESC
    ,n.pedf_nfe_dta_cad
    ,P.PEDF_DTA_EMIS
    ,O.OPER_GEN_ID_TP_OPERACAO_DE
    ,P.PEDF_CLI_ID
    ,P.PEDF_CLI_EMP_ID
    ,PP.MA_PEDF_VLR_TOT_DESC_BOLETO
UNION ALL
select
ar.gen_descricao                                    AS AREA
,DI.GEN_ID                                           AS COD_GER
,DI.GEN_DESCRICAO                                    AS GERENTE
,ST.GEN_ID                                           AS COD_REP
,ST.GEN_DESCRICAO                                    AS REPRESENTANTE
,RT.GEN_ID                                           AS COD_VEND
,RT.GEN_DESCRICAO                                    AS VENDEDOR
,PF.PEDF_ID                                          AS PEDIDO
,NVL(PF.PEDF_NR_NF,0)                                AS NOTA_FISCAL
,CL.CLI_ID                                           AS COD_CLI
,CL.CLI_RAZAO_SOCIAL                                 AS CLIENTE
,CID.GEN_DESCRICAO                                   AS CIDADE
,UF.GEN_DESCRICAO                                    AS UF
,EMB.GEN_ID                                          AS COD_EMB
,EMB.GEN_DESCRICAO                                   AS EMBALAGEM
,PR.PROD_ID                                          AS COD_PROD
,PR.PROD_DESC                                        AS PRODUTO
,0                                                   AS VENDAS_GERAL
,DECODE(TO_CHAR(PF.PEDF_DTA_EMIS,'MM')
        ,1,'JANEIRO',2,'FEVEREIRO',3,'MARCO'
        ,4,'ABRIL',5,'MAIO',6,'JUNHO'
        ,7,'JULHO',8,'AGOSTO',9,'SETEMBRO'
        ,10,'OUTUBRO',11,'NOVEMBRO',12,'DEZEMBRO')    AS MES
,TO_CHAR(PF.PEDF_DTA_EMIS,'YYYY')                    AS ANO
,0                                                   AS DEVOLUCOES
,0                                                   AS VALOR_ACORDO
,0                                                   AS DESC_BOLETO
,0                                                   AS DEV_DESC_BOLETO
,SUM((PP.PEDF_VLR_TOT
    + NVL(PP.PEDF_VLR_IPI,0)
    + NVL(PP.PEDF_VLR_SUBS,0))
    - NVL(PP.PEDF_VALOR_DESCONTO,0)
    - NVL(PP.PEDF_VLR_ICMS_DES,0))                 AS A_FATURAR
,0                                                   AS CARTEIRA
from
PEDIDO_FAT           PF
,PEDIDO_FAT_P         PP
,PRODUTO_C            PC
,PRODUTO              PR
,PRODUTO_TP           PTP
,operacao_fat         o
,gener                rt
,gener                st
,gener                di
,gener                ar
,GENER                EMB
,CLIENTE              CL
,CLIENTE_E            EN
,GENER                CID
,GENER_A                CIDA
,GENER                UF
where
    PF.PEDF_EMP_ID                      = PP.PEDF_PEDF_EMP_ID
AND   PF.PEDF_ID                          = PP.PEDF_PEDF_ID
AND   PF.PEDF_CLI_EMP_ID                  = CL.CLI_EMP_ID
AND   PF.PEDF_CLI_ID                      = CL.CLI_ID
AND   CL.CLI_EMP_ID                       = EN.CLIE_CLI_EMP_ID
AND   CL.CLI_ID                           = EN.CLIE_CLI_ID
AND   EN.CLIE_GEN_TGEN_ID_CIDADE_DE       = CID.GEN_TGEN_ID
AND   EN.CLIE_GEN_EMP_ID_CIDADE_DE        = CID.GEN_EMP_ID
AND   EN.CLIE_GEN_ID_CIDADE_DE            = CID.GEN_ID
AND   CID.GEN_TGEN_ID                     = CIDA.GENA_GEN_TGEN_ID
AND   CID.GEN_EMP_ID                      = CIDA.GENA_GEN_EMP_ID
AND   CID.GEN_ID                          = CIDA.GENA_GEN_ID
AND   CIDA.GENA_GEN_TGEN_ID_PROPRIETARIO_ = UF.GEN_TGEN_ID
AND   CIDA.GENA_GEN_EMP_ID_PROPRIETARIO_D = UF.GEN_EMP_ID
AND   CIDA.GENA_GEN_ID_PROPRIETARIO_DE    = UF.GEN_ID
AND   EN.CLIE_GEN_ID                      = 2
AND   PP.PEDF_PROD_EMP_ID                 = PC.PROC_PROD_EMP_ID
AND   PP.PEDF_PROD_ID                     = PC.PROC_PROD_ID
AND   PP.PEDF_PROD_EMP_ID                 = PR.PROD_EMP_ID
AND   PP.PEDF_PROD_ID                     = PR.PROD_ID
AND   PTP.PROT_PROD_EMP_ID  = PP.PEDF_PROD_EMP_ID
AND   PTP.PROT_PROD_ID      = PP.PEDF_PROD_ID
AND   PC.PROC_GEN_TGEN_ID_EMBALAGEM_DE    = EMB.GEN_TGEN_ID
AND   PC.PROC_GEN_EMP_ID_EMBALAGEM_DE     = EMB.GEN_EMP_ID
AND   PC.PROC_GEN_ID_EMBALAGEM_DE         = EMB.GEN_ID
AND   PF.pedf_oper_emp_id                 = o.oper_emp_id
and   PF.pedf_oper_id                     = o.oper_id
and   PF.pedf_gen_tgen_id                 = di.gen_tgen_id
and   PF.pedf_gen_emp_id                  = di.gen_emp_id
and   PF.pedf_gen_id                      = di.gen_id
and   PF.pedf_gen_tgen_id_area_de         = ar.gen_tgen_id
and   PF.pedf_gen_emp_id_area_de          = ar.gen_emp_id
and   PF.pedf_gen_id_area_de              = ar.gen_id
and   PF.pedf_gen_tgen_id_setor_de        = st.gen_tgen_id
and   PF.pedf_gen_emp_id_setor_de         = st.gen_emp_id
and   PF.pedf_gen_id_setor_de             = st.gen_id
and   PF.pedf_gen_tgen_id_rota_de         = rt.gen_tgen_id
and   PF.pedf_gen_emp_id_rota_de          = rt.gen_emp_id
and   PF.pedf_gen_id_rota_de              = rt.gen_id
and   o.oper_gen_id_tp_operacao_de        = 1
and   PF.pedf_cli_id                      not in (3183)
and   PF.pedf_liqu_id                     <> 1
and   PF.pedf_nr_nf                       is null
and   PF.pedf_situacao                    = 0
and   PF.pedf_flag_emis                   = 9
AND   PTP.PROT_GEN_ID = 3
and   PF.pedf_dta_cad                     >= '01/01/2023'
group by
ar.gen_descricao
,DI.GEN_ID
,DI.GEN_DESCRICAO
,ST.GEN_ID
,ST.GEN_DESCRICAO
,RT.GEN_ID
,RT.GEN_DESCRICAO
,PF.PEDF_ID
,NVL(PF.PEDF_NR_NF,0)
,CL.CLI_ID
,CL.CLI_RAZAO_SOCIAL
,CID.GEN_DESCRICAO
,UF.GEN_DESCRICAO
,PF.PEDF_DTA_EMIS
,EMB.GEN_ID
,EMB.GEN_DESCRICAO
,PR.PROD_ID
,PR.PROD_DESC
    UNION ALL
    SELECT
    AR.GEN_DESCRICAO                                     AS AREA
,P.PEDF_GEN_ID                                        AS COD_GER
,GER.GEN_DESCRICAO                                    AS GERENTE
,P.PEDF_GEN_ID_SETOR_DE                               AS COD_REP
,REP.GEN_DESCRICAO                                    AS REPRESENTANTE
,P.PEDF_GEN_ID_ROTA_DE                                AS COD_VEND
,VEN.GEN_DESCRICAO                                    AS VENDEDOR
,P.PEDF_ID                                            AS PEDIDO
,P.PEDF_NR_NF                                         AS NOTA_FISCAL
,P.PEDF_CLI_ID                                        AS COD_CLI
,CL.CLI_RAZAO_SOCIAL                                  AS CLIENTE
,CID.GEN_DESCRICAO                                    AS CIDADE
,UF.GEN_DESCRICAO                                     AS UF
,EMB.GEN_ID                                           AS COD_EMB
,EMB.GEN_DESCRICAO                                    AS EMBALAGEM
,PP.PEDF_PROD_ID                                      AS COD_PROD
,PR.PROD_DESC                                         AS PRODUTO
,0                                                    AS VENDAS_GERAL
,DECODE(TO_CHAR(P.PEDF_DTA_EMIS,'MM'),1,'JANEIRO'
    ,2,'FEVEREIRO',3,'MARCO',4,'ABRIL',5,'MAIO'
    ,6,'JUNHO',7,'JULHO',8,'AGOSTO',9,'SETEMBRO'
    ,10,'OUTUBRO',11,'NOVEMBRO',12,'DEZEMBRO')         AS MES
,TO_CHAR(P.PEDF_DTA_EMIS,'YYYY')                      AS ANO
,SUM((PP.PEDF_VLR_TOT + NVL(PP.PEDF_VLR_IPI,0)
    + NVL(PP.PEDF_VLR_SUBS,0))
    - NVL(PP.PEDF_VALOR_DESCONTO,0))                   AS DEVOLUCOES
,0                                                    AS VALOR_ACORDO
,SUM(NVL(-PP.MA_PEDF_VLR_TOT_DESC_BOLETO,0)
    + NVL(-PP.MA_PEDF_VLR_TOT_DESC_FINAN,0))           AS DESC_BOLETO
,(SELECT ROUND(FR.DEVOL_PROD,2)
        FROM MI_VLR_FRACIONADO FR
    WHERE FR.pedf_pedf_id = P.PEDF_ID
        AND FR.PEDF_PROD_ID = PP.PEDF_PROD_ID)           AS DEV_DESC_BOLETO
,0                                                    AS A_FATURAR
,0                                                    AS CARTEIRA
    FROM PEDIDO_FAT P
    INNER JOIN OPERACAO_FAT O   ON O.OPER_ID                = P.PEDF_OPER_ID
    INNER JOIN LIQUIDACAO LQ    ON LQ.LIQU_EMP_ID           = P.PEDF_LIQU_EMP_ID
                            AND LQ.LIQU_ID               = P.PEDF_LIQU_ID
    INNER JOIN GENER     AR     ON AR.GEN_TGEN_ID           = P.PEDF_GEN_TGEN_ID_AREA_DE
                            AND AR.GEN_EMP_ID            = P.PEDF_GEN_EMP_ID_AREA_DE
                            AND AR.GEN_ID                = P.PEDF_GEN_ID_AREA_DE
    INNER JOIN GENER     GER    ON GER.GEN_TGEN_ID          = P.PEDF_GEN_TGEN_ID
                            AND GER.GEN_EMP_ID           = P.PEDF_GEN_EMP_ID
                            AND GER.GEN_ID               = P.PEDF_GEN_ID
    INNER JOIN GENER     REP    ON REP.GEN_TGEN_ID          = P.PEDF_GEN_TGEN_ID_SETOR_DE
                            AND REP.GEN_EMP_ID           = P.PEDF_GEN_EMP_ID_SETOR_DE
                            AND REP.GEN_ID               = P.PEDF_GEN_ID_SETOR_DE
    INNER JOIN GENER     VEN    ON VEN.GEN_TGEN_ID          = P.PEDF_GEN_TGEN_ID_ROTA_DE
                            AND VEN.GEN_EMP_ID           = P.PEDF_GEN_EMP_ID_ROTA_DE
                            AND VEN.GEN_ID               = P.PEDF_GEN_ID_ROTA_DE
    INNER JOIN PEDIDO_FAT_P PP  ON PP.PEDF_PEDF_EMP_ID      = P.PEDF_EMP_ID
                            AND PP.PEDF_PEDF_ID          = P.PEDF_ID
    INNER JOIN PRODUTO_TP PTP   ON PTP.PROT_PROD_EMP_ID  = PP.PEDF_PROD_EMP_ID
                            AND PTP.PROT_PROD_ID      = PP.PEDF_PROD_ID
    INNER JOIN PRODUTO PR       ON PR.PROD_EMP_ID           = PP.PEDF_PROD_EMP_ID
                            AND PR.PROD_ID               = PP.PEDF_PROD_ID
    INNER JOIN PRODUTO_C   PC   ON PC.PROC_PROD_EMP_ID      = PR.PROD_EMP_ID
                            AND PC.PROC_PROD_ID          = PR.PROD_ID
    INNER JOIN GENER    EMB     ON EMB.GEN_TGEN_ID          = PC.PROC_GEN_TGEN_ID_EMBALAGEM_DE
                            AND EMB.GEN_EMP_ID           = PC.PROC_GEN_EMP_ID_EMBALAGEM_DE
                            AND EMB.GEN_ID               = PC.PROC_GEN_ID_EMBALAGEM_DE
    INNER JOIN CLIENTE   CL     ON CL.CLI_EMP_ID            = P.PEDF_CLI_EMP_ID
                            AND CL.CLI_ID                = P.PEDF_CLI_ID
    INNER JOIN CLIENTE_E  CE    ON CE.CLIE_CLI_EMP_ID       = CL.CLI_EMP_ID
                            AND CE.CLIE_CLI_ID           = CL.CLI_ID
                            AND CE.CLIE_GEN_ID           = 2
    INNER JOIN GENER     CID    ON CID.GEN_TGEN_ID          = CE.CLIE_GEN_TGEN_ID_CIDADE_DE
                            AND CID.GEN_EMP_ID           = CE.CLIE_GEN_EMP_ID_CIDADE_DE
                            AND CID.GEN_ID               = CE.CLIE_GEN_ID_CIDADE_DE
    INNER JOIN GENER_A   CIDA   ON CIDA.GENA_GEN_TGEN_ID    = CID.GEN_TGEN_ID
                            AND CIDA.GENA_GEN_EMP_ID     = CID.GEN_EMP_ID
                            AND CIDA.GENA_GEN_ID         = CID.GEN_ID
    INNER JOIN GENER     UF     ON UF.GEN_TGEN_ID           = CIDA.GENA_GEN_TGEN_ID_PROPRIETARIO_
                            AND UF.GEN_EMP_ID            = CIDA.GENA_GEN_EMP_ID_PROPRIETARIO_D
                            AND UF.GEN_ID                = CIDA.GENA_GEN_ID_PROPRIETARIO_DE
    INNER JOIN PEDIDO_FAT_NFE NFE  ON NFE.PEDF_PEDF_ID      = P.PEDF_ID
                                AND NFE.PEDF_PEDF_EMP_ID = P.PEDF_EMP_ID
    WHERE P.PEDF_SITUACAO                                   = 0
    AND NFE.PEDF_NFE_DTA_CAD                       >= TO_DATE('04/08/2023 00:00:00','DD/MM/YYYY HH24:MI:SS')
    AND NFE.PEDF_NFE_DTA_CAD                       <= TO_DATE('05/08/2023 23:59:59','DD/MM/YYYY HH24:MI:SS')
    AND P.PEDF_EMP_ID                                     = O.OPER_EMP_ID
    AND P.PEDF_OPER_ID                                    IN (88,90,990,988,913)
    AND PTP.PROT_GEN_ID = 3
    AND P.PEDF_ID                                         NOT IN (SELECT T.PEDF_PEDF_ID
                                                                    FROM PEDIDO_FAT_P T
                                                                    WHERE T.PEDF_PROD_ID = 52)
GROUP BY
    AR.GEN_DESCRICAO
    ,P.PEDF_GEN_ID
    ,GER.GEN_DESCRICAO
    ,P.PEDF_GEN_ID_SETOR_DE
    ,REP.GEN_DESCRICAO
    ,P.PEDF_GEN_ID_ROTA_DE
    ,VEN.GEN_DESCRICAO
    ,P.PEDF_ID
    ,P.PEDF_NR_NF
    ,P.PEDF_CLI_ID
    ,CL.CLI_RAZAO_SOCIAL
    ,CID.GEN_DESCRICAO
    ,UF.GEN_DESCRICAO
    ,EMB.GEN_ID
    ,EMB.GEN_DESCRICAO
    ,PP.PEDF_PROD_ID
    ,PR.PROD_DESC
    ,P.PEDF_DTA_EMIS
    ,O.OPER_GEN_ID_TP_OPERACAO_DE
    ,PP.MA_PEDF_VLR_TOT_DESC_BOLETO
    UNION ALL
    SELECT DISTINCT
    AR.GEN_DESCRICAO                                     AS AREA
    ,P.PEDF_GEN_ID                                        AS COD_GER
    ,GER.GEN_DESCRICAO                                    AS GERENTE
    ,P.PEDF_GEN_ID_SETOR_DE                               AS COD_REP
    ,REP.GEN_DESCRICAO                                    AS REPRESENTANTE
    ,P.PEDF_GEN_ID_ROTA_DE                                AS COD_VEND
    ,VEN.GEN_DESCRICAO                                    AS VENDEDOR
    ,AL.ENTR_ENTR_ID                                      AS PEDIDO
    ,EA.ENTR_NR_DOC                                       AS NOTA_FISCAL
    ,P.PEDF_CLI_ID                                        AS COD_CLI
    ,CL.CLI_RAZAO_SOCIAL                                  AS CLIENTE
    ,CID.GEN_DESCRICAO                                    AS CIDADE
    ,UF.GEN_DESCRICAO                                     AS UF
    ,EMB.GEN_ID                                           AS COD_EMB
    ,EMB.GEN_DESCRICAO                                    AS EMBALAGEM
    ,PP.PEDF_PROD_ID                                      AS COD_PROD
    ,PR.PROD_DESC                                         AS PRODUTO
    ,0                                                    AS VENDAS_GERAL
    ,DECODE(TO_CHAR(EA.ENTR_DTA_LANC,'MM'),1,'JANEIRO'
        ,2,'FEVEREIRO',3,'MARCO',4,'ABRIL',5,'MAIO',6
        ,'JUNHO',7,'JULHO',8,'AGOSTO',9,'SETEMBRO',10
        ,'OUTUBRO',11,'NOVEMBRO',12,'DEZEMBRO')          AS MES
    ,TO_CHAR(EA.ENTR_DTA_LANC,'YYYY')                     AS ANO
    ,SUM(EE.ENTR_PRECO + NVL(EI.ENTR_VLR_IMP,0) + NVL(EP.ENTR_VLR_IMP,0) + EE.ENTR_DESPESA)AS DEVOLUCOES
    ,0                                                    AS VALOR_ACORDO
    ,0                                                    AS DESC_BOLETO
    ,0                                                    AS DEV_DESC_BOLETO
    ,0                                                    AS A_FATURAR
    ,0                                                    AS CARTEIRA
    FROM PEDIDO_FAT P
    INNER JOIN OPERACAO_FAT O        ON O.OPER_ID                  = P.PEDF_OPER_ID
    INNER JOIN LIQUIDACAO LQ         ON LQ.LIQU_EMP_ID             = P.PEDF_LIQU_EMP_ID
                                    AND LQ.LIQU_ID                 = P.PEDF_LIQU_ID
    INNER JOIN ENTRADA_ALM_PEDIDO AL ON AL.ENTR_PEDF_EMP_ID        = P.PEDF_EMP_ID
                                    AND AL.ENTR_PEDF_ID            = P.PEDF_ID
    INNER JOIN ENTRADA_ALM EA        ON EA.ENTR_EMP_ID             = AL.ENTR_ENTR_EMP_ID
                                    AND EA.ENTR_ID                 = AL.ENTR_ENTR_ID
    INNER JOIN GENER     AR          ON AR.GEN_TGEN_ID             = P.PEDF_GEN_TGEN_ID_AREA_DE
                                    AND AR.GEN_EMP_ID              = P.PEDF_GEN_EMP_ID_AREA_DE
                                    AND AR.GEN_ID                  = P.PEDF_GEN_ID_AREA_DE
    INNER JOIN ENTRADA_ALM_E  EE     ON EE.ENTR_ENTR_EMP_ID        = EA.ENTR_EMP_ID
                                    AND EE.ENTR_ENTR_ID            = EA.ENTR_ID
    LEFT JOIN ENTRADA_ALM_EI  EI    ON EI.ENTR_ENTR_E_ENTR_EMP_ID = EE.ENTR_ENTR_EMP_ID
                                    AND EI.ENTR_ENTR_E_ENTR_ID     = EE.ENTR_ENTR_ID
                                    AND EI.ENTR_ENTR_E_ID          = EE.ENTR_ID
                                    AND EI.ENTR_TP_IMPOSTO         = 3
    LEFT JOIN ENTRADA_ALM_EI  EP    ON EP.ENTR_ENTR_E_ENTR_EMP_ID = EE.ENTR_ENTR_EMP_ID
                                    AND EP.ENTR_ENTR_E_ENTR_ID     = EE.ENTR_ENTR_ID
                                    AND EP.ENTR_ENTR_E_ID          = EE.ENTR_ID
                                    AND EP.ENTR_TP_IMPOSTO         = 2
    INNER JOIN GENER     GER    ON GER.GEN_TGEN_ID                 = P.PEDF_GEN_TGEN_ID
                                AND GER.GEN_EMP_ID                  = P.PEDF_GEN_EMP_ID
                                AND GER.GEN_ID                      = P.PEDF_GEN_ID
    INNER JOIN GENER     REP    ON REP.GEN_TGEN_ID                 = P.PEDF_GEN_TGEN_ID_SETOR_DE
                                AND REP.GEN_EMP_ID                  = P.PEDF_GEN_EMP_ID_SETOR_DE
                                AND REP.GEN_ID                      = P.PEDF_GEN_ID_SETOR_DE
    INNER JOIN GENER     VEN    ON VEN.GEN_TGEN_ID                 = P.PEDF_GEN_TGEN_ID_ROTA_DE
                                AND VEN.GEN_EMP_ID                  = P.PEDF_GEN_EMP_ID_ROTA_DE
                                AND VEN.GEN_ID                      = P.PEDF_GEN_ID_ROTA_DE
    INNER JOIN PEDIDO_FAT_P PP  ON PP.PEDF_PEDF_EMP_ID             = P.PEDF_EMP_ID
                                AND PP.PEDF_PEDF_ID                 = P.PEDF_ID
    INNER JOIN PRODUTO PR       ON PR.PROD_EMP_ID                  = PP.PEDF_PROD_EMP_ID
                                AND PR.PROD_ID                      = PP.PEDF_PROD_ID
                                AND EE.ENTR_PROD_EMP_ID             = PR.PROD_EMP_ID
                                AND EE.ENTR_PROD_ID                 = PR.PROD_ID

    INNER JOIN PRODUTO_TP PTP   ON PTP.PROT_PROD_EMP_ID  = PP.PEDF_PROD_EMP_ID
                                AND PTP.PROT_PROD_ID      = PP.PEDF_PROD_ID


    INNER JOIN PRODUTO_C   PC   ON PC.PROC_PROD_EMP_ID             = PR.PROD_EMP_ID
                                AND PC.PROC_PROD_ID                 = PR.PROD_ID
    INNER JOIN GENER    EMB     ON EMB.GEN_TGEN_ID                 = PC.PROC_GEN_TGEN_ID_EMBALAGEM_DE
                                AND EMB.GEN_EMP_ID                  = PC.PROC_GEN_EMP_ID_EMBALAGEM_DE
                                AND EMB.GEN_ID                      = PC.PROC_GEN_ID_EMBALAGEM_DE
    INNER JOIN CLIENTE   CL     ON CL.CLI_EMP_ID                   = P.PEDF_CLI_EMP_ID
                                AND CL.CLI_ID                       = P.PEDF_CLI_ID
    INNER JOIN CLIENTE_E  CE    ON CE.CLIE_CLI_EMP_ID              = CL.CLI_EMP_ID
                                AND CE.CLIE_CLI_ID                  = CL.CLI_ID
                                AND CE.CLIE_GEN_ID                  = 2
    INNER JOIN GENER     CID    ON CID.GEN_TGEN_ID                 = CE.CLIE_GEN_TGEN_ID_CIDADE_DE
                                AND CID.GEN_EMP_ID                  = CE.CLIE_GEN_EMP_ID_CIDADE_DE
                                AND CID.GEN_ID                      = CE.CLIE_GEN_ID_CIDADE_DE
    INNER JOIN GENER_A   CIDA   ON CIDA.GENA_GEN_TGEN_ID           = CID.GEN_TGEN_ID
                                AND CIDA.GENA_GEN_EMP_ID            = CID.GEN_EMP_ID
                                AND CIDA.GENA_GEN_ID                = CID.GEN_ID
    INNER JOIN GENER     UF     ON UF.GEN_TGEN_ID                  = CIDA.GENA_GEN_TGEN_ID_PROPRIETARIO_
                                AND UF.GEN_EMP_ID                   = CIDA.GENA_GEN_EMP_ID_PROPRIETARIO_D
                                AND UF.GEN_ID                       = CIDA.GENA_GEN_ID_PROPRIETARIO_DE
----------------------------------------------------------------------------------------------------------
    WHERE P.PEDF_SITUACAO                         = 0
        AND   EA.ENTR_OPER_ALM_ID                  IN (19,190)
        AND EA.ENTR_DTA_LANC                       >= TO_DATE('04/08/2023 00:00:00','DD/MM/YYYY HH24:MI:SS')
        AND EA.ENTR_DTA_LANC                       <= TO_DATE('05/08/2023 23:59:59','DD/MM/YYYY HH24:MI:SS')
        AND (EI.ENTR_TP_IMPOSTO                     = 3 or EI.ENTR_TP_IMPOSTO  is null )
        AND P.PEDF_EMP_ID                          = O.OPER_EMP_ID
        AND AL.ENTR_ENTR_EMP_ID                    = 2
        AND AL.ENTR_PEDF_ID                        IS NOT NULL
        AND PTP.PROT_GEN_ID = 3

    GROUP BY
        AR.GEN_DESCRICAO
        ,P.PEDF_GEN_ID
        ,GER.GEN_DESCRICAO
        ,P.PEDF_GEN_ID_SETOR_DE
        ,REP.GEN_DESCRICAO
        ,P.PEDF_GEN_ID_ROTA_DE
        ,VEN.GEN_DESCRICAO
        ,AL.ENTR_ENTR_ID
        ,EA.ENTR_NR_DOC
        ,P.PEDF_CLI_ID
        ,CL.CLI_RAZAO_SOCIAL
        ,CID.GEN_DESCRICAO
        ,UF.GEN_DESCRICAO
        ,EMB.GEN_ID
        ,EMB.GEN_DESCRICAO
        ,PP.PEDF_PROD_ID
        ,PR.PROD_DESC
        ,EA.ENTR_DTA_LANC
        ,O.OPER_GEN_ID_TP_OPERACAO_DE
        ) VENDAS
    GROUP BY
        VENDAS.AREA
    ,VENDAS.COD_GER
    ,VENDAS.GERENTE
    ,VENDAS.COD_REP
    ,VENDAS.REPRESENTANTE
    ,VENDAS.COD_VEND
    ,VENDAS.VENDEDOR
    ,VENDAS.COD_CLI
    ,VENDAS.CLIENTE
    ,VENDAS.COD_EMB
        ,VENDAS.EMBALAGEM
        ,VENDAS.COD_PROD
        ,VENDAS.PRODUTO
    ORDER BY
        1,2,3,4,5,6,7