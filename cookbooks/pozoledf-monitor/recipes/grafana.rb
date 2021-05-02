grafana_install 'grafana'

service 'grafana-server' do
  action [:enable, :start]
  subscribes :restart, ['template[/etc/grafana/grafana.ini]', 'template[/etc/grafana/ldap.toml]'], :delayed
end

grafana_datasource 'influxdb' do
  datasource(
    name: 'InfluxDB',
    type: 'influxdb',
    url: 'http://localhost:8086',
    access: 'proxy',
    database: 'telegraf',
    isdefault: true
  )
  action :create
end

grafana_datasource 'influxdb-k8s' do
  datasource(
    name: 'InfluxDB-k8s',
    type: 'influxdb',
    url: 'http://localhost:8086',
    access: 'proxy',
    database: 'telegraf-kubernetes',
    isdefault: false
  )
  action :create
end

grafana_datasource 'elasticsearch' do
  datasource(
    name: 'Elasticsearch',
    type: 'elasticsearch',
    url: 'http://localhost:9200',
    access: 'proxy',
    database: 'syslog',
    isdefault: true,
    jsonData: {
      esVersion: 7,
      logMessageField: 'log',
      maxConcurrentShardRequests: 256,
      timeField: '@timestamp',
    }
  )
  action :create
end

grafana_datasource 'elasticsearch-k8s' do
  datasource(
    name: 'Elasticsearch-k8s',
    type: 'elasticsearch',
    url: 'http://localhost:9200',
    access: 'proxy',
    database: '[kubernetes-]YYYY.MM.DD',
    interval: 'Daily',
    isdefault: true,
    jsonData: {
      esVersion: 7,
      logMessageField: 'log',
      maxConcurrentShardRequests: 256,
      timeField: '@timestamp',
    }
  )
  action :create
end

grafana_dashboard_template 'statsd' do
  template_source 'statsd.grafana.json.erb'
  template_cookbook template[:cookbook]

  action [:create]
end

grafana_dashboard_template 'statsd-k8s' do
  template_source 'statsd-k8s.grafana.json.erb'
  template_cookbook template[:cookbook]

  action [:create]
end
