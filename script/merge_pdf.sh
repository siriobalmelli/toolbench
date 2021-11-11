# merge an array of PDFs
# (c) 2018 Sirio Balmelli

# usage
# $0 : program name
usage()
{
echo "$0 [-v] PDF[,PDF...]

Merges all PDF files into PDF[0] (the filename given).
Deletes all other input files.
Forces .pdf extension to output file.
" >&2
}

# verbosity
V=""
if [[ "$1" == "-v" ]]; then
    V="-v"
    shift
fi

# sanity
if ! which gs >/dev/null; then
    echo "missing GhostScript 'gs' - please install TexLive or similar" >&2
    exit 1
fi
for f in "$@"; do
    if [[ ! -e "$f" ]]; then
        echo "'$f' does not exist" >&2
        exit 1
    fi
done
if (( $# < 1 )); then
    usage
    exit 1
fi

# force .pdf extension on output filename
OUT="${1%.pdf}.pdf"

# one file: rename only
if (( $# == 1)); then
    mv -v "$1" "$OUT"

# multiple files: merge
else
    # unique temp file name: should be multithread safe
    TEMP=".temp_$(date +%s)_$(xxd -p -l 10 </dev/urandom)_$RANDOM"

    if ! gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="$TEMP" "$@"
    then
        rm -f "$TEMP"
        exit 1
    else
        rm -f $V "$@"
    fi
    mv -v "$TEMP" "$OUT"
    rm -f "$TEMP"
fi
