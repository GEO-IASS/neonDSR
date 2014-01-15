

#time iquery -aq "cross(rule_relation, ternary_relation)"

iquery -aq "show('
  cross(cross(cross(ternary_relation, entity),entity), entity)
  
   
  '
  , 'afl');"  


  #cross(binary_relation, entity)
