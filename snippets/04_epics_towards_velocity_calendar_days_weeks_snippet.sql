[non_working_days_snippet]
[team_epics_snippet]

WITH team_epics_for_velocity AS (
  SELECT 
    epic_key,
    epic_name,
    start_date,
    end_date,
    DATEDIFF(DAY, start_date, end_date) + 1 AS num_days
  FROM
    team_epics
  WHERE
    epic_key IN ([epics_towards_velocity])
),
-- create an initially sparse result set with the start day of each epic filled in
calendar_days_with_epic_start_days AS (
  SELECT 
    c.calendar_day AS epic_day,
    e.epic_key,
    e.num_days,
    row_number() OVER (ORDER BY c.calendar_day) AS row_num
  FROM
    calendar_days c
    LEFT OUTER JOIN team_epics_for_velocity e ON c.calendar_day=e.start_date
  WHERE
    c.calendar_day >= (SELECT MIN(start_date) FROM team_epics_for_velocity)
    AND c.calendar_day <= (SELECT MAX(end_date) FROM team_epics_for_velocity)
  ORDER BY c.calendar_day desc
),
-- fill in applicable blank days in initial result set with each day within each epic's start & end boundaries
calendar_days_with_epic_days AS (
  SELECT
    e2.epic_day,
    e1.row_num AS e1_row_num,
    e2.row_num AS e2_row_num,
    CASE 
      WHEN 
          e1.epic_key IS NOT NULL AND e1.row_num != e2.row_num 
        AND 
          e2.row_num > e1.row_num AND e2.row_num <= e1.row_num + e1.num_days - 1
      THEN
        e1.epic_key        
      WHEN 
        e1.epic_day = e2.epic_day
      THEN
        e1.epic_key
      ELSE 
        null 
      END AS epic,
    e1.num_days
  from 
    calendar_days_with_epic_start_days e1 JOIN calendar_days_with_epic_start_days e2 ON 1=1
),
-- remove all other non-matching calendar days which did not have ongoing work on some epic. consolidate overlapping epic days
epics_for_velocity_calendar_days AS (
  SELECT 
    DISTINCT 
      (EXTRACT(YEAR from date(epic_day)) || LPAD(EXTRACT(WEEK from date(epic_day))::text, 2, '0')) :: int as year_week,
      epic_day
  from 
    calendar_days_with_epic_days
  WHERE 
    epic IS NOT NULL
  ORDER BY epic_day
),
-- group calendar days into week buckets by their week number's in order to produce weighted average values for each week.                                                   
epics_for_velocity_calendar_weeks AS (
  SELECT 
    e.year_week,
    count(*) AS weighted_average
  FROM
    epics_for_velocity_calendar_days e
  WHERE
    e.epic_day NOT IN (SELECT non_working_day FROM non_working_days)
  GROUP BY e.year_week
)
