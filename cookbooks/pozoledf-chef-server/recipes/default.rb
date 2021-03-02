#
# Cookbook:: pozoledf-chef-server
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

base_dir = '/opt/chef-server-install'

directory base_dir do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

bash 'download-extract' do
  cwd base_dir
  code <<-EOH
    curl https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip \
      | gunzip - > chef-automate && chmod +x chef-automate

    openssl req -newkey rsa:4096 \
      -x509 \
      -sha256 \
      -days 3650 \
      -nodes \
      -out ssl-certificate.crt \
      -keyout ssl-certificate.key \
      -subj "/C=US/ST=CA/L=Mountain View/O=Pozoledf/OU=Automation/CN=#{ENV["CHEF_SERVER_HOSTNAME"]}"
  EOH
  not_if { ::File.exist?(base_dir + '/chef-automate_linux_amd64.zip') }
end

template base_dir + '/config.toml' do
  source 'config.toml.erb'
  owner  'root'
  group  'root'
  mode   '0755'
  variables (chef_automate_fqdn: ENV["CHEF_SERVER_FQDN"],
             chef_automate_cert: ::File.read('ssl-certificate.crt').chomp,
             chef_automate_key:  ::File.read('ssl-certificate.key').chomp)
end

bash 'run-installer' do
  cwd base_dir
  code <<-EOH
  ./chef-automate deploy config.toml --accept-terms-and-mlsa

  # Use these key files copied for configuring Habitat Builder On Prem
  service_key=`find /hab/svc/automate-ui/ |grep service.key`
  service_crt=`find /hab/svc/automate-ui/ |grep service.crt`
  rm -rf service.key service.crt
  cp $service_key .
  cp $service_crt .
  EOH
  not_if { ::File.exist?(base_dir + '/service.key') }
end
