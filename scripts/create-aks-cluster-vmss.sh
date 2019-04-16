#!/bin/bash
set -x -e

################################################################
# Parameters
################################################################
RESOURCE_GROUP="<Reousrce Group Name>"
CLUSTER_NAME="<AKS Cluster Name>"
REGION="<Region>"
# Service Principal
SP_CLIENT_ID="<Service Principal Client ID>"
SP_CLIENT_SECRET="<Service Principal Secret>"
# Cluster Parameters
SSH_KEY="<SSH Public Key Path>"

################################################################
# Script Start
################################################################
echo "Create Resource Group"
az group create --name $RESOURCE_GROUP --location $REGION

echo "Install aks-preview CLI extension"
az extension add --name aks-preview

echo "Register scale set feature provider"
az feature register --name VMSSPreview --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.ContainerService

START=`date +%s`
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --kubernetes-version 1.12.6 \
  --node-count 1 \
  --service-principal $SP_CLIENT_ID \
  --client-secret $SP_CLIENT_SECRET \
  --ssh-key-value $SSH_KEY \
  --enable-vmss

END=`date +%s`
SS=`expr ${END} - ${START}`
echo "cluster create time - $SS"
