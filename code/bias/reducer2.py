import sys
import os

last_movie = None
gender_count = {'M':0, 'F':0}

for line in sys.stdin:
    key, value = line.strip().split("\t", 1)
    movie, record = key.strip().split("|")
    
    if movie != last_movie:
            last_movie = movie
            gender_count = {'M': 0, 'F': 0}
    
    if 0 == int(record):
        gender, cnt = value.strip().split("\t")
        if not gender in ['M','F']: 
            raise Exception("Unknown gender type: {gender}".format(gender=gender))
        gender_count[gender] = gender_count[gender] + int(cnt)
    elif 1 == int(record): 
        print "{genre}\t{male_count}\t{female_count}".format(genre=value,
            male_count=gender_count['M'],
            female_count=gender_count['F']
        )
    
    
