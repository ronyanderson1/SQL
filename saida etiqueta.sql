SELECT 
  s.etqp_liqu_id, 
  TO_DATE(s.etqp_dta_saida,'dd/mm/yyyy') dia
 from saida_etiquetas s
  
GROUP BY 
  s.etqp_liqu_id, 
  TO_DATE(s.etqp_dta_saida,'dd/mm/yyyy')


ORDER BY 2 DESC
