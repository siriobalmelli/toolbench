#!/bin/bash
# clean up a python package directory and print some mnemonics
# maintainer's personal script; use at own risk
set -e

# Simplify path handling
pushd "$(dirname "$0")"  # don't follow symlinks
trap "popd" EXIT

# Remove any build or runtime arifacts
# ... python can be a bit noisy with artifacts floating around the project dir
rm -rfv \
	"test/test_log" \
	.eggs \
	.tox \
	beancount_docverif.egg-info \
	build dist result \

find . \( -name "__pycache__" -o -name "*.pyc" \) -exec rm -rfv '{}' \;

cat <<EOF
##
# From inside a --pure nix shell:
##

# Run tests
python3 -m pytest

# Build both binary and source distributions locally
python3 setup.py bdist_wheel sdist

# Upload to PyPi
twine upload dist/*

##
# done
##
EOF
