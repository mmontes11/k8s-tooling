#!/bin/bash

set -eo pipefail

function install_bin() {
  BIN=$1
  URL=$2
  echo "Installing binary '$BIN'"
  echo "Getting release from '$URL'..."

  curl -Lo $BIN $URL
  chmod +x $BIN
  mv $BIN /usr/local/bin/$BIN
}

function install_tar() {
  BIN=$1
  URL=$2
  TAR_DIR=$3
  echo "Installing binary '$BIN' from tar.gz"
  echo "Getting release from '$URL'..."

  curl -Lo $BIN $URL
  mkdir -p /tmp/$BIN
  tar -C /tmp/$BIN -zxvf $BIN

  BIN_PATH=/tmp/$BIN/$BIN
  if [ ! -z $TAR_DIR ]; then
    BIN_PATH=/tmp/$BIN/$TAR_DIR/$BIN
  fi

  chmod +x $BIN_PATH
  mv $BIN_PATH /usr/local/bin/$BIN
  rm -rf $BIN_PATH $BIN
}

function get_user_home() {
  USER_HOME=$(getent passwd $SUDO_USER | cut -d: -f6)
  echo $USER_HOME
}

function get_architecture() {
  ARCH=$(uname -m)
  if [ $ARCH = "x86_64" ]; then
    echo "amd64"
  elif [ $ARCH = "aarch64" ]; then
    echo "arm64"
  elif [[ $ARCH = "arm" ]]; then
    echo "arm"
  else
    echo ""
  fi
}

USER_HOME=$(get_user_home)
ARCH=$(get_architecture)
if [ -z $ARCH ]; then
  echo "Architecture not supported"
  exit 1
fi

# kubectl
KUBECTL_VERSION=${KUBECTL_VERSION:-v1.28.0}
KUBECTL_URL=https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/$ARCH/kubectl
install_bin kubectl $KUBECTL_URL

# helm
HELM_VERSION=${HELM_VERSION:-v3.13.2}
HELM_URL=https://get.helm.sh/helm-$HELM_VERSION-linux-$ARCH.tar.gz
install_tar helm $HELM_URL linux-$ARCH

# kubectx + kubens
KUBECTX_VERSION=${KUBECTX_VERSION:-v0.9.5}
KUBECTX_URL=https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_VERSION/kubectx
install_bin kubectx $KUBECTX_URL
KUBENS_URL=https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_VERSION/kubens
install_bin kubens $KUBENS_URL

# kind
KIND_VERSION=${KIND_VERSION:-v0.20.0}
KIND_URL=https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-$ARCH
install_bin kind $KIND_URL

# kustomize
KUSMTOMIZE_URL=${KUSMTOMIZE_URL:-https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv5.2.1/kustomize_v5.2.1_linux_$ARCH.tar.gz}
install_tar kustomize $KUSMTOMIZE_URL

# kubebuilder
KUBEBUILDER_VERSION=${KUBEBUILDER_VERSION:-v3.13.0}
KUBEBUILDER_URL=https://github.com/kubernetes-sigs/kubebuilder/releases/download/$KUBEBUILDER_VERSION/kubebuilder_linux_$ARCH
install_bin kubebuilder $KUBEBUILDER_URL

# operator-sdk
OPERATOR_SDK_VERSION=${OPERATOR_SDK_VERSION:-v1.32.0}
OPERATOR_SDK_URL=https://github.com/operator-framework/operator-sdk/releases/download/$OPERATOR_SDK_VERSION/operator-sdk_linux_$ARCH
install_bin operator-sdk $OPERATOR_SDK_URL

# openshift-local via code-ready-containers
echo "Installing 'code-ready-containers'"
CRC_VERSION=2.29.0
CRC_URL=https://developers.redhat.com/content-gateway/rest/mirror/pub/openshift-v4/clients/crc/$CRC_VERSION/crc-linux-$ARCH.tar.xz
curl -Lo /tmp/crc.tar.xz $CRC_URL
tar -C /tmp -xvf /tmp/crc.tar.xz
mv /tmp/crc-linux-$CRC_VERSION-$ARCH/crc /usr/local/bin
chmod +x /usr/local/bin/crc

