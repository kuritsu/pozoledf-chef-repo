#
# Cookbook:: pozoledf-prometheus
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

require 'chef/data_bag'

graphite_fqdn = "localhost:2003"
if Chef::DataBag.list.key?('monitor')
  monitor = data_bag_item('monitor', 'info')
  graphite_fqdn = monitor['graphite_fqdn']
end

include_recipe 'telegraf::default'

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
