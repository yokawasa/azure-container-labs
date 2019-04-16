# AKS204:  Application Gateway Ingress Controller 

<!-- TOC -->
- [AKS204: Application Gateway Ingress Controller](#aks204-application-gateway-ingress-controller)
  - [Create AKS Cluster: Advanced Network plugin + Custom VNET](#create-aks-cluster-advanced-network-plugin--custom-vnet)
  - [Deploy sample app to AKS Cluster](#deploy-sample-app-to-aks-cluster)
  - [Setup Application Gateway Ingress Controller](#setup-application-gateway-ingress-controller)
    - [Install Azure Application Gateway v2](#install-azure-application-gateway-v2)
    - [Deploy aad-pod-identity service on AKS cluster](#deploy-aad-pod-identity-service-on-aks-cluster)
    - [Install Application Gateway Kubernetes Ingress](#install-application-gateway-kubernetes-ingress)
  - [Cleanup Resources](#cleanup-resources)

In this module, you deploy the Application Gateway Ingress controller in your AKS cluster and make your app accessible via the the Ingress controller. 

- https://github.com/Azure/application-gateway-kubernetes-ingress


## Create AKS Cluster: Advanced Network plugin + Custom VNET

Now you create AKS cluster ( +Advanced Network plugin enabled ) in Custom VNET with `create-aks-cluster-custom-vnet.sh` script. Add your values to parameter sections and run the script:

> scripts/create-aks-cluster-custom-vnet.sh
```sh
################################################################
# Parameters
################################################################
RESOURCE_GROUP="<Reousrce Group Name>"
CLUSTER_NAME="<AKS Cluster Name>"
REGION="<Region>"
# Service Principal
SP_CLIENT_ID="<Service Principal Client ID>"
SP_CLIENT_SECRET="<Service Principal Secret>"
# VNET Info
VNET_NAME="<Virtual Network Name>"
SUBNET_AKS="<Subname name for AKS>"
# Cluster Parameters
NODE_COUNT="<Node#>"
SSH_KEY="<SSH Public Key Path>"

################################################################
# Script Start
################################################################
LATEST_KUBE_VERSION=$(az aks get-versions --location $REGION --output table  |head -3 | grep "1.*" |awk '{print $1}')
echo "LATEST_KUBE_VERSION=> $LATEST_KUBE_VERSION"
KUBE_VERSION=$LATEST_KUBE_VERSION

echo "Create Resource Group: $RESOURCE..."
az group create --name $RESOURCE_GROUP --location $REGION

echo "Create VNET and Subnet for AKS cluster..."
az network vnet create \
    --resource-group $RESOURCE_GROUP \
    --name $VNET_NAME \
    --address-prefixes 10.0.0.0/8 \
    --subnet-name $SUBNET_AKS \
    --subnet-prefix 10.240.0.0/16

echo "Get the virtual network resource ID"
VNET_ID=$(az network vnet show --resource-group $RESOURCE_GROUP --name $VNET_NAME --query id -o tsv)

echo "To grant the correct access for the AKS cluster to use the virtual network"
az role assignment create --assignee $SP_CLIENT_ID --scope $VNET_ID --role Contributor

echo "Get the ID of this subnet into which you deploy an AKS cluster"
AKS_SUBNET_ID=$(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_AKS --query id -o tsv)

az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --node-count 1 \
    --enable-addons http_application_routing \
    --network-plugin azure \
    --service-cidr 10.0.0.0/16 \
    --dns-service-ip 10.0.0.10 \
    --docker-bridge-address 172.17.0.1/16 \
    --vnet-subnet-id $AKS_SUBNET_ID \
    --service-principal $SP_CLIENT_ID \
    --client-secret $SP_CLIENT_SECRET \
    --ssh-key-value $SSH_KEY \
    --enable-vmss
```

Once AKS cluster is provisioned, run the following command to configure kubectl to connect to your Kubernetes cluster:
```
az aks get-credentials -g $RESOURCE_GROUP -n $CLUSTER_NAME
```

Check if you can connect to the cluster by running the following command:

```sh
kubectl get nodes

NAME                                STATUS   ROLES   AGE   VERSION
aks-nodepool1-18558189-vmss000000   Ready    agent   11d   v1.12.6
aks-nodepool1-18558189-vmss000001   Ready    agent   12m   v1.12.6
aks-nodepool1-18558189-vmss000002   Ready    agent   12m   v1.12.6
```

## Deploy sample app to AKS Cluster

You deploy the same vote app that you've deployed in [AKS103](aks-103-deploy-app.md) module.

```sh
kubectl apply -f kubernetes-manifests/vote/all-in-one.yaml
```

Once you've deployed the app, check if it's accessible. Please follow the procedure - [Access service in the cluster by port-forward](aks-103-deploy-app.md#access-service-in-the-cluster-by-port-forward)


## Setup Application Gateway Ingress Controller 

Prerequistes for installing Application Gateway Ingress Controller:
- `Azure Application Gateway v2` with manual scaling configured (not set to AutoScale).
- AKS cluster with `Advanced Networking (CNI plugin)` enabled.
- `aad-pod-identity service` is installed on the AKS cluster.

### Install Azure Application Gateway v2 

Create and configure `Azure Application Gateway v2` by following this:
 - [Quickstart: Direct web traffic with Azure Application Gateway - Azure CLI](https://docs.microsoft.com/en-us/azure/application-gateway/quick-create-cli)


### Deploy aad-pod-identity service on AKS cluster

Deploy [aad-pod-identity](https://github.com/Azure/aad-pod-identity) service on AKS cluster with `deploy-aad-pod-identity.sh` script. Add your values to parameter sections and run the script 

> scripts/deploy-aad-pod-identity.sh
```sh
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
```

### Install Application Gateway Kubernetes Ingress

Add the `application-gateway-kubernetes-ingress` helm repo and perform a helm update
```
helm repo add application-gateway-kubernetes-ingress https://azure.github.io/application-gateway-kubernetes-ingress/helm/
helm repo update
```
Download `helm-config.yaml`
```sh
curl https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/example/helm-config.yaml -o helm-config.yaml 
```

Run `az indentity show` command and find the principal, resource and client ID for the AAD POD identity
```
az identity show -g $RESOURCE_GROUP_AKS_NODE -n $IDENTITY_NAME

{
  "clientId": "5c6f42ca-bfdf-4d00-bcae-c1eae537cc86",
  "clientSecretUrl": "https://control-japaneast.identity.azure.net/subscriptions/88c7c7f9-0c9f-47d1-a856-1305a0cbfd7a/resourcegroups/MC_rg_aztest_akscluster_japaneast/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aadpodid_akscluster/credentials?tid=72f988bf-86f1-41af-91ab-2d7cd011db47&oid=c04e9ff6-ebb3-4714-afc6-ebfcddbd5c43&aid=5c6f42ca-bfdf-4d00-bcae-c1eae537cc86",
  "id": "/subscriptions/88c7c7f9-0c9f-47d1-a856-1305a0cbfd7a/resourcegroups/MC_rg_aztest_akscluster_japaneast/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aadpodid_akscluster",
  "location": "japaneast",
  "name": "aadpodid_akscluster",
  "principalId": "c04e9ff6-ebb3-4714-afc6-ebfcddbd5c43",
  "resourceGroup": "MC_rg_aztest_akscluster_japaneast",
  "tags": {},
  "tenantId": "72f988bf-86f1-41af-91ab-2d7cd011db47",
  "type": "Microsoft.ManagedIdentity/userAssignedIdentities"
}
```

Run `kubectl config view` and find Kubernetes api server address:
```
kubectl config view
```
```YAML
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://aztest-rgaztest-87c7c7-97ac1e80.hcp.japaneast.azmk8s.io:443
  name: aztest
contexts:
- context:
    cluster: aztest
    user: clusterUser_RG_aztest_aztest
  name: aztest
current-context: aztest
kind: Config
preferences: {}
users:
- name: clusterUser_RG_aztest_aztest
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
    token: 62c6371d1d388d964282af2c6addaa0b
```

Edit `helm-config.yaml` and fill in the values for `appgw` and `armAuth`
```YAML
# This file contains the essential configs for the ingress controller helm chart

################################################################################
# Specify which application gateway the ingress controller will manage
#
appgw:
    subscriptionId: <subscriptionId>
    resourceGroup: <resourceGroupName>
    name: <applicationGatewayName>

################################################################################
# Specify which kubernetes namespace the ingress controller will watch
# Default value is "default"
#
# kubernetes:
#   watchNamespace: <namespace>

################################################################################
# Specify the authentication with Azure Resource Manager
#
# Two authentication methods are available:
# - Option 1: AAD-Pod-Identity (https://github.com/Azure/aad-pod-identity)
# - Option 2: ServicePrincipal as a kubernetes secret
# armAuth:
#   type: servicePrincipal
#   secretName: networking-appgw-k8s-azure-service-principal
#   secretKey: ServicePrincipal.json
armAuth:
    type: aadPodIdentity
    identityResourceID: <identityResourceId>
    identityClientID:  <identityClientId>

rbac:
    enabled: false

aksClusterConfiguration:
    apiServerAddress: <aks-api-server-address>
```
> [NOTE] Get <identity-resource-id> and <identity-client-id> from the output of `az identity show` command that you run in previous section.


Finally, install the helm chart application-gateway-kubernetes-ingress with the `helm-config.yaml`
```
helm install -f helm-config.yaml application-gateway-kubernetes-ingress/ingress-azure
```


## Cleanup Resources

```sh
az group delete --name $RESOURCE_GROUP
```