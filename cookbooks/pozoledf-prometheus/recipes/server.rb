#
# Cookbook:: pozoledf-prometheus
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

node.default['prometheus-platform']['components']['prometheus']['install?'] = true
node.default['prometheus-platform']['components']['alertmanager']['install?'] = true
node.default['prometheus-platform']['components']['pushgateway']['install?'] = true

include_recipe 'prometheus-platform::default'
