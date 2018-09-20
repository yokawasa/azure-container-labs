#!/bin/bash
set -e -x

RESOURCE_GROUP="<Reousrce Group Name>"
REGION="<Region Name: eastus,japaneast,etc.>" 
echo "Create Resource Group..."

az group create --resource-group $RESOURCE_GROUP --location $REGION
