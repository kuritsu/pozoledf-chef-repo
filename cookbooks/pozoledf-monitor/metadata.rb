name 'pozoledf-monitor'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'All Rights Reserved'
description 'Installs/Configures pozoledf-monitor'
version '0.1.0'
chef_version '>= 15.0'

depends 'pozoledf-telegraf', '~> 0.1.0'
depends 'elasticsearch', '~> 4.3.0'
depends 'grafana', '~> 9.6.0'
depends 'influxdb', '~> 6.3.1'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/pozoledf-monitor/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/pozoledf-monitor'
