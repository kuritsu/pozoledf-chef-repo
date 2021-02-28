#!/bin/bash
# Installs Chef Habitat and Builder on prem.
#
# NOTE: Run as root
#
# Prerequisites:
# - You need your GitHub account registered in https://bldr.habitat.sh, as you will need
#   it to connect to this on prem builder.
# - You need to create an OAuth application pointing to the Habitat Builder on-prem
#   URL. Go here: https://github.com/settings/developers
# Vars:
#   AUTOMATE_HOSTNAME: Automate host name (UI and API)
#   AUTOMATE_CERT_PATH: Path to the Automate certicate copied locally.
#   AUTOMATE_TOKEN: API token generated in Automate so the Supervisor can report to it.
#   BUILDER_FQDN: Public fully qualified name for the Builder node.
#   BUILDER_HOSTNAME: Private hostname of the builder node.
#   COMPANY_ORIGIN: Company Habitat Origin. Ex: mycompany
#   OAUTH_CLIENT_ID: Client ID of the OAuth Application you created on GitHub.
#   OAUTH_CLIENT_SECRET: Client Secret of the OAuth Application you created on GitHub.
#

rm -rf on-prem-builder || true
git clone https://github.com/habitat-sh/on-prem-builder.git

openssl req -newkey rsa:4096 \
  -x509 \
  -sha256 \
  -days 3650 \
  -nodes \
  -out ssl-certificate.crt \
  -keyout ssl-certificate.key \
  -subj "/C=US/ST=CA/L=Mountain View/O=Pozoledf/OU=Automation/CN=$BUILDER_HOSTNAME"

cp ssl-certificate.key on-prem-builder
cp ssl-certificate.crt on-prem-builder

cd on-prem-builder

cat >bldr.env <<EOF
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5432

export MINIO_ENDPOINT=http://localhost:9000
export MINIO_BUCKET=habitat-builder-artifact-store.local
export MINIO_ACCESS_KEY=depot
export MINIO_SECRET_KEY=password

export APP_SSL_ENABLED=true
export APP_URL=https://$BUILDER_FQDN/

export OAUTH_PROVIDER=github
export OAUTH_USERINFO_URL=https://api.github.com/user
export OAUTH_AUTHORIZE_URL=https://github.com/login/oauth/authorize
export OAUTH_TOKEN_URL=https://github.com/login/oauth/access_token
export OAUTH_REDIRECT_URL=https://$BUILDER_FQDN/
export OAUTH_SIGNUP_URL=https://github.com/join

export BLDR_CHANNEL=on-prem-stable
export BLDR_ORIGIN=habitat
export HAB_BLDR_URL=https://bldr.habitat.sh

export ANALYTICS_ENABLED=false
EOF

export HAB_LICENSE="accept"
bash ./install.sh

cp $AUTOMATE_CERT_PATH /hab/cache/ssl/$AUTOMATE_HOSTNAME.pem
cp ssl-certificate.crt /hab/cache/ssl/$BUILDER_HOSTNAME.pem

mkdir -p /hab/sup/default/config

cat >/hab/sup/default/config/sup.toml <<EOF
bldr_url = "https://$BUILDER_HOSTNAME/"
group = "builder"
event_stream_application = "builder"
event_stream_environment = "infra"
event_stream_url = "$AUTOMATE_HOSTNAME:4222"
event_stream_site = "developer"
event_stream_token = "$AUTOMATE_TOKEN"
event_stream_server_certificate = "/hab/cache/ssl/$AUTOMATE_HOSTNAME.pem"
EOF

systemctl restart hab-sup
