#
# Cookbook:: pozoledf-prometheus
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

require 'chef/data_bag'

influxdb_fqdn = 'localhost:8086'
elasticsearch_fqdn = 'localhost:9200'
if Chef::DataBag.list.key?('monitor')
  monitor = data_bag_item('monitor', 'info')
  influxdb_fqdn = monitor['influxdb_fqdn']
  elasticsearch_fqdn = monitor['elasticsearch_fqdn']
end

include_recipe 'fluentbit::default'

fluentbit_conf 'fluentbit' do
  content <<~CONF
    [INPUT]
      Name  tail
      Path  /var/log/messages
      Tag   #{node['name']}.syslog

    [OUTPUT]
      Name  es
      Match *.syslog
      Host  #{elasticsearch_fqdn.split(':')[0]}
      Port  #{elasticsearch_fqdn.split(':')[1]}
      Index syslog
  CONF
end

include_recipe 'telegraf::default'

directory '/var/log/telegraf' do
  action :create
  mode   '0755'
  user   'telegraf'
  group  'telegraf'
end

node.default['telegraf']['outputs'] = {
  'influxdb' => {
    'urls' => ["http://#{influxdb_fqdn}"],
    'database' => 'telegraf',
    'insecure_skip_verify' => false,
    'timeout' => '5s'
  }
}

telegraf_outputs 'default' do
  outputs node['telegraf']['outputs']
end
