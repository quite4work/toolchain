ARG python_ver=3.13.7
# https://hub.docker.com/_/python/
FROM python:${python_ver}-slim-trixie

ARG image_ver=1.0.0
ARG ansible_ver=9.13.0
ARG biome_ver=2.2.5
ARG butane_ver=0.25.1
ARG deno_ver=2.5.3
ARG doctl_ver=1.145.0
ARG hcloud_ver=1.53.0
ARG helm_ver=3.19.0
ARG jsonnet_ver=0.21.0
ARG jsonnet_bundler_ver=0.6.0
ARG kubectl_ver=1.34.1
ARG terraform_ver=1.13.3

# Indication that the current context is inside this toolchain container.
ENV TOOLCHAIN=1

# Prepare project directory.
RUN mkdir -p /app/
WORKDIR /app/

# Install basic tools and update certificates.
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends --no-install-suggests \
            ca-certificates \
            curl \
            git \
            libvirt-clients \
            make \
            rsync \
            ssh \
            tini \
            zip unzip \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Install Ansible and its dependencies.
ENV PIPX_BIN_DIR=/usr/local/bin/
COPY ansible/ansible-galaxy.deps.yml \
     ansible/pip.requirements.txt \
     /deps/
RUN pip install pipx \
    \
 && pipx install --include-deps ansible==${ansible_ver} \
    \
 && cat /deps/pip.requirements.txt \
    | xargs pipx inject ansible \
 && ansible-galaxy install -r /deps/ansible-galaxy.deps.yml \
    \
 && pip cache purge \
 && rm -rf /var/lib/apt/lists/* \
           /root/.local/share/man/ \
           /root/.local/state/

# Install Biome.
RUN curl -fL -o /usr/local/bin/biome \
         https://github.com/biomejs/biome/releases/download/%40biomejs%2Fbiome%40${biome_ver}/biome-linux-x64 \
 && chmod +x /usr/local/bin/biome

# Install Butane.
RUN curl -fsL -o /usr/local/bin/butane \
         https://github.com/coreos/butane/releases/download/v${butane_ver}/butane-x86_64-unknown-linux-gnu \
 && chmod +x /usr/local/bin/butane

# Install Deno.
RUN curl -fsSL https://deno.land/install.sh \
    | DENO_INSTALL=/usr/local deno_version=v${deno_ver} sh

# Install DigitalOcean CLI.
RUN curl -fsL https://github.com/digitalocean/doctl/releases/download/v${doctl_ver}/doctl-${doctl_ver}-linux-amd64.tar.gz \
    | tar xz -C /usr/local/bin/ \
          doctl

# Install HCloud CLI.
RUN curl -fsL https://github.com/hetznercloud/cli/releases/download/v${hcloud_ver}/hcloud-linux-amd64.tar.gz \
    | tar xz -C /usr/local/bin/ \
          hcloud

# Install Helm.
RUN curl -fsL https://get.helm.sh/helm-v${helm_ver}-linux-amd64.tar.gz \
    | tar xz --strip-components=1 -C /usr/local/bin/ \
          linux-amd64/helm

# Install Jsonnet.
RUN curl -fsL https://github.com/google/go-jsonnet/releases/download/v${jsonnet_ver}/go-jsonnet_Linux_x86_64.tar.gz \
    | tar xz -C /usr/local/bin/ \
          jsonnet jsonnet-deps jsonnet-lint jsonnetfmt

# Install Jsonnet Bundler.
RUN curl -fsL -o /usr/local/bin/jb \
    https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v${jsonnet_bundler_ver}/jb-linux-amd64 \
 && chmod +x /usr/local/bin/jb

# Install Kubernetes CLI.
RUN curl -fL -o /usr/local/bin/kubectl \
         https://dl.k8s.io/release/v${kubectl_ver}/bin/linux/amd64/kubectl \
 && chmod +x /usr/local/bin/kubectl

# Install Terraform.
RUN apt-get update \
 && toolDeps="libarchive-tools" \
 && apt-get install -y --no-install-recommends --no-install-suggests \
            $toolDeps \
    \
 && curl -fsL https://releases.hashicorp.com/terraform/${terraform_ver}/terraform_${terraform_ver}_linux_amd64.zip \
    | bsdtar -C /usr/local/bin/ -xf - terraform \
 && chmod +x /usr/local/bin/terraform \
    \
 && apt-get purge -y --auto-remove \
                      -o APT::AutoRemove::RecommendsImportant=false \
            $toolDeps \
 && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/tini", "--"]
