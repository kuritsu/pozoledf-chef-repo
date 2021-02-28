#!/bin/bash
# Install Chef Automate. Can be done in the Chef Infra Server node.
#
# Vars:
#   CHEF_AUTOMATE_FQDN: Chef Automate Public Fully Qualified Name, like server.com:8443.
#   CHEF_AUTOMATE_HOSTNAME: Automate internal hostname.
#   CHEF_INFRA_INTEGRATE: Set to "yes" to integrate Automate with Infra Server running
#     in the same node.
#   CHEF_HAB_BUILDER_FQDN: Habitat Builder Public FQDN.

curl https://packages.chef.io/files/current/latest/chef-automate-cli/chef-automate_linux_amd64.zip \
  | gunzip - > chef-automate && chmod +x chef-automate

./chef-automate init-config

openssl req -newkey rsa:4096 \
  -x509 \
  -sha256 \
  -days 3650 \
  -nodes \
  -out ssl-certificate.crt \
  -keyout ssl-certificate.key \
  -subj "/C=US/ST=CA/L=Mountain View/O=Pozoledf/OU=Automation/CN=$CHEF_AUTOMATE_HOSTNAME"

automate_cert=`cat ssl-certificate.crt`
automate_pk=`cat ssl-certificate.key`

cat >config.toml <<EOF
[global.v1]
  # The external fully qualified domain name.
  # When the application is deployed you should be able to access 'https://<fqdn>/'
  # to login.
  fqdn = "$CHEF_AUTOMATE_FQDN"

  [[global.v1.frontend_tls]]
    # The TLS certificate for the load balancer frontend.
    cert = """$automate_cert
"""

    # The TLS RSA key for the load balancer frontend.
    key = """$automate_pk
"""

[deployment.v1]
  [deployment.v1.svc]
    channel = "current"
    upgrade_strategy = "at-once"
    deployment_type = "local"

[license_control.v1]
  [license_control.v1.svc]
    license = ""

[elasticsearch.v1.sys.runtime]
  heapsize = "2g"

[load_balancer.v1.sys.service]
  http_port = 8081
  https_port = 8443

[postgresql.v1.sys.service]
  port = 5433
EOF

./chef-automate deploy config.toml --accept-terms-and-mlsa

./chef-automate iam token create chef-infra-server --admin >chef-infra-server.api-token.txt

if [ "$CHEF_INFRA_INTEGRATE" == "yes" ]; then
  token=`cat chef-infra-server.api-token.txt`
  chef-server-ctl set-secret data_collector token "$token"
  chef-server-ctl restart nginx
  chef-server-ctl restart opscode-erchef

  grep "Add for Chef Infra Client" /etc/opscode/chef-server.rb || \
  cat >>/etc/opscode/chef-server.rb <<EOF
data_collector['root_url'] = 'https://${CHEF_AUTOMATE_HOSTNAME}:8443/data-collector/v0/'
# Add for Chef Infra Client run forwarding
data_collector['proxy'] = true
# Add for compliance scanning
profiles['root_url'] = 'https://${CHEF_AUTOMATE_HOSTNAME}:8443'
EOF
  chef-server-ctl reconfigure
fi

# Use these key files copied for configuring Habitat Builder On Prem
service_key=`find /hab/svc/automate-ui/ |grep service.key`
service_crt=`find /hab/svc/automate-ui/ |grep service.crt`
rm -rf service.key service.crt
cp $service_key .
cp $service_crt .
