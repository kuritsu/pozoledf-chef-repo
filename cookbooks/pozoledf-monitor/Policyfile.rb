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

cookbook 'elasticsearch', '~> 4.3.0', :supermarket
cookbook 'kibana', '~> 0.2.3', :supermarket
cookbook 'nginx', '~> 11.5.0', :supermarket
cookbook 'grafana', '~> 9.6.0', :supermarket
