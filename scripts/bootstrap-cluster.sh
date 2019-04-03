#!/usr/bin/env bash
set -x


gcloud beta container --project "pac-test-app-landingpad" \
    clusters create "vault-cluster" --region "us-west2" \
    --no-enable-basic-auth --cluster-version "1.12.6-gke.7" \
    --machine-type "n1-standard-2" --image-type "COS" --num-nodes "1" \
    --disk-type "pd-standard" --disk-size "100" \
    --metadata disable-legacy-endpoints=true --enable-vertical-pod-autoscaling \
    --enable-cloud-logging --enable-cloud-monitoring --enable-ip-alias \
    --network "projects/pac-test-app-landingpad/global/networks/default" \
    --subnetwork "projects/pac-test-app-landingpad/regions/us-west2/subnetworks/default" \
    --default-max-pods-per-node "110" --enable-autoupgrade --enable-autorepair \
    --enable-vertical-pod-autoscaling \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing,KubernetesDashboard \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append"
