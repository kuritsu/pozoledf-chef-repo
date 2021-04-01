# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'pozoledf-telegraf'

# Where to find external cookbooks:
default_source :supermarket

run_list 'pozoledf-telegraf::default'

# Specify a custom source for a single cookbook:
cookbook 'pozoledf-telegraf', path: '.'

cookbook 'telegraf', '~> 0.12.0'
