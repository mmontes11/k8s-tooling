# 📜 kube-scripts
Install Kubernetes tooling with a single command.

### Usage

```bash
 curl -sfL https://raw.githubusercontent.com/mmontes11/kube-scripts/main/kubernetes.sh | sudo bash -s -
``` 

### Override versions

```bash
curl -sfL https://raw.githubusercontent.com/mmontes11/kube-scripts/main/kubernetes.sh | sudo KUBECTL_VERSION=v1.25.4 bash -s -
``` 
```bash
export KUBECTL_VERSION=v1.25.4
export KIND_VERSION=v0.16.0
curl -sfL https://raw.githubusercontent.com/mmontes11/kube-scripts/main/kubernetes.sh | sudo --preserve-env bash -s -
``` 