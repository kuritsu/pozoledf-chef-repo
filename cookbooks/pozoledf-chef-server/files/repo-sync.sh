#!/bin/bash

cd /var/chef
if [ !-d "repo" ]; then
  git clone https://github.com/kuritsu/pozoledf-chef-repo.git repo
fi

cd repo
git checkout main
git pull origin main

knife upload .
cd nodes
for p in `find .|grep .json`; do 
  node=`cat $p|jq -r .name`
  policies=`cat $p|jq -r '.policies|join(" ")'`
  policy_group=`echo $p|awk 'BEGIN { FS = "/" } ; { print $2 }'`
  for policy_name in `echo $policies`; do
    echo knife node policy set $node $policy_group $policy_name
  done
done
