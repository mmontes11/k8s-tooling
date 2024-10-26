#!/bin/bash

set -eo pipefail

KREW_VERSION=${KREW_VERSION:-v0.4.4}
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/${KREW_VERSION}/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

# TODO user: add this to Your .bashrc/.zshrc
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

kubectl krew update

KREW_PLUGINS=(
  "access-matrix"
  "cert-manager"
  "cilium"
  "df-pv"
  "rook-ceph"
  "volsync"
)
for PLUGIN in "${KREW_PLUGINS[@]}"; do
  kubectl krew install "$PLUGIN"
done