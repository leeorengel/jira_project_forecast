total_tickets AS (
SELECT 
  count(*) as total_tickets
FROM 
  production_fivetran_jira_v2.issue i
  INNER JOIN production_fivetran_jira_v2.project p ON i.project = p.id
  INNER JOIN production_fivetran_jira_v2.epic e ON e.id = i.epic_link
WHERE 
  e.key = '[epic_key]'
)