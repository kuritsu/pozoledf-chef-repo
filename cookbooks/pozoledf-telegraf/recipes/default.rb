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
  'graphite' => {
    'servers' => [graphite_fqdn],
    'template' => 'host.tags.measurement.field',
    'prefix' => "#{node['chef_environment']}.#{node['name']}",
    'timeout' => 2
  }
}

telegraf_outputs 'default' do
  outputs node['telegraf']['outputs']
end
