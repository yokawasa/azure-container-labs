# AKS Cheat Sheet

> Unofficial AKS Cheat Sheet

Official AKS FAQ is [here](https://docs.microsoft.com/bs-cyrl-ba/azure/aks/faq)

<!-- TOC -->
- [AKS Cheat Sheet](#aks-cheat-sheet)
  - [Azure CLI Commands](#azure-cli-commands)
    - [AKS](#aks)
    - [ACR](#acr)
  - [Reference Architecture](#reference-architecture)
  - [AKS Features](#aks-features)
    - [Service Principal](#service-principal)
    - [Authn and Authz](#authn-and-authz)
    - [Cluster Security](#cluster-security)
    - [Data Volume](#data-volume)
    - [Network Plugin](#network-plugin)
    - [Network Policiy](#network-policiy)
    - [Load Balancer](#load-balancer)
    - [Ingress](#ingress)
    - [Egress](#egress)
    - [DNS](#dns)
    - [Autoscale](#autoscale)
    - [GPU nodes](#gpu-nodes)
    - [Quota and Limits for AKS](#quota-and-limits-for-aks)
    - [Troubleshooting](#troubleshooting)
  - [Azure Container Registory (ACR)](#azure-container-registory-acr)
  - [Useful Links](#useful-links)

## Azure CLI Commands
### AKS
Reference: [az aks](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest)

- Get k8s available versions
    ```sh
    az aks get-versions --location $REGION -o table

    KubernetesVersion    Upgrades
    -------------------  ------------------------
    1.12.7               None available
    1.12.6               1.12.7
    1.11.9               1.12.6, 1.12.7
    1.11.8               1.11.9, 1.12.6, 1.12.7
    1.10.13              1.11.8, 1.11.9
    1.10.12              1.10.13, 1.11.8, 1.11.9
    1.9.11               1.10.12, 1.10.13
    1.9.10               1.9.11, 1.10.12, 1.10.13
    ```

- To configure kubectl to connect to your Kubernetes cluster
    ```sh
    az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```

- Open k8s Dashboard
    ```sh
    az aks browse --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
    ```
    ![](../assets/k8s-dashboard.png)

    If you're using RBAC enabled kubernetes cluster, you need to configure Service Account and RoleBinding in order to make Dashbaord work.
    ```sh
    # Here is a way to give full privilege (role: cluster-admin) to the Dashboard’s Service Account kubernetes-dashboard
    $ cat <<EOF | kubectl apply -f -
    apiVersion: rbac.authorization.k8s.io/v1beta1
    kind: ClusterRoleBinding
    metadata:
    name: kubernetes-dashboard
    labels:
        k8s-app: kubernetes-dashboard
    roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: cluster-admin
    subjects:
    - kind: ServiceAccount
    name: kubernetes-dashboard
    namespace: kube-system
    EOF
    ```
    If you want to configure more granular privilege to the Dashboard's service account instead of giving full privilege(role: cluster-admin), please follow "Option 1: Access to Dashboard with your Service Account" in [this article](https://unofficialism.info/posts/accessing-rbac-enabled-kubernetes-dashboard/). 

    In addition, please see [Kubernetes dashboard with Azure Container Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/kubernetes-dashboard) to know about basic dashboard operations.

- Get AKS Cluster info
    ```sh
    az aks show  --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME -o table

    Name      Location    ResourceGroup    KubernetesVersion    ProvisioningState    Fqdn
    --------  ----------  ---------------  -------------------  -------------------  -----------------------------------------------------------
    azconlab  japaneast   RG_azconlab      1.12.6               Succeeded            azconlab-rgazconlab-87c7c7-97ac1e80.hcp.japaneast.azmk8s.io
    ```

- Get Node Resource Group
    ```sh
    az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query nodeResourceGroup -o tsv
    ```

- Scale AKS Cluster nodes
    ```sh
    az aks scale --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP \
        --node-count $NODE_COUNT
    ```

- Upgrade AKS Cluster version
    ```sh
    az aks upgrade --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP \
        --kubernetes-version $KUBERNETS_VERSION

    # Check which Kubernetes releases are available for upgrade for your AKS cluster
    az aks get-upgrades --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP -o table
    ```

- Enable Add-on
  - Enable Azure Monitor for Containers
    ```sh
    OMS_WORKSPACE_RESOURCE_ID="/subscriptions/87c7c7f9-0c9f-47d1-a856-1305a0cbfd7a/resourceGroups/DefaultResourceGroup-EJP/providers/Microsoft.OperationalInsights/workspaces/DefaultWorkspace-77c7c7f9-0c9f-47d1-a856-1305a0cbfd7a-EJP"

    az aks enable-addons -a monitoring \
      --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP \
      --workspace-resource-id $OMS_WORKSPACE_RESOURCE_ID
    ```
  - Enable HTTP Application Routing
    ```sh
    az aks enable-addons --addons http_application_routing \
      --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP
    ```

- Check egress IP
    ```sh
    kubectl run -it --rm runtest --image=debian --generator=run-pod/v1
    pod>  apt-get update && apt-get install curl -y
    pod>  curl -s checkip.dyndns.org
    ```

### ACR
Reference: [az acr](https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest)

- Create an Azure Container Registry
    ```sh
    az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic
    ```
    > SKU: `Basic`, `Standard`, `Premium`, `Classic`

- Get ACR list
    ```sh
    az acr list -o table
    ```
- Get ACR Detail 
    ```sh
    az acr show -n $ACR_NAME -g $RESOURCE_GROUP
    # Get only ACR ID
    az acr show -n $ACR_NAME -g $RESOURCE_GROUP --query "id" -o tsv
    ```
- Login to ACR 
    ```sh
    az acr login --name $ACR_NAME

    # Alternatively login with docker command
    ACR_LOGIN_SERVER=$ACR_NAME.azurecr.io
    docker login $ACR_LKOGIN_SERVER -u $ACR_USER -p $ACR_PASSWORD
    ```
- ACR Task - Build
    >  You can queues a quick build, providing streamed logs for an Azure Container Registry by using [az acr build](https://docs.microsoft.com/en-us/cli/azure/acr?view=azure-cli-latest#az-acr-build)

    ```sh
    az acr build --registry $ACR_NAME --image [CONTAINER_NAME:TAG] [SOURCE_LOCATION]

    ## More usages are:
    #Queue a local context (folder), pushed to ACR when complete, with streaming logs.
    az acr build -t sample/hello-world:{{.Run.ID}} -r MyRegistry .

    # Queue a local context, pushed to ACR without streaming logs.
    az acr build -t sample/hello-world:{{.Run.ID}} -r MyRegistry --no-logs .

    # Queue a local context to validate a build is successful, without pushing to the registry using the --no-push parameter.
    az acr build -t sample/hello-world:{{.Run.ID}} -r MyRegistry --no-push .

    # Queue a local context to validate a build is successful, without pushing to the registry. Removing the -t parameter defaults to --no-push
    az acr build -r MyRegistry .
    ```

## Reference Architecture
![](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/microservices/_images/aks.png)
- [Microservices architecture on Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/microservices/aks)
- https://github.com/mspnp/microservices-reference-implementation
- [Building microservices on Azure](https://docs.microsoft.com/en-us/azure/architecture/microservices/index)

## AKS Features
### Service Principal
- About Service Principal
  - https://docs.microsoft.com/en-us/azure/aks/kubernetes-service-principal
- Update Service Principal in AKS cluster
  - https://docs.microsoft.com/en-us/azure/aks/update-credentials

### Authn and Authz
- 3 options to manage access and identity for AKS clusters
  - [Azure RBAC (integration with Azure AD) to control the access to AKS](https://docs.microsoft.com/en-us/azure/aks/aad-integration)
    ```
    1. Developer authenticates with Azure AD(AAD).
    2. AAD token issuance endpoint issues the access token.
    3. The developer performs an action using the AAD token, such as kubectl create pod
    4. k8s validates the token with AAD and fetches the developer's group memberships.
    5. k8s RBAC and cluster policies are applied.
    6. Developer's request is successful or not based on previous validation of AAD group membership and k8s RBAC and policies.
    ```
    from [Bast pracitses for authn & authz in AKS](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-identity)
  - Kubernetes RBAC
    - [Using RBAC Authorization@k8s.io](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
    - Roles, ClusterRoles, RoleBindings, ClusterRoleBindings
  - Pod Identities
    - Use managed identities for Pods in AKS to access to Azure resources
      -  Managed Identities let you automatically request access to services through Azure AD. You don't manually define credentials for pods, instead they request an access token in real time (See [azure doc](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-identity#use-pod-identities))
    - [Use Pod Identities(Managed Identity)](https://github.com/Azure/aad-pod-identity)

### Cluster Security
- [cluster security and upgrades](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-cluster-security)
  - Securing access to the API server, limiting container access, and managing upgrades and node reboots.
- [Container image management and security](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-container-image-management)
  - Securing the image and runtimes, using trusted registries, and automated builds on base image updates..
- [Pod security](https://docs.microsoft.com/en-us/azure/aks/developer-best-practices-pod-security)
  - Securing access to resources, limiting credential exposure, and using [pod identities](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-identity#use-pod-identities) and [Azure Key Vault](https://docs.microsoft.com/en-us/azure/aks/developer-best-practices-pod-security#use-azure-key-vault-with-flexvol) 
  - [KeyVault with FlexVol@Github page](https://github.com/Azure/kubernetes-keyvault-flexvol)

### Data Volume
- Data Volume Options
  - Azure Disk ([Dynamic](https://docs.microsoft.com/en-us/azure/aks/azure-disks-dynamic-pv) / [Static](https://docs.microsoft.com/en-us/azure/aks/azure-disk-volume))
  - Azure Files ([Dynamic](https://docs.microsoft.com/en-us/azure/aks/azure-files-dynamic-pv) / [Static](https://docs.microsoft.com/en-us/azure/aks/azure-files-volume))

### Network Plugin 
- [kubenet](https://docs.microsoft.com/en-us/azure/aks/configure-kubenet) (default policy)
  - az aks create --network-plugin option: `kubenet`
  - see also [@k8s.io]((https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#kubenet))
- [Azure CNI](https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni)
  - az aks create --network-plugin option: `azure`

### Network Policiy
- Kubernetes version: `1.12+`
- [Network Policy Recipes](https://github.com/ahmetb/kubernetes-network-policy-recipes)
- [Network policy Options in AKS](https://docs.microsoft.com/en-us/azure/aks/use-network-policies)
  - 1. `Azure Network Policies` - the Azure CNI sets up a bridge in the VM host for intra-node networking. The filtering rules are applied when the packets pass through the bridge
    - az aks create --network-plugin `azure`
  - 2. `Calico Network Policies` - the Azure CNI sets up local kernel routes for the intra-node traffic. The policies are applied on the pod’s network interface.
    - see [the difference between the two](the Azure CNI sets up local kernel routes for the intra-node traffic. The policies are applied on the pod’s network interface.)
    - az aks create --network-plugin `azure` && --network-policy `calico`

### Load Balancer
- Service: type=`LoadBalancer` (NOT `ClusterIP` nor `NodePort`)
- Default: External Load balancer
- Static IP to LB (see [azure doc](https://docs.microsoft.com/en-us/azure/aks/static-ip))
    ```YAML
    apiVersion: v1
    kind: Service
    metadata:
        name: servicename
    spec:
        loadBalancerIP: 41.222.222.66
        type: LoadBalancer
    ```
- [Internal Load balancer](https://docs.microsoft.com/en-us/azure/aks/internal-lb) - Only accessible from the same VNET
  - Annotation for Internal LB
    ```YAML
    apiVersion: v1
    kind: Service
    metadata:
        name: servicename
        annotations:
            service.beta.kubernetes.io/azure-load-balancer-internal: "true"
    spec:
        type: LoadBalancer
        ...
    ```
  - You can specify IP address for LB: `loadBalancerIP:XX.XX.XX.XX` 
  - You can specify a subnet for LB with special annotation
    ```YAML
    annotations:
        service.beta.kubernetes.io/azure-load-balancer-internal: "true"
        service.beta.kubernetes.io/azure-load-balancer-internal-subnet: "apps-subnet"
    ```

### Ingress
- Ingress Controllers provided by Azure (Not [nginx ingress](https://github.com/kubernetes/ingress-nginx) or others)
  - [HTTP application routing add-on](https://docs.microsoft.com/en-us/azure/aks/http-application-routing)
  - [Application Gateway Kubernetes Ingress](https://github.com/Azure/application-gateway-kubernetes-ingress)
- TLS Termination Configfuration
  - [Your Certificates](https://docs.microsoft.com/en-us/azure/aks/ingress-own-tls)
  - [Let's Encrypt](https://docs.microsoft.com/en-us/azure/aks/ingress-tls)
- Ingress for Internal VNET by using a service with [Internal LB](https://docs.microsoft.com/en-us/azure/aks/internal-lb)

### Egress
- Static IP for egress traffic 
  - See [azure doc](https://docs.microsoft.com/en-us/azure/aks/egress)
  - Default: egress IP from AKS is randomly assigned
     > Once a Kubernetes service of type LoadBalancer is created, agent nodes are added to an Azure Load Balancer pool. For outbound flow, Azure translates it to the first public IP address configured on the load balancer. This public IP address is only valid for the lifespan of that resource. If you delete the Kubernetes LoadBalancer service, the associated load balancer and IP address are also deleted. 
  - Procedures
    - 1. Create static IP in AKS node resource Group
    - 2. Create a service with the static IP ( put the static IP to the `loadBalancerIP` property)

### DNS
- Kubernetes +1.12.x: `CoreDNS` 
  - [Customize CoreDNS](https://docs.microsoft.com/en-us/azure/aks/coredns-custom)
- Kubernetes < 1.12.x: `kube-dns` 
  - [Customize kube-dns](https://www.danielstechblog.io/using-custom-dns-server-for-domain-specific-name-resolution-with-azure-kubernetes-service/)

### Autoscale





### GPU nodes
- https://docs.microsoft.com/en-us/azure/aks/gpu-cluster

### Quota and Limits for AKS
- https://docs.microsoft.com/en-us/azure/aks/container-service-quotas
- Default limit
  - max clusters per subscription: `100`
  - max nodes per cluster: `100`
  - max pods per node setting for AKS
    - Basic networking with Kubenet: `110`
    - Advanced networking with Azure CNI: `30` ( NOTE: you can change the limit for Azure CLI or Resource Manager template deployments up to `110` )
- [Region availability](https://docs.microsoft.com/en-us/azure/aks/container-service-quotas#region-availability)
- [Provisioned Infrastructure](https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits)
- [Supported k8s versions](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions)
  ```
  az aks get-versions --location $REGION -o table
  ```

### Troubleshooting
- [Official troubleshooting Guide @k8s.io](https://kubernetes.io/docs/tasks/debug-application-cluster/troubleshooting/)
- https://docs.microsoft.com/en-us/azure/aks/troubleshooting
- [Kubernetes Troubleshooting @Github](https://github.com/feiskyer/kubernetes-handbook/blob/master/en/troubleshooting/index.md)
- https://docs.microsoft.com/en-us/azure/aks/kube-advisor-tool
- [SSH login to k8s nodes](https://github.com/yokawasa/kubectl-plugin-ssh-jump)


## Azure Container Registory (ACR)
- VNET & Firewall Rule
  - https://docs.microsoft.com/en-us/azure/container-registry/container-registry-vnet
- ACR Task - Automate OS and framework patching 
  - http://aka.ms/acr/tasks
  - https://docs.microsoft.com/en-us/azure/container-registry/container-registry-tasks-multi-step
- Repo & Tag Locking
  - http://aka.ms/acr/tag-locking
-  Helm Chart Repositories
   -  https://docs.microsoft.com/en-us/azure/container-registry/container-registry-helm-repos

## Useful Links
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Helm Cheat Sheet](https://gist.github.com/tuannvm/4e1bcc993f683ee275ed36e67c30ac49)