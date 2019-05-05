[project_forecast_velocity_snippet([epic_key],[daterange_end],[epic_keys])]
SELECT 
  w.val as avg_throughput_per_week
FROM
  weighted_average_closed_per_week w