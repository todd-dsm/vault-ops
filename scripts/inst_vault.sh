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
#   AUTHOR: todd-dsm
# -----------------------------------------------------------------------------
set -x


###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
#"${1?  Wheres my first agument, bro!}"
# ENV Stuff
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
  name: "$vaultRelName"
  namespace: $nameSpace
spec:
  nodes: $nodeCount
  version: "$opsVersion"
EOF


###---
### Deploy the CRD, then wait
###   total 60 seconds
###     1 - for the pod/example-etcd-kg2pfc52nb      # vault storage    20s
###     2 - for the pod/example-748fcd764f-6zlkt     # vault            40s
###---
kubectl create -f "$vaultCRD"


###---
### REQ
###---


###---
### fin~
###---
exit 0
