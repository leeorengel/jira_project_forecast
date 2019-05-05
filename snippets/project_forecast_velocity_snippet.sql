-- Usage: project_forecast_velocity_snippet(epic_key,epic_end_date,epics_towards_velocity)

[epic_calendar_days_weeks_snippet([epics_towards_velocity])],
[num_working_days_weeks_remaining_snippet([epic_end_date])],
[open_epic_tickets_snippet([epic_key])],
resolved_epic_tickets AS (
  SELECT
    i.key,
    e.key as epic_key,
    i.resolved
  FROM 
    production_fivetran_jira_v2.issue i
    INNER JOIN production_fivetran_jira_v2.project p ON i.project = p.id
    INNER JOIN production_fivetran_jira_v2.epic e ON e.id = i.epic_link
  WHERE 
    [jira_epics.key=epics_towards_velocity]
    AND i.resolved is not null
    AND i.resolved in (select epic_day from epics_for_velocity_calendar_days)
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
    o.open_tickets - (w.val * n.val) as val
  FROM 
    weighted_average_closed_per_week w, 
    num_weeks_remaining n, 
    open_tickets o
) 