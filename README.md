# PozoleDF Chef Repo

Every Chef Infra installation needs a Chef Repository. This is the place where cookbooks, policyfiles, config files and other artifacts for managing systems with Chef Infra will live. We strongly recommend storing this repository in a version control system such as Git and treating it like source code.

## Repository Directories

This repository contains several directories, and each directory contains a README file that describes what it is for in greater detail, and how to use it for managing your systems with Chef.

- `cookbooks/` - Cookbooks you download or create.
- `data_bags/` - Stores data bags and items in .json in the repository.
- `environments/` - Stores environments. Add your application enviroments here.
  For more details, go [here](./docs/chef-server.md#Habitat_channels).
- `roles/` - Stores roles. Add node roles here.
- `policyfiles` - Stores policies. They will be used to update 3rd party cookbooks on the
  Chef Server.

## Infrastructure installation/configuration

You will need the following machines running RHEL 7|8 / CentOS 7|8 (we suggest you use [Terraform](https://www.terraform.io) if some of these components will be hosted in the cloud):

- 1 x Chef Infra Server/Chef Automate/Chef Habitat Builder (prerequisite of the other ones)
  - Run [scripts/install-chef-server.sh](https://github.com/kuritsu/pozoledf-chef-repo/tree/main/scripts/install-chef-server.sh), but before make sure
    you read/fullfil the requirements documented at the beginning of the script.
- 1 x Monitor/Telemetry server
  - Run [scripts/install-chef-client.sh](https://github.com/kuritsu/pozoledf-chef-repo/tree/main/scripts/install-chef-client.sh), but before make sure you read/fullfil the requirements documented at the beginning of the script and set the following environment variables:
    - NODE_ENV: dev
    - NODE_ROLE: monitor
- 1 x Jenkins
  - Run [scripts/install-chef-client.sh](https://github.com/kuritsu/pozoledf-chef-repo/tree/main/scripts/install-chef-client.sh), but before make sure you read/fullfil the requirements documented at the beginning of the script and
  set the following environment variables:
    - NODE_ENV: dev
    - NODE_ROLE: jenkins
- 2 (minimum) x Staging application environment
  - K8S controller node (x1):
    - Run [scripts/install-chef-client.sh](https://github.com/kuritsu/pozoledf-chef-repo/tree/main/scripts/install-chef-client.sh), but before make sure you read/fullfil the requirements documented at the beginning of the script and set the following environment variables:
      - NODE_ENV: stg
      - NODE_ROLE: k8s-controller

      *Check the last lines of output after running the script to learn how to add a worker node to the cluster.*
  - K8S worker node (x1+):
    - Run [scripts/install-chef-client.sh](https://github.com/kuritsu/pozoledf-chef-repo/tree/main/scripts/install-chef-client.sh), but before make sure you set the following
  environment variables:
      - NODE_ENV: stg
      - NODE_ROLE: k8s-worker

      *Check the last lines of output after running the script to learn how to add this worker node to the cluster.*
- 2 (minimum) x Production application environment
  - K8S controller node (x1):
    - Run [scripts/install-chef-client.sh](https://github.com/kuritsu/pozoledf-chef-repo/tree/main/scripts/install-chef-client.sh), but before make sure you set the following
  environment variables:
      - NODE_ENV: prd
      - NODE_ROLE: k8s-controller
  - K8S worker node (x1+):
    - Run [scripts/install-chef-client.sh](https://github.com/kuritsu/pozoledf-chef-repo/tree/main/scripts/install-chef-client.sh), but before make sure you set the following
  environment variables:
      - NODE_ENV: prd
      - NODE_ROLE: k8s-worker

## Next Steps

Check all READMEs in every directory for more information.
