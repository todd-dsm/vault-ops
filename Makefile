#!/usr/bin/env make
# PREREQ: source scripts/build.env tsirung
# vim: tabstop=8 noexpandtab

# Grab some ENV stuff
myRelease	?= $(shell $(myRelease))
nameSpace	?= $(shell $(nameSpace))


# ensure some requirements are met
prep:  ## Prepare Kube cluster w/ Helm
	helm init --upgrade
	echo "source scripts/build.env tsirung"

# vault: first the CRD, then the Operator
vault:  ## install Vault via Helm 
	scripts/inst_vault.sh 

proxy:  ## proxy out to the cluster for the unseal
	@scripts/proxy_out.sh $(myRelease)


unseal: ## Unseal Vault
	exec scripts/open_vault.sh $(myRelease)

expose: ## create the NodePort to the service from the outside
	create -f kubes/service_external.yaml
	kubectl get services tsirung-external -o yaml

clean: ## Destroy all in order
	@helm delete --purge $(myRelease)
	@sudo lsof -i :8200 | grep IPv4 | awk '{print $2}' | \
		xargs kill -9

print-%  : ## Print any variable from the Makefile (e.g. make print-VARIABLE);
	@echo $* = $($*)

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
