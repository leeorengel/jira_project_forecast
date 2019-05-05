-- create this as a SQL snippet in periscope and name it 'team_epics_snippet'

CREATE TEMP TABLE team_epics (
  epic_key VARCHAR,
  epic_name VARCHAR,
  start_date DATE,
  end_date DATE
);

-- Example JIRA epics. Change to your epics, and adjust start & end dates accordingly.
INSERT INTO team_epics VALUES
('PRJ-123', 'Project Milestone 1', '2018-10-22','2018-11-13'),
('PRJ-456', 'Project Milestone 2', '2018-11-05','2018-11-30'),
('PRJ-789', 'Project Milestone 3', '2018-12-03','2019-01-15');
