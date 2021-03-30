# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'pozoledf-monitor'

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'pozoledf-monitor::default'

# Specify a custom source for a single cookbook:
cookbook 'pozoledf-monitor', path: '.'

cookbook 'ark', '~> 5.1.0'
cookbook 'elasticsearch', '~> 4.3.0'
cookbook 'grafana', '~> 9.6.0'
cookbook 'java', '~> 8.6.0'
cookbook 'kibana', '~> 0.2.3'
cookbook 'logstash_lwrp', '~> 2.1.0'
cookbook 'nginx', '~> 11.5.0'
