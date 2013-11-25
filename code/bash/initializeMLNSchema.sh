time iquery -aq "create array tree<id:int64, name:string, growth_rate:int64, max_height:int64, 
                      max_dbh:int64, max_crown:int64, successional_level:int64, 
                      shade_tolerance_level:int64, coassociation_id:int64> [i=0:*,1000000,0];"


time iquery -aq "create array atree<id:int64, latitude:int64, logtitude:int64> [i=0:*,1000000,0];"

# attrib_parent_type specifies the entity type of the attribute that it belongs to, e.g. 1
# represents it's an attribute for a tree specie or 2 attribute for a specfic plant, so on.
time iquery -aq "create array attribute<id:int64, attrib_name:string, entity_type: int64,
                       entity_id: int64, value:int64> [i=0:*,1000000,0];"


