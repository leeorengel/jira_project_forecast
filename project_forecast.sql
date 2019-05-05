
[epic_calendar_days_weeks_snippet([epics_towards_velocity])],
 
num_working_days_remaining AS (
  SELECT 
    (DATEDIFF(day, CURRENT_DATE, '[epic_end_date]') + 1)
    - 
    (SELECT count(*) 
    FROM
      non_working_days 
    WHERE 
      country = 'US'
      AND non_working_day >= CURRENT_DATE
      AND non_working_day <= '[epic_end_date]') 
    as num_days
),
num_weeks_remaining AS (
  SELECT 
    ROUND(num_days / 5.0, 1) AS val
  FROM 
    num_working_days_remaining
),
open_tickets AS (
  SELECT 
    count(*) as val
  FROM production_fivetran_jira_v2.issue AS jira_issues
    INNER JOIN production_fivetran_jira_v2.project AS jira_projects ON jira_issues.project = jira_projects.id
    INNER JOIN production_fivetran_jira_v2.epic AS jira_epics ON jira_epics.id = jira_issues.epic_link
  WHERE 
    jira_epics.key = '[epic_issue_number]'
    AND jira_issues.resolved IS NULL
),
total_tickets AS (
  SELECT 
    count(*) as val
  FROM production_fivetran_jira_v2.issue AS jira_issues
    INNER JOIN production_fivetran_jira_v2.project AS jira_projects ON jira_issues.project = jira_projects.id
    INNER JOIN production_fivetran_jira_v2.epic AS jira_epics ON jira_epics.id = jira_issues.epic_link
  WHERE 
    jira_epics.key = '[epic_issue_number]'
),
percent_complete AS (
  SELECT
    1 - round(open_tickets.val / (total_tickets.val * 1.0), 3) as val
  FROM
    open_tickets, 
    total_tickets
),
resolved_epic_tickets AS (
  SELECT
    jira_issues.key,
    jira_epics.key as epic_key,
    jira_issues.resolved
  FROM 
    production_fivetran_jira_v2.issue AS jira_issues
    INNER JOIN production_fivetran_jira_v2.project AS jira_projects ON jira_issues.project = jira_projects.id
    INNER JOIN production_fivetran_jira_v2.epic AS jira_epics ON jira_epics.id = jira_issues.epic_link
  WHERE 
    [jira_epics.key=epics_towards_velocity]
    AND jira_issues.resolved is not null
    AND resolved in (select epic_day from epics_for_velocity_calendar_days)
),
tickets_closed_per_week AS (
  SELECT 
  	(EXTRACT(YEAR FROM date(resolved)) || LPAD(EXTRACT(WEEK FROM date(resolved))::text, 2, '0')) :: int AS year_week,
  	count(*) as tickets_closed
  FROM 
    resolved_epic_tickets
  GROUP BY year_week
  ORDER BY year_week
),
tickets_closed_by_weighted AS (
  SELECT
    w.year_week,
    w.weighted_average,
    case when tickets_closed is null then 0 else tickets_closed end as tickets_closed
  FROM
    epics_for_velocity_calendar_weeks w
    LEFT OUTER JOIN tickets_closed_per_week tc ON tc.year_week=w.year_week
  ORDER BY year_week
),
weighted_average_closed_per_week AS (
  SELECT
    SUM(tickets_closed * weighted_average * 1.0) / SUM(weighted_average) as val 
  FROM
    tickets_closed_by_weighted
),
over_under AS (
  SELECT 
    open_tickets.val - (weighted_average_closed_per_week.val * num_weeks_remaining.val) as val
  FROM 
    weighted_average_closed_per_week, 
    num_weeks_remaining, 
    open_tickets
)
SELECT 
  open_tickets.val AS open_tickets,
  total_tickets.val AS total_tickets,
  percent_complete.val as percent_complete, 
  weighted_average_closed_per_week.val as weighted_average_closed_per_week,
  num_weeks_remaining.val as num_weeks_remaining,
  (weighted_average_closed_per_week.val * num_weeks_remaining.val) as expected_to_close,
  over_under.val as over_under
FROM
  open_tickets,
  total_tickets,
  percent_complete, 
  weighted_average_closed_per_week, 
  num_weeks_remaining, 
  over_under
