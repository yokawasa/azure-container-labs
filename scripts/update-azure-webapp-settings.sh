#!/bin/sh
set -x -e

cwd=`dirname "$0"`
expr "$0" : "/.*" > /dev/null || cwd=`(cd "$cwd" && pwd)`

RESOURCE_GROUP="Resource Group Name"
APP_NAME="Web App Name"

MYSQL_USER="<mysqluser>@<azuremysqlaccount>"
MYSQL_PASSWORD="<password>"
MYSQL_DATABASE="azurevote"  # fixed
MYSQL_HOST="<azuremysqlaccount>.mysql.database.azure.com"

## Configure App Settings
az webapp config appsettings set \
  -n $APP_NAME \
  -g $RESOURCE_GROUP \
  --settings \
    MYSQL_USER=$MYSQL_USER \
    MYSQL_PASSWORD=$MYSQL_PASSWORD \
    MYSQL_DATABASE=$MYSQL_DATABASE \
    MYSQL_HOST=$MYSQL_HOST