# oc
OC_URL=https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-4.9/openshift-client-linux-4.9.59.tar.gz
install_tar oc $OC_URL

# opm
OPM_URL=https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-4.9/opm-linux-4.9.59.tar.gz
install_tar opm $OPM_URL

# cilium
CILIUM_VERSION=${CILIUM_VERSION:-v0.15.10}
CILIUM_URL=${CILIUM_URL:-https://github.com/cilium/cilium-cli/releases/download/$CILIUM_VERSION/cilium-linux-$ARCH.tar.gz}
install_tar cilium $CILIUM_URL

# flux
FLUX_VERSION=${FLUX_VERSION:-2.1.2}
FLUX_URL=https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_$ARCH.tar.gz
install_tar flux $FLUX_URL

# cert-manager
CM_VERSION=${CM_VERSION:-v1.13.2}
CM_URL=https://github.com/cert-manager/cert-manager/releases/download/$CM_VERSION/cmctl-linux-$ARCH.tar.gz
install_tar cmctl $CM_URL

# kubeseal
KUBESEAL_VERSION=${KUBESEAL_VERSION:-0.24.4}
KUBESEAL_URL=https://github.com/bitnami-labs/sealed-secrets/releases/download/v$KUBESEAL_VERSION/kubeseal-$KUBESEAL_VERSION-linux-$ARCH.tar.gz
install_tar kubeseal $KUBESEAL_URL

# vcluster
VCLUSTER_VERSION=${VCLUSTER_VERSION:-v0.17.1}
VCLUSTER_URL=https://github.com/loft-sh/vcluster/releases/download/$VCLUSTER_VERSION/vcluster-linux-$ARCH
install_bin vcluster $VCLUSTER_URL

# mc
MC_URL=https://dl.min.io/client/mc/release/linux-$ARCH/mc
install_bin mc $MC_URL

# talos
TALOS_VERSION=${TALOS_VERSION:-v1.7.0}
TALOS_URL=https://github.com/siderolabs/talos/releases/download/$TALOS_VERSION/talosctl-linux-$ARCH 
echo $TALOS_URL
install_bin talosctl $TALOS_URL

# k9s
K9S_VERSION=${K9S_VERSION:-v0.29.1}
K9S_URL=https://github.com/derailed/k9s/releases/download/$K9S_VERSION/k9s_Linux_$ARCH.tar.gz
install_tar k9s $K9S_URL
mkdir -p $USER_HOME/.config/k9s

K9S_THEME=${K9S_THEME:-nord}
K9S_THEME_URL=https://raw.githubusercontent.com/derailed/k9s/$K9S_VERSION/skins/$K9S_THEME.yml
curl -Lo $USER_HOME/.config/k9s/skin.yml $K9S_THEME_URL

mkdir -p $USER_HOME/.config/k9s
K9S_PLUGIN_CONFIG=$USER_HOME/.config/k9s/plugin.yml

if [ -f "$K9S_PLUGIN_CONFIG" ]; then
  rm "$K9S_PLUGIN_CONFIG"
fi

function install_k9s_plugin() {
  K9S_PLUGIN_URL="$1"
  K9S_PLUGIN_CONFIG="$2"
  K9S_PLUGIN_FILE=plugin.yml

  curl -Lo $K9S_PLUGIN_FILE $K9S_PLUGIN_URL
  cat $K9S_PLUGIN_FILE >> $K9S_PLUGIN_CONFIG
  rm $K9S_PLUGIN_FILE
}
K9S_PLUGINS=(
  # oficial
  "https://raw.githubusercontent.com/derailed/k9s/master/plugins/flux.yml"
  "https://raw.githubusercontent.com/derailed/k9s/master/plugins/watch_events.yml"
  # custom
  "https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/plugins/flux.yaml"
  "https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/plugins/cert-manager.yaml"
  "https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/plugins/openssl.yaml"
)

for i in "${!K9S_PLUGINS[@]}"; do
  K9S_PLUGIN_URL="${K9S_PLUGINS[$i]}" 
  install_k9s_plugin "$K9S_PLUGIN_URL" "$K9S_PLUGIN_CONFIG"
done
