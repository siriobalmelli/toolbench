{ lib, writeText, writeScriptBin, fzf, nixpkgs }:

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

      # CPATH so that YCM+clang can find glibc and clang headers.
      # Probably symptomatic of a broken YCM build,
      # but that stuff is greek, unfortunately.
      C_GLIBC=${nixpkgs.glibc.dev}/include
      C_CLANG=$(find -L ${nixpkgs.clang_7} -type d -name include -exec echo -n ":{}" \;)
      export CPATH=$C_GLIBC$C_CLANG:$CPATH
      unset C_GLIBC
      unset C_CLANG
      ''
    ]
    );

# write a script that sources it
in writeScriptBin "homies-bashrc"
  ''
  echo "source ${bashrc}"
  ''
