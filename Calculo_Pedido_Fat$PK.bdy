CREATE OR REPLACE PACKAGE BODY Calculo_Pedido_Fat$PK AS

FUNCTION Obter_Vlr_Mercadoria_Lei13097 RETURN REAL IS
  V_SAIDA   REAL := 0;
  V_MVA   REAL := 0;
  V_VLR_ST_TEMP   REAL := 0;
  V_MVA_S_DES   REAL := 0;
  V_MVA_IPI     REAL := 0;
  V_SAIDA_TEMP_UNIT   REAL := 0;
  V_ALIQ_ICM_TEMP     REAL := 0;
  V_ALIQ_RED_VLR_ICMS REAL := 0;
  V_DENOMINADOR_IVA_13097    REAL := 0;
  V_DENOMINADOR_MVA_13097    REAL := 0;
  V_FATOR_MVA                REAL := 0;
  V_DESCONTO_IPI             REAL := 0;
  DIF                        REAL := 0;
  PFABRICA                   REAL := 0;


  BEGIN
    V_VALOR_ADC_FINANC_ITEM := 0;
    V_VALOR_MERC_ALIQ_IPI_DIF := 0;
    V_VALOR_MERCADORIA_MVA    := 0;
    V_IPI := 0;
    V_SAIDA    := 0;
    V_MVA      := 0;
    V_VLR_ST_TEMP := 0;
    V_MVA_S_DES   := 0;
    V_MVA_IPI     := 0;
    V_SAIDA_TEMP_UNIT   := 0;
    V_ALIQ_ICM_TEMP     := 0;
    V_ALIQ_RED_VLR_ICMS := 0;
    V_DENOMINADOR_IVA_13097    := 0;
    V_DENOMINADOR_MVA_13097    := 0;
    V_FATOR_MVA                := 0;
    V_DESCONTO_IPI             := 0;
    DIF                        := 0;

    IF (V_TPRC_ALQ_ST_DIF > 0) AND (V_PEDF_PERC_DESC_ORIGINAL > 0) AND (V_PEDF_TPRC_MARGEM_LUCRO > 0) THEN
        V_ALIQ_ICM_TEMP := V_ALIQ_ICM;
        V_ALIQ_ICM      := V_TPRC_ALQ_ST_DIF;
    END IF;

    IF /*(V_OPER_TIPO_REDUCAO = 2) And*/ (V_ALIQ_ICM_REDUCAO > 0 ) THEN --essa alteração foi feita para a redução do valor do ICMS e qto tem IVA c/ IPI
        V_ALIQ_RED_VLR_ICMS       := round(V_ALIQ_ICM * ((100 - V_ALIQ_ICM_REDUCAO) /100),2);
     ELSE
       V_ALIQ_RED_VLR_ICMS        := V_ALIQ_ICM;
    END IF;

    IF V_SEG_ADICIONAL <> 0 THEN --SEGUNDO ADICIONAL
      V_VALOR_ADC_FINANC_ITEM := (V_PFAT_P_TPRC_PRC_FINAL + V_PFAT_P_TPRC_PRC_FRETE) *
                                  ((V_PFAT_CVTO_P_MAX_DIAS *
                                   V_SEG_ADICIONAL)
                                   /100);
    ELSE --ADICIONAL PADWRAO
      V_VALOR_ADC_FINANC_ITEM := ROUND((V_PFAT_P_TPRC_PRC_FINAL + V_PFAT_P_TPRC_PRC_FRETE) *
                                  ((V_PFAT_CVTO_P_MAX_DIAS *
                                   V_PFAT_ADC_FIN_GEN_NUMBER1)
                                   /100),2);
    END IF;
    IF V_PEDF_TPRC_MARGEM_LUCRO > 0 THEN
      V_FATOR_IPI :=  ((V_PEDF_TPRC_MARGEM_LUCRO/100) * (V_ALIQ_SUBST /100) ) +1;
      V_FATOR_IVA :=  (V_PEDF_TPRC_MARGEM_LUCRO/100);
      --V_ALIQ_IVA_13097 := (V_FATOR_IPI-(V_ALIQ_RED_VLR_ICMS /100) +((V_ALIQ_SUBST -V_ALIQ_RED_VLR_ICMS)/100));
      V_DENOMINADOR_IVA_13097 :=(1+ (V_PFAT_P_PROF_ALIQ_IPI / 100)) + ((1 + (V_PFAT_P_PROF_ALIQ_IPI / 100)) * V_FATOR_IVA * (V_ALIQ_SUBST/100)) - 1 * (V_ALIQ_RED_VLR_ICMS / 100);
    ELSE
      V_FATOR_IPI := 0;
      V_FATOR_IVA := 0;

    END IF;
    IF ((V_PEDF_TPRC_MARGEM_LUCRO > 0)
         AND (V_SUBS_TAB = 1)
         AND (V_PEDF_PERC_DESC_ORIGINAL > 0)
         AND (V_oper_aliq_st_ret = 'N')
         ) THEN

      if V_PFAT_P_PROF_ALIQ_IPI > 0 then
        /* V_SAIDA := ((((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100))-
                     ((V_PFAT_P_PROF_ALIQ_IPI /100)*V_FATOR_IPI))/ V_ALIQ_IVA_13097) + V_PFAT_P_TPRC_PRC_FRETE ) * V_PFAT_P_PEDF_QTDE;
           */
           V_SAIDA := (((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100))
                      / V_DENOMINADOR_IVA_13097) + V_PFAT_P_TPRC_PRC_FRETE ) * V_PFAT_P_PEDF_QTDE;

          V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(V_PFAT_P_PEDF_PERC_DESC,0)) / 100),5);
          V_SAIDA := ROUND(V_SAIDA,2) + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);
       else
           V_SAIDA := ( (/*preço mercadoria calculado c/ IVA INI*/
                       ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                       ((  (V_PFAT_P_TPRC_PRC_FAB_MEC - (V_PFAT_P_TPRC_PRC_FAB_MEC * V_PFAT_P_PEDF_PERC_DESC / 100) + NVL(V_PFAT_P_PROF_VLR_IPI,0)) * V_PEDF_TPRC_MARGEM_LUCRO / 100   )
                        * V_ALIQ_SUBST / 100) - NVL(V_PFAT_P_PROF_VLR_IPI,0)) /
                       ((100 - V_ALIQ_RED_VLR_ICMS) / 100)) /*preço mercadoria calculado c/ IVA FIM*/
                      + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;

         V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(V_PFAT_P_PEDF_PERC_DESC,0)) / 100),5);
         V_SAIDA := ROUND(V_SAIDA,2) + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);
      end if;
    ELSIF ((V_PEDF_TPRC_MARGEM_LUCRO > 0)
       AND (V_SUBS_TAB = 1)
       AND (V_TIPO_PESSOA = 1)
       AND (V_ALIQ_ICM > 0)
       AND (V_ALIQ_SUBST > 0)
       AND (V_oper_aliq_st_ret = 'N')
       ) THEN
      if V_PFAT_P_PROF_ALIQ_IPI > 0 then
          V_SAIDA := (((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100))
                      / V_DENOMINADOR_IVA_13097) + V_PFAT_P_TPRC_PRC_FRETE ) * V_PFAT_P_PEDF_QTDE;

          V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(V_PFAT_P_PEDF_PERC_DESC,0)) / 100),5);
          V_SAIDA := ROUND(V_SAIDA,2) + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);
       else
      --CÁLCULO COM IVA PARA PESSOA FÍSICA COM OU SEM DESCONTO
              V_SAIDA := ( (((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * (NVL(V_PEDF_PERC_DESC_ORIGINAL,0) / 100))) -
                           (((V_PFAT_P_TPRC_PRC_FAB_MEC - (V_PFAT_P_TPRC_PRC_FAB_MEC * (NVL(V_PFAT_P_PEDF_PERC_DESC,0) / 100)) +
                              NVL(V_PFAT_P_PROF_VLR_IPI,0)) * V_PEDF_TPRC_MARGEM_LUCRO / 100) * V_ALIQ_SUBST / 100) -
                              NVL(V_PFAT_P_PROF_VLR_IPI,0)) / ((100 - V_ALIQ_RED_VLR_ICMS) / 100)) + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;

              V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(V_PFAT_P_PEDF_PERC_DESC,0)) / 100),5);
              V_SAIDA := ROUND(V_SAIDA,2) + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);
         END IF ;
    ELSIF ((V_SUBS_TAB = 1) AND (V_PEDF_PERC_DESC_ORIGINAL >0)AND (V_oper_aliq_st_ret = 'N')) or (V_USAR_REGRA_PAR_ALIQUOTA = 1 and V_PFAT_OPER_TIPO_ICMR <> 2)  THEN

      IF (V_PFAT_P_TPRC_BASE_SUBST > 0) THEN
        IF V_ALIQ_ICM_REDUCAO > 0 THEN
          V_SAIDA := ( (/*preço mercadoria calculado c/ desconto INI*/
                       ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                       (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                       ((100 - V_ALIQ_RED_VLR_ICMS + V_PFAT_P_PROF_ALIQ_IPI) / 100)) /*preço mercadoria calculado c/ desconto FIM*/
                      + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;


          V_VLR_MERC_ICMS_PARA_ST :=  ( (/*preço mercadoria calculado c/ desconto INI*/
                       ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                       (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                       ((100 - V_ALIQ_RED_VLR_ICMS + V_PFAT_P_PROF_ALIQ_IPI) / 100)) /*preço mercadoria calculado c/ desconto FIM*/
                      + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;
       ELSE
          if V_OPER_ALIQ_ICM_DIF > 0 then
             V_ALIQ_ICM_TEMP := V_ALIQ_ICM;
             V_ALIQ_ICM      := V_OPER_ALIQ_ICM_DIF;
          end if;
           if   (V_AGREGA_IPI_FIS = 0) AND (V_TIPO_PESSOA = 1) then -- FORMULA DIFERENTE QTO PF E SOMA IPI NA BASE ICM
                  V_SAIDA := ( (
                               ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                               (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                               (((100 - V_ALIQ_RED_VLR_ICMS) + V_PFAT_P_PROF_ALIQ_IPI - (V_ALIQ_RED_VLR_ICMS * (V_PFAT_P_PROF_ALIQ_IPI/100))) / 100))
                                + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;


                      V_SAIDA_TEMP_UNIT := ( (--ESSE CALCULO E FEITO PRA UMA UNIDADE DO ITEM  PARA SABER SE E MAIOR QUE A BASE DE S.T
                                               ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                                               (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100)- V_PFAT_P_PROF_VLR_IPI) /
                                               (((100 - V_ALIQ_RED_VLR_ICMS) + V_PFAT_P_PROF_ALIQ_IPI - (V_ALIQ_RED_VLR_ICMS * (V_PFAT_P_PROF_ALIQ_IPI/100))) / 100))
                                              + V_PFAT_P_TPRC_PRC_FRETE);
                      if V_PFAT_P_TPRC_BASE_SUBST > 0 then
                            V_VLR_ST_TEMP := (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - (V_SAIDA_TEMP_UNIT * V_ALIQ_RED_VLR_ICMS / 100);
                            If (V_SAIDA_TEMP_UNIT > V_PFAT_P_TPRC_BASE_SUBST) and (V_VLR_ST_TEMP < 0 ) Then
                                V_SAIDA := ( (/*preço mercadoria calculado c/ desconto INI*/
                                       (V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                                       - V_PFAT_P_PROF_VLR_IPI - ((V_PFAT_P_TPRC_PRC_FAB_MEC - (V_PFAT_P_TPRC_PRC_FAB_MEC * NVL(V_PFAT_P_PEDF_PERC_DESC,0) / 100))
                                       * (V_PFAT_P_PROF_ALIQ_IPI/100))
                                    ) /*preço mercadoria calculado c/ desconto FIM*/
                                       + V_PFAT_P_TPRC_PRC_FRETE
                                  ) * V_PFAT_P_PEDF_QTDE;
                            End If;
                      end if;
             ELSE
             if  ((V_SUBS_TAB = 1) AND (V_PEDF_PERC_DESC_ORIGINAL >0)AND (V_oper_aliq_st_ret = 'N')) or ( V_USAR_PRECO_FINAL = 0) then
                V_SAIDA := ((
                               ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                               (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                               ((100 - V_ALIQ_RED_VLR_ICMS + V_PFAT_P_PROF_ALIQ_IPI) / 100)) /*preço mercadoria calculado c/ desconto FIM*/
                              + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;


                      V_SAIDA_TEMP_UNIT := ( (--ESSE CALCULO E FEITO PRA UMA UNIDADE DO ITEM  PARA SABER SE E MAIOR QUE A BASE DE S.T
                                               ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                                               (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100)- V_PFAT_P_PROF_VLR_IPI) /
                                               ((100 - V_ALIQ_RED_VLR_ICMS + V_PFAT_P_PROF_ALIQ_IPI) / 100))
                                              + V_PFAT_P_TPRC_PRC_FRETE);




              if V_PFAT_P_TPRC_BASE_SUBST > 0 then
                     V_VLR_ST_TEMP := (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - (V_SAIDA_TEMP_UNIT * V_ALIQ_RED_VLR_ICMS / 100);
                    If (V_SAIDA_TEMP_UNIT > V_PFAT_P_TPRC_BASE_SUBST) and (V_VLR_ST_TEMP < 0 ) Then
                        V_SAIDA := ( (/*preço mercadoria calculado c/ desconto INI*/
                                       (V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                                       - V_PFAT_P_PROF_VLR_IPI - ((V_PFAT_P_TPRC_PRC_FAB_MEC - (V_PFAT_P_TPRC_PRC_FAB_MEC * NVL(V_PFAT_P_PEDF_PERC_DESC,0) / 100))
                                       * (V_PFAT_P_PROF_ALIQ_IPI/100))
                                    ) /*preço mercadoria calculado c/ desconto FIM*/
                                       + V_PFAT_P_TPRC_PRC_FRETE
                                  ) * V_PFAT_P_PEDF_QTDE;
                    End If;
              end if;
           ELSE
                 V_SAIDA := ROUND((V_PFAT_P_TPRC_PRC_FAB_MEC + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE,2) +
                 ROUND((V_VALOR_ADC_FINANC_ITEM) * V_PFAT_P_PEDF_QTDE,2);
                 V_VALOR_MERCADORIA_MVA := V_SAIDA;
                 V_VLR_MERC_ICMS_PARA_ST := V_SAIDA;
           END IF;
         END IF;
        END IF;
      ELSE
     if (v_TPRC_ALIQ_MVA > 0) And (v_TPRC_ALIQ_ST_MVA > 0)    then
      IF V_PFAT_P_PROF_ALIQ_IPI > 0 THEN
          V_FATOR_MVA :=  (v_TPRC_ALIQ_MVA/100);
          IF (V_oper_aliq_st_ret = 'S') AND (V_OPER_ALIQ_RED_BC_ICM_OE > 0)AND (V_USAR_REGRA_PAR_ALIQUOTA = 1) then

           V_DENOMINADOR_MVA_13097 := (1+ (V_PFAT_P_PROF_ALIQ_IPI / 100)) + ((1 + (V_PFAT_P_PROF_ALIQ_IPI / 100))
                    * V_FATOR_MVA * (V_ALIQ_SUBST/100)+((1 + (V_PFAT_P_PROF_ALIQ_IPI / 100)) * (V_ALIQ_SUBST/100)))
                    * (1 - (V_OPER_ALIQ_RED_BC_ICM_OE/100)) - 1 * (V_ALIQ_RED_VLR_ICMS / 100);

             V_SAIDA := (((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100))
                          / V_DENOMINADOR_MVA_13097) + V_PFAT_P_TPRC_PRC_FRETE ) * V_PFAT_P_PEDF_QTDE;

              if V_PEDF_PERC_DESC_ORIGINAL = 0 then
                  if  V_PFAT_P_TPRC_PRC_FAB_MEC <> V_SAIDA THEN
                      DIF := V_SAIDA - V_PFAT_P_TPRC_PRC_FAB_MEC;

                   END IF;
              END IF;
              V_VALOR_MERCADORIA_MVA := V_SAIDA;
          else
             if V_PEDF_PERC_DESC_ORIGINAL > 0 then
                   V_DENOMINADOR_MVA_13097 := (1+ (V_PFAT_P_PROF_ALIQ_IPI / 100)) + ((1 + (V_PFAT_P_PROF_ALIQ_IPI / 100))
                          * V_FATOR_MVA * (V_ALIQ_SUBST/100)+((1 + (V_PFAT_P_PROF_ALIQ_IPI / 100)) * (V_ALIQ_SUBST/100)))
                          - 1 * (V_ALIQ_RED_VLR_ICMS / 100);
                          -- -1 * (V_ALIQ_RED_VLR_ICMS * V_ALIQ_ICM_REDUCAO / 100 );
                   V_SAIDA := (((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100))
                                / V_DENOMINADOR_MVA_13097) + V_PFAT_P_TPRC_PRC_FRETE ) * V_PFAT_P_PEDF_QTDE;

                    V_VALOR_MERCADORIA_MVA := V_SAIDA;

              else
                 V_SAIDA := ROUND((V_PFAT_P_TPRC_PRC_FAB_MEC + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE,2) +
                 ROUND((V_VALOR_ADC_FINANC_ITEM) * V_PFAT_P_PEDF_QTDE,2);
                 V_VALOR_MERCADORIA_MVA := V_SAIDA;
                 V_VLR_MERC_ICMS_PARA_ST := V_SAIDA;

              end if;
           end if;

       ELSE

           if V_PEDF_PERC_DESC_ORIGINAL > 0 then
                     V_MVA_IPI := V_PFAT_P_PROF_VLR_IPI ;
                     V_MVA_S_DES := (V_PFAT_P_TPRC_PRC_FAB_MEC + NVL(V_MVA_IPI,0) ) * (v_TPRC_ALIQ_MVA / 100) +
                                      (V_PFAT_P_TPRC_PRC_FAB_MEC + NVL(V_MVA_IPI,0));

                     V_MVA_S_DES := V_MVA_S_DES - (V_MVA_S_DES *   (V_OPER_ALIQ_RED_BC_ICM_OE/100));
                     V_MVA_S_DES := (V_MVA_S_DES * (V_ALIQ_SUBST / 100)) -  (V_PFAT_P_TPRC_PRC_FAB_MEC * v_TPRC_ALIQ_ST_MVA/100);
                     V_MVA_S_DES := ( V_MVA_S_DES *  (V_PEDF_PERC_DESC_ORIGINAL /100));

                     V_MVA := (
                                (V_VLR_DESC_PFAB + NVL(V_MVA_IPI,0) + V_MVA_S_DES
                                    )  * (v_TPRC_ALIQ_MVA / 100)  +
                                            (V_VLR_DESC_PFAB + V_MVA_S_DES+ NVL( V_MVA_IPI,0)) --BASE ST MVA
                              )  * (V_ALIQ_SUBST/ 100) - (V_VLR_DESC_PFAB + V_MVA_S_DES) *(v_TPRC_ALIQ_ST_MVA/100);

                    V_SAIDA := (V_VLR_DESC_PFINAL - V_MVA - V_MVA_IPI) * V_PFAT_P_PEDF_QTDE;
                    V_VALOR_MERCADORIA_MVA := V_SAIDA;
             else
                 V_SAIDA := ROUND((V_PFAT_P_TPRC_PRC_FAB_MEC + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE,2) +
                 ROUND((V_VALOR_ADC_FINANC_ITEM) * V_PFAT_P_PEDF_QTDE,2);
                 V_VALOR_MERCADORIA_MVA := V_SAIDA;
                 V_VLR_MERC_ICMS_PARA_ST := V_SAIDA;

           END IF;
         end if ;

       ELSE--aqui

          if V_PFAT_P_TPRC_BASE_SUBST > 0 then
           if   (V_AGREGA_IPI_FIS = 0) AND (V_TIPO_PESSOA = 1)
           then -- FORMULA DIFERENTE QTO PF E SOMA IPI NA BASE ICM
                 V_SAIDA := ( (
                               ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                               (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                               (((100 - V_ALIQ_RED_VLR_ICMS) + V_PFAT_P_PROF_ALIQ_IPI - (V_ALIQ_RED_VLR_ICMS * (V_PFAT_P_PROF_ALIQ_IPI/100))) / 100))
                              + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;
              ELSE
                  V_SAIDA := ( (
                               ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                               (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                               ((100 - V_ALIQ_RED_VLR_ICMS + V_PFAT_P_PROF_ALIQ_IPI) / 100)) /*preço mercadoria calculado c/ desconto FIM*/
                              + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;
          END IF;

           else


              V_SAIDA := ( (
                           ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                           (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                           ((100  + V_PFAT_P_PROF_ALIQ_IPI) / 100)) --NAO TEM ST NAO  ENTRA ALQUOTA ICMS NA FORMULA
                          + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;
             end if;

          -- end if;


        V_SAIDA_TEMP_UNIT := ( (--ESSE CALCULO E FEITO PRA UMA UNIDADE DO ITEM  PARA SABER SE E MAIOR QUE A BASE DE S.T
                                 ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                                 (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                                  ((100 - V_ALIQ_RED_VLR_ICMS + V_PFAT_P_PROF_ALIQ_IPI) / 100))
                                + V_PFAT_P_TPRC_PRC_FRETE);
         if V_PFAT_P_TPRC_BASE_SUBST > 0  then
            V_VLR_ST_TEMP := (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - (V_SAIDA_TEMP_UNIT * V_ALIQ_RED_VLR_ICMS / 100);
          If (V_SAIDA_TEMP_UNIT > V_PFAT_P_TPRC_BASE_SUBST) and (V_VLR_ST_TEMP < 0 ) Then
            V_SAIDA := ( (/*preço mercadoria calculado c/ desconto INI*/
                                       (V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                                       - V_PFAT_P_PROF_VLR_IPI - ((V_PFAT_P_TPRC_PRC_FAB_MEC - (V_PFAT_P_TPRC_PRC_FAB_MEC * NVL(V_PFAT_P_PEDF_PERC_DESC,0) / 100))
                                       * (V_PFAT_P_PROF_ALIQ_IPI/100))
                                    ) /*preço mercadoria calculado c/ desconto FIM*/
                                       + V_PFAT_P_TPRC_PRC_FRETE
                                  ) * V_PFAT_P_PEDF_QTDE;
           End If;
        end if ;

        END IF;

      END IF;

         V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(round(V_PFAT_P_PEDF_PERC_DESC,4),0)) / 100),5);
         V_SAIDA := ROUND(V_SAIDA,2) + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);

    ELSIF (V_PFAT_P_PROM_CVTO_ID = -1) THEN
      V_SAIDA := ROUND((V_PFAT_P_TPRC_PRC_FAB_MEC + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE,2) +
                 ROUND((V_VALOR_ADC_FINANC_ITEM) * V_PFAT_P_PEDF_QTDE,2);
      V_VALOR_MERCADORIA_MVA := V_SAIDA;
      V_VLR_MERC_ICMS_PARA_ST := V_SAIDA;

    ELSE
      V_SAIDA := ROUND((V_PFAT_P_TPRC_PRC_FAB_MEC + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE,2) +
                 ROUND((V_VALOR_ADC_FINANC_ITEM) * V_PFAT_P_PEDF_QTDE,2);




    END IF;

     IF  v_REGRA_CORTE_GATILHO = 5 THEN
                 if (V_PFAT_P_PROF_ALIQ_IPI = 0) and(V_OPER_SUFRAMA <> 'S')  then
                      V_SAIDA := ( (
                                   ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                                   (((V_PFAT_P_PROF_VLR_IPI + V_PFAT_P_TPRC_PRC_FAB_MEC) - (V_PFAT_P_TPRC_PRC_FAB_MEC * round(V_PFAT_P_PEDF_PERC_DESC,4) / 100))
                                                * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                                   ((100  + V_PFAT_P_PROF_ALIQ_IPI) / 100)) --NAO TEM ST NAO  ENTRA ALQUOTA ICMS NA FORMULA
                                  + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;
                       --PFABRICA := Calc_fabricaFB(30,0,0.92593,0.27,1.296, 1 ,0.06, 0,0, 0.91667,1.4,0.27,0,'N');
                  else
                      IF NVL(V_PFAT_P_PROF_ALIQ_IPI,0) = 0 THEN
                         V_PAUTA_IPI_REGRA_PRC := 0;
                         V_ALIQ_IPI_REGRA_PRC  := 0;
                      END IF;

                      PFABRICA := Calc_fabricaFB(V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)
                                         ,0
                                         ,V_ALIQ_ICM_REDUCAO/100 --ALIQ REDUÇÃO
                                         ,V_ALIQ_RED_VLR_ICMS/100 -- ALIQ ICMS
                                         ,0 --IPI PAUTA
                                         ,1
                                         ,V_ALIQ_IPI_REGRA_PRC/100 --ALIQ IPI
                                         ,0
                                         ,0
                                         ,(V_OPER_ALIQ_RED_BC_ICM_OE /100) -- ALIQ REDUÇÃO BASE ST
                                         ,v_TPRC_ALIQ_MVA/100 --ALIQ MAG LUCRO MVA
                                         ,V_ALIQ_SUBST/100 --ALIQ ST DO MVA
                                         ,V_PEDF_TPRC_MARGEM_LUCRO/100
                                         ,V_PFAT_P_TPRC_PRC_FRETE
                                         ,'T'
                                         ,V_OPER_SUFRAMA
                                         ,0
                                         ,0);
              V_SAIDA := PFABRICA * V_PFAT_P_PEDF_QTDE;
           end if;
         V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(round(V_PFAT_P_PEDF_PERC_DESC,4),0)) / 100),5);
         V_SAIDA := ROUND(V_SAIDA,2) + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);
    ELSE
                IF (v_CLI_ST_REGIME_CNAE = 'S')and (V_PFAT_OPER_DESTINO_OPER = 2) AND (V_SUBS_TAB = 1) AND (V_PEDF_PERC_DESC_ORIGINAL >0) THEN
                    PFABRICA := Calc_fabricaFB(V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)
                                                     ,0
                                                     ,V_ALIQ_ICM_REDUCAO/100 --ALIQ REDUÇÃO
                                                     ,V_ALIQ_RED_VLR_ICMS/100 -- ALIQ ICMS
                                                     ,V_PAUTA_IPI_REGRA_PRC --IPI PAUTA
                                                     ,1
                                                     ,V_ALIQ_IPI_REGRA_PRC/100 --ALIQ IPI
                                                     ,0
                                                     ,0
                                                     ,(V_OPER_ALIQ_RED_BC_ICM_OE /100) -- ALIQ REDUÇÃO BASE ST
                                                     ,0 --ALIQ MAG LUCRO MVA
                                                     ,V_ALIQ_SUBST/100 --ALIQ ST
                                                     ,0 --ALIQ MARGEM DE LUCRO
                                                     ,V_PFAT_P_TPRC_PRC_FRETE
                                                     ,'S'
                                                     ,V_OPER_SUFRAMA
                                                     ,0
                                                     ,0);

                     V_SAIDA := PFABRICA * V_PFAT_P_PEDF_QTDE;
                     V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(round(V_PFAT_P_PEDF_PERC_DESC,4),0)) / 100),5);
                     V_SAIDA := ROUND(V_SAIDA,2) + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);
                 END IF;
       end if;
       IF (V_UF_EMPRESA <> V_UF_CLIENTE) --VENDA FORA DO ESTADO ICMS_ST DIFAL
             AND (NVL(V_GATILHO_PER_MVA,0) = 0)
             AND (V_PFAT_OPER_TIPO_ICMR <> 2)
             AND (NVL(v_REGRA_CORTE_GATILHO,0) = 0)
             AND (NVL(V_USAR_CALC_ST_DIFAL,0) = 1)
             AND (NVL(V_ALIQ_ICMS_UF_DEST,0)>0
             AND (NVL(V_ALIQ_ICM,0) >0)  )
             AND (NVL(V_PEDF_PERC_DESC_ORIGINAL,0)>0)

          THEN
             PFABRICA := Calc_fabricaFB(V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)
                                         ,0
                                         ,V_ALIQ_ICM_REDUCAO/100 --ALIQ REDUÇÃO
                                         ,V_ALIQ_RED_VLR_ICMS/100 -- ALIQ ICMS
                                         ,V_PAUTA_IPI_REGRA_PRC --IPI PAUTA
                                         ,1
                                         ,V_ALIQ_IPI_REGRA_PRC/100 --ALIQ IPI
                                         ,V_PFAT_P_TPRC_BASE_SUBST -- PAUTA ST
                                         ,0
                                         ,(V_OPER_ALIQ_RED_BC_ICM_OE /100) -- ALIQ REDUÇÃO BASE ST
                                         ,v_TPRC_ALIQ_MVA/100 --ALIQ MAG LUCRO MVA
                                         ,V_ALIQ_SUBST/100 --ALIQ ST DO MVA
                                         ,V_PEDF_TPRC_MARGEM_LUCRO/100
                                         ,V_PFAT_P_TPRC_PRC_FRETE
                                         ,'F'
                                         ,V_OPER_SUFRAMA
                                         ,V_ALIQ_ICMS_UF_DEST/100 -- ALIQUOTA INTERNA PEGA GENER ESTADO NR01
                                         ,V_ALIQ_RED_VLR_ICMS/100);--Aliq_InterEstadual
              V_SAIDA := PFABRICA * V_PFAT_P_PEDF_QTDE;
              V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(round(V_PFAT_P_PEDF_PERC_DESC,4),0)) / 100),5);
              V_SAIDA := ROUND(V_SAIDA,2) + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);
          END IF;

    IF V_PFAT_P_PROF_COD_ICM = 2 THEN
       V_VALOR_ISENTO_ICM := V_SAIDA;
    END IF;
    IF V_PFAT_P_PROF_ALIQ_IPI > 0 THEN
        IF (V_PFAT_PEDF_VLR_DESC <> 0) AND (V_DESC_BASE_IPI = 1) THEN
          V_DESCONTO_IPI  := RATIAR_VALOR(V_VLR_TOT_MERCADORIA , V_PFAT_PEDF_VLR_DESC, (V_PFAT_P_TPRC_PRC_FAB * V_PFAT_P_PEDF_QTDE));
        END IF;
       V_IPI := (V_SAIDA + V_PRECO_FRETE_IPI - V_DESCONTO_IPI ) *(V_PFAT_P_PROF_ALIQ_IPI/100 );
     END IF ;
     if V_SAIDA < 0 then
       V_SAIDA := 0;
     end if;
     if (v_TPRC_ALIQ_MVA > 0) And (v_TPRC_ALIQ_ST_MVA > 0)
        and (V_VALOR_MERCADORIA_MVA = 0) and (V_SAIDA > 0) then
        V_VALOR_MERCADORIA_MVA := V_SAIDA;
     end if;

    IF V_ALIQ_ICM_TEMP  > 0 THEN
        V_ALIQ_ICM := V_ALIQ_ICM_TEMP;
    END IF ;
    RETURN(V_SAIDA);
   END Obter_Vlr_Mercadoria_Lei13097;



FUNCTION Obter_Valor_Mercadoria RETURN REAL IS
  V_SAIDA   REAL := 0;
  V_MVA   REAL := 0;
  V_MVA_S_DES   REAL := 0;
  V_VLR_ST_TEMP   REAL := 0;
  V_SAIDA_TEMP_UNIT      REAL := 0;
  V_ALIQ_ICM_TEMP         REAL := 0;
  V_DESCONTO_IPI          REAL := 0;
  PFABRICA                   REAL := 0;
   V_TP_CALC                  VARCHAR(1) := NULL ;
  V_VALOR_SUBST_FUNC          REAL := 0;
    V_VALOR_BASE_ST_FUNC        REAL := 0;

  V_ALIQ_RED_VLR_ICMS REAL := 0;
  BEGIN
    V_VALOR_ADC_FINANC_ITEM := 0;
    V_VALOR_MERC_ALIQ_IPI_DIF := 0;
    V_IPI := 0;
    V_VALOR_MERCADORIA_MVA    := 0;
    V_SAIDA   := 0;
    V_MVA     := 0;
    V_MVA_S_DES   := 0;
    V_VLR_ST_TEMP := 0;
    V_SAIDA_TEMP_UNIT  := 0;
    V_ALIQ_ICM_TEMP    := 0;
    V_DESCONTO_IPI     := 0;
    PFABRICA           := 0;
    V_TP_CALC          := NULL;
    V_VALOR_ICM_SUBST          := 0;
    V_VALOR_BASE_ST_FUNC       := 0;
    IF (V_TPRC_ALQ_ST_DIF > 0) AND (V_PEDF_PERC_DESC_ORIGINAL > 0) AND (V_PEDF_TPRC_MARGEM_LUCRO > 0) THEN
        V_ALIQ_ICM_TEMP := V_ALIQ_ICM;
        V_ALIQ_ICM      := V_TPRC_ALQ_ST_DIF;
    END IF;
    IF (V_OPER_TIPO_REDUCAO = 2) And (V_ALIQ_ICM_REDUCAO > 0 ) THEN --essa alteração foi feita para a redução do valor do ICMS e qto tem IVA c/ IPI
        V_ALIQ_RED_VLR_ICMS       := round(V_ALIQ_ICM * ((100 - V_ALIQ_ICM_REDUCAO) /100),2);
     ELSE
       V_ALIQ_RED_VLR_ICMS        := V_ALIQ_ICM;
    END IF;

    IF V_SEG_ADICIONAL <> 0 THEN --SEGUNDO ADICIONAL
      V_VALOR_ADC_FINANC_ITEM := (V_PFAT_P_TPRC_PRC_FINAL + V_PFAT_P_TPRC_PRC_FRETE) *
                                  ((V_PFAT_CVTO_P_MAX_DIAS *
                                   V_SEG_ADICIONAL)
                                   /100);
    ELSE --ADICIONAL PADWRAO
      V_VALOR_ADC_FINANC_ITEM := ROUND((V_PFAT_P_TPRC_PRC_FINAL + V_PFAT_P_TPRC_PRC_FRETE) *
                                  ((V_PFAT_CVTO_P_MAX_DIAS *
                                   V_PFAT_ADC_FIN_GEN_NUMBER1)
                                   /100),2);
    END IF;

    IF ((V_PEDF_TPRC_MARGEM_LUCRO > 0)
         AND (V_SUBS_TAB = 1)
         AND (V_PEDF_PERC_DESC_ORIGINAL > 0)
         AND (V_oper_aliq_st_ret = 'N')
         ) THEN

      if (V_ALIQ_ICM_REDUCAO > 0 ) and (V_OPER_TIPO_REDUCAO = 1) and (V_OPER_NAO_RED_BASE_ST_IVA = 'S') THEN
           V_SAIDA := ( (/*preço mercadoria calculado c/ IVA INI*/
                   ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                   ((  (V_PFAT_P_TPRC_PRC_FAB_MEC - (V_PFAT_P_TPRC_PRC_FAB_MEC * V_PFAT_P_PEDF_PERC_DESC / 100)
                      + NVL(V_PFAT_P_PROF_VLR_IPI,0))  * V_ALIQ_ICM_REDUCAO/100 * V_PEDF_TPRC_MARGEM_LUCRO / 100   )
                    * V_ALIQ_SUBST / 100) - NVL(V_PFAT_P_PROF_VLR_IPI,0)) /
                   ((100 - ((V_ALIQ_RED_VLR_ICMS *V_ALIQ_ICM_REDUCAO/100) )) / 100)) /*preço mercadoria calculado c/ IVA FIM*/
                  + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;
        ELSE
           V_SAIDA := ( (/*preço mercadoria calculado c/ IVA INI*/
                   ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                   ((  (V_PFAT_P_TPRC_PRC_FAB_MEC - (V_PFAT_P_TPRC_PRC_FAB_MEC * V_PFAT_P_PEDF_PERC_DESC / 100)
                      + NVL(V_PFAT_P_PROF_VLR_IPI,0))  *  V_PEDF_TPRC_MARGEM_LUCRO / 100   )
                    * V_ALIQ_SUBST / 100) - NVL(V_PFAT_P_PROF_VLR_IPI,0)) /
                   ((100 - V_ALIQ_RED_VLR_ICMS) / 100)) /*preço mercadoria calculado c/ IVA FIM*/
                  + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;
         END IF;


      V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(V_PFAT_P_PEDF_PERC_DESC,0)) / 100),5);
      V_SAIDA := ROUND(V_SAIDA,2) + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);

    ELSIF ((V_PEDF_TPRC_MARGEM_LUCRO > 0)
       AND (V_SUBS_TAB = 1)
       AND (V_TIPO_PESSOA = 1)
       AND (V_ALIQ_ICM > 0)
       AND (V_ALIQ_SUBST > 0)
       AND (V_oper_aliq_st_ret = 'N')
       ) THEN
       --CÁLCULO COM IVA PARA PESSOA FÍSICA COM OU SEM DESCONTO
        if (V_ALIQ_ICM_REDUCAO > 0 ) and (V_OPER_TIPO_REDUCAO = 1)and (V_OPER_NAO_RED_BASE_ST_IVA = 'S')  THEN
           V_SAIDA := ( (/*preço mercadoria calculado c/ IVA INI*/
                   ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                   ((  (V_PFAT_P_TPRC_PRC_FAB_MEC - (V_PFAT_P_TPRC_PRC_FAB_MEC * V_PFAT_P_PEDF_PERC_DESC / 100)
                      + NVL(V_PFAT_P_PROF_VLR_IPI,0))  * V_ALIQ_ICM_REDUCAO/100 * V_PEDF_TPRC_MARGEM_LUCRO / 100   )
                    * V_ALIQ_SUBST / 100) - NVL(V_PFAT_P_PROF_VLR_IPI,0)) /
                   ((100 - ((V_ALIQ_RED_VLR_ICMS *V_ALIQ_ICM_REDUCAO/100) )) / 100)) /*preço mercadoria calculado c/ IVA FIM*/
                  + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;
        ELSE
           V_SAIDA := ( (/*preço mercadoria calculado c/ IVA INI*/
                   ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                   ((  (V_PFAT_P_TPRC_PRC_FAB_MEC - (V_PFAT_P_TPRC_PRC_FAB_MEC * V_PFAT_P_PEDF_PERC_DESC / 100)
                      + NVL(V_PFAT_P_PROF_VLR_IPI,0))  *  V_PEDF_TPRC_MARGEM_LUCRO / 100   )
                    * V_ALIQ_SUBST / 100) - NVL(V_PFAT_P_PROF_VLR_IPI,0)) /
                   ((100 - V_ALIQ_RED_VLR_ICMS) / 100)) /*preço mercadoria calculado c/ IVA FIM*/
                  + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;
         END IF;

      V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(V_PFAT_P_PEDF_PERC_DESC,0)) / 100),5);
      V_SAIDA := ROUND(V_SAIDA,2) + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);

    ELSIF ((V_SUBS_TAB = 1) AND (V_PEDF_PERC_DESC_ORIGINAL >0)AND (V_oper_aliq_st_ret = 'N')) or ( V_USAR_PRECO_FINAL = 0 AND  V_USAR_REGRA_PAR_ALIQUOTA = 1)  THEN

      IF V_PFAT_P_PROF_ALIQ_IPI <> 0 THEN
        IF V_OPER_PRC_FINAL = 'S' THEN
          V_IPI := ((V_PFAT_P_TPRC_PRC_FAB_MEC - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) * 100 / ( 100 + V_PFAT_P_PROF_ALIQ_IPI ) * V_PFAT_P_PROF_ALIQ_IPI )/ 100;
        ELSE
        IF (V_PFAT_P_TPRC_BASE_SUBST > 0) then
         V_IPI := ((((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                      (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                      ((100 - V_ALIQ_RED_VLR_ICMS + V_PFAT_P_PROF_ALIQ_IPI) / 100)) /*preço mercadoria calculado c/ desconto FIM*/
                      + V_PFAT_P_TPRC_PRC_FRETE + V_PRECO_FRETE_IPI) * (V_PFAT_P_PROF_ALIQ_IPI/100);
         else
            V_IPI := ( (((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                           (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) ) /
                           ((100  + V_PFAT_P_PROF_ALIQ_IPI) / 100))
                           + V_PFAT_P_TPRC_PRC_FRETE + V_PRECO_FRETE_IPI) *(V_PFAT_P_PROF_ALIQ_IPI/100);
         END IF;
        END IF;
      ELSE
        V_IPI := NVL(V_PFAT_P_PROF_VLR_IPI,0);
      END IF;

      IF (V_PFAT_P_TPRC_BASE_SUBST > 0) THEN
        IF (V_ALIQ_ICM_REDUCAO > 0) AND ((V_OPER_TIPO_REDUCAO = 1) ) THEN
         V_SAIDA := ( (/*preço mercadoria calculado c/ desconto INI*/
                       ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                       (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                       ((100 - (V_ALIQ_RED_VLR_ICMS * V_ALIQ_ICM_REDUCAO/100)   + V_PFAT_P_PROF_ALIQ_IPI) / 100)) /*preço mercadoria calculado c/ desconto FIM*/
                      + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;

          V_VLR_MERC_ICMS_PARA_ST := ( (/*preço mercadoria calculado c/ desconto INI*/
                       ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                       (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                       ((100 - V_ALIQ_RED_VLR_ICMS + V_PFAT_P_PROF_ALIQ_IPI) / 100)) /*preço mercadoria calculado c/ desconto FIM*/
                      + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;



       ELSE
          if V_OPER_ALIQ_ICM_DIF > 0 then
             V_ALIQ_ICM_TEMP := V_ALIQ_ICM;
             V_ALIQ_RED_VLR_ICMS      := V_OPER_ALIQ_ICM_DIF;
          end if;
          V_SAIDA := ((((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                               (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                               ((100 - V_ALIQ_RED_VLR_ICMS + V_PFAT_P_PROF_ALIQ_IPI) / 100)) /*preço mercadoria calculado c/ desconto FIM*/
                              + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;



          V_SAIDA_TEMP_UNIT := ( (--ESSE CALCULO E FEITO PRA UMA UNIDADE DO ITEM  PARA SABER SE E MAIOR QUE A BASE DE S.T
                                 ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                                 (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_IPI) /
                                 ((100 - V_ALIQ_RED_VLR_ICMS) / 100))
                                + V_PFAT_P_TPRC_PRC_FRETE);

          if V_PFAT_P_TPRC_BASE_SUBST > 0 then
           V_VLR_ST_TEMP := (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - (V_SAIDA_TEMP_UNIT * V_ALIQ_RED_VLR_ICMS / 100);
           If (V_SAIDA_TEMP_UNIT > V_PFAT_P_TPRC_BASE_SUBST) and (V_VLR_ST_TEMP < 0 ) Then
            V_SAIDA := ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100))
                      - V_IPI) * V_PFAT_P_PEDF_QTDE;
           End If;
         end if;
          IF V_ALIQ_ICM_TEMP  > 0 THEN
             V_ALIQ_RED_VLR_ICMS := V_ALIQ_ICM_TEMP;
          END IF ;

        END IF;
      ELSE
      if (v_TPRC_ALIQ_MVA > 0) And (v_TPRC_ALIQ_ST_MVA > 0)   then
       V_MVA_S_DES := (V_PFAT_P_TPRC_PRC_FAB_MEC + NVL(OBTER_VALOR_IPI,0) ) * (v_TPRC_ALIQ_MVA / 100) +
                        (V_PFAT_P_TPRC_PRC_FAB_MEC + NVL(OBTER_VALOR_IPI,0));

       V_MVA_S_DES := (V_MVA_S_DES * (V_ALIQ_SUBST / 100)) -  (V_PFAT_P_TPRC_PRC_FAB_MEC * v_TPRC_ALIQ_ST_MVA/100);
       V_MVA_S_DES := V_MVA_S_DES *  (V_PEDF_PERC_DESC_ORIGINAL /100);

       V_MVA := (
                  (V_VLR_DESC_PFAB + NVL( OBTER_VALOR_IPI,0) + V_MVA_S_DES
                      )  * (v_TPRC_ALIQ_MVA / 100)  +
                              (V_VLR_DESC_PFAB + V_MVA_S_DES+ NVL( OBTER_VALOR_IPI,0)) --BASE ST MVA
                )  * (V_ALIQ_SUBST/ 100) - (V_VLR_DESC_PFAB + V_MVA_S_DES) *(v_TPRC_ALIQ_ST_MVA/100);

      V_SAIDA := (V_VLR_DESC_PFINAL - V_MVA - OBTER_VALOR_IPI) * V_PFAT_P_PEDF_QTDE;
      V_VALOR_MERCADORIA_MVA := V_SAIDA;

       ELSE
        IF V_PFAT_P_PROF_ALIQ_IPI > 0 THEN
        V_SAIDA := ( (
                           ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                           (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) ) /
                           ((100  + V_PFAT_P_PROF_ALIQ_IPI) / 100)) --NAO TEM ST NAO  ENTRA ALQUOTA ICMS NA FORMULA
                          + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;

         V_SAIDA_TEMP_UNIT := ( (
                           ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                           (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) ) /
                           ((100  + V_PFAT_P_PROF_ALIQ_IPI) / 100)) --NAO TEM ST NAO  ENTRA ALQUOTA ICMS NA FORMULA
                          + V_PFAT_P_TPRC_PRC_FRETE);


         ELSE
            V_SAIDA := ( (/*preço mercadoria calculado c/ desconto INI*/
                     ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                     (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_IPI)) /*preço mercadoria calculado c/ desconto FIM*/
                    + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;

             V_SAIDA_TEMP_UNIT := ( (--ESSE CALCULO E FEITO PRA UMA UNIDADE DO ITEM  PARA SABER SE E MAIOR QUE A BASE DE S.T
                                 ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100)) -
                                 (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - V_IPI) /
                                 ((100 - V_ALIQ_RED_VLR_ICMS) / 100))
                                + V_PFAT_P_TPRC_PRC_FRETE);

        END IF;



          if V_PFAT_P_TPRC_BASE_SUBST > 0 then
           V_VLR_ST_TEMP := (V_PFAT_P_TPRC_BASE_SUBST * V_ALIQ_SUBST / 100) - (V_SAIDA_TEMP_UNIT * V_ALIQ_RED_VLR_ICMS / 100);
           If (V_SAIDA_TEMP_UNIT > V_PFAT_P_TPRC_BASE_SUBST) and (V_VLR_ST_TEMP < 0 ) Then
            V_SAIDA := ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * V_PEDF_PERC_DESC_ORIGINAL / 100))
                      - V_IPI) * V_PFAT_P_PEDF_QTDE;
           End If;
         end if;
         END IF;

      END IF;

         V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(round(V_PFAT_P_PEDF_PERC_DESC,4),0)) / 100),5);
         V_SAIDA := ROUND(V_SAIDA,2) + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);

    ELSIF (V_PFAT_P_PROM_CVTO_ID = -1) THEN
      V_SAIDA := ROUND((V_PFAT_P_TPRC_PRC_FAB_MEC + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE,2) +
                 ROUND((V_VALOR_ADC_FINANC_ITEM) * V_PFAT_P_PEDF_QTDE,2);
      V_VALOR_MERCADORIA_MVA := V_SAIDA;
      V_VLR_MERC_ICMS_PARA_ST := V_SAIDA;
      IF V_PROF_ALIQ_IPI_DIFERENCIADA > 0 THEN -- CALCULO DA MERCADORIA PARA OBTER VALOR DE IPI DIFERENCIADO SÓ É USADO NA FUNC Obter_Valor_IPI
         V_VALOR_MERC_ALIQ_IPI_DIF := ROUND((V_PFAT_P_TPRC_PRC_FAB_MEC +V_PROF_ALIQ_IPI_DIFERENCIADA+ V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE,2) +
                 ROUND((V_VALOR_ADC_FINANC_ITEM) * V_PFAT_P_PEDF_QTDE,2);
      END IF;

    ELSE
      V_SAIDA := ROUND((V_PFAT_P_TPRC_PRC_FAB_MEC + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE,2) +
                 ROUND((V_VALOR_ADC_FINANC_ITEM) * V_PFAT_P_PEDF_QTDE,2);

      IF V_PROF_ALIQ_IPI_DIFERENCIADA > 0 THEN -- CALCULO DA MERCADORIA PARA OBTER VALOR DE IPI DIFERENCIADO SÓ É USADO NA FUNC Obter_Valor_IPI
         V_VALOR_MERC_ALIQ_IPI_DIF := ROUND((V_PFAT_P_TPRC_PRC_FAB_MEC +V_PROF_ALIQ_IPI_DIFERENCIADA+ V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE,2) +
                 ROUND((V_VALOR_ADC_FINANC_ITEM) * V_PFAT_P_PEDF_QTDE,2);
      END IF;


    END IF;
          IF  v_REGRA_CORTE_GATILHO = 5 THEN
                 if (V_PFAT_P_PROF_ALIQ_IPI = 0) and(V_OPER_SUFRAMA <> 'S')  then
                      V_SAIDA := ( (
                                   ((V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)) -
                                   (((V_PFAT_P_PROF_VLR_IPI + V_PFAT_P_TPRC_PRC_FAB_MEC) - (V_PFAT_P_TPRC_PRC_FAB_MEC * round(V_PFAT_P_PEDF_PERC_DESC,4) / 100))
                                                * V_ALIQ_SUBST / 100) - V_PFAT_P_PROF_VLR_IPI) /
                                   ((100  + V_PFAT_P_PROF_ALIQ_IPI) / 100)) --NAO TEM ST NAO  ENTRA ALQUOTA ICMS NA FORMULA
                                  + V_PFAT_P_TPRC_PRC_FRETE) * V_PFAT_P_PEDF_QTDE;
                  else
                      IF NVL(V_PFAT_P_PROF_ALIQ_IPI,0) = 0 THEN
                         V_PAUTA_IPI_REGRA_PRC := 0;
                         V_ALIQ_IPI_REGRA_PRC  := 0;
                      END IF;
                       FOR C IN ( SELECT * FROM TABLE( TCalc_fabricaFB.Calc_fabricaFB(V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)
                                                                                     ,0
                                                                                     ,V_ALIQ_ICM_REDUCAO/100 --ALIQ REDUÇÃO
                                                                                     ,V_ALIQ_RED_VLR_ICMS/100 -- ALIQ ICMS
                                                                                     ,0 --IPI PAUTA
                                                                                     ,1
                                                                                     ,V_PFAT_P_PROF_ALIQ_IPI/100 --ALIQ IPI
                                                                                     ,0
                                                                                     ,0
                                                                                     ,(V_OPER_ALIQ_RED_BC_ICM_OE /100) -- ALIQ REDUÇÃO BASE ST
                                                                                     ,v_TPRC_ALIQ_MVA/100 --ALIQ MAG LUCRO MVA
                                                                                     ,V_ALIQ_SUBST/100 --ALIQ ST DO MVA
                                                                                     ,V_PEDF_TPRC_MARGEM_LUCRO/100
                                                                                     ,V_PFAT_P_TPRC_PRC_FRETE
                                                                                     ,'T'
                                                                                     ,V_OPER_SUFRAMA
                                                                                     ,0
                                                                                     ,0)))--Aliq_InterEstadual))
                   LOOP
                      PFABRICA := C.VLR_MECADORIA;

                  END LOOP;

              V_SAIDA := PFABRICA * V_PFAT_P_PEDF_QTDE;
           end if;
         V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(round(V_PFAT_P_PEDF_PERC_DESC,4),0)) / 100),5);
         V_SAIDA := ROUND(V_SAIDA,2) + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);
     ELSE

         IF (v_CLI_ST_REGIME_CNAE = 'S')and (V_PFAT_OPER_DESTINO_OPER = 2) AND (V_SUBS_TAB = 1) AND (V_PEDF_PERC_DESC_ORIGINAL >0) THEN

            FOR C IN ( SELECT * FROM TABLE( TCalc_fabricaFB.Calc_fabricaFB(V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)
                                             ,0
                                             ,V_ALIQ_ICM_REDUCAO/100 --ALIQ REDUÇÃO
                                             ,V_ALIQ_RED_VLR_ICMS/100 -- ALIQ ICMS
                                             ,V_PFAT_P_PROF_VLR_IPI --IPI PAUTA
                                             ,1
                                             ,V_PFAT_P_PROF_ALIQ_IPI/100 --ALIQ IPI
                                             ,0
                                             ,0
                                             ,(V_OPER_ALIQ_RED_BC_ICM_OE /100) -- ALIQ REDUÇÃO BASE ST
                                             ,0 --ALIQ MAG LUCRO MVA
                                             ,V_ALIQ_SUBST/100 --ALIQ ST
                                             ,0 --ALIQ MARGEM DE LUCRO
                                             ,V_PFAT_P_TPRC_PRC_FRETE
                                             ,'S'
                                             ,V_OPER_SUFRAMA
                                             ,0
                                             ,0)))--Aliq_InterEstadual))
                   LOOP
                      PFABRICA := C.VLR_MECADORIA;

                  END LOOP;
             V_SAIDA := PFABRICA * V_PFAT_P_PEDF_QTDE;
             V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(round(V_PFAT_P_PEDF_PERC_DESC,4),0)) / 100),5);
             V_SAIDA := ROUND(V_SAIDA,2) + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);
         END IF;
    end if;

     IF (V_UF_EMPRESA <> V_UF_CLIENTE) --VENDA FORA DO ESTADO ICMS_ST DIFAL
             AND (NVL(V_GATILHO_PER_MVA,0) = 0)
             AND (V_PFAT_OPER_TIPO_ICMR <> 2)
             AND (NVL(v_REGRA_CORTE_GATILHO,0) = 0)
             AND (NVL(V_USAR_CALC_ST_DIFAL,0) = 1)
             AND (NVL(V_ALIQ_ICMS_UF_DEST,0)>0
             AND (NVL(V_ALIQ_ICM,0) >0)  )
             AND (NVL(V_PEDF_PERC_DESC_ORIGINAL,0)>0)
             or (( V_USAR_PRECO_FINAL = 0) and (V_USAR_REGRA_PAR_ALIQUOTA = 1) AND (v_TPRC_ALIQ_MVA > 0))
          THEN
            IF (( V_USAR_PRECO_FINAL = 0)
                and (V_USAR_REGRA_PAR_ALIQUOTA = 1)
                AND (v_TPRC_ALIQ_MVA > 0))
              THEN
              V_TP_CALC := 'M' ;
              ELSE
              V_TP_CALC := 'F' ;
             END IF;

              FOR C IN ( SELECT * FROM TABLE( TCalc_fabricaFB.Calc_fabricaFB(V_PFAT_P_TPRC_PRC_FINAL - (V_PFAT_P_TPRC_PRC_FINAL * round(V_PEDF_PERC_DESC_ORIGINAL,4) / 100)
                                         ,0
                                         ,V_ALIQ_ICM_REDUCAO/100 --ALIQ REDUÇÃO
                                         ,V_ALIQ_RED_VLR_ICMS/100 -- ALIQ ICMS
                                         ,V_PFAT_P_PROF_VLR_IPI --IPI PAUTA
                                         ,1
                                         ,V_PFAT_P_PROF_ALIQ_IPI/100 --ALIQ IPI
                                         ,V_PFAT_P_TPRC_BASE_SUBST -- PAUTA ST
                                         ,0
                                         ,(V_OPER_ALIQ_RED_BC_ICM_OE /100) -- ALIQ REDUÇÃO BASE ST
                                         ,v_TPRC_ALIQ_MVA/100 --ALIQ MAG LUCRO MVA
                                         ,V_ALIQ_SUBST/100 --ALIQ ST DO MVA
                                         ,V_PEDF_TPRC_MARGEM_LUCRO/100
                                         ,V_PFAT_P_TPRC_PRC_FRETE
                                         ,V_TP_CALC
                                         ,V_OPER_SUFRAMA
                                         ,V_ALIQ_ICMS_UF_DEST/100 -- ALIQUOTA INTERNA PEGA GENER ESTADO NR01
                                         ,V_ALIQ_RED_VLR_ICMS/100)))
                   LOOP
                      PFABRICA := C.VLR_MECADORIA;
                      V_VALOR_SUBST_FUNC := C.VLR_ST * V_PFAT_P_PEDF_QTDE;
                      V_VALOR_BASE_ST_FUNC :=C.VLR_BASE_ST * V_PFAT_P_PEDF_QTDE;

                  END LOOP;

              V_SAIDA := PFABRICA * V_PFAT_P_PEDF_QTDE;
              V_PFAT_P_TPRC_PRC_FAB := ROUND((V_SAIDA / V_PFAT_P_PEDF_QTDE) / ((100 - NVL(round(V_PFAT_P_PEDF_PERC_DESC,4),0)) / 100),5);
              V_SAIDA := V_SAIDA + ROUND(V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE,2);
              V_VALOR_MERCADORIA_MVA := V_SAIDA;
          END IF;

    IF V_PFAT_P_PROF_COD_ICM = 2 THEN
       V_VALOR_ISENTO_ICM := V_SAIDA;
    END IF;

      IF V_PFAT_P_PROF_ALIQ_IPI > 0 THEN
        IF (V_PFAT_PEDF_VLR_DESC <> 0) AND (V_DESC_BASE_IPI = 1) THEN
          V_DESCONTO_IPI  := RATIAR_VALOR(V_VLR_TOT_MERCADORIA , V_PFAT_PEDF_VLR_DESC, (V_PFAT_P_TPRC_PRC_FAB * V_PFAT_P_PEDF_QTDE));
        END IF;
       V_IPI := (V_SAIDA + V_PRECO_FRETE_IPI - V_DESCONTO_IPI ) *(V_PFAT_P_PROF_ALIQ_IPI/100 );
     END IF ;
    if V_SAIDA < 0 then
       V_SAIDA := 0;
     end if;
     if (v_TPRC_ALIQ_MVA > 0) And (v_TPRC_ALIQ_ST_MVA > 0)
       and (V_VALOR_MERCADORIA_MVA = 0) and (V_SAIDA > 0) then
        V_VALOR_MERCADORIA_MVA := V_SAIDA;
     end if;
     IF V_ALIQ_ICM_TEMP  > 0 THEN
        V_ALIQ_ICM := V_ALIQ_ICM_TEMP;
    END IF ;
    RETURN(V_SAIDA);
  END Obter_Valor_Mercadoria;

FUNCTION Obter_Base_Seguro RETURN REAL IS
  BASE_SEG                 REAL   := 0;
  VALOR_IPI_SEG            REAL   := 0;
  --VALOR_ADF                REAL   := 0;
  BEGIN
  VALOR_IPI_SEG := Obter_Valor_IPI_SEG;

   SELECT  ROUND((SUM(VLR_GARR.VLR_GARRAFA_EMB1 + VLR_GARR.VLR_GARRAFA_EMB2)
            + NVL(V_VLR_TOT_MERCADORIA,0)  + NVL(V_PFAT_PEDF_VLR_FRETE,0)
            - nvl(V_PFAT_TOT_DESC,0)  + NVL(VALOR_IPI_SEG,0)) *  NVL(MAX(ALIQ.ALIQ_SEG),0),2)  VLR_BASE_SEGURO
           ,ROUND(SUM(BASE_VASILHAME),2)  BASE_VASILHAME

   INTO  BASE_SEG ,V_BASE_VASILHAME

   FROM
       (SELECT
                   NVL((SELECT  SUM((PEDF_QTDE/NVL(PC.PROC_FATOR_PESO_VOLUME,1)) *  NVL(P.PROF_PRC_UNIT,0))
                          FROM   PRODUTO_FAT P

                          WHERE   P.PROF_PROD_EMP_ID   = PF.PROF_PROD_EMP_ID_PROD_EMBAL_2_
                              AND P.PROF_PROD_ID       = PF.PROF_PROD_ID_PROD_EMBAL_2_DE),0) VLR_GARRAFA_EMB2

                 , NVL((SELECT  SUM(NVL(PEDF_QTDE,0) * NVL(PC.PROC_FATOR_CX,1) * NVL(P.PROF_PRC_UNIT,0))
                          FROM  PRODUTO_FAT P
                          WHERE   P.PROF_PROD_EMP_ID  = PF.PROF_PROD_EMP_ID_PROD_EMBAL_1_
                              AND P.PROF_PROD_ID      = PF.PROF_PROD_ID_PROD_EMBAL_1_DE),0) VLR_GARRAFA_EMB1


                    ,NVL((SELECT  SUM((PEDF_QTDE/NVL(PC.PROC_FATOR_PESO_VOLUME,1)) *  NVL(P.PROF_PRC_UNIT,0))
                          FROM   PRODUTO_FAT P
                          WHERE   P.PROF_PROD_EMP_ID  = PF.PROF_PROD_EMP_ID_PROD_EMBAL_2_
                              AND P.PROF_PROD_ID      = PF.PROF_PROD_ID_PROD_EMBAL_2_DE),0)

                   +
                   NVL((SELECT  SUM(NVL(PEDF_QTDE,0) * NVL(PC.PROC_FATOR_CX,1) * NVL(P.PROF_PRC_UNIT,0))
                          FROM  PRODUTO_FAT P
                          WHERE   P.PROF_PROD_EMP_ID  = PF.PROF_PROD_EMP_ID_PROD_EMBAL_1_
                              AND P.PROF_PROD_ID      = PF.PROF_PROD_ID_PROD_EMBAL_1_DE),0) BASE_VASILHAME

                    ,F.PEDF_ID
                    ,F.PEDF_EMP_ID
               FROM  PRODUTO_FAT  PF
                    ,PEDIDO_FAT_P
                    ,PEDIDO_FAT F
                    ,PRODUTO_C PC

               WHERE       F.PEDF_EMP_ID             = PEDF_PEDF_EMP_ID
                      AND  F.PEDF_ID                 = PEDF_PEDF_ID
                      AND  PF.PROF_PROD_EMP_ID       = PEDF_PROD_EMP_ID
                      AND  PF.PROF_PROD_ID           = PEDF_PROD_ID
                      AND  PC.PROC_PROD_EMP_ID       = PEDF_PROD_EMP_ID
                      AND  PC.PROC_PROD_ID           = PEDF_PROD_ID
                      AND  PEDF_EMP_ID               = V_EMP_ATIVA
                      AND  F.PEDF_ID         BETWEEN V_PEDID_INI AND V_PEDID_FIN
                      AND  F.PEDF_LIQU_EMP_ID         = V_EMP_ATIVA
                      AND  F.PEDF_LIQU_ID             = V_LIQUID
                      AND  PEDF_SITUACAO              = V_SITUACAO
                     -- AND  NVL(PEDF_LIB_ANALISTA,'S') = 'S'
                      AND DECODE(V_GERA_NF,1, NVL(PEDF_LIB_ANALISTA,'S'),'S') = 'S'
                      AND  NVL(PEDF_FLAG_EMIS,0)     <> 9
                      AND  (
                       ((PEDF_SITUACAO     = 2)          AND
                        (PEDF_NR_NF        IS NOT NULL)  AND
                        (PEDF_NR_NF_DEV    IS NULL))     OR
                       ((PEDF_SITUACAO     = 0)          AND
                        (PEDF_NR_NF        IS NULL)      AND
                        (PEDF_NR_NF_DEV    IS NULL))
                       ) AND
                       (PEDF_NF_COBERT    IS NULL)
        )VLR_GARR
       ,(SELECT DISTINCT
                 (NVL(EMP.EMPU_ALIQ_SEGURO,0) /100) ALIQ_SEG
                ,F.PEDF_EMP_ID
                ,F.PEDF_ID
            FROM
                GENER
               ,GENER_A
               ,GENER PROP
               ,CLIENTE_E E
               ,PEDIDO_FAT F
               ,EMPRESA_UF EMP

            WHERE
                        GENER.GEN_EMP_ID                       = GENER_A.GENA_GEN_EMP_ID
                    AND GENER.GEN_ID                           = GENER_A.GENA_GEN_ID
                    AND GENER.GEN_TGEN_ID                      = GENER_A.GENA_GEN_TGEN_ID
                    AND GENER_A.GENA_GEN_TGEN_ID_PROPRIETARIO_ = PROP.GEN_TGEN_ID
                    AND GENER_A.GENA_GEN_EMP_ID_PROPRIETARIO_D = PROP.GEN_EMP_ID
                    AND GENER_A.GENA_GEN_ID_PROPRIETARIO_DE    = PROP.GEN_ID
                    AND GENER.GEN_EMP_ID                       = E.CLIE_GEN_EMP_ID_CIDADE_DE
                    AND GENER.GEN_TGEN_ID                      = E.CLIE_GEN_TGEN_ID_CIDADE_DE
                    AND GENER.GEN_ID                           = E.CLIE_GEN_ID_CIDADE_DE
                    AND EMP.EMPU_GEN_ID                        = PROP.GEN_ID
                    AND EMP.EMPU_GEN_TGEN_ID                   = PROP.GEN_TGEN_ID
                    AND EMP.EMPU_GEN_EMP_ID                    = PROP.GEN_EMP_ID
                    AND EMP.EMPU_EMP_ID                        = F.PEDF_EMP_ID
                    AND F.PEDF_CLI_EMP_ID                      = E.CLIE_CLI_EMP_ID
                    AND F.PEDF_CLI_ID                          = E.CLIE_CLI_ID
                    AND E.CLIE_GEN_ID                          = 2
                    AND  F.PEDF_ID             BETWEEN V_PEDID_INI AND V_PEDID_FIN
                    AND  F.PEDF_LIQU_EMP_ID         = V_EMP_ATIVA
                    AND  F.PEDF_LIQU_ID             = V_LIQUID
                    AND  PEDF_SITUACAO       = V_SITUACAO
                    --AND NVL(PEDF_LIB_ANALISTA,'S') = 'S'
                    AND DECODE(V_GERA_NF,1, NVL(PEDF_LIB_ANALISTA,'S'),'S') = 'S'
                    AND NVL(PEDF_FLAG_EMIS,0)     <> 9
                     AND  (
                       ((PEDF_SITUACAO     = 2)          AND
                        (PEDF_NR_NF        IS NOT NULL)  AND
                        (PEDF_NR_NF_DEV    IS NULL))     OR
                       ((PEDF_SITUACAO     = 0)          AND
                        (PEDF_NR_NF        IS NULL)      AND
                        (PEDF_NR_NF_DEV    IS NULL))
                       ) AND
                       (PEDF_NF_COBERT    IS NULL)
        )ALIQ
       WHERE    VLR_GARR.PEDF_EMP_ID     =  ALIQ.PEDF_EMP_ID
            AND VLR_GARR.PEDF_ID         =  ALIQ.PEDF_ID;


    RETURN(NVL(BASE_SEG,0));
  END  Obter_Base_Seguro;


  FUNCTION RATIAR_VALOR(Total_Geral In Real,
                        Desconto In Real,
                        Valor_Item In Real) RETURN REAL IS
  V_SAIDA REAL := 0;
  BEGIN
    /*V_SAIDA := Round( (Desconto * ((Valor_Item * 100) / Total_Geral)) / 100, 2);*/
      IF Total_Geral <> 0 THEN
          V_SAIDA := Round( (Desconto * ((Valor_Item * 100) / Total_Geral)) / 100, 7);
      ELSE
          V_SAIDA := 0;
      END IF;
    RETURN(V_SAIDA);
  END RATIAR_VALOR;

  /*FRETE VALORIZA NA BASE DE ICMS*/
  FUNCTION OBTER_VAL_FRETE_ICMS(EMP_ATIVA IN INTEGER) RETURN INTEGER IS
  V_VALOR INTEGER := 0;
  V_DENTRO_ESTADO INTEGER := 0;
  BEGIN
     SELECT NVL(GEN_NUMBER1,0) ,NVL(GEN_NUMBER2,0)
        INTO V_VALOR
            ,V_DENTRO_ESTADO
     FROM GENER
     WHERE GEN_TGEN_ID = 945
       AND GEN_EMP_ID  = EMP_ATIVA
       AND GEN_ID      = 100;
       IF (V_VALOR = 1) AND (V_DENTRO_ESTADO = 1) THEN
                if  V_UF_EMPRESA = V_UF_CLIENTE THEN
                   V_VALOR := 1;
                 ELSE
                   V_VALOR := 0;
               END IF;
       END IF;

     RETURN(V_VALOR);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(V_VALOR);
  END;


  FUNCTION BLOQUEAR_REGISTROS(CUSOR INTEGER) RETURN BOOLEAN IS
  BEGIN
    /*
      1 = CURSOR_PEDIDO_FAT_BLOQ
      2 = CURSOR_PEDIDO_FAT_P_BLOQ
    */
    IF CUSOR    = 1 THEN
      OPEN CURSOR_PEDIDO_FAT_BLOQ;
    ELSIF CUSOR = 2 THEN
      OPEN CURSOR_PEDIDO_FAT_P_BLOQ;
    END IF;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END BLOQUEAR_REGISTROS;

  FUNCTION Obter_Base_Subst RETURN REAL AS
  V_VALOR_BASE_SUBST REAL := 0;
  V_VLR_SUBST_TEMP   REAL := 0;
  V_TIPO_SUBS        REAL := 0;
  V_VALOR_ICM_DIF    REAL := 0;
  V_VALOR_BASE_SUBST_PAUTA REAL := 0;
  V_VALOR_BASE_SUBST_MVA  REAL := 0;
  V_ALIQ_ICM_TEMP            REAL := 0;
  V_VALOR_ICM_TEMP          REAL := 0;
  V_BASE_ICMS_TEMP          REAL  := 0;
  V_VALOR_ICM_SUBST_PAUTA   REAL := 0;
  V_VALOR_ICM_SUBST_MVA     REAL := 0;
  V_VALOR_RED_ICM_SUBST_MVA     REAL := 0;
  VLR_ICMS_OP_PROPRIA     REAL :=0;
  VLR_ICMS_ST_ESTIMATIVA  REAL :=0;

  BEGIN
    V_VALOR_ICM_SUBST  := 0;
    V_VLR_SUBST_NORMAL := 0;
    V_VALOR_ICM_TEMP   := 0;--usada para calculo ST com base reduzida
    V_BASE_ICMS_TEMP   := 0;--usada para calculo ST com base reduzida
    V_VALOR_BASE_SUBST_PAUTA :=0;
    V_VALOR_ICM_SUBST_PAUTA  :=0;
    V_VALOR_ICM_SUBST_MVA    :=0;
    V_VALOR_RED_ICM_SUBST_MVA:=0;
    V_VALOR_BASE_SUBST       :=0;
    V_VALOR_BASE_SUBST_MVA   :=0;
    VLR_ICMS_OP_PROPRIA      :=0;
    VLR_ICMS_ST_ESTIMATIVA   :=0;





    IF (V_PFAT_OPER_TIPO_ICMR <> 2) THEN--0
      /*CASO O VALOR DO SUBSTITUTO ESTEJA EM BRANCO NA TABELA DE PRECO
        DEVO CALCULAR O MESMO A PARTIR DA BASE DO SUBSTITUTO */
    IF (V_VLR_ICMS_PARA_ST = 2) And (V_ALIQ_ICM_REDUCAO > 0) THEN
        V_VALOR_ICM_TEMP        := V_VALOR_ICM;
        V_VALOR_ICM             := Calculo_Pedido_Fat$PK.Obter_Valor_ICM(1);


    END IF;

      SELECT
          GEN_NUMBER6
      INTO
          V_TIPO_SUBS
      FROM
          GENER
      WHERE
          GEN_TGEN_ID =  V_PFAT_P_TPRC_GEN_TGEN_ID
      AND GEN_EMP_ID  =  V_PFAT_P_TPRC_GEN_EMP_ID
      AND GEN_ID      =  V_PFAT_P_TPRC_GEN_ID;

      IF (V_PFAT_P_TPRC_ICM_SUBST <> 0) THEN--1
        V_VALOR_ICM_SUBST := V_PFAT_P_PEDF_QTDE * V_PFAT_P_TPRC_ICM_SUBST;
        V_VALOR_ICM_SUBST := ROUND(V_VALOR_ICM_SUBST,2);

        IF V_TIPO_SUBS = 1 THEN
          /* SUBTRAI DESCONTO OU SOMA ADICIONAL NO VALOR DO SUBSTITUTO */
           V_VALOR_ICM_SUBST := V_VALOR_ICM_SUBST +
                                ROUND(((V_PFAT_P_TPRC_PRC_FAB * V_PFAT_P_PEDF_QTDE) - (V_BASE_ICMS))
                                      * (V_ALIQ_ICM/100),2) ;
           IF V_VALOR_ICM_SUBST < 0 THEN
             V_VALOR_ICM_SUBST := 0;
           END IF;
           V_VALOR_ICM_SUBST := ROUND(V_VALOR_ICM_SUBST,2);
        END IF;
      END IF;--1
--aqui
      if (V_oper_aliq_st_ret = 'S') and (V_VALOR_RED_ICM_PARA_ST > 0) and (V_BASE_RED_ICM_PARA_ST >0)
      then
        V_BASE_ICMS_TEMP := V_BASE_ICMS;
        V_VALOR_ICM_TEMP := V_VALOR_ICM;

        V_BASE_ICMS := V_BASE_RED_ICM_PARA_ST;
        V_VALOR_ICM := V_VALOR_RED_ICM_PARA_ST;

      end if;

     IF V_PEDF_TPRC_MARGEM_LUCRO <> 0 THEN--2

       IF (V_ALIQ_ICM_REDUCAO > 0 ) Or (V_REDUZ_ST_SIMPLES_NAC = 1) OR (V_ZERA_BASE_ST = 1)OR (V_OPER_ALIQ_RED_ST_DES > 0) THEN
         IF V_OPER_NAO_RED_BASE_ST_IVA = 'S'
          THEN
             IF V_REDUZ_ST_SIMPLES_NAC = 1 THEN
                  IF V_PFAT_OPER_TIPO_IPI = 1 THEN
                      V_VALOR_BASE_SUBST := ((V_VALOR_MERCADORIA + OBTER_VALOR_IPI) * V_PEDF_TPRC_MARGEM_LUCRO / 100) * v_TPRC_ALIQ_MVA / 100 ;
                    ELSE
                      V_VALOR_BASE_SUBST := (V_VALOR_MERCADORIA * V_PEDF_TPRC_MARGEM_LUCRO / 100) * v_TPRC_ALIQ_MVA / 100 ;
                    END IF;
              ELSE
              IF (V_OPER_TIPO_REDUCAO = 1)
              THEN --reduzir somente qto estive no cadastro pra reduzir a base qto
                      --a redução for no valor nao deve reduzir a base do st
                     IF V_PFAT_OPER_TIPO_IPI = 1 THEN
                        IF V_OPER_ALIQ_RED_ST_DES > 0 THEN
                          V_VALOR_BASE_SUBST := ((V_VALOR_MERCADORIA + OBTER_VALOR_IPI) * V_PEDF_TPRC_MARGEM_LUCRO / 100) * (1 - (V_OPER_ALIQ_RED_ST_DES / 100)) ;
                         ELSE
                           V_VALOR_BASE_SUBST := ((V_VALOR_MERCADORIA + OBTER_VALOR_IPI) * V_PEDF_TPRC_MARGEM_LUCRO / 100) * V_ALIQ_ICM_REDUCAO / 100 ;
                         END IF;
                      ELSE
                         IF V_OPER_ALIQ_RED_ST_DES > 0 THEN
                          V_VALOR_BASE_SUBST := ((V_VALOR_MERCADORIA + OBTER_VALOR_IPI) * V_PEDF_TPRC_MARGEM_LUCRO / 100) * (1 - (V_OPER_ALIQ_RED_ST_DES / 100)) ;
                         ELSE
                            V_VALOR_BASE_SUBST := (V_VALOR_MERCADORIA * V_PEDF_TPRC_MARGEM_LUCRO / 100) * V_ALIQ_ICM_REDUCAO / 100 ;
                         END IF;
                    END IF;
                ELSE
                    IF V_PFAT_OPER_TIPO_IPI = 1 THEN
                      V_VALOR_BASE_SUBST := ((V_VALOR_MERCADORIA - V_DESCONTO_NOR_ITEM + OBTER_VALOR_IPI) * V_PEDF_TPRC_MARGEM_LUCRO / 100) ;
                    ELSE
                      V_VALOR_BASE_SUBST := ((V_VALOR_MERCADORIA - V_DESCONTO_NOR_ITEM) * V_PEDF_TPRC_MARGEM_LUCRO / 100)  ;
                    END IF;

              END IF;
            END IF;
           ELSE
              IF V_PFAT_OPER_TIPO_IPI = 1 THEN
                V_VALOR_BASE_SUBST := ((V_VALOR_MERCADORIA + OBTER_VALOR_IPI) * V_PEDF_TPRC_MARGEM_LUCRO / 100) ;
              ELSE
                V_VALOR_BASE_SUBST := (V_VALOR_MERCADORIA * V_PEDF_TPRC_MARGEM_LUCRO / 100)  ;
              END IF;

           END IF;
        ELSE
          IF V_PFAT_OPER_TIPO_IPI = 1 THEN
            if  (V_VALORIZO_IPI) OR (v_oper_ipi_base_st = 'N') then
              V_VALOR_BASE_SUBST := (V_BASE_ICMS ) * V_PEDF_TPRC_MARGEM_LUCRO / 100;
            else
              V_VALOR_BASE_SUBST := (V_BASE_ICMS +OBTER_VALOR_IPI) * V_PEDF_TPRC_MARGEM_LUCRO / 100;
            end if;
          ELSE
            V_VALOR_BASE_SUBST := V_BASE_ICMS * V_PEDF_TPRC_MARGEM_LUCRO / 100;
          END IF;
      END IF;
      IF V_TPRC_ALQ_ST_DIF = 0 THEN
             V_VALOR_ICM_SUBST  := (V_VALOR_BASE_SUBST * V_ALIQ_SUBST / 100) - V_VALOR_ICM;
         ELSE
             V_ALIQ_ICM_TEMP    := V_ALIQ_ICM;
             V_ALIQ_ICM         := V_TPRC_ALQ_ST_DIF;

             IF V_OPER_SUFRAMA = 'N' THEN
                 V_VALOR_ICMS_ST    := Obter_Valor_ICM(0);
             ELSE
                V_VALOR_ICMS_ST    := Obter_Valor_ICM(2);
             END IF;

             V_VALOR_ICM_SUBST  := (V_VALOR_BASE_SUBST * V_ALIQ_SUBST / 100) - V_VALOR_ICMS_ST;
             V_ALIQ_ICM         := V_ALIQ_ICM_TEMP;
       END IF;

        IF V_VALOR_ICM_SUBST < 0 THEN
          V_VALOR_ICM_SUBST := 0;
        END IF;


      ELSIF (V_PFAT_OPER_DESTINO_OPER = 1) THEN--2
         /*ESTADUAL*/


         IF V_PFAT_P_TPRC_BASE_SUBST <> 0 THEN--3
            V_VALOR_BASE_SUBST := V_PFAT_P_PEDF_QTDE * V_PFAT_P_TPRC_BASE_SUBST;
            V_VLR_SUBST_NORMAL := V_PFAT_P_PEDF_QTDE * V_BASE_SUBST_NORMAL;
            IF (V_VALOR_ICM_SUBST = 0) THEN
                V_VALOR_ICM_SUBST := ((V_PFAT_P_TPRC_BASE_SUBST * V_PFAT_P_PEDF_QTDE) * V_ALIQ_SUBST / 100) - V_VALOR_ICM;
                V_VALOR_ICM_SUBST := ROUND(V_VALOR_ICM_SUBST,2);
              /*Tratamento para evitar a impressao para valores negativos */
              IF V_VALOR_ICM_SUBST < 0 THEN
                 V_VALOR_ICM_SUBST := 0;
              END IF;
            END IF;
         ELSE--3
            IF (V_ALIQ_ICM <> 0) AND
               (V_VALOR_ICM_SUBST <> 0) THEN
               V_VALOR_BASE_SUBST := (V_VALOR_ICM_SUBST +
                                      V_VALOR_ICM) * 100 /
                                      V_ALIQ_ICM;
             V_VLR_SUBST_NORMAL   := (ROUND(((V_BASE_SUBST_NORMAL * V_PFAT_P_PEDF_QTDE) * V_ALIQ_ICM / 100) - V_VALOR_ICM,2) +
                                      V_VALOR_ICM) * 100 /
                                      V_ALIQ_ICM;


            END IF;
         END IF;--3
      ELSE--2
        /*INTER ESTADUAL*/
        V_VALOR_ICM_DIF :=V_BASE_ICMS * (V_OPER_ALIQ_ICM_DIF/100);
        -- REDUÇÃO DO  VALOR DO ICMS PARA CALCULO DO VALOR ST

      IF V_VALOR_ICM_DIF = 0 THEN
        IF (V_PFAT_P_TPRC_BASE_SUBST <> 0) THEN--6
          IF (V_VALOR_ICM_SUBST = 0) THEN--5
            IF (V_PFAT_P_TPRC_ALIQ_ICM_SUBS <> 0) THEN--4
               V_VALOR_ICM_SUBST := ((V_PFAT_P_TPRC_BASE_SUBST * V_PFAT_P_PEDF_QTDE) * V_PFAT_P_TPRC_ALIQ_ICM_SUBS / 100) - V_VALOR_ICM;
               V_VALOR_ICM_SUBST := ROUND(V_VALOR_ICM_SUBST,2);

               V_VALOR_BASE_SUBST := V_PFAT_P_PEDF_QTDE *
                                    V_PFAT_P_TPRC_BASE_SUBST;

               V_VLR_SUBST_NORMAL := V_PFAT_P_PEDF_QTDE * V_BASE_SUBST_NORMAL;


               IF V_VALOR_ICM_SUBST < 0 THEN
                  V_VALOR_ICM_SUBST := 0;
               END IF;
            ELSE--4
               IF (V_ALIQ_SUBST <> 0) THEN
                 V_VALOR_ICM_SUBST  := ((V_PFAT_P_TPRC_BASE_SUBST * V_PFAT_P_PEDF_QTDE) * V_ALIQ_SUBST/ 100) - V_VALOR_ICM;
                 V_VALOR_BASE_SUBST := V_PFAT_P_PEDF_QTDE * V_PFAT_P_TPRC_BASE_SUBST;
                 V_VLR_SUBST_NORMAL := V_PFAT_P_PEDF_QTDE * V_BASE_SUBST_NORMAL;

                 /*  ACERTANDO BASE  - SERGIO / FREDERICO - 08/04/2002 */
                 V_VLR_SUBST_TEMP   := ROUND(V_VALOR_ICM_SUBST,2)  + V_VALOR_ICM;
                 V_VALOR_BASE_SUBST := ROUND((V_VLR_SUBST_TEMP * 100) / V_ALIQ_SUBST,2);
                 V_VLR_SUBST_NORMAL := (((V_BASE_SUBST_NORMAL * V_PFAT_P_PEDF_QTDE) * V_ALIQ_SUBST / 100) - V_VALOR_ICM + V_VALOR_ICM *100)/ V_ALIQ_SUBST;
                 V_VLR_SUBST_NORMAL := ROUND(V_VLR_SUBST_NORMAL,2);
                 V_VALOR_ICM_SUBST  := ROUND(V_VALOR_ICM_SUBST,2);

                 V_VALOR_BASE_SUBST := V_PFAT_P_PEDF_QTDE *
                                       V_PFAT_P_TPRC_BASE_SUBST;

                 V_VLR_SUBST_NORMAL := V_PFAT_P_PEDF_QTDE * V_BASE_SUBST_NORMAL;
                 IF V_VALOR_ICM_SUBST < 0 THEN
                    V_VALOR_ICM_SUBST := 0;
                 END IF;
               ELSE
                 V_VALOR_ICM_SUBST := ((V_PFAT_P_TPRC_BASE_SUBST * V_PFAT_P_PEDF_QTDE) * V_ALIQ_ICM / 100) - V_VALOR_ICM;
                 V_VALOR_BASE_SUBST := V_PFAT_P_PEDF_QTDE * V_PFAT_P_TPRC_BASE_SUBST;
                 V_VLR_SUBST_NORMAL := V_PFAT_P_PEDF_QTDE * V_BASE_SUBST_NORMAL;
                 /*  ACERTANDO BASE  - SERGIO / FREDERICO - 08/04/2002 */
                 V_VLR_SUBST_TEMP   := ROUND(V_VALOR_ICM_SUBST,2)  + V_VALOR_ICM;
                 V_VALOR_BASE_SUBST := ROUND((V_VLR_SUBST_TEMP * 100) /V_ALIQ_ICM ,2);
                  V_VLR_SUBST_NORMAL := (((V_BASE_SUBST_NORMAL * V_PFAT_P_PEDF_QTDE) * V_ALIQ_ICM / 100) - V_VALOR_ICM + V_VALOR_ICM *100)/ V_ALIQ_SUBST;
                 V_VLR_SUBST_NORMAL := ROUND(V_VLR_SUBST_NORMAL,2);
                 V_VALOR_ICM_SUBST  := ROUND(V_VALOR_ICM_SUBST,2);
                 IF V_VALOR_ICM_SUBST < 0 THEN
                    V_VALOR_ICM_SUBST := 0;
                 END IF;
               END IF;
            END IF;--4
          ELSE--5
             V_VALOR_BASE_SUBST := V_PFAT_P_PEDF_QTDE *
                                    V_PFAT_P_TPRC_BASE_SUBST;
            V_VLR_SUBST_NORMAL := V_PFAT_P_PEDF_QTDE * V_BASE_SUBST_NORMAL;
          END IF;--5
          if  (V_USAR_REGRA_PAR_ALIQUOTA = 0) Then
            IF (V_PFAT_P_TPRC_ALIQ_ICM_SUBS <> 0) AND
             (V_VALOR_ICM_SUBST           <> 0)THEN
             V_VALOR_BASE_SUBST := (V_VALOR_ICM_SUBST + V_VALOR_ICM) * 100 /
                                    V_PFAT_P_TPRC_ALIQ_ICM_SUBS;
            ELSE
              IF (V_ALIQ_ICM <> 0) AND
                 (V_VALOR_ICM_SUBST <> 0) THEN
                V_VALOR_BASE_SUBST := (V_VALOR_ICM_SUBST + V_VALOR_ICM) * 100 /
                                        V_ALIQ_ICM;
              END IF;
          End if;
         END IF;
        END IF;--6

      ELSE
        V_VALOR_ICM_SUBST  := ((V_PFAT_P_TPRC_BASE_SUBST * V_PFAT_P_PEDF_QTDE) * V_ALIQ_SUBST/ 100) - V_VALOR_ICM_DIF;
        V_VALOR_BASE_SUBST := V_PFAT_P_PEDF_QTDE *  V_PFAT_P_TPRC_BASE_SUBST;
        V_VLR_SUBST_NORMAL := V_PFAT_P_PEDF_QTDE * V_BASE_SUBST_NORMAL;
       IF V_VALOR_ICM_SUBST < 0 THEN
          V_VALOR_ICM_SUBST := 0;
         END IF;
       END IF; -- V_VALOR_ICM_DIF > 0
      END IF;--2


   END IF;--0
    if (V_OPer_st_diferenciado_AL = 'S') And (V_PFAT_OPER_DESTINO_OPER = 2) Then --Calculo deferente para o estado de alagoas missiato
       V_VALOR_BASE_SUBST := V_VALOR_MERCADORIA +
                             V_PFAT_PEDF_VLR_FRETE+
                             Calculo_Pedido_Fat$PK.Obter_Valor_IPI+
                             NVL(V_PFAT_PEDF_VLR_SEG,0)
                             - V_DESCONTO_NOR_ITEM ;

      V_VALOR_ICM_SUBST := V_VALOR_BASE_SUBST *(V_PFAT_P_TPRC_ALIQ_ICM_SUBS/100);
    end if;
    V_VALOR_ICM_SUBST_PAUTA := V_VALOR_ICM_SUBST;
    V_VALOR_BASE_SUBST_PAUTA:= V_VALOR_BASE_SUBST;

     if (v_TPRC_ALIQ_MVA > 0) And (v_TPRC_ALIQ_ST_MVA > 0) AND  (V_PFAT_OPER_TIPO_ICMR <> 2)   then
       -- esse and (V_PEDF_PERC_DESC_ORIGINAL > 0) foi colocado pq qto tem desconto o IPI já esta na variavel V_VALOR_MERCADORIA_MVA
       IF (V_VALORIZO_IPI) and (V_PEDF_PERC_DESC_ORIGINAL > 0)  THEN
           V_VALOR_BASE_SUBST := (V_VALOR_MERCADORIA_MVA  * (v_TPRC_ALIQ_MVA / 100)) + V_VALOR_MERCADORIA_MVA ;
           IF (V_oper_aliq_st_ret = 'S') AND (V_OPER_ALIQ_RED_BC_ICM_OE > 0)AND (V_USAR_REGRA_PAR_ALIQUOTA = 1) THEN
             V_VALOR_BASE_SUBST := V_VALOR_BASE_SUBST - (V_VALOR_BASE_SUBST * V_OPER_ALIQ_RED_BC_ICM_OE /100 );
           END IF;

          IF (V_ALIQ_ICM_REDUCAO > 0)then
              V_VALOR_ICM_SUBST := (V_VALOR_BASE_SUBST * (V_ALIQ_SUBST / 100)) -  ((V_VALOR_MERCADORIA_MVA * V_ALIQ_ICM_REDUCAO/100) * v_TPRC_ALIQ_ST_MVA/100);
           else
             V_VALOR_ICM_SUBST := (V_VALOR_BASE_SUBST * (V_ALIQ_SUBST / 100)) -  (V_VALOR_MERCADORIA_MVA * v_TPRC_ALIQ_ST_MVA/100);
           end if;

        ELSE

            V_VALOR_BASE_SUBST := (V_VALOR_MERCADORIA_MVA + NVL(OBTER_VALOR_IPI,0)) * (v_TPRC_ALIQ_MVA / 100) +
                                  (V_VALOR_MERCADORIA_MVA + NVL(OBTER_VALOR_IPI,0));


            IF (V_oper_aliq_st_ret = 'S') AND (V_OPER_ALIQ_RED_BC_ICM_OE > 0)AND (V_USAR_REGRA_PAR_ALIQUOTA = 1) THEN
             V_VALOR_BASE_SUBST := V_VALOR_BASE_SUBST - (V_VALOR_BASE_SUBST * V_OPER_ALIQ_RED_BC_ICM_OE /100 );
            END IF;


           IF  (V_ALIQ_ICM_REDUCAO > 0)then
            if not V_VALORIZO_IPI then --qto for pessoa juridica nao deve soma o ipi no valor da mercadoria a nao ser q este parametrizada a operação ou juridica nao contribuite
               V_VALOR_ICM_SUBST := (V_VALOR_BASE_SUBST * (V_ALIQ_SUBST / 100)) -  ((V_VALOR_MERCADORIA_MVA * V_ALIQ_ICM_REDUCAO/100)  * v_TPRC_ALIQ_ST_MVA/100);
            else
             V_VALOR_ICM_SUBST := (V_VALOR_BASE_SUBST * (V_ALIQ_SUBST / 100)) -  (((V_VALOR_MERCADORIA_MVA + NVL(OBTER_VALOR_IPI,0)* V_ALIQ_ICM_REDUCAO/100)) * v_TPRC_ALIQ_ST_MVA/100);
             end if ;


          else
            if not V_VALORIZO_IPI then --qto for pessoa juridica nao deve soma o ipi no valor da mercadoria a nao ser q este parametrizada a operação ou juridica nao contribuite
               V_VALOR_ICM_SUBST := (V_VALOR_BASE_SUBST * (V_ALIQ_SUBST / 100)) -  (V_VALOR_MERCADORIA_MVA   * v_TPRC_ALIQ_ST_MVA/100);
            else
             V_VALOR_ICM_SUBST := (V_VALOR_BASE_SUBST * (V_ALIQ_SUBST / 100)) -  ((V_VALOR_MERCADORIA_MVA + NVL(OBTER_VALOR_IPI,0)) * v_TPRC_ALIQ_ST_MVA/100);
             end if ;
          end if;

       END IF;
       V_VALOR_ICM_SUBST_MVA := V_VALOR_ICM_SUBST;
       V_VALOR_BASE_SUBST_MVA:= V_VALOR_BASE_SUBST;
       if V_VALOR_ICM_SUBST_MVA < 0 then
         V_VALOR_ICM_SUBST_MVA := 0;
       end if ;

       if  V_VALOR_BASE_SUBST_MVA < 0 then
         V_VALOR_BASE_SUBST_MVA := 0;
       end if ;

    end if ;

    IF (V_GATILHO_PER_MVA > 0) AND  (V_PFAT_OPER_TIPO_ICMR <> 2) THEN
     /*'0 OU NULO NÃO USA GATILHO' ;
     '1-GATILHO MVA(%S/MERC.LIQ.)' ;
     '2-MAIOR VALOR IMPOSTO' ;
     '3-GATILHO MVA(%S/MERC.LIQ.)SEM IPI' ;
     '4-GATILHO SOBRE VALOR TOTAL DO ITEM'
      5-ST CARGA TRIBUTÁRIA MÉDIA*/
     CASE
        WHEN v_REGRA_CORTE_GATILHO = 1 THEN
          IF (V_VALOR_MERCADORIA +  NVL(OBTER_VALOR_IPI,0)) >= (V_GATILHO_PER_MVA/100) * V_VALOR_BASE_SUBST_PAUTA  THEN
              V_VALOR_ICM_SUBST := V_VALOR_ICM_SUBST_MVA  ;
              V_VALOR_BASE_SUBST:= V_VALOR_BASE_SUBST_MVA;
            ELSE
              V_VALOR_ICM_SUBST := V_VALOR_ICM_SUBST_PAUTA;
              V_VALOR_BASE_SUBST:= V_VALOR_BASE_SUBST_PAUTA;
          END IF;

        WHEN v_REGRA_CORTE_GATILHO = 2 THEN
           IF (V_VALOR_ICM_SUBST_MVA/V_VALOR_ICM_SUBST_PAUTA) -1 > (V_GATILHO_PER_MVA/100) THEN
              V_VALOR_ICM_SUBST := V_VALOR_ICM_SUBST_MVA;
              V_VALOR_BASE_SUBST:= V_VALOR_BASE_SUBST_MVA;
            ELSE
              V_VALOR_ICM_SUBST := V_VALOR_ICM_SUBST_PAUTA;
              V_VALOR_BASE_SUBST:= V_VALOR_BASE_SUBST_PAUTA;
            END IF;

         WHEN v_REGRA_CORTE_GATILHO = 3 THEN

          IF (V_VALOR_MERCADORIA) >= (V_GATILHO_PER_MVA/100) * V_VALOR_BASE_SUBST_PAUTA  THEN
              V_VALOR_ICM_SUBST := V_VALOR_ICM_SUBST_MVA  ;
              V_VALOR_BASE_SUBST:= V_VALOR_BASE_SUBST_MVA;
            ELSE
              V_VALOR_ICM_SUBST := V_VALOR_ICM_SUBST_PAUTA;
              V_VALOR_BASE_SUBST:= V_VALOR_BASE_SUBST_PAUTA;
          END IF;

        WHEN v_REGRA_CORTE_GATILHO = 4 THEN

          IF (V_VALOR_MERCADORIA +  NVL(OBTER_VALOR_IPI,0)+ V_VALOR_ICM_SUBST_PAUTA ) > (V_GATILHO_PER_MVA/100) * V_VALOR_BASE_SUBST_PAUTA  THEN
              V_VALOR_ICM_SUBST := V_VALOR_ICM_SUBST_MVA  ;
              V_VALOR_BASE_SUBST:= V_VALOR_BASE_SUBST_MVA;
            ELSE
              V_VALOR_ICM_SUBST := V_VALOR_ICM_SUBST_PAUTA;
              V_VALOR_BASE_SUBST:= V_VALOR_BASE_SUBST_PAUTA;
          END IF;


      END CASE;
    END IF;
      IF  v_REGRA_CORTE_GATILHO = 5 THEN -- regra CNAE DYDYO
          IF V_OPER_SUFRAMA = 'S' THEN
             V_VALOR_BASE_SUBST := (V_BASE_ICMS - V_VALOR_ICM) * V_PEDF_TPRC_MARGEM_LUCRO / 100;
             V_VALOR_ICM_SUBST  := (V_VALOR_BASE_SUBST * V_ALIQ_SUBST / 100) - V_VALOR_ICM;
          ELSE
           VLR_ICMS_OP_PROPRIA    := V_VALOR_MERCADORIA *(V_ALIQ_ICM/100);
           V_VALOR_ICM_SUBST      := (V_VALOR_MERCADORIA +
                                     NVL(OBTER_VALOR_IPI,0) +
                                     V_PFAT_PEDF_VLR_SEG +
                                     V_PFAT_PEDF_VLR_DESP +
                                     V_PFAT_PEDF_VLR_FRETE) * (V_ALIQ_SUBST/100);
           V_VALOR_BASE_SUBST:= (VLR_ICMS_OP_PROPRIA + V_VALOR_ICM_SUBST)/(v_TPRC_ALIQ_ST_MVA/100);

        END IF;
       ELSE
       IF (v_CLI_ST_REGIME_CNAE = 'S')and (V_PFAT_OPER_DESTINO_OPER = 2) then
           V_VALOR_BASE_SUBST := V_BASE_ICMS ;
           V_VALOR_ICM_SUBST  := (V_VALOR_BASE_SUBST * V_ALIQ_SUBST / 100);
       end if ;
    END IF;
    IF (V_UF_EMPRESA <> V_UF_CLIENTE) --VENDA FORA DO ESTADO ICMS_ST DIFAL
       AND (NVL(V_GATILHO_PER_MVA,0) = 0)
       AND (V_PFAT_OPER_TIPO_ICMR <> 2)
       AND (NVL(v_REGRA_CORTE_GATILHO,0) = 0)
       AND (NVL(V_USAR_CALC_ST_DIFAL,0) = 1)
       AND (NVL(V_ALIQ_ICMS_UF_DEST,0)>0
       AND (NVL(V_ALIQ_ICM,0) >0)  )

    THEN
      V_VALOR_BASE_SUBST := CalcIcmsStDIFAL(V_VALOR_MERCADORIA + NVL(OBTER_VALOR_IPI,0)
                                            ,V_ALIQ_ICMS_UF_DEST/100 -- ALIQUOTA INTERNA PEGA GENER ESTADO NR01
                                            ,V_ALIQ_ICM/100          -- ALIQUOTA INTER-ESTADUAL PEGAR OP
                                            ,0                   -- VALOR ICMS
                                            ,v_TPRC_ALIQ_MVA/100     -- % MVA
                                            ,V_PFAT_P_TPRC_ICM_SUBST * V_PFAT_P_PEDF_QTDE); ---PAUTA ST


    END IF;


    IF (V_VALOR_ICM_SUBST <= 0) AND (V_REDUZ_ST_SIMPLES_NAC = 0) AND (V_ZERA_BASE_ST = 0) THEN
        V_VALOR_BASE_SUBST := 0;
     End if ;
    V_VALOR_ICM_SUBST := round(V_VALOR_ICM_SUBST,2);
     IF V_VALOR_ICM_TEMP > 0 THEN
        V_VALOR_ICM        := V_VALOR_ICM_TEMP;
     END IF;

     if V_BASE_ICMS_TEMP > 0 then
        V_BASE_ICMs        := V_BASE_ICMS_TEMP;
     end if ;
 IF (V_VALOR_ICM_SUBST <= 0)
     then V_VALOR_ICM_SUBST := 0;
  end if;

  RETURN (ROUND(V_VALOR_BASE_SUBST,2));

  EXCEPTION
    WHEN OTHERS THEN
      RETURN (-1);
  END Obter_Base_Subst;

 FUNCTION Obter_Valor_IPI_SEG RETURN REAL AS
   V_VALOR_IPI_A REAL := 0;
   V_VALOR_IPI_V REAL := 0;
  BEGIN
  IF V_PFAT_OPER_TIPO_IPI = 1 THEN
   SELECT
     SUM(NVL(F.PEDF_QTDE,0) *  NVL(P.PROF_VLR_IPI,0) )VALOR_IPI
     INTO V_VALOR_IPI_A
   FROM     PEDIDO_FAT_P F
           ,PRODUTO_FAT P
   WHERE     F.PEDF_PROD_EMP_ID = P.PROF_PROD_EMP_ID
         AND F.PEDF_PROD_ID     = P.PROF_PROD_ID
         AND F.PEDF_PEDF_EMP_ID = V_EMP_ATIVA
         AND F.PEDF_PEDF_ID     = V_PFAT_PEDF_ID ;

   SELECT
     SUM((NVL(F.PEDF_QTDE,0) * NVL(F.PEDF_VLR_UNIT,0)) *  NVL(P.PROF_ALIQ_IPI,0)/100) VALOR_IPI
     INTO V_VALOR_IPI_V
    FROM     PEDIDO_FAT_P F
            ,PRODUTO_FAT P
    WHERE        F.PEDF_PROD_EMP_ID = P.PROF_PROD_EMP_ID
             AND F.PEDF_PROD_ID     = P.PROF_PROD_ID
             AND F.PEDF_PEDF_EMP_ID =  V_EMP_ATIVA
             AND F.PEDF_PEDF_ID     = V_PFAT_PEDF_ID ;
    END IF;

    RETURN (ROUND(V_VALOR_IPI_A +  V_VALOR_IPI_V ,2));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (-1);
  END Obter_Valor_IPI_SEG ;

  FUNCTION Obter_Valor_ADF_FINAC RETURN REAL AS
   V_VALOR_ADF REAL := 0;
  BEGIN
  SELECT
         SUM(ROUND(TAB_PRECO.TPRC_PRC_FINAL  * ((DECODE(CVTO_PRAZO_MEDIO,99999,I.NUMERO_DIAS,CVTO_PRAZO_MEDIO)*ADC_FIN.GEN_NUMBER1)/100),2) * PEDF_QTDE)ADF_FINAC
        ,ROUND(SUM(NVL(PEDF_QTDE,0) * (NVL(PEDF_VLR_UNIT,0) + ROUND(TPRC_PRC_FINAL  * ((DECODE(CVTO_PRAZO_MEDIO,99999,I.NUMERO_DIAS,CVTO_PRAZO_MEDIO)*NVL(ADC_FIN.GEN_NUMBER1,0))/100),2)) * NVL(PEDF_PERC_DESC,0)) / 100,2)
        INTO  V_VALOR_ADF
             ,V_PFAT_TOT_DESC
   FROM  PEDIDO_FAT_P
        ,PEDIDO_FAT F
        ,CLIENTE
        ,GENER ADC_FIN
        ,TAB_PRECO
        ,(Select
                 CVTO_CVTO_EMP_ID
                 ,CVTO_CVTO_ID
                 ,Max(COND_VCTO_P.CVTO_DIAS_VCTO) NUMERO_DIAS
                 ,NVL(CVTO_PRAZO_MEDIO,99999)         CVTO_PRAZO_MEDIO
               FROM
                 COND_VCTO_P,
                 COND_VCTO C
               WHERE
                     C.CVTO_EMP_ID    = CVTO_CVTO_EMP_ID
                 AND C.CVTO_ID        = CVTO_CVTO_ID
                 AND CVTO_CVTO_EMP_ID = V_EMP_ATIVA
               GROUP BY
                 CVTO_CVTO_EMP_ID,
                 CVTO_CVTO_ID,
                 NVL(CVTO_PRAZO_MEDIO,99999)
           ) I
   WHERE       F.PEDF_EMP_ID                       = PEDF_PEDF_EMP_ID
          AND  F.PEDF_ID                           = PEDF_PEDF_ID
          AND  F.PEDF_LIQU_EMP_ID                  = V_EMP_ATIVA
          AND  F.PEDF_LIQU_ID                      = V_LIQUID
          AND  PEDF_EMP_ID                         = V_EMP_ATIVA
          AND  F.PEDF_ID                           = V_PFAT_PEDF_ID
          AND  F.PEDF_CLI_EMP_ID                   = CLI_EMP_ID
          AND  F.PEDF_CLI_ID                       = CLI_ID
          AND  ADC_FIN.GEN_TGEN_ID                 (+) = CLI_GEN_TGEN_ID_TAB_ADC_FIN_DE
          AND  ADC_FIN.GEN_ID                      (+) = CLI_GEN_ID_TAB_ADC_FIN_DE
          AND  ADC_FIN.GEN_EMP_ID                  (+) = CLI_GEN_EMP_ID_TAB_ADC_FIN_DE
          AND  PEDF_SITUACAO                       = 0
          AND  I.CVTO_CVTO_EMP_ID                  = F.PEDF_CVTO_EMP_ID
          AND  I.CVTO_CVTO_ID                      = F.PEDF_CVTO_ID
          AND  TAB_PRECO.TPRC_PROD_EMP_ID          = PEDIDO_FAT_P.PEDF_TPRC_PROD_EMP_ID
          AND  TAB_PRECO.TPRC_PROD_ID              = PEDIDO_FAT_P.PEDF_TPRC_PROD_ID
          AND  TAB_PRECO.TPRC_EMP_ID               = PEDIDO_FAT_P.PEDF_TPRC_EMP_ID
          AND  TAB_PRECO.TPRC_GEN_TGEN_ID          = PEDIDO_FAT_P.PEDF_TPRC_GEN_TGEN_ID
          AND  TAB_PRECO.TPRC_GEN_EMP_ID           = PEDIDO_FAT_P.PEDF_TPRC_GEN_EMP_ID
          AND  TAB_PRECO.TPRC_GEN_ID               = PEDIDO_FAT_P.PEDF_TPRC_GEN_ID
          AND  TAB_PRECO.TPRC_DTA_VIGENCIA         = PEDIDO_FAT_P.PEDF_TPRC_DTA_VIGENCIA ;

  RETURN (ROUND(NVL(V_VALOR_ADF,0),2));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END Obter_Valor_ADF_FINAC;


  FUNCTION Obter_Valor_IPI RETURN REAL AS
  V_VALOR_IPI REAL := 0;
  V_VALOR_FRETE_SEG_NA_BASE REAL := 0;
  V_DESCONTO_NOR_ITEM_IPI   REAL := 0;
  BEGIN
    IF (V_PFAT_PEDF_VLR_DESC <> 0) AND (V_DESC_BASE_IPI = 1) THEN
          V_DESCONTO_NOR_ITEM_IPI  := RATIAR_VALOR(V_VLR_TOT_MERCADORIA , V_PFAT_PEDF_VLR_DESC, (V_PFAT_P_TPRC_PRC_FAB * V_PFAT_P_PEDF_QTDE));
        END IF;

    IF V_PFAT_OPER_TIPO_IPI = 1 THEN
      IF V_PFAT_P_PROF_VLR_IPI > 0 THEN
          V_VALOR_IPI :=  V_PFAT_P_PEDF_QTDE * V_PFAT_P_PROF_VLR_IPI;
      ELSE
        IF V_PFAT_P_PROF_ALIQ_IPI <> 0 THEN
         IF V_PROD_SOMA_FRETE_IPI = 'S' THEN
            V_VALOR_FRETE_SEG_NA_BASE := V_VLR_FRETE_RATEIO + RATIAR_VALOR(V_VLR_TOT_MERCADORIA    - V_TOT_MERC_SELO,V_PFAT_PEDF_VLR_SEG, V_VALOR_MERCADORIA);
         ELSE
            V_VALOR_FRETE_SEG_NA_BASE := 0;
         END IF ;
      --AQUI
          IF (V_PEDF_PERC_DESC_ORIGINAL > 0) THEN
             IF V_VALOR_MERC_ALIQ_IPI_DIF > 0 THEN --  OBTER VALOR DE IPI DIFERENCIADO
                 V_VALOR_IPI := (V_VALOR_MERC_ALIQ_IPI_DIF - V_DESCONTO_NOR_ITEM_IPI)  * V_PFAT_P_PROF_ALIQ_IPI / 100;
               ELSE
                if V_DESC_BASE_IPI = 1 then
                   V_VALOR_IPI := ((V_VALOR_MERCADORIA + V_PRECO_FRETE_IPI - V_DESCONTO_NOR_ITEM_IPI  - (V_VALOR_MERCADORIA * V_PEDF_PERC_DESC_ORIGINAL / 100))+ V_VALOR_FRETE_SEG_NA_BASE)  * (V_PFAT_P_PROF_ALIQ_IPI/100);
                 else

                   if V_IPI > 0 then
                      -- essa variavel é calculada na função do vlr da mercadoria
                      --isso é uma tentativa de igualar os valores q é usado na composição do valor de mercadoria qto há ipi por aliq
                     -- if V_PASSO_PELA_REGRA_13097 then
                          V_VALOR_IPI :=  V_IPI;
                      --else
                     --  V_VALOR_IPI := V_PFAT_P_PEDF_QTDE * V_IPI;
                     --end if;
                     --------------
                   else
                     V_VALOR_IPI := (V_VALOR_MERCADORIA + V_PRECO_FRETE_IPI - V_DESCONTO_NOR_ITEM_IPI) * V_PFAT_P_PROF_ALIQ_IPI / 100;
                   end if;
                 end if;
             END IF ;

          ELSIF V_OPER_PRC_FINAL = 'S' THEN
            V_VALOR_IPI := ((V_VALOR_MERCADORIA + V_PRECO_FRETE_IPI - (V_VALOR_MERCADORIA * V_PFAT_P_PEDF_PERC_DESC / 100 )) * 100 / ( 100 + V_PFAT_P_PROF_ALIQ_IPI ) * V_PFAT_P_PROF_ALIQ_IPI )/ 100;
          ELSE

            IF V_VALOR_MERC_ALIQ_IPI_DIF > 0 THEN --  OBTER VALOR DE IPI DIFERENCIADO
               V_VALOR_IPI := (V_VALOR_MERC_ALIQ_IPI_DIF - V_DESCONTO_NOR_ITEM_IPI - (V_VALOR_MERCADORIA * (V_PFAT_P_PEDF_PERC_DESC / 100) )) * (V_PFAT_P_PROF_ALIQ_IPI/100);
             ELSE
               V_VALOR_IPI := ((V_VALOR_MERCADORIA + V_PRECO_FRETE_IPI - (V_VALOR_MERCADORIA * V_PEDF_PERC_DESC_ORIGINAL / 100) - V_DESCONTO_NOR_ITEM_IPI)+ V_VALOR_FRETE_SEG_NA_BASE)  * (V_PFAT_P_PROF_ALIQ_IPI/100);
           END IF ;

          END IF;
        END IF;
      END IF;
    END IF;
    RETURN (ROUND(V_VALOR_IPI,2));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (-1);
  END Obter_Valor_IPI;

 PROCEDURE Acerto_totais_notas IS
  VLR_TOTAL real;
     FUNCTION RETORNA_VLR_TOTAL_IMP (CAMPO In VARCHAR2) RETURN REAL IS
     vSQL      LONG;
     vValor    real;
     type cDados is REF CURSOR;
          cCursorDados  cDados;
     BEGIN
        vSQL := 'SELECT sum(round('||CAMPO||',2))Valor '||
                'FROM PEDIDO_FAT_P P ' ||
                'WHERE P.PEDF_PEDF_EMP_ID ='|| V_EMP_ATIVA||
                ' AND P.PEDF_PEDF_ID = '||V_PFAT_PEDF_ID;
         open cCursorDados for vSQL;
         fetch cCursorDados into
               vValor;

          RETURN(vValor);

      EXCEPTION
         WHEN OTHERS THEN
              RETURN (0);
      END RETORNA_VLR_TOTAL_IMP;
 begin
   VLR_TOTAL := RETORNA_VLR_TOTAL_IMP('PEDF_BASE_ICMS');
   for ARRED IN (select (  Valor_Seguro_item - f.pedf_vlr_seg) DIF_SEG
                          ,(Valor_FRETE_item - F.PEDF_VLR_FRETE) DIF_FRETE
                          ,vPrimItem
                          ,Valor_ICMS
        ,Valor_desp_item - Pedf_Vlr_desp DIF_DESP
                                 from pedido_fat f

                                ,(SELECT PEDF_PEDF_ID
                                    ,PEDF_PEDF_EMP_ID
                                    ,sum(round(Pedf_Valor_Seguro,2))Valor_Seguro_item
                                    ,sum(round(Pedf_Valor_FRETE,2))Valor_FRETE_item
                                    ,min(p.pedf_id)vPrimItem
                                    ,case when VLR_TOTAL > 0 then sum(P.Pedf_Base_Icms)
                                     else 0
                                    end Valor_ICMS
           ,sum(round(Pedf_Valor_desp,2))Valor_desp_item
                                FROM PEDIDO_FAT_P P
                                WHERE P.PEDF_PEDF_EMP_ID = V_EMP_ATIVA
                                  AND P.PEDF_PEDF_ID     = V_PFAT_PEDF_ID
                                  group by   PEDF_PEDF_ID
                                            ,PEDF_PEDF_EMP_ID) prod
                                 where    f.pedf_emp_id = prod.PEDF_PEDF_EMP_ID
                                     and  f.pedf_id = prod.PEDF_PEDF_ID)

                 LOOP
                   UPDATE PEDIDO_FAT_P FP
                      SET FP.PEDF_VALOR_SEGURO        = FP.PEDF_VALOR_SEGURO - (ARRED.DIF_SEG)
                         ,FP.PEDF_BASE_ICMS           = FP.PEDF_BASE_ICMS  -  (VLR_TOTAL - ARRED.VALOR_ICMS)
                         ,FP.PEDF_VALOR_FRETE         = FP.PEDF_VALOR_FRETE - (ARRED.DIF_FRETE)
       ,FP.PEDF_VALOR_DESP          = FP.PEDF_VALOR_DESP - (ARRED.DIF_DESP)
                           WHERE     FP.PEDF_PEDF_EMP_ID    = V_EMP_ATIVA
                                 AND FP.PEDF_PEDF_ID        = V_PFAT_PEDF_ID
                                 AND FP.PEDF_ID             = ARRED.VPRIMITEM;
                          COMMIT;

                 END LOOP;
 end Acerto_totais_notas;

  PROCEDURE Obter_Valor_PIS_COFINS IS

 -- V_DEBITO_PIS_COFINS VARCHAR2(1);
  V_DESP_ACESSORIAS_ITEM REAL := 0;
  V_PAUTA_PIS    REAL := 0;
  V_PAUTA_COFINS REAL := 0;

  FUNCTION  ObterPisCofinsTM(PIS_COFINS IN VARCHAR
                           ,INDICADOR IN VARCHAR
                           ,PROD_ID IN REAL) RETURN REAL AS
  VALOR          REAL := 0;

   BEGIN
      IF PIS_COFINS ='PIS' THEN
         SELECT   NVL(TAB_PRC_MD.TPRC_PIS_COFINS,0)
                   INTO VALOR
          FROM TAB_PRC_MD
              ,(SELECT
                  tprc_emp_id,
                  tprc_prod_emp_id,
                  tprc_prod_id,
                  tprc_gen_id,
                  tprc_gen_tgen_id,
                  tprc_gen_emp_id,
                  max(tprc_data) TPRC_DATA
              FROM TAB_PRC_MD
              WHERE tprc_emp_id = V_EMP_ATIVA
                AND tprc_prod_emp_id = V_EMP_ATIVA
                AND tprc_prod_id = PROD_ID
                AND tprc_gen_id = 100
                AND tprc_gen_tgen_id = 959
                AND tprc_gen_emp_id = V_EMP_ATIVA
              GROUP BY tprc_emp_id,
                  tprc_prod_emp_id,
                  tprc_prod_id,
                  tprc_gen_id,
                  tprc_gen_tgen_id,
                  tprc_gen_emp_id   ) ULTIMA

          WHERE TAB_PRC_MD.TPRC_PROD_EMP_ID            = ULTIMA.TPRC_PROD_EMP_ID
            AND TAB_PRC_MD.TPRC_PROD_ID                = ULTIMA.TPRC_PROD_ID
            AND TAB_PRC_MD.TPRC_GEN_ID                 = ULTIMA.TPRC_GEN_ID
            AND TAB_PRC_MD.TPRC_GEN_TGEN_ID            = ULTIMA.TPRC_GEN_TGEN_ID
            AND TAB_PRC_MD.TPRC_GEN_EMP_ID             = ULTIMA.TPRC_GEN_EMP_ID
            AND TAB_PRC_MD.TPRC_EMP_ID                 = ULTIMA.TPRC_EMP_ID
            AND TAB_PRC_MD.TPRC_DATA                   = ULTIMA.TPRC_DATA
            AND TAB_PRC_MD.TPRC_EMP_ID                 = V_EMP_ATIVA
            AND TAB_PRC_MD.TPRC_GEN_TGEN_ID            = 959
            AND TAB_PRC_MD.TPRC_GEN_EMP_ID             = V_EMP_ATIVA
            AND TAB_PRC_MD.TPRC_GEN_ID                 = 100
            AND TAB_PRC_MD.TPRC_PROD_ID                = PROD_ID
            AND NVL(TAB_PRC_MD.TPRC_CALC_ALIQ,'N')     = INDICADOR;
        ELSE
          SELECT   NVL(TAB_PRC_MD.TPRC_COFINS,0)
                   INTO VALOR
          FROM TAB_PRC_MD
              ,(SELECT
                  tprc_emp_id,
                  tprc_prod_emp_id,
                  tprc_prod_id,
                  tprc_gen_id,
                  tprc_gen_tgen_id,
                  tprc_gen_emp_id,
                  max(tprc_data) TPRC_DATA
              FROM TAB_PRC_MD
              WHERE tprc_emp_id = V_EMP_ATIVA
                AND tprc_prod_emp_id = V_EMP_ATIVA
                AND tprc_prod_id = PROD_ID
                AND tprc_gen_id = 100
                AND tprc_gen_tgen_id = 959
                AND tprc_gen_emp_id = V_EMP_ATIVA
              GROUP BY tprc_emp_id,
                  tprc_prod_emp_id,
                  tprc_prod_id,
                  tprc_gen_id,
                  tprc_gen_tgen_id,
                  tprc_gen_emp_id   ) ULTIMA

          WHERE TAB_PRC_MD.TPRC_PROD_EMP_ID            = ULTIMA.TPRC_PROD_EMP_ID
            AND TAB_PRC_MD.TPRC_PROD_ID                = ULTIMA.TPRC_PROD_ID
            AND TAB_PRC_MD.TPRC_GEN_ID                 = ULTIMA.TPRC_GEN_ID
            AND TAB_PRC_MD.TPRC_GEN_TGEN_ID            = ULTIMA.TPRC_GEN_TGEN_ID
            AND TAB_PRC_MD.TPRC_GEN_EMP_ID             = ULTIMA.TPRC_GEN_EMP_ID
            AND TAB_PRC_MD.TPRC_EMP_ID                 = ULTIMA.TPRC_EMP_ID
            AND TAB_PRC_MD.TPRC_DATA                   = ULTIMA.TPRC_DATA
            AND TAB_PRC_MD.TPRC_EMP_ID                 = V_EMP_ATIVA
            AND TAB_PRC_MD.TPRC_GEN_TGEN_ID            = 959
            AND TAB_PRC_MD.TPRC_GEN_EMP_ID             = V_EMP_ATIVA
            AND TAB_PRC_MD.TPRC_GEN_ID                 = 100
            AND TAB_PRC_MD.TPRC_PROD_ID                = PROD_ID
            AND NVL(TAB_PRC_MD.TPRC_CALC_ALIQ,'N')     = INDICADOR;
        END IF;



       RETURN(VALOR);
    EXCEPTION
        WHEN OTHERS THEN
        RETURN (0);
END;



  BEGIN
         V_BASE_PIS    :=0;
         V_BASE_COFINS :=0;
         V_VALOR_PIS   :=0;
         V_VALOR_COFINS:=0;
         V_ALIQ_COFINS :=0;
         V_ALIQ_PIS    :=0;
         v_VALOR_DESO  :=0;
         IF V_DEDUZ_ICMS_BASE_PIS = 1 THEN
           v_VALOR_DESO := 0;
           ELSE
          v_VALOR_DESO := ROUND(V_VALOR_ICM,2);
         END IF;

  IF (V_PFAT_P_CONTROLE_ISENTO = 0) THEN
                 V_TOT_ITENS_ISENTOS_PIS := V_TOT_ITENS_ISENTOS_PIS + V_VALOR_MERCADORIA;
          END IF;

          IF (V_PFAT_P_CONTROLE_ISENTO = 1 AND V_TOT_ITENS_ISENTOS_PIS > 0) THEN
              V_DESP_ACESSORIAS_ITEM := RATIAR_VALOR(V_VLR_TOT_MERCADORIA  - NVL(V_TOT_MERC_SELO,0), (V_PFAT_PEDF_VLR_DESP + V_PFAT_PEDF_VLR_SEG),(V_VALOR_MERCADORIA  +
                                        RATIAR_VALOR((V_VLR_TOT_MERCADORIA  - NVL(V_TOT_MERC_SELO,0) - V_TOT_ITENS_ISENTOS_PIS), V_TOT_ITENS_ISENTOS_PIS,V_VALOR_MERCADORIA)));
          END IF;

          IF (V_PFAT_P_CONTROLE_ISENTO = 1 AND V_TOT_ITENS_ISENTOS_PIS = 0) THEN
              V_DESP_ACESSORIAS_ITEM := RATIAR_VALOR(V_VLR_TOT_MERCADORIA  - NVL(V_TOT_MERC_SELO,0), (V_PFAT_PEDF_VLR_DESP + V_PFAT_PEDF_VLR_SEG) , V_VALOR_MERCADORIA);


          END IF;

        IF V_CST_PIS_COFINS = '01' THEN --CALCULO PELA ALIQ GENER 945 ID 55 E 66
         IF V_PASSO_PELA_REGRA_13097 THEN
            V_ALIQ_PIS    := V_PLI_ALIQ_PIS;
            V_ALIQ_COFINS := V_PLI_ALIQ_COFINS;
          ELSE
            SELECT GEN_NUMBER1
                INTO V_ALIQ_PIS
                FROM GENER
               WHERE GEN_TGEN_ID = 945
                 AND GEN_EMP_ID = V_EMP_ATIVA
                 AND GEN_ID = 55;
              SELECT GEN_NUMBER1
                INTO V_ALIQ_COFINS
              FROM GENER
              WHERE GEN_TGEN_ID = 945
                AND GEN_EMP_ID = V_EMP_ATIVA
                AND GEN_ID = 66;
          END IF;
           V_BASE_PIS := (V_VALOR_MERCADORIA  + V_PRECO_FRETE  + V_DESP_ACESSORIAS_ITEM - V_DESCONTO_NOR_ITEM - v_VALOR_DESO);
           V_VALOR_PIS:=  V_BASE_PIS * (V_ALIQ_PIS / 100);
           V_BASE_COFINS := V_BASE_PIS;
           V_VALOR_COFINS:= V_BASE_COFINS * (V_ALIQ_COFINS / 100);

        END IF;--IF V_CST_PIS_COFINS = '01'

        IF V_CST_PIS_COFINS = '02' THEN --PIS_COFINS PREÇO MEDIO POR ALIQUOTA
            IF V_PASSO_PELA_REGRA_13097 THEN
               V_ALIQ_PIS    := V_PLI_ALIQ_PIS;
               V_ALIQ_COFINS := V_PLI_ALIQ_COFINS;
             ELSE
               V_ALIQ_PIS    := ObterPisCofinsTM('PIS','S',V_PFAT_P_PEDF_PROD_ID);
               V_ALIQ_COFINS := ObterPisCofinsTM('COFINS','S',V_PFAT_P_PEDF_PROD_ID);
            END IF ;

           V_BASE_PIS := (V_VALOR_MERCADORIA  + V_PRECO_FRETE  + V_DESP_ACESSORIAS_ITEM - V_DESCONTO_NOR_ITEM - v_VALOR_DESO);
           V_VALOR_PIS:=  V_BASE_PIS * (V_ALIQ_PIS / 100);
           V_BASE_COFINS := V_BASE_PIS;
           V_VALOR_COFINS:= V_BASE_COFINS * (V_ALIQ_COFINS / 100);

        END IF;--IF V_CST_PIS_COFINS = '02'
       IF V_CST_PIS_COFINS = '03' THEN --PIS_COFINS PREÇO MEDIO POR PAUTA
            IF V_PASSO_PELA_REGRA_13097 THEN
                V_PAUTA_PIS    := V_PLI_VLR_PIS_MIN;
                V_PAUTA_COFINS := V_PLI_VLR_COFINS_MIN;
            ELSE
                V_PAUTA_PIS    := ObterPisCofinsTM('PIS','N',V_PFAT_P_PEDF_PROD_ID);
                V_PAUTA_COFINS := ObterPisCofinsTM('COFINS','N',V_PFAT_P_PEDF_PROD_ID);
            END IF;

                V_ALIQ_PIS     := V_PAUTA_PIS;
                V_ALIQ_COFINS  := V_PAUTA_COFINS;
                V_BASE_PIS     := (V_PFAT_P_PEDF_QTDE * (V_PFAT_P_PROC_LITRAGEM  / 1000) * V_FATOR_CX_PRODUTO);
                V_BASE_COFINS  := (V_PFAT_P_PEDF_QTDE * (V_PFAT_P_PROC_LITRAGEM  / 1000) * V_FATOR_CX_PRODUTO);
                V_VALOR_PIS    := (V_PFAT_P_PEDF_QTDE * (V_PFAT_P_PROC_LITRAGEM  / 1000) * V_FATOR_CX_PRODUTO) *
                                   V_PAUTA_PIS;
                V_VALOR_COFINS := (V_PFAT_P_PEDF_QTDE * (V_PFAT_P_PROC_LITRAGEM  / 1000) * V_FATOR_CX_PRODUTO) *
                                   V_PAUTA_COFINS;



        END IF ;--IF V_CST_PIS_COFINS = '03' THEN

        IF V_CST_PIS_COFINS in('04','06') THEN
            V_ALIQ_PIS     := 0;
            V_VALOR_PIS    := 0;
            V_BASE_PIS     := (V_VALOR_MERCADORIA  + V_PRECO_FRETE  + V_DESP_ACESSORIAS_ITEM - V_DESCONTO_NOR_ITEM);
            V_ALIQ_COFINS  := 0;
            V_VALOR_COFINS := 0;
            V_BASE_COFINS  := (V_VALOR_MERCADORIA  + V_PRECO_FRETE  + V_DESP_ACESSORIAS_ITEM - V_DESCONTO_NOR_ITEM);
        END IF ;--IF V_CST_PIS_COFINS = 'in('04','06')

        IF V_CST_PIS_COFINS = '49' THEN
            V_ALIQ_PIS     := 0;
            V_VALOR_PIS    := 0;
            V_BASE_PIS     := 0;
            V_ALIQ_COFINS  := 0;
            V_VALOR_COFINS := 0;
            V_BASE_COFINS  := 0;
        END IF ;--IF V_CST_PIS_COFINS = 49


        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              BEGIN
              V_BASE_PIS    :=0;
              V_BASE_COFINS :=0;
              V_VALOR_PIS   :=0;
              V_VALOR_COFINS:=0;
              V_ALIQ_COFINS :=0;
              V_ALIQ_PIS    :=0;


    END;
END Obter_Valor_PIS_COFINS;

  FUNCTION Obter_Impostos_Servicos RETURN REAL AS
  V_VALOR_IMPOSTOS REAL := 0;
  IMPOSTOS         REAL := 0;
  BEGIN


    IF V_PFAT_P_PROF_RETEM_PIS <> 'S' THEN

          SELECT
             SUM(NVL(PEDF_VLR_PIS,0) + NVL(PEDF_VLR_COFINS,0) + NVL(PEDF_VLR_CSL,0))
          INTO
             IMPOSTOS
          FROM
             PEDIDO_FAT   P
            ,PEDIDO_FAT_P PP
            ,PRODUTO_FAT
          WHERE
              P.PEDF_EMP_ID = V_EMP_ATIVA
          AND P.PEDF_ID     = V_PFAT_PEDF_ID
          AND PP.PEDF_PEDF_EMP_ID = P.PEDF_EMP_ID
          AND PP.PEDF_PEDF_ID     = P.PEDF_ID
          AND PP.PEDF_PROD_EMP_ID = PROF_PROD_EMP_ID (+)
          AND PP.PEDF_PROD_ID     = PROF_PROD_ID  (+)
          AND NVL(PROF_PIS,'N') <> 'S' AND NVL(PROF_COFINS,'N') <> 'S' ;

          V_VALOR_IMPOSTOS :=  IMPOSTOS;

    END IF;


    RETURN (ROUND(V_VALOR_IMPOSTOS,2));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END Obter_Impostos_Servicos;

  FUNCTION Obter_Valor_FRETE RETURN REAL AS
  V_VALOR_FRETE REAL := 0;
  BEGIN
     IF V_PFAT_LIQU_TIPO = 1 THEN
        V_VALOR_FRETE := V_PFAT_PEDF_VLR_FRETE;
     END IF;
     RETURN (V_VALOR_FRETE);
  EXCEPTION
     WHEN OTHERS THEN
        RETURN (-1);
  END Obter_Valor_FRETE;

  FUNCTION Existe_NF(Nr_NF In Real,
                     Serie In Varchar) RETURN INTEGER AS
    V_P_FAT_ID NUMBER := 0;
  BEGIN
    SELECT
      NVL(PEDF_ID,0)
    INTO
      V_P_FAT_ID
    FROM
      PEDIDO_FAT
    WHERE
      (PEDF_EMP_ID       = V_EMP_ATIVA
       AND PEDF_NR_NF    = Nr_NF
       AND PEDF_SERIE_NF = Serie)
      OR
      (PEDF_EMP_ID           = V_EMP_ATIVA
       AND PEDF_NR_NF_DEV    = Nr_NF
       AND PEDF_SERIE_NF_DEV = Serie)
  OR
       (PEDF_EMP_ID       = V_EMP_ATIVA
       AND PEDF_NR_NF    = Nr_NF
       AND PEDF_SERIE_NF = V_SERIE_NF_SCAN) ;
    IF V_P_FAT_ID = 0 THEN
      RETURN(0);
    ELSE
      RETURN(1);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(0);
  END Existe_NF;

  FUNCTION Prox_NR_NF(Tipo In Integer) RETURN REAL AS
    NR_NF REAL         := 0;
    SEL_SEQUENCE    VARCHAR2(1000);
    C_SEL_SEQ       INTEGER   := DBMS_SQL.OPEN_CURSOR;
    RETVAL          NUMBER;
    v_SERIE         VARCHAR2 (6) := '';


  BEGIN

   IF V_GERA_NF <> 1 THEN
        RETURN(NULL);
    END IF;
       Busca_Param_Serie(Tipo);

     IF (V_PEDF_SERIE_NFCE IS NOT NULL) and (V_EMP_UTILIZA_IE_PEDIDO = 'N') THEN     --serie usada para cupom fiscal
         V_PFAT_SERIE_NF := V_PEDF_SERIE_NFCE;
      END IF;


    If (Tipo = 1) then
        IF V_EMP_UTILIZA_IE_PEDIDO = 'N' THEN
           SEL_SEQUENCE := 'SELECT NUMERO_NF_'||V_EMP_ATIVA||'_'||V_PFAT_SERIE_NF||'_S'||'.NEXTVAL PROX_CODIGO'
                            ||' FROM DUAL';
        ELSE
          SEL_SEQUENCE := 'SELECT NUMERO_NF_'||V_EMP_ATIVA||'_'||V_PFAT_SERIE_NF||'_S_'||V_PEDF_INSCRICAO_ESTADUAL||'.NEXTVAL PROX_CODIGO'
                            ||' FROM DUAL';
        END IF;

        C_SEL_SEQ := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(C_SEL_SEQ, SEL_SEQUENCE, DBMS_SQL.NATIVE);
        RETVAL := DBMS_SQL.EXECUTE(C_SEL_SEQ);
        DBMS_SQL.DEFINE_COLUMN (C_SEL_SEQ, 1, NR_NF);

        LOOP
            EXIT WHEN DBMS_SQL.FETCH_ROWS (C_SEL_SEQ) = 0;
              DBMS_SQL.COLUMN_VALUE (C_SEL_SEQ, 1, NR_NF);
               NR_NF := NR_NF;
        END LOOP;


      IF (Existe_NF(NR_NF,V_PFAT_SERIE_NF) = 1) THEN
         RETURN (0);
      ELSE
         RETURN (NR_NF);
      END IF;

    ElsIf (Tipo = 2) then
        if v_SERIE_DEVOLUCAO is NULL THEN
           v_SERIE    := V_PFAT_SERIE_NF;
         ELSE
           v_SERIE    := v_SERIE_DEVOLUCAO;
        END IF;

        IF V_EMP_UTILIZA_IE_PEDIDO = 'N' THEN
            SEL_SEQUENCE := 'SELECT NUMERO_NF_'||V_EMP_ATIVA||'_'||v_SERIE||'_E'||'.NEXTVAL PROX_CODIGO'
                         ||' FROM DUAL';
        ELSE
             SEL_SEQUENCE := 'SELECT NUMERO_NF_'||V_EMP_ATIVA||'_'||V_PFAT_SERIE_NF||'_E_'||V_PEDF_INSCRICAO_ESTADUAL||'.NEXTVAL PROX_CODIGO'
                            ||' FROM DUAL';
        END IF;
        C_SEL_SEQ := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(C_SEL_SEQ, SEL_SEQUENCE, DBMS_SQL.NATIVE);
        RETVAL := DBMS_SQL.EXECUTE(C_SEL_SEQ);
        DBMS_SQL.DEFINE_COLUMN (C_SEL_SEQ, 1, NR_NF);

        LOOP
            EXIT WHEN DBMS_SQL.FETCH_ROWS (C_SEL_SEQ) = 0;
              DBMS_SQL.COLUMN_VALUE (C_SEL_SEQ, 1, NR_NF);
               NR_NF := NR_NF;
        END LOOP;

      IF (Existe_NF(NR_NF,V_PFAT_SERIE_NF) = 1) THEN
         RETURN (0);
      ELSE
         RETURN (NR_NF);
      END IF;
    end If;
  EXCEPTION
    WHEN OTHERS THEN
      if (Tipo = 1) then
        RETURN(0);
      ElsIf (Tipo = 2) then
        RETURN(Prox_NR_NF(1));
      End If;
  END Prox_NR_NF;

  FUNCTION  Obter_parametro_tributa_ipi(OPER_ID IN REAL
                                        ,PROD_ID IN REAL) RETURN VARCHAR2 AS
   BEGIN
     SELECT  NVL(O.OPER_TRIBUTA_IPI,'S')
                 INTO V_TRIBUTA_IPI
              FROM OPERACAO_PRODUTO_CFO O
              WHERE     O.OPER_OPER_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_OPER_ID           = OPER_ID
                    AND O.OPER_PROD_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_PROD_ID           = PROD_ID;

            RETURN(V_TRIBUTA_IPI);
           EXCEPTION
             WHEN OTHERS THEN
                RETURN ('S');
   END;

FUNCTION  Obter_EXCECAO_CALC_FCP(OPER_ID IN REAL
                                ,PROD_ID IN REAL) RETURN VARCHAR2 AS
V_FCP VARCHAR(1);
   BEGIN
     SELECT  NVL(O.OPER_EXCECAO_FCP,'S')
                 INTO V_FCP
              FROM OPERACAO_PRODUTO_CFO O
              WHERE     O.OPER_OPER_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_OPER_ID           = OPER_ID
                    AND O.OPER_PROD_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_PROD_ID           = PROD_ID;

            RETURN(V_FCP);
           EXCEPTION
             WHEN OTHERS THEN
                RETURN ('S');
END;

FUNCTION  Obter_ALIQ_EXCECAO_CALC_FCP(OPER_ID IN REAL
                                     ,PROD_ID IN REAL) RETURN VARCHAR2 AS
V_ALIQ VARCHAR(1);
   BEGIN
     SELECT  NVL(O.OPER_ALIQ_EXCECAO_FCP,0)
                 INTO V_ALIQ
              FROM OPERACAO_PRODUTO_CFO O
              WHERE     O.OPER_OPER_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_OPER_ID           = OPER_ID
                    AND O.OPER_PROD_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_PROD_ID           = PROD_ID;

            RETURN(V_ALIQ);
           EXCEPTION
             WHEN OTHERS THEN
                RETURN (0);
END;



FUNCTION  Obter_Aliq_Red_ST(OPER_ID IN REAL
                           ,PROD_ID IN REAL) RETURN VARCHAR2 AS
  V_ALIQ_ST_RED VARCHAR(1);
 BEGIN
     SELECT  NVL(O.oper_aliq_st_ret ,'N')
                 INTO V_ALIQ_ST_RED
              FROM OPERACAO_PRODUTO_CFO O
              WHERE     O.OPER_OPER_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_OPER_ID           = OPER_ID
                    AND O.OPER_PROD_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_PROD_ID           = PROD_ID;

    RETURN(V_ALIQ_ST_RED);
 EXCEPTION
   WHEN OTHERS THEN
   RETURN ('N');
END;




FUNCTION  Obter_Aliq_ICM_Diferenciada(OPER_ID IN REAL
                                     ,PROD_ID IN REAL
                                     ,TIPO IN REAL) RETURN Real AS
  V_ALIQ_ICM_DIF real;
  V_ESTADO real;
BEGIN
     SELECT   NVL(O.OPER_ALIQ_ICM_DIF,0)
             ,NVL(OPER_ALIQ_ICM_DIF_F_ESTADO,0)
                 INTO V_ALIQ_ICM_DIF,V_ESTADO
              FROM OPERACAO_PRODUTO_CFO O
              WHERE     O.OPER_OPER_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_OPER_ID           = OPER_ID
                    AND O.OPER_PROD_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_PROD_ID           = PROD_ID;
          IF TIPO = 1 THEN
              RETURN(V_ALIQ_ICM_DIF);
          ELSE
             RETURN(V_ESTADO);
         END IF ;

           EXCEPTION
             WHEN OTHERS THEN
                RETURN (0);
END;
FUNCTION  ObterCFO(V_OPER_ID IN REAL
                  ,V_PROD_ID IN REAL) RETURN VARCHAR2 AS
  V_CFO NUMBER(10);
   BEGIN
      V_CFO := NULL;
    FOR C IN (SELECT  O.OPER_CFO
              FROM OPERACAO_PRODUTO_CFO O
              WHERE     O.OPER_OPER_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_OPER_ID           = V_OPER_ID
                    AND O.OPER_PROD_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_PROD_ID           = V_PROD_ID
    )
     LOOP
        V_CFO := C.OPER_CFO;

    END LOOP;
       IF V_CFO IS NULL THEN
           SELECT  O.OPER_GEN_ID_COD_FISCAL_DE
                   INTO V_CFO
                FROM OPERACAO_FAT O
                WHERE     O.OPER_EMP_ID       = V_EMP_ATIVA
                      AND O.OPER_ID           = V_OPER_ID;
         END IF ;


            RETURN(V_CFO);
           EXCEPTION
             WHEN OTHERS THEN
                RETURN (NULL);
    END;

FUNCTION  AliqDIFAL RETURN VARCHAR2 AS
  vAliq NUMBER(10);
   BEGIN
    vAliq := 0;

        FOR C IN (SELECT  D.DIF_PERC
                  FROM DIF_ALIQ_INTER D
                  WHERE DIF_ANO = EXTRACT(YEAR FROM SYSDATE)

        )
         LOOP
            vAliq := C.DIF_PERC;

        END LOOP;

   RETURN(vAliq);
   EXCEPTION
   WHEN OTHERS THEN
  RETURN (0);
END;

FUNCTION  CalcIcmsStDIFAL(  vVLR_MERCADORIA IN REAL
                           ,vALIQ_INTERNA IN REAL
                           ,vALIQ_INTER_ESTADUAL IN REAL
                           ,vVLR_ICMS IN REAL
                           ,PERC_MVA IN REAL
                           ,PAUTA_ST IN REAL
                           ) RETURN REAL AS

  VLR_ICMS_ORIGEM NUMBER;
  VLR_ICMS_DIF NUMBER;
  BASE_ST NUMBER;


   BEGIN
   VLR_ICMS_ORIGEM := vVLR_MERCADORIA * vALIQ_INTER_ESTADUAL;
   IF PERC_MVA > 0 THEN
    BASE_ST := (((1 + PERC_MVA)* vVLR_MERCADORIA)- VLR_ICMS_ORIGEM)/(1 - vALIQ_INTERNA);
    V_VALOR_ICM_SUBST  := (BASE_ST * vALIQ_INTERNA) - VLR_ICMS_ORIGEM;

    ELSE
       IF PAUTA_ST > 0 THEN
         VLR_ICMS_DIF    := PAUTA_ST - VLR_ICMS_ORIGEM;
       ELSE
          VLR_ICMS_DIF    := vVLR_MERCADORIA - VLR_ICMS_ORIGEM;
       END IF;

       BASE_ST         := VLR_ICMS_DIF /(1 - vALIQ_INTERNA);
       BASE_ST         := BASE_ST * vALIQ_INTERNA;
       V_VALOR_ICM_SUBST          := BASE_ST - VLR_ICMS_ORIGEM;
    END IF;


   RETURN(BASE_ST);
   EXCEPTION
   WHEN OTHERS THEN
  RETURN (0);
END;




FUNCTION  ObterCst_IPI(V_OPER_ID IN REAL
                             ,V_PROD_ID IN REAL) RETURN VARCHAR2 AS
  V_CST_IPI VARCHAR(3);
   BEGIN
      V_CST_IPI := NULL;
    FOR C IN (SELECT  O.OPER_CST_IPI
              FROM OPERACAO_PRODUTO_CFO O
              WHERE     O.OPER_OPER_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_OPER_ID           = V_OPER_ID
                    AND O.OPER_PROD_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_PROD_ID           = V_PROD_ID
    )
     LOOP
        V_CST_IPI := C.OPER_CST_IPI;

    END LOOP;
       IF V_CST_IPI IS NULL THEN
           SELECT  O.OPER_CST_IPI
                   INTO V_CST_IPI
                FROM OPERACAO_FAT O
                WHERE     O.OPER_EMP_ID       = V_EMP_ATIVA
                      AND O.OPER_ID           = V_OPER_ID;
         END IF ;


            RETURN(V_CST_IPI);
           EXCEPTION
             WHEN OTHERS THEN
                RETURN (NULL);
    END;


  FUNCTION  ObterCst_PisCofins(OPER_ID IN REAL
                             ,PROD_ID IN REAL) RETURN VARCHAR2 AS
  V_CST VARCHAR(3);
   BEGIN
     SELECT  O.OPER_CST_PIS_COFINS
                 INTO V_CST
              FROM OPERACAO_PRODUTO_CFO O
              WHERE     O.OPER_OPER_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_OPER_ID           = OPER_ID
                    AND O.OPER_PROD_EMP_ID       = V_EMP_ATIVA
                    AND O.OPER_PROD_ID           = PROD_ID;

            RETURN(V_CST);
           EXCEPTION
             WHEN OTHERS THEN
                RETURN (NULL);
    END;

 FUNCTION  Obter_Serie_Devolucao RETURN VARCHAR2 AS
 SERIE VARCHAR2(6);
 BEGIN
      SELECT
        SUBSTR(NVL(GEN_DESCRICAO,'UN'),1,3)
      INTO
        SERIE
      FROM
        GENER
      WHERE
        GEN_TGEN_ID = 944 AND
        GEN_EMP_ID  = V_EMP_ATIVA AND
        GEN_ID      = 18;

   RETURN(SERIE);
   EXCEPTION
     WHEN OTHERS THEN
        RETURN ('');
 END;

  PROCEDURE Delete_Pedido_S IS
  BEGIN
     DELETE FROM PEDIDO_FAT_S WHERE
            (PEDF_PEDF_EMP_ID = V_EMP_ATIVA) AND
            (PEDF_PEDF_ID     = V_PFAT_PEDF_ID);
  END Delete_Pedido_S;
 PROCEDURE Converte_Vlr_Desc_Capa_Em_Per is
       V_DESC          REAL := 0;
       V_DESC_ORIGINAL REAL := 0;
      -- V_PERC          REAL := 0;
      -- V_PERC_ORIGEM   REAL := 0;
 Begin
    V_DESC          := RATIAR_VALOR(V_VLR_TOT_PRC_FAB , V_PFAT_PEDF_VLR_DESC, V_PFAT_P_TPRC_PRC_FAB * V_PFAT_P_PEDF_QTDE);
    V_DESC_ORIGINAL := RATIAR_VALOR(V_VLR_TOT_PRC_FINAL , V_PFAT_PEDF_VLR_DESC, V_PFAT_P_TPRC_PRC_FINAL * V_PFAT_P_PEDF_QTDE);
    V_PFAT_P_PEDF_PERC_DESC     := (V_DESC *100)/(V_PFAT_P_TPRC_PRC_FAB * V_PFAT_P_PEDF_QTDE);
    V_PEDF_PERC_DESC_ORIGINAL   := (V_DESC_ORIGINAL *100)/(V_PFAT_P_TPRC_PRC_FINAL * V_PFAT_P_PEDF_QTDE);

/* UPDATE PEDIDO_FAT_P P
 SET  P.PEDF_PERC_DESC          = ROUND(V_PFAT_P_PEDF_PERC_DESC,4)
     ,P.PEDF_PERC_DESC_ORIGINAL = ROUND(V_PEDF_PERC_DESC_ORIGINAL,4)
 WHERE
        PEDF_PEDF_EMP_ID = V_EMP_ATIVA
    AND PEDF_PEDF_ID     = V_PFAT_PEDF_ID
    AND PEDF_ID          = V_PFAT_P_PEDF_ID
    AND P.PEDF_PROD_ID   = V_PFAT_P_PEDF_PROD_ID;
 COMMIT;*/
 end Converte_Vlr_Desc_Capa_Em_Per;


  PROCEDURE Delete_Pedido_I IS
  BEGIN
     DELETE FROM PEDIDO_FAT_I WHERE
            (PEDF_PEDF_EMP_ID = V_EMP_ATIVA) AND
            (PEDF_PEDF_ID     = V_PFAT_PEDF_ID);
  END Delete_Pedido_I;

  FUNCTION Busca_Param_945_ID_131 RETURN INTEGER IS
  V_FLAG REAL;
  V_FLAG2 REAL;
  V_QTDE REAL;
  BEGIN
      SELECT NVL(GENER.GEN_NUMBER1,0)
            ,NVL(GENER.GEN_NUMBER2,0)
            ,NVL(GENER.GEN_NUMBER3,0)
         INTO V_FLAG
             ,V_FLAG2
             ,V_DESC_BASE_IPI
             FROM GENER
                WHERE GEN_TGEN_ID = 945 AND
                      GEN_EMP_ID  = V_EMP_ATIVA AND
                      GEN_ID      = 131;
 -- Específico para o estado do PIAUÍ pedidos de pessoa física maior que X quantidades não agrega IPI na base
  IF ((V_FLAG2 > 0) AND (V_FLAG = 0)) THEN
    select sum(fp.pedf_qtde)
           INTO V_QTDE
    from pedido_fat_p fp
    where fp.pedf_pedf_emp_id = V_EMP_ATIVA
      and fp.pedf_pedf_id = V_PFAT_PEDF_ID;
    IF (V_QTDE > V_FLAG2) THEN
       V_FLAG := 1;
    END IF;
  END IF;

     RETURN (V_FLAG);
  EXCEPTION
     WHEN OTHERS THEN
          RETURN (0);
  END Busca_Param_945_ID_131;



PROCEDURE Busca_prod_lei_13097_item (vProd In Integer
                                    ,vTpQualificacao In Integer
                                    ,vPrecoPVV in Real
                                    ,vExecPisCofins in real)--executar somente a busca das aliquotas do piscofins , para ponto de corte nao PVV
                                    IS

  BEGIN
   V_VLR_IPI_IVA_13097 := NULL;
   V_PLI_ALIQ_PIS      := NULL;
   V_PLI_ALIQ_COFINS   := NULL;
   V_PLI_VLR_PIS_MIN   := NULL;
   V_PLI_VLR_COFINS_MIN := NULL;
   V_DTA_ORIGEM_DEVOL   := NULL;

  BEGIN
    SELECT
         TRUNC(LIQUIDACAO.LIQU_DTA_EMIS)
    INTO
         V_DTA_ORIGEM_DEVOL
    FROM
         PEDIDO_FAT
        ,PEDIDO_FAT PED_DEVOL_ORIGEM
        ,LIQUIDACAO
    WHERE
         PEDIDO_FAT.PEDF_EMP_ID              = PED_DEVOL_ORIGEM.PEDF_EMP_ID(+)
    AND  PEDIDO_FAT.PEDF_ID_DEVOL            = PED_DEVOL_ORIGEM.PEDF_ID(+)
    --
    AND  PED_DEVOL_ORIGEM.PEDF_LIQU_EMP_ID   = LIQUIDACAO.LIQU_EMP_ID(+)
    AND  PED_DEVOL_ORIGEM.PEDF_LIQU_ID       = LIQUIDACAO.LIQU_ID(+)
    --
    AND  PEDIDO_FAT.PEDF_EMP_ID              = V_EMP_ATIVA
    AND  PEDIDO_FAT.PEDF_ID                  = V_PFAT_PEDF_ID;

    EXCEPTION
        WHEN OTHERS THEN
          V_DTA_ORIGEM_DEVOL := TRUNC(SYSDATE);
    END;

    IF V_DTA_ORIGEM_DEVOL IS NULL THEN
       V_DTA_ORIGEM_DEVOL := TRUNC(SYSDATE);
    END IF;


   FOR DADOS IN (SELECT  PLI_ALIQ_IPI,
                         PLI_ALIQ_PIS,
                         PLI_ALIQ_COFINS,
                         PLI_VLR_PVV_MIN,
                         PLI_VLR_IPI_MIN,
                         PLI_VLR_PIS_MIN,
                         PLI_VLR_COFINS_MIN,
                         PLI_VLR_PIS_IMPORT,
                         PLI_VLR_COFINS_IMPORT

                      FROM PARAM_LEI_13097_ITEM I
                      WHERE
                           (PLI_EMP_ID,
                            PLI_PAR_EMP_ID,
                            PLI_PAR_TIPO_QUALIFICACAO,
                            PLI_PAR_DATA_VIGENCIA,
                            PLI_PROD_EMP_ID,
                            PLI_PROD_ID) IN(SELECT PLI_EMP_ID,
                                                   PLI_PAR_EMP_ID,
                                                   PLI_PAR_TIPO_QUALIFICACAO,
                                                   MAX(PLI_PAR_DATA_VIGENCIA),
                                                   PLI_PROD_EMP_ID,
                                                   PLI_PROD_ID
                                                  FROM PARAM_LEI_13097_ITEM I
                                                  WHERE TRUNC(PLI_PAR_DATA_VIGENCIA) <= V_DTA_ORIGEM_DEVOL
                                                      AND I.PLI_EMP_ID                = V_EMP_ATIVA
                                                      AND I.PLI_PROD_ID               = vProd
                                                      AND PLI_PAR_TIPO_QUALIFICACAO   = vTpQualificacao
                                                  GROUP BY
                                                     PLI_EMP_ID,
                                                     PLI_PAR_EMP_ID,
                                                     PLI_PROD_EMP_ID,
                                                     PLI_PROD_ID,
                                                     PLI_PAR_TIPO_QUALIFICACAO))
     LOOP

       V_ALIQ_IPI_REGRA_PRC := DADOS.PLI_ALIQ_IPI;
       V_PAUTA_IPI_REGRA_PRC:= DADOS.PLI_VLR_IPI_MIN;
       IF V_USAR_REGRA_COM_PVV = 1 THEN --USA O PVV COMO PONTO DE CORTE
        IF vPrecoPVV - DADOS.PLI_VLR_IPI_MIN  >= DADOS.PLI_VLR_PVV_MIN  THEN --por aliquota
          V_PFAT_P_PROF_VLR_IPI  := 0;
          V_PFAT_P_PROF_ALIQ_IPI := DADOS.PLI_ALIQ_IPI;
         IF V_CST_PIS_COFINS in ('01','02','03') THEN
          V_CST_PIS_COFINS       := '02';
          V_PLI_ALIQ_PIS         := DADOS.PLI_ALIQ_PIS;
          V_PLI_ALIQ_COFINS      := DADOS.PLI_ALIQ_COFINS;
          V_PLI_VLR_PIS_MIN      := 0;
          V_PLI_VLR_COFINS_MIN   := 0;
         END IF;
      ELSE -- por pauta

         V_PFAT_P_PROF_VLR_IPI  := DADOS.PLI_VLR_IPI_MIN; --Se ao cadastro de parametro Lei 13097 estiver cadastrado IPI por produto usar este
       --  V_PFAT_P_PROF_VLR_IPI  := ((DADOS.PLI_VLR_IPI_MIN * (V_PFAT_P_PROC_LITRAGEM * V_FATOR_CX_PRODUTO)) / 1000); --Se estiver cadastrado por litro usar este
         V_PFAT_P_PROF_ALIQ_IPI := 0;
        IF V_CST_PIS_COFINS in ('01','02','03') THEN
          V_CST_PIS_COFINS       := '03';
          V_PLI_VLR_PIS_MIN      := DADOS.PLI_VLR_PIS_MIN;
          V_PLI_VLR_COFINS_MIN   := DADOS.PLI_VLR_COFINS_MIN;
          V_PLI_ALIQ_PIS         := 0;
          V_PLI_ALIQ_COFINS      := 0;
        END IF;
      END IF;
      ELSE
             /*IPI*/
           if (vExecPisCofins = 0) then
            IF (vPrecoPVV * (DADOS.PLI_ALIQ_IPI/100) >= ((DADOS.PLI_VLR_IPI_MIN * (V_PFAT_P_PROC_LITRAGEM * V_FATOR_CX_PRODUTO)) / 1000))
              THEN --por aliquota IPI
                  V_PFAT_P_PROF_VLR_IPI  := 0;
                  V_PFAT_P_PROF_ALIQ_IPI := DADOS.PLI_ALIQ_IPI;-- * 100;
                 ELSE -- por pauta IPI
                -- V_PFAT_P_PROF_VLR_IPI  := DADOS.PLI_VLR_IPI_MIN;(V_PFAT_P_PEDF_QTDE * (V_PFAT_P_PROC_LITRAGEM  / 1000) * V_FATOR_CX_PRODUTO);
                 V_PFAT_P_PROF_VLR_IPI  := ((DADOS.PLI_VLR_IPI_MIN * (V_PFAT_P_PROC_LITRAGEM * V_FATOR_CX_PRODUTO)) / 1000);
                 V_PFAT_P_PROF_ALIQ_IPI := 0;
              END IF;
            END IF;

              IF V_CST_PIS_COFINS in ('01','02','03') THEN
                  /*PIS/COFINS*/
                  IF vPrecoPVV * (DADOS.PLI_ALIQ_PIS/100) >= ((DADOS.PLI_VLR_PIS_MIN * (V_PFAT_P_PROC_LITRAGEM * V_FATOR_CX_PRODUTO)) / 1000)
                  THEN --por aliquota
                    V_CST_PIS_COFINS       := '02';
                    V_PLI_ALIQ_PIS         := DADOS.PLI_ALIQ_PIS;
                    V_PLI_VLR_PIS_MIN      := 0;
                    V_PLI_ALIQ_COFINS      := DADOS.PLI_ALIQ_COFINS;
                    V_PLI_VLR_COFINS_MIN   := 0;
                   ELSE -- por pauta
                     V_CST_PIS_COFINS       := '03';
                     V_PLI_VLR_PIS_MIN      := DADOS.PLI_VLR_PIS_MIN;
                     V_PLI_ALIQ_PIS         := 0;
                     V_PLI_VLR_COFINS_MIN   := DADOS.PLI_VLR_COFINS_MIN;
                     V_PLI_ALIQ_COFINS      := 0;
                  END IF;


             END IF;
        END IF;

      V_PASSO_PELA_REGRA_13097 := True;
    END LOOP;

  END Busca_prod_lei_13097_item;



FUNCTION Busca_Gener ( TGENER  In INTEGER
                      ,GEN_ID In INTEGER
                      ,NUMERICO In INTEGER) RETURN INTEGER IS
  V_RESULT REAL;
  vSQL     LONG;
  type cDados is REF CURSOR;
       cCursorDados  cDados;
  BEGIN
     vSQL := 'SELECT NVL(GENER.GEN_NUMBER'||NUMERICO||',0)'||
                'FROM GENER' ||
                ' WHERE GEN_TGEN_ID = '|| TGENER||
                ' AND GEN_EMP_ID = '||V_EMP_ATIVA||
                ' AND GEN_ID = '||GEN_ID;
         open cCursorDados for vSQL;
         fetch cCursorDados into
               V_RESULT;
     RETURN (nvl(V_RESULT,0));
  EXCEPTION
     WHEN OTHERS THEN
          RETURN (0);
  END Busca_Gener;


  FUNCTION Busca_Param_941 RETURN BOOLEAN IS
  V_FLAG REAL;
  BEGIN
      SELECT MAX(GEN_ID) INTO V_FLAG FROM GENER
                WHERE GEN_TGEN_ID = 941 AND
                      GEN_EMP_ID  = V_EMP_ATIVA AND
                      GEN_ID IN(9,10);
     RETURN (TRUE);
  EXCEPTION
     WHEN OTHERS THEN
          RETURN (FALSE);
  END Busca_Param_941;


  FUNCTION Usa_Desconto_Atacado RETURN INTEGER  IS
  V_FLAG INTEGER;
  BEGIN
      SELECT GEN_NUMBER1 INTO V_FLAG
      FROM GENER
      WHERE GEN_TGEN_ID = 945
        AND GEN_EMP_ID  = V_EMP_ATIVA
        AND GEN_ID      = 38;

      IF (V_FLAG = 1) THEN
        RETURN(1);
      ELSIF (V_FLAG = 2) THEN
        RETURN(0);
      ELSE
        RETURN(0);
      END IF;
  EXCEPTION
     WHEN OTHERS THEN
          RETURN (0);
  END Usa_Desconto_Atacado;


  FUNCTION BUSCAR_DESCONTO_ATACADO(p_TipoLiquidacao IN REAL,
                                   p_RotaPedido     IN REAL,
                                   p_Cond_Vcto      IN REAL,
                                   p_Cliente        IN REAL) RETURN REAL IS
    V_DESCONTO_ROTA      REAL;
    V_DESCONTO_COND_VCTO REAL;
    V_DESCONTO_CLIENTE   REAL;
    V_DESCONTO_ACUMULADO REAL;
  BEGIN
    --V_DESCONTO_ACUMULADO := 0;
    V_DESCONTO_ROTA     := 0;
    V_DESCONTO_COND_VCTO := 0;
    V_DESCONTO_CLIENTE   := 0;

    IF (p_TipoLiquidacao = 2) THEN
      SELECT NVL(GEN_NUMBER2, 0) INTO V_DESCONTO_ROTA
      FROM GENER
      WHERE GEN_TGEN_ID = 920
        AND GEN_EMP_ID  = V_EMP_ATIVA
        AND GEN_ID      = p_RotaPedido;
    END IF;

    SELECT NVL(CVTO_DESCONTO,0) INTO V_DESCONTO_COND_VCTO
    FROM COND_VCTO
    WHERE CVTO_EMP_ID = V_EMP_ATIVA
      AND CVTO_ID     = p_Cond_Vcto;

    SELECT NVL(CLI_DESC_ATACADO,0) INTO V_DESCONTO_CLIENTE
    FROM CLIENTE
    WHERE CLI_EMP_ID = V_EMP_ATIVA
      AND CLI_ID     = p_Cliente;

    V_DESCONTO_ACUMULADO := V_DESCONTO_ROTA + V_DESCONTO_COND_VCTO + V_DESCONTO_CLIENTE;
    RETURN(V_DESCONTO_ACUMULADO);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN(0);
  END BUSCAR_DESCONTO_ATACADO;


   PROCEDURE Busca_Param_Serie(Tipo In Integer) IS
  BEGIN
    IF V_EMP_UTILIZA_IE_PEDIDO = 'N' THEN             --- Tratado aqui, quando naum usa, default o que já estava, no else tratamento para pegar a serie da inscrição tabela EMPRESA_IE
       IF (Tipo = 1) THEN
          SELECT
               SUBSTR(NVL(GEN_DESCRICAO,'UN'),1,3)
              ,NVL(GEN_TEXT1,'000')
          INTO
               V_PFAT_SERIE_NF,
               V_SERIE_NF_SCAN
          FROM
               GENER
          WHERE
               GEN_TGEN_ID = 944
          AND  GEN_EMP_ID  = V_EMP_ATIVA
          AND  GEN_ID      = 17;
       ELSIF (Tipo = 2) THEN
             SELECT
                  SUBSTR(NVL(GEN_DESCRICAO,'UN'),1,3)
                 ,NVL(GEN_TEXT1,'000')
             INTO
                  V_PFAT_SERIE_NF
                 ,V_SERIE_NF_SCAN
             FROM
                  GENER
             WHERE
                  GEN_TGEN_ID = 944
             AND  GEN_EMP_ID  = V_EMP_ATIVA
             AND  GEN_ID      = 18;
       END IF;
    ELSE
       IF (Tipo = 1) THEN
          SELECT
               EMPRESA_IE.EMI_SERIE_NF_NORMAL
              ,'000'
          INTO
               V_PFAT_SERIE_NF
              ,V_SERIE_NF_SCAN
          FROM
               EMPRESA_IE
          WHERE
               EMPRESA_IE.EMI_EMP_ID            = V_EMP_ATIVA
          AND  EMPRESA_IE.EMI_INSCR_ESTADUAL    = V_PEDF_INSCRICAO_ESTADUAL;
       ELSIF (Tipo = 2) THEN
          SELECT
               EMPRESA_IE.EMI_SERIE_NF_DEVOLUCAO
              ,'000'
          INTO
               V_PFAT_SERIE_NF
              ,V_SERIE_NF_SCAN
          FROM
               EMPRESA_IE
          WHERE
               EMPRESA_IE.EMI_EMP_ID            = V_EMP_ATIVA
          AND  EMPRESA_IE.EMI_INSCR_ESTADUAL    = V_PEDF_INSCRICAO_ESTADUAL;
       END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      if (Tipo = 1) then
        V_PFAT_SERIE_NF := 'UN';
      ElsIf (Tipo = 2) then
        Busca_Param_Serie(1);
      End If;
  END Busca_Param_Serie;


  FUNCTION Obter_Valor_ICM_RED RETURN REAL AS
    V_CALCULO               REAL := 0;
    V_DESP_ACESSORIAS_ITEM  REAL := 0;
    V_VALOR_IPI             REAL := 0;
    V_VLR_DESP_INI          REAL := 0;



  BEGIN
    /*FRETE_GENER*/
    V_BASE_RED_ICM_PARA_ST :=0;
    V_BASE_RED_COM_FRETE := 0;
    V_VLR_DESP_INI   := V_PFAT_PEDF_VLR_DESP;
    IF V_PEDF_FLAG_DESP_ICMS = 1 THEN --SOMENTE PARA EFEITO DE CALCULO DO ICM
       V_PFAT_PEDF_VLR_DESP := 0;
     END IF;
    V_DESP_ACESSORIAS_ITEM := RATIAR_VALOR(V_VLR_TOT_MERCADORIA  - NVL(V_TOT_MERC_SELO,0), (V_PFAT_PEDF_VLR_DESP + V_PFAT_PEDF_VLR_SEG), V_VALOR_MERCADORIA);
    V_PFAT_PEDF_VLR_DESP := V_VLR_DESP_INI; --VOLTA VALOR INCIAL
    IF V_ALIQ_ICM_REDUCAO = 0 THEN
       RETURN (0);
    ELSE

       IF (V_PFAT_OPER_TIPO_ICM = 5) OR --AGREGA IPI PELA OPERACAO
          (V_TIPO_PESSOA = 1 AND V_AGREGA_IPI_FIS = 0) OR -- PESSOA FISICA
         ( (V_TIPO_PESSOA = 2) AND (NVL(V_CLI_CONTRIB,'S') = 'N') ) THEN -- JURIDICA NAO CONTRIBUINTE

         V_VALOR_IPI := CALCULO_PEDIDO_FAT$PK.OBTER_VALOR_IPI;
-- AQUI
      ELSE IF (V_PFAT_OPER_TIPO_IPI = 1 AND NOT  V_PFAT_P_PROF_VLR_IPI > 0 AND V_PFAT_P_PROF_ALIQ_IPI > 0 AND V_OPER_PRC_FINAL = 'S') THEN
               V_VALOR_IPI := (CALCULO_PEDIDO_FAT$PK.OBTER_VALOR_IPI) * -1;
           END IF;
     END IF;
       IF V_PRIMEIRO_NR = 1 THEN
           IF (V_OPER_TIPO_REDUCAO = 2) AND (V_UF_EMPRESA = V_UF_CLIENTE) THEN --REDUZ O VALOR DO ICM AO INVES DA BASE DENTRO DO ESTADO
             V_CALCULO := ((V_VALOR_MERCADORIA  - V_DESCONTO_NOR_ITEM + V_VALOR_IPI) + V_PRECO_FRETE + V_DESP_ACESSORIAS_ITEM );
             RETURN (V_CALCULO * V_ALIQ_ICM / 100) - ((V_CALCULO * V_ALIQ_ICM / 100) * V_ALIQ_ICM_REDUCAO / 100);
           ELSE
              if V_SOMA_FRETE_RED = 1 then
                  V_CALCULO := ((((V_VALOR_MERCADORIA  - V_DESCONTO_NOR_ITEM + V_VALOR_IPI + V_PRECO_FRETE + V_DESP_ACESSORIAS_ITEM )* V_ALIQ_ICM_REDUCAO ) / 100) );
                  V_BASE_RED_COM_FRETE := V_CALCULO;
                else
                  V_CALCULO := ((((V_VALOR_MERCADORIA  - V_DESCONTO_NOR_ITEM + V_VALOR_IPI)* V_ALIQ_ICM_REDUCAO ) / 100) + V_PRECO_FRETE + V_DESP_ACESSORIAS_ITEM );
                end if;
                V_BASE_RED_ICM_PARA_ST :=V_CALCULO;
             RETURN (V_CALCULO * V_ALIQ_ICM / 100);
           END IF;
       ELSE

         IF (V_OPER_TIPO_REDUCAO = 2) AND (V_UF_EMPRESA = V_UF_CLIENTE) THEN --REDUZ O VALOR DO ICM AO INVES DA BASE DENTRO DO ESTADO
           V_CALCULO := ((V_VALOR_MERCADORIA  - V_DESCONTO_NOR_ITEM + V_VALOR_IPI) + V_PRECO_FRETE +  V_DESP_ACESSORIAS_ITEM );
           RETURN (V_CALCULO * V_ALIQ_ICM / 100) - ((V_CALCULO * V_ALIQ_ICM / 100) * V_ALIQ_ICM_REDUCAO / 100);
         ELSE
            if V_SOMA_FRETE_RED = 1 then
                  V_CALCULO := ((((V_VALOR_MERCADORIA  - V_DESCONTO_NOR_ITEM + V_VALOR_IPI + V_PRECO_FRETE + V_DESP_ACESSORIAS_ITEM )* V_ALIQ_ICM_REDUCAO ) / 100) );
                  V_BASE_RED_COM_FRETE := V_CALCULO;
                else
                  V_CALCULO := ((((V_VALOR_MERCADORIA  - V_DESCONTO_NOR_ITEM + V_VALOR_IPI)* V_ALIQ_ICM_REDUCAO ) / 100) + V_PRECO_FRETE + V_DESP_ACESSORIAS_ITEM );
                end if;
                V_BASE_RED_ICM_PARA_ST := V_CALCULO;
           RETURN (V_CALCULO * V_ALIQ_ICM / 100);
         END IF;

       END IF;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN (-1);
  END Obter_Valor_ICM_RED;


  FUNCTION Obter_Impostos RETURN REAL AS
     V_IMPOSTOS REAL := 0;
     V_NR_CONTRATO REAL := 0;

  BEGIN
       SELECT
             NVL(PEDF_PCON_ID,0)
       INTO  V_NR_CONTRATO
       FROM
             PEDIDO_FAT
       WHERE
             PEDF_EMP_ID = V_EMP_ATIVA
       AND   PEDF_ID   BETWEEN V_PEDID_INI AND V_PEDID_FIN;

       IF V_NR_CONTRATO > 0 THEN
          SELECT SUM(NVL(FAT_P.PEDF_VLR_INSS,0) + NVL(FAT_P.PEDF_VLR_IRRF,0)
                     + (DECODE(SERV.PARA_TP_ISSQN,'S',NVL(FAT_P.PEDF_VLR_ISS,0),'N',0,NULL,0))
                      ) INTO V_IMPOSTOS
          FROM PEDIDO_FAT             FAT
              ,PEDIDO_FAT_P           FAT_P
              ,OPERACAO_FAT           OPER
              ,PRODUTO                PROD
              ,PARAM_CONTRATO_SERVICO SERV
          WHERE
              FAT.PEDF_OPER_EMP_ID           = OPER.OPER_EMP_ID
          AND FAT.PEDF_OPER_ID               = OPER.OPER_ID
          AND FAT_P.PEDF_PEDF_EMP_ID         = FAT.PEDF_EMP_ID
          AND FAT_P.PEDF_PEDF_ID             = FAT.PEDF_ID
          AND FAT_P.PEDF_PROD_EMP_ID         = PROD.PROD_EMP_ID
          AND FAT_P.PEDF_PROD_ID             = PROD.PROD_ID
          AND SERV.PARA_PROD_EMP_ID (+)      = PROD.PROD_EMP_ID
          AND SERV.PARA_PROD_ID     (+)      = PROD.PROD_ID
          AND SERV.PARA_PARAMCTO_PCON_EMP_ID = FAT.PEDF_PCON_EMP_ID
          AND SERV.PARA_PARAMCTO_PCON_ID     = FAT.PEDF_PCON_ID
          AND FAT.PEDF_EMP_ID                = V_EMP_ATIVA
          AND FAT.PEDF_ID  BETWEEN V_PEDID_INI AND V_PEDID_FIN;
     ELSE
          SELECT SUM(NVL(FAT_P.PEDF_VLR_INSS,0) + NVL(FAT_P.PEDF_VLR_IRRF,0)
                     + NVL(FAT_P.PEDF_VLR_IRRF,0)
                     + (DECODE(OPER.OPER_ISSQN,'S',NVL(FAT_P.PEDF_VLR_ISS,0),'N',0,NULL,0))
                      ) INTO V_IMPOSTOS
          FROM PEDIDO_FAT             FAT
              ,PEDIDO_FAT_P           FAT_P
              ,OPERACAO_FAT           OPER
              ,PRODUTO                PROD
          WHERE
              FAT.PEDF_OPER_EMP_ID           = OPER.OPER_EMP_ID
          AND FAT.PEDF_OPER_ID               = OPER.OPER_ID
          AND FAT_P.PEDF_PEDF_EMP_ID         = FAT.PEDF_EMP_ID
          AND FAT_P.PEDF_PEDF_ID             = FAT.PEDF_ID
          AND FAT_P.PEDF_PROD_EMP_ID         = PROD.PROD_EMP_ID
          AND FAT_P.PEDF_PROD_ID             = PROD.PROD_ID
          AND FAT.PEDF_EMP_ID                = V_EMP_ATIVA
          AND FAT.PEDF_ID  BETWEEN V_PEDID_INI AND V_PEDID_FIN;
     END IF;

     IF V_IMPOSTOS <> 0 THEN
       RETURN(V_IMPOSTOS);
     ELSE
       RETURN(0);
     END IF;

  EXCEPTION
    WHEN OTHERS THEN
       RETURN (0);
  END Obter_Impostos;

  FUNCTION Valores_a_Deduzir RETURN REAL AS
     VALORES_DEDUZIR REAL := 0;
  BEGIN
     SELECT
          COUNT(*)  INTO VALORES_DEDUZIR
     FROM
          PEDIDO_FAT_P  FAT_P
         ,PEDIDO_FAT   FAT
     WHERE
         FAT.PEDF_EMP_ID                                      = FAT_P.PEDF_PEDF_EMP_ID
         AND FAT.PEDF_ID                                      = FAT_P.PEDF_PEDF_ID
         AND FAT.PEDF_EMP_ID                                  = V_EMP_ATIVA
         AND DECODE(FAT_P.PEDF_VALORIZA,NULL,'S','S','S','N') <> 'N'
         AND FAT.PEDF_ID BETWEEN V_PEDID_INI AND V_PEDID_FIN;

     IF VALORES_DEDUZIR > 0 THEN
        SELECT
             SUM(ROUND(FAT_P.PEDF_QTDE * FAT_P.PEDF_VLR_UNIT,2)) INTO VALORES_DEDUZIR
        FROM
             PEDIDO_FAT_P  FAT_P
            ,PEDIDO_FAT   FAT
         WHERE
             FAT.PEDF_EMP_ID         = FAT_P.PEDF_PEDF_EMP_ID
         AND FAT.PEDF_ID             = FAT_P.PEDF_PEDF_ID
         AND FAT.PEDF_EMP_ID         = V_EMP_ATIVA
         AND FAT_P.PEDF_VALORIZA     = 'N'
         AND FAT.PEDF_ID BETWEEN V_PEDID_INI AND V_PEDID_FIN;
     END IF;
  IF VALORES_DEDUZIR <> 0 THEN
     RETURN(VALORES_DEDUZIR);
  ELSE
     RETURN(0);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
       RETURN (0);
  END Valores_a_Deduzir;

  FUNCTION Obter_Aliq_ICM_SUBST RETURN REAL AS
  V_ESTADO  REAL := 0;
  V_ALIQ    REAL := -1;
  BEGIN
    SELECT GENA_GEN_ID_PROPRIETARIO_DE INTO V_ESTADO
    FROM   GENER_A
    WHERE  GENA_GEN_TGEN_ID = 5001
       AND GENA_GEN_EMP_ID  = 0
       AND GENA_GEN_ID      = V_PFAT_GEN_ID_CIDADE_DE;

    SELECT PROD_ALIQ_SUBST INTO V_ALIQ
    FROM   PRODUTO_UF
    WHERE  PROD_PROD_EMP_ID = V_EMP_ATIVA
       AND PROD_PROD_ID     = V_PFAT_P_PEDF_PROD_ID
       AND PROD_GEN_ID      = V_ESTADO
       AND PROD_GEN_TGEN_ID = 5006
       AND PROD_GEN_EMP_ID  = 0;

    RETURN (V_ALIQ);
  EXCEPTION
     WHEN OTHERS THEN
        RETURN (-1);
  END Obter_Aliq_ICM_SUBST;


  FUNCTION Obter_Aliq_ICM_Red RETURN REAL AS
   V_GEN_TIPO     REAL := 0;
   V_GEN_ALIQ     REAL := 0;
   V_NCONTR_PF    REAL := 0;
   V_NCONTR_PJ    REAL := 0;

  BEGIN
      IF V_USAR_REGRA_PAR_ALIQUOTA =  1 THEN
         RETURN(NVL(V_PAR_VDA_ALIQ_RED_ICMS,0));
      END IF;

   /*OBTER SE APLICA REGRA DE CALC. ALIQ. POR TIPO DE PESSOA*/
     SELECT MAX(GENER_945.CODIGO)
           ,MAX(GENER_945.COD_ALIQ)
           ,MAX(GENER_945.V_NCONTR_PJ)
           ,MAX(GENER_945.V_NCONTR_PF)
     INTO
        V_GEN_TIPO ,V_GEN_ALIQ,V_NCONTR_PJ,V_NCONTR_PF
     FROM
        (SELECT
             NVL(GEN_NUMBER1,0) CODIGO
            ,NVL(GEN_NUMBER2,0) COD_ALIQ
            ,NVL(GEN_NUMBER5,0) V_NCONTR_PJ
            ,NVL(GEN_NUMBER6,0) V_NCONTR_PF
         FROM
            GENER
         WHERE  GEN_TGEN_ID = 945
          AND GEN_EMP_ID  = V_EMP_ATIVA
            AND GEN_ID      = 44
        UNION
        SELECT
              0 CODIGO
             ,0 COD_ALIQ
             ,0
             ,0
        FROM
        DUAL) GENER_945;


    /* Se Tipo de Pessoa Fisica n?o deve haver reduc?o */
     IF (V_TIPO_PESSOA = 1) AND ((V_GEN_TIPO = 1) and (NVL(V_PROC_CESTA_BASICA,'N') = 'N'))
        OR (V_PFAT_PEDF_TIPO_PED = 8)
        OR ((V_NCONTR_PF = 1) AND (V_CLI_CONTRIB = 'N'))
        THEN
          RETURN (0);
     END IF ;
     IF (V_TIPO_PESSOA = 2) AND ( (V_NCONTR_PJ = 1) AND
                                  (V_CLI_CONTRIB = 'N') AND
                                  (NVL(V_PROC_CESTA_BASICA,'N') = 'N')
                                )
      THEN
          RETURN (0);
     END IF ;




     IF (V_PFAT_OPER_ALIQ_ICM_PROD = 'S') THEN
       /*Se S entao devo obter a aliquota do Produto*/
     --  RETURN (V_PFAT_P_PROF_ALIQ_ICM_RED);
       IF (V_CLI_SIMPLES_NACIONAL = 'N') THEN
         RETURN (V_PFAT_P_PROF_ALIQ_ICM_RED);
       ELSIF (V_PROF_REDUZIR_BC_SIMPLES_NAC = 'S') THEN
         RETURN (V_PFAT_P_PROF_ALIQ_ICM_RED);
       ELSE
         RETURN(0);
       END IF;
     ELSE
       /*Se N entao devo obter a aliquota da Operacao*/
       RETURN (V_PFAT_OPER_ALIQ_RED_BC_ICM);
     END IF;
       IF (V_TIPO_PESSOA = 1) AND (V_GEN_TIPO = 1) THEN
            IF (V_GEN_ALIQ = 1) THEN

                 IF V_PFAT_OPER_TIPO_ICM in (1,5) THEN
                        -- RETURN (V_PFAT_P_PROF_ALIQ_ICM_RED);
                           IF (V_CLI_SIMPLES_NACIONAL = 'N') THEN
                             RETURN (V_PFAT_P_PROF_ALIQ_ICM_RED);
                           ELSIF (V_PROF_REDUZIR_BC_SIMPLES_NAC = 'S') THEN
                             RETURN (V_PFAT_P_PROF_ALIQ_ICM_RED);
                           ELSE
                             RETURN(0);
                           END IF;
                        ELSE
                        --se operacao não tributada, retorna aliquota zero para pessoa fisica.
                            RETURN (0);
                       END IF ;
                     ELSE
                       RETURN (V_PFAT_OPER_ALIQ_RED_BC_ICM);
                    END IF ;

       ELSIF (V_PFAT_OPER_ALIQ_ICM_PROD = 'S') THEN
        /*Se S entao devo obter a aliquota do Produto*/
       -- RETURN (V_PFAT_P_PROF_ALIQ_ICM_RED);
         IF (V_CLI_SIMPLES_NACIONAL = 'N') THEN
           RETURN (V_PFAT_P_PROF_ALIQ_ICM_RED);
         ELSIF (V_PROF_REDUZIR_BC_SIMPLES_NAC = 'S') THEN
           RETURN (V_PFAT_P_PROF_ALIQ_ICM_RED);
         ELSE
           RETURN(0);
         END IF;
           ELSE
     /*Se N entao devo obter a aliquota da Operacao*/
           RETURN (V_PFAT_OPER_ALIQ_RED_BC_ICM);
     END IF;
  EXCEPTION
     WHEN OTHERS THEN
        RETURN (-1);
  END Obter_Aliq_ICM_Red;

  FUNCTION Obter_Aliq_ICM RETURN REAL AS
  V_GEN_TIPO   REAL := 0;
  V_GEN_ALIQ   REAL := 0;
  V_GEN_CESTA_BASICA REAL := 0;
  BEGIN

     IF V_USAR_REGRA_PAR_ALIQUOTA =  1 THEN
        RETURN (NVL(V_PAR_VDA_ALIQ_ICMS,-1))  ;
     END IF;

     /* Parâmetros via genérica para regras de ICMS por Tipo de Pessoa */
     SELECT
         NVL(GEN_NUMBER1,0) CODIGO
        ,NVL(GEN_NUMBER2,0) COD_ALIQ
        ,NVL(GEN_NUMBER4,0) COD_CESTA_BASICA
        ,NVL(GEN_NUMBER5,0)

     INTO
         V_GEN_TIPO
        ,V_GEN_ALIQ
        ,V_GEN_CESTA_BASICA
        ,V_VLR_ICMS_PARA_ST
     FROM
        GENER
     WHERE  GEN_TGEN_ID = 945
      AND GEN_EMP_ID    = V_EMP_ATIVA
        AND GEN_ID      = 44;




   IF (V_OPER_ALIQ_ICM_DIF_F_ESTADO > 0)  THEN
     RETURN (V_OPER_ALIQ_ICM_DIF_F_ESTADO);
   END IF ;


     IF (V_GEN_CESTA_BASICA = 1) AND /*regra de produto isento p/ consumidor final*/
        (V_PROC_CESTA_BASICA = 'S') AND /*produto da cesta basica*/
        ((V_TIPO_PESSOA = 1) OR ((V_TIPO_PESSOA = 2) AND (V_CLI_CONTRIB = 'N'))) AND /*consumidor final*/
        (V_UF_EMPRESA = V_UF_CLIENTE) THEN /*operacao interna*/
       RETURN (0); /*ISENTO, aliq ICM = 0 */

     ELSIF ((V_TIPO_PESSOA = 1) OR ((V_TIPO_PESSOA = 2) AND (V_CLI_CONTRIB = 'N'))) AND /*consumidor final*/
           (V_UF_EMPRESA <> V_UF_CLIENTE) AND (V_GEN_TIPO = 1) THEN /*operacao interESTADUAL*/

         IF V_PFAT_OPER_TIPO_ICM in (1,5) THEN
           RETURN (V_PFAT_P_PROF_ALIQ_ICM);
         ELSE --se operacao não tributada, retorna aliquota zero para pessoa fisica.
           RETURN (0);
         END IF ;

     /* Se for Tipo de Pessoa Fisica ou Não Contribuinte ent?o deve pegar da Operac?o FAT */
     ELSIF ((V_TIPO_PESSOA = 1) or ((V_TIPO_PESSOA = 2) AND (V_CLI_CONTRIB = 'N'))) AND (V_GEN_TIPO = 1) THEN

       IF (V_GEN_ALIQ = 1) THEN

         IF V_PFAT_OPER_TIPO_ICM in (1,5) THEN
           RETURN (V_PFAT_P_PROF_ALIQ_ICM);
         ELSE --se operacao não tributada, retorna aliquota zero para pessoa fisica.
           RETURN (0);
         END IF ;

       ELSE
         RETURN (V_PFAT_OPER_ALIQ_ICM_FABR);
       END IF ;


     ELSIF (V_PFAT_OPER_ALIQ_ICM_PROD = 'S') THEN /*obter a aliquota do Produto*/
           RETURN (V_PFAT_P_PROF_ALIQ_ICM);

      ELSE /*obter a aliquota da Operacao*/
           IF (V_PFAT_P_PROF_ALIQ_ICM = 0) AND  (V_UF_EMPRESA <> V_UF_CLIENTE) AND ( Busca_Gener(945,186,1)=1) THEN
               RETURN (V_PFAT_P_PROF_ALIQ_ICM);
           ELSE
              RETURN (V_PFAT_OPER_ALIQ_ICM_FABR);
          END IF;
       RETURN (V_PFAT_OPER_ALIQ_ICM_FABR);
     END IF;


  EXCEPTION
     WHEN OTHERS THEN
        RETURN (-1);
  END Obter_Aliq_ICM;

  FUNCTION Obter_Valor_ICM (sTipoCha in integer)RETURN REAL AS
    --sTipoCha = 1 permite fazer o calculo mesmo q tem
    --redução isso é usado para S.T com valor do icms cheio sem reduzir
  V_DESP_ACESSORIAS_ITEM  REAL        := 0;
  V_VALOR_IPI             REAL        := 0;
  V_VLR_DESP_INI          REAL        := 0;
  V_VALOR_MERCADORIA_TEMP   REAL := 0;



  BEGIN
    /*FRETE_GENER*/
    V_VALORIZO_IPI := FALSE;
    V_VLR_DESP_INI   := V_PFAT_PEDF_VLR_DESP;
    IF V_PEDF_FLAG_DESP_ICMS = 1 THEN
       V_PFAT_PEDF_VLR_DESP  := 0;
     END IF;

    IF V_OPER_SUFRAMA = 'S' THEN --QTO FOR SUFRAMA O DESCONTO NAO DEVE ENTRA NA BASE LEMBRANDO Q O  ICMS É
                                 -- CALCULANDO SOMENTE PARA EFEITO DO CALCULO DO S.T
        V_DESCONTO_OLD := 0;
       ELSE
        V_DESCONTO_OLD := NVL(V_DESCONTO_NOR_ITEM,0);
    END IF ;

    V_BASE_ICMS := 0;

    IF (V_PFAT_P_CONTROLE_ISENTO = 0) THEN
       V_TOT_ITENS_ISENTOS := V_TOT_ITENS_ISENTOS + V_VALOR_MERCADORIA;
    END IF;

    IF (V_PFAT_P_CONTROLE_ISENTO = 1 AND V_TOT_ITENS_ISENTOS > 0) THEN
      -- CODIGO
      V_DESP_ACESSORIAS_ITEM := RATIAR_VALOR(V_VLR_TOT_MERCADORIA  - NVL(V_TOT_MERC_SELO,0), (V_PFAT_PEDF_VLR_DESP + V_PFAT_PEDF_VLR_SEG),(V_VALOR_MERCADORIA  +
                                RATIAR_VALOR((V_VLR_TOT_MERCADORIA  - NVL(V_TOT_MERC_SELO,0) - V_TOT_ITENS_ISENTOS), V_TOT_ITENS_ISENTOS,V_VALOR_MERCADORIA)));
    END IF;

    IF (V_PFAT_P_CONTROLE_ISENTO = 1 AND V_TOT_ITENS_ISENTOS = 0) THEN
      V_DESP_ACESSORIAS_ITEM := RATIAR_VALOR(V_VLR_TOT_MERCADORIA  - NVL(V_TOT_MERC_SELO,0), (V_PFAT_PEDF_VLR_DESP + V_PFAT_PEDF_VLR_SEG) , V_VALOR_MERCADORIA);
    END IF;


    V_PFAT_PEDF_VLR_DESP   := V_VLR_DESP_INI;
    IF (V_ALIQ_ICM_REDUCAO = 0) Or (sTipoCha  IN (1,2))  THEN
       if sTipoCha = 1 then
          V_VALOR_MERCADORIA_TEMP := V_VALOR_MERCADORIA;
          V_VALOR_MERCADORIA      := V_VLR_MERC_ICMS_PARA_ST;
       end if;


      --V_AGREGA_IPI_FIS     :=  Busca_Param_945_ID_131;
       IF (V_PFAT_OPER_TIPO_ICM = 5)                   OR --AGREGA IPI PELA OPERACAO
          (NVL(V_OPER_IMPORTACAO,'N') = 'S')                    OR -- AGREGA IPI SE FOR IMPORTAÇÃO
          (V_TIPO_PESSOA = 1 AND V_AGREGA_IPI_FIS = 0) OR -- PESSOA FISICA
          ( (V_TIPO_PESSOA = 2) AND (NVL(V_CLI_CONTRIB,'S') = 'N') ) THEN -- JURIDICA NAO CONTRIBUINTE
          V_VALOR_IPI := Calculo_Pedido_Fat$PK.Obter_Valor_IPI;
          V_VALORIZO_IPI := TRUE;
          IF V_PRIMEIRO_NR = 1 THEN
             IF NVL(V_OPER_IMPORTACAO,'N') = 'S' THEN
                V_BASE_ICMS := (((V_VALOR_MERCADORIA  - V_VALOR_ISENTO_ICM) + V_PRECO_FRETE  + V_DESP_ACESSORIAS_ITEM - V_DESCONTO_OLD + V_VALOR_IPI) / (1 -(V_ALIQ_ICM / 100)));
                if sTipoCha = 1 then
                   V_VALOR_MERCADORIA := V_VALOR_MERCADORIA_TEMP;
                end if;
                RETURN   (((V_BASE_ICMS) / (1 -(V_ALIQ_ICM / 100))) * (V_ALIQ_ICM / 100) );
             ELSE
                V_BASE_ICMS := ((V_VALOR_MERCADORIA  - V_VALOR_ISENTO_ICM) + V_PRECO_FRETE  + V_DESP_ACESSORIAS_ITEM - V_DESCONTO_OLD + V_VALOR_IPI);
                if sTipoCha = 1 then
                   V_VALOR_MERCADORIA := V_VALOR_MERCADORIA_TEMP;
                end if;
                RETURN   V_BASE_ICMS * (V_ALIQ_ICM / 100 );
             END IF;
          ELSE
             IF NVL(V_OPER_IMPORTACAO,'N') = 'S' THEN
                V_BASE_ICMS := (((V_VALOR_MERCADORIA  - V_VALOR_ISENTO_ICM) + V_PRECO_FRETE  + V_DESP_ACESSORIAS_ITEM - V_DESCONTO_OLD + V_VALOR_IPI) / (1 -(V_ALIQ_ICM / 100)));
                if sTipoCha = 1 then
                   V_VALOR_MERCADORIA := V_VALOR_MERCADORIA_TEMP;
                end if;
                RETURN   (((V_BASE_ICMS) / (1 -(V_ALIQ_ICM / 100))) * (V_ALIQ_ICM / 100) );
             ELSE
                V_BASE_ICMS := ((V_VALOR_MERCADORIA  - V_VALOR_ISENTO_ICM) + V_PRECO_FRETE  + V_DESP_ACESSORIAS_ITEM - V_DESCONTO_OLD + V_VALOR_IPI);
                if sTipoCha = 1 then
                   V_VALOR_MERCADORIA := V_VALOR_MERCADORIA_TEMP;
                end if;
                RETURN   V_BASE_ICMS * (V_ALIQ_ICM / 100 );
             END IF;
          END IF;
          V_VALOR_IPI := 0;
       ELSE
          IF  V_PRIMEIRO_NR = 1 THEN
             V_BASE_ICMS := ((V_VALOR_MERCADORIA - V_VALOR_ISENTO_ICM) + V_PRECO_FRETE  + V_DESP_ACESSORIAS_ITEM - V_DESCONTO_OLD);
             if sTipoCha = 1 then
                   V_VALOR_MERCADORIA := V_VALOR_MERCADORIA_TEMP;
             end if;
             RETURN V_BASE_ICMS * (V_ALIQ_ICM / 100 );
          ELSE
             V_BASE_ICMS := ((V_VALOR_MERCADORIA  - V_VALOR_ISENTO_ICM) + V_PRECO_FRETE + V_DESP_ACESSORIAS_ITEM - V_DESCONTO_OLD);
             if sTipoCha = 1 then
                   V_VALOR_MERCADORIA := V_VALOR_MERCADORIA_TEMP;
             end if;
             RETURN  V_BASE_ICMS * (V_ALIQ_ICM / 100 );
          END IF;
       END IF;


    ELSE
       RETURN (V_VALOR_RED_ICM);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN (-1);
  END Obter_Valor_ICM;

  PROCEDURE Gravar_Pedido_Fat_S AS
  V_FLAG REAL;
  BEGIN
    SELECT PEDF_PEDF_ID INTO V_FLAG
           FROM PEDIDO_FAT_S
           WHERE PEDF_PEDF_EMP_ID = V_EMP_ATIVA AND
                 PEDF_PEDF_ID     = V_PFAT_PEDF_ID AND
                 PEDF_ALIQ_SUBST  = V_ALIQ_SUBST;


    UPDATE PEDIDO_FAT_S SET
      PEDF_VLR_RED_SUBST  = 0,
      PEDF_ALIQ_RED_SUBST = 0,
      PEDF_BASE_SUBST     = PEDF_BASE_SUBST + V_BASE_SUBST,
      PEDF_VLR_SUBST      = PEDF_VLR_SUBST + V_VALOR_ICM_SUBST
    WHERE
      PEDF_PEDF_EMP_ID = V_EMP_ATIVA AND
      PEDF_PEDF_ID     = V_PFAT_PEDF_ID AND
      PEDF_ALIQ_SUBST  = V_ALIQ_SUBST;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       INSERT INTO PEDIDO_FAT_S
              (PEDF_PEDF_EMP_ID,
               PEDF_PEDF_ID,
               PEDF_ALIQ_SUBST,
               PEDF_VLR_RED_SUBST,
               PEDF_ALIQ_RED_SUBST,
               PEDF_BASE_SUBST,
               PEDF_VLR_SUBST)
              VALUES
              (
                V_EMP_ATIVA,
                V_PFAT_PEDF_ID,
                V_ALIQ_SUBST,
                0,
                0,
                V_BASE_SUBST,
                V_VALOR_ICM_SUBST);
  END Gravar_Pedido_Fat_S;


  PROCEDURE Gravar_Pedido_Fat_I AS
  V_FLAG REAL;
  BEGIN

     IF  V_PRIMEIRO_NR = 1 THEN
        V_PEDF_BASE_ICM := V_BASE_ICM_PRODUTO;
        -- + V_PFAT_PEDF_VLR_FRETE; --FRETE JA INCLUSO NO CALCULO DA VARIAVEL V_BASE_ICM_PRODUTO
     ELSE
        V_PEDF_BASE_ICM := V_BASE_ICM_PRODUTO;
    /*+ V_PFAT_PEDF_VLR_FRETE;*/
    END IF;

     IF V_VALOR_ICM = 0 THEN
        V_PEDF_BASE_ICM := 0;
     END IF;
     SELECT PEDF_PEDF_ID INTO V_FLAG
       FROM PEDIDO_FAT_I
      WHERE PEDF_PEDF_EMP_ID = V_EMP_ATIVA AND
            PEDF_PEDF_ID     = V_PFAT_PEDF_ID AND
            PEDF_ALIQ_ICM    = V_ALIQ_ICM;

     UPDATE PEDIDO_FAT_I SET
            PEDF_VLR_RED_ICM = ROUND(PEDF_VLR_RED_ICM + V_VALOR_RED_ICM,2),
            PEDF_BASE_ICM    = PEDF_BASE_ICM + Decode(V_PFAT_P_PROF_COD_ICM, 0, ROUND(V_PEDF_BASE_ICM,2), 1, 0, ROUND(V_PEDF_BASE_ICM,2)),
            PEDF_VLR_ICM     = PEDF_VLR_ICM + Decode(V_PFAT_P_PROF_COD_ICM, 0, ROUND(V_VALOR_ICM,2), 1, 0, ROUND(V_VALOR_ICM,2))
      WHERE PEDF_PEDF_EMP_ID = V_EMP_ATIVA AND
            PEDF_PEDF_ID     = V_PFAT_PEDF_ID AND
            PEDF_ALIQ_ICM    = V_ALIQ_ICM;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        INSERT INTO PEDIDO_FAT_I
               (PEDF_PEDF_EMP_ID
                ,PEDF_PEDF_ID
                ,PEDF_ALIQ_ICM
                ,PEDF_VLR_RED_ICM
                ,PEDF_ALIQ_RED_ICM
                ,PEDF_BASE_ICM
                ,PEDF_VLR_ICM)
               VALUES
               ( V_EMP_ATIVA
                ,V_PFAT_PEDF_ID
                ,V_ALIQ_ICM
                ,ROUND(V_VALOR_RED_ICM,2)
                ,V_ALIQ_ICM_REDUCAO
                ,ROUND(Decode(V_PFAT_P_PROF_COD_ICM, 0, V_PEDF_BASE_ICM, 1, 0, V_PEDF_BASE_ICM),2)
                ,ROUND(Decode(V_PFAT_P_PROF_COD_ICM, 0, V_VALOR_ICM, 1, 0, V_VALOR_ICM),2)
                );
  END Gravar_Pedido_Fat_I;

  FUNCTION Obter_Param_Desconto_Item(EMPRESA In Real) RETURN REAL IS
  V_PARAMETRO REAL := 0;
  BEGIN
    SELECT GEN_NUMBER1 INTO V_PARAMETRO
    FROM GENER
    WHERE GEN_TGEN_ID = 941
      AND GEN_EMP_ID  = EMPRESA
      AND GEN_ID      = 15;

    RETURN(V_PARAMETRO);
  EXCEPTION
     WHEN OTHERS THEN
       RETURN(1);
  END Obter_Param_Desconto_Item;


/*FUNCTION Obter_Gener_945_181_NR2(EMPRESA In Real) RETURN REAL IS
  V_PARAMETRO REAL := 0;
  BEGIN
    SELECT NVL(GEN_NUMBER2,0) INTO V_PARAMETRO
    FROM GENER
    WHERE GEN_TGEN_ID = 945
      AND GEN_EMP_ID  = EMPRESA
      AND GEN_ID      = 181;

    RETURN(V_PARAMETRO);
  EXCEPTION
     WHEN OTHERS THEN
       RETURN(0);
  END Obter_Gener_945_181_NR2;
*/

  FUNCTION Obter_Desconto_Item(Tipo In Varchar2) RETURN REAL IS
  V_DESCONTO REAL := 0;
  V_DESCONTO_RATIADO REAL := 0;
  BEGIN
    IF (Tipo = 'E') and (Busca_Gener(945,181,1)) = 0 THEN
      /*  Especial DESCONTO EM TABELA DE PRECO
        neste caso o desconto deve vir da tabela de preco
      */
      V_DESCONTO := (V_PFAT_P_PEDF_QTDE * V_PFAT_P_TPRC_DESCONTO);
    ELSIF (Tipo = 'N') OR (Tipo = 'P') THEN
       /*  Normal OU Desconto em Pedido
         neste caso o desconto deve vir do campo da tabela de Pedido_Fat_P
       */

      IF (V_USA_DESCONTO_ATACADO = 'S') THEN
        IF (MOD(V_PFAT_P_PEDF_QTDE ,V_FATOR_CX_PRODUTO) = 0) THEN
          V_PFAT_P_PEDF_PERC_DESC    := V_PFAT_P_PEDF_PERC_DESC + V_DESCONTO_EMPRESA + V_DESCONTO_ATACADO_PRODUTO;
        ELSE
          V_PFAT_P_PEDF_PERC_DESC    := V_PFAT_P_PEDF_PERC_DESC + V_DESCONTO_EMPRESA;
        END IF;
      ELSE
        V_DESCONTO_ATACADO_PRODUTO := 0;
      END IF;

      IF Obter_Param_Desconto_Item(V_EMP_ATIVA) = 1 THEN
         V_DESCONTO := round( (V_VALOR_MERCADORIA * (V_PFAT_P_PEDF_PERC_DESC / 100)) ,2);
         IF (V_PFAT_PEDF_VLR_DESC <> 0) THEN
           V_DESCONTO_RATIADO := RATIAR_VALOR(V_VLR_TOT_MERCADORIA , V_PFAT_PEDF_VLR_DESC, V_VALOR_MERCADORIA);
         END IF;
      ELSE
        V_DESCONTO  := round(((V_PFAT_P_TPRC_PRC_FAB * V_PFAT_P_PEDF_QTDE) * (V_PFAT_P_PEDF_PERC_DESC / 100)),2);
        IF (V_PFAT_PEDF_VLR_DESC <> 0) THEN
          V_DESCONTO_RATIADO  := RATIAR_VALOR(V_VLR_TOT_MERCADORIA , V_PFAT_PEDF_VLR_DESC, (V_PFAT_P_TPRC_PRC_FAB * V_PFAT_P_PEDF_QTDE));
        END IF;
      END IF;




      V_DESCONTO := V_DESCONTO + V_DESCONTO_RATIADO;
    END IF;
    RETURN(V_DESCONTO);
  END Obter_Desconto_Item;

  PROCEDURE Gravar_Pedido_Fat_P AS
  V_VALOR_IPI             REAL := 0;
  V_BASE_IPI              REAL := 0;
  --V_DESCONTO_RATIADO      REAL := 0;
  --V_ACRESCIMO_RATIADO     REAL := 0;
  V_DESP_ACESSORIAS_ITEM  REAL := 0;
  V_DESCONTO_TOTAL        REAL := 0;
  V_VALOR_SEG             REAL := 0;
  V_VALOR_DESCONTO        REAL := 0;
  --V_VALOR_FRETE           REAL := 0;
  V_VLR_DESP_INI          REAL := 0;
  V_VLR_DESP              REAL := 0;
  V_PEDF_VLR_UNIT_NFRETE  REAL := 0;
  V_PEDF_VLR_TOTAL_NFRETE REAL := 0;
  V_VALOR_IMPORTACAO      REAL := 0;
  V_VALOR_IMPORTACAO_LIQ  REAL := 0;
  V_CST_IPI VARCHAR2(2) :=NULL;
  BEGIN
    /*FRETE_GENER*/



    V_CST_IPI := ObterCst_IPI(V_OPER_ID,V_PFAT_P_PEDF_PROD_ID);
    V_PEDF_VLR_UNIT_NFRETE  := V_PFAT_P_TPRC_PRC_FINAL - (V_FRETE_ITEM_SABAO_OESTE * V_PROF_PESO_B);

    IF V_PEDF_VLR_UNIT_NFRETE > 0 THEN
     V_PEDF_VLR_TOTAL_NFRETE := (V_PEDF_VLR_UNIT_NFRETE * V_PFAT_P_PEDF_QTDE) -((V_PEDF_VLR_UNIT_NFRETE * V_PFAT_P_PEDF_QTDE) * NVL(V_PFAT_P_PEDF_PERC_DESC,0) / 100)  ;
    ELSE
     V_PEDF_VLR_UNIT_NFRETE  := V_PFAT_P_TPRC_PRC_FAB;
     V_PEDF_VLR_TOTAL_NFRETE := 0 ;
    END IF;


    dbms_output.put_line(V_VALOR_DESCONTO);

    V_BASE_ICM_PRODUTO      := 0;
    V_VALOR_IPI             := Calculo_Pedido_Fat$PK.Obter_Valor_IPI;

    IF (V_PFAT_OPER_TIPO_IPI = 1 AND NOT (V_PFAT_P_PROF_VLR_IPI > 0 AND V_PFAT_P_PROF_ALIQ_IPI > 0)) THEN
      IF NVL(V_OPER_IMPORTACAO,'N') <> 'S' THEN
        IF V_OPER_PRC_FINAL = 'S' THEN
          V_VALOR_TOTAL_PEDIDO    := V_VALOR_TOTAL_PEDIDO + V_VALOR_MERCADORIA;
        ELSE
          V_VALOR_TOTAL_PEDIDO    := V_VALOR_TOTAL_PEDIDO + V_VALOR_MERCADORIA + V_VALOR_IPI ;
        END IF;
      END IF;
    ELSE
      IF NVL(V_OPER_IMPORTACAO,'N') <> 'S' THEN
        V_VALOR_TOTAL_PEDIDO    := V_VALOR_TOTAL_PEDIDO + V_VALOR_MERCADORIA + V_VALOR_IPI;
      END IF;
    END IF;

    V_VALOR_TOTAL_DESC_NOR  := V_VALOR_TOTAL_DESC_NOR + V_DESCONTO_NOR_ITEM;
    V_VALOR_TOTAL_DESC_ESP  := V_VALOR_TOTAL_DESC_ESP + V_DESCONTO_ESP_ITEM;
    V_VLR_DESP_INI := V_PFAT_PEDF_VLR_DESP;

    IF V_PEDF_FLAG_DESP_ICMS = 1 THEN --SOMENTE PARA EFEITO DE CALCULO DO ICM
      V_PFAT_PEDF_VLR_DESP := 0;
    END IF;

    IF (V_PFAT_P_CONTROLE_ISENTO = 1 AND V_TOT_ITENS_ISENTOS > 0) THEN
      -- CODIGO
        V_DESP_ACESSORIAS_ITEM := RATIAR_VALOR(V_VLR_TOT_MERCADORIA  - NVL(V_TOT_MERC_SELO,0), (V_PFAT_PEDF_VLR_DESP + V_PFAT_PEDF_VLR_SEG),(V_VALOR_MERCADORIA  +
                                RATIAR_VALOR((V_VLR_TOT_MERCADORIA  - NVL(V_TOT_MERC_SELO,0) - V_TOT_ITENS_ISENTOS), V_TOT_ITENS_ISENTOS,V_VALOR_MERCADORIA))) + V_PRECO_FRETE;
    ELSE
        IF (V_PFAT_P_CONTROLE_ISENTO = 1 AND V_TOT_ITENS_ISENTOS = 0) THEN
             V_DESP_ACESSORIAS_ITEM := RATIAR_VALOR(V_VLR_TOT_MERCADORIA  - NVL(V_TOT_MERC_SELO,0), (V_PFAT_PEDF_VLR_DESP + V_PFAT_PEDF_VLR_SEG) , V_VALOR_MERCADORIA) + V_PRECO_FRETE;

        ELSE
           IF  V_PRIMEIRO_NR = 1 THEN
               V_DESP_ACESSORIAS_ITEM  := RATIAR_VALOR(V_VLR_TOT_MERCADORIA  - NVL(V_TOT_MERC_SELO,0), (V_PFAT_PEDF_VLR_DESP + V_PFAT_PEDF_VLR_SEG) , V_VALOR_MERCADORIA)+ V_PRECO_FRETE;

             ELSE
                   V_DESP_ACESSORIAS_ITEM  := RATIAR_VALOR(V_VLR_TOT_MERCADORIA    - NVL(V_TOT_MERC_SELO,0) , (V_PFAT_PEDF_VLR_DESP + V_PFAT_PEDF_VLR_SEG) , V_VALOR_MERCADORIA)+ V_PRECO_FRETE;
            END IF;

        END IF;
    END IF;

     V_PFAT_PEDF_VLR_DESP     := V_VLR_DESP_INI;
     V_VALOR_TOTAL_ADC_FINANC := V_VALOR_TOTAL_ADC_FINANC + ( V_VALOR_ADC_FINANC_ITEM * V_PFAT_P_PEDF_QTDE);
     V_VALOR_TOTAL_SUBST      := V_VALOR_TOTAL_SUBST + V_VALOR_ICM_SUBST;
  --   V_VALOR_PIS              := Calculo_Pedido_Fat$PK.Obter_Valor_PIS;
  --   V_VALOR_COFINS           := Calculo_Pedido_Fat$PK.Obter_Valor_COFINS;
      IF V_PFAT_P_FLAG_SELO  = 'N' THEN -- NAO RATIAR O SELO
         V_VALOR_SEG             := RATIAR_VALOR(V_VLR_TOT_MERCADORIA    - V_TOT_MERC_SELO,V_PFAT_PEDF_VLR_SEG, V_VALOR_MERCADORIA);
         --V_VALOR_DESCONTO        := RATIAR_VALOR(V_VLR_TOT_MERCADORIA    - V_TOT_MERC_SELO,V_PFAT_PEDF_VLR_DESC, V_VALOR_MERCADORIA);

        V_VLR_DESP              := RATIAR_VALOR(V_VLR_TOT_MERCADORIA    - V_TOT_MERC_SELO,V_PFAT_PEDF_VLR_DESP, V_VALOR_MERCADORIA);
        IF V_PFAT_PEDF_VLR_DESC = 0 THEN
           V_VALOR_DESCONTO  :=  V_DESCONTO_ESP_ITEM;
       ELSE
           V_VALOR_DESCONTO  := RATIAR_VALOR(V_VLR_TOT_PRC_FAB , V_PFAT_PEDF_VLR_DESC, V_PFAT_P_TPRC_PRC_FAB_MEC * V_PFAT_P_PEDF_QTDE);
       END IF;

    ELSE
         V_VALOR_SEG             := 0;
         V_VALOR_DESCONTO        := 0;
         V_PRECO_FRETE           := 0;
         V_VLR_FRETE_RATEIO      := 0;
         V_VLR_DESP              := 0;

    END IF;

     IF V_PFAT_OPER_TIPO_IPI = 1 THEN
        IF V_VALOR_IPI       > 0 THEN
           --V_BASE_IPI := V_VALOR_MERCADORIA;
   -- AQUI
           IF (V_PFAT_OPER_TIPO_IPI = 1 AND NOT  V_PFAT_P_PROF_VLR_IPI > 0 AND V_PFAT_P_PROF_ALIQ_IPI > 0) AND V_OPER_PRC_FINAL = 'S' THEN
               V_BASE_IPI := V_VALOR_MERCADORIA - V_DESCONTO_NOR_ITEM - Calculo_Pedido_Fat$PK.Obter_Valor_IPI;
           ELSE
               if (V_PASSO_PELA_REGRA_13097) AND (V_PFAT_P_PROF_ALIQ_IPI = 0) then
                   V_BASE_IPI := (V_PFAT_P_PEDF_QTDE * (V_PFAT_P_PROC_LITRAGEM  / 1000) * V_FATOR_CX_PRODUTO);
               ELSE
                   IF (V_DESC_BASE_IPI = 1) AND (V_PFAT_P_PROF_ALIQ_IPI > 0) THEN
                          V_BASE_IPI := V_VALOR_MERCADORIA + V_PRECO_FRETE_IPI - V_VALOR_DESCONTO ;
                   ELSE
                      V_BASE_IPI := V_VALOR_MERCADORIA + V_PRECO_FRETE_IPI;
                   END IF;
               END IF ;
           END IF;
        END IF;
     END IF;
     /*
       V_PFAT_OPER_TIPO_ICM =
         1 CREDITO
         2 OUTROS
         3 ISENTO
         4 DISTRIBUIDOR
         5 AGREGAR IPI
     */
     IF V_PFAT_OPER_TIPO_ICM IN (2,3,4) THEN
       V_BASE_ICM_PRODUTO := 0;
     /*CREDITO AGREGADO AO IPI*/
     ELSIF (V_PFAT_OPER_TIPO_ICM = 5) OR
           (V_TIPO_PESSOA = 1 AND V_AGREGA_IPI_FIS = 0) OR
           (NVL(V_OPER_IMPORTACAO,'N') = 'S') OR
           ( (V_TIPO_PESSOA = 2) AND (V_CLI_CONTRIB = 'N') ) THEN
       IF (V_ALIQ_ICM_REDUCAO = 0) OR
          ( (V_OPER_TIPO_REDUCAO = 2) AND (V_UF_EMPRESA = V_UF_CLIENTE) ) THEN
          IF (NVL(V_OPER_IMPORTACAO,'N') = 'S') THEN
             V_BASE_ICM_PRODUTO := ((((V_VALOR_MERCADORIA - V_VALOR_ISENTO_ICM) + V_DESP_ACESSORIAS_ITEM - V_DESCONTO_NOR_ITEM) + V_VALOR_IPI)  / (1 -(V_ALIQ_ICM / 100)));
          ELSE
            V_BASE_ICM_PRODUTO := ((V_VALOR_MERCADORIA - V_VALOR_ISENTO_ICM) + V_DESP_ACESSORIAS_ITEM - V_DESCONTO_NOR_ITEM) + V_VALOR_IPI;

          END IF ;
       ELSE
          IF  V_PRIMEIRO_NR = 1 THEN
            V_BASE_ICM_PRODUTO := (((V_VALOR_MERCADORIA - V_VALOR_ISENTO_ICM) - V_DESCONTO_NOR_ITEM + V_VALOR_IPI) * V_ALIQ_ICM_REDUCAO / 100)+ V_DESP_ACESSORIAS_ITEM;-- O FRETE ESTA
           Else                                                                                                                                                        -- INCLUIDO NA DESP PARA O 1º ITEM
            V_BASE_ICM_PRODUTO := (((V_VALOR_MERCADORIA - V_VALOR_ISENTO_ICM) - V_DESCONTO_NOR_ITEM + V_VALOR_IPI ) * V_ALIQ_ICM_REDUCAO / 100)+ V_DESP_ACESSORIAS_ITEM ;
           End if;
       end if;
     ELSIF (V_PFAT_OPER_TIPO_ICM = 1) OR  ( (V_TIPO_PESSOA = 2) AND (V_CLI_CONTRIB <> 'N') ) THEN
       if (V_ALIQ_ICM_REDUCAO = 0) OR ( (V_OPER_TIPO_REDUCAO = 2) AND (V_UF_EMPRESA = V_UF_CLIENTE) ) then
         V_BASE_ICM_PRODUTO := V_VALOR_MERCADORIA + V_DESP_ACESSORIAS_ITEM - V_DESCONTO_NOR_ITEM;
       else
  -- AQUI
        IF (V_PFAT_OPER_TIPO_IPI = 1 AND NOT  V_PFAT_P_PROF_VLR_IPI > 0 AND V_PFAT_P_PROF_ALIQ_IPI > 0 AND V_OPER_PRC_FINAL = 'S') THEN
           IF  V_PRIMEIRO_NR = 1 THEN
            V_BASE_ICM_PRODUTO := ((V_VALOR_MERCADORIA  - V_DESCONTO_NOR_ITEM - ((CALCULO_PEDIDO_FAT$PK.OBTER_VALOR_IPI))) * V_ALIQ_ICM_REDUCAO / 100)+ V_DESP_ACESSORIAS_ITEM;-- O FRETE ESTA
           Else                                                                                                                    -- INCLUIDO NA DESP PARA O 1º ITEM
             V_BASE_ICM_PRODUTO := ((V_VALOR_MERCADORIA - V_DESCONTO_NOR_ITEM - ((CALCULO_PEDIDO_FAT$PK.OBTER_VALOR_IPI))) * V_ALIQ_ICM_REDUCAO / 100) + V_DESP_ACESSORIAS_ITEM;
           End if ;

        ELSE

        IF  V_PRIMEIRO_NR = 1 THEN
            V_BASE_ICM_PRODUTO := ((V_VALOR_MERCADORIA  - V_DESCONTO_NOR_ITEM) * V_ALIQ_ICM_REDUCAO / 100)+ V_DESP_ACESSORIAS_ITEM;-- O FRETE ESTA
           Else                                                                                                                    -- INCLUIDO NA DESP PARA O 1º ITEM
             V_BASE_ICM_PRODUTO := ((V_VALOR_MERCADORIA - V_DESCONTO_NOR_ITEM) * V_ALIQ_ICM_REDUCAO / 100) + V_DESP_ACESSORIAS_ITEM;
           End if ;
            END IF;
-- ATE AQUI
       end if;
     ELSE
       V_BASE_ICM_PRODUTO := 0;
     END IF;
    -- V_VALOR_PIS              := Calculo_Pedido_Fat$PK.Obter_Valor_PIS;
    -- V_VALOR_COFINS           := Calculo_Pedido_Fat$PK.Obter_Valor_COFINS;
     IF V_VLR_SUBST_NORMAL - V_BASE_SUBST  > 0
       THEN
        V_VLR_RED_SUBST :=  V_VLR_SUBST_NORMAL - V_BASE_SUBST;
       ELSE
        V_VLR_RED_SUBST :=0;
      END IF;

     V_DESCONTO_TOTAL := (V_DESCONTO_ATACADO_PRODUTO + V_DESCONTO_EMPRESA);

      IF (NVL(V_OPER_IMPORTACAO,'N') = 'S') THEN
        V_VALOR_IMPORTACAO     := V_BASE_ICM_PRODUTO;
        V_VALOR_IMPORTACAO_LIQ := V_BASE_ICM_PRODUTO;
      IF V_PFAT_OPER_TIPO_ICM IN (2,3,4) THEN --isso é pra qto nao tem icms  PQ O PEDIDO FICAVA COM VALOR zero aff
           V_VALOR_TOTAL_PEDIDO   := V_VALOR_TOTAL_PEDIDO +   V_VALOR_MERCADORIA + V_VALOR_IPI - V_DESCONTO_NOR_ITEM;
           V_VALOR_IMPORTACAO     := V_VALOR_MERCADORIA + V_VALOR_IPI - V_DESCONTO_NOR_ITEM;
           V_VALOR_IMPORTACAO_LIQ := V_VALOR_IMPORTACAO;
           else
           V_VALOR_TOTAL_PEDIDO   := V_VALOR_TOTAL_PEDIDO + V_BASE_ICM_PRODUTO;
       end if ;
     ELSE
        IF V_SUBS_TAB = 1 THEN
           IF V_PEDF_PERC_DESC_ORIGINAL = 0 THEN
              V_VALOR_IMPORTACAO  := ROUND(V_VALOR_MERCADORIA,2);
           ELSE
              V_VALOR_IMPORTACAO  := (V_PFAT_P_TPRC_PRC_FAB * V_PFAT_P_PEDF_QTDE);
           END IF;
        ELSE
          V_VALOR_IMPORTACAO := ROUND(V_VALOR_MERCADORIA,2);
        END IF;
        V_VALOR_IMPORTACAO_LIQ := ROUND(V_VALOR_MERCADORIA,2);
     END IF;


    IF (V_RAT_DESC_CAPA = 1) AND (V_SUBS_TAB = 1) and (V_PFAT_PEDF_VLR_DESC > 0) THEN
      V_PFAT_P_TPRC_PRC_FAB := round((V_VALOR_MERCADORIA + V_VALOR_DESCONTO)/V_PFAT_P_PEDF_QTDE,5);
      V_VALOR_IMPORTACAO    := (V_VALOR_MERCADORIA + V_VALOR_DESCONTO);
    END IF;
    if (V_EMP_REGIME_TRIBUTARIO = 1)  then
          V_BASE_ICM_PRODUTO := 0;
          V_VALOR_ICM        := 0;
          V_ALIQ_ICM         := 0;
    end if;
     if V_VALOR_IPI = 0 then
      V_VALOR_IPI            := null;
      V_PFAT_P_PROF_ALIQ_IPI := null;
      V_BASE_IPI             := null;

     end if;
     v_CFO_PROD := ObterCFO(V_OPER_ID,V_PFAT_P_PEDF_PROD_ID);
     IF V_BASE_RED_COM_FRETE > 0 THEN
        V_BASE_ICM_PRODUTO := V_BASE_RED_COM_FRETE;
      END IF ;
     UPDATE PEDIDO_FAT_P SET
       PEDF_VALOR_SEGURO    = round(V_VALOR_SEG,2),
       PEDF_VALOR_DESCONTO  = V_VALOR_DESCONTO,
       PEDF_VALOR_FRETE     = V_VLR_FRETE_RATEIO,
       PEDF_VLR_RAT_FUNDO_POBREZA = (CASE  WHEN v_CONSUMIDOR_FINAL IN (0,2)--BASE ST PESSOA JURIDICA
                                     THEN
                                      DECODE(NVL(V_VALOR_ICM_SUBST,0),0,0,NVL(ROUND( V_BASE_SUBST*(V_PERC_FUNDO_POBREZA_P/100),2),0))
                                     ELSE
                                       0
                                     END),
       PEDF_VLR_FUNDO_POBREZA_ICMS = (CASE  WHEN v_CONSUMIDOR_FINAL IN (1,2) --BASE ICMS CONSUMIDOR FINAL
                                     THEN
                                       DECODE(NVL(V_VALOR_ICM,0),0,0,NVL(ROUND(V_BASE_ICM_PRODUTO*(V_PERC_FUNDO_POBREZA_P/100),2),0))
                                     ELSE
                                       0
                                     END),
       PEDF_VALOR_DESP      = V_VLR_DESP,
       PEDF_VLR_RED_ICMS    = ROUND(V_VALOR_RED_ICM,2),
       PEDF_ALIQ_RED_ICMS   = V_ALIQ_ICM_REDUCAO,
       PEDF_BASE_ICMS       = ROUND(Decode(V_PFAT_P_PROF_COD_ICM, 0, V_BASE_ICM_PRODUTO, 1, 0, V_BASE_ICM_PRODUTO),2),
       PEDF_VLR_ICMS        = ROUND(Decode(V_PFAT_P_PROF_COD_ICM, 0, V_VALOR_ICM, 1, 0, V_VALOR_ICM),2),
       PEDF_ALIQ_ICMS       = Decode(V_PFAT_P_PROF_COD_ICM, 0, V_ALIQ_ICM, 1, 0, V_ALIQ_ICM),
       PEDF_ALIQ_RED_SUBST  = 0,
       PEDF_VLR_IPI         = DECODE(V_CST_IPI,99,0,ROUND(V_VALOR_IPI,2)),
       PEDF_ALIQ_IPI        = DECODE(V_CST_IPI,99,0,V_PFAT_P_PROF_ALIQ_IPI),
       PEDF_BASE_IPI        = DECODE(V_CST_IPI,99,0,ROUND(V_BASE_IPI,2)),
       PEDF_VLR_SUBS        = ROUND(V_VALOR_ICM_SUBST,2),
       PEDF_ALIQ_SUBS       = V_ALIQ_SUBST,
       PEDF_VLR_RED_SUBST   = ROUND(V_VLR_RED_SUBST,2),
       PEDF_BASE_SUBS       = ROUND(V_BASE_SUBST,2),
       PEDF_BASE_ICMS_FRETE = 0,
       PEDF_ALIQ_ICMS_FRETE = 0,
       PEDF_VLR_ICMS_FRETE  = 0,
       PEDF_VLR_SELO        = 0,
       PEDF_VLR_UNIT        = V_PFAT_P_TPRC_PRC_FAB,
       PEDF_VLR_TOT         = ROUND(V_VALOR_IMPORTACAO,2), --DECODE(V_SUBS_TAB,1, DECODE(V_PEDF_PERC_DESC_ORIGINAL,0,ROUND(V_VALOR_MERCADORIA,2),V_PFAT_P_TPRC_PRC_FAB * PEDF_QTDE) ,ROUND(V_VALOR_MERCADORIA,2)) ,
       PEDF_VLR_TOT_LIQ     = ROUND(V_VALOR_MERCADORIA,2),
       PEDF_VLR_FRETE       = ROUND(V_PFAT_P_TPRC_PRC_FRETE,2),
       PEDF_ADC_FINANC      = ROUND(V_VALOR_ADC_FINANC_ITEM,2),
       PEDF_DESC_ATACADO    = ROUND(V_DESCONTO_TOTAL,2),
       --PEDF_PERC_DESC       = V_PFAT_P_PEDF_PERC_DESC,
       PEDF_BASE_PIS        = ROUND(V_BASE_PIS,2),
       PEDF_VLR_PIS         = ROUND(ROUND(V_VALOR_PIS,3),2),
       PEDF_ALIQ_PIS        = V_ALIQ_PIS,
       PEDF_BASE_COFINS     = ROUND(V_BASE_COFINS,2),
       PEDF_VLR_COFINS      = ROUND(ROUND(V_VALOR_COFINS,3),2),
       PEDF_ALIQ_COFINS     = V_ALIQ_COFINS,
       PEDF_VLR_UNIT_NFRETE = V_PEDF_VLR_UNIT_NFRETE,
       PEDF_VLR_TOTAL_NFRETE = DECODE(V_PEDF_VLR_TOTAL_NFRETE,0,DECODE(V_SUBS_TAB,1, DECODE(V_PEDF_PERC_DESC_ORIGINAL,0,ROUND(V_VALOR_MERCADORIA,2),PEDF_VLR_UNIT * PEDF_QTDE) ,ROUND(V_VALOR_MERCADORIA,2)),V_PEDF_VLR_TOTAL_NFRETE),
       PEDF_VLR_UNIT_DCY     = DECODE(V_OPER_PRC_FINAL,'S',NVL(V_LOC_VLR_UNIT_LIQ_DCY,0),0),
       PEDF_VLR_TOT_DCY      = DECODE(V_OPER_PRC_FINAL,'S',NVL(V_LOC_VLR_UNIT_LIQ_DCY * PEDF_QTDE,0) + NVL(V_VALOR_IPI,0) + NVL(V_VALOR_ICM_SUBST,0)+ NVL(V_PRECO_FRETE,0) - NVL(V_VALOR_DESCONTO,0) ,0),
       PEDF_VLR_DESC_ESP_DUPL = V_DESC_DUPL_P,
       PEDF_CST_PIS_COFINS    = V_CST_PIS_COFINS,
       PEDF_CST_IPI           = V_CST_IPI,
       pedf_lvr_CFO           = v_CFO_PROD,
       pedf_lvr_NBM           = V_NBM,
       pedf_lvr_PROF_REDUCAO_OE =V_PROF_REDUCAO_OE,
       PEDF_BASE_ICMS_DES       =DECODE(V_OPER_SUFRAMA,'S',V_BASE_ICM_PRODUTO,NULL),
       PEDF_VLR_ICMS_DES        =DECODE(V_OPER_SUFRAMA,'S',ROUND(V_VALOR_ICM,2),NULL),
       PEDF_ALIQ_ICMS_DES       =DECODE(V_OPER_SUFRAMA,'S',V_ALIQ_ICM,NULL),
       PEDF_ALIQ_FUNDO_POBREZA   = V_PERC_FUNDO_POBREZA_P,

       PEDF_ALIQ_ICMS_UF_DEST     = DECODE(V_CLI_IND_IE_DEST,9,V_ALIQ_ICMS_UF_DEST,null),
       PEDF_PERC_PART_ICMS_INTER  = DECODE(V_CLI_IND_IE_DEST,9,V_ALIQ_DIFAL,null),
       PEDF_PERC_FCP_UF_DEST      = DECODE(V_CLI_IND_IE_DEST,9,DECODE(V_PFAT_OPER_DESTINO_OPER,1,NULL,NVL(V_ALIQ_FUNDO_POBREZA_DIFAL,0)),NULL),

       PEDF_VLR_ICMS_FCP_UF_DEST  = ROUND(DECODE(V_CLI_IND_IE_DEST,9,DECODE(V_PFAT_OPER_DESTINO_OPER,1,NULL,V_BASE_ICM_PRODUTO *(NVL(V_ALIQ_FUNDO_POBREZA_DIFAL,0)/100)),NULL),2),
       PEDF_VLR_ICMS_INT_UF_DEST  = DECODE(V_CLI_IND_IE_DEST,9,ROUND(GREATEST(0,V_BASE_ICM_PRODUTO *(((V_ALIQ_ICMS_UF_DEST/100) - (V_ALIQ_ICM/100)) * (V_ALIQ_DIFAL/100))),2),null),
       PEDF_VLR_ICMS_INT_UF_REMET = DECODE(V_CLI_IND_IE_DEST,9,ROUND(GREATEST(0,DECODE(V_ALIQ_DIFAL,0,0,V_BASE_ICM_PRODUTO) *(((V_ALIQ_ICMS_UF_DEST/100) - (V_ALIQ_ICM/100)) * ((100 - V_ALIQ_DIFAL)/100))),2),null),

       PEDF_PAR_VDA_EMP_ID        = DECODE(V_USAR_REGRA_PAR_ALIQUOTA,0,NULL,V_EMP_ATIVA),
       PEDF_PAR_VDA_PROD_EMP_ID   = DECODE(V_USAR_REGRA_PAR_ALIQUOTA,0,NULL,V_EMP_ATIVA),
       PEDF_PAR_VDA_PROD_ID       = DECODE(V_USAR_REGRA_PAR_ALIQUOTA,0,NULL,V_PFAT_P_PEDF_PROD_ID),
       PEDF_PAR_VDA_TGEN_UF_ID    = DECODE(V_USAR_REGRA_PAR_ALIQUOTA,0,NULL,5006),
       PEDF_PAR_VDA_GEN_UF_EMP_ID = DECODE(V_USAR_REGRA_PAR_ALIQUOTA,0,NULL,0),
       padf_PAR_VDA_GEN_UF_ID     = DECODE(V_USAR_REGRA_PAR_ALIQUOTA,0,NULL,V_PAR_VDA_GEN_UF_ID),
       PEDF_PAR_VDA_DATA_VIGENCIA = DECODE(V_USAR_REGRA_PAR_ALIQUOTA,0,NULL,v_PAR_VDA_DATA_VIGENCIA)
     WHERE
       PEDF_PEDF_EMP_ID = V_EMP_ATIVA    AND
       PEDF_PEDF_ID     = V_PFAT_PEDF_ID AND
       PEDF_ID          = V_PFAT_P_PEDF_ID;


  END  Gravar_Pedido_Fat_P;

  PROCEDURE Gravar_Pedido_Fat AS
  VALOR_TOT_PED REAL :=0;
  V_FLAG_DESC_ESP           REAL := 0;

  BEGIN


    V_FLAG_DESC_ESP := Busca_Gener(945,151,1);


    IF NVL(V_OPER_IMPORTACAO,'N') = 'S' THEN
      VALOR_TOT_PED  := V_VALOR_TOTAL_PEDIDO;
    ELSE
      IF V_FLAG_DESC_ESP = 0 THEN
        VALOR_TOT_PED := V_VALOR_TOTAL_PEDIDO + V_PFAT_PEDF_VLR_FRETE +
                         V_PFAT_PEDF_VLR_SEG  + V_PFAT_PEDF_VLR_DESP +
                         V_VALOR_TOTAL_SUBST  -
                        (V_VALOR_TOTAL_DESC_ESP + V_VALOR_TOTAL_DESC_NOR)- Calculo_Pedido_Fat$PK.Obter_Impostos;

      ELSE
        VALOR_TOT_PED := V_VALOR_TOTAL_PEDIDO + V_PFAT_PEDF_VLR_FRETE  +
                         V_PFAT_PEDF_VLR_SEG  + V_PFAT_PEDF_VLR_DESP +
                         V_VALOR_TOTAL_SUBST  -
                         (V_VALOR_TOTAL_DESC_NOR)- Calculo_Pedido_Fat$PK.Obter_Impostos;

      END IF;

    END IF;

    IF  V_PEDF_FLAG_SEGURO <> 0  THEN
         V_BASE_VASILHAME:= 0 ;
    END IF ;


      UPDATE PEDIDO_FAT F SET
        F.PEDF_VLR_FRETE             =  V_PFAT_PEDF_VLR_FRETE
       ,F.PEDF_VLR_SEG               =  V_PFAT_PEDF_VLR_SEG
       ,F.PEDF_VLR_BASE_SEG          =  V_BASE_VASILHAME
       ,F.PEDF_IMP_LAYOUT            =  V_OPER_PRC_FINAL
       ,F.PEDF_VLR_TOT_DESC_ESP_DUPL =  V_DESC_DUPL
       /* campos guarda  historicos para uso no livro fiscal*/
       ,F.PEDF_LVR_OPER_BASE_CALC_ICM = V_PFAT_OPER_BASE_CALC_ICM
       ,F.PEDF_LVR_OPER_ALIQ_ICM_PROD = V_PFAT_OPER_ALIQ_ICM_PROD
       ,F.PEDF_LVR_OPER_TIPO_ICMR     = V_PFAT_OPER_TIPO_ICMR
       ,F.PEDF_LVR_OPER_TIPO_ICM      = V_PFAT_OPER_TIPO_ICM
       ,F.PEDF_LVR_OPER_TIPO_IPI      = V_PFAT_OPER_TIPO_IPI
       ,F.PEDF_VERSAO_CALCULO         = 2
       ,F.pedf_lvr_OPER_DIF_CRED_IPI   = v_OPER_DIF_CRED_IPI
       ,F.pedf_lvr_OPER_DIF_RED_BC_ICM = v_OPER_DIF_RED_BC_ICM
       ,F.pedf_lvr_OPER_TIPO_REDUCAO   = V_OPER_TIPO_REDUCAO
       ,F.pedf_OPER_ALIQ_RED_BC_ICM_OE = V_OPER_ALIQ_RED_BC_ICM_OE
       ,F.PEDF_PESO_BRUTO_TOTAL        = V_PESO_TOTAL
       ,PEDF_CLI_IND_IE_DEST = V_CLI_IND_IE_DEST
       ,PEDF_CLI_UF_DESTINO  = V_PEDF_CLI_UF_DESTINO
       ,PEDF_CONSUMIDOR_FINAL = DECODE(v_CONSUMIDOR_FINAL,1,'S','N')

       WHERE
         PEDF_EMP_ID = V_EMP_ATIVA AND
         PEDF_ID     = V_PFAT_PEDF_ID;


     IF ((V_PFAT_OPER_BASE_CALC_ICM = 'E') OR (V_PFAT_OPER_BASE_CALC_ICM = 'P')) THEN
      IF (V_ATU_NR_NF = 1) THEN

         IF V_FLAG_DESC_ESP = 0 THEN

           UPDATE PEDIDO_FAT SET
             PEDF_VLR_TOT_PED = ROUND(VALOR_TOT_PED,2),
             PEDF_ADC_FIN     = V_VALOR_TOTAL_ADC_FINANC,
             PEDF_NR_NF       = V_PFAT_PEDF_NR_NF,
             PEDF_SERIE_NF    = V_PFAT_SERIE_NF,
             PEDF_VLR_DESC    = (V_VALOR_TOTAL_DESC_NOR + V_VALOR_TOTAL_DESC_ESP),
             PEDF_IMP_LAYOUT        = V_OPER_PRC_FINAL
            ,PEDF_VLR_TOT_DESC_ESP_DUPL = V_DESC_DUPL
            ,PEDF_CLI_IND_IE_DEST = V_CLI_IND_IE_DEST
             ,PEDF_CLI_UF_DESTINO  = V_PEDF_CLI_UF_DESTINO
             ,PEDF_CONSUMIDOR_FINAL = DECODE(v_CONSUMIDOR_FINAL,1,'S','N')
           WHERE
             PEDF_EMP_ID = V_EMP_ATIVA AND
             PEDF_ID     = V_PFAT_PEDF_ID;

         ELSE
           UPDATE PEDIDO_FAT SET
             PEDF_VLR_TOT_PED = ROUND(VALOR_TOT_PED,2),
             PEDF_ADC_FIN     = V_VALOR_TOTAL_ADC_FINANC,
             PEDF_NR_NF       = V_PFAT_PEDF_NR_NF,
             PEDF_SERIE_NF    = V_PFAT_SERIE_NF,
             PEDF_VLR_DESC    = (V_VALOR_TOTAL_DESC_NOR),
             PEDF_IMP_LAYOUT        = V_OPER_PRC_FINAL
            ,PEDF_VLR_TOT_DESC_ESP_DUPL = V_DESC_DUPL
            ,PEDF_CLI_IND_IE_DEST = V_CLI_IND_IE_DEST
            ,PEDF_CLI_UF_DESTINO  = V_PEDF_CLI_UF_DESTINO
            ,PEDF_CONSUMIDOR_FINAL = DECODE(v_CONSUMIDOR_FINAL,1,'S','N')
           WHERE
             PEDF_EMP_ID = V_EMP_ATIVA AND
             PEDF_ID     = V_PFAT_PEDF_ID;

         END IF;


      ELSE
         IF V_FLAG_DESC_ESP = 0 THEN
           UPDATE PEDIDO_FAT SET
             PEDF_VLR_TOT_PED = ROUND(VALOR_TOT_PED,2),
             PEDF_ADC_FIN     = V_VALOR_TOTAL_ADC_FINANC,
             PEDF_VLR_DESC    = (V_VALOR_TOTAL_DESC_NOR + V_VALOR_TOTAL_DESC_ESP),
             PEDF_IMP_LAYOUT        = V_OPER_PRC_FINAL
            ,PEDF_VLR_TOT_DESC_ESP_DUPL = V_DESC_DUPL
            ,PEDF_CLI_IND_IE_DEST = V_CLI_IND_IE_DEST
            ,PEDF_CLI_UF_DESTINO  = V_PEDF_CLI_UF_DESTINO
            ,PEDF_CONSUMIDOR_FINAL = DECODE(v_CONSUMIDOR_FINAL,1,'S','N')
           WHERE
             PEDF_EMP_ID = V_EMP_ATIVA AND
             PEDF_ID     = V_PFAT_PEDF_ID;

         ELSE
           UPDATE PEDIDO_FAT SET
             PEDF_VLR_TOT_PED = ROUND(VALOR_TOT_PED,2),
             PEDF_ADC_FIN     = V_VALOR_TOTAL_ADC_FINANC,
             PEDF_VLR_DESC    = (V_VALOR_TOTAL_DESC_NOR),
             PEDF_IMP_LAYOUT        = V_OPER_PRC_FINAL
            ,PEDF_VLR_TOT_DESC_ESP_DUPL = V_DESC_DUPL
            ,PEDF_CLI_IND_IE_DEST = V_CLI_IND_IE_DEST
            ,PEDF_CLI_UF_DESTINO  = V_PEDF_CLI_UF_DESTINO
            ,PEDF_CONSUMIDOR_FINAL = DECODE(v_CONSUMIDOR_FINAL,1,'S','N')
           WHERE
             PEDF_EMP_ID = V_EMP_ATIVA AND
             PEDF_ID     = V_PFAT_PEDF_ID;
         END IF;


      END IF;
     ELSIF (V_PFAT_OPER_BASE_CALC_ICM = 'N') OR  (V_PFAT_OPER_BASE_CALC_ICM = 'S') THEN
      IF (V_ATU_NR_NF = 1)  THEN
       UPDATE PEDIDO_FAT SET
         PEDF_VLR_TOT_PED = ROUND(VALOR_TOT_PED,2),
         PEDF_ADC_FIN     = V_VALOR_TOTAL_ADC_FINANC,
         PEDF_NR_NF       = V_PFAT_PEDF_NR_NF,
         PEDF_SERIE_NF    = V_PFAT_SERIE_NF,
         PEDF_IMP_LAYOUT        = V_OPER_PRC_FINAL,
         PEDF_VLR_TOT_DESC_ESP_DUPL = V_DESC_DUPL
        ,PEDF_CLI_IND_IE_DEST = V_CLI_IND_IE_DEST
        ,PEDF_CLI_UF_DESTINO  = V_PEDF_CLI_UF_DESTINO
        ,PEDF_CONSUMIDOR_FINAL = DECODE(v_CONSUMIDOR_FINAL,1,'S','N')
       WHERE
         PEDF_EMP_ID = V_EMP_ATIVA AND
         PEDF_ID     = V_PFAT_PEDF_ID;
      ELSE
       UPDATE PEDIDO_FAT SET
         PEDF_VLR_TOT_PED = ROUND(VALOR_TOT_PED,2),
         PEDF_ADC_FIN     = V_VALOR_TOTAL_ADC_FINANC,
         PEDF_IMP_LAYOUT        = V_OPER_PRC_FINAL
         ,PEDF_VLR_TOT_DESC_ESP_DUPL = V_DESC_DUPL
         ,PEDF_CLI_IND_IE_DEST = V_CLI_IND_IE_DEST
       ,PEDF_CLI_UF_DESTINO  = V_PEDF_CLI_UF_DESTINO
       ,PEDF_CONSUMIDOR_FINAL = DECODE(v_CONSUMIDOR_FINAL,1,'S','N')
       WHERE
         PEDF_EMP_ID = V_EMP_ATIVA AND
         PEDF_ID     = V_PFAT_PEDF_ID;
      END IF;
     END IF;
  END Gravar_Pedido_Fat;

  PROCEDURE Verificar_Situacao_ICMSUBST AS
  V_VALOR_PEDIDO  REAL :=0;
  V_FLAG_DESC_ESP REAL := 0;
  BEGIN
    V_FLAG_DESC_ESP := Busca_Gener(945,151,1);

    IF V_FLAG_DESC_ESP = 0 THEN

      V_VALOR_PEDIDO := V_VALOR_TOTAL_PEDIDO + V_PFAT_PEDF_VLR_FRETE +
                        V_PFAT_PEDF_VLR_SEG  + V_PFAT_PEDF_VLR_DESP +
                        V_VALOR_TOTAL_SUBST  -
                       (V_VALOR_TOTAL_DESC_ESP + V_VALOR_TOTAL_DESC_NOR)- Calculo_Pedido_Fat$PK.Obter_Impostos
                        - Calculo_Pedido_Fat$PK.Valores_a_Deduzir;
    ELSE
      V_VALOR_PEDIDO := V_VALOR_TOTAL_PEDIDO + V_PFAT_PEDF_VLR_FRETE +
                        V_PFAT_PEDF_VLR_SEG  + V_PFAT_PEDF_VLR_DESP +
                        V_VALOR_TOTAL_SUBST  -
                       (V_VALOR_TOTAL_DESC_NOR)- Calculo_Pedido_Fat$PK.Obter_Impostos
                        - Calculo_Pedido_Fat$PK.Valores_a_Deduzir;

    END IF;



    IF (V_LIMINAR_SUBSTITUTO = 'S') AND
       (V_VALOR_PEDIDO <= V_VALOR_MINIMO_NF_SUBSTITUTO) THEN
      V_ISENTO_SUBSTITUTO := 'S';
    ELSE
      V_ISENTO_SUBSTITUTO := 'N';
    END IF;


    IF (V_ISENTO_SUBSTITUTO = 'S') THEN
      Calculo_Pedido_Fat$PK.Delete_Pedido_S;

      UPDATE PEDIDO_FAT_P
      SET PEDF_VLR_UNIT  = NVL(PEDF_VLR_UNIT,0)  +  (NVL(PEDF_VLR_SUBS,0) / NVL(PEDF_QTDE,0))
         ,PEDF_VLR_TOT   = ROUND(NVL(PEDF_VLR_TOT,0)   + NVL(PEDF_VLR_SUBS,0),2)
         ,PEDF_BASE_ICMS = NVL(PEDF_BASE_ICMS,0) + NVL(PEDF_VLR_SUBS,0)
         ,PEDF_VLR_ICMS  = (NVL(PEDF_BASE_ICMS,0) + NVL(PEDF_VLR_SUBS,0)) * ( NVL(PEDF_ALIQ_ICMS,0) / 100 )
         --,PEDF_VLR_RAT_FUNDO_POBREZA = ROUND(DECODE(v_CONSUMIDOR_FINAL,1,PEDF_BASE_ICMS, ROUND(PEDF_BASE_SUBS,2)) *(V_PERC_FUNDO_POBREZA_P/100),2)
        ,PEDF_VLR_RAT_FUNDO_POBREZA = (CASE  WHEN v_CONSUMIDOR_FINAL IN (0,2)--BASE ST PESSOA JURIDICA
                                     THEN
                                      DECODE(NVL(V_VALOR_ICM_SUBST,0),0,0,NVL(ROUND( PEDF_BASE_SUBS*(V_PERC_FUNDO_POBREZA_P/100),2),0))
                                     ELSE
                                       0
                                     END)
        ,PEDF_VLR_FUNDO_POBREZA_ICMS = (CASE  WHEN v_CONSUMIDOR_FINAL IN (1,2) --BASE ICMS CONSUMIDOR FINAL
                                     THEN
                                      DECODE(NVL(V_VALOR_ICM,0),0,0,NVL(ROUND(V_BASE_ICM_PRODUTO*(V_PERC_FUNDO_POBREZA_P/100),2),0))
                                     ELSE
                                       0
                                     END)
         ,PEDF_BASE_SUBS = 0
         ,PEDF_VLR_SUBS  = 0
         ,PEDF_VLR_DESC_ESP_DUPL = V_DESC_DUPL_P

      WHERE PEDF_PEDF_EMP_ID = V_EMP_ATIVA
        AND PEDF_PEDF_ID     = V_PFAT_PEDF_ID;

      UPDATE PEDIDO_FAT_I
      SET  (PEDF_VLR_ICM
           ,PEDF_BASE_ICM ) = (SELECT SUM(NVL(PEDF_VLR_ICMS,0))
                                     ,SUM(NVL(PEDF_BASE_ICMS,0))
                               FROM PEDIDO_FAT_P
                               WHERE PEDIDO_FAT_P.PEDF_PEDF_EMP_ID = V_EMP_ATIVA
                                 AND PEDIDO_FAT_P.PEDF_PEDF_ID     = V_PFAT_PEDF_ID
                                 AND PEDIDO_FAT_P.PEDF_PEDF_EMP_ID = PEDIDO_FAT_I.PEDF_PEDF_EMP_ID
                                 AND PEDIDO_FAT_P.PEDF_PEDF_ID     = PEDIDO_FAT_I.PEDF_PEDF_ID
                                 AND PEDIDO_FAT_P.PEDF_ALIQ_ICMS   = PEDIDO_FAT_I.PEDF_ALIQ_ICM
                               GROUP BY PEDF_ALIQ_ICM)
      WHERE  PEDIDO_FAT_I.PEDF_PEDF_EMP_ID = V_EMP_ATIVA
         AND PEDIDO_FAT_I.PEDF_PEDF_ID     = V_PFAT_PEDF_ID;
    END IF;
  END Verificar_Situacao_ICMSUBST;




  PROCEDURE Adicionar_Erro
            (LIQUID IN REAL,
             PEDID IN REAL,
             COD_ERRO IN INTEGER) IS
  BEGIN
       /*
         A VAIRAVEL DE ERRO CONTERA 02 CARACTERES COM O CODIGO DO ERRO E
         O RESTANTE SERA O CODIGO DO PEDIDO.
         0 = ERRO AO OBTER PARAMETRO DO SISTEMA GEN_TGEN_ID = 945 GEN_ID = 7
         1 = ERRO AO ABRIR O CURSOR CURSOR_PEDIDO_FAT
         2 = ERRO AO ABRIR O CURSOR CURSOR_PEDIDO_FAT_P
         3 = ERRO AO PASSAR VALORES NO FECH DO CURSOR CURSOR_PEDIDO_FAT
         4 = ERRO AO OBTER O NUMERO DA NOTA FISCAL
         5 = ERRO AO OBTER O NUMERO DA NOTA FISCAL
         6 =
         7 = ERRO AO ABRIR O CURSOR CURSOR_PEDIDO_FAT_BLOQ
         8 = ERRO AO GRAVAR O NUMERO DE DEVOLUC?O
         9 = ERRO AO APAGAR PEDIDO_FAT_S
         10 = ERRO AO APAGAR PEDIDO_FAT_I
         11 = ERRO AO OBTER PARAMETRO DO SISTEMA GEN_TGEN_ID = 941 GEIN_ID 9 OU 10
         12 = ERRO AO ABRIR O CURSOR CURSOR_PEDIDO_FAT_BLOQ
         13 = ERRO AO ABRIR O CURSOR CURSOR_PEDIDO_FAT_P_BLOQ
         14 = ERRO AO PASSAR VALORES NO FECH DO CURSOR CURSOR_PEDIDO_FAT_P
         15 = ERRO AO OBTER ALIQUOTA DE ICM Obter_Aliq_ICM
         16 = ERRO AO OBTER VALOR DE ICM Obter_Valor_ICM
         17 = ERRO AO OBTER BASE DE SUBSTITUTO Obter_Base_Subst
         18 = ERRO AO GRAVAR PEDIDO_FAT_S Gravar_Pedido_Fat_S
         19 = ERRO AO GRAVAR PEDIDO_FAT_I Gravar_Pedido_Fat_I
         20 = ERRO AO GRAVAR PEDIDO_FAT_I Gravar_Pedido_Fat_P
         21 = ERRO AO GRAVAR LIQUIDAC?O
         22 = ERRO AO [R ESTOQUE
         23 = ERRO NO LIVRO FISCAL
         24 = ERRO AO OBTER NR NF RETORNO
       */
       IF V_PFAT_PEDF_ID <> 0 THEN
         ERROS_PARCIAIS := LPAD(TO_CHAR(COD_ERRO),2,'0') || TO_CHAR(V_PFAT_PEDF_ID) ||CHR(13);
       ELSIF PEDID <> 0 THEN
         ERROS_PARCIAIS := LPAD(TO_CHAR(COD_ERRO),2,'0') || TO_CHAR(PEDID) ||CHR(13);
       END IF;
  END Adicionar_Erro;
PROCEDURE BuscarAliquotas
            (EMPRESA IN NUMBER,
             PRODUTO IN NUMBER,
             ESTADO IN NUMBER) IS
  BEGIN
  V_PAR_VDA_GEN_UF_ID  := NULL;
  V_PAR_VDA_UF_DESTINO := NULL;
  V_GATILHO_PER_MVA    :=0;
  V_PAR_VDA_ALIQ_ICMS  := 0;
  V_PAR_VDA_ALIQ_RED_ICMS := 0;
  V_PAR_VDA_ALIQ_ST       := 0;
  V_PFAT_P_TPRC_ICM_SUBST := 0;
  V_PFAT_P_TPRC_BASE_SUBST:= 0;
  V_PEDF_TPRC_MARGEM_LUCRO:= 0;
  v_TPRC_ALIQ_ST_MVA      := 0;
  v_TPRC_ALIQ_MVA         := 0;
  V_oper_aliq_st_ret      := NULL;
  V_OPER_ALIQ_ICM_DIF     := 0;
  V_OPER_ALIQ_RED_BC_ICM_OE := 0;
  V_PFAT_P_TPRC_ALIQ_ICM_SUBS :=0;
  V_DTA_ORIGEM_DEVOL   := NULL;

  BEGIN
    SELECT
         TRUNC(LIQUIDACAO.LIQU_DTA_EMIS)
    INTO
         V_DTA_ORIGEM_DEVOL
    FROM
         PEDIDO_FAT
        ,PEDIDO_FAT PED_DEVOL_ORIGEM
        ,LIQUIDACAO
    WHERE
         PEDIDO_FAT.PEDF_EMP_ID              = PED_DEVOL_ORIGEM.PEDF_EMP_ID(+)
    AND  PEDIDO_FAT.PEDF_ID_DEVOL            = PED_DEVOL_ORIGEM.PEDF_ID(+)
    --
    AND  PED_DEVOL_ORIGEM.PEDF_LIQU_EMP_ID   = LIQUIDACAO.LIQU_EMP_ID(+)
    AND  PED_DEVOL_ORIGEM.PEDF_LIQU_ID       = LIQUIDACAO.LIQU_ID(+)
    --
    AND  PEDIDO_FAT.PEDF_EMP_ID              = V_EMP_ATIVA
    AND  PEDIDO_FAT.PEDF_ID                  = V_PFAT_PEDF_ID;

    EXCEPTION
        WHEN OTHERS THEN
          V_DTA_ORIGEM_DEVOL := TRUNC(SYSDATE);
    END;

    IF V_DTA_ORIGEM_DEVOL IS NULL THEN
       V_DTA_ORIGEM_DEVOL := TRUNC(SYSDATE);
    END IF;

    FOR C IN (SELECT  PAR_VDA_GEN_UF_ID,
                      PAR_VDA_ALIQ_ICMS,
                      PAR_VDA_ALIQ_RED_ICMS,
                      PAR_VDA_ALIQ_ST,
                      PAR_VDA_BASE_ST,
                      PAR_VDA_VLR_ST,
                      PAR_VDA_ALIQ_ST_MVA,
                      PAR_VDA_ALIQ_MVA,
                      PAR_VDA_MARGEM_LUCRO_IVA,
                      PAR_VDA_UF_DESTINO,
                      PAR_VDA_RED_ST,
                      PAR_VDA_ALIQ_ICM_DIF,
                      PAR_VDA_ALIQ_RED_BC_ICM_OE,
                      PAR_PERC_GATILHO_MVA_PAUTA,
                      PAR_REGRA_CORTE_GATILHO,
                      TO_DATE(par_vda_data_vigencia,'DD/MM/RRRR') PAR_VDA_DATA_VIGENCIA


              FROM PARAM_VDA_OPERACAO  O

              WHERE
              (par_vda_emp_id,
              par_vda_prod_emp_id,
              par_vda_prod_id,
              par_vda_tgen_uf_id,
              par_vda_gen_uf_emp_id,
              PAR_VDA_GEN_UF_ID,
              par_vda_data_vigencia) IN (SELECT par_vda_emp_id,
                                          par_vda_prod_emp_id,
                                          par_vda_prod_id,
                                          par_vda_tgen_uf_id,
                                          par_vda_gen_uf_emp_id,
                                          PAR_VDA_GEN_UF_ID,
                                          MAX(par_vda_data_vigencia)

                                         FROM PARAM_VDA_OPERACAO

                                         WHERE  PAR_VDA_EMP_ID     = EMPRESA
                                           AND PAR_VDA_PROD_EMP_ID = EMPRESA
                                           AND PAR_VDA_PROD_ID     = PRODUTO
                                           AND PAR_VDA_TGEN_UF_ID  = 5006
                                           AND PAR_VDA_GEN_UF_EMP_ID = 0
                                           AND PAR_VDA_GEN_UF_ID     = ESTADO
                                           AND par_vda_data_vigencia <= V_DTA_ORIGEM_DEVOL --TRUNC(SYSDATE)
                                           GROUP BY
                                               par_vda_emp_id,
                                              par_vda_prod_emp_id,
                                              par_vda_prod_id,
                                              par_vda_tgen_uf_id,
                                              par_vda_gen_uf_emp_id,
                                              PAR_VDA_GEN_UF_ID)

              )
     LOOP

       V_PAR_VDA_UF_DESTINO       :=C.PAR_VDA_UF_DESTINO;
       V_PAR_VDA_ALIQ_ICMS        :=NVL(C.PAR_VDA_ALIQ_ICMS,0);
       V_PAR_VDA_ALIQ_RED_ICMS    :=NVL(C.PAR_VDA_ALIQ_RED_ICMS,0);
       V_PAR_VDA_ALIQ_ST          :=NVL(C.PAR_VDA_ALIQ_ST,0);
       V_PFAT_P_TPRC_ALIQ_ICM_SUBS := NVL(V_PAR_VDA_ALIQ_ST,0) ;
       /*00000VARIAVEL JÁ EXISTE */
       V_PFAT_P_TPRC_ICM_SUBST    :=NVL(C.PAR_VDA_VLR_ST,0);
       V_PFAT_P_TPRC_BASE_SUBST   :=NVL(C.PAR_VDA_BASE_ST,0);
       V_PEDF_TPRC_MARGEM_LUCRO   :=NVL(C.PAR_VDA_MARGEM_LUCRO_IVA,0);
       v_TPRC_ALIQ_ST_MVA         :=NVL(C.PAR_VDA_ALIQ_ST_MVA,0);
       v_TPRC_ALIQ_MVA            :=NVL(C.PAR_VDA_ALIQ_MVA,0);
       V_oper_aliq_st_ret         :=NVL(C.PAR_VDA_RED_ST,0);
       V_OPER_ALIQ_ICM_DIF        :=NVL(C.PAR_VDA_ALIQ_ICM_DIF,0);
       V_OPER_ALIQ_RED_BC_ICM_OE  :=NVL(C.PAR_VDA_ALIQ_RED_BC_ICM_OE,0);
       V_GATILHO_PER_MVA          :=NVL(C.PAR_PERC_GATILHO_MVA_PAUTA,0);
       v_REGRA_CORTE_GATILHO      :=NVL(C.PAR_REGRA_CORTE_GATILHO,0);
       v_PAR_VDA_DATA_VIGENCIA    :=C.PAR_VDA_DATA_VIGENCIA;
       V_PAR_VDA_GEN_UF_ID        :=C.PAR_VDA_GEN_UF_ID;
       /*0000000*/

    END LOOP;

  END BuscarAliquotas;

  FUNCTION GERAR_LIVROS_FISCAIS RETURN BOOLEAN IS
  BEGIN
    /*ATUAL_LIVROF_SAI$P (V_EMP_ATIVA,V_LIQUID, NULL,NULL,1);*/
    RETURN(TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(FALSE);
  END;

FUNCTION GERAR_CONTABILIDADE RETURN BOOLEAN IS
 DTA_LIQU DATE;
BEGIN


    IF V_SITUACAO = 0 THEN
      DTA_LIQU := V_DTA_EMIS;
     ELSE
       DTA_LIQU := V_DTA_LIB;
    END IF ;

  RETURN(TRUE);
   EXCEPTION
     WHEN OTHERS THEN
       RETURN(FALSE);
  END;
  FUNCTION OBTER_VLR_MIN_NF_SUBST(EMP_ATIVA IN INTEGER) RETURN REAL IS
  V_VALOR  REAL := 0;
  BEGIN
     SELECT NVL(GEN_NUMBER1,0) INTO V_VALOR
     FROM GENER
     WHERE GEN_TGEN_ID = 945
       AND GEN_EMP_ID  = EMP_ATIVA
       AND GEN_ID      = 29;
     RETURN(V_VALOR);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(V_VALOR);
  END;

  PROCEDURE Calculo_Pedido_Fat
            (EMP_ATIVA IN INTEGER,
             LIQUID IN REAL,
             PEDID IN REAL,
             COD_USUARIO IN REAL,
             SITUACAO IN INTEGER,
             GERA_NF IN INTEGER,
             ERROS OUT VARCHAR2) IS
  /*-ESTA VARIAVEL E O CODIGO DO ERRO CORRENTE */
  V_POS_ERRO          INTEGER     := 0;
  GRAVOU_PEDIDO_FAT   BOOLEAN     := FALSE;
  --V_FLAG_POS          INTEGER     := 0;
  V_LIQU_FLAG_RETORNO INTEGER     := 0;
  V_ERRO_ESTOQUE      VARCHAR2(1) := 'F';
  OBTEVE_NUMERO_NOTA  BOOLEAN     := FALSE;
  V_FLAG_941          BOOLEAN     := FALSE;
  V_DESCONTO_SUBST    REAL        := 0;
  BEGIN
     ERROS_PARCIAIS               := '0';
     RESULTADO                    := '';
     V_EMP_ATIVA                  := EMP_ATIVA;
     V_LIQUID                     := LIQUID;
     V_SITUACAO                   := SITUACAO;
     V_GERA_NF                    := GERA_NF;
     --V_FLAG_POS                   := 2;
     V_VALOR_MINIMO_NF_SUBSTITUTO := OBTER_VLR_MIN_NF_SUBST(EMP_ATIVA);
     IF (USA_DESCONTO_ATACADO = 1) THEN
       V_USA_DESCONTO_ATACADO := 'S';
     END IF;
     IF PEDID <> 0 THEN
        V_PEDID_INI := Pedid;
        V_PEDID_FIN := Pedid;
     ELSE
        V_PEDID_INI := 1;
        V_PEDID_FIN := 9999999;
     END IF;

     SELECT
        NVL(GEN_NUMBER2,0)
       ,NVL(GEN_NUMBER4,0)
       ,NVL(GEN_NUMBER5,0)
       ,NVL(GEN_NUMBER6,0)
     INTO
        V_SUBS_TAB
       ,V_RAT_DESC_CAPA
       ,V_USA_CALC_PIS_COFINS
       ,V_USA_CALC_ST_PF
     FROM
        GENER
     WHERE
        GEN_TGEN_ID =  945
     AND GEN_EMP_ID  =  V_EMP_ATIVA
     AND GEN_ID      =  29;


     V_POS_ERRO := 1;
     OPEN CURSOR_PEDIDO_FAT;

     V_POS_ERRO := 3;
     LOOP


     FETCH CURSOR_PEDIDO_FAT INTO   V_PFAT_PEDF_ID,
                                    V_PFAT_PEDF_NR_NF,
                                    V_PFAT_PEDF_VLR_FRETE,
                                    V_PFAT_PEDF_VLR_DESC,
                                    V_PFAT_PEDF_VLR_DESP,
                                    V_PFAT_PEDF_VLR_SEG,
                                    V_PFAT_OPER_DESTINO_OPER,
                                    V_PFAT_OPER_ALIQ_ICM_FABR,
                                    V_PFAT_OPER_ALIQ_RED_BC_ICM,
                                    V_PFAT_OPER_TIPO_IPI,
                                    V_PFAT_OPER_TIPO_ICM,
                                    V_PFAT_OPER_TIPO_ICMR,
                                    V_PFAT_OPER_ALIQ_ICM_PROD,
                                    V_PFAT_OPER_GEN_ID_TP_OPER,
                                    V_OPER_IMPORTACAO,
                                    V_PFAT_GEN_ID_CIDADE_DE,
                                    V_PFAT_ADC_FIN_GEN_NUMBER1,
                                    V_VLR_TOT_MERCADORIA,
                                    V_PFAT_CVTO_P_MAX_DIAS,
                                    V_PFAT_CVTO_EMP_ID,
                                    V_PFAT_CVTO_ID,
                                    V_PFAT_LIQU_TIPO,
                                    V_PFAT_PEDF_CLI_ID,
                                    V_PFAT_OPER_BASE_CALC_ICM,
                                    V_LIMINAR_SUBSTITUTO,
                                    V_ROTA_PEDIDO,
                                    V_TIPO_PESSOA,
                                    V_PEDF_FLAG_SEGURO,
                                    V_PEDF_FLAG_DESP_ICMS,
                                    V_PFAT_TOT_DESC,
                                    V_TOT_MERC_SELO,
                                    V_OPER_PRC_FINAL,
                                    V_OPER_ID,
                                    V_CLI_CONTRIB,
                                    V_OPER_TIPO_REDUCAO,
                                    V_UF_CLIENTE,
                                    V_UF_EMPRESA,
                                    V_OPER_ALIQ_RED_BC_ICM_OE,
                                    V_PERC_FUNDO_POBREZA,
                                    V_PEDF_FLAG_FRETE,
                                    V_PEDF_VLR_FRETE_ESP,
                                    V_PESO_TOTAL,
                                    V_OPER_SUFRAMA,
                                    V_DESC_DUPL,
                                    V_PEDF_PROCED,
                                    V_PFAT_PEDF_TIPO_PED,
                                    V_OPER_NAO_RED_BASE_ST_IVA,
                                    V_CLI_SIMPLES_NACIONAL,
                                    V_OPer_st_diferenciado_AL,
                                    V_VLR_TOT_PRC_FAB,
                                    V_VLR_TOT_PRC_FINAL,
                                    V_EMP_REGIME_TRIBUTARIO,
                                    V_PEDF_INSCRICAO_ESTADUAL,
                                    V_EMP_UTILIZA_IE_PEDIDO,
                                    V_SERIE_NF_PEDIDO_FAT,
                                    v_OPER_DIF_CRED_IPI,
                                    v_OPER_DIF_RED_BC_ICM,
                                    V_DTA_LIB,
                                    v_dta_emis,
                                    V_PEDF_SERIE_NFCE,
                                    V_CLI_QUALIFICACAO,
                                    V_EMP_PARTICIPA_LEI_13097,
                                    v_oper_ipi_base_st,
                                    V_ALIQ_ICMS_UF_DEST,
                                    V_CLI_IND_IE_DEST,
                                    V_ALIQ_FUNDO_POBREZA_DIFAL,
                                    V_ALIQ_ICMS_UF_DEST_2,
                                    V_OPER_INSCR_ESTADUAL,
                                    v_CLI_ST_REGIME_CNAE,
                                    V_CLI_ALIQ_CNAE,
                                    V_OPER_FIXA_REGRA_TAB_ALIQ,
                                    V_OPER_ALIQ_RED_ST_DES;


       EXIT WHEN CURSOR_PEDIDO_FAT%NOTFOUND;
       /*INICIO ATRIBUINDO 0 PARA VARIAVEIS GLOBAIS POR PEDIDO*/
       V_USAR_FDP_FORA_EST := Busca_Gener(945,211,3);
       V_USAR_CALC_ST_DIFAL := Busca_Gener(945,211,4);
       V_DEDUZ_ICMS_BASE_PIS := Busca_Gener(945,132,2);
       V_USAR_PRECO_FINAL    := Busca_Gener(945,211,5);
       V_DESCONTO_DESONERADO := Busca_Gener(945,221,1);

       V_USAR_REGRA_COM_PVV      := Busca_Gener(945,211,2);

       V_PEDF_CLI_UF_DESTINO :='N';
       if (V_UF_EMPRESA <> V_UF_CLIENTE) and (V_PFAT_OPER_DESTINO_OPER = 2) AND(V_CLI_IND_IE_DEST = 9) Then
           V_ALIQ_DIFAL        :=AliqDIFAL;
           V_PEDF_CLI_UF_DESTINO :='S';
          ELSE
            IF (V_USAR_CALC_ST_DIFAL = 0)  AND(V_CLI_IND_IE_DEST = 9) THEN
              V_ALIQ_ICMS_UF_DEST := 0;
            END IF;
       end if;
       if V_PESO_TOTAL > 0 then
         V_FRETE_ITEM_SABAO_OESTE := (V_PEDF_VLR_FRETE_ESP / V_PESO_TOTAL);
       End If ;
       GRAVOU_PEDIDO_FAT   := FALSE;
       V_VLR_TOT_MERCADORIA :=  V_VLR_TOT_MERCADORIA + Obter_Valor_ADF_FINAC ;

       IF  V_PEDF_FLAG_SEGURO = 0  THEN
           V_PFAT_PEDF_VLR_SEG := Obter_Base_Seguro;
       END IF ;
       V_VALOR_MERCADORIA       := 0;
       V_VALOR_ISENTO_ICM       := 0;
       V_ALIQ_ICM               := 0;
       V_VALOR_ICM              := 0;
       V_VALOR_RED_ICM          := 0;
       V_VALOR_ISENTO_ICM       := 0;
       V_VALOR_ICM_SUBST        := 0;
       V_ALIQ_SUBST             := 0;
       V_BASE_SUBST             := 0;
       V_VALOR_TOTAL_PEDIDO     := 0;
       V_VALOR_TOTAL_DESC_NOR   := 0;
       V_VALOR_TOTAL_DESC_ESP   := 0;
       V_DESCONTO_NOR_ITEM      := 0;
       V_DESCONTO_ESP_ITEM      := 0;
       V_VALOR_TOTAL_ADC_FINANC := 0;
       V_VALOR_TOTAL_SUBST      := 0;
       ERROS_PARCIAIS := '0';
       v_CONSUMIDOR_FINAL := 0;
       V_SOMA_FRETE_RED  :=  Busca_Gener(945,183,2);
       IF V_CLI_SIMPLES_NACIONAL = 'S' THEN
          V_REDUZ_ST_SIMPLES_NAC :=  Busca_Gener(945,183,1);
  ELSE
     V_REDUZ_ST_SIMPLES_NAC := 0;

  END IF;

        V_ZERA_BASE_ST :=  Busca_Gener(945,183,4);


       /*FIM ATRIBUINDO 0 PARA VARIAVEIS GLOBAIS POR PEDIDO*/
       V_VAL_FRETE_ICMS := OBTER_VAL_FRETE_ICMS(V_EMP_ATIVA);
       V_VAL_FRETE_IPI  := Busca_Gener(945,215,1);
       V_POS_ERRO := 4;

       IF (V_PFAT_PEDF_NR_NF IS NULL) AND (V_PFAT_OPER_GEN_ID_TP_OPER <> 3) THEN
          V_PFAT_PEDF_NR_NF   := Prox_Nr_NF(1);

          IF (V_USA_DESCONTO_ATACADO = 'S') THEN
            V_DESCONTO_EMPRESA  := BUSCAR_DESCONTO_ATACADO(V_PFAT_LIQU_TIPO, V_ROTA_PEDIDO, V_PFAT_CVTO_ID, V_PFAT_PEDF_CLI_ID);
          ELSE
            V_DESCONTO_EMPRESA  := 0;
          END IF;
          IF V_PFAT_PEDF_NR_NF = 0 THEN
            OBTEVE_NUMERO_NOTA := FALSE;
            V_POS_ERRO := 5;
            Adicionar_Erro(LIQUID,V_PFAT_PEDF_ID,V_POS_ERRO);
          ELSE
            OBTEVE_NUMERO_NOTA     := TRUE;
            ERROS_PARCIAIS         := '0';
          END IF;
         V_ATU_NR_NF := 1;
       END IF;

       IF (V_PFAT_PEDF_NR_NF IS NULL) AND (V_PFAT_OPER_GEN_ID_TP_OPER = 3) THEN
          V_PFAT_PEDF_NR_NF   := Prox_Nr_NF(2);

          IF (V_USA_DESCONTO_ATACADO = 'S') THEN
            V_DESCONTO_EMPRESA  := BUSCAR_DESCONTO_ATACADO(V_PFAT_LIQU_TIPO, V_ROTA_PEDIDO, V_PFAT_CVTO_ID, V_PFAT_PEDF_CLI_ID);
          ELSE
            V_DESCONTO_EMPRESA  := 0;
          END IF;
          IF V_PFAT_PEDF_NR_NF = 0 THEN
             OBTEVE_NUMERO_NOTA := FALSE;
             V_POS_ERRO := 5;
             Adicionar_Erro(LIQUID,V_PFAT_PEDF_ID,V_POS_ERRO);
          ELSE
            IF (V_PEDF_PROCED in (4,5)) Or (V_OPER_IMPORTACAO = 'S') THEN
               UPDATE PEDIDO_FAT SET
                PEDF_NR_NF    = V_PFAT_PEDF_NR_NF,
               PEDF_SERIE_NF = V_PFAT_SERIE_NF

               WHERE
                 PEDF_EMP_ID = V_EMP_ATIVA AND
                 PEDF_ID     = V_PFAT_PEDF_ID;
               END IF;
            OBTEVE_NUMERO_NOTA     := TRUE;
            ERROS_PARCIAIS         := '0';
          END IF;
         V_ATU_NR_NF := 1;
       END IF;
       IF (V_PEDF_PROCED = 5 ) THEN --USADO PARA PROCED PEDIDOS EXPORTAÇÃO BRASIMPORT
           UPDATE PEDIDO_FAT SET    -- essa procedencia nao deve mexe nos valores somete
            PEDF_NR_NF    = V_PFAT_PEDF_NR_NF, --atualizar o estoque e gerar nr de nota
            PEDF_SERIE_NF = V_PFAT_SERIE_NF
           WHERE
              PEDF_EMP_ID = V_EMP_ATIVA AND
              PEDF_ID     = V_PFAT_PEDF_ID;

               IF V_GERA_NF = 1 THEN
               MOVIMENTACAO_EST$P(0, -- operacao
                                  0, -- tipo
                                  V_EMP_ATIVA,
                                  TO_CHAR(V_LIQUID),
                                  COD_USUARIO,
                                  V_ERRO_ESTOQUE,
                                  V_PFAT_PEDF_ID);
                END IF;

              IF V_ERRO_ESTOQUE <> 'F' THEN
                 Adicionar_Erro(LIQUID,V_PFAT_PEDF_ID,V_POS_ERRO);
                 ERROS_PARCIAIS := 0;
              END IF;




          END IF;

       IF (V_PFAT_PEDF_NR_NF IS NOT NULL) AND (V_PFAT_OPER_GEN_ID_TP_OPER = 11) THEN
          V_PFAT_PEDF_NR_NF   := Prox_Nr_NF(2);
          UPDATE PEDIDO_FAT SET
                PEDF_NR_NF_DEV    = V_PFAT_PEDF_NR_NF,
                PEDF_SERIE_NF_DEV = V_PFAT_SERIE_NF
                ,PEDF_VLR_TOT_DESC_ESP_DUPL = V_DESC_DUPL
             WHERE
               PEDF_EMP_ID = V_EMP_ATIVA AND
               PEDF_ID     = V_PFAT_PEDF_ID;
             COMMIT WORK;

          IF (V_USA_DESCONTO_ATACADO = 'S') THEN
            V_DESCONTO_EMPRESA  := BUSCAR_DESCONTO_ATACADO(V_PFAT_LIQU_TIPO, V_ROTA_PEDIDO, V_PFAT_CVTO_ID, V_PFAT_PEDF_CLI_ID);
          ELSE
            V_DESCONTO_EMPRESA  := 0;
          END IF;
          IF V_PFAT_PEDF_NR_NF = 0 THEN
             OBTEVE_NUMERO_NOTA := FALSE;
             V_POS_ERRO := 5;
             Adicionar_Erro(LIQUID,V_PFAT_PEDF_ID,V_POS_ERRO);
          ELSE
            OBTEVE_NUMERO_NOTA     := TRUE;
            ERROS_PARCIAIS         := '0';
          END IF;
          V_ATU_NR_NF := 0;
       END IF;

       IF (OBTEVE_NUMERO_NOTA = FALSE) AND
          (V_SITUACAO         = 2)     AND
          (ERROS_PARCIAIS     = '0') THEN
          V_POS_ERRO := 7;
          IF BLOQUEAR_REGISTROS(1) = TRUE THEN
             V_POS_ERRO := 24;
             V_PFAT_PEDF_NR_NF      := Calculo_Pedido_Fat$PK.Prox_Nr_NF(2);
             V_POS_ERRO := 8;

             v_SERIE_DEVOLUCAO  := Obter_Serie_Devolucao;

             UPDATE PEDIDO_FAT SET
                PEDF_NR_NF_DEV    = V_PFAT_PEDF_NR_NF,
                PEDF_SERIE_NF_DEV = DECODE(v_SERIE_DEVOLUCAO,'', V_PFAT_SERIE_NF,v_SERIE_DEVOLUCAO),
                PEDF_VLR_TOT_DESC_ESP_DUPL = V_DESC_DUPL
             WHERE
               PEDF_EMP_ID = V_EMP_ATIVA AND
               PEDF_ID     = V_PFAT_PEDF_ID;
             COMMIT WORK;
          ELSE
             Adicionar_Erro(LIQUID,V_PFAT_PEDF_ID,V_POS_ERRO);
          END IF;
          IF CURSOR_PEDIDO_FAT_BLOQ%ISOPEN THEN
             CLOSE CURSOR_PEDIDO_FAT_BLOQ;
          END IF;
       END IF;

       IF (OBTEVE_NUMERO_NOTA = TRUE) AND
          (ERROS_PARCIAIS     = '0')  AND
          ( V_PEDF_PROCED not in (4,5))AND
          (V_OPER_IMPORTACAO = 'N')

          THEN
         V_POS_ERRO := 2;
         OPEN CURSOR_PEDIDO_FAT_P;
         V_POS_ERRO := 12;
         IF (BLOQUEAR_REGISTROS(1) = TRUE) AND
            (BLOQUEAR_REGISTROS(2) = TRUE) THEN
            V_POS_ERRO := 9;
            Calculo_Pedido_Fat$PK.Delete_Pedido_S;
            V_POS_ERRO := 10;
            Calculo_Pedido_Fat$PK.Delete_Pedido_I;
            V_POS_ERRO := 11;
            V_FLAG_941  := Calculo_Pedido_Fat$PK.Busca_Param_941;
            V_ERRO_ESTOQUE := 'F';
            V_POS_ERRO := 14;
            V_TOT_ITENS_ISENTOS := 0;
            V_TOT_ITENS_ISENTOS_PIS := 0;

            LOOP
               FETCH CURSOR_PEDIDO_FAT_P INTO
                 V_PFAT_P_PEDF_PEDF_ID,
                 V_PFAT_P_PEDF_ID,
                 V_PFAT_P_PEDF_PROD_ID,
                 V_PFAT_P_PEDF_QTDE,
                 V_PFAT_P_PEDF_PERC_DESC,
                 V_PFAT_P_TPRC_BASE_SUBST,
                 V_BASE_SUBST_NORMAL,
                 V_PFAT_P_TPRC_ICM_SUBST,
                 V_PFAT_P_TPRC_PRC_FAB,
                 V_PFAT_P_TPRC_PRC_FAB_MEC,
                 V_PFAT_P_TPRC_PRC_FINAL,
                 V_PFAT_P_TPRC_PRC_FRETE,
                 V_PFAT_P_TPRC_PRC_ADCFIN,
                 V_PFAT_P_PROF_ALIQ_ICM,
                 V_PFAT_P_CONTROLE_ISENTO,
                 V_PFAT_P_PROF_RETEM_PIS,
                 V_PFAT_P_PROF_RETEM_COFINS,
                 V_PFAT_P_PROF_VLR_IPI,
                 V_PFAT_P_PROF_ALIQ_IPI,
                 V_PFAT_P_PROF_COD_ICM,
                 V_PFAT_P_PROC_NAO_RET,
                 V_PFAT_P_TPRC_DESCONTO,
                 V_PFAT_P_PROF_ALIQ_ICM_RED,
                 V_PFAT_P_TPRC_EMP_ID,
                 V_PFAT_P_TPRC_GEN_TGEN_ID,
                 V_PFAT_P_TPRC_GEN_EMP_ID,
                 V_PFAT_P_TPRC_GEN_ID,
                 V_PFAT_P_TPRC_PROD_EMP_ID,
                 V_PFAT_P_TPRC_PROD_ID,
                 V_PFAT_P_TPRC_DTA_VIGENCIA,
                 V_PFAT_P_TPRC_ALIQ_ICM_SUBS,
                 V_PFAT_P_PROM_CVTO_ID,
                 V_FATOR_CX_PRODUTO,
                 V_DESCONTO_ATACADO_PRODUTO,
                 V_PFAT_P_PROC_LITRAGEM,
                 V_PFAT_P_VLR_PIS,
                 V_PFAT_P_VLR_COFINS,
                 V_PFAT_P_VLR_CSL,
                 V_PFAT_P_FLAG_SELO,
                 V_SEG_ADICIONAL,
                 V_PEDF_PERC_DESC_ORIGINAL,
                 V_PEDF_TPRC_MARGEM_LUCRO,
                 V_OPER_TIPO_REDUCAO,
                 V_PROF_REDUCAO_OE,
                 V_PROC_CESTA_BASICA,
                 V_PRECO_FRETE,
                 V_PROF_PESO_B,
                 V_PROF_ALIQ_IPI_DIFERENCIADA,
                 V_DESC_DUPL_P,
                 V_PROF_REDUZIR_BC_SIMPLES_NAC,
                 V_CST_PIS_COFINS_OP,
                 v_TPRC_ALIQ_MVA,
                 v_TPRC_ALIQ_ST_MVA,
                 V_VLR_DESC_PFINAL,
                 V_VLR_DESC_PFAB,
                 v_NBM,
                 V_PROD_SOMA_FRETE_IPI,
                 V_PROF_LEI_13097,
                 V_PROF_ALIQ_DEST_EX,
                 v_PROF_PARAM_ALIQ_VDA,
                 V_TPRC_ALQ_ST_DIF,
                 V_PAR_FECOP_ICMS,
                 V_PRIMEIRO_NR;
              EXIT WHEN CURSOR_PEDIDO_FAT_P%NOTFOUND;
        v_SOMA_FPOBRE := 0;
        if  (V_PROF_ALIQ_DEST_EX = 'S') and (V_PEDF_CLI_UF_DESTINO = 'S')
            and (V_ALIQ_ICMS_UF_DEST_2 > 0)
            AND(V_CLI_IND_IE_DEST = 9)
         then
            V_ALIQ_ICMS_UF_DEST := V_ALIQ_ICMS_UF_DEST_2;
        end if;

        V_USAR_REGRA_PAR_ALIQUOTA := Busca_Gener(945,211,1);

        IF V_OPER_FIXA_REGRA_TAB_ALIQ = 'S' THEN
           V_USAR_REGRA_PAR_ALIQUOTA := 1;
        END IF;

        IF  V_USAR_REGRA_PAR_ALIQUOTA = '1' THEN
           if v_PROF_PARAM_ALIQ_VDA = 'N' Then
              V_USAR_REGRA_PAR_ALIQUOTA := 0;

           End  if;
        END IF;



        V_PASSO_PELA_REGRA_13097 := FALSE;
        V_oper_aliq_st_ret :=NULL;
        IF V_USAR_REGRA_PAR_ALIQUOTA =  1 THEN
           BuscarAliquotas(V_EMP_ATIVA,V_PFAT_P_PEDF_PROD_ID,V_UF_CLIENTE);
        ELSE
           V_oper_aliq_st_ret :=  Obter_Aliq_Red_ST(V_OPER_ID,V_PFAT_P_PEDF_PROD_ID);
           V_OPER_ALIQ_ICM_DIF := Obter_Aliq_ICM_Diferenciada (V_OPER_ID,V_PFAT_P_PEDF_PROD_ID,1);
           V_OPER_ALIQ_ICM_DIF_F_ESTADO := Obter_Aliq_ICM_Diferenciada (V_OPER_ID,V_PFAT_P_PEDF_PROD_ID,2);
        END IF;


          IF (((V_TIPO_PESSOA = 1) OR (NVL(V_CLI_CONTRIB,'S') = 'N')) and (Busca_Gener(945,200,2) = 0))  THEN
            v_CONSUMIDOR_FINAL := 1;--VALOR SOBRE ICMS CONSUMIDOR FINAL
          ELSE
            v_CONSUMIDOR_FINAL := 0;-- VALOR SOBRE BASE ST
         END IF;

        if (V_PAR_FECOP_ICMS = 'S') and (V_UF_EMPRESA = V_UF_CLIENTE) then
            v_CONSUMIDOR_FINAL := 2;-- FCP SOBRE A BASE ICMS E ST
        end if;
        V_PERC_FUNDO_POBREZA_DIF := Obter_ALIQ_EXCECAO_CALC_FCP(V_OPER_ID,V_PFAT_P_PEDF_PROD_ID);
        if (V_PERC_FUNDO_POBREZA > 0 ) and (V_PERC_FUNDO_POBREZA_DIF > 0) THEN
          V_PERC_FUNDO_POBREZA := V_PERC_FUNDO_POBREZA_DIF;
        END IF;


        IF (V_PFAT_OPER_DESTINO_OPER = 1) OR (V_USAR_FDP_FORA_EST = 1 AND v_CONSUMIDOR_FINAL in (0,2) ) THEN
           V_PERC_FUNDO_POBREZA_P := V_PERC_FUNDO_POBREZA;
        ELSE
           V_PERC_FUNDO_POBREZA_P :=0;
           V_PERC_FUNDO_POBREZA   :=0;
        END IF;

        --IF NVL(V_PERC_FUNDO_POBREZA,0) > 0 THEN
          SELECT  NVL(P.PROD_FUNDO_POBREZA,'S')
             INTO  V_PROD_FUNDO_POBREZA
           FROM   PRODUTO P
            WHERE  P.PROD_EMP_ID      = V_EMP_ATIVA
              AND  P.PROD_ID          = V_PFAT_P_PEDF_PROD_ID;
          IF (V_PROD_FUNDO_POBREZA = 'N') OR (Obter_EXCECAO_CALC_FCP(V_OPER_ID,V_PFAT_P_PEDF_PROD_ID)='N') THEN
             V_PERC_FUNDO_POBREZA_P := 0;
             V_ALIQ_FUNDO_POBREZA_DIFAL := 0;
          END IF ;
       -- END IF ;
          if (v_CONSUMIDOR_FINAL IN (0,2)) and (NVL(V_PFAT_P_TPRC_ALIQ_ICM_SUBS,0) > 0) and(V_USAR_REGRA_PAR_ALIQUOTA =0) then
             V_PFAT_P_TPRC_ALIQ_ICM_SUBS := NVL(V_PFAT_P_TPRC_ALIQ_ICM_SUBS,0) + V_PERC_FUNDO_POBREZA_P;
             v_SOMA_FPOBRE := 1;
          end if;

             if V_USA_CALC_ST_PF = 1 Then
                If (V_TIPO_PESSOA = 1) OR (V_CLI_CONTRIB = 'N') Then
                   V_PFAT_P_TPRC_BASE_SUBST := 0;
                   V_BASE_SUBST_NORMAL      := 0;
                   V_PFAT_P_TPRC_ICM_SUBST  := 0;
                   V_PEDF_TPRC_MARGEM_LUCRO := 0;

                End if;
             end if;

             V_CST_PIS_COFINS    := ObterCst_PisCofins (V_OPER_ID,V_PFAT_P_PEDF_PROD_ID);
             IF V_CST_PIS_COFINS IS NULL THEN
                V_CST_PIS_COFINS := V_CST_PIS_COFINS_OP ;

             END IF;

            /* IF (V_CLI_QUALIFICACAO > 0) AND (V_PROF_LEI_13097 = 'S') AND (V_EMP_PARTICIPA_LEI_13097 = 'S')THEN
                --V_BASE_PVV_MIN := (V_PFAT_P_TPRC_PRC_FAB_MEC - (V_PFAT_P_TPRC_PRC_FAB_MEC * V_PFAT_P_PEDF_PERC_DESC / 100));
                V_BASE_PVV_MIN := Obter_Vlr_Mercadoria_Lei13097;
                Busca_prod_lei_13097_item(V_PFAT_P_PEDF_PROD_ID,V_CLI_QUALIFICACAO,V_BASE_PVV_MIN);
             END IF ;*/


             IF V_OPER_PRC_FINAL = 'S' THEN
                 V_DESC_DCY :=  ROUND((V_PFAT_P_TPRC_PRC_FINAL - V_PFAT_P_TPRC_ICM_SUBST) - (V_PFAT_P_TPRC_PRC_FINAL * NVL(V_PFAT_P_PEDF_PERC_DESC,0) /100),2);
                 V_LOC_VLR_UNIT_LIQ_DCY := (V_DESC_DCY * 100)/(100 + NVL(V_PFAT_P_PROF_ALIQ_IPI,0));
              END IF;

              /*  SE A OPERAC?O DE FATURAMENTO FOR ESPECIAL DESCONTO SUBST. ENT?O O DESC. TABELA DE PRECO  */
              /*  DEVE SER REDUZIDO DO PRECO DE FABRICA   */
              IF V_PFAT_OPER_BASE_CALC_ICM = 'S' THEN
                V_DESCONTO_SUBST          := (V_PFAT_P_TPRC_DESCONTO * 100) / V_PFAT_P_TPRC_PRC_FAB;
                V_DESCONTO_SUBST          := V_PFAT_P_TPRC_BASE_SUBST * ((V_DESCONTO_SUBST + V_PFAT_P_PEDF_PERC_DESC)/100);
                V_PFAT_P_TPRC_BASE_SUBST  := V_PFAT_P_TPRC_BASE_SUBST - V_DESCONTO_SUBST;
                V_PFAT_P_TPRC_PRC_FAB     := V_PFAT_P_TPRC_PRC_FAB - V_PFAT_P_TPRC_DESCONTO;
              END IF;

              IF (V_RAT_DESC_CAPA = 1) AND (V_SUBS_TAB = 1) and (V_PFAT_PEDF_VLR_DESC > 0) THEN
                 Converte_Vlr_Desc_Capa_Em_Per;
              END IF;



              V_VLR_FRETE_RATEIO := RATIAR_VALOR(V_VLR_TOT_PRC_FAB    - V_TOT_MERC_SELO,V_PFAT_PEDF_VLR_FRETE, (V_PFAT_P_TPRC_PRC_FAB_MEC * V_PFAT_P_PEDF_QTDE)-V_TOT_MERC_SELO);
              IF V_VAL_FRETE_IPI = 1 THEN
                 V_PRECO_FRETE_IPI  := V_VLR_FRETE_RATEIO;
                ELSE
                  V_PRECO_FRETE_IPI  := 0;
              END IF;

              IF V_VAL_FRETE_ICMS = 0 THEN
                IF V_PEDF_FLAG_FRETE <> 0 THEN  --FRAZER O RATEIO DO FRETE INFOMADO NO PEDIDO PARA COMPOR A BASE ICMS NAO JOGA MAIS NO 1º ITEM
                                                  --QTO   V_PEDF_FLAG_FRETE = 0 JÁ VEM RATIADO DO CURSO PEDIDO_FAT_P
                     V_PRECO_FRETE :=  RATIAR_VALOR(V_VLR_TOT_PRC_FAB    - V_TOT_MERC_SELO,V_PFAT_PEDF_VLR_FRETE, (V_PFAT_P_TPRC_PRC_FAB_MEC * V_PFAT_P_PEDF_QTDE)-V_TOT_MERC_SELO);
                ELSE
                    IF (V_PEDF_FLAG_FRETE = 0)  THEN
                       V_VLR_FRETE_RATEIO := V_PRECO_FRETE;
                    END IF;
                END IF;

             ELSE -- NAO AGREGAR O FRETE NA BASE DE CALCULO DO  ICMS
              V_VALOR_FRETE_MANUAL := 0;
              V_PRECO_FRETE        := 0;
             END IF;
              V_ALIQ_ICM         := Calculo_Pedido_Fat$PK.Obter_Aliq_ICM;

              IF (V_ALIQ_ICM > 0) AND (v_CONSUMIDOR_FINAL IN (1,2)) THEN
                 V_ALIQ_ICM := V_ALIQ_ICM + V_PERC_FUNDO_POBREZA_P;
              END IF;

              IF (V_PFAT_OPER_DESTINO_OPER = 1) and (Busca_Gener(945,200,1) = 0) THEN
                 IF (v_CONSUMIDOR_FINAL IN (0,2)) AND (NVL(V_PERC_FUNDO_POBREZA_P,0)> 0) THEN
                    V_ALIQ_SUBST := V_ALIQ_ICM + V_PERC_FUNDO_POBREZA_P;
                  ELSE
                   V_ALIQ_SUBST := V_ALIQ_ICM;
                 END IF;
              ELSE
                 V_ALIQ_SUBST := Obter_Aliq_ICM_SUBST;
                 --SOMA O % DO FUNDO DE  POBREZA  NA ALIQ DO ST, SEGUINDO ANALISE GLAUDINEI MISSIATO


                 IF V_ALIQ_SUBST < 0 THEN
                   IF V_PFAT_P_TPRC_ALIQ_ICM_SUBS <> 0 THEN
                     V_ALIQ_SUBST := V_PFAT_P_TPRC_ALIQ_ICM_SUBS;
                   ELSE
                     V_ALIQ_SUBST := V_ALIQ_ICM;
                   END IF;
                 END IF;
              END IF;

             IF V_USAR_REGRA_PAR_ALIQUOTA =  1 THEN
                V_ALIQ_SUBST := V_PAR_VDA_ALIQ_ST;
             END IF;
              IF (V_CLI_ALIQ_CNAE > 0) and ( v_CLI_ST_REGIME_CNAE = 'S') and (V_PFAT_OPER_DESTINO_OPER = 2) THEN
                  V_ALIQ_SUBST :=V_CLI_ALIQ_CNAE;
              END IF;

              IF (V_ALIQ_SUBST > 0) and (v_CONSUMIDOR_FINAL IN (0,2))AND(v_SOMA_FPOBRE = 0) THEN
                  V_ALIQ_SUBST := V_ALIQ_SUBST + V_PERC_FUNDO_POBREZA_P;
                  V_PFAT_P_TPRC_ALIQ_ICM_SUBS := V_ALIQ_SUBST;
              END IF ;

--------------
--TESTAR AQUI SOMENTE QUANDO DEVOLUCAO, REFERENCIADA A UMA NOTA DE SAIDA
--
              BEGIN
               SELECT
                     PED_DEVOL_ORIGEM.PEDF_ALIQ_SUBS
                INTO
                     V_ALIQ_SUBST
                FROM
                     PEDIDO_FAT
                    ,PEDIDO_FAT_P PED_DEVOL_ORIGEM
                WHERE
                     PEDIDO_FAT.PEDF_EMP_ID              = PED_DEVOL_ORIGEM.PEDF_PEDF_EMP_ID
                AND  PEDIDO_FAT.PEDF_ID_DEVOL            = PED_DEVOL_ORIGEM.PEDF_PEDF_ID
                AND  PED_DEVOL_ORIGEM.PEDF_PROD_ID       = V_PFAT_P_PEDF_PROD_ID
                --
                AND  PEDIDO_FAT.PEDF_EMP_ID              = V_EMP_ATIVA
                AND  PEDIDO_FAT.PEDF_ID                  = V_PFAT_PEDF_ID;
              EXCEPTION
                 WHEN OTHERS THEN
                   V_ALIQ_SUBST := V_ALIQ_SUBST;
              END;
--FIM


              IF (V_CLI_QUALIFICACAO > 0) AND (V_PROF_LEI_13097 = 'S') AND (V_EMP_PARTICIPA_LEI_13097 = 'S')THEN
                --V_BASE_PVV_MIN := (V_PFAT_P_TPRC_PRC_FAB_MEC - (V_PFAT_P_TPRC_PRC_FAB_MEC * V_PFAT_P_PEDF_PERC_DESC / 100));
                V_PFAT_P_PROF_VLR_IPI := 0;
                V_PFAT_P_PROF_ALIQ_IPI := 0;
                V_BASE_PVV_MIN := Obter_Vlr_Mercadoria_Lei13097;
                Busca_prod_lei_13097_item(V_PFAT_P_PEDF_PROD_ID,V_CLI_QUALIFICACAO,(V_BASE_PVV_MIN/V_PFAT_P_PEDF_QTDE),0);
               END IF ;

               --QTO A OPERAÇÃO PRODUTO CFO ESTIVE MARCADA PARA NAO TRIBUTAR IPI
               IF Obter_parametro_tributa_ipi(V_OPER_ID,V_PFAT_P_PEDF_PROD_ID) = 'N' THEN
                 V_PFAT_P_PROF_VLR_IPI   := 0;
                 V_PFAT_P_PROF_ALIQ_IPI  := 0;
               END IF;


             V_AGREGA_IPI_FIS     :=  Busca_Param_945_ID_131;
             if V_PASSO_PELA_REGRA_13097 then
                V_VALOR_MERCADORIA := Obter_Vlr_Mercadoria_Lei13097;
             else
                V_VALOR_MERCADORIA := Obter_Valor_Mercadoria; --TESTE 01
             end if ;


              IF ((V_SUBS_TAB = 1) AND (V_PEDF_PERC_DESC_ORIGINAL > 0) AND (V_oper_aliq_st_ret = 'N') ) OR
                 ((V_PEDF_TPRC_MARGEM_LUCRO > 0) AND (V_TIPO_PESSOA = 1)AND (V_oper_aliq_st_ret = 'N')) or
                 (V_USAR_REGRA_PAR_ALIQUOTA = 1) THEN




                V_DESCONTO_NOR_ITEM := 0;
              ELSIF (V_PFAT_OPER_BASE_CALC_ICM = 'E') THEN
                V_DESCONTO_NOR_ITEM := 0;
                V_DESCONTO_ESP_ITEM := Obter_Desconto_Item('E');
              ELSIF (V_PFAT_OPER_BASE_CALC_ICM = 'P') THEN
                V_DESCONTO_NOR_ITEM := 0;
                V_DESCONTO_ESP_ITEM := Obter_Desconto_Item('P');
              ELSIF (V_PFAT_OPER_BASE_CALC_ICM = 'N') OR (V_PFAT_OPER_BASE_CALC_ICM = 'S') THEN
                V_DESCONTO_NOR_ITEM := Obter_Desconto_Item('N');
                V_DESCONTO_ESP_ITEM := 0;
              END IF;

              V_POS_ERRO := 15;


              V_ALIQ_ICM_REDUCAO := 0;
              V_VALOR_RED_ICM_PARA_ST :=0;

              IF (V_UF_EMPRESA = V_UF_CLIENTE) THEN -- VENDA DENTRO DO ESTADO
                V_ALIQ_ICM_REDUCAO := Calculo_Pedido_Fat$PK.Obter_Aliq_ICM_Red;
              -- VENDA INTERESTADUAL NAO REDUZ BASE ICM

              ELSIF (V_PROF_REDUCAO_OE = 'S') AND (V_ALIQ_ICM > 0) THEN -- PRODUTO EXCEÇAO QUE REDUZ FORA DO ESTADO
                V_ALIQ_ICM_REDUCAO := V_OPER_ALIQ_RED_BC_ICM_OE;  -- aliquota especial
              ELSE
                V_ALIQ_ICM_REDUCAO := 0;
              END IF;

              IF V_ALIQ_ICM = -1 THEN
                Adicionar_Erro(LIQUID,V_PFAT_PEDF_ID,V_POS_ERRO);
              END IF;
              V_ALIQ_ICM_PARA_ST_TEMP :=0;

              IF  (V_oper_aliq_st_ret = 'S') AND (V_OPER_ALIQ_RED_BC_ICM_OE > 0)AND (V_USAR_REGRA_PAR_ALIQUOTA = 0) THEN -- Efeito somente para calculo do ST com Redução do ST
                     V_ALIQ_ICM_PARA_ST_TEMP := V_ALIQ_ICM; --PARA REDUZIR PRECISA SER A ALIQ DO ST
                     V_ALIQ_ICM_REDUCAO      := V_OPER_ALIQ_RED_BC_ICM_OE;
                     V_ALIQ_ICM              := V_PFAT_P_TPRC_ALIQ_ICM_SUBS;
                     V_VALOR_RED_ICM_PARA_ST := Calculo_Pedido_Fat$PK.Obter_Valor_ICM_RED;
                     V_ALIQ_ICM_REDUCAO      := 0;
                     V_ALIQ_ICM              := V_ALIQ_ICM_PARA_ST_TEMP;
                ELSE
                V_VALOR_RED_ICM := Calculo_Pedido_Fat$PK.Obter_Valor_ICM_RED;

              END IF ;

              V_POS_ERRO := 16;

              IF V_PFAT_OPER_TIPO_ICM  in(2,3) THEN
                V_VALOR_ICM := 0 ;
                V_VALOR_RED_ICM :=0;
                V_ALIQ_ICM_REDUCAO  :=0;
              ELSE
                 V_VALOR_ICM := Calculo_Pedido_Fat$PK.Obter_Valor_ICM(0);
              END IF;


              IF V_VALOR_ICM = -1 THEN
                Adicionar_Erro(LIQUID,V_PFAT_PEDF_ID,V_POS_ERRO);
              END IF;

              IF (V_PFAT_OPER_DESTINO_OPER = 1) and (Busca_Gener(945,200,1) = 0) THEN
                IF (v_CONSUMIDOR_FINAL IN (0,2)) AND (NVL(V_PERC_FUNDO_POBREZA_P,0)> 0) THEN
                    V_ALIQ_SUBST := V_ALIQ_ICM + V_PERC_FUNDO_POBREZA_P;
                  ELSE
                   V_ALIQ_SUBST := V_ALIQ_ICM;
                 END IF;
              ELSE
                 V_ALIQ_SUBST := Obter_Aliq_ICM_SUBST;
                 --SOMA O % DO FUNDO DE  POBREZA  NA ALIQ DO ST, SEGUINDO ANALISE GLAUDINEI MISSIATO


                 IF V_ALIQ_SUBST < 0 THEN
                   IF V_PFAT_P_TPRC_ALIQ_ICM_SUBS <> 0 THEN
                     V_ALIQ_SUBST := V_PFAT_P_TPRC_ALIQ_ICM_SUBS;
                   ELSE
                     V_ALIQ_SUBST := V_ALIQ_ICM;
                   END IF;
                 END IF;
              END IF;


               IF V_USAR_REGRA_PAR_ALIQUOTA =  1 THEN
                  V_ALIQ_SUBST := V_PAR_VDA_ALIQ_ST;
               END IF;

               IF (V_CLI_ALIQ_CNAE > 0) and ( v_CLI_ST_REGIME_CNAE = 'S') and (V_PFAT_OPER_DESTINO_OPER = 2) THEN
                  V_ALIQ_SUBST :=V_CLI_ALIQ_CNAE;
               END IF;

               IF (V_ALIQ_SUBST > 0) and (v_CONSUMIDOR_FINAL IN (0,2)) AND(v_SOMA_FPOBRE = 0) THEN
                  V_ALIQ_SUBST := V_ALIQ_SUBST + V_PERC_FUNDO_POBREZA_P;
                  V_PFAT_P_TPRC_ALIQ_ICM_SUBS := V_ALIQ_SUBST;
              END IF ;

--------------
--TESTAR AQUI SOMENTE QUANDO DEVOLUCAO, REFERENCIADA A UMA NOTA DE SAIDA
--
              BEGIN
               SELECT
                     PED_DEVOL_ORIGEM.PEDF_ALIQ_SUBS
                INTO
                     V_ALIQ_SUBST
                FROM
                     PEDIDO_FAT
                    ,PEDIDO_FAT_P PED_DEVOL_ORIGEM
                WHERE
                     PEDIDO_FAT.PEDF_EMP_ID              = PED_DEVOL_ORIGEM.PEDF_PEDF_EMP_ID
                AND  PEDIDO_FAT.PEDF_ID_DEVOL            = PED_DEVOL_ORIGEM.PEDF_PEDF_ID
                AND  PED_DEVOL_ORIGEM.PEDF_PROD_ID       = V_PFAT_P_PEDF_PROD_ID
                --
                AND  PEDIDO_FAT.PEDF_EMP_ID              = V_EMP_ATIVA
                AND  PEDIDO_FAT.PEDF_ID                  = V_PFAT_PEDF_ID;
              EXCEPTION
                 WHEN OTHERS THEN
                   V_ALIQ_SUBST := V_ALIQ_SUBST;
              END;
--FIM


              IF ((V_SUBS_TAB = 1) AND (V_PEDF_PERC_DESC_ORIGINAL > 0)AND (V_oper_aliq_st_ret = 'N')) OR
                 ((V_PEDF_TPRC_MARGEM_LUCRO > 0) AND (V_TIPO_PESSOA = 1) AND (V_oper_aliq_st_ret = 'N'))
                 or (V_USAR_REGRA_PAR_ALIQUOTA = 1) THEN
                if V_PASSO_PELA_REGRA_13097 then
                   V_VALOR_MERCADORIA := Obter_Vlr_Mercadoria_Lei13097;
                else
                   V_VALOR_MERCADORIA := Obter_Valor_Mercadoria; --TESTE 01

                end if ;


                IF ((V_SUBS_TAB = 1) AND (V_PEDF_PERC_DESC_ORIGINAL > 0)) THEN
                  V_DESCONTO_NOR_ITEM := 0;
                ELSIF (V_PFAT_OPER_BASE_CALC_ICM = 'E') THEN
                  V_DESCONTO_NOR_ITEM := 0;
                  V_DESCONTO_ESP_ITEM := Obter_Desconto_Item('E');

                ELSIF (V_PFAT_OPER_BASE_CALC_ICM = 'P') THEN
                  V_DESCONTO_NOR_ITEM := 0;
                  V_DESCONTO_ESP_ITEM := Obter_Desconto_Item('P');

                ELSIF (V_PFAT_OPER_BASE_CALC_ICM = 'N') OR (V_PFAT_OPER_BASE_CALC_ICM = 'S') THEN
                  V_DESCONTO_NOR_ITEM := Obter_Desconto_Item('N');
                  V_DESCONTO_ESP_ITEM := 0;

                END IF;


                V_POS_ERRO := 15;
                V_ALIQ_ICM         := Calculo_Pedido_Fat$PK.Obter_Aliq_ICM;
                V_ALIQ_ICM_REDUCAO := Calculo_Pedido_Fat$PK.Obter_Aliq_ICM_Red;

                 IF (V_ALIQ_ICM > 0) AND (v_CONSUMIDOR_FINAL IN (1,2)) THEN
                    V_ALIQ_ICM := V_ALIQ_ICM + V_PERC_FUNDO_POBREZA_P;
                 END IF;


                IF V_ALIQ_ICM = -1 THEN
                  Adicionar_Erro(LIQUID,V_PFAT_PEDF_ID,V_POS_ERRO);
                END IF;

                --V_VALOR_RED_ICM := Calculo_Pedido_Fat$PK.Obter_Valor_ICM_RED;
                 IF  (V_oper_aliq_st_ret = 'S') AND (V_OPER_ALIQ_RED_BC_ICM_OE > 0) AND (V_USAR_REGRA_PAR_ALIQUOTA = 0) THEN -- Efeito somente para calculo do ST com Redução do ST
                     V_ALIQ_ICM_REDUCAO_TEMP := V_ALIQ_ICM_REDUCAO;
                     V_ALIQ_ICM_PARA_ST_TEMP := V_ALIQ_ICM;
                     V_ALIQ_ICM_REDUCAO := V_OPER_ALIQ_RED_BC_ICM_OE;
                     V_ALIQ_ICM         := V_PFAT_P_TPRC_ALIQ_ICM_SUBS;
                     V_VALOR_RED_ICM_PARA_ST := Calculo_Pedido_Fat$PK.Obter_Valor_ICM_RED;
                     V_ALIQ_ICM_REDUCAO      := V_ALIQ_ICM_REDUCAO_TEMP;
                     V_ALIQ_ICM              := V_ALIQ_ICM_PARA_ST_TEMP;

                    ELSE
                    V_VALOR_RED_ICM := Calculo_Pedido_Fat$PK.Obter_Valor_ICM_RED;

                 END IF ;



                V_POS_ERRO := 16;

                IF V_PFAT_OPER_TIPO_ICM  in(2,3) THEN
                  V_VALOR_ICM := 0 ;
                  V_VALOR_RED_ICM :=0;
                  V_ALIQ_ICM_REDUCAO  :=0;
                ELSE
                   V_VALOR_ICM := Calculo_Pedido_Fat$PK.Obter_Valor_ICM(0);

                END IF;



                IF V_VALOR_ICM = -1 THEN
                  Adicionar_Erro(LIQUID,V_PFAT_PEDF_ID,V_POS_ERRO);
                END IF;


               IF (V_PFAT_OPER_DESTINO_OPER = 1) and (Busca_Gener(945,200,1) = 0) THEN
                IF (v_CONSUMIDOR_FINAL IN (0,2)) AND (NVL(V_PERC_FUNDO_POBREZA_P,0)> 0) THEN
                    V_ALIQ_SUBST := V_ALIQ_ICM + V_PERC_FUNDO_POBREZA_P;
                  ELSE
                   V_ALIQ_SUBST := V_ALIQ_ICM;
                 END IF;
                ELSE
               V_ALIQ_SUBST := Obter_Aliq_ICM_SUBST;

                   IF V_ALIQ_SUBST < 0 THEN
                     IF V_PFAT_P_TPRC_ALIQ_ICM_SUBS <> 0 THEN
                       V_ALIQ_SUBST := V_PFAT_P_TPRC_ALIQ_ICM_SUBS;
                     ELSE
                       V_ALIQ_SUBST := V_ALIQ_ICM;

                     END IF;

                   END IF;

                END IF;

                 IF V_USAR_REGRA_PAR_ALIQUOTA =  1 THEN
                    V_ALIQ_SUBST := V_PAR_VDA_ALIQ_ST;
                 END IF;

                 IF (V_CLI_ALIQ_CNAE > 0) and ( v_CLI_ST_REGIME_CNAE = 'S')and (V_PFAT_OPER_DESTINO_OPER = 2) THEN
                  V_ALIQ_SUBST :=V_CLI_ALIQ_CNAE;
                 END IF;

                 IF (V_ALIQ_SUBST > 0) and (v_CONSUMIDOR_FINAL IN (0,2)) AND(v_SOMA_FPOBRE = 0) THEN
                  V_ALIQ_SUBST := V_ALIQ_SUBST + V_PERC_FUNDO_POBREZA_P;
                  V_PFAT_P_TPRC_ALIQ_ICM_SUBS := V_ALIQ_SUBST;
                END IF ;
--------------
--TESTAR AQUI SOMENTE QUANDO DEVOLUCAO, REFERENCIADA A UMA NOTA DE SAIDA
--
               BEGIN
                SELECT
                      PED_DEVOL_ORIGEM.PEDF_ALIQ_SUBS
                 INTO
                      V_ALIQ_SUBST
                 FROM
                      PEDIDO_FAT
                     ,PEDIDO_FAT_P PED_DEVOL_ORIGEM
                 WHERE
                      PEDIDO_FAT.PEDF_EMP_ID              = PED_DEVOL_ORIGEM.PEDF_PEDF_EMP_ID
                 AND  PEDIDO_FAT.PEDF_ID_DEVOL            = PED_DEVOL_ORIGEM.PEDF_PEDF_ID
                 AND  PED_DEVOL_ORIGEM.PEDF_PROD_ID       = V_PFAT_P_PEDF_PROD_ID
                 --
                 AND  PEDIDO_FAT.PEDF_EMP_ID              = V_EMP_ATIVA
                 AND  PEDIDO_FAT.PEDF_ID                  = V_PFAT_PEDF_ID;
               EXCEPTION
                  WHEN OTHERS THEN
                    V_ALIQ_SUBST := V_ALIQ_SUBST;
               END;
--FIM
              END IF;


              V_POS_ERRO := 17;

              V_BASE_SUBST := Calculo_Pedido_Fat$PK.Obter_Base_Subst;
               if V_USA_CALC_PIS_COFINS = 0 then

                if (V_CST_PIS_COFINS in ('01','02','03')) and
                                     (V_BASE_PVV_MIN > 0) and
                                (V_USAR_REGRA_COM_PVV =0) and
                                (V_DEDUZ_ICMS_BASE_PIS =0) then

                   Busca_prod_lei_13097_item(V_PFAT_P_PEDF_PROD_ID,V_CLI_QUALIFICACAO,((V_BASE_PVV_MIN -V_VALOR_ICM) /V_PFAT_P_PEDF_QTDE),1);
                end if;
                Calculo_Pedido_Fat$PK.Obter_Valor_PIS_COFINS;
             else
               V_CST_PIS_COFINS:= '';

               end if;


              IF V_BASE_SUBST = -1 THEN
                Adicionar_Erro(LIQUID,V_PFAT_PEDF_ID,V_POS_ERRO);
              END IF;

              V_POS_ERRO := 18;
              Calculo_Pedido_Fat$PK.Gravar_Pedido_Fat_S;
              V_POS_ERRO := 20;
              Calculo_Pedido_Fat$PK.Gravar_Pedido_Fat_P;
              V_POS_ERRO := 19;
              Calculo_Pedido_Fat$PK.Gravar_Pedido_Fat_I;
              IF (V_PFAT_P_PROC_NAO_RET = 'N') THEN
                 V_LIQU_FLAG_RETORNO := 1;
              END IF;

            END LOOP;


             UPDATE PEDIDO_FAT F
                  SET F.PEDF_VLR_FUNDO_POBREZA = (SELECT ROUND(SUM (NVL(P.PEDF_VLR_RAT_FUNDO_POBREZA + NVL(P.PEDF_VLR_FUNDO_POBREZA_ICMS,0),0)),2)
                                                   FROM PEDIDO_FAT_P P
                                                   WHERE P.PEDF_PEDF_EMP_ID = V_EMP_ATIVA
                                                     AND P.PEDF_PEDF_ID = V_PFAT_PEDF_ID)

                     ,F.pedf_vlr_icms_fcp_uf_dest_tot = (SELECT ROUND(SUM (NVL(P.pedf_vlr_icms_fcp_uf_dest,0)),2)
                                                         FROM PEDIDO_FAT_P P
                                                         WHERE P.PEDF_PEDF_EMP_ID = V_EMP_ATIVA
                                                           AND P.PEDF_PEDF_ID = V_PFAT_PEDF_ID)

                     ,F.pedf_vlr_icms_int_uf_dest_tot = (SELECT ROUND(SUM (NVL(P.pedf_vlr_icms_int_uf_dest,0)),2)
                                                         FROM PEDIDO_FAT_P P
                                                         WHERE P.PEDF_PEDF_EMP_ID = V_EMP_ATIVA
                                                           AND P.PEDF_PEDF_ID = V_PFAT_PEDF_ID)

                     ,pedf_vlr_icms_int_uf_remet_tot = (SELECT ROUND(SUM (NVL(P.pedf_vlr_icms_int_uf_remet,0)),2)
                                                         FROM PEDIDO_FAT_P P
                                                         WHERE P.PEDF_PEDF_EMP_ID = V_EMP_ATIVA
                                                           AND P.PEDF_PEDF_ID = V_PFAT_PEDF_ID)




             WHERE     F.PEDF_EMP_ID = V_EMP_ATIVA
                   AND F.PEDF_ID    = V_PFAT_PEDF_ID;

            COMMIT;



            IF CURSOR_PEDIDO_FAT_P%ISOPEN THEN
               CLOSE CURSOR_PEDIDO_FAT_P;
            END IF;

            IF CURSOR_PEDIDO_FAT_P_BLOQ%ISOPEN THEN
               CLOSE CURSOR_PEDIDO_FAT_P_BLOQ;
            END IF;

         ELSE
            Adicionar_Erro(LIQUID,V_PFAT_PEDF_ID,V_POS_ERRO);

         END IF;

         IF ERROS_PARCIAIS = '0' THEN
            V_POS_ERRO := 21;
            IF (V_LIQU_FLAG_RETORNO = 1 AND
                V_PFAT_LIQU_TIPO    = 1 AND
                V_FLAG_941) THEN
              UPDATE LIQUIDACAO SET
                     LIQU_FLAG_RETORNO = 1
                     WHERE LIQU_EMP_ID = V_EMP_ATIVA AND
                           LIQU_ID     = V_LIQUID ;

            END IF;

            IF ERROS_PARCIAIS = '0' THEN
               V_POS_ERRO := 22;

            IF V_GERA_NF = 1 THEN
               MOVIMENTACAO_EST$P(0, -- operacao
                                  0, -- tipo
                                  V_EMP_ATIVA,
                                  TO_CHAR(V_LIQUID),
                                  COD_USUARIO,
                                  V_ERRO_ESTOQUE,
                                  V_PFAT_PEDF_ID);
            END IF;


              IF V_ERRO_ESTOQUE <> 'F' THEN
                 Adicionar_Erro(LIQUID,V_PFAT_PEDF_ID,V_POS_ERRO);
                 ERROS_PARCIAIS := 0;
              END IF;


              IF ERROS_PARCIAIS = '0' THEN
                 Calculo_Pedido_Fat$PK.Verificar_Situacao_ICMSUBST;
                 Calculo_Pedido_Fat$PK.Gravar_Pedido_Fat;
                 GRAVOU_PEDIDO_FAT := TRUE;
              IF V_OPER_SUFRAMA = 'S' THEN
                 UPDATE PEDIDO_FAT F
                 SET F.PEDF_VLR_TOT_DES_SUFRAMA = (SELECT SUM (NVL(P.PEDF_VLR_ICMS_DES,0))
                                                   FROM PEDIDO_FAT_P P
                                                   WHERE   P.PEDF_PEDF_EMP_ID = F.PEDF_EMP_ID
                                                       AND P.PEDF_PEDF_ID     = F.PEDF_ID )
                     ,F.PEDF_VLR_TOT_PED        =F.PEDF_VLR_TOT_PED -(CASE WHEN V_DESCONTO_DESONERADO = 0 THEN
                                                                                (SELECT SUM (NVL(P.PEDF_VLR_ICMS_DES,0))
                                                                                 FROM PEDIDO_FAT_P P
                                                                                 WHERE   P.PEDF_PEDF_EMP_ID = F.PEDF_EMP_ID
                                                                                     AND P.PEDF_PEDF_ID     = F.PEDF_ID)
                                                                  ELSE 0
                                                                 END)
                       WHERE     F.PEDF_EMP_ID    =V_EMP_ATIVA
                             AND F.PEDF_ID        =V_PFAT_PEDF_ID;

              END IF;



                IF Busca_Gener(945,199,1) = 1 THEN
                   Acerto_totais_notas;
                END IF;


                 IF  Busca_Gener(945,181,2) = 1 THEN
                     for UPD IN (SELECT
                                      vlr_tot
                                     ,ROUND(vlr_tot_liq,2)vlr_tot_liq
                                     ,base_icms
                                     ,FF.PEDF_VLR_TOT_PED
                                     ,FF.PEDF_ID
                                     ,VLR_IPI
                                     ,VLR_SUBS
                                FROM PEDIDO_FAT FF,
                                     (select PEDF_PEDF_EMP_ID,
                                             pedf_pedf_id,
                                             SUM(f.pedf_vlr_tot) vlr_tot,
                                             SUM(f.pedf_vlr_tot_liq + NVL(F.PEDF_VLR_SUBS,0)) vlr_tot_liq,
                                             SUM(f.pedf_base_icms) base_icms,
                                             SUM(NVL(F.PEDF_VLR_IPI,0)) VLR_IPI,
                                             sum(NVL(F.PEDF_VLR_SUBS,0))VLR_SUBS
                                        from pedido_fat_p f
                                       where F.PEDF_PEDF_EMP_ID = V_EMP_ATIVA
                                         AND f.pedf_pedf_id     = V_PFAT_PEDF_ID
                                       GROUP BY PEDF_PEDF_EMP_ID, pedf_pedf_id) PEDF_P
                               WHERE     FF.PEDF_EMP_ID = PEDF_P.PEDF_PEDF_EMP_ID
                                     AND FF.PEDF_EMP_ID = V_EMP_ATIVA
                                     AND FF.PEDF_ID     = PEDF_P.pedf_pedf_id
                                     AND fF.pedf_id     = V_PFAT_PEDF_ID
                                     AND ((vlr_tot <> vlr_tot_liq) AND (vlr_tot_liq = base_icms))
                                     AND vlr_tot_liq  <> PEDF_VLR_TOT_PED
                                 )
                  LOOP
                      UPDATE PEDIDO_FAT F
                      SET F.PEDF_VLR_TOT_PED          = UPD.VLR_TOT_LIQ
                         ,F.pedf_vlr_tot_ped_bkp      = UPD.PEDF_VLR_TOT_PED
                           WHERE     F.PEDF_EMP_ID    = V_EMP_ATIVA
                                 AND F.PEDF_ID        = V_PFAT_PEDF_ID;

                          COMMIT;

                  END LOOP;

               IF (V_SUBS_TAB = 1) THEN
                 FOR DADOS IN (
                    SELECT
                           p_item .*
                          ,VLR_DESCONTO_ORI - VLR_DESCONTO_CONV DESC_DIV,
                           Pedf_Base_Icms -(VLR_DESCONTO_ORI - VLR_DESCONTO_CONV)
                    FROM
                    (select ROUND(DECODE(NVL(PEDF_VALOR_DESCONTO,0),0,
                          CASE WHEN   (NVL(PEDIDO_FAT_P.PEDF_VLR_TOT,0) <>  NVL(PEDIDO_FAT_P.PEDF_VLR_TOT_LIQ,0))
                                           AND (NVL(PEDIDO_FAT_P.PEDF_VLR_TOT_LIQ,0) > 0 )
                                           AND ((NVL(PEDIDO_FAT_P.PEDF_PERC_DESC_ORIGINAL,0) > 0 ))
                                           THEN
                            NVL(PEDIDO_FAT_P.PEDF_VLR_TOT,0) - NVL(PEDIDO_FAT_P.PEDF_VLR_TOT_LIQ,0)
                           ELSE
                             NVL(PEDIDO_FAT_P.PEDF_VLR_TOT,0) * (PEDIDO_FAT_P.PEDF_PERC_DESC/100)
                          END
                           , NVL(PEDF_VALOR_DESCONTO,0)),2) VLR_DESCONTO_CONV
                    ,ROUND(DECODE(NVL(PEDF_VALOR_DESCONTO,0),0,NVL(PEDIDO_FAT_P.PEDF_VLR_TOT,0) * (PEDIDO_FAT_P.PEDF_PERC_DESC/100), NVL(PEDF_VALOR_DESCONTO,0)),2) VLR_DESCONTO_ORI
                    ,pedido_fat_p.pedf_prod_id
                    ,pedido_fat_p.pedf_id
                    ,pedido_fat_p.Pedf_Base_Icms
                    ,pedido_fat_p.pedf_vlr_tot_liq
                    ,pedido_fat_p.pedf_aliq_icms
                    ,pedido_fat_p.pedf_vlr_icms
                    from pedido_fat_p
                    where
                        pedido_fat_p.pedf_pedf_emp_id = V_EMP_ATIVA
                    and pedf_pedf_id = V_PFAT_PEDF_ID)p_item

                    WHERE VLR_DESCONTO_CONV <> VLR_DESCONTO_ORI
                   )
                   LOOP

                    UPDATE PEDIDO_FAT_P P
                        SET P.PEDF_BASE_ICMS         = P.PEDF_BASE_ICMS - DADOS.DESC_DIV
                           ,P.PEDF_VLR_TOT_LIQ       = P.PEDF_VLR_TOT_LIQ - DADOS.DESC_DIV
                             WHERE     P.PEDF_PEDF_EMP_ID    = V_EMP_ATIVA
                                   AND P.PEDF_PEDF_ID        = V_PFAT_PEDF_ID
                                   AND P.PEDF_ID             = DADOS.PEDF_ID
                                   AND P.PEDF_PROD_ID        = DADOS.PEDF_PROD_ID;

                            COMMIT;
                     END LOOP;

                  END IF;

               END IF ;

              END IF;

            END IF;

         END IF;

       END IF;

       IF ERROS_PARCIAIS = '0' THEN
         COMMIT WORK;
         IF CURSOR_PEDIDO_FAT_BLOQ%ISOPEN THEN
            CLOSE CURSOR_PEDIDO_FAT_BLOQ;
         END IF;

       ELSE
         ROLLBACK;
         Adicionar_Erro(LIQUID,V_PFAT_PEDF_ID,V_POS_ERRO);
         RESULTADO := SUBSTR(RESULTADO || ERROS_PARCIAIS,1,255);

       END IF;

       OBTEVE_NUMERO_NOTA := FALSE;
       IF CURSOR_PEDIDO_FAT_BLOQ%ISOPEN THEN
          CLOSE CURSOR_PEDIDO_FAT_BLOQ;
       END IF;

       IF CURSOR_PEDIDO_FAT_P_BLOQ%ISOPEN THEN
          CLOSE CURSOR_PEDIDO_FAT_P_BLOQ;
       END IF;

     END LOOP;

     V_POS_ERRO := 23;
     IF GERAR_LIVROS_FISCAIS = FALSE THEN
       Adicionar_Erro(LIQUID,PEDID,V_POS_ERRO);
     END IF;


     IF GERAR_CONTABILIDADE = FALSE THEN
       Adicionar_Erro(LIQUID,PEDID,V_POS_ERRO);
     END IF;


     IF CURSOR_PEDIDO_FAT%ISOPEN THEN
        CLOSE CURSOR_PEDIDO_FAT;
     END IF;

     IF CURSOR_PEDIDO_FAT_P%ISOPEN THEN
        CLOSE CURSOR_PEDIDO_FAT_P;
     END IF;

     ERROS := RESULTADO;

   EXCEPTION
     WHEN OTHERS THEN
          Adicionar_Erro(LIQUID,PEDID,V_POS_ERRO);
          IF CURSOR_PEDIDO_FAT%ISOPEN THEN
             CLOSE CURSOR_PEDIDO_FAT;
          END IF;

          IF CURSOR_PEDIDO_FAT_P%ISOPEN THEN
             CLOSE CURSOR_PEDIDO_FAT_P;
          END IF;

          IF CURSOR_PEDIDO_FAT_BLOQ%ISOPEN THEN
             CLOSE CURSOR_PEDIDO_FAT_BLOQ;
          END IF;

          IF CURSOR_PEDIDO_FAT_P_BLOQ%ISOPEN THEN
             CLOSE CURSOR_PEDIDO_FAT_P_BLOQ;
          END IF;

          RESULTADO := SUBSTR(RESULTADO || ERROS_PARCIAIS,1,255);
          ERROS     := RESULTADO;
          ROLLBACK;

  END Calculo_Pedido_Fat;

END Calculo_Pedido_Fat$PK;
