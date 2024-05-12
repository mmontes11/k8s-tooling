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