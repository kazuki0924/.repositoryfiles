FROM ubuntu:focal-20220801

# disable interactive dialogue
ENV DEBIAN_FRONTEND noninteractive

# hadolint ignore=DL3008
RUN set -ex \
  && apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y \
  --no-install-recommends \
  ca-certificates \
  bash \
  cargo \
  curl \
  fd-find \
  fzf \
  git \
  jq \
  make \
  postgresql \
  postgresql-contrib \
  ripgrep \
  vim \
  wget \
  zip \
  && rm -rf /var/lib/apt/lists/*

# fd
RUN ln -s "$(which fdfind)" /usr/local/bin/fd

# cargo
RUN echo "export PATH=\"${PATH}:${HOME}/.cargo/bin\"" >> ~/.bashrc

# sd
# hadolint ignore=DL3059
RUN cargo install sd

# sops
ENV SOPS_VERSION v3.7.3
RUN wget --progress=dot:giga -O /usr/local/bin/sops \
  "https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.$(dpkg --print-architecture)" && \
  chmod +x /usr/local/bin/sops

# yq
ENV YQ_VERSION v4.27.2
RUN wget --progress=dot:giga -O /usr/bin/yq \
  "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_$(dpkg --print-architecture).tar.gz" && \
  chmod +x /usr/bin/yq

RUN useradd -ms /bin/bash docker
USER docker
