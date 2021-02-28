# Use for installing a Kubernetes Control plane node
name 'jenkins'
default_source :supermarket
run_list 'pozoledf-k8s-node::controller'
