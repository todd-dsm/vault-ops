#!/usr/bin/env bash
# shellcheck disable=SC2154
#  PURPOSE: Description
# -----------------------------------------------------------------------------
#  PREREQS: a) source scripts/build.env relName
#           b) helm init --upgrade
#           c)
# -----------------------------------------------------------------------------
#  EXECUTE:
# -----------------------------------------------------------------------------
#     TODO: 1)
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2018/10/00
# -----------------------------------------------------------------------------
set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
#"${1?  Wheres my first agument, bro!}"
# ENV Stuff


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Install the Vault Operator
###   * etcd Operator included
###   * config opts: https://github.com/helm/charts/tree/master/stable/vault-operator#configuration
###---
#helm install stable/vault-operator  \
#    --name="$vaultRelName"          \
#    --namespace="$nameSpace"        \
#    --values='kubes/values.yaml'


###---
### Install the Banzai Cloud Vault Operator
###   * etcd Operator included
###   * https://github.com/banzaicloud/banzai-charts/tree/master/vault-operator
###---
helm install banzaicloud-stable/vault-operator  \
    --name="$vaultRelName"                      \
    --namespace="$nameSpace"                    \
    --set etcd-operator.enabled=true


###---
### REQ
###---


###---
### fin~
###---
exit 0
