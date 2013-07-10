import os
import sys
import operator

#
# Compute frequency of search tokens in a search dataset
# Usage: cat ../data/queries.csv | python word_frequency.py > output.tab
#

def normalize(inWord):
    return inWord.strip().lower()
    
if __name__ == "__main__":
    #Initialize an empty map to store word and its frequency
    words = {}
    
    #process each input line
    for line in sys.stdin:
        #get tokens
        tokens = line.strip().split()
        #iterate over tokens
        for token in tokens:
            #normalize token
            token = normalize(token)
            #if token exists in map, then increment by 1, otherwise add it to map
            if token in words:
                words[token] = words[token] + 1
            else:
                words[token]  = 1

    #sort dictionary by value and print in reverse order
    sorted_list = sorted(words.iteritems(), key=operator.itemgetter(1))
    for item in sorted_list[::-1]:
        print "%d\t%s" % (item[1], item[0])
    
    
    