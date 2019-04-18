# Istio01: Setup Istio

<!-- TOC -->
- [Istio01: Setup Istio](#istio01-setup-istio)
  - [Download Istio release package](#download-istio-release-package)
  - [Install Istio Core Components](#install-istio-core-components)
    - [(a) Install Istio with Helm](#a-install-istio-with-helm)
    - [(b) Install Istio without Helm (by applying YAMLs)](#b-install-istio-without-helm-by-applying-yamls)
    - [[Supplements] CRDs for Istio](#supplements-crds-for-istio)
  - [Check Pods & Services of Istio](#check-pods--services-of-istio)
  - [Access Istio endpoints (Forwarding local ports to a Pod.)](#access-istio-endpoints-forwarding-local-ports-to-a-pod)
  - [Expose and access Istio endpoints (if you can't access the Istio endpoint by forwarding local ports to a Pod)](#expose-and-access-istio-endpoints-if-you-cant-access-the-istio-endpoint-by-forwarding-local-ports-to-a-pod)


## Download Istio release package

In this workshop, we use `istio-1.0.4`. Run the following command to download `istio-1.0.4` package

```sh
$ curl -L https://raw.githubusercontent.com/yokawasa/azure-container-labs/master/scripts/istio-helpers/get-istio-1.0.4 | sh -
```
> [NOTE] If you want to download the latest Istio, run the following:
> ```sh
> curl -L https://git.io/getLatestIstio | sh -
> ```

Once you download the package, change directory to istio-1.X.X
```sh
cd istio-1.X.X
```
## Install Istio Core Components

To install Istio’s core components, you have options:
- (a) Install Istio with Helm
- (b) Install Istio without Helm (by applying YAMLs)

Please see [Istio - Installation Options](https://istio.io/docs/reference/config/installation-options/) for more details on what options can be added. 

### (a) Install Istio with Helm

For a production setup of Istio, it's recommended to install with the Helm Chart, to use all the configuration options.

First of all, check Helm version that you're using, and if you're using a Helm version prior to 2.10.0, install Istio’s Custom Resource Definitions (CRD) via kubectl apply, and wait a few seconds for the CRDs to be committed in the kube-apiserver:

```sh
# Check Helm version
$ helm version

Client: &version.Version{SemVer:"v2.8.2", GitCommit:"a80231648a1473929271764b920a8e346f6de844", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.8.2", GitCommit:"a80231648a1473929271764b920a8e346f6de844", GitTreeState:"clean"}

# Install (if you're using < 2.10.0)
$ kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml

# If you are enabling certmanager, you also need to install its CRDs as well and wait a few seconds for the CRDs to be committed in the kube-apiserver:
$ kubectl apply -f install/kubernetes/helm/istio/charts/certmanager/templates/crds.yaml
```

Then, if a service account has not already been installed for `Tiller`, install one by running the follwoing command:
```sh
$ cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
EOF
```

Then, install `Tiller` on your cluster with the service account:
```sh
$ helm init --service-account tiller --upgrade
```

Install Istio with addons using Helm:
```sh
$ helm install install/kubernetes/helm/istio --name istio --namespace istio-system \
  --set prometheus.enabled=true \
  --set tracing.enabled=true \
  --set grafana.enabled=true \
  --set kiali.enabled=true
```

In this workshop, we use `prometheus` and `grafana` for viewing the metrics from Istio, and `Jaeger` for tracing, and `Kiali` for visualization.
By default, Istio is installed with parameters like `Prometheus:enabled`, `grafana:disabled`, `Jaeger:disabled`, `Kiali:diabled`, therefore, these parameters need to be enabled like above. 

For more detail, see [Install with Helm and Tiller via helm install](https://istio.io/docs/setup/kubernetes/helm-install/#option-2-install-with-helm-and-tiller-via-helm-install).


### (b) Install Istio without Helm (by applying YAMLs)
```sh
$ kubectl apply -f install/kubernetes/helm/istio/templates/crds.yaml
$ kubectl apply -f install/kubernetes/istio-demo.yaml
```
### [Supplements] CRDs for Istio

Check how many of CRDs installed for Istio with `kubectl get crd` command. Istio consists of bunch of CRDs!
```sh
$ kubectl get crd | wc -l
51

$ kubectl get crd

NAME                                    AGE
adapters.config.istio.io                14m
apikeys.config.istio.io                 14m
attributemanifests.config.istio.io      14m
authorizations.config.istio.io          14m
bypasses.config.istio.io                14m
checknothings.config.istio.io           14m
circonuses.config.istio.io              14m
deniers.config.istio.io                 14m
destinationrules.networking.istio.io    15m
edges.config.istio.io                   14m
envoyfilters.networking.istio.io        15m
fluentds.config.istio.io                14m
gateways.networking.istio.io            15m
handlers.config.istio.io                14m
httpapispecbindings.config.istio.io     15m
httpapispecs.config.istio.io            15m
instances.config.istio.io               14m
kubernetesenvs.config.istio.io          14m
...
```

## Check Pods & Services of Istio

Confrim all pods in `istio-system` namespace are `running`  
```
$ kubectl get pods -n istio-system

NAME                                        READY     STATUS    RESTARTS   AGE
grafana-56d946d5b6-4m5tf                    1/1       Running   0          1d
istio-citadel-769b85bf84-zhj7z              1/1       Running   0          1d
istio-egressgateway-677c95648f-q662v        1/1       Running   0          1d
istio-galley-5c65774d47-tz2nd               1/1       Running   0          1d
istio-ingressgateway-6fd6575b8b-j6fcm       1/1       Running   0          1d
istio-pilot-65f4cfb764-md9dc                2/2       Running   0          1d
istio-policy-5b9945744b-s2nzg               2/2       Running   0          1d
istio-sidecar-injector-75bfd779c9-z8djf     1/1       Running   0          1d
istio-statsd-prom-bridge-7f44bb5ddb-brscl   1/1       Running   0          1d
istio-telemetry-5fc7ccc5b7-ppgrp            2/2       Running   0          1d
istio-tracing-ff94688bb-f56hv               1/1       Running   0          1d
prometheus-84bd4b9796-trrg9                 1/1       Running   0          1d
kiali-5fbd6ffb-r5pq6                        1/1       Running   0          1d
```


Get the service list in `istio-system` namespace
```
$ kubectl get svc -n istio-system

NAME                       TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                                                                                                     AGE
grafana                    ClusterIP      10.0.213.140   <none>           3000/TCP                                                                                                    10m
istio-citadel              ClusterIP      10.0.141.145   <none>           8060/TCP,9093/TCP                                                                                           11h
istio-egressgateway        ClusterIP      10.0.209.229   <none>           80/TCP,443/TCP                                                                                              11h
istio-galley               ClusterIP      10.0.105.143   <none>           443/TCP,9093/TCP                                                                                            11h
istio-ingressgateway       LoadBalancer   10.0.165.160   40.115.180.109   80:31380/TCP,443:31390/TCP,31400:31400/TCP,15011:30898/TCP,8060:30247/TCP,15030:30955/TCP,15031:31046/TCP   11h
istio-pilot                ClusterIP      10.0.48.233    <none>           15010/TCP,15011/TCP,8080/TCP,9093/TCP                                                                       11h
istio-policy               ClusterIP      10.0.66.142    <none>           9091/TCP,15004/TCP,9093/TCP                                                                                 11h
istio-sidecar-injector     ClusterIP      10.0.52.142    <none>           443/TCP                                                                                                     11h
istio-statsd-prom-bridge   ClusterIP      10.0.199.206   <none>           9102/TCP,9125/UDP                                                                                           11h
istio-telemetry            ClusterIP      10.0.77.108    <none>           9091/TCP,15004/TCP,9093/TCP,42422/TCP                                                                       11h
jaeger-agent               ClusterIP      None           <none>           5775/UDP,6831/UDP,6832/UDP                                                                                  9m
jaeger-collector           ClusterIP      10.0.207.231   <none>           14267/TCP,14268/TCP                                                                                         9m
jaeger-query               ClusterIP      10.0.179.186   <none>           16686/TCP                                                                                                   9m
prometheus                 ClusterIP      10.0.196.72    <none>           9090/TCP                                                                                                    11h
tracing                    ClusterIP      10.0.254.69    <none>           80/TCP                                                                                                      9m
zipkin                     ClusterIP      10.0.181.238   <none>           9411/TCP                                                                                                    9m
```

## Access Istio endpoints (Forwarding local ports to a Pod.)

To port-forward and access `grafana`, run the following commands: 
```
$ kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana \
  -o jsonpath='{.items[0].metadata.name}') 3000:3000

$ curl http://localhost:3000
```

To port-forward and access `prometheus`, run the following commands: 
```
$ kubectl -n istio-system port-forward \
  $(kubectl -n istio-system get pod -l app=prometheus -o jsonpath='{.items[0].metadata.name}') 9090:9090

$ curl http://localhost:9090
```

To port-forward and access `Jaeger`, run the follwoing commands:
```
$ kubectl port-forward -n istio-system $(kubectl get pod -n istio-system -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686

$ curl http://localhost:16686
```

To port-forward and access `Kiali`, run the follwoing commands (user:pass=`admin`:`admin` by default):
```
$ kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=kiali -o jsonpath='{.items[0].metadata.name}') 20001:20001

$ curl http://localhost:20001
```


## Expose and access Istio endpoints (if you can't access the Istio endpoint by forwarding local ports to a Pod)

For example, if you are using `Azure Cloud Shell`, you can not use local portforward to access internal endpoints in Istio, you need to change the service type from `ClusterIP` to `LoadBalancer`. By changing the type to `LoadBalancer`, you can access the endpoint with Global IP. 

Edit the services and change the service type from `ClusterIP` to `LoadBalancer`:

```
# for Prometheus
$ kubectl -n istio-system edit svc prometheus

# for Grafana
$ kubectl -n istio-system edit svc grafana

# for Jaeger
$ kubectl -n istio-system edit svc jaeger-query

# for Kiali
$ kubectl -n istio-system edit svc kiali
```

![](../assets/edit-isito-service.png)


---
[Istio Top](aks-202-istio-top.md)| [Next](istio-02-deploy-bookinfo.md)
