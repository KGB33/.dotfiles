# XDG Vars
set -xg XDG_DATA_HOME "$HOME/.local/share"
set -xg XDG_CONFIG_HOME "$HOME/.config"
set -xg XDG_STATE_HOME "$HOME/.local/state"
set -xg XDG_CACHE_HOME "$HOME/.cache"

# Docker
set -xg DOCKER_CONFIG "$XDG_CONFIG_HOME/docker"

# Go
set -xg GOPATH "$XDG_DATA_HOME/go"

# Rust
set -xg CARGO_HOME "$XDG_DATA_HOME/cargo"
set -xg RUSTUP_HOME "$XDG_DATA_HOME/rustup"

# GnuPG
set -xg GNUPGHOME "$XDG_CONFIG_HOME/gnupg/"
set -xg GPG_TTY (tty)

# Others
set -xg EDITOR nvim

set -xg NIXOS_OZONE_WL 1
