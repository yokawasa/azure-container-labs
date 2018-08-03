#!/bin/bash
set -x -e

RESOURCE_GROUP="<Reousrce Group Name>"
CLUSTER_NAME="<AKS Cluster Name>"
REGION="<Region>"
# Cluster Parameters
NODE_COUNT="<Node#>"
KUBE_VERSION="Kubernetes Version"

## Examples
# RESOURCE_GROUP="RG-aks"
# CLUSTER_NAME="myAKSCluster"
# REGION="japaneast"
## Cluster Parameters
#NODE_COUNT=2
#KUBE_VERSION=1.10.3

echo "Regist relevant providers..."
az provider register -n Microsoft.Network
az provider register -n Microsoft.Storage
az provider register -n Microsoft.Compute
az provider register -n Microsoft.ContainerService

echo "Create Azure resource group..."
az group create --name $RESOURCE_GROUP --location $REGION

echo "Create AKS Cluster..."
az aks create --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --kubernetes-version $KUBE_VERSION \
    --node-count $NODE_COUNT \
    --generate-ssh-keys
