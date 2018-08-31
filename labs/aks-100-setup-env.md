# Module00: Setup Lab environment

## Open Azure Cloud Shell

In this hands-on labs, you're running this workthrough on [Azure Cloud Shell Bash](https://docs.microsoft.com/en-us/azure/cloud-shell/overview).

So open Azure Cloud Shell with `Base Mode`, first of all.

![](../img/cloud-shell-open-bash.png)
> Note: Another option is to use the full screen Azure Cloud Shell at https://shell.azure.com/.

The first time you connect to the Azure Cloud Shell you will be prompted to setup an Azure File Share that you will persist the environment.
![](../img/cloud-shell-welcome.png)

Click the "Bash (Linux)" option, and select the Azure Subscription and click "Create storage":
![](../img/cloud-shell-no-storage-mounted.png)

After a few seconds, your storage account will be created. Azure Cloud Shell is ready to use


## Verify Subscription

Run the command az account list -o table
```
$ az account list -o table

Name                             CloudName    SubscriptionId                        State    IsDefault
-------------------------------  -----------  ------------------------------------  -------  -----------
Visual Studio Premium with MSDN  AzureCloud   xxxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx  Enabled  True
Another sub1                     AzureCloud   xxxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx  Enabled  False
Another sub2                     AzureCloud   xxxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx  Enabled  False
Another sub3                     AzureCloud   xxxxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx  Enabled  False
```

If you have more than subscription, make sure that subscription is set as default using the subscription name:

```
$ az account set -s 'Visual Studio Premium with MSDN'
```

## Register Azure Resource Providers

Execute the following commands which are needed in case that it's the first time to manage Azrue resources such as Network, Storage, Compute and ContainerSerivces with your subscription:

```sh
$ az provider register -n Microsoft.Network
$ az provider register -n Microsoft.Storage
$ az provider register -n Microsoft.Compute
$ az provider register -n Microsoft.ContainerService
```

---
[Top](toc.md) | [Next](module01.md)