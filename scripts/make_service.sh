#!/usr/bin/env bash
# shellcheck disable=SC2154

serviceFile='kubes/service_external.yaml'

cat > "$serviceFile" <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${vaultRelName}-ext
  namespace: $nameSpace
  labels:
    app: vault
    vault_cluster: $vaultRelName
spec:
  type: NodePort
  ports:
  - name: vault-client
    port: 8200
    protocol: TCP
    targetPort: 8200
  - name: vault-cluster
    port: 8201
    protocol: TCP
    targetPort: 8201
  - name: prometheus
    port: 9102
    protocol: TCP
    targetPort: 9102
  selector:
    app: vault
    vault_cluster: $vaultRelName
  sessionAffinity: None
EOF
