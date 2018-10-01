# Helper: Helm CLI Commands

## Delete package (Optional)

```sh
# helm del <chartname>
$ helm del vote

release "vote" deleted
```

## Install remote charts

```sh
$ helm install https://myhelmrepo001.blob.core.windows.net/helmrepo/azure-voting-app-0.1.0.tgz -n vote-dev

$ helm install https://myhelmrepo001.blob.core.windows.net/helmrepo/azure-voting-app-0.1.0.tgz -n vote-dev \
    --set azureVoteFront.service.type=ClusterIP,ingress.enabled=true,ingress.host=vote.486f848139314d26aeef.japaneast.aksapp.io,azureVoteFront.deployment.image=yoichika.azurecr.io/azure-voting-app-front,azureVoteFront.deployment.imageTag=latest
```
