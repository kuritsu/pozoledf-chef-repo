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

mkdir -p /etc/chef
cat >/etc/chef/attr.json <<EOF
{
  "CHEF_ADMIN_USER": "${CHEF_ADMIN_USER}",
  "CHEF_SERVER_HOSTNAME": "${CHEF_SERVER_HOSTNAME}",
  "CHEF_SERVER_FQDN": "${CHEF_SERVER_FQDN}",
  "ORG_NAME": "${ORG_NAME}"
}
EOF

yum makecache && yum install -y git
mkdir -p /var/chef && cd /var/chef && rm -rf repo
git clone https://github.com/kuritsu/pozoledf-chef-repo.git repo && cd repo

chef-client -z -r recipe[pozoledf-chef-server] --chef-license accept -j /etc/chef/attr.json

rpm -Uvh https://packages.chef.io/files/stable/chefdk/4.13.3/el/8/chefdk-4.13.3-1.el7.x86_64.rpm

cp -u /bin/knife /bin/knife2
sed 's|/hab/svc/automate-cs-nginx/config/knife_superuser.rb|/root/.chef/config.rb|g' -i /bin/knife2

knife2 ssl fetch
bash /var/chef/repo-sync.sh

bag=`knife2 data bag show automate`
if [ $? != 0 ]; then
  bag_file="/opt/chef-server-install/automate-info.json"
  token=`chef-automate iam token create event-stream --id event-stream`
  automate_cert=`cat /opt/chef-server-install/ssl-certificate.crt|awk '{printf "%s\\\n", $0}'`

  cat >$bag_file <<EOF
{
  "id": "info",
  "stream_token": "$token",
  "cert_file": "$automate_cert"
}
EOF

  knife2 data bag create automate
  knife2 data bag from file automate $bag_file

  rm -rf $bag_file
fi

chef-client -r role[chef-server]

echo "===> Chef Server installed. Use chef-server-ctl to control users and orgs."
echo "     Use knife2 to manage the ${ORG_NAME} org objects."
