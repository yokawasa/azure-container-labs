# AKS206: Virtual Node

<!-- TOC -->
- [AKS206: Virtual Node](#aks206-virtual-node)
  - [Install aks-preview CLI extension](#Install-aks-preview-cli-extension)
  - [Provision AKS and enable Virtual Node](#provision-aks-and-enable-virtual-node)
  - [Deploy sample app to Virtual Node](#deploy-sample-app-to-virtual-node)
  - [Manually scale out the app (Massive scale)](#manually-scale-out-the-app-massive-scale)
  - [Cleanup Resources](#cleanup-resources)



## Install aks-preview CLI extension

AKS cluster autoscaler only supported in `virtual machine scale set (VMSS)` with Kubernetes version `1.12.4`. As of June 2019, this is still in preview stage and you need to opt-in to preview features to try this. For this you need to add the aks-preview feature to CLI
```sh
az extension add --name aks-preview
```

## Provision AKS and enable Virtual Node
First of all, create AKS cluster ( +Advanced Network plugin enabled ) in Custom VNET with `create-aks-cluster-custom-vnet.sh` script. Before you run the script, add your values to parameter sections:

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

Once AKS cluster is provisioned, run the following command to create a subnet for Virtual Node and grant the correct access for the AKS cluster to use the virtual network.
Before you run the script, add your values to parameter sections:

> scripts/create-subnet-virtual-node.sh
```sh
################################################################
# Parameters
################################################################
RESOURCE_GROUP="<Reousrce Group Name>"
CLUSTER_NAME="<AKS Cluster Name>"
# Service Principal
SP_CLIENT_ID="<Service Principal Client ID>"
# VNET Info
VNET_NAME="<Virtual Network Name>"
SUBNET_VIRTUAL_NODE="<Subnet name for AKS>"

################################################################
# Start Script
################################################################
echo "Create Subnet for Virtual Nodes"
az network vnet subnet create \
    --resource-group $RESOURCE_GROUP \
    --vnet-name $VNET_NAME \
    --name $SUBNET_VIRTUAL_NODE \
    --address-prefix 10.241.0.0/16

echo "Get the virtual network resource ID"
VNET_ID=$(az network vnet show --resource-group $RESOURCE_GROUP --name $VNET_NAME --query id -o tsv)

echo "To grant the correct access for the AKS cluster to use the virtual network"
az role assignment create --assignee $SP_CLINET_ID --scope $VNET_ID --role Contributor
```

Then, update the AKS cluster to enable `Virtual Node`.
Before you run the script, add your values to parameter sections:

> scripts/enable-addons-virtual-node.sh
```sh
################################################################
# Parameters
################################################################
RESOURCE_GROUP="<Reousrce Group Name>"
CLUSTER_NAME="<AKS Cluster Name>"
# VNET Info
VNET_NAME="<Virtual Network Name>"
SUBNET_VIRTUAL_NODE="<Subname name for AKS>"

################################################################
# Start Script
################################################################
echo "Use the az aks enable-addons command to enable virtual nodes"
az aks enable-addons \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --addons virtual-node \
    --subnet-name $SUBNET_VIRTUAL_NODE
```

Finally, run the following command to configure kubectl to connect to your Kubernetes cluster:

```
az aks get-credentials -g $RESOURCE_GROUP -n $CLUSTER_NAME
```

Check if you can connect to the cluster by running the following command:

```sh
kubectl get nodes

NAME                                STATUS   ROLES   AGE     VERSION
aks-nodepool1-33040345-vmss000000   Ready    agent   4h15m   v1.12.7
virtual-node-aci-linux              Ready    agent   176m    v1.13.1-vk-v0.7.4-44-g4f3bd20e-dev
```

## Deploy sample app to Virtual Node

Create a YAML file named `party-clippy-vn.yaml` for a party-clippy app deployment on the virtual node. 

```sh
cat << EOD | tee party-clippy-vn.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aci-party-clippy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: aci-party-clippy
  template:
    metadata:
      labels:
        app: aci-party-clippy
    spec:
      containers:
      - name: aci-party-clippy
        image: r.j3ss.co/party-clippy
        tty: true
        command: ["party-clippy"]
        ports:
        - containerPort: 8080
      nodeSelector:
        kubernetes.io/role: agent
        beta.kubernetes.io/os: linux
        type: virtual-kubelet
      tolerations:
      - key: virtual-kubelet.io/provider
        operator: Exists
      - key: azure.com/aci
        effect: NoSchedule
EOD
```
> [NOTE] A [nodeSelector](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) and [toleration](https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/) are being used to schedule the container on the node.

Run the application with the kubectl create command.
```sh
kubectl create -f  party-clippy-vn.yaml 
```

Check the party-clippy Pod is running on the node, and get IP address that is assigned to the pod.
```sh
kubectl get po -o wide

NAME                                READY   STATUS    RESTARTS   AGE   IP           NODE                     NOMINATED NODE
aci-party-clippy-6949f66686-24d85   1/1     Running   0          8h    10.241.0.4   virtual-node-aci-linux   <none>
```

Create a pod in the cluster to access the party-clippy app from the pod like this:

```sh
kubectl run -it --rm runtest --image=debian --generator=run-pod/v1
pod#  apt-get update && apt-get install curl -y
pod#  curl -s 10.241.0.4:8080

 _________________________________
/ It looks like you're building a \
\ microservice.                   /
 ---------------------------------
 \
  \
     __
    /  \
    |  |
    @  @
    |  |
    || | /
    || ||
    |\_/|
    \___/
```

## Manually scale out the app (Massive scale)

Get the name of deployment for the party-clippy app

```sh
kubectl get deploy

NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
aci-party-clippy   1         1         1            1           8h
```

Manually scale the app up to 50 with `kubectl scale` command:

```sh
kubectl scale deploy aci-party-clippy --replicas=50
```

Finally, check pods' status with `kubectl get pod` and `kubectl get deploy` command. You'll see 50 pods running on the node

```
kubectl get pod

aci-party-clippy-6949f66686-qvct9   0/1     Pending   0          <invalid>
aci-party-clippy-6949f66686-qx8p2   0/1     Pending   0          <invalid>
aci-party-clippy-6949f66686-rtn7h   0/1     Pending   0          <invalid>
aci-party-clippy-6949f66686-sxz6x   0/1     Pending   0          <invalid>
aci-party-clippy-6949f66686-tk2pj   0/1     Pending   0          <invalid>
aci-party-clippy-6949f66686-tlnkf   0/1     Pending   0          <invalid>
aci-party-clippy-6949f66686-tm2sp   0/1     Pending   0          <invalid>
aci-party-clippy-6949f66686-tqstm   0/1     Pending   0          <invalid>
aci-party-clippy-6949f66686-wcxx5   0/1     Pending   0          <invalid>
aci-party-clippy-6949f66686-x7f9f   0/1     Pending   0          <invalid>
aci-party-clippy-6949f66686-xjkxg   0/1     Pending   0          <invalid>
aci-party-clippy-6949f66686-z9bb5   0/1     Pending   0          <invalid>
aci-party-clippy-6949f66686-znp8s   0/1     Pending   0          <invalid>
aci-party-clippy-6949f66686-ft8nh   0/1     Creating   0          <invalid>
aci-party-clippy-6949f66686-48kzr   0/1     Creating   0          <invalid>
aci-party-clippy-6949f66686-9wxdw   0/1     Creating   0          <invalid>
aci-party-clippy-6949f66686-6t4f7   0/1     Creating   0          <invalid>
aci-party-clippy-6949f66686-j22ht   0/1     Creating   0          <invalid>
...

kubectl get deploy

NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
aci-party-clippy   50        50        50           5           10h
```
## Cleanup Resources

```sh
az group delete --name $RESOURCE_GROUP
```