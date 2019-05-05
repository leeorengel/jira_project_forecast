WITH
[open_epic_tickets_snippet([epic_key])],
[total_epic_tickets_snippet([epic_key])]
SELECT
  1 - round(o.open_tickets / (t.total_tickets * 1.0), 3) as complete_percent
FROM
  open_tickets o, 
  total_tickets t