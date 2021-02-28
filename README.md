# PozoleDF Chef Repo

Every Chef Infra installation needs a Chef Repository. This is the place where cookbooks, policyfiles, config files and other artifacts for managing systems with Chef Infra will live. We strongly recommend storing this repository in a version control system such as Git and treating it like source code.

## Repository Directories

This repository contains several directories, and each directory contains a README file that describes what it is for in greater detail, and how to use it for managing your systems with Chef.

- `cookbooks/` - Cookbooks you download or create.
- `data_bags/` - Store data bags and items in .json in the repository.
- `policies/` - Store policies in .rb in the repository.

## Infrastructure installation/configuration

You will need the following machines running RHEL 7|8 / CentOS 7|8 (we suggest you use [Terraform](https://www.terraform.io) if some of these components will be hosted in the cloud):

- 1 x Chef Infra Server/Chef Automate (prerequisite of the other ones)
  - Run [scripts/install-chef-server.sh](https://github.com/kuritsu/pozoledf-chef-repo/tree/main/scripts/install-chef-server.sh).
- 1 x Chef Habitat Builder (for storing Habitat deployment packages)
  - Run [scripts/install-chef-client.sh](https://github.com/kuritsu/pozoledf-chef-repo/tree/main/scripts/install-chef-client.sh), but before make sure you set the following
  environment variables:
    - NODE_ENV: dev
    - NODE_ROLE: hab-builder
- 1 x Jenkins
  - Run [scripts/install-chef-client.sh](https://github.com/kuritsu/pozoledf-chef-repo/tree/main/scripts/install-chef-client.sh), but before make sure you set the following
  environment variables:
    - NODE_ENV: dev
    - NODE_ROLE: jenkins
- 2 (minimum) x Staging application environment
  - K8S controller node (x1):
    - Run [scripts/install-chef-client.sh](https://github.com/kuritsu/pozoledf-chef-repo/tree/main/scripts/install-chef-client.sh), but before make sure you set the following
  environment variables:
      - NODE_ENV: stg
      - NODE_ROLE: k8s-controller
  - K8S worker node (x1+):
    - Run [scripts/install-chef-client.sh](https://github.com/kuritsu/pozoledf-chef-repo/tree/main/scripts/install-chef-client.sh), but before make sure you set the following
  environment variables:
      - NODE_ENV: stg
      - NODE_ROLE: k8s-worker
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

Read the README file in each of the subdirectories for more information about what goes in those directories.
