#!/bin/bash

set -eo pipefail

source <(curl -s source https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/lib.sh)

USER_HOME=$(get_user_home)
USER=$(get_username)
ARCH=$(get_architecture)
if [ -z $ARCH ]; then
  echo "Architecture not supported"
  exit 1
fi

log "Installing kubectl..."
KUBECTL_VERSION=${KUBECTL_VERSION:-v1.33.1}
KUBECTL_URL=https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/$ARCH/kubectl
install_bin kubectl $KUBECTL_URL

log "Installing helm..."
HELM_VERSION=${HELM_VERSION:-v3.17.1}
HELM_URL=https://get.helm.sh/helm-$HELM_VERSION-linux-$ARCH.tar.gz
install_tar helm $HELM_URL linux-$ARCH

log "Installing kubectx + kubens..."
KUBECTX_VERSION=${KUBECTX_VERSION:-v0.9.5}
KUBECTX_URL=https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_VERSION/kubectx
install_bin kubectx $KUBECTX_URL
KUBENS_URL=https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_VERSION/kubens
install_bin kubens $KUBENS_URL

log "Installing kind..."
KIND_VERSION=${KIND_VERSION:-v0.27.0}
KIND_URL=https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-$ARCH
install_bin kind $KIND_URL

log "Installing kustomize..."
KUSMTOMIZE_URL=${KUSMTOMIZE_URL:-https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.4.3/kustomize_v5.4.3_linux_$ARCH.tar.gz}
install_tar kustomize $KUSMTOMIZE_URL

log "Installing kubebuilder..."
KUBEBUILDER_VERSION=${KUBEBUILDER_VERSION:-v4.5.1}
KUBEBUILDER_URL=https://github.com/kubernetes-sigs/kubebuilder/releases/download/$KUBEBUILDER_VERSION/kubebuilder_linux_$ARCH
install_bin kubebuilder $KUBEBUILDER_URL

log "Installing clusterctl..."
CLUSTERCTL_VERSION=${CLUSTERCTL_VERSION:-v1.10.2}
CLUSTERCTL_URL=https://github.com/kubernetes-sigs/cluster-api/releases/download/$CLUSTERCTL_VERSION/clusterctl-linux-$ARCH
install_bin clusterctl $CLUSTERCTL_URL

log "Installing kubeadm-join-config..."
KUBEADM_JOIN_CONFIG_VERSION=${KUBEADM_JOIN_CONFIG:-0.0.1}
KUBEADM_JOIN_CONFIG_URL=https://github.com/mmontes11/k8s-bootstrap/releases/download/v${KUBEADM_JOIN_CONFIG_VERSION}/kubeadm-join-config_${KUBEADM_JOIN_CONFIG_VERSION}_${ARCH}
install_bin kubeadm-join-config $KUBEADM_JOIN_CONFIG_URL

log "Installing cilium..."
CILIUM_VERSION=${CILIUM_VERSION:-v0.17.0}
CILIUM_URL=${CILIUM_URL:-https://github.com/cilium/cilium-cli/releases/download/$CILIUM_VERSION/cilium-linux-$ARCH.tar.gz}
install_tar cilium $CILIUM_URL

log "Installing flux..."
FLUX_VERSION=${FLUX_VERSION:-2.5.0}
FLUX_URL=https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_$ARCH.tar.gz
install_tar flux $FLUX_URL

log "Installing cmctl..."
CM_VERSION=${CM_VERSION:-v2.1.1}
CM_URL=https://github.com/cert-manager/cmctl/releases/download/$CM_VERSION/cmctl_linux_$ARCH.tar.gz
install_tar cmctl $CM_URL

log "Installing kubeseal..."
KUBESEAL_VERSION=${KUBESEAL_VERSION:-0.28.0}
KUBESEAL_URL=https://github.com/bitnami-labs/sealed-secrets/releases/download/v$KUBESEAL_VERSION/kubeseal-$KUBESEAL_VERSION-linux-$ARCH.tar.gz
install_tar kubeseal $KUBESEAL_URL

log "Installing vcluster..."
VCLUSTER_VERSION=${VCLUSTER_VERSION:-v0.22.4}
VCLUSTER_URL=https://github.com/loft-sh/vcluster/releases/download/$VCLUSTER_VERSION/vcluster-linux-$ARCH
install_bin vcluster $VCLUSTER_URL

log "Installing talosctl..."
TALOS_VERSION=${TALOS_VERSION:-v1.9.4}
TALOS_URL=https://github.com/siderolabs/talos/releases/download/$TALOS_VERSION/talosctl-linux-$ARCH 
install_bin talosctl $TALOS_URL

log "Installing yq..."
YQ_VERSION=${YQ_VERSION:-v4.45.1}
YQ_URL=https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_$ARCH
install_bin yq $YQ_URL

log "Installing MinIO mc..."
MC_URL=https://dl.min.io/client/mc/release/linux-$ARCH/mc
install_bin mc $MC_URL

log "Installing MinIO warp..."
WARP_VERSION=${WARP_VERSION:-v1.3.0}
WARP_URL=https://github.com/minio/warp/releases/download/$WARP_VERSION/warp_Linux_$(uname -m).tar.gz
install_tar warp $WARP_URL

log "Installing kubestr..."
KUBESTR_VERSION=${KUBESTR_VERSION:-0.4.49}
KUBESTR_URL=https://github.com/kastenhq/kubestr/releases/download/v${KUBESTR_VERSION}/kubestr_${KUBESTR_VERSION}_Linux_${ARCH}.tar.gz
install_tar kubestr $KUBESTR_URL

log "Installing krr..."
KRR_VERSION=${KRR_VERSION:-v1.23.0}
KRR_URL="https://github.com/robusta-dev/krr/releases/download/${KRR_VERSION}/krr-ubuntu-latest-${KRR_VERSION}.zip"
TMP_DIR=$(mktemp -d)
curl -sSLo "$TMP_DIR/krr.zip" "$KRR_URL"  
unzip -q "$TMP_DIR/krr.zip" -d "$TMP_DIR"
rm -rf /opt/krr
rm -rf /usr/local/bin/krr
mv $TMP_DIR/krr /opt
ln -s /opt/krr/krr /usr/local/bin/krr
rm -rf "$TMP_DIR"

# k9s
source <(curl -s https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/k9s.sh) -y

# krew
sudo -u $USER bash -c 'curl -sfL https://raw.githubusercontent.com/mmontes11/k8s-tooling/main/krew.sh | bash'