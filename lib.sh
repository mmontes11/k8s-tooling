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

function get_username() {
  if [ -n "$SUDO_USER" ]; then
      echo "$SUDO_USER"
  else
      echo "$(whoami)"
  fi
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