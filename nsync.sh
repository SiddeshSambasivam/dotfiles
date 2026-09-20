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
