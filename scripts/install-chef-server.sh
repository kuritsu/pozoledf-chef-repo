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
chef-solo -o 'pozoledf-chef-server' --chef-license accept
chef-client --chef-license accept
