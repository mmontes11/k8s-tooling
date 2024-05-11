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
YQ_VERSION=v4.43.1
YQ_URL=https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_$ARCH
install_bin yq $YQ_URL

# k9s
echo "Installing k9s"

K9S_CONFIG=$USER_HOME/.config/k9s
if [ -d "$K9S_CONFIG" ]; then
  echo "Deleting existing config"
  rm -rf "$K9S_CONFIG"
fi
if [ -d "k9s" ]; then
  echo "Deleting existing upstream repo"
  rm -rf "k9s"
fi

K9S_VERSION=${K9S_VERSION:-v0.32.4}
K9S_URL=https://github.com/derailed/k9s/releases/download/$K9S_VERSION/k9s_Linux_$ARCH.tar.gz
install_tar k9s $K9S_URL

mkdir -p "$K9S_CONFIG"
mkdir -p "$K9S_CONFIG/skins"
touch "$K9S_CONFIG/plugins.yaml"

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

chown -R "$USER:$USER" "$K9S_CONFIG"