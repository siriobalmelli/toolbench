## toolbench scripts, for installation on a running system
# TODO: de-facto 'ghostscript' dependency for merge_pdf is not encoded anywhere
{ writeShellScriptBin ? (import <nixpkgs> {}).writeShellScriptBin }:

{
  tbh_gemset_nix = writeShellScriptBin "tbh_gemset_nix" ./gemset_nix.sh;
  tbh_install = writeShellScriptBin "tbh_install" ./install.sh;
  tbh_merge_pdf = writeShellScriptBin "tbh_merge_pdf" ./merge_pdf.sh;
}
