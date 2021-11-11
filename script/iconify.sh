# convert the icon $0.png to $0.icns
set -e
if ! [[ "$1" =~ \.png$ ]]; then
	echo "The file '$1' is not a .png; aborting" >&2
	exit 1
fi

ISET="${1%%.png}.iconset"
rm -rf "$ISET"
mkdir "$ISET"

sips -z 16 16     "$1" --out "$ISET/icon_16x16.png"
sips -z 32 32     "$1" --out "$ISET/icon_16x16@2x.png"
sips -z 32 32     "$1" --out "$ISET/icon_32x32.png"
sips -z 64 64     "$1" --out "$ISET/icon_32x32@2x.png"
sips -z 128 128   "$1" --out "$ISET/icon_128x128.png"
sips -z 256 256   "$1" --out "$ISET/icon_128x128@2x.png"
sips -z 256 256   "$1" --out "$ISET/icon_256x256.png"
sips -z 512 512   "$1" --out "$ISET/icon_256x256@2x.png"
sips -z 512 512   "$1" --out "$ISET/icon_512x512.png"
sips -z 1024 1024 "$1" --out "$ISET/icon_512x512@2x.png"

iconutil -c icns "$ISET"
rm -rf "$ISET"
