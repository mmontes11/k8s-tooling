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
  if [ $ARCH == "x86_64" ]; then
    echo "amd64"
  elif [ $ARCH == "aarch64" ]; then
    echo "arm64"
  elif [[ $ARCH == arm* ]]; then
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
KUBECTL_VERSION=${KUBECTL_VERSION:-v1.26.0}
KUBECTL_URL=https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/$ARCH/kubectl
install_bin kubectl $KUBECTL_URL

# helm
HELM_VERSION=${HELM_VERSION:-v3.11.2}
HELM_URL=https://get.helm.sh/helm-$HELM_VERSION-linux-$ARCH.tar.gz
install_tar helm $HELM_URL linux-$ARCH

# kubectx + kubens
KUBECTX_VERSION=${KUBECTX_VERSION:-v0.9.4}
KUBECTX_URL=https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_VERSION/kubectx
install_bin kubectx $KUBECTX_URL
KUBENS_URL=https://github.com/ahmetb/kubectx/releases/download/$KUBECTX_VERSION/kubens
install_bin kubens $KUBENS_URL

# kind
KIND_VERSION=${KIND_VERSION:-v0.18.0}
KIND_URL=https://kind.sigs.k8s.io/dl/$KIND_VERSION/kind-linux-$ARCH
install_bin kind $KIND_URL

# kustomize
KUSMTOMIZE_URL=${KUSMTOMIZE_URL:-https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv4.5.7/kustomize_v4.5.7_linux_$ARCH.tar.gz}
install_tar kustomize $KUSMTOMIZE_URL

# kubebuilder
KUBEBUILDER_VERSION=${KUBEBUILDER_VERSION:-v3.7.0}
KUBEBUILDER_URL=https://github.com/kubernetes-sigs/kubebuilder/releases/download/$KUBEBUILDER_VERSION/kubebuilder_linux_$ARCH
install_bin kubebuilder $KUBEBUILDER_URL

# operator-sdk
OPERATOR_SDK_VERSION=${OPERATOR_SDK_VERSION:-v1.26.0}
OPERATOR_SDK_URL=https://github.com/operator-framework/operator-sdk/releases/download/$OPERATOR_SDK_VERSION/operator-sdk_linux_$ARCH
install_bin operator-sdk $OPERATOR_SDK_URL

# cilium
CILIUM_VERSION=${CILIUM_VERSION:-v0.12.11}
CILIUM_URL=${CILIUM_URL:-https://github.com/cilium/cilium-cli/releases/download/$CILIUM_VERSION/cilium-linux-$ARCH.tar.gz}
install_tar cilium $CILIUM_URL

# flux
FLUX_VERSION=${FLUX_VERSION:-v0.40.1}
FLUX_URL=https://github.com/fluxcd/flux2/releases/download/$FLUX_VERSION/flux_0.40.1_linux_$ARCH.tar.gz
install_tar flux $FLUX_URL

# cert-manager
CM_VERSION=${CM_VERSION:-v1.10.1}
CM_URL=https://github.com/cert-manager/cert-manager/releases/download/$CM_VERSION/cmctl-linux-$ARCH.tar.gz
install_tar cmctl $CM_URL

# kubeseal
KUBESEAL_VERSION=${KUBESEAL_VERSION:-0.19.2}
KUBESEAL_URL=https://github.com/bitnami-labs/sealed-secrets/releases/download/v$KUBESEAL_VERSION/kubeseal-$KUBESEAL_VERSION-linux-$ARCH.tar.gz
install_tar kubeseal $KUBESEAL_URL

# k9s
K9S_VERSION=${K9S_VERSION:-v0.27.3}
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