#!/bin/bash

set -eo pipefail

source <(curl -s source https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/lib.sh)

USER_HOME=$(get_user_home)
ARCH=$(get_architecture)
if [ -z $ARCH ]; then
  echo "Architecture not supported"
  exit 1
fi

log "Installing kubectl..."
KUBECTL_VERSION=${KUBECTL_VERSION:-v1.30.0}
KUBECTL_URL=https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/$ARCH/kubectl
install_bin kubectl $KUBECTL_URL

log "Installing helm..."
HELM_VERSION=${HELM_VERSION:-v3.14.4}
HELM_URL=https://get.helm.sh/helm-$HELM_VERSION-linux-$ARCH.tar.gz
install_tar helm $HELM_URL linux-$ARCH

log "Installing kubectx + kubens..."
KUBECTX_VERSION=${KUBECTX_VERSION:-v0.9.5}
KUBECTX_URL=https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_VERSION/kubectx
install_bin kubectx $KUBECTX_URL
KUBENS_URL=https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_VERSION/kubens
install_bin kubens $KUBENS_URL

log "Installing kind..."
KIND_VERSION=${KIND_VERSION:-v0.21.0}
KIND_URL=https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-$ARCH
install_bin kind $KIND_URL

log "Installing kustomize..."
KUSMTOMIZE_URL=${KUSMTOMIZE_URL:-https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.4.1/kustomize_v5.4.1_linux_$ARCH.tar.gz}
install_tar kustomize $KUSMTOMIZE_URL

log "Installing kubebuilder..."
KUBEBUILDER_VERSION=${KUBEBUILDER_VERSION:-v3.14.2}
KUBEBUILDER_URL=https://github.com/kubernetes-sigs/kubebuilder/releases/download/$KUBEBUILDER_VERSION/kubebuilder_linux_$ARCH
install_bin kubebuilder $KUBEBUILDER_URL

log "Installing cilium..."
CILIUM_VERSION=${CILIUM_VERSION:-v0.16.7}
CILIUM_URL=${CILIUM_URL:-https://github.com/cilium/cilium-cli/releases/download/$CILIUM_VERSION/cilium-linux-$ARCH.tar.gz}
install_tar cilium $CILIUM_URL

log "Installing flux..."
FLUX_VERSION=${FLUX_VERSION:-2.3.0}
FLUX_URL=https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_$ARCH.tar.gz
install_tar flux $FLUX_URL

log "Installing cmctl..."
CM_VERSION=${CM_VERSION:-v1.14.5}
CM_URL=https://github.com/cert-manager/cert-manager/releases/download/$CM_VERSION/cert-manager-cmctl-linux-$ARCH.tar.gz
install_tar cmctl $CM_URL

log "Installing kubeseal..."
KUBESEAL_VERSION=${KUBESEAL_VERSION:-0.26.2}
KUBESEAL_URL=https://github.com/bitnami-labs/sealed-secrets/releases/download/v$KUBESEAL_VERSION/kubeseal-$KUBESEAL_VERSION-linux-$ARCH.tar.gz
install_tar kubeseal $KUBESEAL_URL

log "Installing vcluster..."
VCLUSTER_VERSION=${VCLUSTER_VERSION:-v0.19.5}
VCLUSTER_URL=https://github.com/loft-sh/vcluster/releases/download/$VCLUSTER_VERSION/vcluster-linux-$ARCH
install_bin vcluster $VCLUSTER_URL

log "Installing mc..."
MC_URL=https://dl.min.io/client/mc/release/linux-$ARCH/mc
install_bin mc $MC_URL

log "Installing talosctl..."
TALOS_VERSION=${TALOS_VERSION:-v1.7.1}
TALOS_URL=https://github.com/siderolabs/talos/releases/download/$TALOS_VERSION/talosctl-linux-$ARCH 
install_bin talosctl $TALOS_URL

log "Installing yq..."
YQ_VERSION=${YQ_VERSION:-v4.43.1}
YQ_URL=https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_$ARCH
install_bin yq $YQ_URL

# k9s
source <(curl -s https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/k9s.sh) -y