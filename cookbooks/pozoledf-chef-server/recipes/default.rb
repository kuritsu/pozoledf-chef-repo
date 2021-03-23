#
# Cookbook:: pozoledf-chef-server
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

require 'chef/data_bag'

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
      -subj "/C=US/ST=CA/L=Mountain View/O=Pozoledf/OU=Automation/CN=#{node['CHEF_SERVER_HOSTNAME']}"
  EOH
  creates "#{base_dir}/chef-automate"
end

template base_dir + '/config.toml' do
  source 'config.toml.erb'
  owner  'root'
  group  'root'
  mode   '0755'
  variables(base_dir: base_dir)
end

sysctl 'vm.max_map_count' do
  value 262144
end

sysctl 'vm.dirty_expire_centisecs' do
  value 30000
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
  creates "#{base_dir}/service.key"
end

bash 'create-admin-user' do
  cwd base_dir
  code <<-EOH
    chef-server-ctl user-create $CHEF_ADMIN_USER \
        "$CHEF_ADMIN_USER_FIRST_NAME" \
        "$CHEF_ADMIN_USER_LAST_NAME" \
        "$CHEF_ADMIN_USER_EMAIL" \
        "$CHEF_ADMIN_USER_PASSWORD" --filename $CHEF_ADMIN_USER.pem
    mkdir -p ~/.chef
    cp -u ${CHEF_ADMIN_USER}.pem ~/.chef
  EOH
  environment ENV.to_h
  creates "#{base_dir}/#{node['CHEF_ADMIN_USER']}.pem"
end

bash 'create-org' do
  cwd base_dir
  code <<-EOH
    chef-server-ctl org-create $ORG_NAME "$ORG_NAME_LONG" \
      --association_user $CHEF_ADMIN_USER --filename $ORG_NAME.pem
    cp $ORG_NAME.pem /etc/chef/$ORG_NAME.pem
  EOH
  environment ENV.to_h
  creates "#{base_dir}/#{node['ORG_NAME']}.pem"
end

template "/root/.chef/credentials" do
  source 'credentials.erb'
  owner  'root'
  group  'root'
  mode   '0640'
end

template "/root/.chef/config.rb" do
  source 'config.rb.erb'
  owner  'root'
  group  'root'
  mode   '0640'
end

template '/etc/chef/client.rb' do
  source 'client.rb.erb'
  owner  'root'
  group  'root'
  mode   '0644'
end

cookbook_file '/var/chef/repo-sync.sh' do
  source 'repo-sync.sh'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cron 'sync-chef-repo' do
  action :create
  minute '*/5'
  user 'root'
  home '/var/chef'
  command '/var/chef/repo-sync.sh >/var/log/chef-repo-sync.log 2>&1'
end

unless Chef::DataBag.list.key?('automate')
  bash 'create-automate-stream-token' do
    cwd base_dir
    code <<-EOH
      chef-automate iam token create event-stream --id event-stream >automate-stream-token
    EOH
    environment ENV.to_h
    creates "#{base_dir}/automate-stream-token"
  end

  ruby_block 'automate-data-bag' do
    block do
      new_databag = Chef::DataBag.new
      new_databag.name('automate')
      new_databag.save

      info = {
        'id' => 'info',
        'org' => node['ORG_NAME'],
        'stream_token' => "#{::File.read("#{base_dir}/automate-stream-token").chomp}",
        'stream_url' => "#{node['CHEF_SERVER_HOSTNAME']}:4222",
        'cert_file' => "#{::File.read("#{base_dir}/ssl-certificate.crt").chomp}",
      }
      databag_item = Chef::DataBagItem.new
      databag_item.data_bag('automate')
      databag_item.raw_data = info
      databag_item.save
    end
    action :run
  end
end

unless Chef::DataBag.list.key?('builder')
  new_databag = Chef::DataBag.new
  new_databag.name('builder')
  new_databag.save

  info = {
    'id' => 'info',
    'builder_url' => "https://#{node['CHEF_SERVER_HOSTNAME']}/bldr/v1"
  }
  databag_item = Chef::DataBagItem.new
  databag_item.data_bag('builder')
  databag_item.raw_data = info
  databag_item.save
end
