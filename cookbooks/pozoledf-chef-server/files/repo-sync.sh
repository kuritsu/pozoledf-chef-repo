#!/bin/bash

if [ -f "/var/chef/sync.lock" ]; then
  echo "Syncing already."
  exit 0
fi

touch /var/chef/sync.lock

set -x

cd /var/chef
if [ !-d "repo" ]; then
  git clone https://github.com/kuritsu/pozoledf-chef-repo.git repo
fi

cd repo
git checkout main
git pull origin main

knife2 upload . --chef-repo-path .

cd policyfiles
chef update chef-server.rb
chef push dev chef-server.lock.json
knife2 cookbook upload -o ~/.chefdk/cache/cookbooks/ -a

cd ..
builder_token="/var/chef/builder-token"
if [ -f "$builder_token" ]; then
  ORG_NAME=`knife opc org show|awk 'BEGIN { FS = ":" } ; { print $1 }'`
  export HAB_BLDR_URL=`knife2 config get chef_server_url -r|sed 's|/organizations.*|/bldr/v1|g'`
  export HAB_AUTH_TOKEN=`cat ${builder_token}`
  hab origin create $ORG_NAME && \
    hab origin key upload $ORG_NAME -s || true
  cd environments
  envs=`ls -1 *.json|sed -e 's/\..*$//'`
  for env in $envs; do
    hab bldr channel create $env || true
  done
fi

rm -rf /var/chef/sync.lock
