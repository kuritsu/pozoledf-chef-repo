#
# Cookbook:: pozoledf-habitat-chef
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

hab_install 'install habitat' do
  license 'accept'
end

automate_info = data_bag_item('automate', 'info')
builder_info = data_bag_item('builder', 'info')

file '/hab/cache/ssl/automate.pem' do
  content automate_info['cert_file']
  mode '0644'
  owner 'root'
  group 'root'
end

hab_package 'core/hab-sup' do
  version '1.6.288'
done

hab_package 'core/hab-launcher' do
  version '1.6.288'
done

hab_sup 'default' do
  license                   'accept'
  action                    :run
  org                       automate_info['org']
  hab_channel               node['chef_environment']
  bldr_url                  builder_info['builder_url']
  event_stream_application  node['name']
  event_stream_environment  node['chef_environment']
  event_stream_site         node['chef_environment']
  event_stream_url          automate_info['stream_url']
  event_stream_token        automate_info['stream_token']
  event_stream_cert         '/hab/cache/ssl/automate.pem'
  sup_version               '1.6.288'
  toml_config               true
end

hab_sup 'default' do
  license                   'accept'
  action                    :run
  org                       automate_info['org']
  hab_channel               node['chef_environment']
  bldr_url                  builder_info['builder_url']
  event_stream_application  node['name']
  event_stream_environment  node['chef_environment']
  event_stream_site         node['chef_environment']
  event_stream_url          automate_info['stream_url']
  event_stream_token        automate_info['stream_token']
  event_stream_cert         '/hab/cache/ssl/automate.pem'
  sup_version               '1.6.288'
  toml_config               true
end

# Ensure hab group permissions in /hab
