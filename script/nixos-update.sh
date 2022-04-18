set -e
# system
sudo nix-collect-garbage --delete-older-than 30d
sudo nixos-rebuild --upgrade-all switch
# user
nix-channel --update
nix-env --delete-generations 30d
# nix-env --upgrade  # causes machine to hang forever ?!
