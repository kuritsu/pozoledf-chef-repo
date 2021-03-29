elasticsearch_user 'elasticsearch'

elasticsearch_install 'elasticsearch' do
  type 'tarball'
  version node['elasticsearch']['version']
  download_url node['elasticsearch']['download_url']
  action :install
end

elasticsearch_configure 'elasticsearch'

elasticsearch_service 'elasticsearch'
