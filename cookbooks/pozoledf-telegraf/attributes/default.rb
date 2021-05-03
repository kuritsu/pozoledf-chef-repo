default['telegraf']['version'] = '1.18.0'
default['telegraf']['install_type'] = 'file'
default['telegraf']['config']['global_tags']['env'] = node['chef_environment']
default['telegraf']['config']['global_tags']['name'] = node['name']
default['telegraf']['config']['agent']['logfile'] = '/var/log/telegraf/telegraf.log'
default['telegraf']['config']['agent']['logfile_rotation_max_size'] = '50MB'
default['telegraf']['config']['agent']['logfile_rotation_max_archives'] = 7

default['fluentbit']['forward']['cert'] = '** This is a cert'
