#!/usr/bin/env make
# PREREQ: source scripts/build.env tsirung
# vim: tabstop=8 noexpandtab

# Grab some ENV stuff
vaultRelName	?= $(shell $(vaultRelName))
opsRelName	?= $(shell $(opsRelName))
nameSpace	?= $(shell $(nameSpace))


# ensure some requirements are met
cluster:  ## Bootstrap a 1-node cluster in minikube
	scripts/minikube.sh

prep:  ## Prepare Kube cluster w/ Helm
	kubectl create -f kubes/tiller-rbac.yaml
	helm init --service-account=tiller --upgrade
	@printf '\n\n%s\n' "SOURCE-IN YOUR ENV VARIABLES; EXAMPLE:"
	@printf '\n%s\n\n' "  source scripts/build.env vaultRelName"


operators: ## deploy the operators
	scripts/inst_operators.sh


vault:  ## install Vault via Helm 
	scripts/inst_vault.sh 
	kubectl --namespace=vault get vault $(vaultRelName) -o yaml


proxy:  ## proxy out to the cluster for the unseal
	scripts/proxy_out.sh


unseal: ## Unseal Vault
	scripts/open_vault.sh


policy: ## Configure Vault - update this per-use
	vault audit enable file file_path=stdout
	vault auth  enable kubernetes
	vault policy write admin_policy scripts/admin_policy.hcl
	

#tls_ingress: ## generage tls certs for ingress
#	KUBE_NS=$(nameSpace) \
#	SERVER_SECRET=vault-server-ingress-tls \
#	CLIENT_SECRET=vault-client-ingress-tls \
#	SERVER_CERT=tls.crt \
#	SERVER_KEY=tls.key \
#	scripts/tls-gen.sh
#	#SAN_HOSTS="vault.ingress.staging.core-os.net" \


###    CHECK NODEPORT BEFORE THIS STEP
expose: ## create the NodePort to the service from the outside
	@scripts/make_service.sh
	kubectl create -f kubes/service_external.yaml
	kubectl -n $(nameSpace) get services $(vaultRelName)-ext -o yaml


clean: ## Destroy all in order
	@helm delete --purge $(vaultRelName)
	@kubectl delete -f kubes/service_external.yaml
	sudo lsof -i :8200 | grep IPv4 | awk '{print $2}' | \
		xargs kill -9
	@helm delete --purge $(opsRelName)


#-----------------------------------------------------------------------------#
#------------------------   MANAGERIAL OVERHEAD   ----------------------------#
#-----------------------------------------------------------------------------#
print-%  : ## Print any variable from the Makefile (e.g. make print-VARIABLE);
	@echo $* = $($*)

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
