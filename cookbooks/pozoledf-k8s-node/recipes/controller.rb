# controller recipe

include_recipe '::common'

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
