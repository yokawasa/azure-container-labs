# Module AKS102: Azure Container Registry (ACR) and ACR Build

In this module, you will use Azure Container Registry (ACR) to build containers from Dockerfiles and also host your images to run in AKS

## Create Azure Container Registry instance

```sh
ACR_NAME="myazconacr"   # Registry Name
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Standard
```
> - Resource Group: Use the existing Resource Group that you created in previous module
> - SKU Options: `Basic`, `Standard`(default), `Premium`: The Standard registry offers the same capabilities as Basic, but with increased storage limits and image throughput. Standard registries should satisfy the needs of most production scenarios.

## Build Containers from Dockerfiles using ACR Build and host the images in ACR

### Clone the workshop repo into the cloud shell environment

Clone the workshop repo
```sh
$ git clone https://github.com/yokawasa/azure-container-labs.git
```

Then, change directory to the repository

```
$ cd azure-container-labs
$ ls

apps  assets  charts  kubernetes-manifests  labs  LICENSE  README.md  scripts
```

### Build azure-vote-front container
```sh
ACR_NAME="myazconacr"   # Registry Name
cd azure-container-labs/apps/vote/azure-vote
az acr build --registry $ACR_NAME --image azure-vote-front:1.0.0 .
```

### Build azure-vote-msyql container
```sh
ACR_NAME="myazconacr"   # Registry Name
cd azure-container-labs/apps/vote/azure-vote-mysql
az acr build --registry $ACR_NAME --image azure-vote-back:1.0.0 .
```

### Check your repositories in ACR

```
$ az acr repository list -n $ACR_NAME -o table

Result
----------------
azure-vote-front
azure-vote-back
```

```
$  az acr repository show -n $ACR_NAME --repository azure-vote-front -o table

CreatedTime                   ImageName         LastUpdateTime                ManifestCount    Registry               TagCount
----------------------------  ----------------  ----------------------------  ---------------  ---------------------  ----------
2018-09-20T02:03:33.3498203Z  azure-vote-front  2018-09-20T02:03:33.4005353Z  1                myazconacr.azurecr.io  1
```


## Useful Links
- https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tutorial-quick-build
- https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest

---
[Top](../README.md) | [Back](aks-101-create-aks-cluster.md) | [Next](aks-103-deploy-app.md)
