# AKS107: Azure Monitor for Containers

## Enable monitoring using Azure CLI

```sh
CLUSTER_NAME="myazconlabs"
RESOURCE_GROUP="rg_azconlab"
az aks enable-addons -a monitoring -n $CLUSTER_NAME -g $RESOURCE_GROUP

(output)
provisioningState       : Succeeded
```

You can also enable the monitoring from either `Azure Portal`, `Azure Resource Manager Template`, or `Azure Monitor dashboard`.  

For more detail, please see the following page:
- [How to onboard Azure Monitor for containers](https://docs.microsoft.com/en-us/azure/monitoring/monitoring-container-insights-onboard)

## Monitor AKS with Azure Monitor for Container

- [Analyze AKS cluster performance with Azure Monitor for containers](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-analyze)
- [View container logs real time with Azure Monitor for containers](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-live-logs) 
- [Setup Alert for performance problems](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-alerts)


---
[Top](../README.md) | [Back](aks-106-statefulsets.md) | [Next](aks-108-helm.md)
