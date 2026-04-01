#!/usr/bin/env bash

set -e

sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5

sudo nix-collect-garbage -d

nix-collect-garbage -d

nix store optimise

echo "OK"
