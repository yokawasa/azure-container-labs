# WEBAPP103: Setup Web App and deploy the application to Web App

```sh
RESOURCE_GROUP="Resource Group Name"
APP_NAME="Web App Name"
APP_SERVICE_PLAN="App Service Plan Name"
APP_SERVICE_PLAN_SKU="S1"
CONTAINER_IMAGE=<REGISTRY_URL>/<CONTAINER_IMAGE:TAG>

MYSQL_USER="<mysqluser>@<azuremysqlaccount>"
MYSQL_PASSWORD="<password>"
MYSQL_DATABASE="azurevote"  # fixed
MYSQL_HOST="<azuremysqlaccount>.mysql.database.azure.com"
```

## Create Resource Group for App Service Plan (if needed)
```sh
az group create --name $RESOURCE_GROUP --location $LOCATION
```

## Create App Service Plan (If it's App Service Plan instead of Consumption Plan)
```
az appservice plan create \
 --name $APP_SERVICE_PLAN \
 --resource-group $RESOURCE_GROUP \
 --sku $APP_SERVICE_PLAN_SKU --is-linux
```
> [NOTE] Plan with Linux worker can only be created in a group which has never contained a Windows worker, and vice versa.

## Create Web App for Container
```sh
az webapp create \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --plan $APP_SERVICE_PLAN \
  --deployment-container-image-name $CONTAINER_IMAGE
```

## Configure App Settings for accessing MySQL
```sh
az webapp config appsettings set \
  -n $APP_NAME \
  -g $RESOURCE_GROUP \
  --settings \
    MYSQL_USER=$MYSQL_USER \
    MYSQL_PASSWORD=$MYSQL_PASSWORD \
    MYSQL_DATABASE=$MYSQL_DATABASE \
    MYSQL_HOST=$MYSQL_HOST
```

---
[Top](../README.md) | [Back](webapp-102-acr.md)