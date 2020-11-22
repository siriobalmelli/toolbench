#!/bin/bash
#	install.sh
# install (pin) a top-level Nix derivation as the Nix environment
# (c) 2018 Sirio Balmelli

# recipe mode
set -e

[[ "$1" ]] && DERIVATION="$1" || DERIVATION="$(dirname "$0")/../default.nix"

# install nix if necessary
if ! command -v nix-env; then
	curl https://nixos.org/nix/install | sh
	# shellcheck source=/Users/sirio/.nix-profile/etc/profile.d/nix.sh
	source "$HOME/.nix-profile/etc/profile.d/nix.sh"
	nix-env -iA "nixpkgs.git"  # some CentOs boxes have git 1.8, no -C flag
fi

# make sure there is a Git
command -v git || nix-env -iA "nixpkgs.git"

# reset environment to current toolbench, clean up old generations
nix-env --cores 0 -j auto -f "$DERIVATION" -i --remove-all --tarball-ttl 0
nix-env --delete-generations 10d

# Set nix-env's environment to point to the nixpkgs we just built against.
# Depends nix-channel clobbering (replacing) when doing an --add.
# NOTE this duplicates the fetchGit in default.nix,
# but I don't (yet) understand the subtleties of Nix tooling any better.
# TODO: this is not generic (e.g. for private tools)
nix-channel --add \
	https://github.com/siriobalmelli-foss/nixpkgs/archive/master.tar.gz \
	nixpkgs
nix-channel --update

# TODO: can't GC as it removes GBs of build-time dependencies,
# which are re-downloaded when we are run again.
# Would be nice to remove now-unused packages-though!
#nix-store --gc

# execute post-install scripting
[[ -s "$(dirname "$DERIVATION")/impurity.sh" ]] && \
	( cd "$(dirname "$DERIVATION")" && ./impurity.sh )
