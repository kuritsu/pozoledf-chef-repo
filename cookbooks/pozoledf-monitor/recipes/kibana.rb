include_recipe 'kibana::default'

template '/opt/kibana/current/config/kibana.yml' do
  source   'kibana.yml.erb'
  owner    'kibana'
  group    'kibana'
  mode     '0644'
  notifies :restart, 'service[kibana]'
end

service 'kibana' do
  action :nothing
end
