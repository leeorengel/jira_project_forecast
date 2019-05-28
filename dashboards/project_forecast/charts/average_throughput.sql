[non_working_days_snippet]
[team_epics_snippet]

WITH
  [project_forecast_snippet([daterange_end],[epics_towards_velocity])]
SELECT
  v.val
FROM
  average_velocity v