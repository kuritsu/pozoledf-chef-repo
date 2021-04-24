corretto_install '8'

elasticsearch_user 'elasticsearch'

elasticsearch_install 'elasticsearch' do
  type 'tarball'
  version node['elasticsearch']['version']
  download_url node['elasticsearch']['download_url']
  action :install
end

elasticsearch_configure 'elasticsearch' do
  configuration {
    'cluster.name' => node['name'],
    'node.name' => node['name'],
    'http.port' => 9200,
    'network.host' => '0.0.0.0',
    'cluster.initial_master_nodes' => [node['name']]
  }

  jvm_options %w(
    -Xms994m
    -Xmx994m
  )
end

elasticsearch_service 'elasticsearch'
