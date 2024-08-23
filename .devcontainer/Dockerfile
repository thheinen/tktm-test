FROM chef/chefworkstation:24.6.1066
# 24.8.1068 is the internal build pre habitat_config

ARG DIRENV_VERSION=2.32.3

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG CHEF_LICENSE=accept-silent

# System base with common tooling
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install --no-install-recommends --yes \
        lsb-release vim sudo curl wget apt-utils dialog apt-transport-https ca-certificates unzip software-properties-common \
        yamllint python3-pip git less jq ssh patchutils \
    && apt-get autoremove --yes \
    && apt-get clean --yes \
    && rm -rf /var/lib/apt/lists/* \
    #
    && curl --location-trusted "https://github.com/direnv/direnv/releases/download/v${DIRENV_VERSION}/direnv.linux-amd64" --output /usr/local/bin/direnv --silent \
    && chmod +x /usr/local/bin/direnv

# Apply patches to original Chef tools
COPY import-patches.sh /tmp
RUN /bin/bash /tmp/import-patches.sh > /opt/chef-workstation/patches.info

# User configuration
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && echo 'eval "$(direnv hook bash)"' >> /home/$USERNAME/.bashrc
