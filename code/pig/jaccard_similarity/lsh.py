import sys
import os
import random

@outputSchema("func: {(a:long, b:long)}")
def get_hash_functions(n=400):
	'''Generates random set of hash function'''
	records = []
	for i in range(n):
		a = random.randint(0, sys.maxint)
		b = random.randint(0, sys.maxint)
		records.append(tuple([a, b]))
	return records


@outputSchema("{(sig:long)}")
def token_signature(token, hashes):
	''''For a given token, apply different hash function'''
	if not hashes or len(hashes) == 0: 
		raise Exception("ERROR: invalid hash function: " + str(hashes))

	signature = []
	c = sys.maxint
	for idx, hash_func in enumerate(hashes):
		a = hash_func[0]
		b = hash_func[1]		
		hash_value = (a + hash(token) * b) % c
		signature.append(tuple([hash_value]))
	return signature


@outputSchema("{(sig:long)}")
def min_hash(signatures):
	'''Calculates minhash for each index'''
	if len(signatures) < 2: 
		raise Exception("ERROR: Invalid signature length: {0}".format(len(signatures)))
	
	signature_length = len(signatures[0][0])

	#copy first signature in min_hash
	min_hash = [col[0] for col in signatures[0][0]]

	#update min_hash based on second signature and forth
	for record in signatures[1:]:
		signature = record[0]
		if len(signature) != signature_length:
			raise Exception("Error: Expecting signature of size " + str(signature_length) + " but found " \
				"signature of size " + str(len(signature)) + ": " + str(signature))
		for idx in range(0, signature_length):
			if min_hash[idx] > signature[idx][0]: 
				min_hash[idx] = signature[idx][0]

	return [tuple([v]) for v in min_hash]

@outputSchema("{(bucket:int)}")
def bands(signature, rows):
	values = [i[0] for i in signature]
	buckets = []
	no_of_bands = (int)(len(values)/rows)
	for i in range(no_of_bands):
		cols = tuple(values[i*rows:i*rows+rows])
		buckets.append(tuple([hash(cols)]))
	return buckets

@outputSchema("double")
def compare_signature(sig1, sig2):
	val1 = [i[0] for i in sig1]
	val2 = [i[0] for i in sig2]

	k = len(val1)
	if k != len(val2):
		raise Exception("Error: Signatures have different lengths")

	counter = 0.0
	for i in range(k): 
		counter += int(val1[i] == val2[i])

	return counter/k