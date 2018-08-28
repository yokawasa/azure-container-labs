#!/bin/bash
set -x -e

RESOURCE_GROUP="<Reousrce Group Name>"
CLUSTER_NAME="<AKS Cluster Name>"
REGION="<Region>"
# Service Principal
SP_CLIENT_ID="<Service Principal Client ID>"
SP_CLIENT_SECRET="<Service Principal Secret>"
# Cluster Parameters
NODE_COUNT="<Node#>"
VM_SIZE="VM Size Name for Worker Node"
KUBE_VERSION="Kubernetes Version"
SSH_KEY="SSH Public Key Path"
OMS_WORKSPACE_RESOURCE_ID="/subscriptions/<SubscriptionID>/resourceGroups/<ResourceGroupName>/providers/Microsoft.OperationalInsights/workspaces/<WorkspaceID>"

## Examples
# RESOURCE_GROUP="RG-aks"
# CLUSTER_NAME="myAKSCluster"
# REGION="japaneast"
## Service Principal
#SP_CLIENT_ID="20b943f5-6d00-441c-8263-67adca5582ex"
#SP_CLIENT_SECRET="97803bdf-b42e-4bcb-ae20-a93aa0361500"
## Cluster Parameters
#NODE_COUNT=2
#VM_SIZE=Standard_D2_v2
#KUBE_VERSION=1.11.1
# SSH_KEY="~/.ssh/id_rsa.pub"
# OMS_WORKSPACE_RESOURCE_ID="/subscriptions/87x7c7f9-0c9f-47d1-a856-1305a0cbfd7a/resourceGroups/DefaultResourceGroup-EJP/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-87c7c7f9-0c9f-47d1-a856-1305a0cbfd7a-EJP"

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
    --node-vm-size $VM_SIZE \
    --node-count $NODE_COUNT \
    --service-principal $SP_CLIENT_ID \
    --client-secret $SP_CLIENT_SECRET \
    --enable-addons http_application_routing,monitoring \
    --workspace-resource-id $OMS_WORKSPACE_RESOURCE_ID \
    --ssh-key-value $SSH_KEY 
