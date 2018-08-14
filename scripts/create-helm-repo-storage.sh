#!/bin/bash
set -x -e

cwd=`dirname "$0"`
expr "$0" : "/.*" > /dev/null || cwd=`(cd "$cwd" && pwd)`

RESOURCE_GROUP="<Reousrce Group Name>"
STORAGE_NAME="<Azure Storage Account Name>"
CONTAINER_NAME="<Storage Container Name>"

# Create Azure Storage Account for Video Processing Pipeline and Blob Container in the account
az storage account create \
    --name $STORAGE_NAME \
    --resource-group $RESOURCE_GROUP \
    --sku Standard_LRS \
    --kind Storage

# Get Key
ACCESS_KEY=$(az storage account keys list --account-name $STORAGE_NAME --resource-group $RESOURCE_GROUP --output tsv |head -1 | awk '{print $3}')

# Create Container
az storage container create  \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_NAME \
    --account-key $ACCESS_KEY \
    --public-access blob

