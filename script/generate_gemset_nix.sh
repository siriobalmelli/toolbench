rm -rfv Gemfile.lock
nix-shell -p bundler \
	--command 'bundler package --no-install --path vendor && rm -rf .bundler vendor' \
	&& $(nix-build '<nixpkgs>' -A bundix)/bin/bundix \
	&& rm result
