#!/bin/bash
set -x -e

RESOURCE_GROUP="<Reousrce Group Name>"
CLUSTER_NAME="<AKS Cluster Name>"
REGION="<Region>"
# Service Principal
SP_CLIENT_ID="<Service Principal Client ID>"
SP_CLIENT_SECRET="<Service Principal Secret>"
# VNET Info
VNET_NAME="<Virtual Network Name>"
SUBNET_AKS="<Subname name for AKS>"
# Cluster Parameters
NODE_COUNT="<Node#>"
SSH_KEY="<SSH Public Key Path>"


LATEST_KUBE_VERSION=$(az aks get-versions --location $REGION --output table  |head -3 | grep "1.*" |awk '{print $1}')
echo "LATEST_KUBE_VERSION=> $LATEST_KUBE_VERSION"
KUBE_VERSION=$LATEST_KUBE_VERSION

echo "Create Resource Group: $RESOURCE..."
#pip install -U azure-cli
#az provider register -n Microsoft.ContainerService
az group create --name $RESOURCE_GROUP --location $REGION

echo "Create VNET and Subnet for AKS cluster..."
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $VNET_NAME \
    --address-prefixes 10.0.0.0/8 \
    --subnet-name $SUBNET_AKS \
    --subnet-prefix 10.240.0.0/16

echo "Get the virtual network resource ID"
VNET_ID=$(az network vnet show --resource-group $RESOURCE_GROUP --name $VNET_NAME --query id -o tsv)

echo "To grant the correct access for the AKS cluster to use the virtual network"
az role assignment create --assignee $SP_CLIENT_ID --scope $VNET_ID --role Contributor

echo "Get the ID of this subnet into which you deploy an AKS cluster"
AKS_SUBNET_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_AKS --query id -o tsv)

echo "Create an AKS cluster"
START=`date +%s`

az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 1 \
    --enable-addons http_application_routing \
    --network-plugin azure \
    --service-cidr 10.0.0.0/16 \
    --dns-service-ip 10.0.0.10 \
    --docker-bridge-address 172.17.0.1/16 \
    --vnet-subnet-id $AKS_SUBNET_ID \
    --service-principal $SP_CLIENT_ID \
    --client-secret $SP_CLIENT_SECRET \
    --ssh-key-value $SSH_KEY \
    --enable-vmss


END=`date +%s`
SS=`expr ${END} - ${START}`
echo "cluster create time - $SS"
