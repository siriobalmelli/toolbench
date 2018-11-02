#!/bin/bash
# this script demonstrates an apparent bug with GIT_CONFIG
# where it is used by 'git-config' but *not* by 'git'
# 2018 Sirio Balmelli
set -e

# don't break the user's config
if [[ -e ~/.gitconfig ]]; then
	echo "this script would break your existing ~/.gitconfig - please remove it and run again" >&2
	exit 1
fi

unset GIT_CONFIG
git config -l | grep -q alias.he=help && echo "alias 'he' already set" && exit 1 \
	|| echo "1. the alias 'he' is unset by default"

echo "2. write a gitconfig in a non-standard location; export to GIT_CONFIG:"
mkdir git-env-bug
cat <<EOF | tee git-env-bug/gitconfig
[alias]
  he = help
EOF
export GIT_CONFIG=git-env-bug/gitconfig
env | grep GIT_CONFIG

git config -l | grep -q alias.he=help \
	&& echo "3. git-config DID see 'he' from GIT_CONFIG"

git he \
	|| echo "4. git, however, did NOT see 'he'"

ln -s $GIT_CONFIG ~/.gitconfig
git he >/dev/null \
	&& echo "5. git DOES see 'he' if conf is linked to '~/.gitconfig'"

echo "6. this script was 'set -e': if you are reading this there may be a bug in $(git --version)"

# cleanup
rm -rf ~/.gitconfig git-env-bug
