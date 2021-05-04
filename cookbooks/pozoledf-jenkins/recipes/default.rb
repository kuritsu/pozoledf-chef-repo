#
# Cookbook:: pozoledf-jenkins-chef
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

require 'base64'

bash 'selinux' do
  code <<-EOH
    setenforce 0
    sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
  EOH
  action :run
end

kernel_module 'br_netfilter' do
  action :install
end

yum_package %w(yum-utils device-mapper-persistent-data lvm2 git) do
  action :install
end

if redhat_platform? || centos_platform?
  remote_file '/etc/yum.repos.d/docker-ce.repo' do
    source 'https://download.docker.com/linux/centos/docker-ce.repo'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end

  yum_package %w(containerd docker-ce docker-ce-cli) do
    # version [ '1.2.13', '19.03.11', '19.03.11' ]
    action :install
  end
end

yum_package 'docker' do
  action :install
  only_if { amazon_platform? }
end

service 'docker' do
  supports status: true, restart: true, reload: true
  action [ :enable, :start ]
end

openjdk_install '8'

include_recipe 'jenkins::master'

jenkins_plugin 'blueocean'
jenkins_plugin 'docker-plugin'
jenkins_plugin 'docker-workflow'
jenkins_plugin 'github'
jenkins_plugin 'workflow-aggregator'

group 'docker' do
  append   true
  members  'jenkins'
  action   :modify
  notifies :restart, 'service[jenkins]', :delayed
end

service 'jenkins' do
  action :nothing
end

automate_info = data_bag_item('automate', 'info')
builder_bag = data_bag('builder')

if builder_bag.include?('keys')
  builder_info = data_bag_item('builder', 'info')
  builder_keys = data_bag_item('builder', 'keys')

  jenkins_secret_text_credentials 'hab-origin' do
    id          'hab-origin'
    description 'Chef Habitat origin/org name'
    secret      automate_info['org']
    ignore_failure true
  end

  jenkins_file_credentials 'hab-origin-private-key-file' do
    id          'hab-origin-private-key-file'
    description 'Chef Habitat origin private key file'
    filename    "#{automate_info['org']}.sig.key"
    data        Base64.decode64(builder_keys['origin_private_key_file'])
    ignore_failure true
  end

  jenkins_file_credentials 'hab-origin-public-key-file' do
    id          'hab-origin-public-key-file'
    description 'Chef Habitat origin public key file'
    filename    "#{automate_info['org']}.pub"
    data        Base64.decode64(builder_keys['origin_public_key_file'])
    ignore_failure true
  end

  jenkins_secret_text_credentials 'hab-token' do
    id          'hab-token'
    description 'Chef Habitat user API token'
    secret      builder_keys['hab_token']
    ignore_failure true
  end

  jenkins_secret_text_credentials 'hab-builder-url' do
    id          'hab-builder-url'
    description 'Chef Habitat Builder (on premise) URL'
    secret      builder_info['builder_url']
    ignore_failure true
  end

  jenkins_secret_text_credentials 'hab-builder-url' do
    id          'hab-builder-url'
    description 'Chef Habitat Builder (on premise) URL'
    secret      builder_info['builder_url']
    ignore_failure true
  end

  jenkins_file_credentials 'hab-builder-certificate' do
    id          'hab-builder-certificate'
    description 'Chef Habitat Builder/Automate SSL certificate'
    filename    "builder.pem"
    data        automate_info['cert_file']
    ignore_failure true
  end
end

jenkins_command 'safe-restart' do
  action :nothing
  subscribes :execute, 'jenkins_plugin[github]', :delayed
  subscribes :execute, 'jenkins_plugin[blueocean]', :delayed
  subscribes :execute, 'group[docker]', :delayed
end
