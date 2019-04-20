# impority.sh
# directives that do post-install, environment-altering, unclean things

# clobber bashrc so it sources *only* our bash config
# ... don't go *via* homies-bashrc - source directly!
homies-bashrc >~/.bashrc
ln -sf ~/.bashrc ~/.bash_profile  # macOS

# clobber .gitconfig (see git/default.nix for details)
homies-gitconfig >~/.gitconfig

# brand new world
source ~/.bashrc
