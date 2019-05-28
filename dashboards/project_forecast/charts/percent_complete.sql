WITH
  [open_epic_tickets_snippet],
  [total_epic_tickets_snippet]
SELECT
    1 - round(o.open_tickets / (t.total_tickets::float), 3) as complete_percent
FROM
  open_tickets o,
  total_tickets t