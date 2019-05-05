[project_forecast_velocity_snippet([epic_key],[daterange_end],[epic_keys])]
SELECT 
  w.val * n.val as expected_to_close
FROM
  weighted_average_closed_per_week w, 
  num_weeks_remaining n