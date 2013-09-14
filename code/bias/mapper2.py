import os
import sys

genre_columns = []
fp = open("genre_mapping",'r')
for line in fp:
    column, cateogry = line.strip().split("\t")
    genre_columns.append(int(column))
fp.close()


for line in sys.stdin:
    filepath = os.environ["map_input_file"]
    
    if "data/movies/item" in filepath:
        #print movie genre pair
        tokens = line.strip().split("|")
        movie = tokens[0].strip()
        for col in genre_columns:
            if 1==int(tokens[col]):
                print "{movie}|1\t{genre}".format(movie=movie, genre=col)

    elif "data/step1" in filepath:
        movie, gender = line.strip().split("\t")
        print "{movie}|0\t{gender}\t1".format(movie=movie, gender=gender)