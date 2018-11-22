#!/usr/bin/env bash
#  PURPOSE: auto-initialize and unseal vault
# -----------------------------------------------------------------------------
#  PREREQS: a)
#           b)
#           c)
# -----------------------------------------------------------------------------
#  EXECUTE:
# -----------------------------------------------------------------------------
#     TODO: 1) Fix expansion of 'example'
#           2)
#           3)
# -----------------------------------------------------------------------------
#   AUTHOR: Todd E Thomas
# -----------------------------------------------------------------------------
#  CREATED: 2018/09/00
# -----------------------------------------------------------------------------
set -x

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
releaseName="$1"
export VAULT_ADDR='https://localhost:8200'
export VAULT_SKIP_VERIFY="true"

# Data Files
theJelly='/tmp/jelly.out'


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
### Port-forward to the un-sealed/initialized endpoint: myRelease, then
### Access the vault by initializing and unsealing
function vaultInit() {
    currentRelease="$1"
    {
        kubectl -n default get vault "$currentRelease" \
            -o jsonpath='{.status.vaultStatus.sealed[0]}' | \
            xargs -0 -I {} kubectl -n default port-forward {} 8200&
    } > /dev/null
    vault operator init  2>&1 | tee "$theJelly"
}

# Export the Root Token
function getToken() {
    export ROOT_TOKEN="$(grep 'Root' "$theJelly" | awk '{print $4}')"
    export UNSEAL_KEY="$(grep 'Unseal Key 1' "$theJelly" | awk '{print $4}')"

}

###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### Initialize
###---
vaultInit "$releaseName"


###---
### Export the Root Token
###---
getToken "$theJelly"


###---
### Unseal
###---
vault operator unseal "$UNSEAL_KEY"


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
