#
# Cookbook:: pozoledf-sample-app
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

include_recipe 'pozoledf-habitat::default'

automate_info = data_bag_item('automate', 'info')
builder_info = data_bag_item('builder', 'info')

hab_service "#{automate_info['org']}/pozoledf-sample-app" do
  channel  node['chef_environment']
  bldr_url builder_info['builder_url']
  strategy 'at-once'
  topology 'standalone'
  update_condition 'track-channel'
end
