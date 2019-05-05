# JIRA Project Forecast

A project forecast report using [PeriscopeData](https://www.periscopedata.com/) based on the [Fivetran](https://fivetran.com) JIRA schema.

## Assumptions

* Your team uses JIRA.
* Your team uses epics for projects/features.
* Each epic has a clear start date and end date, where a relatively stable set of team members are collectively working on the feature; there may be tickets worked on preceding or following those dates, but they aren’t considered since they may not include the entire project team
* The code assumes use of the Fivetran JIRA integration (using the v2 fivetran [schema](https://fivetran.com/docs/applications/jira#schemainformation)), Amazon Redshift (compatible SQL), and [PeriscopeData](https://www.periscopedata.com/) as the analytics tool. Some Periscope features are used such as snippets, filters, and views.

## Notes

* Historical epics chosen towards velocity calculations should be ones worked on by the _same_ team as the epic being forecasted and should represent similar types of projects. The idea is that general team velocity on _all_ work done within a given period of time on _any_ projects is not a good predictor of velocity on any _particular_ project due to the wide variability in the nature of such work.
* You will likely have to tweak this report to fit your organization, but this should be a good starting point
* The report should also be relatively straightforward to migrate to other tools; e.g. different JIRA schemas by a different ETL provider, different data warehouse, different analytics tool, etc.

## Dashboard Filters 

The following periscope filters are setup for the dashboard:

* `epic_issue_number` - the JIRA epic issue key (e.g. `PRJ-123`)
* `epic_start_date` (`[daterange_start]`, periscope's `DateRange` filter) - the start date for the epic (e.g. `2018-11-03`)
* `epic_end_date` (`[daterange_end]`, periscope's `DateRange` filter) - the end date for the epic (e.g. `2018-11-30`)
* `epics_towards_velocity` - a list of epics (epic key and epic name for lables) to include in team velocity calculations. These can be populated based on the following SQL query in the periscope filter configuration:

```sql
[team_epics_snippet]
select epic_key,epic_name from team_epics
```
