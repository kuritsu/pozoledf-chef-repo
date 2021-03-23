#
# Cookbook:: pozoledf-sample-app
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

include_recipe 'pozoledf-habitat::default'

builder_info = data_bag_item('builder', 'info')

hab_service "#{builder_info['org']}/pozoledf-sample-app" do
  strategy 'at-once'
  topology 'standalone'
end
