# AKS Cheat Sheet

> Unofficial AKS Cheat Sheet

Official AKS FAQ is [here](https://docs.microsoft.com/bs-cyrl-ba/azure/aks/faq)

<!-- TOC -->
- [AKS Cheat Sheet](#aks-cheat-sheet)
  - [Azure CLI Commands](#azure-cli-commands)
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
    - [GPU nodes](#gpu-nodes)
    - [Quota and Limits for AKS](#quota-and-limits-for-aks)
    - [Troubleshooting](#troubleshooting)
  - [Azure Container Registory (ACR)](#azure-container-registory-acr)

## Azure CLI Commands
- Get Node Resource Group
    ```
    az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query nodeResourceGroup -o tsv
    ```
- Check egress IP
    ```
    kubectl run -it --rm runtest --image=debian --generator=run-pod/v1
    pod#  apt-get update && apt-get install curl -y
    pod#  curl -s checkip.dyndns.org
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
- Update Service Principal
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

### GPU nodes
- https://docs.microsoft.com/en-us/azure/aks/gpu-cluster

### Quota and Limits for AKS
- https://docs.microsoft.com/en-us/azure/aks/container-service-quotas
- Default limit
  - max clusters per subscription: `100`
  - max nodes per cluster: `100`
  - max pods per node setting for AKS
    - Basic networking with Kubenet: `110`
    - Advanced networking with Azure CNI: `30` - Portal Deploy, `110` - ARM template / Azure CLI deploy
- [Region availability](https://docs.microsoft.com/en-us/azure/aks/container-service-quotas#region-availability)
- [Provisioned Infrastructure](https://docs.microsoft.com/en-us/azure/azure-subscription-service-limits)
- [Supported k8s versions](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions)
  ```
  az aks get-versions --location $REGION --output table
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