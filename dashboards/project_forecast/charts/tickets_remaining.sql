[non_working_days_snippet]
[team_epics_snippet]

WITH
  [open_epic_tickets_snippet],
  [total_epic_tickets_snippet],
  [project_forecast_snippet([daterange_end],[epics_towards_velocity])]
SELECT
    o.open_tickets - (v.val * n.val) as delta_in_tickets
FROM
  average_velocity v,
  num_weeks_remaining n,
  open_tickets o