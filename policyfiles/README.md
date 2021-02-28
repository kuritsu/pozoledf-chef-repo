# Policy files

Create Policyfiles inside directories here. The directories indicate the policy group name
or environment. When using a chef-repo, give your Policyfiles
the same filename as the name set in the policyfile itself, and use the
`.rb` file extension.

Compile the policy with a command like this:

```
chef install dev/chef-server.rb
```

This will create a lockfile `dev/chef-server.lock.json`.

To update locked dependencies, run `chef update` like this:

```
chef update dev/chef-server.rb
```

You can upload the policy (with associated cookbooks) to the server
using a command like:

```
chef push stg stg/chef-server.rb
```
