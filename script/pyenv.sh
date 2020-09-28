#	pyenv.sh
# Setup a python development environment in Nix, without a 'shell.nix' file
SHELLCMD=$(cat <<EOF
with import <nixpkgs>{};

mkShell {
  buildInputs = with python3Packages; [
    python
    venvShellHook
  ];

  venvDir = "venv";

  postShellHook = ''
    export SOURCE_DATE_EPOCH=315532800  # fix ZIP does not support timestamps before 1980
    alias pip="python -m pip"
    pip install --upgrade pip wheel
    [ -s requirements.txt ] && pip install -r requirements.txt
  '';
}
EOF
)

nix-shell --pure -E "$SHELLCMD"
