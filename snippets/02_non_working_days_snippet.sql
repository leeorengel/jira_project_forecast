-- create this as a SQL snippet in periscope and name it 'non_working_days_snippet'

DROP TABLE IF EXISTS non_working_days;

CREATE TEMP TABLE non_working_days (
non_working_day DATE,
country VARCHAR(50),
notes VARCHAR(100)
);

INSERT INTO non_working_days VALUES
('2018-01-01', 'CA', 'New Years Day'),
('2018-01-01', 'US', 'New Years Day'),
('2018-01-15', 'US', 'Martin Luther King Day'),
('2018-02-19', 'CA', 'Family Day'),
('2018-02-19', 'US', 'Presidents Day'),
('2018-03-30', 'CA', 'Good Friday'),
('2018-05-21', 'CA', 'Victoria Day'),
('2018-05-28', 'US', 'Memorial Day'),
('2018-07-02', 'CA', 'Canada Day'),
('2018-07-04', 'US', 'Independence Day'),
('2018-08-06', 'CA', 'Civic Holiday'),
('2018-09-03', 'CA', 'Labour day'),
('2018-09-03', 'US', 'Labour day'),
('2018-10-08', 'CA', 'Thanksgiving day'),
('2018-11-22', 'US', 'Thanksgiving day'),
('2018-11-23', 'US', 'Day After Thanksgiving day'),
('2018-12-24', 'US', 'Christmas eve'),
('2018-12-25', 'US', 'Christmas day'),
('2018-12-25', 'CA', 'Christmas day'),
('2018-12-26', 'CA', 'Boxing day'),
-- 2019
('2019-01-01', 'CA', 'New Years Day'),
('2019-01-01', 'US', 'New Years Day'),
('2019-01-21', 'US', 'Martin Luther King Day'),
('2019-02-18', 'CA', 'Family Day'),
('2019-02-18', 'US', 'Presidents day'),
('2019-04-19', 'CA', 'Good Friday'),
('2019-05-20', 'CA', 'Victoria Day'),
('2019-05-27', 'US', 'Memorial Day'),
('2019-07-01', 'CA', 'Canada Day'),
('2019-07-04', 'US', 'Independence Day'),
('2019-08-05', 'CA', 'Civic holiday'),
('2019-09-02', 'US', 'Labour Day'),
('2019-09-02', 'CA', 'Labour Day'),
('2019-10-14', 'CA', 'Thanksgiving'),
('2019-11-28', 'US', 'Thanksgiving'),
('2019-11-29', 'US', 'Day after Thanksgiving'),
('2019-12-25', 'CA', 'Christmas Day'),
('2019-12-26', 'CA', 'Boxing Day'),
('2019-12-25', 'US', 'Christmas Day'),
('2019-12-24', 'US', 'Christmas Eve'),
-- 2020
('2020-01-01', 'CA', 'New Years Day'),
('2020-01-01', 'US', 'New Years Day'),
('2020-01-20', 'US', 'Martin Luther King Day'),
('2020-02-17', 'CA', 'Family Day'),
('2020-02-17', 'US', 'Presidents day'),
('2020-04-10', 'CA', 'Good Friday'),
('2020-05-18', 'CA', 'Victoria Day'),
('2020-05-25', 'US', 'Memorial Day'),
('2020-07-01', 'CA', 'Canada Day'),
('2020-07-03', 'US', 'Independence Day (holiday)'),
('2020-07-04', 'US', 'Independence Day'),
('2020-08-03', 'CA', 'Civic holiday'),
('2020-09-07', 'US', 'Labour Day'),
('2020-09-07', 'CA', 'Labour Day'),
('2020-10-12', 'CA', 'Thanksgiving'),
('2020-11-26', 'US', 'Thanksgiving'),
('2020-11-27', 'US', 'Day after Thanksgiving'),
('2020-12-25', 'CA', 'Christmas Day'),
('2020-12-25', 'US', 'Christmas Day'),
('2020-12-26', 'CA', 'Boxing Day');

-- combine holidays with weekends to get all non-working days
INSERT INTO non_working_days (
  WITH weekends AS (
    SELECT  
      calendar_day AS non_working_day,
      'weekend' AS notes
    FROM
      calendar_days
    WHERE
      DATE_PART(DOW, calendar_day) = 0 
      OR DATE_PART(DOW, calendar_day) = 6
  )
  (SELECT w.*, 'CA' AS country FROM weekends w)
  UNION
  (SELECT w.*, 'US' AS country FROM weekends w)
);

