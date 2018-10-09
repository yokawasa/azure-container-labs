# Kubernetes Userful Tools

## kubectx
kubectx is a commandline tool that allow you to switch between clusters and namespaces in kubectl easily & smoothly
- https://github.com/ahmetb/kubectx

```sh
# installation (Mac)
$ brew install kubectx

# how to switch contexts
$ kubectx [tab]
 <cluster1> <cluster2> <cluster3> ...
```

## stern
stern is a commandline for multi pod and container log tailing for Kubernetes
- https://github.com/wercker/stern

```
# installation on MacOS
$ brew install stern

# Usage
## tail <podname> in namespace
## stern <podname> -n <namespace>
$ stern samplepod

+ samplepod-684ccd679f-nl252 › sample-pod-demo
samplepod-684ccd679f-nl252 sample-pod-demo o36e6ivtni@8ae3fca5-9b5c-471b-99d8-0eeb567c6acb
samplepod-684ccd679f-nl252 sample-pod-demo ===== table list =====
samplepod-684ccd679f-nl252 sample-pod-demo ('test',)
samplepod-684ccd679f-nl252 sample-pod-demo ===== Records =====
samplepod-684ccd679f-nl252 sample-pod-demo Id: 1 Content: hoge
samplepod-684ccd679f-nl252 sample-pod-demo Id: 2 Content: foo
samplepod-684ccd679f-nl252 sample-pod-demo Id: 3 Content: bar
```


## kubespy
kubespy is a commandline tool for observing Kubernetes resources in real time
- https://github.com/pulumi/kubespy

Here is a way to install kubespy
```sh
# install binary (`go install` didn't work on my env for some reason)

$ wget https://github.com/pulumi/kubespy/releases/download/v0.4.0/kubespy-darwin-368.tar.gz
$ tar zxvf kubespy-darwin-368.tar.gz
$ cp -p releases/kubespy-darwin-386/kubespy $PATH/
$ kubespy

Spy on your Kubernetes resources

Usage:
  kubespy [command]

Available Commands:
  changes     Displays changes made to a Kubernetes resource in real time. Emitted as JSON diffs
  help        Help about any command
  status      Displays changes to a Kubernetes resources's status in real time. Emitted as JSON diffs
  trace       Traces status of complex API objects
  version     Displays version information for this tool

Flags:
  -h, --help   help for kubespy

Use "kubespy [command] --help" for more information about a command.
```
