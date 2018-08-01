#!/bin/sh
set -x -e

cwd=`dirname "$0"`
expr "$0" : "/.*" > /dev/null || cwd=`(cd "$cwd" && pwd)`

RESOURCE_GROUP="Resource Group Name"
AZURE_DB_ACCOUNT_NAME="Azure Database Account Name"

## Firewall - Allow all within Azure
az mysql server firewall-rule create \
    -g $RESOURCE_GROUP \
    -s $AZURE_DB_ACCOUNT_NAME \
    --name AllowFullRangeIP \
    --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

## SSL enforcement enabled
az mysql server update \
    -g $RESOURCE_GROUP \
    -n $AZURE_DB_ACCOUNT_NAME \
    --ssl-enforcement Enabled
