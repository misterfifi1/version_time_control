require 'redmine'

Redmine::Plugin.register :version_time_control do
  name 'Version Time Control plugin'
  author 'Misterfifi'
  description 'Redmine plugin, used to update the progress of the past versions fonction time'
  version '1.0'
  url 'http://trium-agency.fr'
  author_url 'http://trium-agency.fr'

  menu :top_menu, :version_time_control, { :controller => 'version_time_control', :action => 'index' }, :caption => 'Maintenance'

  settings :default => {
      'contract_field' => true,
      'hours_field' => true
  }, :partial => 'settings/version_time_control_settings'
end