corretto_install '8'

logstash_install 'logstash' do
  action :install
end

logstash_config 'logstash' do
  action :create
end

logstash_pipeline 'logstash' do
  instance 'logstash'
  config_templates %w( output-elasticsearch.conf.erb )
  pipeline_workers 1
  action :create
end

logstash_service 'logstash' do
  xms '512M'
  xmx '512M'
  action [:start, :enable]
end
