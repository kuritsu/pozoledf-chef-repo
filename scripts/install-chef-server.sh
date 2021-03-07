#!/bin/bash
#
# Install Chef Infra Server
# Vars:
#  CHEF_ADMIN_USER:            Admin user account name.
#  CHEF_ADMIN_USER_FIRST_NAME: Admin user first name.
#  CHEF_ADMIN_USER_LAST_NAME:  Admin user last name.
#  CHEF_ADMIN_USER_EMAIL:      Admin user email.
#  CHEF_ADMIN_USER_PASSWORD:   Admin user password.
#  CHEF_SERVER_FQDN:           Public Fully Qualified name.
#  CHEF_SERVER_HOSTNAME:       Chef server private host name.
#  ORG_NAME:                   Organization name identifier.
#                              Must be fully lowercase and starting with a letter, no spaces.
#  ORG_NAME_LONG:              Organization full name.
#

rpm -Uvh https://packages.chef.io/files/stable/chef/16.10.17/el/8/chef-16.10.17-1.el7.x86_64.rpm
yum makecache && yum install -y git
mkdir -p /var/chef && cd /var/chef && rm -rf repo
git clone https://github.com/kuritsu/pozoledf-chef-repo.git repo && cd repo
echo '{"run_list": ["recipe[pozoledf-chef-server]"]}' >run_list.json
chef-client -z -j run_list.json --chef-license accept

mkdir -p ~/.chef
cp -u /opt/chef-server-install/${CHEF_ADMIN_USER}.pem ~/.chef
cat >~/.chef/credentials <<EOF
[${CHEF_ADMIN_USER}]
client_name     = '${CHEF_ADMIN_USER}'
client_key      = '${HOME}/.chef/${CHEF_ADMIN_USER}.pem'
chef_server_url = 'https://${CHEF_SERVER_HOSTNAME}/organizations/${ORG_NAME}'
EOF

knife upload . --profile ${CHEF_ADMIN_USER} --chef-repo-path .
