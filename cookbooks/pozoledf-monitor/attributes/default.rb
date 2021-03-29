#<> ES version
default['elasticsearch']['version'] = '7.12.0'
default['elasticsearch']['checksums']['7.12.0']['rhel'] = 'cbdf48d235341fcc9d4f310978e3a973cc1e6093b7e1f5711c487c6300ee03c8'

#<> Kibana7 exact version
default['kibana']['kibana5_version'] = '7.12.0'
default['kibana']['kibana5_checksum'] = 'dbc1cb0ff6d0ddda687bde4ecb69b5e7da80e5a207398929b9bbe4e87e962d81'
default['kibana']['kibana5_url'] = "https://artifacts.elastic.co/downloads/kibana/kibana-#{node['kibana']['kibana5_version']}-linux-x86_64.tar.gz"
