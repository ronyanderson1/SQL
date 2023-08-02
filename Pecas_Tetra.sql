SELECT 
       ACME_PROD_EMP_ID "EMPRESA"                                       
      ,ACME_PROD_ID "CODIGO"
      ,PRODUTO.PROD_DESC "DESCRICAO PRODUTO"
      ,CAST(ACUM_ESTOQVM_ST.ACME_QTD_INI AS REAL) "QTD INICIAL"
      ,GRUPO.Gen_Id "IDG"
      ,GRUPO.Gen_Descricao GRUPO                                               
      ,SUB_GRUPO.Gen_Id "IDS"
      ,SUB_GRUPO.Gen_Descricao "SUB GRUPO"
      ,DECODE(PRODUTO.PROD_SITUACAO,'H','HABILITADO','D','DESABILITADO') "STATUS"

FROM                                                                                
    (SELECT KDX.KDEX_PROD_EMP_ID EMPRESA_PRODUTO                                    
          ,KDX.KDEX_PROD_ID     CODIGO_PRODUTO                                      
          ,PROD_DESC                                                                
          ,KDEX_OPER_EMP_ID                                                         
          ,KDEX_OPER_ID                                                             
          ,EMP_NOME                                                                 
          ,KDX.KDEX_QTD         QTDE                                                
          ,KDX.KDEX_CTO         CUSTO                                               
          ,KDX.KDEX_ENTR_SAI    TIPO                                                
          ,KDX.KDEX_SDAL_SDAL_EMP_ID EMP_ID                                         
          ,KDX.KDEX_SDAL_SDAL_ID     ID_ID                                          
          ,KDX.KDEX_SDAL_ID          ID                                             
          ,KDX.KDEX_SEQUENCIA                                                       
          ,NVL(KDX.KDEX_SDAL_SUB_TIPO,1) SUB_TIPO                                   
          ,KDEX_EMP_ID                                                              
          ,KDEX_DATA                                                                
          ,KDEX_DTA_CAD                                                             
          ,sa.sdal_docum  KDEX_NR_NOTA                                              
          ,'SAIDA_ALM' TABELA                                                     
          ,S.SDAL_PCTA_REF                     CTA_DESPESA                           
          ,DECODE(OP.OPER_REQUER_DEVOL,NULL,'N',OP.OPER_REQUER_DEVOL) OPER_REQUER_DEVOL 
                                                                                    
    FROM KARDEX       KDX                                                           
        ,PRODUTO                                                                    
        ,EMPRESA                                                                    
        ,SAIDA_ALM_E S                                                              
        ,saida_alm sa                                    
        ,OPERACAO_ALM OP                                   
    WHERE KDEX_SDAL_ID   Is Not Null                                                
      And KDEX_PROD_EMP_ID            = PROD_EMP_ID                                 
      And KDEX_PROD_ID                = PROD_ID                                     
      And EMP_ID                      = KDEX_EMP_ID                                 
      And NOT  ((NVL(S.SDAL_MOV_DEPOSITO,'N')) = 'S' AND (KDX.KDEX_ENTR_SAI = 'E')) 
      And (NVL(S.SDAL_MOV_KARDEX,'S') = 'S'  )
      AND TO_CHAR(KDEX_DATA,'MM/YYYY') = '06/2023'
      AND KDEX_PROD_EMP_ID               = 2
      AND KDEX_EMP_ID                    = 2
      AND S.SDAL_SDAL_EMP_ID           = KDX.KDEX_SDAL_SDAL_EMP_ID (+) 
      AND S.SDAL_SDAL_ID               = KDX.KDEX_SDAL_SDAL_ID     (+) 
      AND S.SDAL_ID                    = KDX.KDEX_SDAL_ID          (+) 
      AND S.SDAL_SUB_TIPO              = KDX.KDEX_SDAL_SUB_TIPO    (+) 
      and s.sdal_sdal_emp_id           = sa.sdal_emp_id                
      and s.sdal_sdal_id               = sa.sdal_id                    
      AND SA.SDAL_OPER_ALM_EMP_ID      = OP.OPER_EMP_ID  
      AND SA.SDAL_OPER_ALM_ID          = OP.OPER_ID      

    UNION ALL                                                                       
                                                                                  
    SELECT KDX.KDEX_PROD_EMP_ID                                                     
          ,KDX.KDEX_PROD_ID                                                         
          ,PROD_DESC                                                                
          ,KDEX_OPER_EMP_ID                                                         
          ,KDEX_OPER_ID                                                             
          ,EMP_NOME                                                                 
          ,KDX.KDEX_QTD                                                             
          ,KDX.KDEX_CTO                                                             
          ,KDX.KDEX_ENTR_SAI                                                        
          ,KDX.KDEX_ENTR_ENTR_EMP_ID EMP_ID                                         
          ,KDX.KDEX_ENTR_ENTR_ID     ID_ID                                          
          ,KDX.KDEX_ENTR_ID          ID                                             
          ,KDX.KDEX_SEQUENCIA                                                       
          ,NVL(KDX.KDEX_SDAL_SUB_TIPO,1) SUB_TIPO                                   
          ,KDEX_EMP_ID                                                              
          ,KDEX_DATA                                                                
          ,KDEX_DTA_CAD                                                             
          ,TO_CHAR(KDEX_NR_NOTA)                                                    
          ,'ENTRADA_ALM' TABELA                                                   
          ,0 CTA_DESPESA                                                         
          ,DECODE(OP.OPER_REQUER_DEVOL,NULL,'N',OP.OPER_REQUER_DEVOL) OPER_REQUER_DEVOL

    FROM KARDEX         KDX                                                         
        ,PRODUTO                                                                    
        ,EMPRESA                                                                    
        ,ENTRADA_ALM EN                                    
        ,OPERACAO_ALM OP                                   
                                                                                    
    WHERE KDX.KDEX_ENTR_ID Is Not Null                                              
      And EMP_ID                      = KDEX_EMP_ID                                 
      And KDEX_PROD_EMP_ID            = PROD_EMP_ID                                 
      And KDEX_PROD_ID                = PROD_ID                                     
      AND TO_CHAR(KDEX_DATA,'MM/YYYY') = '06/2023'
      AND KDEX_PROD_EMP_ID               = 2
      AND KDEX_EMP_ID                    = 2
      AND KDX.KDEX_ENTR_ENTR_EMP_ID = EN.ENTR_EMP_ID 
      AND KDX.KDEX_ENTR_ENTR_ID     = EN.ENTR_ID     
      AND EN.ENTR_OPER_ALM_EMP_ID      = OP.OPER_EMP_ID  
      AND EN.ENTR_OPER_ALM_ID          = OP.OPER_ID      
    UNION ALL                                                                        
    SELECT KDX.KDEX_PROD_EMP_ID                                                      
          ,KDX.KDEX_PROD_ID                                                          
          ,PROD_DESC                                                                 
          ,KDEX_OPER_EMP_ID                                                          
          ,KDEX_OPER_ID                                                              
          ,EMP_NOME                                                                  
          ,KDX.KDEX_QTD                                                              
          ,KDX.KDEX_CTO                                                              
          ,KDX.KDEX_ENTR_SAI                                                         
          ,KDX.KDEX_PEDV_PEDV_EMP_ID EMP_ID                                          
          ,KDX.KDEX_PEDV_PEDV_ID     ID_ID                                           
          ,KDX.KDEX_PEDV_ID          ID                                              
          ,KDX.KDEX_SEQUENCIA                                                        
          ,NVL(KDX.KDEX_SDAL_SUB_TIPO,1) SUB_TIPO                                    
          ,KDEX_EMP_ID                                                               
          ,KDEX_DATA                                                                 
          ,KDEX_DTA_CAD                                                              
          ,TO_CHAR(KDEX_NR_NOTA)                                                     
          ,'PEDIDO_VRJ' TABELA                                                     
          ,0 CTA_DESPESA                                                          
          ,'N'OPER_REQUER_DEVOL
    FROM KARDEX         KDX                                                          
        ,PRODUTO                                                                     
        ,EMPRESA                                                                     
    WHERE KDEX_PEDV_ID Is Not Null                                                   
      And KDEX_PROD_EMP_ID            = PROD_EMP_ID                                  
      And KDEX_PROD_ID                = PROD_ID                                      
      And EMP_ID                      = KDEX_EMP_ID                                  
      AND TO_CHAR(KDEX_DATA,'MM/YYYY') = '06/2023'
      AND KDEX_PROD_EMP_ID               = 2
      AND KDEX_EMP_ID                    = 2
    
    UNION ALL                                                                        
                                                                                     
    SELECT KDX.KDEX_PROD_EMP_ID                                                      
          ,KDX.KDEX_PROD_ID                                                          
          ,PROD_DESC                                                                 
          ,KDEX_OPER_EMP_ID                                                         
          ,KDEX_OPER_ID                                                             
          ,EMP_NOME                                                                  
          ,KDX.KDEX_QTD                                                              
          ,KDX.KDEX_CTO                                                              
          ,KDX.KDEX_ENTR_SAI                                                         
          ,KDX.KDEX_PEDF_PEDF_EMP_ID EMP_ID                                          
          ,KDX.KDEX_PEDF_PEDF_ID     ID_ID                                           
          ,KDX.KDEX_PEDF_ID          ID                                              
          ,KDX.KDEX_SEQUENCIA                                                        
          ,NVL(KDX.KDEX_SDAL_SUB_TIPO,1) SUB_TIPO                                    
          ,KDEX_EMP_ID                                                               
          ,KDEX_DATA                                                                 
          ,KDEX_DTA_CAD                                                              
          ,TO_CHAR(KDEX_NR_NOTA)                                                     
          ,'PEDIDO_FAT' TABELA                                                     
          ,0 CTA_DESPESA                                                                           
          ,'N'OPER_REQUER_DEVOL
                                                                                     
    FROM KARDEX         KDX                                                          
        ,PRODUTO                                                                     
        ,EMPRESA                                                                     
                                                                                     
    WHERE KDX.KDEX_PEDF_ID  Is Not Null                                              
      And KDEX_PROD_EMP_ID            = PROD_EMP_ID                                  
      And KDEX_PROD_ID                = PROD_ID                                      
      And EMP_ID                      = KDEX_EMP_ID                                  
      AND TO_CHAR(KDEX_DATA,'MM/YYYY') = '06/2023'
      AND KDEX_PROD_EMP_ID               = 2
      AND KDEX_EMP_ID                    = 2) KARDEX_INT
   ,EMPRESA                                                                           
   ,ACUM_ESTOQVM_ST                                                                   
   ,PRODUTO                                                                           
   ,PRODUTO_AL                                                                        
   ,GENER GRUPO                                                                       
   ,GENER SUB_GRUPO                                                                   
   ,GENER_A SUB_GRUPO_PROP
                                                                                      
