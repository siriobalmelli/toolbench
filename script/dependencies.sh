# get references for default.nix
REFS=./default.nix.refs.txt
rm -f $REF
for a in $(nix-instantiate ./default.nix); do
cat >>$REFS <<EOF
$a
$(nix-store -q --references "${a%%\!*}" >>$REFS)

EOF
done

# dedupe them to get full tree of derivations
TREE=./default.nix.tree.txt
sort -u <$REFS >$TREE
