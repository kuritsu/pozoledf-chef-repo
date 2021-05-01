#!/bin/bash
#
# Install Chef Infra Client and assign a role to the current node, installing
# all extra software required for the role. Run as root!
# Vars:
#
## Node name.
#  export NODE_NAME=jenkins
## Node environment. Ex: "dev", "stg" or "prd"
#  export NODE_ENV=dev
## Node role. Check the list of possible roles in the
## roles dir of this repo.
#  export NODE_ROLE=jenkins
## Organization ID. Alphanumeric & all lowercase.
#  export NODE_ORG=myorg
## Chef internal/external hostname.
#  export CHEF_SERVER_HOSTNAME=automate.net.internal
## Organization pem file path (generated by the install-chef-server.sh script,
## get it from /opt/chef-server-install/myorg.pem)
#  export VALIDATE_PEM_FILE=myorg.pem
#

rpm -Uvh https://packages.chef.io/files/stable/chef/16.10.17/el/8/chef-16.10.17-1.el7.x86_64.rpm

mkdir -p /etc/chef
cp $VALIDATE_PEM_FILE /etc/chef/validation.pem

cat >/etc/chef/client.rb <<EOF
log_location     STDOUT
ssl_verify_mode  :verify_none
chef_server_url  'https://$CHEF_SERVER_HOSTNAME/organizations/$NODE_ORG'
node_name        '$NODE_NAME'
validation_key   '/etc/chef/validation.pem'
environment      '$NODE_ENV'
EOF

mkdir -p ~/.chef

cat >~/.chef/config.rb <<EOF
ssl_verify_mode  :verify_none
chef_server_url  'https://$CHEF_SERVER_HOSTNAME/organizations/$NODE_ORG'
EOF

knife ssl fetch

chef-client -r role[${NODE_ROLE}] --chef-license=accept

echo "===> Chef Infra client and node role installed."
echo "===> IMPORTANT: Remove the validation key (/etc/chef/validation.pem) manually."

if [ -f "/tmp/install-chef-client-notice.txt" ]; then
  cat /tmp/install-chef-client-notice.txt
fi
