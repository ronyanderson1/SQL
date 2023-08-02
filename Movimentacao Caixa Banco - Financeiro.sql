    SELECT                                                       

      L.MVCB_EMP_ID, L.BCO_EMP_ID, L.BCO_ID, L.DATA, L.DOCUM,    
      L.MOVIMENTO, B.BCO_DESC, SUM(L.VALOR) VALOR                

    FROM                                                         
      (                                                          
         SELECT                                                  
             MVCB_EMP_ID                                         
             , MVCB_BCO_EMP_ID_BCO_CRED_DE            BCO_EMP_ID 
             , MVCB_BCO_ID_BCO_CRED_DE                BCO_ID     
             , MVCB_DTA_CRED                          DATA       
             , MVCB_NR_CHEQUE                         DOCUM      
             , MVCB_VLR_CRE                           VALOR      
             , MVCB_TP_MOVIM                          MOVIMENTO  
             , MVCB_USR_ID                                       

           FROM                                                  
             MOV_CX_BCO                                          
           WHERE                                                 
             MVCB_TP_MOVIM = 'S'
         UNION ALL 
         SELECT                                        
             MVCB_EMP_ID                                         
             , MVCB_BCO_EMP_ID_BCO_DEB_DE             BCO_EMP_ID 
             , MVCB_BCO_ID_BCO_DEB_DE                 BCO_ID     
             , MVCB_DTA_CRED                          DATA       
             , MVCB_NR_CHEQUE                         DOCUM      
             , MVCB_VLR_DEB                           VALOR      
             , MVCB_TP_MOVIM                          MOVIMENTO  
             , MVCB_USR_ID                                       
           FROM                                                  
             MOV_CX_BCO                                          
           WHERE                                                 
             MVCB_TP_MOVIM =  'E'
        ) L                                                      
        , BANCO B                                                
      WHERE                                                      
        (L.BCO_EMP_ID = B.BCO_EMP_ID)                            
      AND (L.BCO_ID = B.BCO_ID)                                
      AND (                                                      
            (TRUNC(L.DATA) >= TO_DATE( '01/06/2023', 'DD/MM/YYYY')) --- altere aqui
            AND                                                                      
            (TRUNC(L.DATA) <= TO_DATE('30/06/2023','DD/MM/YYYY')) --- alterar aqui 
          )                                                                        
      AND (L.DATA NOT IN
            (SELECT CALE_CALE_DATA                                                 
              FROM CALENDARIO_ATV_T                                                
                WHERE                                                              
                  (CALE_CALE_EMP_ID = 2   )                 
                  AND (CALE_TAREFA = 1)))                                          
      AND (                                                                        
           (L.MVCB_EMP_ID, L.BCO_EMP_ID, L.BCO_ID, L.DATA, L.DOCUM, L.MOVIMENTO) NOT IN 
           (SELECT                                                                      
                ACXB_EMP_ID, ACXB_BCO_EMP_ID, ACXB_BCO_ID, ACXB_DATA, ACXB_DOCUM, ACXB_TIPO 
              FROM                                                                          
                ACUM_CX_BCO_H                                                               
              WHERE                                                                         
                (ACXB_EMP_ID =  2 )                                 
                AND (ACXB_ORIGEM IN (2,3))                                                  
           )                                                                                
          )                                                                                 
        AND (L.MVCB_EMP_ID = 2 )                                     
      GROUP BY                                                                              
        L.MVCB_EMP_ID, L.BCO_EMP_ID, L.BCO_ID, L.DATA,                                      
        L.DOCUM, L.MOVIMENTO, B.BCO_DESC                                                    
      ORDER BY                                                                              
        L.DATA, B.BCO_DESC, L.DOCUM
