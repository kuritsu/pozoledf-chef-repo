#
# Cookbook:: pozoledf-jenkins-chef
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

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

jenkins_command 'safe-restart' do
  action :nothing
  subscribes :execute, 'jenkins_plugin[github]', :delayed
  subscribes :execute, 'jenkins_plugin[blueocean]', :delayed
end
