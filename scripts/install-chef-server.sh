#!/bin/bash
#
# Install Chef Infra Server
# Vars:
#  CHEF_ADMIN_USER: Admin user account name.
#  CHEF_ADMIN_USER_FIRST_NAME: Admin user first name.
#  CHEF_ADMIN_USER_LAST_NAME: Admin user last name.
#  CHEF_ADMIN_USER_EMAIL: Admin user email.
#  CHEF_ADMIN_USER_PASSWORD: Admin user password.
#  CHEF_SERVER_FQDN: Chef Server fully qualified name.
#  NODE_NAME: Node name for Chef management.
#  ORG_NAME: Organization name identifier. Must be fully lowercase and starting with a letter, no spaces.
#  ORG_NAME_LONG: Organization full name.
#

yum makecache && yum install -y git
rpm -Uvh https://packages.chef.io/files/stable/chef-server/14.0.65/el/8/chef-server-core-14.0.65-1.el7.x86_64.rpm
chef-server-ctl reconfigure --chef-license=accept
chef-server-ctl user-create $CHEF_ADMIN_USER \
  "$CHEF_ADMIN_USER_FIRST_NAME" \
  "$CHEF_ADMIN_USER_LAST_NAME" \
  "$CHEF_ADMIN_USER_EMAIL" \
  "$CHEF_ADMIN_USER_PASSWORD" --filename $CHEF_ADMIN_USER.pem
chef-server-ctl org-create $ORG_NAME "$ORG_NAME_LONG" \
  --association_user $CHEF_ADMIN_USER --filename $ORG_NAME.pem

curl -O https://raw.githubusercontent.com/kuritsu/pozoledf-chef-repo/main/scripts/install-chef-client.sh

chmod a+x ./install-chef-client.sh

export NODE_ENV=dev
export NODE_ROLE=chef-server
export SERVER_URL=https://$CHEF_SERVER_FQDN/organizations/$ORG_NAME
export VALIDATE_PEM_FILE=$ORG_NAME.pem

./install-chef-client.sh

if [ ! -d "repo" ]; then
  git clone https://github.com/kuritsu/pozoledf-chef-repo.git repo
fi

cd repo
git checkout main
git pull origin main

knife upload .

echo "===> IMPORTANT: Keep your $CHEF_ADMIN_USER.pem and $ORG_NAME.pem files at hand in a safe place."
