FROM ghcr.io/actions/actions-runner:2.321.0

USER root

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGET_TOOLSET_REV=45226c1116cdb863fcc3804d00c9aaaedb270b52

COPY install_pkgs.sh toolset-2204.json.sha256sum /home/runner

RUN curl -LO https://github.com/actions/runner-images/raw/${TARGET_TOOLSET_REV}/images/ubuntu/toolsets/toolset-2204.json && \
    sha256sum --check < toolset-2204.json.sha256sum

RUN curl -L -o nix-installer https://install.determinate.systems/nix/nix-installer-x86_64-linux && \
    chmod +x nix-installer

RUN apt-get update -y

RUN ./install_pkgs.sh toolset-2204.json

RUN ./nix-installer install --no-confirm
