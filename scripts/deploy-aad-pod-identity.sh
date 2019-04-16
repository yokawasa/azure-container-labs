#!/bin/bash
set -x -e

################################################################
# Parameters
################################################################
RESOURCE_GROUP_AKS_NODE="<AKS-Nodes-Resource-Group: MC_****>"
IDENTITY_NAME="<Identity-Name>"
RESOURCE_GROUP_APPGW="<Resource-Group-AppGateway>"
SUBSCRIPTION_ID="<Subscription-ID>"
APPGW_NAME="<AppGateway-Name>"

################################################################
# Script Start
################################################################
echo "Create an Azure identity in the same resource group as the AKS nodes"
az identity create -g $RESOURCE_GROUP_AKS_NODE -n $IDENTITY_NAME

echo "Find the principal, resource and client ID for this identity"
az identity show -g $RESOURCE_GROUP_AKS_NODE -n $IDENTITY_NAME
PRINCIPAL_ID=$(az identity show -g $RESOURCE_GROUP_AKS_NODE -n $IDENTITY_NAME --output tsv | awk '{print $6}')

RESOURCE_ID_APPGW="/subscriptions/$SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP_APPGW/providers/Microsoft.Network/applicationGateways/$APPGW_NAME"
echo "Assign this new identity Contributor access on the application gateway"
az role assignment create --role Contributor --assignee $PRINCIPAL_ID --scope $RESOURCE_ID_APPGW

RESOURCE_ID_APPGW_RESOURCE_GROUP="/subscriptions/$SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP_APPGW"
echo "Assign this new identity Reader access on the resource group that the application gateway belongs to"
az role assignment create --role Reader --assignee $PRINCIPAL_ID --scope $RESOURCE_ID_APPGW_RESOURCE_GROUP
