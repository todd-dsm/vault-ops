#!/usr/bin/env bash
# PURPOSE: Start a version of kubernetes

mkVers='v1.11.3'
#mkVers='v1.12.3'

minikube start --kubernetes-version="$mkVers"
