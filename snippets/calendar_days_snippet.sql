-- Create table of previous, current, and next years
DROP TABLE IF EXISTS calendar_years;
CREATE TEMP TABLE calendar_years (
  year INT
);

INSERT INTO calendar_years VALUES 
(2018),
(2019),
(2020);

-- Create surrogate sequence table to populate calendar days for each year
-- https://www.periscopedata.com/blog/generate-series-in-redshift-and-mysql
DROP TABLE IF EXISTS calendar_sequence;
CREATE TEMP TABLE calendar_sequence (
  n int
);

INSERT INTO calendar_sequence (
  SELECT 
    row_number() OVER (order by true) AS n 
  FROM 
    users -- presumes a users table. Any table with enough rows in it to fill 365 days can work.
  LIMIT 365
);

DROP TABLE IF EXISTS calendar_days;
CREATE TEMP TABLE calendar_days (
year INT,
doy INT,
calendar_day DATE
);

INSERT INTO calendar_days (
  SELECT
    y.year,
    s.n AS doy,
    to_date(y.year || ' ' || LPAD(s.n, 3, '0'), 'YYYY DDD') AS calendar_day
  FROM 
    calendar_sequence s INNER JOIN calendar_years y ON 1=1
);
--
