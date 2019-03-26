# recipe mode
set -e
pushd "$(dirname $0)/.."

# install nix if necessary
if ! command -v nix-env; then
	curl https://nixos.org/nix/install | sh
	source $HOME/.nix-profile/etc/profile.d/nix.sh
fi

# reset environment to current toolbench, clean up old generations
nix-env -f default.nix -i --remove-all
nix-env --delete-generations 10d

# Set nix-env's environment to point to the nixpkgs we just built against.
# Depends nix-channel clobbering (replacing) when doing an --add.
# NOTE this feels like a complete hack,
# but I don't understand the subtleties of Nix tooling any better.
nix-channel --add \
	$(nix repl <nixpkgs/url.nix | sed -nE 's/"(.*)"\s*/\1/p' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g') \
	nixpkgs
	# That inscrutable little gem of a sed hack at the end?
	# ... yeah, that's because 'nix repl' outputs colorized text that
	# nix-channel doesn't accept as valid input (facepalm).
nix-channel --update

# TODO: can't GC as it removes GBs of build-time dependencies,
# which are re-downloaded when we are run again.
# Would be nice to remove now-unused packages-though!
#nix-store --gc

# clobber bashrc so it sources *only* our bash config
# ... don't go *via* homies-bashrc - source directly!
homies-bashrc >~/.bashrc
ln -sf ~/.bashrc ~/.bash_profile  # macOS
# clobber .gitconfig (see git/default.nix for details)
homies-gitconfig >~/.gitconfig

# brand new world
popd
source ~/.bashrc
