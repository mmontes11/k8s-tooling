# 🧰 k8s-tooling
[![CI](https://github.com/mmontes11/k8s-tooling/actions/workflows/ci.yml/badge.svg)](https://github.com/mmontes11/k8s-tooling/actions/workflows/ci.yml)
[![Bump version](https://github.com/mmontes11/k8s-scripts/actions/workflows/bump-version.yml/badge.svg)](https://github.com/mmontes11/k8s-scripts/actions/workflows/bump-version.yml)
[![Release](https://github.com/mmontes11/k8s-tooling/actions/workflows/release.yml/badge.svg)](https://github.com/mmontes11/k8s-tooling/actions/workflows/release.yml)

Kurated Kubernetes tooling installable with one-liner command.

### Tooling
- [cilium](https://github.com/cilium/cilium-cli)
- [cmctl](https://github.com/cert-manager/cmctl)
- [flux](https://github.com/fluxcd/flux2)
- [helm](https://github.com/helm/helm)
- [k9s](https://github.com/derailed/k9s)
- [kind](https://github.com/kubernetes-sigs/kind/)
- [kubebuilder](https://github.com/kubernetes-sigs/kubebuilder)
- [kubectl](https://github.com/kubernetes/kubectl)
- [kubectx + kubens](https://github.com/ahmetb/kubectx)
- [kubeseal](https://github.com/bitnami-labs/sealed-secrets)
- [kustomize](https://github.com/kubernetes-sigs/kustomize)
- [mc](https://github.com/minio/mc)
- [oc](https://github.com/openshift/oc)
- [openshift-local](https://developers.redhat.com/products/openshift-local/overview)
- [operator-sdk](https://github.com/operator-framework/operator-sdk)
- [opm](https://github.com/operator-framework/operator-registry)
- [talosctl](https://github.com/siderolabs/talos/releases)
- [vcluster](https://github.com/loft-sh/vcluster)
- [yq](https://github.com/mikefarah/yq)

### Kubernetes

```bash
curl -sfL https://raw.githubusercontent.com/mmontes11/k8s-tooling/main/kubernetes.sh | sudo bash -s -
``` 

### Openshift

```bash
curl -sfL https://raw.githubusercontent.com/mmontes11/k8s-tooling/main/kubernetes.sh | sudo bash -s -
```

### k9s

```bash
curl -sfL https://raw.githubusercontent.com/mmontes11/k8s-tooling/main/k9s.sh | sudo bash -s -
``` 

[k9s](https://github.com/derailed/k9s) is also installed by the [Kubernetes](#kubernetes) installation flavour.

### Override versions

```bash
curl -sfL https://raw.githubusercontent.com/mmontes11/k8s-tooling/main/kubernetes.sh | sudo KUBECTL_VERSION=v1.25.4 bash -s -
``` 
```bash
export KUBECTL_VERSION=v1.25.4
export KIND_VERSION=v0.16.0
curl -sfL https://raw.githubusercontent.com/mmontes11/k8s-tooling/main/kubernetes.sh | sudo --preserve-env bash -s -
``` 
