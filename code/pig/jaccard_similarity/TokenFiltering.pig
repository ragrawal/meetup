--
-- Computing Jaccard Similarity using Token Filtering Approach
-- Idea: Compute jaccard similarity only for those pairs that share atleast one token. 
-- Note:
--   assumes distinct tokens
--   ignores pairs that don't share any token. Hence all pairs that have zero jaccard similarity will 
--         be missing in the output file
--
--

DEFINE JaccardSimilarityTokenFilter(inputData)
RETURNS outData
{
	--
	-- STEP1: Redefine column names of input data
	--
	data = FOREACH $inputData GENERATE 
				$0 AS id1,
				$1 AS token;
	--
	-- STEP 2: Calculate Number of Tokens Per ID
	--
	tblTokenCount = FOREACH (GROUP data by id1) GENERATE
						group as id,0
						COUNT($1) AS size;

	--
	-- STEP 3: Self join on token. 
	--
	tblB = FOREACH data GENERATE 
				id1 as id2, 
				token as token;

	jn =  JOIN data by (token), tblB by (token);
	flt = FILTER jn BY id1 > id2; -- remove duplicate pairs and self join

	tblOverlap = FOREACH (GROUP flt by (id1, id2)) GENERATE 
					flatten(group) as (id1, id2),
					COUNT($1) as overlap;

	-- 
	-- STEP 4: Compute jaccard similarity. In order to compute jaccard similarity,
	-- first get number of tokens for id1 and id2 by joinint tblOverlap to tblTokenCount based on id1 
	-- and id2. Finally jaccard similarity can be calculated as follows
	-- J(A,B) = Overlap(A,B)/ (Size(A) + Size(B) - Overlap(A,B))
	--
	jn1 = JOIN tblOverlap by id1, tblTokenCount by id;
	jn2 = JOIN jn1 by id2, tblTokenCount by id;

	$outData = FOREACH jn2 {
					id1_size = jn1::tblTokenCount::size;
					id2_size = tblTokenCount::size;
					similarity = ((float) overlap) / (id1_size + id2_size - overlap);
					GENERATE 
						id1 as id1,
						id2 as id2,
						similarity as similarity;
				}

};
