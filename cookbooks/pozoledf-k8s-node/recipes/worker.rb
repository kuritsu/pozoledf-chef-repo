# worker recipe

include_recipe '::common'

file '/tmp/install-chef-client-notice.txt' do
  content <<-EOM
===> IMPORTANT: Check the last line of the /var/lib/kubelet/kubeinit.log file
on the Kubernetes control plane node, and run the command contained there
to add this node to the cluster.
EOM
  user  'root'
  group 'root'
  mode  '0644'
end
