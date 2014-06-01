--
-- Computing Jaccard Similarity using Token Filtering Approach
-- Idea: Compute jaccard similarity only for those pairs that share atleast one token. 
-- Note:
--   assumes distinct tokens
--   ignores pairs that don't share any token. Hence all pairs that have zero jaccard similarity will 
--         be missing in the output file
--
--

-- Load Dataset 
tbl = LOAD 'data/movies/rating/u.data' using PigStorage('\t') as (user_id:int, item_id:int, rating:int, timestamp:long);
dataDup = FOREACH tbl GENERATE user_id as user_id, item_id as item_id;
dataA = DISTINCT dataDup;

-- Calculate Number of users per item
userCntPerItem = FOREACH (GROUP dataA by item_id) GENERATE 
						group as item_id,
						(float) COUNT(dataA) as size;

-- Self join on user so that we only compare those items that share one or more users
dataB = FOREACH dataA GENERATE 
			item_id as item_id,
			user_id as user_id;
jn = JOIN dataA by (user_id), dataB by (user_id);
flt = FILTER jn by dataA::item_id < dataB::item_id;
overlap = FOREACH (GROUP flt BY (dataA::item_id, dataB::item_id)) GENERATE 
				FLATTEN(group) as (item_id1, item_id2),
				(float) COUNT(flt) as intersect;

-- Jaccard Similarity = intersect / (size(A) + size(B) - intersect)					
-- hence join overlap with userCntPerItem twice. Once for A and once for B
jn1 = JOIN overlap by item_id1, userCntPerItem by item_id using 'replicated';
jn2 = JOIN jn1 by item_id2, userCntPerItem by item_id using 'replicated';

jaccard = FOREACH jn2 GENERATE 
					item_id1 as item_id1,
					item_id2 as item_id2,
					intersect/(jn1::userCntPerItem::size + userCntPerItem::size - intersect) as similarity;

store jaccard into 'data/movies/similarity/token' using PigStorage(',');
                                                                                                                                                              


