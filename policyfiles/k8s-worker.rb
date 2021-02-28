# Use for installing a Kubernetes worker node
name 'jenkins'
default_source :supermarket
run_list 'pozoledf-k8s-node::worker'
