#
# Cookbook:: pozoledf-monitor
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

elasticsearch_user 'elasticsearch'

elasticsearch_install 'elasticsearch'

elasticsearch_configure 'elasticsearch'

elasticsearch_service 'elasticsearch'

node['kibana']['url'] = 'https://artifacts.elastic.co/downloads/kibana/kibana-7.4.2-linux-x86_64.tar.gz'
include_recipe 'kibana::default'

grafana_install 'grafana'

service 'grafana-server' do
  action [:enable, :start]
  subscribes :restart, ['template[/etc/grafana/grafana.ini]', 'template[/etc/grafana/ldap.toml]'], :delayed
end
