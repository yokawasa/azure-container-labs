#!/bin/sh
set -x -e

cwd=`dirname "$0"`
expr "$0" : "/.*" > /dev/null || cwd=`(cd "$cwd" && pwd)`

RESOURCE_GROUP="Resource Group Name"
AZURE_DB_ACCOUNT_NAME="Azure Database Account Name"
MYSQL_ADMIN_USER="DB Admin User Name"
MYSQL_ADMIN_PASSWORD="DB Admin User Name"
AZURE_DB_SKU="B_Gen4_1"                             # tier_family_cores
LOCATION="Azure Region"                             # ie. japaneast etc

## Create Azure Database for MySQL 
az mysql server create \
    --resource-group $RESOURCE_GROUP \
    --name $AZURE_DB_ACCOUNT_NAME \
    --admin-user $MYSQL_ADMIN_USER \
    --admin-password $MYSQL_ADMIN_PASSWORD \
    --sku-name $AZURE_DB_SKU \
    --location $LOCATION

## Firewall - Allow from All
az mysql server firewall-rule create \
    -g $RESOURCE_GROUP \
    -s $AZURE_DB_ACCOUNT_NAME \
    --name AllowFullRangeIP \
    --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255

## SSL enforcement disable
az mysql server update \
    -g $RESOURCE_GROUP \
    -n $AZURE_DB_ACCOUNT_NAME \
    --ssl-enforcement Disabled

## Confirm Access
mysqladmin -u $MYSQL_ADMIN_USER@$AZURE_DB_ACCOUNT_NAME -p$MYSQL_ADMIN_PASSWORD -h $AZURE_DB_ACCOUNT_NAME.mysql.database.azure.com ping

## Create Database 'azurevote' on Azure MySQL (Azure Database for MySQL)
echo "CREATE TABLE azurevote.azurevote (voteid INT NOT NULL AUTO_INCREMENT,votevalue VARCHAR(45) NULL,PRIMARY KEY (voteid));" \
    | mysql -u $MYSQL_ADMIN_USER@$AZURE_DB_ACCOUNT_NAME -p$MYSQL_ADMIN_PASSWORD -h $AZURE_DB_ACCOUNT_NAME.mysql.database.azure.com
