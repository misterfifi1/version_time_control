class VersionTimeControlController < ApplicationController
  unloadable

  def index
    @custom_field =  Setting.plugin_version_time_control[:contract_field]

    if @custom_field != ""
      @list = "SELECT v.name, ROUND(sum(t.hours),2) as spent_time,
      ROUND(sum(i.estimated_hours)/count(t.id),2) as estimaed_time,
      ROUND((sum(t.hours) / (sum(i.estimated_hours)/count(t.id)))*100,2) as percent,
      100 - ROUND((sum(t.hours) / (sum(i.estimated_hours)/count(t.id)))*100,2) as percenttofinish
      FROM   time_entries as t, versions as v,
             issues as i, projects as p,
             custom_values as c
      WHERE t.issue_id = i.id
         and i.fixed_version_id = v.id
         and i.project_id = p.id
         and v.`status` = 'open'
         and v.id = c.customized_id
         and c.value = 1
         and c.custom_field_id = " + @custom_field + " GROUP BY t.issue_id"
    else
      @list = "SELECT v.name, ROUND(sum(t.hours),2) as spent_time,
      ROUND(sum(i.estimated_hours)/count(t.id),2) as estimaed_time,
      ROUND((sum(t.hours) / (sum(i.estimated_hours)/count(t.id)))*100,2) as percent,
      100 - ROUND((sum(t.hours) / (sum(i.estimated_hours)/count(t.id)))*100,2) as percenttofinish
      FROM time_entries as t, versions as v, issues as i, projects as p
      WHERE t.issue_id = i.id
        and i.fixed_version_id = v.id
        and i.project_id = p.id
        and v.`status` = 'open'
      GROUP BY t.issue_id"
    end

    @versions = Version.find_by_sql([@list])
  end
end
