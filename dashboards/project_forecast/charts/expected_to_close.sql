[non_working_days_snippet]
[team_epics_snippet]

with
  [project_forecast_snippet([daterange_end],[epics_towards_velocity])]
SELECT
    v.val * n.val as expected_to_close
FROM
  average_velocity v,
  num_weeks_remaining n