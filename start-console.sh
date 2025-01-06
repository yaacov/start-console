#!/usr/bin/env bash

set -euo pipefail
script_dir=$(dirname "$0")

CONSOLE_CONTAINER_NAME=okd-console

CONTAINER_NETWORK_TYPE=${CONTAINER_NETWORK_TYPE:-"host"}
CONSOLE_IMAGE=${CONSOLE_IMAGE:-"quay.io/openshift/origin-console:latest"}
CONSOLE_PORT=${CONSOLE_PORT:-9000}

PULL_POLICY=${PULL_POLICY:-"always"}

# Test if console is already running
if podman container exists ${CONSOLE_CONTAINER_NAME}; then
  echo "container named ${CONSOLE_CONTAINER_NAME} is running, exit."
  exit 1
fi

# remove all exported variables with the prefix "BRIDGE_"...
for var in $(compgen -v | grep '^BRIDGE_'); do
  unset "$var"
done

BRIDGE_BASE_ADDRESS="http://localhost:${CONSOLE_PORT:-9000}"
BRIDGE_K8S_MODE="off-cluster"
BRIDGE_K8S_MODE_OFF_CLUSTER_SKIP_VERIFY_TLS=true
BRIDGE_USER_SETTINGS_LOCATION="localstorage"

BRIDGE_K8S_AUTH="bearer-token"
BRIDGE_USER_AUTH="disabled"

CURRENT_CONTEXT="$(kubectl config current-context)"
BRIDGE_K8S_MODE_OFF_CLUSTER_ENDPOINT="$(kubectl config view --minify -o jsonpath="{.clusters[?(@.name=='${CURRENT_CONTEXT}')].cluster.server}")"

kubectl create serviceaccount myadmin --dry-run=client -o yaml | kubectl apply -f -
kubectl create clusterrolebinding myadmin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=default:myadmin \
  --dry-run=client -o yaml | kubectl apply -f -

SECRET_NAME="$(kubectl get serviceaccount myadmin -o jsonpath='{.secrets[0].name}')"
BRIDGE_K8S_AUTH_BEARER_TOKEN="$(kubectl get secret "$SECRET_NAME" -o jsonpath='{.data.token}' | base64 --decode)"

# export all variables with the prefix "BRIDGE_"...
export $(compgen -v | grep '^BRIDGE_')

# run the console container
echo "
Starting local OpenShift console...
===================================
API Server: ${BRIDGE_K8S_MODE_OFF_CLUSTER_ENDPOINT}
Console URL: ${BRIDGE_BASE_ADDRESS}
Console Image: ${CONSOLE_IMAGE}
Container pull policy: ${PULL_POLICY}
"

podman run \
    --pull=${PULL_POLICY} \
    --rm \
    --network=${CONTAINER_NETWORK_TYPE} \
    --publish=${CONSOLE_PORT}:${CONSOLE_PORT} \
    --name=${CONSOLE_CONTAINER_NAME} \
    --env "BRIDGE_*" \
    --arch=amd64 \
    ${CONSOLE_IMAGE}
