#	install.sh
# install (pin) a top-level Nix derivation as the Nix environment
# (c) 2018 Sirio Balmelli

if [[ $(uname) == 'Darwin' ]]; then
	sudo killall -HUP mDNSResponder
else
	echo "linux DNS flush not implemented yet" >&2
	exit 1
fi
