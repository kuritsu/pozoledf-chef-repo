#!/bin/bash

set -x

cd /var/chef
if [ !-d "repo" ]; then
  git clone https://github.com/kuritsu/pozoledf-chef-repo.git repo
fi

cd repo
git checkout main
git pull origin main

knife upload --chef-repo-path . .

cd policyfiles
for f in `find .|grep .rb`; do
  chef install $f
  chef update $f
  group=`echo $f|awk -F '/' '{print $2}'`
  chef push $group $f
done
