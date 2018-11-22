#!/usr/bin/env bash
# shellcheck disable=SC2154
#  PURPOSE: Description
# -----------------------------------------------------------------------------
#  PREREQS: a) source scripts/build.env tsirung
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
nodeCount='2'
vaultCRD='kubes/vault.yaml'
opsVersion='0.9.1-0'


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Create the CRD
### FIXME: apiVersion, spec.version
###---
cat > "$vaultCRD" <<EOF
apiVersion: "vault.security.coreos.com/v1alpha1"
kind: "VaultService"
metadata:
  name: "$myRelease"
spec:
  nodes: $nodeCount
  version: "$opsVersion"
EOF


###---
### Install the Vault Operator
###   * etcd Operator included
###---
helm install stable/vault-operator  \
    --name="$myRelease"             \
    --values='kubes/values.yaml'


###---
### wait for the above deployment to finish
###---
sleep 20


###---
### Deploy the CRD, then wait
###   total 60 seconds
###     1 - for the pod/tsirung-etcd-kg2pfc52nb      # vault storage    20s
###     2 - for the pod/tsirung-748fcd764f-6zlkt     # vault            40s
###---
kubectl create -f "$vaultCRD"


###---
### Initialize and Unseal
###---
#sleep 110
#scripts/open_vault.sh "$myRelease"


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### REQ
###---


###---
### fin~
###---
exit 0
