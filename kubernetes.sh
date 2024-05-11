#!/bin/bash

set -eo pipefail

source <(curl -s source https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/lib.sh)

USER_HOME=$(get_user_home)
ARCH=$(get_architecture)
if [ -z $ARCH ]; then
  echo "Architecture not supported"
  exit 1
fi

# openshift-local
CRC_VERSION=2.29.0
CRC_URL=https://developers.redhat.com/content-gateway/rest/mirror/pub/openshift-v4/clients/crc/$CRC_VERSION/crc-linux-$ARCH.tar.xz
curl -Lo /tmp/crc.tar.xz $CRC_URL
tar -C /tmp -xvf /tmp/crc.tar.xz
mv /tmp/crc-linux-$CRC_VERSION-$ARCH/crc /usr/local/bin
chmod +x /usr/local/bin/crc

# oc
OC_URL=https://mirror.openshift.com/pub/openshift-v4/$(uname -m)/clients/ocp/stable-4.15/openshift-client-linux-4.15.11.tar.gz
install_tar oc $OC_URL

# opm
OPM_URL=https://mirror.openshift.com/pub/openshift-v4/$(uname -m)/clients/ocp/stable-4.15/opm-linux-4.15.11.tar.gz
install_tar opm $OPM_URL

# operator-sdk
OPERATOR_SDK_VERSION=${OPERATOR_SDK_VERSION:-v1.34.1}
OPERATOR_SDK_URL=https://github.com/operator-framework/operator-sdk/releases/download/$OPERATOR_SDK_VERSION/operator-sdk_linux_$ARCH
install_bin operator-sdk $OPERATOR_SDK_URL

# kubectl
KUBECTL_VERSION=${KUBECTL_VERSION:-v1.30.0}
KUBECTL_URL=https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/$ARCH/kubectl
install_bin kubectl $KUBECTL_URL

# helm
HELM_VERSION=${HELM_VERSION:-v3.14.4}
HELM_URL=https://get.helm.sh/helm-$HELM_VERSION-linux-$ARCH.tar.gz
install_tar helm $HELM_URL linux-$ARCH

# kubectx + kubens
KUBECTX_VERSION=${KUBECTX_VERSION:-v0.9.5}
KUBECTX_URL=https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_VERSION/kubectx
install_bin kubectx $KUBECTX_URL
KUBENS_URL=https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_VERSION/kubens
install_bin kubens $KUBENS_URL

# kind
KIND_VERSION=${KIND_VERSION:-v0.22.0}
KIND_URL=https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-$ARCH
install_bin kind $KIND_URL

# kustomize
KUSMTOMIZE_URL=${KUSMTOMIZE_URL:-https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.4.1/kustomize_v5.4.1_linux_$ARCH.tar.gz}
install_tar kustomize $KUSMTOMIZE_URL

# kubebuilder
KUBEBUILDER_VERSION=${KUBEBUILDER_VERSION:-v3.14.2}
KUBEBUILDER_URL=https://github.com/kubernetes-sigs/kubebuilder/releases/download/$KUBEBUILDER_VERSION/kubebuilder_linux_$ARCH
install_bin kubebuilder $KUBEBUILDER_URL

# cilium
CILIUM_VERSION=${CILIUM_VERSION:-v0.16.7}
CILIUM_URL=${CILIUM_URL:-https://github.com/cilium/cilium-cli/releases/download/$CILIUM_VERSION/cilium-linux-$ARCH.tar.gz}
install_tar cilium $CILIUM_URL

# flux
FLUX_VERSION=${FLUX_VERSION:-2.2.3}
FLUX_URL=https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_$ARCH.tar.gz
install_tar flux $FLUX_URL

# cert-manager
CM_VERSION=${CM_VERSION:-v1.14.5}
CM_URL=https://github.com/cert-manager/cert-manager/releases/download/$CM_VERSION/cert-manager-cmctl-linux-$ARCH.tar.gz
install_tar cmctl $CM_URL

# kubeseal
KUBESEAL_VERSION=${KUBESEAL_VERSION:-0.26.2}
KUBESEAL_URL=https://github.com/bitnami-labs/sealed-secrets/releases/download/v$KUBESEAL_VERSION/kubeseal-$KUBESEAL_VERSION-linux-$ARCH.tar.gz
install_tar kubeseal $KUBESEAL_URL

# vcluster
VCLUSTER_VERSION=${VCLUSTER_VERSION:-v0.19.5}
VCLUSTER_URL=https://github.com/loft-sh/vcluster/releases/download/$VCLUSTER_VERSION/vcluster-linux-$ARCH
install_bin vcluster $VCLUSTER_URL

# mc
MC_URL=https://dl.min.io/client/mc/release/linux-$ARCH/mc
install_bin mc $MC_URL

# talos
TALOS_VERSION=${TALOS_VERSION:-v1.7.1}
TALOS_URL=https://github.com/siderolabs/talos/releases/download/$TALOS_VERSION/talosctl-linux-$ARCH 
echo $TALOS_URL
install_bin talosctl $TALOS_URL

# yq
YQ_VERSION=v4.43.1
YQ_URL=https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_$ARCH
install_bin yq $YQ_URL

# k9s
source <(curl -s https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/k9s.sh) -y