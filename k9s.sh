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
YQ_VERSION=${YQ_VERSION:-v4.53.6}
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

K9S_VERSION=${K9S_VERSION:-v0.51.0}
K9S_URL=https://github.com/derailed/k9s/releases/download/$K9S_VERSION/k9s_Linux_$ARCH.tar.gz
install_tar k9s $K9S_URL

mkdir -p "$K9S_CONFIG"
mkdir -p "$K9S_CONFIG/skins"

mkdir -p "$K9S_CTX"
mkdir -p "$K9S_CTX/clusters"

git clone -q --no-progress https://github.com/derailed/k9s.git
git clone -q --no-progress https://github.com/mmontes11/k8s-tooling.git

cp k9s/skins/* "$K9S_CONFIG/skins"
cp k8s-tooling/.k9s/config.yaml "$K9S_CONFIG/config.yaml"
cp -r k8s-tooling/.k9s/skins/* "$K9S_CONFIG/skins"
cp -r k8s-tooling/.k9s/clusters/* "$K9S_CTX/clusters"

if [ -n "${K9S_SKIN:-}" ]; then
  log "Setting k9s theme to '$K9S_SKIN'..."
  yq eval ".k9s.ui.skin = \"$K9S_SKIN\"" --inplace "$K9S_CONFIG/config.yaml"
else
  log "k9s theme: '$(yq eval '.k9s.ui.skin' "$K9S_CONFIG/config.yaml")' (default)"
fi

K9S_PLUGINS=(
  # oficial
  "k9s/plugins/cert-manager.yaml"
  "k9s/plugins/debug-container.yaml"
  "k9s/plugins/openssl.yaml"
  "k9s/plugins/resource-recommendations.yaml"
  "k9s/plugins/watch-events.yaml"
  # custom
  "k8s-tooling/.k9s/plugins/flux.yaml"
)
# Build plugins.yaml from scratch on every run. Merging into a pre-existing
# plugins.yaml is unsafe: yq '*+' deep-merge concatenates arrays (scopes,
# args, inputs) and comments on every re-run, and k9s v0.51+ rejects the
# result once 'inputs' exceeds 5 entries (schema: maxItems 5).
# Refuse to merge plugin names that collide across source files, since a
# '*+' merge would silently concatenate the colliding plugin's arrays.
duplicates=$(for plugin in "${K9S_PLUGINS[@]}"; do
  yq eval '.plugins // {} | keys | .[]' -r "$plugin"
done | sort | uniq -d)
if [ -n "$duplicates" ]; then
  echo "ERROR: duplicate plugin names in ${K9S_PLUGINS[*]}:"
  echo "$duplicates"
  exit 1
fi

tmp_plugins=$(mktemp)
trap 'rm -f "$tmp_plugins"' EXIT
yq eval-all '. as $item ireduce ({}; . *+ $item)' "${K9S_PLUGINS[@]}" > "$tmp_plugins"

# k9s schema allows at most 5 inputs per plugin; fail early instead of
# installing a plugins.yaml that k9s will refuse to load.
for bad in $(yq eval '.plugins // {} | to_entries | map(select((.value.inputs // []) | length > 5) | .key) | .[]' -r "$tmp_plugins"); do
  echo "ERROR: plugin '$bad' defines more than 5 inputs (k9s schema limit)"
  exit 1
done

# Keep a copy of any previous plugins.yaml for inspection.
if [ -f "$K9S_CONFIG/plugins.yaml" ] && ! cmp -s "$K9S_CONFIG/plugins.yaml" "$tmp_plugins"; then
  mv "$K9S_CONFIG/plugins.yaml" "$K9S_CONFIG/plugins.yaml.bak"
fi
mv "$tmp_plugins" "$K9S_CONFIG/plugins.yaml"
trap - EXIT

# Add override: true to all plugins to prevent "duplicate plugin key found" errors
# with built-in k9s shortcuts. See: https://github.com/derailed/k9s/issues/3886
yq eval '.plugins[].override = true' --inplace "$K9S_CONFIG/plugins.yaml"

rm -rf k9s
rm -rf k8s-tooling

chown -R "$USER:$USER" "$K9S_CONFIG"
chown -R "$USER:$USER" "$K9S_CTX"

log "Done!"