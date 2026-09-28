#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# As you. Brings flake.lock up to date and keeps your ownership.
nix flake lock

# As root. Only activation needs it.
sudo darwin-rebuild switch --flake .

# After the switch, not during it. home-manager's copyApps recreates
# ~/Applications/Home Manager Apps/WezTerm.app partway through
# activation, so anything written to it earlier is discarded.
# Also needs root: App Management blocks an unprivileged process from
# creating files inside a bundle in /Applications.
sudo ./scripts/set-app-icons.sh

# Pull the model nvim's ghost text runs on, if this Mac doesn't have it yet.
# Ollama's server comes with its app, so start the app in the background and
# wait for the server to answer. The name is read from ghost-text.lua, the
# one place it is set.
model=$(sed -n "s/^local model = '\(.*\)'$/\1/p" nvim/lua/plugins/ghost-text.lua)
open -g -a Ollama
for _ in $(seq 30); do curl -sf http://localhost:11434/api/version >/dev/null && break; sleep 1; done
ollama show "$model" >/dev/null 2>&1 || ollama pull "$model"

# nvim's Rust language server. rustup owns the toolchain (see README), and
# its rust-analyzer proxy on PATH fails until the component is added.
if command -v rustup >/dev/null; then rustup component add rust-analyzer; fi
