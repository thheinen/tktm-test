#!/bin/bash

TARGET_BRANCH="thheinen/target-mode"

REPO="https://github.com/tecracer-chef/kitchen-transport-train"
MAIN="master"
TARGET_DIR="/home/$USER/.chef/gem/ruby/3.1.0/gems/kitchen-transport-train-0.*/"
echo "Syncing with $REPO..."
cd $TARGET_DIR
curl --silent "${REPO}/compare/${MAIN}..${TARGET_BRANCH}.patch" | sudo patch -p1
echo
