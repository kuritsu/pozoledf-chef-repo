name 'chef-server'
run_list 'role[habitat]'
default_source :supermarket
cookbook 'habitat', '~> 2.2.4'
cookbook 'java', '~> 8.6.0'
cookbook 'jenkins', '~> 8.2.1'
