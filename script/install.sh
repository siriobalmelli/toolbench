# recipe mode
set -e
pushd "$(dirname $0)/.."

# install nix if necessary
if ! command -v nix-env; then
	curl https://nixos.org/nix/install | sh
	source $HOME/.nix-profile/etc/profile.d/nix.sh
fi

# keep nix-env packages in lockstep with this repo
nix-channel --update
nix-env -qaP >nix_env_avail.txt  # easy grep of what packages are available

script/update-src.sh nixpkgs
nix-env -f default.nix -i --remove-all
# don't GC ... it removes GBs of things which are
# re-downloaded if we are run again
#nix-store --gc

# clobber bashrc so it sources *only* our bash config
# ... don't go *via* homies-bashrc - source directly!
echo "$(homies-bashrc)" >~/.bashrc

# brand new world
popd
source ~/.bashrc
