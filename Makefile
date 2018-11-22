#!/usr/bin/env make
# PREREQ: source scripts/build.env tsirung
# vim: tabstop=8 noexpandtab

# Grab some ENV stuff
myRelease	?= $(shell $(myRelease))
nameSpace	?= $(shell $(nameSpace))


# ensure some requirements are met
prep:
	helm init --upgrade
	echo "source scripts/build.env tsirung"


# vault: first the CRD, then the Operator
vault:
	scripts/inst_vault.sh


unseal:
	exec scripts/open_vault.sh $(myRelease)


clean: ## Destroy all in order
	helm delete --purge $(myRelease) > /dev/null
	sudo lsof -PiTCP -sTCP:LISTEN | grep 8200 | awk '{print $2}' | \
		head -1 | xargs kill -9 > /dev/null
