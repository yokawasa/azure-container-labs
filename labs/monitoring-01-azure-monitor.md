# Monitoring01: Azure Monitor for Container

## Enable monitoring using Azure CLI

```sh
CLUSTER_NAME="myazconlabs"
RESOURCE_GROUP="rg_azconlab"
az aks enable-addons -a monitoring -n $CLUSTER_NAME -g $RESOURCE_GROUP

(output)
provisioningState       : Succeeded
```

You can also enable the monitoring using [Azure Portal](https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-insights-onboard#enable-monitoring-from-aks-cluster-in-the-portal) or [Azure Resource Manager Template](https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-insights-onboard#enable-monitoring-by-using-an-azure-resource-manager-template), or you can enable it from [Azure Monitor dashboard](https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-insights-onboard#enable-monitoring-from-azure-monitor).

## Observe and Analye the AKS cluster with Azure Monitor for Container

https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-insights-analyze

# LINKS
- [How to onboard Azure Monitor for containers](https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-insights-onboard)
---
[Monitoring Top](aks-107-monitoring-top.md)
