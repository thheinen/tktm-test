#!/bin/bash

if [[ -f '/opt/chef-workstation/APPLYING_PATCHES' ]]; then
  echo "ERROR: Incomplete apply of upstream patches detected. Rebuild container and apply again"
  exit 1
fi

sudo touch '/opt/chef-workstation/APPLYING_PATCHES'

REPO="https://github.com/test-kitchen/test-kitchen"
echo "Syncing with $REPO..."

GEM="$(echo "$REPO" | cut -d/ -f5)"
TARGET_REPO="thheinen:${GEM}:thheinen/target-mode"
SOURCE_VERSION="$(gem info -leq "$GEM" | head -n1 | cut -d\( -f2 | cut -d\) -f1)"
TK_VERSION=$SOURCE_VERSION
TARGET_DIR="$(gem info -leq chef | grep "Installed at" | cut -d: -f2 | cut -b2-)/gems/${GEM}-${SOURCE_VERSION}"
URL="${REPO}/compare/v${SOURCE_VERSION}..${TARGET_REPO}.patch"

cd $TARGET_DIR
curl --silent "$URL" | filterdiff -i "*lib/**/*" | sudo patch -p1
echo


REPO="https://github.com/inspec/train"
echo "Syncing with $REPO..."

GEM="$(echo "$REPO" | cut -d/ -f5)"
TARGET_REPO="thheinen:${GEM}:thheinen/target-mode"
SOURCE_VERSION="$(gem info -leq "$GEM" | head -n1 | cut -d\( -f2 | cut -d\) -f1)"
TARGET_DIR="$(gem info -leq chef | grep "Installed at" | cut -d: -f2 | cut -b2-)/gems/${GEM}-core-${SOURCE_VERSION}" #!
URL="${REPO}/compare/v${SOURCE_VERSION}..${TARGET_REPO}.patch"

cd $TARGET_DIR
curl --silent "${URL}" | filterdiff -i "*lib/**/*" -x "*version.rb" | sudo patch -p1
echo


# merged
#REPO="https://github.com/tecracer-chef/kitchen-transport-train"
#MAIN="master"
#TARGET_DIR="/home/$USER/.chef/gem/ruby/3.1.0/gems/kitchen-transport-train-0.*/"
#echo "Syncing with $REPO..."
#cd $TARGET_DIR
#curl --silent "${REPO}/compare/${MAIN}..${TARGET_BRANCH}.patch" | sudo patch -p1
#echo


REPO="https://github.com/chef/mixlib-shellout"
echo "Syncing with $REPO..."

GEM="$(echo "$REPO" | cut -d/ -f5)"
TARGET_REPO="thheinen:${GEM}:thheinen/target-mode"
SOURCE_VERSION="$(gem info -leq "$GEM" | head -n1 | cut -d\( -f2 | cut -d\) -f1)"
TARGET_DIR="$(gem info -leq chef | grep "Installed at" | cut -d: -f2 | cut -b2-)/gems/${GEM}-${SOURCE_VERSION}"
URL="${REPO}/compare/v${SOURCE_VERSION}..${TARGET_REPO}.patch"

cd $TARGET_DIR
curl --silent "$URL" | filterdiff -i "*lib/**/*" -x "*version.rb" | sudo patch -p1
echo
sudo wget -O lib/mixlib/shellout/helper.rb https://raw.githubusercontent.com/thheinen/mixlib-shellout/thheinen/target-mode-multiline-fix/lib/mixlib/shellout/helper.rb --quiet
echo

REPO="https://github.com/chef/ohai"
echo "Syncing with $REPO..."

GEM="$(echo "$REPO" | cut -d/ -f5)"
TARGET_REPO="thheinen:${GEM}:thheinen/target-mode"
SOURCE_VERSION="$(gem info -leq "$GEM" | head -n1 | cut -d\( -f2 | cut -d\) -f1)"
TARGET_DIR="$(gem info -leq chef | grep "Installed at" | cut -d: -f2 | cut -b2-)/gems/${GEM}-${SOURCE_VERSION}"
URL="${REPO}/compare/v${SOURCE_VERSION}..${TARGET_REPO}.patch"

cd $TARGET_DIR
curl --silent "${URL}" | filterdiff -i "*lib/**/*" -x "*version.rb" | sudo patch -p1
echo


REPO="https://github.com/chef/cheffish"
echo "Syncing with $REPO..."

GEM="$(echo "$REPO" | cut -d/ -f5)"
TARGET_REPO="thheinen:${GEM}:main" #!!!
SOURCE_VERSION="$(gem info -leq "$GEM" | head -n1 | cut -d\( -f2 | cut -d\) -f1)"
TARGET_DIR="$(gem info -leq chef | grep "Installed at" | cut -d: -f2 | cut -b2-)/gems/${GEM}-${SOURCE_VERSION}"
URL="${REPO}/compare/v${SOURCE_VERSION}..${TARGET_REPO}.patch"

cd $TARGET_DIR
curl --silent "${URL}" | filterdiff -i "*lib/**/*" -x "*version.rb" | sudo patch -p1
echo

REPO="https://github.com/chef/chef"
echo "Syncing with $REPO..."

GEM="$(echo "$REPO" | cut -d/ -f5)"
TARGET_REPO="thheinen:${GEM}:thheinen/target-mode"
SOURCE_VERSION="$(gem info -leq "$GEM" | head -n1 | cut -d\( -f2 | cut -d\) -f1)"
TARGET_DIR="$(gem info -leq chef | grep "Installed at" | cut -d: -f2 | cut -b2-)/gems/${GEM}-${SOURCE_VERSION}"
URL="${REPO}/compare/v${SOURCE_VERSION}..${TARGET_REPO}.patch"
CHEF_VERSION=$SOURCE_VERSION

# Monorepo, yay!
cd $TARGET_DIR
curl --silent "$URL" | filterdiff -i "*/lib/chef/*" -x "*knife*" | sudo patch -p1
TARGET_DIR="/opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/chef-config-*/"
cd $TARGET_DIR
curl --silent "$URL" | filterdiff -i "*/chef-config/lib/**/*" | sudo patch -p2
TARGET_DIR="/opt/chef-workstation/embedded/lib/ruby/gems/3*/gems/chef-utils-*/"
cd $TARGET_DIR
curl --silent "$URL" | filterdiff -i "*/chef-utils/lib/**/*" | sudo patch -p2

# Adjust TK version dependency
sudo sed -i "s/19.0.0/$CHEF_VERSION/" /opt/chef-workstation/embedded/lib/ruby/gems/3.1.0/gems/test-kitchen-${TK_VERSION}/lib/kitchen/provisioner/chef_target.rb

sudo rm /opt/chef-workstation/APPLYING_PATCHES
sudo touch /opt/chef-workstation/APPLIED_PATCHES
