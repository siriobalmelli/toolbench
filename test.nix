{
  nixpkgs ? import (builtins.fetchGit {
    url = "https://siriobalmelli@github.com/siriobalmelli-foss/nixpkgs.git";
    ref = "master";
    }) {}
  #nixpkgs ? import ~/repos/foss/nixpkgs/default.nix {}
}:

with nixpkgs;

{
    python = python36;
    python3 = python36;

    shellHook = ''
        ${python.interpreter} --version
    '';
}
