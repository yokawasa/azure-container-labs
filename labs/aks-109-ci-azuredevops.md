# AKS109: CI with Azure DevOps

Soming soon

```
 helm upgrade azure-voting-app-dev https://myhelmrepo001.blob.core.windows.net/helmrepo/azure-voting-app-0.1.0.tgz --set azureVoteFront.service.type=ClusterIP,ingress.enabled=true,ingress.host=vote.486f848139314d26aeef.japaneast.aksapp.io,azureVoteFront.deployment.image=yoichika.azurecr.io/azure-voting-app-front,azureVoteFront.deployment.imageTag=latest
```
