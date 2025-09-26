#!/usr/bin/env bats


@test "ssh runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'ssh -V'
  [ "$status" -eq 0 ]
}


@test "rsync runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'rsync --help'
  [ "$status" -eq 0 ]
}


@test "kubectl runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'kubectl --help'
  [ "$status" -eq 0 ]
}


@test "terraform runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'terraform --help'
  [ "$status" -eq 0 ]
}


@test "deno runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'deno --help'
  [ "$status" -eq 0 ]
}


@test "jsonnet runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'jsonnet --help'
  [ "$status" -eq 0 ]
}


@test "jsonnet bundler runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'jb --help'
  [ "$status" -eq 0 ]
}


@test "hcloud runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'hcloud --help'
  [ "$status" -eq 0 ]
}


@test "doctl runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'doctl --help'
  [ "$status" -eq 0 ]
}


@test "helm runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'helm --help'
  [ "$status" -eq 0 ]
}


@test "biome runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'biome --version'
  [ "$status" -eq 0 ]
}


@test "butane runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'butane --version'
  [ "$status" -eq 0 ]
}


@test "ansible runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'ansible --version'
  [ "$status" -eq 0 ]
}


@test "git runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'git --help'
  [ "$status" -eq 0 ]
}


@test "unzip runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'unzip --help'
  [ "$status" -eq 0 ]
}


@test "make runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'make --help'
  [ "$status" -eq 0 ]
}


@test "virsh runs ok" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'virsh --help'
  [ "$status" -eq 0 ]
}


@test "Working directory is set to /app" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'pwd'
  [ "$status" -eq 0 ]
  [ "$output" = "/app" ]
}


@test "TOOLCHAIN_CONTAINER environment variable is set" {
  run docker run --rm --pull never --entrypoint sh $IMAGE -c \
    'echo $TOOLCHAIN_CONTAINER'
  [ "$status" -eq 0 ]
  [ "$output" = "1" ]
}
