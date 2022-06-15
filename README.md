# Helmfile Cluster

## Overview

This repository is a central repository managing baremetal, Kubernetes based home server.
It uses `helmfile` to manage all resources installed on it- from `nginx-ingress` and `metallb`, through `jupyterhub` and `code-server` up to `transmission` and `plex`.

## Sub-Helmfiles structure

Repository consists of set of `helmfile.yaml` files organized into theme-based subdirectories:

* `helmfiles/backbone/` manages things like `ingress-nginx`, `cert-manager`, `metallb` and `external-dns` helm releases- everything bare-metal cluster needs to host web applications
* `helmfiles/authentication/` keeps `keycloak` release which provide OIDC/OAuth2 authentication/authorization for other services deployed in cluster
* `helmfiles/cicd/` setting up Github Actions Runner chart (from my [other repo](https://github.com/szymonrychu/gha-runner)) - currently it's upgrades are not functioning properly- see *Known Issues* below.
* `helmfiles/monitoring/` installs and upgrades Grafana/Prometheus/Loki stack allowing for good-enough observability for the cluster.
* `helmfiles/blog/` manages my `wordpress` installation hosting [www.szymonrichert.pl](www.szymonrichert.pl)/[blog.szymonrichert.pl](blog.szymonrichert.pl).
* `helmfiles/media/` keeps things like `plex`, `emby`, `transmission` and `samba`, so my personal video files are available everywhere.
* `helmfiles/coding` installs [`code server`](https://github.com/coder/code-server) (web-based vscode) installed using my customized container and my own helm chart (from my [other repo](https://github.com/szymonrychu/code-server-oauth2)) integrating vscode with `keycloak` using `Oauth2`.
* `helmfiles/datascience/` manages `jupyterhub` installation and configuration
* `helmfiles/home-automation/` installs `home-assistant`, `mosquitto` server, `speedtest-exporter`, [`shelly2prometheus`](https://github.com/szymonrychu/shelly2prometheus), `esphome`.

## Sub-Helmfiles directory's structure

Each of above subdirectories follows similar directory structure:

* `helmfile.yaml` - defines all releases installed through this particular subdirectory
* `values/<name of the release>/common.yaml` - keeps all non-secret helm configuration customizing installation to my needs
* `values/<name of the release>/common.secrets.yaml` - keeps all secrets used by helm encrypted with `sops` and `gpg`, so it's possible to put them into public repo safely
* `values/<name of the release>/raw/<anything>.<pre/post>.yaml` - plain kubernetes files applied before `helm upgrade --install` run by helmfile or after.
* `values/<name of the release>/raw/<anything>.secrets.<pre/post>yaml` - plain kubernetes encrypted with `gpg` files applied before `helm upgrade --install` run by helmfile or after.

The structure of how the `YAML` files are loaded by such `helmfile.yaml` is defined by `&default` yaml anchor:

```
templates:
  default: &default
    (...)
    values:
    - values/common.yaml
    - values/{{`{{ .Environment.Name }}`}}.yaml
    - values/{{`{{ .Release.Name }}`}}/common.yaml
    - values/{{`{{ .Release.Name }}`}}/{{`{{ .Environment.Name }}`}}.yaml
    secrets:
    - values/{{`{{ .Release.Name }}`}}/common.secrets.yaml
    - values/{{`{{ .Release.Name }}`}}/{{`{{ .Environment.Name }}`}}.secrets.yaml
```

This defines merging order for the values.yaml provided in the release's directory. Thanks to it, it's possible to easily define different types of the environments out of one `helmfile.yaml`.
Using that approach allows to setup several separate `environments`, having most of the configuration common among them and focuse only on differences between them.
It heavily resembles `hiera` pattern from `Puppet`. The idea is to separate configuration to layers- from most common describing **a** cluster and all settings specific to any cluster, going though different flavours of clusters (like *development*, *staging* or *production*), through common settings specific for a release among all flavours up to very specific settings for particular release and particular flavour of cluster.

For this particular usecase (one simple, baremetal non-ha kubernetes server) such approach is a bit of an overkill.
BUT it's subhelmfiles can be imported and slightly customized in order to manage commercial projects (as it's done in main `helmfile.yaml`- see [helmfile README.md](https://github.com/helmfile/helmfile#helmfile-)).

## Additional things in the repo

Besides that repository contains of:

* master `helmfile.yaml` connecting all subdirectory helmfiles into one run
* encrypted `kubeconfig` with gpg
* `upgrade.py` python script, that allows for external pipelines to easily upgrade a release in a themed helmfile.
* `autoupgrade.py` python script, that will parse all themed `helmfile.yaml`s and upgrade all helm releases into their newest available stable version.

## Pipelines

There are 3 types of pipelines that run for this repository. Each of the pipelines is using self-hosted runner running in a cluster it's managing.
That allows for hiding kubernetes API endpoint, while also removing necessity of encrypting/decrypting `kubeconfig` on the fly in the pipeline.
Also - because self-hosted runner has all tools necessary preinstalled- the runs are faster.

* `diff` pipeline- reacts to pull-requests created in the repository and pointing to `master` branch. It will run `helmfile diff` command in a root of the repository and print-out delta between what's in the server vs what's coming in after mege to master.
* `main` pipeline- reacts to all commits pushed to `master`. Once triggered it will run `helmfile apply` in root of the repository, which means that all the changes from master will get applied to cluster. What's nice is that `helmfile` is smart enough to check what releases change between current and previous master and pick only helm releases that need to be updated.
* `autoupgrade` pipeline is somewhat special- it runs out of CRON (at 10:00 UTC everyday) and instead of using `helmfile` commands, it will run `autupgrade.py` script, which will edit all `helmfile.yalm` files and update releases with new charts. Once the files are edited, pipeline will commit the changes back to `master` branch, which will trigger `main` pipeline and automatically upgrade all releases.

## Known Issues

* Current implementation will require a bit of love to get it running on HA Kubernetes cluster. Most of the helm releases don't use PVCs, but `hostPath` mounts.
* Currently not all helm releases come-through clearly- some of them will always show something after running `helmfile diff`. That's unhealthy state, because it means, that even `helmfile apply` will refresh all resources of the release and it will simply clutter diff's output.
* there is chicken-and-egg problem between a pipeline that applies stuff to a cluster and `gha-runner` release. Once `gha-release` rotates deployment and it's pod running pipeline that does all of this to a cluster, it will hang the run. When that's happening one should simply cancel rotten build and trigger apply once again.
