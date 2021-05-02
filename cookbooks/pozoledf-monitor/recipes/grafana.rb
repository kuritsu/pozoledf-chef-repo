grafana_install 'grafana'

service 'grafana-server' do
  action [:enable, :start]
  subscribes :restart, ['template[/etc/grafana/grafana.ini]', 'template[/etc/grafana/ldap.toml]'], :delayed
end

org = 'org'
if Chef::DataBag.list.key?('automate')
  automate_info = data_bag_item('automate', 'info')
  org = automate_info['org']
end

grafana_organization org

grafana_datasource 'influxdb' do
  datasource(
    name: 'InfluxDB',
    type: 'influxdb',
    url: 'http://localhost:8086',
    access: 'proxy',
    database: 'telegraf',
    isdefault: true
  )
  organization org
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
  organization org
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
  organization org
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
  organization org
  action :create
end

grafana_dashboard_template 'Statsd' do
  template_source 'statsd.grafana.json.erb'
  template_cookbook 'pozoledf-monitor'
  organization org

  action [:create]
end

grafana_dashboard_template 'Statsd k8s' do
  template_source 'statsd-k8s.grafana.json.erb'
  template_cookbook 'pozoledf-monitor'
  organization org

  action [:create]
end
