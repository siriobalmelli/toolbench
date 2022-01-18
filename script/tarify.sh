# simplify tar and gpg operations on files and directories
set -e

FUNC=
SOURCE=
DEST=
export XZ_OPT="-Csha256 -9 -T0"

# subprocesses inherit nice value, set it once here
renice -n 10 -p $$


tarify()
{
	OUT="$DEST/$(basename "$SOURCE").tar.xz"
	tar --totals --sort=name --xz -c -f "$OUT" "$SOURCE"
	rm -rfv "$SOURCE"
}

untarify()
{
	tar --totals --xz -x -f "$SOURCE" -C "$DEST"
	rm -fv "$SOURCE"
}

gpgify()
{
	OUT="$DEST/$(basename "$SOURCE").tar.xz.gpg"
	tar --totals --sort=name --xz -c "$SOURCE" -f - | gpg --encrypt -o "$OUT"
	rm -rfv "$SOURCE"
}

ungpgify()
{
	gpg --decrypt "$SOURCE" | tar --totals --xz -x -f - -C "$DEST"
	rm -fv "$SOURCE"
}

##
# generic unpack, chooses which function to use under the hood
##
unpack()
{
	# strip longest match of '*.' from front of string
	case ${SOURCE##*.} in
		gpg) ungpgify ;;
		xz) untarify ;;
		*)
			echo "'$SOURCE' does not have a '.gpg' or '.xz' extension" >&2
			exit 1
			;;
	esac
}


##
# handle/sanitize arguments
##
usage()
{
cat >&2 <<EOF
$0: SOURCE [DESTINATION_DIR] -(t|g|u)

	-t : tarify
	-g : gpgify
	-u : un(tar|gpg)ify
EOF
exit 1
}

while [ -n "$1" ]; do
	case "$1" in
		-t)	FUNC=tarify	;;
		-g)	FUNC=gpgify	;;
		-u)	FUNC=unpack	;;
		-h|--help|-?)	usage	;;
		*)
			if [ -z "$SOURCE" ]; then
				SOURCE="$1"
			elif [ -z "$DEST" ]; then
				DEST="$1"
			else
				usage
			fi
			;;
	esac
	shift
done

if [ -z "$DEST" ]; then
	DEST="."
elif ! [ -d "$DEST" ]; then
	echo "'$DEST' is not a valid destination dir"
	exit 1
fi

[ -z "$FUNC" ] && usage
$FUNC
