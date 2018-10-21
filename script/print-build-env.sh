#!/bin/bash
#	print-build-env.sh
# audit the build environment (e.g. in debugging Nix derivations)
# (c) 2018 Sirio Balmelli

if [[ -z "$CC" ]]; then
	echo 'WARNING: $CC is NULL! assuming "gcc"'
	CC=gcc
fi

cat <<EOF

---- BUILD CONFIG ----
	compiler:	$(realpath $(which $CC 2>&1))
	compiler include paths:
$($CC -E -Wp,-v - </dev/null 2>&1 | sed -nE 's|\s*(/.*include)$|\1|p')

	linker:		$(realpath $(which ld 2>&1))
	linker config:
$(ld -v 2>&1 | grep -v "no object")

	pkgconfig:	$(realpath $(which pkg-config 2>&1))
	pkgconfig paths:
$PKG_CONFIG_PATH
---- END BUILD CONFIG ----

EOF
