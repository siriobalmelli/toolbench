# Tmux with ./tmux.conf baked in
{ nixpkgs, writeText, symlinkJoin, makeWrapper }:
symlinkJoin {
  name = "tmux";
  buildInputs = [makeWrapper];
  paths = [ nixpkgs.tmux ];
  postBuild = ''
    wrapProgram "$out/bin/tmux" \
    --add-flags "-f ${./tmux.conf}"
  '';
}
