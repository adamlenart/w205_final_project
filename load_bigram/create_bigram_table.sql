CREATE EXTERNAL TABLE IF NOT EXISTS bigram
(phrase string,
year string,
match_count int,
volume_count int)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE
LOCATION '/user/w205/literaly/bigram';
