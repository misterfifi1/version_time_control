
class VersionTimeControlController < ApplicationController
  unloadable

  def index
    @custom_field =  Setting.plugin_version_time_control[:contract_field]
    @hours_field = Setting.plugin_version_time_control[:hours_field]
    if @custom_field != "" && @hours_field != ""
      @sql = "SELECT p.name as projectname, v.name, ROUND(sum(t.hours),2) as spent_time, c.id as customid, v.id as version
      FROM   time_entries as t, versions as v,
             issues as i, projects as p,
             custom_values as c
      WHERE t.issue_id = i.id
         and i.fixed_version_id = v.id
         and i.project_id = p.id
         and v.`status` = 'open'
         and v.id = c.customized_id
         and c.value = 1
         and c.custom_field_id = " + @custom_field +"
         GROUP BY v.id"
      @issues = Version.find_by_sql([@sql])
      @liste = []
      for @time in @issues
        @values = CustomValue.where(:customized_id => @time[:customid],:custom_field_id => @hours_field).all
        for @value in @values
          @val = @value[:value]
        end
        if @val
          @percent = ((@time[:spent_time].to_f/@val.to_f) *100)
          @liste.push(
              {
                        :projectname => @time[:projectname],
                        :name => @time[:name],
                        :version => @time[:version],
                        :spent_time => @time[:spent_time],
                        :percent => @percent,
                        :percentrnd => sprintf( "%.2f", @percent.to_f ),
                        :estimaed_time => @val.to_f,
                        :percenttofinish => 100 - @percent,
                    }
          )
        end
      end
    else
      @message = "Merci de configurer le plugin"
    end


  end
end
