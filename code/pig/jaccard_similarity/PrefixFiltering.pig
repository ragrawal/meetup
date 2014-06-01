--
-- Computing Jaccard Similarity using Prefix Filtering Approach
-- Idea: From a given global ordering of tokens, select top n tokens where n is the length of prefix. 
-- Use the prefix to determine pairs that might have similarity more than that minimum threshold. 
-- REQUIREMENTS
--   * Uses Enumerate function from datafu library. Make sure to include datafu library and define 
--     Enumerate function i.e DEFINE Enumerate datafu.pig.bags.Enumerate();
--   * For some reason the macro doesn't work if the combiner is on. Hence set the following pig property
--     to false: set pig.exec.nocombiner true;
-- Note:
--   * assumes distinct tokens
--   * generates false positive pairs hence its possible certain combination have 
--     jaccard similarity less than of minimum threshold
--
--
--set pig.exec.nocombiner true;

register 'datafu-1.2.0.jar';
DEFINE Enumerate datafu.pig.bags.Enumerate();


-- Load dataset
tbl = LOAD 'data/movies/rating/u.data' using PigStorage('\t') as (user_id:int, item_id:int, rating:int, timestamp:long);
dataDup = FOREACH tbl GENERATE user_id as user_id, item_id as item_id;
data = DISTINCT dataDup;


-- Generate ordered (DESC) list of tokens. 
tblTokenFrequency = FOREACH (GROUP data by user_id) GENERATE 
						group as user_id,
						COUNT($1) as frequency;

tblRankedTokens = FOREACH (GROUP tblTokenFrequency all) {
							sorted = order $1 by frequency DESC;
							GENERATE 
								flatten(Enumerate(sorted)) AS (user_id, frequency, user_idx);
						};


tblTokenIndex = FOREACH tblRankedTokens GENERATE 
							user_id as user_id,
							user_idx as user_idx;

--
-- Replace user_id BY above calculated user index. This will make
-- future process of selecting top n prefixes easier
--
data = FOREACH (JOIN data BY user_id, tblTokenIndex BY user_id) GENERATE 
				item_id as item_id,
				user_idx as user_idx;


--
-- Compute prefix length and get top n prefixes
-- Copy prefixes in two tables for self join
-- Prefix length = |A| - \tau * |A| + 1
--
IdDescription = FOREACH (GROUP data BY item_id) {
			user_cnt = (float) COUNT(data);
			prefix_size = (int)(user_cnt - $threshold * user_cnt + 1.0);
			prefix = TOP(prefix_size, 1, $1);
			GENERATE
				group as item_id,
				user_cnt as size,
				prefix.$1 as prefix;
		}

PrefixA = FOREACH IdDescription GENERATE
					item_id as item_id,
					flatten(prefix.$0) as user_idx;			

PrefixB = FOREACH PrefixA GENERATE 
					item_id as item_id,
					user_idx as user_idx;


--
-- Join on token_index to get pairs that atleast share one or more 
-- token_index. 
-- Filter: Since J(A, B) = J(B, A) and J(A, A) = 1.0, use id1 > id2 filter to 
-- out duplicate pairs and self join
--
jnPairs = JOIN PrefixA BY user_idx, PrefixB BY user_idx;
prunedPairs = FOREACH (GROUP jnPairs BY (PrefixA::item_id, PrefixB::item_id)) GENERATE 
					flatten(group) as (item_id1, item_id2);					
Pairs = FILTER prunedPairs BY item_id1 < item_id2;

--
-- Get tokens for all the pairs and compute overlap
--
jn3 = JOIN Pairs by item_id1, data by item_id;
jn4 = JOIN jn3 by (item_id2, data::user_idx), data by (item_id, user_idx);
Overlap = FOREACH (GROUP jn4 BY (item_id1, item_id2)) GENERATE
					flatten(group) as (item_id1, item_id2),
					(float)COUNT($1) as overlap_cnt;
--
-- Get number of tokens for id1 and id2 and compute 
-- jaccard similarity
--
jn5 = JOIN Overlap by item_id1, IdDescription by item_id;
jn6 = JOIn jn5 by item_id2, IdDescription by item_id;
tblSimilarity = FOREACH jn6 {
			id1_size = jn5::IdDescription::size;
			id2_size = IdDescription::size;
			GENERATE 
				item_id1 as item_id1,
				item_id2 as item_id2,
				overlap_cnt/(float)(id1_size + id2_size - overlap_cnt) as jaccard_similarity;
		};

store tblSimilarity into 'data/movies/similarity/prefix' using PigStorage(',');


