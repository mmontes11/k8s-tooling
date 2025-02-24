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

log "Installing yq..."
YQ_VERSION=${YQ_VERSION:-v4.43.1}
YQ_URL=https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_$ARCH

if ! command -v yq &> /dev/null; then
  install_bin yq $YQ_URL
else
  echo "yq is already installed"
fi

log "Installing k9s..."
K9S_CONFIG=${XDG_CONFIG_HOME:="$USER_HOME/.config/k9s"}
K9S_CTX=${XDG_DATA_HOME:="$USER_HOME/.local/share/k9s"}
echo "Config folder: $K9S_CONFIG"
echo -n "Contexts folder: $K9S_CTX"

function cleanup() {
  if [ -d "$K9S_CONFIG" ]; then
    echo "Deleting existing config at '$K9S_CONFIG'..."
    rm -rf "$K9S_CONFIG"
  fi
  if [ -d "$K9S_CTX" ]; then
    echo "Deleting existing contexts at '$K9S_CTX'..."
    rm -rf "$K9S_CTX"
  fi
  if [ -d "k9s" ]; then
    echo "Deleting existing 'k9s' folder..."
    rm -rf "k9s"
  fi
}

if [ "$1" == "-f" -o "$1" == "-y" ]; then
  cleanup
else
  read -p "Do you want to cleanup existing config at '$K9S_CONFIG' and contexts at '$K9S_CTX'? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cleanup
  fi
fi

K9S_VERSION=${K9S_VERSION:-v0.40.5}
K9S_URL=https://github.com/derailed/k9s/releases/download/$K9S_VERSION/k9s_Linux_$ARCH.tar.gz
install_tar k9s $K9S_URL

mkdir -p "$K9S_CONFIG"
mkdir -p "$K9S_CONFIG/skins"
touch "$K9S_CONFIG/plugins.yaml"

mkdir -p "$K9S_CTX"
mkdir -p "$K9S_CTX/clusters"

git clone -q --no-progress https://github.com/derailed/k9s.git
git clone -q --no-progress https://github.com/mmontes11/k8s-tooling.git

cp k9s/skins/* "$K9S_CONFIG/skins"
cp k8s-tooling/.k9s/config.yaml "$K9S_CONFIG/config.yaml"
cp -r k8s-tooling/.k9s/skins/* "$K9S_CONFIG/skins"
cp -r k8s-tooling/.k9s/clusters/* "$K9S_CTX/clusters"

K9S_PLUGINS=(
  # oficial
  "k9s/plugins/cert-manager.yaml"
  "k9s/plugins/debug-container.yaml"
  "k9s/plugins/openssl.yaml"
  "k9s/plugins/watch-events.yaml"
  # custom
  "k8s-tooling/.k9s/plugins/flux.yaml"
)
for PLUGIN in "${K9S_PLUGINS[@]}"; do
  yq eval-all '. as $item ireduce ({}; . *+ $item)' \
    --inplace "$K9S_CONFIG/plugins.yaml" "$PLUGIN"
done

rm -rf k9s
rm -rf k8s-tooling

chown -R "$USER:$USER" "$K9S_CONFIG"
chown -R "$USER:$USER" "$K9S_CTX"

log "Done!"