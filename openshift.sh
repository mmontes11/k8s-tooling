#!/bin/bash

set -eo pipefail

source <(curl -s source https://raw.githubusercontent.com/mmontes11/k8s-scripts/main/lib.sh)

USER_HOME=$(get_user_home)
ARCH=$(get_architecture)
if [ -z $ARCH ]; then
  echo "Architecture not supported"
  exit 1
fi

log "Installing openshift-local..."
CRC_VERSION=2.48.0
CRC_URL=https://developers.redhat.com/content-gateway/rest/mirror/pub/openshift-v4/clients/crc/$CRC_VERSION/crc-linux-$ARCH.tar.xz
curl -sSLo /tmp/crc.tar.xz $CRC_URL
tar -C /tmp -xvf /tmp/crc.tar.xz > /dev/null 2>&1
mv /tmp/crc-linux-$CRC_VERSION-$ARCH/crc /usr/local/bin
chmod +x /usr/local/bin/crc

log "Installing oc..."
OC_VERSION=${OC_VERSION:-4.18.6}
OC_URL=https://mirror.openshift.com/pub/openshift-v4/$(uname -m)/clients/ocp/$OC_VERSION/openshift-client-linux-$OC_VERSION.tar.gz
install_tar oc $OC_URL

log "Installing opm..."
OPM_VERSION=${OPM_VERSION:-v1.51.0}
OPM_URL=https://github.com/operator-framework/operator-registry/releases/download/$OPM_VERSION/linux-$ARCH-opm 
install_bin opm $OPM_URL

log "Installing operator-sdk..."
OPERATOR_SDK_VERSION=${OPERATOR_SDK_VERSION:-v1.39.2}
OPERATOR_SDK_URL=https://github.com/operator-framework/operator-sdk/releases/download/$OPERATOR_SDK_VERSION/operator-sdk_linux_$ARCH
install_bin operator-sdk $OPERATOR_SDK_URL

log "Installing tekton..."
TEKTON_VERSION=${TEKTON_VERSION:-0.40.0}
TEKTON_URL="https://github.com/tektoncd/cli/releases/download/v${TEKTON_VERSION}/tektoncd-cli-${TEKTON_VERSION}_Linux-64bit.deb"
install_deb tkn $TEKTON_URL

log "Done!"