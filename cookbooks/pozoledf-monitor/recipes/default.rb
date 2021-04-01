#
# Cookbook:: pozoledf-monitor
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

include_recipe 'pozoledf-prometheus::default'
include_recipe '::elasticsearch'
include_recipe '::kibana'
include_recipe '::logstash'
include_recipe '::grafana'
