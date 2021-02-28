# pozoledf-jenkins-chef

[PozoleDF](https://github.com/kuritsu/pozoledf) Chef cookbook for installing Jenkins.

## Requirements:

- Linux RHEL 7/CentOS 7/Amazon 2
- Chef Infra Client

## Components installed

- Java 8 ([Corretto](https://docs.aws.amazon.com/corretto/latest/corretto-8-ug/downloads-list.html))
- [Docker](https://docker.com)
- [Jenkins](https://jenkins.io), running on port 8080, with the following plugins:
  - [GitHub](https://plugins.jenkins.io/github)
  - [Blue Ocean](https://plugins.jenkins.io/blueocean)
  - [Pipeline: Multibranch](https://plugins.jenkins.io/workflow-multibranch)

