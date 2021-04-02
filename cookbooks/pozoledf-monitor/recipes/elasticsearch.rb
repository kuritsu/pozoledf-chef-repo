corretto_install '8'

elasticsearch_user 'elasticsearch'

elasticsearch_install 'elasticsearch' do
  type 'tarball'
  version node['elasticsearch']['version']
  download_url node['elasticsearch']['download_url']
  action :install
end

elasticsearch_configure 'elasticsearch' do
  jvm_options %w(
    -Xms994m
    -Xmx994m
  )
end

elasticsearch_service 'elasticsearch'
