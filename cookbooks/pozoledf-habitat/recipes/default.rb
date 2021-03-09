#
# Cookbook:: pozoledf-habitat-chef
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

hab_install 'install habitat' do
  license 'accept'
end

automate_info = data_bag_item('automate', 'info')

file '/hab/cache/ssl/automate.pem' do
  content automate_info['cert_file']
  mode '0644'
  owner 'root'
  group 'root'
end

hab_sup 'default' do
  license 'accept'
  event_stream_application node['name']
  event_stream_environment node['chef_environment']
  event_stream_site node['site']
  event_stream_url Chef::Config['chef_server_url']
  event_stream_token automate_info['stream_token']
  event_stream_cert "/hab/cache/ssl/automate.pem"
end
