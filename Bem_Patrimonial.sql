select pb.bem_flg_status, pb.*

from pat_bem pb

where pb.bem_id between 1857 and 1857

and   pb.bem_flg_status = 1 -- indica registro marcado como exclu�do (n�o considera nos c�lculos/apropria��o)

order by pb.bem_id

for update
  
