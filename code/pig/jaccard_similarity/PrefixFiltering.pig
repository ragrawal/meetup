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

set pig.exec.nocombiner true;

register 'datafu-1.2.0.jar';
DEFINE Enumerate datafu.pig.bags.Enumerate();

DEFINE JaccardSimilarityPrefixFiltering(inputData, threshold)
RETURNS outData
{
	
	--
	-- Compute Token Frequency and  assign global ordering based on frequency 
	--
	tblTokenFrequency = FOREACH (GROUP $inputData by $1) GENERATE 
							group as token,
							COUNT($1) as frequency;	

	tblRankedTokens = FOREACH (GROUP tblTokenFrequency all) {
							sorted = order $1 by frequency ASC;
							GENERATE 
								flatten(Enumerate(sorted)) AS (token, freq, token_index);
						}

	tblTokenIndex = FOREACH tblRankedTokens GENERATE 
							token as token,
							token_index as token_index;

	--
	-- Replace tokens BY above calculated token index. This will make
	-- future process of selecting top n prefixes easier
	--
	data = FOREACH (JOIN $inputData BY $1, tblTokenIndex BY token) GENERATE 
				$0 as id,
				token_index as token_index;


	--
	-- Compute prefix length and get top n prefixes
	-- Copy prefixes in two tables for self join
	-- Prefix length = |A| - \tau * |A| + 1
	--
	IdDescription = FOREACH (GROUP data BY id) {
				token_cnt = COUNT($1);
				prefix_size = (int)(token_cnt - $threshold * token_cnt + 1);
				prefix = TOP(prefix_size, 0, $1.token_index);
				GENERATE
					group as id,
					token_cnt as size,
					prefix.$0 as prefix;
			}

	PrefixA = FOREACH IdDescription GENERATE
						id as id1,
						flatten(prefix.$0) as token_index;			

	PrefixB = FOREACH PrefixA GENERATE 
						id1 as id2,
						token_index as token_index;


	--
	-- Join on token_index to get pairs that atleast share one or more 
	-- token_index. 
	-- Filter: Since J(A, B) = J(B, A) and J(A, A) = 1.0, use id1 > id2 filter to 
	-- out duplicate pairs and self join
	--
	jnPairs = JOIN PrefixA BY (token_index), PrefixB BY (token_index);
	prunedPairs = FOREACH (GROUP jnPairs BY (id1, id2)) GENERATE 
						flatten(group) as (id1, id2);
	Pairs = FILTER prunedPairs BY id1 > id2;

	--
	-- Get tokens for all the pairs and compute overlap
	--
	jn3 = JOIN Pairs by (id1), data by (id);
	jn4 = JOIN jn3 by (id2, data::token_index), data by (id, token_index);
	Overlap = FOREACH (GROUP jn4 BY (id1, id2)) GENERATE
						flatten(group) as (id1, id2),
						COUNT($1) as overlap_cnt;
	--
	-- Get number of tokens for id1 and id2 and compute 
	-- jaccard similarity
	--
	jn5 = JOIN Overlap by (id1), IdDescription by (id);
	jn6 = JOIn jn5 by (id2), IdDescription by (id);
	tblSimilarity = FOREACH jn6 {
				id1_size = jn5::IdDescription::size;
				id2_size = IdDescription::size;
				GENERATE 
					id1 as id1,
					id2 as id2,
					overlap_cnt/(float)(id1_size + id2_size - overlap_cnt) as jaccard_similarity;
			}

	$outData= FILTER tblSimilarity BY jaccard_similarity >= $threshold;

};		


inputData = load 'data.csv' as (id:chararray, token:chararray);
outputData = JaccardSimilarityPrefixFiltering(inputData, 0.6);
store outputData into 'PrefixFiltering.out';
