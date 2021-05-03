default['telegraf']['version'] = '1.18.2-1'
default['telegraf']['include_repository'] = false
default['telegraf']['shasums']['rhel'] = 'e568a22b9d35de89997263af7565ec6044ff91c92b5fbe54ad42e94b13594512'
default['telegraf']['install_type'] = 'file'
default['telegraf']['config']['global_tags']['env'] = node['chef_environment']
default['telegraf']['config']['global_tags']['name'] = node['name']
default['telegraf']['config']['agent']['logfile'] = '/var/log/telegraf/telegraf.log'
default['telegraf']['config']['agent']['logfile_rotation_max_size'] = '50MB'
default['telegraf']['config']['agent']['logfile_rotation_max_archives'] = 7

default['fluentbit']['forward']['cert'] = '** This is a cert'
