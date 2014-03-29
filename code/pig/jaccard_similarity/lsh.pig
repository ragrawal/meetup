
set pig.pretty.print.schema true;
--set pig.delete.temp.files false;

register 'lsh.py' using jython as lsh;

%declare SIGNATURE_LENGTH 400
%declare NUMBER_OF_ROWS 5


DEFINE JaccardSimilarityLSH(inputData, signature_length, number_of_rows)
RETURNS outData
{

	-- Hack to generate hashes table..
	-- TODO: optimize this step
	hashes = FOREACH (GROUP $inputData all) GENERATE 
				lsh.get_hash_function($signature_length);

	-- STEP 1: Compute Hash Signature for each TOKENIZE
	tokensDup = FOREACH $inputData GENERATE $1 as token;
	tokens = DISTINCT tokensDup;
	tokensSignature = FOREACH tokens GENERATE
						token as token,
						lsh.token_signature(token, $hashes) as signature;


	-- STEP 2: Find MinHash Signature for each id
	data = FOREACH (JOIN $inputData BY ($1), tokensSignature BY (token)) GENERATE 
					$inputData::id as id,
					tokensSignature::signature as signature;


	MinHash = FOREACH (GROUP data BY id) GENERATE 
					group as id,
					lsh.min_hash($1.signature) as signature;


	-- 
	-- STEP 3: split minHash signature into group of r entries and compute hash for each to identify different 
	--         bands 
	--
	tblBandsA = FOREACH MinHash GENERATE 
					id as id1,
					flatten(lsh.bands(signature, (int) $number_of_rows)) as bucket;

	tblBandsB = FOREACH tblBandsA GENERATE 
					id1 as id2,
					bucket as bucket;


	bandPairs = JOIN tblBandsA BY bucket, tblBandsB BY bucket;


	dupPairs = FOREACH (GROUP bandPairs BY (id1, id2)) GENERATE 
					FLATTEN(group) as (id1, id2);

	Pairs = FILTER dupPairs BY id1 > id2;

	-- 
	-- STEP 4: As a approximation, we can simply compare
	--         minHash signature to get jaccard values. 
	--         Thus join with MinHash to get signature for each
	--         pair
	--
	jn1 = JOIN Pairs BY (id1), MinHash BY (id);
	jn2 = JOIN jn1 BY (id2), MinHash BY (id);
	$outData = FOREACH jn2 GENERATE 
					id1 as id1,
					id2 as id2,
					lsh.compare_signature(jn1::MinHash::signature, MinHash::signature) as similarity;

};

inputData = load 'data.csv' as (id:chararray, token:chararray);
outputData = JaccardSimilarityLSH(inputData, SIGNATURE_LENGTH, NUMBER_OF_ROWS);
store outputData into 'lsh.out';

