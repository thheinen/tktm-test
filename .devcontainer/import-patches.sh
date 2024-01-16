#!/bin/bash

if [[ -f '/opt/chef-workstation/APPLYING_PATCHES' ]]; then
  echo "ERROR: Incomplete apply of upstream patches detected. Rebuild container and apply again"
  exit 1
fi

sudo touch '/opt/chef-workstation/APPLYING_PATCHES'

TARGET_BRANCH="thheinen/target-mode"

REPO="https://github.com/thheinen/test-kitchen"
MAIN="master"
TARGET_DIR="/opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/test-kitchen-*/"
echo "Syncing with $REPO..."
cd $TARGET_DIR
curl --silent "${REPO}/compare/${MAIN}..${TARGET_BRANCH}.patch" | sudo patch -p1
echo

REPO="https://github.com/thheinen/train"
MAIN="master"
TARGET_DIR="/opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/train-core-*/"
echo "Syncing with $REPO..."
cd $TARGET_DIR
curl --silent "${REPO}/compare/${MAIN}..${TARGET_BRANCH}.patch" | sudo patch -p1
echo

REPO="https://github.com/tecracer-chef/kitchen-transport-train"
MAIN="master"
TARGET_DIR="/home/$USER/.chef/gem/ruby/3.1.0/gems/kitchen-transport-train-0.*/"
echo "Syncing with $REPO..."
cd $TARGET_DIR
curl --silent "${REPO}/compare/${MAIN}..${TARGET_BRANCH}.patch" | sudo patch -p1
echo

REPO="https://github.com/thheinen/mixlib-shellout"
MAIN="main"
TARGET_DIR="/opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/mixlib-shellout-*/"
echo "Syncing with $REPO..."
cd $TARGET_DIR
curl --silent "${REPO}/compare/${MAIN}..${TARGET_BRANCH}.patch" | sudo patch -p1
echo

REPO="https://github.com/thheinen/ohai"
MAIN="main"
TARGET_DIR="/opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/ohai-*/"
echo "Syncing with $REPO..."
cd $TARGET_DIR
curl --silent "${REPO}/compare/${MAIN}..${TARGET_BRANCH}.patch" | sudo patch -p1
echo

REPO="https://github.com/thheinen/chef"
MAIN="main"
echo "Syncing with $REPO..."

# Monorepo, yay!
TARGET_DIR="/opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/chef-1*/"
cd $TARGET_DIR
curl --silent "${REPO}/compare/${MAIN}..${TARGET_BRANCH}.patch" | filterdiff -x "*/chef-config/*" -x "*/chef-utils/*" | sudo patch -p1
TARGET_DIR="/opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/chef-config-*/"
cd $TARGET_DIR
curl --silent "${REPO}/compare/${MAIN}..${TARGET_BRANCH}.patch" | filterdiff -i "*/chef-config/*" | sudo patch -p2
TARGET_DIR="/opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/chef-utils-*/"
cd $TARGET_DIR
curl --silent "${REPO}/compare/${MAIN}..${TARGET_BRANCH}.patch" | filterdiff -i "*/chef-utils/*" | sudo patch -p2

rm touch '/opt/chef-workstation/APPLYING_PATCHES'
sudo touch '/opt/chef-workstation/APPLIED_PATCHES'