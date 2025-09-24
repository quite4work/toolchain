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


@test "ssh runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'ssh -V'
  [ "$status" -eq 0 ]
}


@test "rsync runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'rsync --help'
  [ "$status" -eq 0 ]
}


@test "kubectl runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'kubectl --help'
  [ "$status" -eq 0 ]
}


@test "terraform runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'terraform --help'
  [ "$status" -eq 0 ]
}


@test "deno runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'deno --help'
  [ "$status" -eq 0 ]
}


@test "jsonnet runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'jsonnet --help'
  [ "$status" -eq 0 ]
}


@test "jsonnet bundler runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'jb --help'
  [ "$status" -eq 0 ]
}


@test "hcloud runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'hcloud --help'
  [ "$status" -eq 0 ]
}


@test "doctl runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'doctl --help'
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


@test "ansible runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'ansible --version'
  [ "$status" -eq 0 ]
}


@test "git runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'git --help'
  [ "$status" -eq 0 ]
}


@test "unzip runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'unzip --help'
  [ "$status" -eq 0 ]
}


@test "make runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'make --help'
  [ "$status" -eq 0 ]
}


@test "virsh runs ok" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'virsh --help'
  [ "$status" -eq 0 ]
}


@test "Working directory is set to /app" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'pwd'
  [ "$status" -eq 0 ]
  [ "$output" = "/app" ]
}


@test "TOOLCHAIN_CONTAINER environment variable is set" {
  run docker run --rm --pull never --platform $PLATFORM \
                 --entrypoint sh $IMAGE -c \
    'echo $TOOLCHAIN_CONTAINER'
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}
