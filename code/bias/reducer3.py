import os
import sys

last_genre = None
gender_count = [0, 0]
genre_columns = {}

def populate_genre():
    fp = open("genre_mapping",'r')
    for line in fp:
        column, category = line.strip().split("\t")
        genre_columns[int(column)] = category
    fp.close()
    


def output_combiner():
    print "{genre}\t{males}\t{females}".format(
                genre=last_genre,
                males=gender_count[0],
                females=gender_count[1]
        )

def output_reducer():
    print "{genre}\t{males}\t{females}".format(
                genre=genre_columns[last_genre],
                males=gender_count[0],
                females=gender_count[1]
            )

if __name__ == "__main__":
    type = sys.argv[1].strip()
    if type != "combiner": populate_genre()
    
    for line in sys.stdin:
       
        genre, male_count, female_count = [int(x) for x in line.strip().split("\t")]
    
        if genre != last_genre:
            if last_genre != None:
                if type == "combiner": 
                    output_combiner()
                else:
                    output_reducer() 
            last_genre = genre
            gender_count = [0, 0]
    
        gender_count[0] = gender_count[0] + male_count
        gender_count[1] = gender_count[1] + female_count

    if type == "combiner": output_combiner()
    else: output_reducer() 
        