# Roles

This directory has all the node roles that PozoleDF supports. Check each role in the details below.

## chef-server

This server gets configured by the `cookbooks/pozoledf-chef-server` recipe, but for a
clean install the `scripts/install-chef-server.sh` script should be used.

It installs and configures the following software:

- [Chef Automate](https://docs.chef.io/automate/infra_server/), which in chain installs also:
  - [Chef Infra Server](https://docs.chef.io/server/)
  - [Chef Habitat Builder](https://docs.chef.io/habitat/builder_overview/)

After completing a successfull installation, this [chef repo](https://docs.chef.io/chef_repo/) 
will be automatically synced/uploaded to the Chef server, though you can change that behavior
in the [cookbooks/pozoledf-chef-server/recipes/default.rb](../cookbooks/pozoledf-chef-server/recipes/default.rb) recipe and the
[cookbooks/pozoledf-chef-server/files/repo-sync.sh](../cookbooks/pozoledf-chef-server/files/repo-sync.sh) script. The following info will be synchronized:

- `cookbooks` directory.
- `environments` directory. See [here](#Habitat_channels) for more details on this folder.
- `policyfiles` directory. `chef update`, `chef push` will be performed to keep local
  versions of the 3rd party cookbooks required by the cookbooks of this repo.
- `roles` directory.

Note that you can check the automated sync log at `/var/log/chef-repo-sync.log`.

### Habitat channels

Each environment inside the `environments` directory correspond to a [Chef Habitat channel](https://docs.chef.io/habitat/pkg_promote/#continuous-deployment-using-channels), meaning
that when configured, the environments also will be synced in Habitat Builder (installed
in this node).

To enable environment synchronization (aka channel creation), follow the next steps:
- Enter the Habitat Builder UI (which you can find after you open the Chef Automate UI,
  then go to Applications on the main menu, then click on the Habitat Builder link on the left menu)
- Sign in with your Automate credentials.
- Click on the Avatar menu (icon on the top right) and click Profile.
- There you can update some of the profile settings, and then click on the 
  [Generate token button](https://docs.chef.io/habitat/builder_profile/#create-a-personal-access-token).
  Save the token generated in a safe place, as you will use it later.
- Connect to the Chef Server, then create a file `/var/chef/builder-token` with the
  content of the token you recently generated.

Now, every 5 minutes (default setting in cron), as the [repo-sync](../cookbooks/pozoledf-chef-server/files/repo-sync.sh) script runs, when it detects that the `/var/chef/builder-token` file
exists, it will:
- create the origin named after the organization and push its generated keys.
- get all environments (`.json` files under the `environments` dir), use
the file name as the channel name (without the `.json` extension) and create the
channel on Habitat if it doesn't exist.

## jenkins

Installs [Jenkins](https://www.jenkins.io/) together with the plugins:

- [Blue Ocean](https://plugins.jenkins.io/blueocean/)
- [GitHub](https://plugins.jenkins.io/github/)

And the dependencies:

- [Amazon Corretto JDK](https://aws.amazon.com/corretto/)
- [Docker](https://docker.com)

The pipelines defined in the source repos are using `Jenkinsfile` and Jenkins Pipelines running with Docker agents.

**NOTE:** This Jenkins service is not officially protected with user login, you need to set that manually for now.
It listens on the 8080 port.

## k8s-controller

Installs a [Kubernetes control plane](https://kubernetes.io/docs/concepts/overview/components/), with the latest version detected, together with the following:

- Docker
- [helm](https://helm.sh/), for installing Helm charts in k8s.
- [Chef Habitat Supervisor](https://docs.chef.io/habitat/sup/), for installing Habitat packages (our k8s manifests will be installed this way).

**Note:** After running the `install-chef-client.sh` script in this node, check the last lines of the output. They will indicate what you should run to join a worker node to the cluster.

## k8s-worker

Installs a [Kubernetes node or worker](https://kubernetes.io/docs/concepts/overview/components/), with the latest version.

## monitor

Installs the following tools:

- [ElasticSearch](https://www.elastic.co/elasticsearch), for storing the logs sent by [Fluent-bit](https://fluentbit.io/) in every node and Kubernetes. It listens on port 9200 by default.
- [InfluxDB](https://www.influxdata.com), for storing time series data, like the metrics collected by [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/) in every node and Kubernetes. It listens on port 8086 by default.
- [Grafana](https://grafana.com), for displaying charts and log reports, setting alerts and dashboards. It listens on port 3000.

Notice that every role installs the `pozoledf-telegraf` cookbook, which includes the Telegraf and Fluent-bit configuration for sending telemetry to this node.

**IMPORTANT:** Once you can enter Grafana, enter with admin/admin and immediately change the password.

### Grafana Data Source configuration

We recommend you configure 4 data sources:
- InfluxDB (contains all data sent by Telegraf installed in every VM)
  - URL: `http://localhost:8086`
  - Database: `telegraf`
- Elasticsearch (contains all logs sent by Fluent-bit installed in every VM)
  - URL: `http://localhost:9200`
  - Elasticsearch details:
    - Index name: `syslog`
    - Time field name: `@timestamp`
    - Version: `7.0+`
  - Logs:
    - Message field name: `log`
- InfluxDB-k8s (contains all metrics sent by Telegraf running inside Kubernetes)
  - URL: `http://localhost:8086`
  - Database: `telegraf-kubernetes`
- Elasticsearch-k8s (contains all logs sent by Fluent-bit running inside Kubernetes)
  - URL: `http://localhost:9200`
  - Elasticsearch details:
    - Index name: `[kubernetes-]YYYY.MM.DD`
    - Pattern: `Daily`
    - Time field name: `@timestamp`
    - Version: `7.0+`
  - Logs:
    - Message field name: `log`

Then you can import the 2 dashboards (JSON files) inside the `cookbooks/pozoledf-monitor/templates` directory of this repo.
