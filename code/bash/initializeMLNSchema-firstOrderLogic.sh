

echo ""
time iquery -aq "create array attribute<id:int64, name:string, 
                        entity_id: int64,
                        weight: int64> 
                        [i=0:*,1000000,0];"

echo ""
time iquery -aq "create array entity<id:int64, name:string, quantifier:bool NULL> [i=0:*,1000000,0];"

echo ""
time iquery -aq "create array binary_relation<id:int64, name:string, entity1:int64, entity2:int64, weight:int64> [i=0:*,1000000,0];"

echo ""
time iquery -aq "create array ternary_relation<id:int64, name:string, entity1:int64, entity2:int64, entity3:int64, weight:int64> [i=0:*,1000000,0];"

echo ""
time iquery -aq "create array rule<id:int64, name:string, weight:int64> [i=0:*,1000000,0];"

echo ""
time iquery -aq "create array rule_relation<rule_id:int64, relation_id:string, entity_type:int64> [i=0:*,1000000,0];"

echo "Grounding"
time iquery -aq ""
