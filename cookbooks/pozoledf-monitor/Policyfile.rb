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

cookbook 'pozoledf-telegraf', '~> 0.1.0', path: '../pozoledf-telegraf'
cookbook 'elasticsearch', '~> 4.3.0'
cookbook 'grafana', '~> 9.6.0'
cookbook 'influxdb', '~> 6.3.1'
