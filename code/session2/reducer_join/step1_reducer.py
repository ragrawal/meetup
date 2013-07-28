import os
import sys

last_user = None
last_gender = None
rated_movies = []

def output():
    if not last_user or not last_gender or len(rated_movies) == 0: return
    for movie in rated_movies:
        print "\t".join([movie, last_user, last_gender])
    
for line in sys.stdin:
    userid, record, value = line.strip().split("\t")
    
    if userid != last_user:
        output()
        last_user = userid
        last_gender = None
        rated_movies = []
        
    if record == "USER":
        last_gender = value
    else if record == "RATING":
        rated_movies.append(value)

#print last user
output()

    
        