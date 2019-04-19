#!/usr/bin/env bash

################################################################
# Parameters
################################################################
RESOURCE_GROUP="<Reousrce Group Name>"
CLUSTER_NAME="<AKS Cluster Name>"
# Service Principal
SP_CLIENT_ID="<Service Principal Client ID>"
# VNET Info
VNET_NAME="<Virtual Network Name>"
SUBNET_VIRTUAL_NODE="<Subname name for AKS>"

################################################################
# Script Start
################################################################
echo "Create Subnet for Virtual Nodes"
az network vnet subnet create \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $VNET_NAME \
    --name $SUBNET_VIRTUAL_NODE \
    --address-prefix 10.241.0.0/16

echo "Get the virtual network resource ID"
VNET_ID=$(az network vnet show --resource-group $RESOURCE_GROUP --name $VNET_NAME --query id -o tsv)

echo "To grant the correct access for the AKS cluster to use the virtual network"
az role assignment create --assignee $SP_CLIENT_ID --scope $VNET_ID --role Contributor

