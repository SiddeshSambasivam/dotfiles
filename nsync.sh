#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
nix flake lock
exec sudo darwin-rebuild switch --flake .
