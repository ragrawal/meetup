set pig.pretty.print.schema true;

register 'myudfs.py' using jython as myudfs;

-- Load dataset
users = LOAD 'data/movies/user/' 
        USING PigStorage('|') 
        AS (userid:int, age:int, gender:chararray, job:chararray, zipcode:chararray);

--extract required columns 
genderData = FOREACH users GENERATE
                gender as gender,
                age as age;


-- group by gender and pass the bag of tuples containing age to udf
genderAgeMode = FOREACH (GROUP genderData BY gender) GENERATE 
                    group as gender,
                    myudfs.Mode($1.(age)) as records:{t:(age:int, cnt:int)};

genderAgeMode = FOREACH genderAgeMode GENERATE 
                    gender as gender,
                    FLATTEN(records) as (age:int, cnt:int);

-- dump results
describe genderAgeMode;
dump genderAgeMode
