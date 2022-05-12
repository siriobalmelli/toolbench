set -e
OUTFILE="$(echo "$1" | sed -E 's/\.[a-z]{3}$/.mp4/g')"
ffmpeg -i "$1" \
	-vf scale=3840x2560:flags=lanczos -c:v libx264 -preset slow -crf 12 -pix_fmt yuv420p \
	"$OUTFILE"
