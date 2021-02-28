# Use for installing Chef Habitat Builder
name 'hab-builder'
default_source :supermarket
default_source :chef_server, Chef::Config['chef_server_url']
run_list 'pozoledf-habitat::builder'
