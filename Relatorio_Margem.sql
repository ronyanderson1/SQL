select
    MA.PEDF_ID                         AS PEDIDO_MARGEM
   ,PEDF_ID_FAT                        AS PEDIDO_FAT
   ,MA.PEDF_LIQU_ID                    AS LIQUIDACAO
   ,C.CLI_ID
   ,C.CLI_RAZAO_SOCIAL                 AS CLIENTE
--   ,UF.GEN_DESCRICAO                   AS UF -- ESTADO
   ,MA.PEDF_VLR_TOT_PED                AS VALOR
   ,nvl(ma.pedf_perc_margem_atual,0)   AS MARGEM
   ,ma.pedf_situacao                   AS SITUACAO
   ,MA.PEDF_VLR_LUCRO_LIQUIDO          AS LUCRO_LIQUIDO
   ,MA.PEDF_VLR_TOT_PED                AS VL_TOT_PEDIDO
   ,MA.PEDF_DTA_CAD                    AS DATA_CADASTRO
   ,MA.PEDF_DTA_EMIS                   AS DATA_EMISSAO
   ,MA.PEDF_DTA_ENTREGA                AS DATA_ENTREGA
   ,MA.PEDF_NR_NF                      AS NR_NF
   ,MA.PEDF_SERIE_NF                   AS SERIE_NF
   ,MA.PEDF_LIB_ANALISTA               AS LIBERACAO
   ,MA.PEDF_EDI_NR_PEDIDO              AS NR_PEDIDO
   ,MA.PEDF_PEDF_ID_VENDA
from
   MA_PEDIDO_FAT   MA,
   CLIENTE         C,
   CLIENTE_E       CLI,
   GENER           CID,
   GENER_A         CID_P,
   GENER           UF,
   (SELECT
         P.PEDF_EMP_ID
        ,P.PEDF_ID      PEDF_ID_FAT
        ,P.PEDF_NR_NF   NR_NF
        ,P.PEDF_ID_ORIGEM2
     FROM PEDIDO_FAT P
     WHERE P.PEDF_EMP_ID = 2)    PF
WHERE MA.PEDF_EMP_ID                       = 2
  AND C.CLI_EMP_ID                         = PEDF_CLI_EMP_ID
  AND C.CLI_ID                             = PEDF_CLI_ID
--  AND MA.PEDF_PEDF_ID_VENDA                IS NULL
  AND MA.PEDF_EMP_ID                       = PF.PEDF_EMP_ID (+)
  AND MA.PEDF_ID                           = PF.PEDF_ID_ORIGEM2 (+)
  AND CLI.CLIE_GEN_ID_CIDADE_DE            = CID.GEN_ID
  AND CLI.CLIE_GEN_TGEN_ID_CIDADE_DE       = CID.GEN_TGEN_ID
  AND CLI.CLIE_GEN_EMP_ID_CIDADE_DE        = CID.GEN_EMP_ID
  AND CID.GEN_ID                           = CID_P.GENA_GEN_ID
  AND CID.GEN_TGEN_ID                      = CID_P.GENA_GEN_TGEN_ID
  AND CID.GEN_EMP_ID                       = CID_P.GENA_GEN_EMP_ID
  AND CID_P.GENA_GEN_TGEN_ID_PROPRIETARIO_ = UF.GEN_TGEN_ID
  AND CID_P.GENA_GEN_EMP_ID_PROPRIETARIO_D = UF.GEN_EMP_ID
  AND CID_P.GENA_GEN_ID_PROPRIETARIO_DE    = UF.GEN_ID
  AND CLI.CLIE_CLI_EMP_ID                  = C.CLI_EMP_ID
  AND CLI.CLIE_CLI_ID                      = C.CLI_ID
  AND CLI.CLIE_CLI_EMP_ID                  = 2
  AND CLI.CLIE_GEN_ID                      = 2
  AND MA.PEDF_DTA_CAD                      >= '01/10/2022'
ORDER BY MA.Pedf_Dta_Cad desc
;
