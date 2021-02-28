# Use for installing a Kubernetes worker node
name 'jenkins'
default_source :supermarket
default_source :chef_server, Chef::Config['chef_server_url']
run_list 'pozoledf-k8s-node::worker'
