#!/usr/bin/env bats


@test "Built on correct arch" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'uname -m'
  [ "$status" -eq 0 ]
  if [ "$PLATFORM" = "linux/amd64" ]; then
    [ "$output" = "x86_64" ]
  elif [ "$PLATFORM" = "linux/arm/v6" ]; then
    [ "$output" = "armv7l" ]
  elif [ "$PLATFORM" = "linux/arm/v7" ]; then
    [ "$output" = "armv7l" ]
  elif [ "$PLATFORM" = "linux/arm64/v8" ]; then
    [ "$output" = "aarch64" ]
  elif [ "$PLATFORM" = "linux/386" ]; then
    [ "$output" = "x86_64" ]
  else
    [ "$output" = "$(echo $PLATFORM | cut -d '/' -f2-)" ]
  fi
}


@test "SSH is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which ssh'
  [ "$status" -eq 0 ]
}


@test "rsync is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which rsync'
  [ "$status" -eq 0 ]
}


@test "rsync runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'rsync --help'
  [ "$status" -eq 0 ]
}


@test "kubectl is installed and in PATH" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which kubectl'
  [ "$status" -eq 0 ]
  [[ "$output" == "/root/.local/bin/kubectl" ]]
}


@test "kubectl runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'kubectl version --client'
  [ "$status" -eq 0 ]
}


@test "terraform is installed and in PATH" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which terraform'
  [ "$status" -eq 0 ]
  [[ "$output" == "/root/.local/bin/terraform" ]]
}


@test "terraform runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'terraform version'
  [ "$status" -eq 0 ]
}


@test "deno is installed and in PATH" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which deno'
  [ "$status" -eq 0 ]
  [[ "$output" == "/root/.deno/bin/deno" ]]
}


@test "deno runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'deno --version'
  [ "$status" -eq 0 ]
}


@test "jsonnet is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which jsonnet'
  [ "$status" -eq 0 ]
  [[ "$output" == "/root/.local/bin/jsonnet" ]]
}


@test "jsonnet bundler (jb) is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which jb'
  [ "$status" -eq 0 ]
  [[ "$output" == "/root/.local/bin/jb" ]]
}


@test "hcloud is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which hcloud'
  [ "$status" -eq 0 ]
  [[ "$output" == "/root/.local/bin/hcloud" ]]
}


@test "hcloud runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'hcloud version'
  [ "$status" -eq 0 ]
}


@test "doctl is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which doctl'
  [ "$status" -eq 0 ]
  [[ "$output" == "/root/.local/bin/doctl" ]]
}


@test "doctl runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'doctl version'
  [ "$status" -eq 0 ]
}


@test "helm is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which helm'
  [ "$status" -eq 0 ]
  [[ "$output" == "/root/.local/bin/helm" ]]
}


@test "helm runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'helm version'
  [ "$status" -eq 0 ]
}


@test "biome is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which biome'
  [ "$status" -eq 0 ]
  [[ "$output" == "/root/.local/bin/biome" ]]
}


@test "biome runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'biome --version'
  [ "$status" -eq 0 ]
}


@test "butane is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which butane'
  [ "$status" -eq 0 ]
  [[ "$output" == "/root/.local/bin/butane" ]]
}


@test "butane runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'butane --version'
  [ "$status" -eq 0 ]
}


@test "ansible is installed via pipx" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which ansible'
  [ "$status" -eq 0 ]
  [[ "$output" == "/root/.local/bin/ansible" ]]
}


@test "ansible runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'ansible --version'
  [ "$status" -eq 0 ]
}


@test "ansible-playbook is available" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which ansible-playbook'
  [ "$status" -eq 0 ]
}


@test "ansible-galaxy is available" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which ansible-galaxy'
  [ "$status" -eq 0 ]
}


@test "python3 is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which python3'
  [ "$status" -eq 0 ]
}


@test "pipx is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which pipx'
  [ "$status" -eq 0 ]
}


@test "git is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which git'
  [ "$status" -eq 0 ]
}


@test "curl is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which curl'
  [ "$status" -eq 0 ]
}


@test "unzip is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which unzip'
  [ "$status" -eq 0 ]
}


@test "make is installed" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which make'
  [ "$status" -eq 0 ]
}


@test "libvirt-clients tools are available" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'which virsh'
  [ "$status" -eq 0 ]
}


@test "Working directory is set to /app" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'pwd'
  [ "$status" -eq 0 ]
  [ "$output" = "/app" ]
}


@test "PATH includes /root/.local/bin" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'echo $PATH | grep -o "/root/\.local/bin"'
  [ "$status" -eq 0 ]
  [ "$output" = "/root/.local/bin" ]
}


@test "DENO_INSTALL environment variable is set" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'echo $DENO_INSTALL'
  [ "$status" -eq 0 ]
  [ "$output" = "/root/.deno" ]
}


@test "TOOLCHAIN_CONTAINER environment variable is set" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'echo $TOOLCHAIN_CONTAINER'
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}


@test "TZ env var works ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 -e TZ=Asia/Tokyo \
                 --entrypoint sh $IMAGE -c \
    'date +%Z'
  [ "$status" -eq 0 ]
  [ "$output" = "JST" ]
}
