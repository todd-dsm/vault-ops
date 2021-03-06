#!/usr/bin/env bash
# shellcheck disable=SC2001
#  PURPOSE: Generate custom TLS assets for the Ingress host
# -----------------------------------------------------------------------------
#  PREREQS: a)
#           b)
#           c)
# -----------------------------------------------------------------------------
# Usage:
#   KUBE_NS=default \
#   SERVER_SECRET=vault-server-tls \
#   CLIENT_SECRET=vault-client-tls \
#   tls-gen.sh
# Additional params:
#   SAN_HOSTS="a.b.c,x.y.z"
#   SERVER_CERT="tls.crt"
#   SERVER_KEY="tls.key"

# -----------------------------------------------------------------------------
#     TODO: 1) FIXME: for i in $(echo "${SAN_HOSTS}"; then remove disable SC2001
#           2)
#           3)
# -----------------------------------------------------------------------------
#  CREATED: 2018/09/00
# -----------------------------------------------------------------------------
set -x

###----------------------------------------------------------------------------
### VARIABLES
###----------------------------------------------------------------------------
# ENV Stuff
: "${KUBE_NS:?"Need to set KUBE_NS"}"
SERVER_CERT=${SERVER_CERT:-"server.crt"}
SERVER_KEY=${SERVER_KEY:-"server.key"}
SERVER_SECRET=vault-server-tls
CLIENT_SECRET=vault-client-tls
# Create temporary output directory
OUTPUT_DIR=$(mktemp -d)
# these programs need to be installed
declare reqdProgs=('cfssl' 'cfssljson' 'jq' 'kubectl')


###----------------------------------------------------------------------------
### FUNCTIONS
###----------------------------------------------------------------------------
function pMsg() {
    theMessage="$1"
    printf '%s\n' "$theMessage"
}
# Deletes the temp directory
function cleanup {
  rm -rf "$OUTPUT_DIR"
}
trap cleanup EXIT


###----------------------------------------------------------------------------
### MAIN PROGRAM
###----------------------------------------------------------------------------
### PREP: Verify required programs
###---
pMsg "Verifying required programs are installed..."
for myProgram in "${reqdProgs[@]}"; do
    if ! command -v "$myProgram" > /dev/null; then
        echo "$myProgram needs to be installed"
        exit 1
    else
        printf '%s\n\n' "  Installed: $myProgram"
    fi
done


###---
### Dump the old garbage
###---
pMsg "Cleaning up a bit..."
rm -rf "$OUTPUT_DIR/config"
mkdir -p "$OUTPUT_DIR/config"
rm -rf "$OUTPUT_DIR/certs/tmp"
mkdir -p "$OUTPUT_DIR/certs/tmp"


###----------------------------------------------------------------------------
### Generate the TLS Assets
###----------------------------------------------------------------------------
### Generate ca-config.json and ca-csr.json
cfssl print-defaults config | \
  jq 'del(.signing.profiles) | .signing.default.expiry="8760h" | .signing.default.usages=["signing", "key encipherment", "server auth"] | .key = {"algo":"rsa","size":2048}' \
  > "$OUTPUT_DIR/config/ca-config.json"
cfssl print-defaults csr | \
  jq 'del(.hosts) | .CN = "Autogenerated CA" | .names[0].O="Autogen CA for Vault-Operator" | .key = {"algo":"rsa","size":2048}' \
	> "$OUTPUT_DIR/config/ca-csr.json"



###---
### add additional hosts to SAN:
###   SAN_HOSTS="a.b.c,x.y.z"
###---
HOSTS="\"localhost\", \"*.${KUBE_NS}.pod\", \"*.${KUBE_NS}.svc\""
for i in $(echo "${SAN_HOSTS}" | sed "s/,/ /g")
do
    HOSTS="\"$i\",${HOSTS}"
done

echo "SAN HOSTS: ${HOSTS}"


###---
### Generate TLS Assets
###---
### Generate vault-server-csr.json with the SANs according to the namespace and name of the vault cluster
cfssl print-defaults csr | jq ".hosts = [$HOSTS]" | \
	jq '.CN = "vault-server" | .key = {"algo":"rsa","size":2048}' > \
    "$OUTPUT_DIR/config/vault-csr.json"

### Generate ca cert and key
cfssl gencert -initca "$OUTPUT_DIR/config/ca-csr.json" | \
    cfssljson -bare "$OUTPUT_DIR/certs/tmp/ca"

### Generate server cert and key
cfssl gencert \
    -ca "$OUTPUT_DIR/certs/tmp/ca.pem" \
    -ca-key "$OUTPUT_DIR/certs/tmp/ca-key.pem" \
    -config "$OUTPUT_DIR/config/ca-config.json" \
    "$OUTPUT_DIR/config/vault-csr.json" | \
    cfssljson -bare "$OUTPUT_DIR/certs/tmp/server"

### Rename certs for vault-operator consumption
mv "$OUTPUT_DIR/certs/tmp/ca.pem" "$OUTPUT_DIR/certs/vault-client-ca.crt"
mv "$OUTPUT_DIR/certs/tmp/server.pem" "$OUTPUT_DIR/certs/${SERVER_CERT}"
mv "$OUTPUT_DIR/certs/tmp/server-key.pem" "$OUTPUT_DIR/certs/${SERVER_KEY}"

### Create server secret
if [[ -n "${SERVER_SECRET}" ]]; then
	echo "creating server secret: ${SERVER_SECRET}"
	kubectl -n "$KUBE_NS" create secret generic "$SERVER_SECRET" \
    --from-file="$OUTPUT_DIR/certs/${SERVER_CERT}" \
    --from-file="$OUTPUT_DIR/certs/${SERVER_KEY}"
fi

### Create client secret
if [[ -n "${CLIENT_SECRET}" ]]; then
  echo "creating client secret: ${CLIENT_SECRET}"
	kubectl -n "$KUBE_NS" create secret generic "$CLIENT_SECRET" \
        --from-file="$OUTPUT_DIR/certs/vault-client-ca.crt"
fi


###---
### REQ
###---


###---
### fin~
###---
exit 0
