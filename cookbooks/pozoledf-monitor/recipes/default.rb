#
# Cookbook:: pozoledf-monitor
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

include_recipe '::elasticsearch'
include_recipe '::influxdb'
include_recipe '::grafana'
include_recipe 'pozoledf-telegraf::default'
