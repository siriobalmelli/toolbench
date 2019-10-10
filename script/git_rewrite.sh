usage()
{
cat >&2 <<EOF

usage:
$0 REPO BFG_GLOB

Use BFG Repo-Cleaner (https://rtyley.github.io/bfg-repo-cleaner/)
to remove certain files from the history of _all_ branches in a repo.

REPO	:	Git repository containing the special remotes 'tainted' and 'clean'.
BFG_GLOB :	Filename (not path) blog (eg '*.class', '*.{txt,log}'),
		see 'bfg --help' for more info.

- Fetches from 'tainted' remote.
- Creates local branches for every branch on 'tainted',
	and resets them to match 'tainted'.
- Runs BFG to rewrite history of the entire repo, including latest commits.
- Pushes all branches to 'clean' remote with '--force'.


Example usage, removing '*.o' build artifacts from a repo:

cd ~
# existing repo remains untouched
git clone --origin tainted git@github.com:iamuser/repo.git
cd repo
# new repo will have rewritten history
git remote add clean git@github.com:iamuser/repo_sane.git 

$0 ./ '*.o'
EOF
}

error() { echo "$@" >&2; usage; exit 1; }
set -e


# restore working directory and current branch afterwards
REPO="$1"
[ -d "$REPO/.git" ] || error "'$REPO' is not a valid git repo"
pushd $REPO >/dev/null
CURR="$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)"
trap "git checkout $CURR >/dev/null 2>&1 && popd >/dev/null" EXIT

# sanity: must have 'tainted' and 'clean' branches
git remote get-url tainted >/dev/null
git remote get-url clean >/dev/null

BFG_GLOB="$2"
[ -n "$BFG_GLOB" ] || error "no BFG_GLOB given"


git fetch tainted
git remote prune tainted
BRANCHES=$(git branch -a | sed -nE 's|.*remotes/tainted/(\S+).*|\1|p')


# rewrite history of all branches
git purge "$BFG_GLOB"
git reflog expire --expire=now --all && git gc --prune=now --aggressive


# force-push to 'new' all clean branches
# only push if top commit is the _same_
git fetch clean
git remote prune clean
FAIL=""
SUCCESS=""
for b in $BRANCHES; do
	# commit IDs will be different, but all other attributes should match
	TAINTED="$(git log -1 --pretty=format:'%an %ae %s %ct' tainted/$b)"
	CLEAN="$(git log -1 --pretty=format:'%an %ae %s %ct' clean/$b 2>/dev/null || true)"
	if [ -n "$CLEAN" -a "$CLEAN" != "$TAINTED" ]; then
		echo "divergent commits on branch '$b':"	>&2
		echo "tainted/$b:	$TAINTED"		>&2
		echo "clean/$b:		$CLEAN"			>&2
		FAIL="$FAIL\n$b"
	else
		git checkout tainted/$b >/dev/null 2>&1
		git push --force clean $b
		SUCCESS="$SUCCESS\n$b"
	fi
done


cat <<EOF


Done!

Branches succeeded:$SUCCESS

Branches failed (divergent):$FAIL

... don't forget the "$(realpath ./)/bfg-report*" directory,
to be inspected or deleted as necessary.
EOF
