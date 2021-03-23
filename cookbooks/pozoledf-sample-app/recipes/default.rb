#
# Cookbook:: pozoledf-sample-app
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

include_recipe 'pozoledf-habitat::default'

builder_info = data_bag_item('builder', 'info')

hab_service "#{builder_info['org']}/pozoledf-sample-app" do
  channel  node['chef_environment']
  strategy 'at-once'
  topology 'standalone'
  update_condition 'latest'
end
