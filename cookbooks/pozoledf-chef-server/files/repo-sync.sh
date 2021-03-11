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
cli_conf="/hab/etc/cli.toml"
if [ -f "$cli_conf" ]; then
  ORG_NAME=`cat /hab/etc/cli.toml|grep origin|awk 'BEGIN { FS = "\"" } ; { print $2 }'`
  hab origin create $ORG_NAME && \
    hab origin key upload $ORG_NAME -s || true
  cd environments
  envs=`ls -1 *.json|sed -e 's/\..*$//'`
  for env in $envs; do
    hab bldr channel create $env || true
  done
fi

rm -rf /var/chef/sync.lock
