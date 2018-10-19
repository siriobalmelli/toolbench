{ lib, writeText, writeScriptBin, fzf }:

# compile a bashrc into /nix/store (path is unknowable)
# TODO: the CPATH stuff is a terrible hack - must go away eventually
let
  bashrc = writeText "bashrc"
    (lib.concatStringsSep "\n"
    [ (builtins.readFile ./bashrc)
      ''
      source ${fzf}/share/fzf/completion.bash
      source ${fzf}/share/fzf/key-bindings.bash
      source ${./pass.bash-completion}
      ''
    ]
    );

# write a script that sources it
in writeScriptBin "homies-bashrc"
  ''
  echo "source ${bashrc}"
  ''