WHERE   
      ACME_EMP_ID                  = EMPRESA.EMP_ID                                   
  And PROA_PROD_EMP_ID             = PROD_EMP_ID                                      
  And PROA_PROD_ID                = PROD_ID                                           
  And PRODUTO_AL.PROA_GEN_TGEN_ID = SUB_GRUPO.GEN_TGEN_ID (+)                         
  AND PRODUTO_AL.PROA_GEN_EMP_ID  = SUB_GRUPO.GEN_EMP_ID  (+)                         
  AND PRODUTO_AL.PROA_GEN_ID      = SUB_GRUPO.GEN_ID      (+)                         
  AND SUB_GRUPO.GEN_TGEN_ID       = SUB_GRUPO_PROP.GENA_GEN_TGEN_ID                   
  AND SUB_GRUPO.GEN_EMP_ID        = SUB_GRUPO_PROP.GENA_GEN_EMP_ID                    
  AND SUB_GRUPO.GEN_ID            = SUB_GRUPO_PROP.GENA_GEN_ID                        
  AND SUB_GRUPO_PROP.GENA_GEN_TGEN_ID_PROPRIETARIO_ = GRUPO.GEN_TGEN_ID               
  AND SUB_GRUPO_PROP.GENA_GEN_EMP_ID_PROPRIETARIO_D = GRUPO.GEN_EMP_ID                
  AND SUB_GRUPO_PROP.GENA_GEN_ID_PROPRIETARIO_DE    = GRUPO.GEN_ID                    
  AND ACME_EMP_ID                  = KARDEX_INT.KDEX_EMP_ID     (+)
  AND ACME_SUB_TIPO                = KARDEX_INT.SUB_TIPO        (+)
  And ACME_PROD_EMP_ID             = KARDEX_INT.EMPRESA_PRODUTO (+)
  And ACME_PROD_ID                 = KARDEX_INT.CODIGO_PRODUTO  (+)
  And ACME_PROD_EMP_ID             = PROD_EMP_ID                                      
  And ACME_PROD_ID                 = PROD_ID
  AND TO_CHAR(ACME_DATA,'MM/YYYY') = '06/2023' --Campo de consulta e especificações de regra
  AND PRODUTO_AL.PROA_GEN_ID IN (30) 
  AND ACME_PROD_EMP_ID               = 2
  AND ACME_EMP_ID                    = 2
  AND ACME_PROD_ID IN (903,1284,1418,1422,1484,1507,1509,1511,1513,1514,1521,1524,1687,1698,1921,1966,1994,1995,1996,2015,2019,2066,2067,2070,2071,2072,2075,2078,2079,2081,
2082,2083,2084,2089,2098,2099,2102,2105,2110,2112,2113,2115,2124,2125,2126,2127,2128,2129,2130,2131,2132,2133,2134,2136,2137,2138,2140,2141,2142,2143,
2144,2146,2147,2148,2150,2152,2153,2154,2155,2157,2158,2173,2174,2175,2176,2177,2178,2179,2181,2182,2183,2184,2185,2189,2190,2191,2192,2193,2196,2199,
2200,2201,2202,2204,2205,2206,2207,2208,2210,2212,2213,2214,2215,2216,2217,2218,2219,2220,2221,2222,2223,2224,2225,2226,2227,2228,2229,2230,2231,2232,
2233,2234,2235,2239,2242,2243,2245,2246,2248,2249,2251,2257,2258,2259,2260,2265,2266,2268,2269,2271,2273,2274,2275,2276,2277,2287,2289,2292,2295,2303,
2304,2327,2332,2335,2337,2343,2344,2345,2346,2347,2348,2349,2350,2351,2352,2353,2354,2355,2356,2357,2360,2361,2362,2363,2391,2393,2404,2406,2407,2410,
2412,2417,2418,2419,2420,2421,2422,2423,2424,2425,2427,2428,2429,2430,2431,2432,2434,2435,2436,2450,2451,2460,2463,2464,2469,2474,2479,2482,2483,2489,
2491,2493,2497,2508,2514,2515,2529,2532,2536,2537,2544,2546,2547,2549,2551,2552,2557,2558,2559,2560,2562,2566,2569,2572,2573,2575,2576,2577,2578,2579,
2580,2582,2584,2586,2594,2601,2602,2603,2604,2616,2617,2618,2624,2627,2628,2632,2633,2634,2635,2636,2637,2639,2642,2643,2644,2645,2646,2649,2652,2654,
2656,2657,2660,2667,2683,2686,2687,2688,2689,2690,2691,2692,2693,2702,2707,2718,2720,2721,2724,2725,2726,2727,2731,2733,2735,2737,2738,2739,2742,2744,
2746,2756,2757,2760,2761,2762,2763,2764,2768,2770,2784,2792,2793,2796,2800,2801,2807,2808,2809,2812,2813,2824,2826,2829,2830,2831,2838,2853,2855,2860,
2861,2867,2868,2870,2873,2878,2879,2880,2881,2883,2885,2886,2888,2890,2891,2892,2894,2895,2896,2897,2900,2901,2902,2903,2904,2905,2909,2911,2913,2914,
2916,2917,2919,2920,2921,2925,2929,2938,2945,2948,2950,2959,2968,2969,2972,2973,2976,2977,2978,2981,2982,2983,2984,3006,3007,3016,3017,3027,3038,3040,
3041,3043,3048,3053,3075,3078,3082,3087,3098,3124,3125,3130,3131,3132,3134,3136,3137,3147,3148,3149,3152,3153,3154,3155,3160,3161,3171,3172,3173,3176,
3183,3187,3189,3194,3195,3203,3207,3209,3211,3213,3214,3218,3221,3222,3224,3225,3284,3287,3288,3290,3307,3316,3349,3380,3386,3388,3393,3394,3397,3398,
3399,3402,3403,3414,3426,3430,3431,3437,3438,3440,3441,3442,3443,3444,3445,3448,3451,3477,3478,3480,3483,3488,3492,3494,3496,3499,3502,3505,3506,3509,
3517,3521,3524,3527,3530,3542,3546,3550,3551,3552,3554,3555,3564,3566,3568,3569,3570,3572,3580,3581,3582,3593,3626,3638,3639,3642,3644,3645,3656,3664,
3666,3669,3670,3671,3674,3675,3677,3694,3705,3706,3707,3713,3715,3734,3735,3737,3738,3739,3740,3744,3745,3746,3747,3749,3750,3754,3756,3768,3772,3776,
3778,3780,3782,3786,3790,3791,3801,3804,3807,3808,3811,3812,3815,3816,3817,3818,3820,3844,3845,3848,3849,3854,3855,3856,3859,3867,3871,3872,3874,3875,
3880,3881,3883,3888,3892,3897,3899,3900,3904,3915,3916,3919,3938,3939,3941,3947,3948,3950,3952,3954,3957,3958,3959,3970,3971,3973,3974,3976,3978,3983,
3984,3985,3986,3987,3989,3990,3996,3997,4008,4009,4010,4026,4034,4037,4038,4126,4131,4135,4153,4154,4161,4164,4166,4174,4179,4180,4183,4188,4189,4194,
4195,4196,4198,4199,4200,4202,4204,4207,4237,4238,4252,4259,4260,4261,4264,4270,4283,4294,4297,4299,4306,4310,4316,4327,4352,4353,4354,4359,4360,4362,
4364,4365,4366,4367,4369,4370,4371,4374,4375,4377,4378,4379,4382,4388,4389,4392,4393,4395,4396,4399,4416,4417,4423,4430,4432,4433,4434,4435,4436,4437,
4440,4441,4442,4445,4446,4449,4454,4456,4459,4465,4468,4470,4474,4475,4479,4485,4486,4503,4508,4509,4513,4515,4528,4529,4530,4538,4541,4542,4545,4557,
4564,4567,4570,4571,4572,4573,4584,4590,4597,4598,4600,4603,4607,4615,4616,4617,4624,4625,4637,4642,4643,4645,4647,4648,4661,4663,4664,4665,4671,4674,
4676,4677,4680,4681,4682,4683,4684,4685,4686,4687,4690,4694,4696,4697,4698,4699,4700,4704,4718,4721,4722,4736,4739,4740,4752,4784,4823,4826,4833,4834,
4835,4836,4837,4843,4844,4852,4854,4856,4857,4860,4861,4862,4863,4864,4865,4866,4867,4870,4876,4877,4881,4882,4883,4884,4885,4887,4889,4892,4894,4895,
4900,4902,4903,4904,4905,4906,4907,4908,4909,4912,4914,4915,4917,4939,4940,4941,4943,4944,4947,4948,4949,4950,4951,4952,4969,4970,4977,4978,4979,4981,
4982,4983,4984,4985,4986,4987,4988,4992,5002,5006,5007,5008,5025,5044,5099,5100,5107,5108,5110,5111,5116,5118,5119,5121,5125,5146,5147,5148,5149,5153,
5154,5157,5158,5159,5160,5163,5165,5166,5168,5169,5170,5171,5172,5174,5197,5212,5213,5214,5215,5216,5217,5218,5220,5221,5222,5223,5224,5225,5226,5227,
5247,5250,5253,5254,5255,5256,5260,5420,5481,5540,5603,5610,5611,5612,5613,5614,5615,5619,5620,5628,5629,5632,5635,5637,5638,5640,5643,5644,5646,5675,
5679,5681,5682,5683,5684,5687,5688,5701,5703,5705,5708,5709,5712,5715,5720,5724,5742,5790,5792,5821,5823,5824,5832,5863,5864,5919,5939,5940,5947,5980,
5998,6030,6060,6062,6144,6145,6154,6156,6158,6159,6160,6163,6165,6166,6167,6174,6177,6179,6180,6181,6184,6186,6187,6188,6190,6191,6192,6193,6198,6199,
6201,6202,6203,6205,6209,6210,6211,6213,6217,6218)

ORDER BY  ACME_EMP_ID                                                                 
         ,GRUPO.GEN_ID                                                                
         ,SUB_GRUPO.GEN_ID                                                            
         ,ACME_PROD_ID                                                           
         ,ACME_PROD_ID
         ,PRODUTO.PROD_SITUACAO
         ,ACME_SUB_TIPO                                                               
         ,KARDEX_INT.KDEX_DATA                                                        
         ,DECODE(KARDEX_INT.OPER_REQUER_DEVOL,'S','R',KARDEX_INT.TIPO) -- --DEV. SIMB. DEPOIS DE TODAS AS DEMAIS ENTRADAS 
         ,DECODE(KARDEX_INT.OPER_REQUER_DEVOL,NULL,'N',KARDEX_INT.OPER_REQUER_DEVOL)
         ,KARDEX_INT.KDEX_SEQUENCIA
