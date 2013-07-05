import os
import sys

def normalize(inWord):
    return inWord.strip().lower()
    
if __name__ == "__main__":
    """Compute frequency of search tokens"""
    
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

    #print search tokens and its frequency 
    for word in words:
        print "%s\t%s" % (words[word], word)
    
    