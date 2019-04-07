# toolbench scripts, for installation on a running system
#{ writeShellScriptBin ? (import <nixpkgs> {}).writeShellScriptBin }:
{
  system ? builtins.currentSystem,
  nixpkgs ? import (builtins.fetchGit {
    url = "https://github.com/siriobalmelli-foss/nixpkgs.git";
    ref = "sirio";
    }) {}
}:

with nixpkgs;

stdenv.mkDerivation {
  name = "tbh";
  buildInputs = [
    writeShellScriptBin "tbh_merge_pdf" ./tbh_merge_pdf.sh
    writeShellScriptBin "tbh_install" ./tbh_install.sh
  ];
}
