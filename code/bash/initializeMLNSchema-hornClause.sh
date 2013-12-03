

echo "List of unground relationships that occur in a rule. Contains name and entity type it belongs to "
time iquery -aq "create array relation<id:int64, name:string, 
                        entity_type: int64,
                        rule_id: int64> 
                        [i=0:*,1000000,0];"



echo "Create tree array..."

time iquery -aq "create array tree<id:int64, name:string, growth_rate:int64, max_height:int64, 
                        max_dbh:int64, max_crown:int64, successional_level:int64, 
                        shade_tolerance_level:int64, coassociation_id:int64> [i=0:*,1000000,0];"

echo "Create atree array..."
time iquery -aq "create array atree<id:int64, latitude:int64, logtitude:int64> [i=0:*,1000000,0];"

echo "Create attribute array..."
# entity_type specifies the entity type of the fact that it belongs to, e.g. 1
# represents it's an attribute for a tree specie or 2 attribute for a specfic plant, so on.
# a fact such as    tree_growthrate("Turkey Oak") : fast

echo "A ground relation. Contains id of the relation. Contains id of the specific entity it belongs to." 
echo "Value and weight of relationship"
time iquery -aq "create array relationship<id:int64, 
                        relation_id:int64, 
                        entity_id: int64, 
                        value:int64, weight:int64> 
                        [i=0:*,1000000,0];"



# This array would store rules(propositions) as a list of conjunctions that leads to a conclusion 
# Joining this with the attributes array and tree array provides groundings for MLN.
time iquery -aq "create array rule<id:int64, > 
                        [i=0:*,1000000,0];"

echo "MLN schema created successfully!"
echo ""
