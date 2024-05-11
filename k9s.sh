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

# yq
echo "Installing yq..."

YQ_VERSION=v4.43.1
YQ_URL=https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_$ARCH

if ! command -v yq &> /dev/null; then
  install_bin yq $YQ_URL
else
  echo "yq is already installed"
fi

# k9s
echo "🐶 Installing k9s..."

K9S_CONFIG=${XDG_CONFIG_HOME:="$USER_HOME/.config/k9s"}
K9S_CTX=${XDG_DATA_HOME:="$USER_HOME/.local/share/k9s"}
echo "Config folder: $K9S_CONFIG"
echo "Contextss folder: $K9S_CTX"

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

if [ "$1" == "--force" -o "$1" == "-f" -o "$1" == "-y" ]; then
  cleanup
else
  read -p "Do you want to cleanup existing config @ '$K9S_CONFIG' and contexts @ '$K9S_CTX'? (y/n) " -n 1
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cleanup
  fi
fi

K9S_VERSION=${K9S_VERSION:-v0.32.4}
K9S_URL=https://github.com/derailed/k9s/releases/download/$K9S_VERSION/k9s_Linux_$ARCH.tar.gz
install_tar k9s $K9S_URL

mkdir -p "$K9S_CONFIG"
mkdir -p "$K9S_CONFIG/skins"
touch "$K9S_CONFIG/plugins.yaml"

mkdir -p "$K9S_CTX"
mkdir -p "$K9S_CTX/clusters"

git clone https://github.com/derailed/k9s.git
cp k9s/skins/* "$K9S_CONFIG/skins"
rm -rf k9s

K9S_PLUGINS=(
  # oficial
  "https://raw.githubusercontent.com/derailed/k9s/master/plugins/watch-events.yaml"
  # custom
  "https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/.k9s/plugins/flux.yaml"
  "https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/.k9s/plugins/cert-manager.yaml"
  "https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/.k9s/plugins/openssl.yaml"
)
for i in "${!K9S_PLUGINS[@]}"; do
  curl -Lo plugin.yaml "${K9S_PLUGINS[$i]}"

  yq eval-all '. as $item ireduce ({}; . *+ $item)' \
    --inplace "$K9S_CONFIG/plugins.yaml" plugin.yaml
  rm plugin.yaml
done

cp .k9s/config.yaml "$K9S_CONFIG/config.yaml"

cp -r .k9s/clusters/* "$K9S_CTX/clusters"

chown -R "$USER:$USER" "$K9S_CONFIG"
chown -R "$USER:$USER" "$K9S_CTX"

echo "🐶 Done!"
