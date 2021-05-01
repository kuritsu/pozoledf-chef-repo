#!/bin/bash
#
# Install Chef Infra Server
# Vars:
#
## Admin user account name.
#  export CHEF_ADMIN_USER=admin
## Admin user first name.
#  export CHEF_ADMIN_USER_FIRST_NAME=Administrator
## Admin user last name.
#  export CHEF_ADMIN_USER_LAST_NAME=Chef
## Admin user email.
#  export CHEF_ADMIN_USER_EMAIL=chef_admin@myorg.com
## Admin user password.
#  export CHEF_ADMIN_USER_PASSWORD="Ch3fAdm1nP4ss**"
## Chef Server Public Fully Qualified name.
#  export CHEF_SERVER_FQDN=automate.myorg.com
## Chef server private host name (for internal network use)
#  export CHEF_SERVER_HOSTNAME=automate.net.internal
## Grafana/ElasticSearch/InfluxDB server hostname.
#  export GRAFANA_HOSTNAME=monitor.net.internal
## Organization name identifier.
## Must be fully lowercase and starting with a letter, no spaces.
#  export ORG_NAME=myorg
## Organization full name.
#  export ORG_NAME_LONG="My Organization"
#

rpm -Uvh https://packages.chef.io/files/stable/chef/16.10.17/el/8/chef-16.10.17-1.el7.x86_64.rpm

mkdir -p /etc/chef
cat >/etc/chef/attr.json <<EOF
{
  "CHEF_ADMIN_USER": "${CHEF_ADMIN_USER}",
  "CHEF_SERVER_HOSTNAME": "${CHEF_SERVER_HOSTNAME}",
  "CHEF_SERVER_FQDN": "${CHEF_SERVER_FQDN}",
  "GRAFANA_HOSTNAME": "${GRAFANA_HOSTNAME}",
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

chef-client -r 'role[chef-server]'

echo "===> Chef Server installed. Use chef-server-ctl to control users and orgs."
echo "     Use knife2 to manage the ${ORG_NAME} org objects."
