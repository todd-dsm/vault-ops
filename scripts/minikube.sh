#!/usr/bin/env bash
# PURPOSE: Start a version of kubernetes

mkVers='v1.13.11'

minikube start --kubernetes-version="$mkVers"
