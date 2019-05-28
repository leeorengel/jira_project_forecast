num_non_working_days AS (
  SELECT
    count(*) as num_non_working_days
  FROM
      non_working_days
  WHERE
    country = 'US'
    AND non_working_day >= CURRENT_DATE
    AND non_working_day <= [epic_end_date]
),
non_working_days_us AS (
  select
    n.*
  from
    non_working_days n
  where
    n.country = 'US'
),
num_working_days_remaining AS (
  SELECT
    greatest(0,(DATEDIFF(day, CURRENT_DATE, [epic_end_date]) + 1)
    - (SELECT num_non_working_days from num_non_working_days))
    as num_days
),
num_weeks_remaining AS (
  SELECT
    ROUND(num_days / 5.0, 1) AS val
  FROM
    num_working_days_remaining
),
team_epics_for_velocity AS (
  SELECT
    e.*
  from team_epics e
  where
    [epic_key=epics_towards_velocity]
),
-- take all days within the bounds of all epic dates and remove any non-working days
calendar_working_days_for_epic_bounds AS (
  select
    distinct c.*
  from
    calendar_days c
    left join non_working_days_us n on c.calendar_day=n.non_working_day
  where
    c.calendar_day >= (select min(start_date) from team_epics_for_velocity)
    and c.calendar_day <= (select max(end_date) from team_epics_for_velocity)
    and n.non_working_day is null
),
-- only consider the working days which are within the start/end date bounds of at least 1 epic
calendar_working_days_for_epics AS (
  select
    distinct
      ce.calendar_day,
      (EXTRACT(YEAR from date(calendar_day)) || LPAD(EXTRACT(WEEK from date(calendar_day))::text, 2, '0')) :: int as year_week
  from
    team_epics_for_velocity ev
    inner join calendar_working_days_for_epic_bounds ce
      on (ce.calendar_day >= ev.start_date and ce.calendar_day <= ev.end_date)
),
resolved_epic_tickets AS (
  SELECT
    distinct i.key, e.key as epic_key, i.resolved
  FROM
    production_fivetran_jira_v2.issue i
    INNER JOIN production_fivetran_jira_v2.issue_type it ON it.id = i.issue_type
    INNER JOIN production_fivetran_jira_v2.epic e ON e.id = i.epic_link
    inner join team_epics_for_velocity ev on ev.epic_id=i.epic_link and trunc(i.resolved) >= ev.start_date and trunc(i.resolved) <= ev.end_date
  WHERE
    [e.key=epics_towards_velocity]
    AND i.resolved is not null
    AND it.name != 'Epic'
),
total_closed_overall AS (
  select
    count(*) as total_closed
  from
    resolved_epic_tickets
),
total_epic_working_days AS (
  select
    count(*) as num_days
  from
    calendar_working_days_for_epics
),
average_velocity_per_day AS (
  SELECT
    (c.total_closed / (n.num_days * 1.0)) as velocity_per_day
  FROM
    total_closed_overall c,
    total_epic_working_days n
),
average_velocity AS (
  SELECT
    velocity_per_day * 5 as val
  FROM
    average_velocity_per_day
)