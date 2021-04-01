#
# Cookbook:: pozoledf-prometheus
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

require 'chef/data_bag'

if Chef::DataBag.list.key?('monitor')
  monitor = data_bag_item('monitor', 'info')
  config = node.default['prometheus-platform']['components']['prometheus']['config']
  index = config['scrape_configs']['index_1']['static_configs']['index_1']
  index['targets'] = [monitor['prometheus_fqdn']]
end

include_recipe 'prometheus-platform::default'
