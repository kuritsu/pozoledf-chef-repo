# ES version info
default['elasticsearch']['version'] = '7.12.0'
default['elasticsearch']['download_url'] = 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.12.0-linux-x86_64.tar.gz'

default['influxdb']['shasums']['amazon'] = node['influxdb']['shasums']['rhel']
