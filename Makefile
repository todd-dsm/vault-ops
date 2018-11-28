#!/usr/bin/env make
# PREREQ: source scripts/build.env tsirung
# vim: tabstop=8 noexpandtab

# Grab some ENV stuff
myRelease	?= $(shell $(myRelease))
nameSpace	?= $(shell $(nameSpace))


.PHONY:  help

help: 
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

print-%:
	@echo $*=$($*)

# ensure some requirements are met
prep:  ## Prepare Kube cluster w/ Helm
	helm init --upgrade
	echo "source scripts/build.env tsirung"


# vault: first the CRD, then the Operator
vault:  ## install Vault via Helm + setup local proxy for unseal
	scripts/inst_vault.sh
	@scripts/proxy_out.sh $(myRelease)


unseal: ## Unseal Vault
	exec scripts/open_vault.sh $(myRelease)


clean: ## Destroy all in order
	helm delete --purge $(myRelease) > /dev/null
	sudo lsof -PiTCP -sTCP:LISTEN | grep 8200 | awk 'NR==2{print $2}'| \
		head -1 | xargs kill -9 > /dev/null
