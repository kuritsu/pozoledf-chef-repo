elasticsearch_user 'elasticsearch'

elasticsearch_install 'elasticsearch' do
  type 'package'
  version node['elasticsearch']['version']
  action :install
end

elasticsearch_configure 'elasticsearch'

elasticsearch_service 'elasticsearch'
