[non_working_days_snippet]
[team_epics_snippet]

with
  [project_forecast_snippet([daterange_end],[epics_towards_velocity])]
SELECT
  num_weeks_remaining.val as num_weeks_remaining
FROM
  num_weeks_remaining