#!/usr/bin/env bash

# Copyright 2018 Instrumentisto Team
#
# The MIT License (MIT)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# initOS discovers the operating system for this system.
initOS() {
  OS=$(echo `uname` | tr '[:upper:]' '[:lower:]')
  case "$OS" in
    # Minimalist GNU for Windows
    mingw*) OS='windows';;
  esac
}

# runAsRoot runs the given command as root (detects if we are root already).
runAsRoot() {
  local CMD="$*"
  if [ $EUID -ne 0 ]; then
    CMD="sudo $CMD"
  fi
  $CMD
}

# upgradeHomebrewPackages upgrades required Homebrew packages to latest version.
upgradeHomebrewPackages() {
  brew update
  brew tap caskroom/cask
  brew cask outdated minikube || brew cask reinstall minikube
  for pkg in kubernetes-cli kubernetes-helm; do
    if [ ! $(brew list | grep $pkg) ]; then
      brew install $pkg
    else
      brew outdated $pkg || brew upgrade $pkg --cleanup
    fi
  done
}

# installHyperkitDriver installs Hyperkit VM driver if it's not installed yet.
installHyperkitDriver() {
  if [ -z $(which docker-machine-driver-hyperkit) ]; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/docker-machine-driver-hyperkit
    chmod +x docker-machine-driver-hyperkit
    runAsRoot mv docker-machine-driver-hyperkit /usr/local/bin/
    runAsRoot chown root:wheel /usr/local/bin/docker-machine-driver-hyperkit
    runAsRoot chmod u+s /usr/local/bin/docker-machine-driver-hyperkit
  fi
}




set -e
initOS


MINIKUBE_K8S_VER=v1.9.2
MINIKUBE_BOOTSTRAPPER=kubeadm
MINIKUBE_VM_DRIVER=virtualbox

case "$OS" in
darwin)
  # TODO: Hyperkit driver is still not stable enough. Use with later releases.
  #MINIKUBE_VM_DRIVER=hyperkit
  ;;
esac


case "$OS" in
darwin)
  upgradeHomebrewPackages
  # TODO: Hyperkit driver is still not stable enough. Use with later releases.
  #installHyperkitDriver
  ;;
esac

(minikube status | grep 'minikube:' | grep 'Running') || \
minikube start --bootstrapper=$MINIKUBE_BOOTSTRAPPER \
               --kubernetes-version=$MINIKUBE_K8S_VER \
               --vm-driver=$MINIKUBE_VM_DRIVER \
               --disk-size=10g

(minikube addons list | grep ingress | grep enabled) || \
minikube addons enable ingress

eval $(minikube docker-env)

sleep 10

minikube dashboard
