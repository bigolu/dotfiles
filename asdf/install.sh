#!/bin/sh

# Exit if a command returns a non-zero exit code
set -o errexit

# Exit if an unset variable is referenced
set -o nounset

# TODO: Get plugin dependencies in a cross-platform way, maybe with nix
# asdf-python
sudo apt --yes install build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
# asdf-nodejs
sudo apt install --yes python3 g++ make python3-pip
# asdf-java
sudo apt install --yes unzip jq

# With this, even if a command fails the script will continue
suppress_error() {
  "$@" || true
}

# suppressing error because I don't consider it an error if the plugin was already added
suppress_error asdf plugin-add java https://github.com/halcyon/asdf-java.git
suppress_error asdf plugin-add golang https://github.com/kennyp/asdf-golang.git
suppress_error asdf plugin-add rust https://github.com/code-lever/asdf-rust.git
suppress_error asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git
suppress_error asdf plugin-add direnv https://github.com/asdf-community/asdf-direnv.git
suppress_error asdf plugin-add python https://github.com/asdf-community/asdf-python.git