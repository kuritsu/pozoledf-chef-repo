# controller recipe

require 'chef/data_bag'

include_recipe '::common'

influxdb_fqdn = 'localhost:8086'
elasticsearch_fqdn = 'localhost:9200'
if Chef::DataBag.list.key?('monitor')
  monitor = data_bag_item('monitor', 'info')
  influxdb_fqdn = monitor['influxdb_fqdn']
  elasticsearch_fqdn = monitor['elasticsearch_fqdn']
end

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

directory '/var/conf/fluent-bit-logging' do
  owner     'root'
  group     'root'
  mode      '0755'
  recursive true
  action    :create
end

for f in [
  'fluent-bit-configmap',
  'fluent-bit-role',
  'fluent-bit-role-binding',
  'fluent-bit-service-account'
  ] do
  cookbook_file "/var/conf/fluent-bit-logging/#{f}.yaml" do
    source "fluent-bit-logging/#{f}.yaml"
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end
end

template '/var/conf/fluent-bit-logging/fluent-bit-ds.yaml' do
  source 'fluent-bit-ds.yaml.erb'
  owner  'root'
  group  'root'
  mode   '0755'
  variables(
    elasticsearch_host: elasticsearch_fqdn.split(':')[0],
    elasticsearch_port: elasticsearch_fqdn.split(':')[1])
end

bash 'kubectl-logging' do
  code <<-EOH
    export KUBECONFIG=/etc/kubernetes/admin.conf
    cd /var/conf/fluent-bit-logging
    kubectl create namespace logging
    kubectl apply -f . >/var/conf/fluent-bit-logging/apply.log 2>&1
  EOH
  action :run
  not_if { ::File.exist?('/var/conf/fluent-bit-logging/apply.log') }
end

include_recipe 'pozoledf-habitat::default'

file '/tmp/install-chef-client-notice.txt' do
  content <<-EOM
===> IMPORTANT: Check the last line of the /var/lib/kubelet/kubeinit.log file
on how to include a worker node to the Kubernetes cluster. Make sure you
run that command after the install-chef-client.sh script.
EOM
  user  'root'
  group 'root'
  mode  '0644'
end
