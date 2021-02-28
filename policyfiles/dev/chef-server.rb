# Use for installing Chef Infra Server extra configuration
name 'chef-server'
default_source :supermarket
default_source :chef_server, Chef::Config['chef_server_url']
run_list 'pozoledf-chef-server'
