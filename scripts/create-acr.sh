#!/bin/bash

set -e -x

RESOURCE_GROUP="<Reousrce Group Name>"
ACR_NAME="<ACR Instance Name>"
ACR_SKU="<ACR SKU: Basic|Standard|Premium>"

echo "Create ACR Instance..."

az acr create --resource-group $RESOURCE_GROUP \
    --name $ACR_NAME \
    --sku $ACR_SKU
