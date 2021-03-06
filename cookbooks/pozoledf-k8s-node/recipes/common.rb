# Common recipe

bash 'selinux-permission' do
  code <<-EOH
    setenforce 0
    sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
  EOH
  action :run
  only_if { ::File.exist?('/etc/selinux/config') }
end

kernel_module 'br_netfilter' do
  action :install
end

yum_package %w(yum-utils device-mapper-persistent-data lvm2) do
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
    flush_cache [ :before, :after ]
    action :install
  end
end

yum_package 'docker' do
  action :install
  only_if { amazon_platform? }
end

directory '/etc/docker' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  recursive true
end

cookbook_file '/etc/docker/daemon.json' do
  source 'daemon.json'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

service 'docker' do
  supports status: true, restart: true, reload: true
  action [ :enable, :start ]
end

sysctl 'bg-call-ip-tables' do
  key               'net.bridge.bridge-nf-call-iptables'
  value             1
  action            :apply
end

yum_repository 'kubernetes' do
  baseurl                    'https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch'
  description                'docker repo'
  enabled                    true
  gpgcheck                   false
  repo_gpgcheck              false
  make_cache                 true
  action                     :create
end

yum_package 'tc' do
  action :install
  only_if { amazon_platform? }
end

yum_package %w(kubelet kubeadm kubectl) do
  action :install
end

service 'kubelet' do
  action [ :enable, :start ]
end

include_recipe 'helm::default'
