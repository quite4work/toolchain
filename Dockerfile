FROM debian:12.10

ENV TOOLCHAIN_CONTAINER=1

ARG ANSIBLE_VER="9.13.0"
ARG BIOME_VER="2.2.4"
ARG DENO_VER="2.5.1"
ARG DOCTL_VER="1.142.0"
ARG HCLOUD_VER="1.52.0"
ARG HELM_VER="3.19.0"
ARG JSONNET_BUNDLER_VER="0.6.0"
ARG JSONET_VER="0.21.0"
ARG KUBECTL_VER="1.34.1"
ARG TERRAFORM_VER="1.11.1"
ARG BUTANE_VER="0.25.0"

# Add "/root/.local/bin" path for pipx and other.
ENV PATH="$PATH:/root/.local/bin"

ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

RUN mkdir -p /app/ /root/.local/bin/
WORKDIR /app

COPY requirements.txt ansible-galaxy.deps.yml /deps/

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends --no-install-suggests \
            ca-certificates curl unzip libarchive-tools git python3 ssh pipx \
            rsync make libvirt-clients \
 && rm -rf /var/lib/apt/lists/* \
 && update-ca-certificates \
 && echo "Installing kubectl..." \
 && curl -sLO "https://dl.k8s.io/v$KUBECTL_VER/bin/linux/amd64/kubectl" \
         --output-dir /root/.local/bin/ \
 && chmod +x /root/.local/bin/kubectl \
 && echo "Installing Terraform..." \
 && curl -sL https://releases.hashicorp.com/terraform/$TERRAFORM_VER/terraform_${TERRAFORM_VER}_linux_amd64.zip \
    | bsdtar -C /root/.local/bin/ -xf - terraform \
 && chmod +x /root/.local/bin/terraform \
 && echo "Installing Deno..." \
 && curl -fsSL https://deno.land/install.sh | sh \
 && deno upgrade $DENO_VER \
 && echo "Installing Jsonnet..." \
 && curl -sL https://github.com/google/go-jsonnet/releases/download/v$JSONET_VER/go-jsonnet_Linux_x86_64.tar.gz \
    | tar xz -C /root/.local/bin/ jsonnet jsonnet-deps jsonnet-lint jsonnetfmt \
 && echo "Installing Jsonnet Bundler..." \
 && curl -sL https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v$JSONNET_BUNDLER_VER/jb-linux-amd64 \
         -o /root/.local/bin/jb \
 && chmod +x /root/.local/bin/jb \
 && echo "Installing hcloud..." \
 && curl -sL https://github.com/hetznercloud/cli/releases/download/v$HCLOUD_VER/hcloud-linux-amd64.tar.gz \
    | tar xz -C /root/.local/bin/ hcloud \
 && echo "Installing doctl..." \
 && curl -sL https://github.com/digitalocean/doctl/releases/download/v$DOCTL_VER/doctl-${DOCTL_VER}-linux-amd64.tar.gz \
    | tar xz -C /root/.local/bin/ doctl \
 && echo "Installing Helm..." \
 && curl -sL https://get.helm.sh/helm-v{$HELM_VER}-linux-amd64.tar.gz \
    | tar xz --strip-components=1 -C /root/.local/bin/ linux-amd64/helm \
 && echo "Installing Biome..." \
 && curl -sL https://github.com/biomejs/biome/releases/download/%40biomejs%2Fbiome%40$BIOME_VER/biome-linux-x64 \
         -o /root/.local/bin/biome \
 && chmod +x /root/.local/bin/biome \
 && echo "Installing Butane..." \
 && curl -sL https://github.com/coreos/butane/releases/download/v$BUTANE_VER/butane-x86_64-unknown-linux-gnu \
         -o /root/.local/bin/butane \
 && chmod +x /root/.local/bin/butane \
 && echo "Installing Ansible..." \
 && pipx install --include-deps ansible==$ANSIBLE_VER \
 && cat /deps/requirements.txt | xargs pipx inject ansible \
 && ansible-galaxy install -r /deps/ansible-galaxy.deps.yml
