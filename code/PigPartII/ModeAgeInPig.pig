--
--Task: Determine mode age for each gender group
--

--load the user dataset.
users = LOAD 'data/movies/user/' 
        USING PigStorage('|') 
        AS (userid:int, age:int, gender:chararray, job:chararray, zipcode:chararray);

--extract required columns 
genderData = FOREACH users GENERATE
                gender as gender,
                age as age;

-- Next we group the dataset by gender and age and count number of 
-- users per group
genderAgeCount = FOREACH (GROUP genderData BY (gender, age)) GENERATE
                    FLATTEN(group) as (gender, age),
                    COUNT($1) as cnt;

--
--Above is a very compressed statement and it can be written 
-- much more verbosely as below:
-- genderAgeGroup = Group genderData BY (gender, age);
-- genderAgeCount = FOREACH genderAgeGroup GENERATE
--                group.gender as gender,
--                group.age as age,
--                COUNT(genderData) as cnt;
--


--Again group the dataset by gender and within each group we will 
--sort the data by cnt and pick the topmost record
genderModeAge = FOREACH (GROUP genderAgeCount BY gender) {
                ordered = TOP(3,2,$1);
                GENERATE FLATTEN(ordered) as (gender, age, cnt);
            };

--
-- Alternate Solution (for the last part):
-- genderModeAge = FOREACH (GROUP genderAgeCount By gender) {
--                ordered = ORDER $1 BY cnt DESC, age DESC;
--                mode = LIMIT ordered 1;
--                GENERATE
--                    FLATTEN(mode) as (gender, age, cnt);
--             };
--
dump genderModeAge;
