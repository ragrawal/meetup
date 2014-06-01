REGISTER datafu-1.2.0.jar
define SetIntersect datafu.pig.sets.SetIntersect();
define SetUnion datafu.pig.sets.SetUnion();

-- Load Dataset twice for self join
tbl = LOAD 'data/movies/rating/u.data' using PigStorage('\t') as (user_id:int, item_id:int, rating:int, timestamp:long);
data = FOREACH tbl GENERATE user_id as user_id, item_id as item_id;


dataA = FOREACH (GROUP data BY item_id) {
            sorted = ORDER data by user_id;
            GENERATE 
                1 as key,
                group as item_id,
                sorted.user_id as users;  
        };

dataA = FILTER dataA by COUNT(users) > 0 and item_id is not null and item_id > 0;

dataB = FOREACH dataA GENERATE 
            key AS key,
            item_id as item_id,
            users as users;

-- Join Dataset 
jn = JOIN dataA by key, dataB by key;
-- jn = FILTER jn by dataA::item_id < dataB::item_id;  -- since J(A,B) = J(B,A), we can remove more than half such computation
jaccard = FOREACH jn {
                num = (float) COUNT(SetIntersect(dataA::users, dataB::users));
                deno = (float) COUNT(SetUnion(dataA::users, dataB::users));
                GENERATE 
                    dataA::item_id as item1,
                    dataB::item_id as item2,
                    num/deno as similarity;                    
            };
STORE jaccard into 'data/movies/similarity/basic' using PigStorage(',');







