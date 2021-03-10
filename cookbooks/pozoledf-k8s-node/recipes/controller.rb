# controller recipe

include_recipe '::common'

directory '/var/lib/kubelet' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

bash 'kubectl' do
  code <<-EOH
    kubeadm init >/var/lib/kubelet/kubeinit.log
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
    kubectl taint nodes --all node-role.kubernetes.io/master-
  EOH
  action :run
  not_if { ::File.exist?('/var/lib/kubelet/kubeinit.log') }
end

include_recipe 'pozoledf-habitat::default'

log 'message' do
  message <<-EOM
  ==> IMPORTANT: Check the last line of the /var/lib/kubelet/kubeinit.log file
  on how to include a worker node to the Kubernetes cluster. Make sure you
  run that command after the install-chef-client.sh script.
  EOM
  level :info
end
