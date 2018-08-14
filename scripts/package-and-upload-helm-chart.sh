#!/bin/bash
set -x -e

cwd=`dirname "$0"`
expr "$0" : "/.*" > /dev/null || cwd=`(cd "$cwd" && pwd)`

RESOURCE_GROUP="<Reousrce Group Name>"
STORAGE_NAME="<Azure Storage Account Name>"
CONTAINER_NAME="<Storage Container Name>"

HELM_PACKAGE_PATH=$(helm package $cwd/../charts/azure-voting-app | awk '{print $8}')
HELM_PACKAGE=$(basename $HELM_PACKAGE_PATH)
echo $HELM_PACKAGE

# Get Key
ACCESS_KEY=$(az storage account keys list --account-name $STORAGE_NAME --resource-group $RESOURCE_GROUP --output tsv |head -1 | awk '{print $3}')

az storage blob upload \
    --account-name $STORAGE_NAME \
    --container-name $CONTAINER_NAME \
    --account-key $ACCESS_KEY \
    --name $HELM_PACKAGE \
    --file $HELM_PACKAGE_PATH

rm $HELM_PACKAGE
