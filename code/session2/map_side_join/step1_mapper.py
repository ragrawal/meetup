import sys
import os

user_info = {}
with open(sys.argv[1], 'r') as fp:
    for line in fp.readline():
        tokens = line.strip().split('|')
        user_info[tokens[0].strip()] = tokens[2].strip()

for line in sys.stdin:
    user, movie, values= line.strip().split("\t", 2)
    