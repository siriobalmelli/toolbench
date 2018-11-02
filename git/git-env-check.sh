#!/bin/bash
# this script demonstrates that the GIT_CONFIG is used by 'git-config'
# but *not* by 'git' itself.
# 2018 Sirio Balmelli

cleanup()
{
rm -rf ~/.gitconfig git-env-check
}

fail()
{
	echo "$*" >&2
	cleanup
	exit 1
}

# don't break the user's config
if [[ -e ~/.gitconfig ]]; then
	# don't fail, deleting ~/.gitconfig, for obvious reasons
	echo "this script would break your existing ~/.gitconfig - please remove it and run again" >&2
	exit 1
fi

unset GIT_CONFIG
git config -l | grep -q alias.he=help \
	&& fail "alias 'he' already set, can't use it for this test" \
	|| echo "1. the alias 'he' is unset by default"

echo "2. write a gitconfig in a non-standard location; export to GIT_CONFIG:"
mkdir git-env-check
cat <<EOF | tee git-env-check/gitconfig
[alias]
  he = help
EOF
export GIT_CONFIG=$(realpath git-env-check/gitconfig)
env | grep GIT_CONFIG

git config -l | grep -q alias.he=help \
	|| fail "unexpected: git-config doesn't see GIT_CONFIG" \
	&& echo "3. git-config DID see 'he' from GIT_CONFIG"

git he \
	&& fail "git does see GIT_CONFIG: please ignore this report" \
	|| echo "4. git, however, did NOT see 'he'"

ln -s $GIT_CONFIG ~/.gitconfig
git he >/dev/null \
	|| fail "unexpected: git also ignores ~/.gitconfig" \
	&& echo "5. git DOES see 'he' if conf is linked to '~/.gitconfig'"

echo "6. this was $(git --version)"
cleanup
