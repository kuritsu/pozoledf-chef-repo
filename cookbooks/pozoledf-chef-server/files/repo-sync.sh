#!/bin/bash

if [ -f "/var/chef/sync.lock" ]; then
  echo "Syncing already."
  exit 0
fi

touch /var/chef/sync.lock

set -x

cd /var/chef
if [ ! -d "repo" ]; then
  git clone https://github.com/kuritsu/pozoledf-chef-repo.git repo
fi

cd repo
git checkout main
git pull origin main

knife2 upload . --chef-repo-path .

cd policyfiles
rm -rf ~/.chefdk/cache/cookbooks/
chef update chef-server.rb --chef-license accept
chef push dev chef-server.lock.json
knife2 cookbook upload -o ~/.chefdk/cache/cookbooks/ -a

cd ..
builder_token="/var/chef/builder-token"
if [ -f "$builder_token" ]; then
  hab license accept
  cp -u /opt/chef-server-install/ssl-certificate.crt /hab/cache/ssl
  ORG_NAME=`knife opc org show|awk 'BEGIN { FS = ":" } ; { print $1 }'`
  export HAB_BLDR_URL=`knife2 config get chef_server_url -r|sed 's|/organizations.*|/bldr/v1|g'`
  export HAB_AUTH_TOKEN=`cat ${builder_token}`
  hab origin info $ORG_NAME
  if [ $? != 0 ]; then
    hab origin create $ORG_NAME
    hab origin key generate $ORG_NAME
    private_key=`hab origin key export $ORG_NAME -t secret|base64 -w 0`
    public_key=`hab origin key export $ORG_NAME|base64 -w 0`
    cat >builder-keys.json <<EOF
{
  "id": "keys",
  "hab_token": "${HAB_AUTH_TOKEN}",
  "origin_private_key_file": "${private_key}",
  "origin_public_key_file": "${public_key}"
}
EOF
    knife2 data bag from file builder keys builder-keys.json
    rm -rf builder-keys.json
    hab origin key upload $ORG_NAME -s
    knife2 upload data_bags --chef-repo-path .
  fi
  cd environments
  envs=`ls -1 *.json|sed -e 's/\..*$//'`
  for env in $envs; do
    hab bldr channel create $env -o $ORG_NAME || true
  done
fi

rm -rf /var/chef/sync.lock
