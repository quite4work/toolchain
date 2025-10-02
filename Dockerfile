ARG debian_ver=13.1
FROM debian:${debian_ver}

ENV TOOLCHAIN_CONTAINER=1

ARG image_ver=1.0.0-r0
ARG ansible_ver=9.13.0
ARG biome_ver=2.2.5
ARG deno_ver=2.5.2
ARG doctl_ver=1.145.0
ARG hcloud_ver=1.53.0
ARG helm_ver=3.19.0
ARG jsonnet_bundler_ver=0.6.0
ARG jsonnet_ver=0.21.0
ARG kubectl_ver=1.34.0
ARG terraform_ver=1.13.3
ARG butane_ver=0.25.1

# Add "/root/.local/bin" path for pipx and other.
ENV PATH="$PATH:/root/.local/bin"

ENV DENO_INSTALL=/root/.deno
ENV PATH="$DENO_INSTALL/bin:$PATH"

RUN mkdir -p /app/ /root/.local/bin/
WORKDIR /app

COPY ansible/requirements.txt ansible/ansible-galaxy.deps.yml /deps/

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends --no-install-suggests \
            ca-certificates curl unzip libarchive-tools git python3 ssh pipx \
            rsync make libvirt-clients \
 && rm -rf /var/lib/apt/lists/* \
 && update-ca-certificates \
 && echo "Installing kubectl..." \
 && curl -sLO "https://dl.k8s.io/v${kubectl_ver}/bin/linux/amd64/kubectl" \
         --output-dir /root/.local/bin/ \
 && chmod +x /root/.local/bin/kubectl \
 && echo "Installing Terraform..." \
 && curl -sL https://releases.hashicorp.com/terraform/${terraform_ver}/terraform_${terraform_ver}_linux_amd64.zip \
    | bsdtar -C /root/.local/bin/ -xf - terraform \
 && chmod +x /root/.local/bin/terraform \
 && echo "Installing Deno..." \
 && curl -fsSL https://deno.land/install.sh | sh \
 && deno upgrade ${deno_ver} \
 && echo "Installing Jsonnet..." \
 && curl -sL https://github.com/google/go-jsonnet/releases/download/v${jsonnet_ver}/go-jsonnet_Linux_x86_64.tar.gz \
    | tar xz -C /root/.local/bin/ jsonnet jsonnet-deps jsonnet-lint jsonnetfmt \
 && echo "Installing Jsonnet Bundler..." \
 && curl -sL https://github.com/jsonnet-bundler/jsonnet-bundler/releases/download/v${jsonnet_bundler_ver}/jb-linux-amd64 \
         -o /root/.local/bin/jb \
 && chmod +x /root/.local/bin/jb \
 && echo "Installing hcloud..." \
 && curl -sL https://github.com/hetznercloud/cli/releases/download/v${hcloud_ver}/hcloud-linux-amd64.tar.gz \
    | tar xz -C /root/.local/bin/ hcloud \
 && echo "Installing doctl..." \
 && curl -sL https://github.com/digitalocean/doctl/releases/download/v${doctl_ver}/doctl-${doctl_ver}-linux-amd64.tar.gz \
    | tar xz -C /root/.local/bin/ doctl \
 && echo "Installing Helm..." \
 && curl -sL https://get.helm.sh/helm-v{${helm_ver}}-linux-amd64.tar.gz \
    | tar xz --strip-components=1 -C /root/.local/bin/ linux-amd64/helm \
 && echo "Installing Biome..." \
 && curl -sL https://github.com/biomejs/biome/releases/download/%40biomejs%2Fbiome%40${biome_ver}/biome-linux-x64 \
         -o /root/.local/bin/biome \
 && chmod +x /root/.local/bin/biome \
 && echo "Installing Butane..." \
 && curl -sL https://github.com/coreos/butane/releases/download/v${butane_ver}/butane-x86_64-unknown-linux-gnu \
         -o /root/.local/bin/butane \
 && chmod +x /root/.local/bin/butane \
 && echo "Installing Ansible..." \
 && pipx install --include-deps ansible==${ansible_ver} \
 && cat /deps/requirements.txt | xargs pipx inject ansible \
 && ansible-galaxy install -r /deps/ansible-galaxy.deps.yml
