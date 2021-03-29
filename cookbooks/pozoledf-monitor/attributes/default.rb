# ES version info
default['elasticsearch']['version'] = '7.12.0'
default['elasticsearch']['download_url'] = 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.12.0-linux-x86_64.tar.gz'

#<> Kibana7 exact version
default['kibana']['kibana5_version'] = default['elasticsearch']['version']
default['kibana']['kibana5_checksum'] = 'dbc1cb0ff6d0ddda687bde4ecb69b5e7da80e5a207398929b9bbe4e87e962d81'
default['kibana']['kibana5_url'] = "https://artifacts.elastic.co/downloads/kibana/kibana-#{node['kibana']['kibana5_version']}-linux-x86_64.tar.gz"
