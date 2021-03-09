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

knife upload . --chef-repo-path .

cd policyfiles
chef update chef-server.rb
chef push dev chef-server.lock.json -c /hab/svc/automate-cs-nginx/config/knife_superuser.rb
knife cookbook upload -o ~/.chefdk/cache/cookbooks/ -a

rm -rf /var/chef/sync.lock
