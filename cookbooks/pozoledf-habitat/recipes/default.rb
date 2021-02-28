#
# Cookbook:: pozoledf-habitat-chef
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

hab_install 'install habitat' do
  license 'accept'
  bldr_url "https://#{data_bag_item('builder', 'fqdn')}/"
end

file '/hab/cache/ssl/automate.pem' do
  content data_bag_item('automate', 'cert_file')
  mode '0644'
  owner 'root'
  group 'root'
end

hab_sup 'default' do
  license 'accept'
  event_stream_application node['name']
  event_stream_environment node['chef_environment']
  event_stream_site node['site']
  event_stream_url data_bag_item('automate', 'fqdn')
  event_stream_token data_bag_item('automate', 'stream_token')
  event_stream_cert "/hab/cache/ssl/automate.pem"
end
