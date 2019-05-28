DROP TABLE IF EXISTS team_epics;
CREATE TEMP TABLE team_epics (
                               epic_id int,
                               epic_key VARCHAR,
                               epic_name VARCHAR,
                               start_date DATE,
                               end_date DATE
);

-- Example JIRA epics. Change to your epics, and adjust start & end dates accordingly.
-- It should also be straight-forward to pull this data directly from JIRA if you have custom fields for epic start/end dates too.
INSERT INTO team_epics VALUES
(1, 'PRJ-123', 'Project Milestone 1', '2018-10-22','2018-11-13'),
(2, 'PRJ-456', 'Project Milestone 2', '2018-11-05','2018-11-30'),
(3, 'PRJ-789', 'Project Milestone 3', '2018-12-03','2019-01-15');