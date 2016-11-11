drop table if exists medintsev.MA1796_fee_thresholds;
create external table medintsev.MA1796_fee_thresholds (
    hid int,
  fee_threshold double
)
row format delimited
        fields terminated by ';'
        lines terminated by '\n'
stored as textfile
location '/user/medintsev/MARKETANSWERS-1796/data';