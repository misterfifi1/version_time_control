
class VersionTimeControlController < ApplicationController
  unloadable

  def index
    @dir = home_url(:only_path => false)
    @custom_field =  Setting.plugin_version_time_control[:contract_field]
    @hours_field = Setting.plugin_version_time_control[:hours_field]
    if @custom_field != "" && @hours_field != ""
      @sql = "SELECT p.name as projectname, v.name, ROUND(sum(t.hours),2) as spent_time, c.customized_id as customid, v.id as version
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
      @main = Version.find_by_sql([@sql])
      @mainList = []
      @issueList = []
      for @time in @main
        @values = CustomValue.where(:customized_id => @time[:customid],:custom_field_id => @hours_field).all
        for @value in @values
          @val = @value[:value]
        end
        if @val
          @percent = ((@time[:spent_time].to_f/@val.to_f) *100)
          @mainList.push(
              {
                  :projectname => @time[:projectname],
                  :name => @time[:name],
                  :version => @time[:version],
                  :spent_time => @time[:spent_time],
                  :percent => @percent,
                  :percentrnd => sprintf("%.2f", @percent.to_f),
                  :estimaed_time => @val.to_f,
                  :percenttofinish => 100 - @percent,
              }
          )
          @issues = Issue.where(:fixed_version_id => @time[:version]).all
          for @issue in @issues
            #recherche de l'utilisateur
            @users = User.where(:id => @issue[:assigned_to_id]).all
            if @users.count > 0
              for @us in @users
                @user = @us[:login]
              end
            end

          #recherche du temps passé
          @sumtime = ""
          @times = TimeEntry.where(:issue_id => @issue[:id]).group(:issue_id).select("SUM(HOURS) as spent")
          for @time in @times
            @sumtime = @time[:spent]
          end
          @issueList.push(
            {
              :fixed_version_id => @issue[:fixed_version_id],
              :label_issue_id => @issue[:id],
              :label_project_plural => @time[:projectname],
              :field_subject => @issue[:subject],
              :field_start_date => @issue[:start_date],
              :label_spent_time => sprintf("%.2f", @sumtime.to_f),
              :field_assigned_to => @user,
            }
          )
          end
        end
      end
    else
      @message = "true"
    end


  end
end
