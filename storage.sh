#!/bin/bash

set -eo pipefail

source <(curl -s source https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/lib.sh)

ARCH=$(get_architecture)
if [ -z $ARCH ]; then
  echo "Architecture not supported"
  exit 1
fi

log "Installing MinIO mc..."
MC_URL=https://dl.min.io/client/mc/release/linux-$ARCH/mc
install_bin mc $MC_URL

log "Installing MinIO warp..."
WARP_VERSION=${WARP_VERSION:-v1.5.0}
WARP_URL=https://dl.min.io/aistor/warp/release/linux-$ARCH/archive/warp.$WARP_VERSION
install_bin warp $WARP_URL

log "Installing kubestr..."
KUBESTR_VERSION=${KUBESTR_VERSION:-0.4.49}
KUBESTR_URL=https://github.com/kastenhq/kubestr/releases/download/v${KUBESTR_VERSION}/kubestr_${KUBESTR_VERSION}_Linux_${ARCH}.tar.gz
install_tar kubestr $KUBESTR_URL

log "Installing rclone..."
RCLONE_VERSION=${RCLONE_VERSION:-v1.74.4}
RCLONE_URL=https://github.com/rclone/rclone/releases/download/$RCLONE_VERSION/rclone-$RCLONE_VERSION-linux-$ARCH.zip
TMP_DIR=$(mktemp -d)
curl -sSLo "$TMP_DIR/rclone.zip" "$RCLONE_URL"
unzip -q "$TMP_DIR/rclone.zip" -d "$TMP_DIR"
chmod +x "$TMP_DIR/rclone-$RCLONE_VERSION-linux-$ARCH/rclone"
mv "$TMP_DIR/rclone-$RCLONE_VERSION-linux-$ARCH/rclone" /usr/local/bin/rclone
rm -rf "$TMP_DIR"

log "Installing kopia..."
KOPIA_VERSION=${KOPIA_VERSION:-v0.23.1}
KOPIA_ARCH=$ARCH
if [ "$ARCH" = "amd64" ]; then
  KOPIA_ARCH=x64
fi
KOPIA_URL=https://github.com/kopia/kopia/releases/download/$KOPIA_VERSION/kopia-${KOPIA_VERSION#v}-linux-$KOPIA_ARCH.tar.gz
install_tar kopia $KOPIA_URL kopia-${KOPIA_VERSION#v}-linux-$KOPIA_ARCH

log "Installing SeaweedFS weed..."
WEED_VERSION=${WEED_VERSION:-4.40}
WEED_URL=https://github.com/seaweedfs/seaweedfs/releases/download/$WEED_VERSION/linux_$ARCH.tar.gz
install_tar weed $WEED_URL

log "Done!"
