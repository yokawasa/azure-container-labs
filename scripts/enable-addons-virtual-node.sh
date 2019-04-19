#!/usr/bin/env bash

################################################################
# Parameters
################################################################
RESOURCE_GROUP="<Reousrce Group Name>"
CLUSTER_NAME="<AKS Cluster Name>"
# VNET Info
VNET_NAME="<Virtual Network Name>"
SUBNET_VIRTUAL_NODE="<Subname name for AKS>"

################################################################
# Start Script
################################################################
cat << EOD | tee
PREREQUISITES:
- Virtual node enabled AKS cluster running Kubernetes version 1.10 or later
- Virtual nodes only work with AKS clusters created using advanced networking (network plugin:azure)
- Subnet for Virtual Nodes
EOD

# echo "Install the extension using the az extension add command to enable the virtual nodes connector"
# az extension add --source https://aksvnodeextension.blob.core.windows.net/aks-virtual-node/aks_virtual_node-0.2.0-py2.py3-none-any.whl

echo "Use the az aks enable-addons command to enable virtual nodes"
az aks enable-addons \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --addons virtual-node \
    --subnet-name $SUBNET_VIRTUAL_NODE

