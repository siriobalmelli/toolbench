{
  system ? builtins.currentSystem,
  nixpkgs ? import (builtins.fetchGit {
    url = "https://github.com/siriobalmelli-foss/nixpkgs.git";
    ref = "sirio";
    }) {}
}:

let
  # TODO: get accepted upstream
  replacement = nixpkgs.replacement or import (builtins.fetchGit {
    url = "https://github.com/siriobalmelli/replacement.git";
    ref = "master";
    }) {};

  # single knob for python version everywhere
  # ... there is also the wrapped 'python35.withPackages' approach (see <https://nixos.org/nixpkgs/manual/#python>)
  # which would obviate having to set PYTHONPATH in bashrc,
  # but would require explicitly reinstalling the wrapped python at every change,
  # as opposed to quickly and painlessly testing things with 'nix-env --install'
  python = nixpkgs.python37Full;

  gcc = nixpkgs.gcc.overrideAttrs ( oldAttrs: rec { meta.priority = 5; });
  clang = nixpkgs.clang.overrideAttrs ( oldAttrs: rec { meta.priority = 6; });

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = nixpkgs.callPackage ./bashrc {};

  # Git with config baked in
  git = import ./git (
    { inherit (nixpkgs) git symlinkJoin makeWrapper writeScriptBin ; });

  tbh = import ./script (with nixpkgs;
    { inherit writeShellScriptBin; });

  # Tmux with a custom tmux.conf baked in
  tmux = import ./tmux (with nixpkgs;
    { inherit symlinkJoin makeWrapper writeText;
       tmux = nixpkgs.tmux;
    });

  # Vim with a custom vimrc and set of packages
  vim = import ./vim
    { inherit nixpkgs python; };

  # The list of packages to be installed
  homies = [
      # Customized packages
      bashrc
      replacement
      tbh
      tmux
      vim

      git
      nixpkgs.gitAndTools.gitRemoteGcrypt
      nixpkgs.git-crypt
      #nixpkgs.gitAndTools.gitAnnex  # build fails on Darwin

      python
      python.pkgs.beancount
      python.pkgs.cycler
      python.pkgs.dateutil
      python.pkgs.flake8
      python.pkgs.ipython
      python.pkgs.jsonschema
      python.pkgs.markdown
      python.pkgs.matplotlib
      python.pkgs.numpy
      python.pkgs.pip
      python.pkgs.ply
      python.pkgs.prompt_toolkit
      python.pkgs.pyparsing
      python.pkgs.requests
      python.pkgs.ruamel_yaml
      python.pkgs.setuptools
      python.pkgs.six
      python.pkgs.tabulate
      python.pkgs.twine
      python.pkgs.wcwidth
      python.pkgs.wheel
      python.pkgs.yamllint
      #python.pkgs.mypy # TODO: not playing nice and finding e.g. beancount.
                        # TODO: debug and re-inable for ALE in vimrc
      #python.pkgs.pylint  # pyenchant build issue? Replaced with flake8 and mypy

      # compilers and wrappers
      gcc
      clang
      nixpkgs.valgrind
      nixpkgs.gdb
      nixpkgs.llvm
      nixpkgs.binutils-unwrapped

      #crypto
      nixpkgs.gnupg
      nixpkgs.keybase
      nixpkgs.paperkey
      nixpkgs.gopass
      nixpkgs.pinentry
      nixpkgs.scrypt

      # standard packages - query with `nix-env -qaP`
      nixpkgs.altcoins.go-ethereum
      nixpkgs.cacert
      nixpkgs.cht-sh  # cheat sheet
      nixpkgs.cloc
      nixpkgs.cointop
      nixpkgs.coreutils
      nixpkgs.cscope
      nixpkgs.curl
      nixpkgs.dos2unix
      nixpkgs.dosfstools  # mkdosfs
      nixpkgs.entr
      nixpkgs.fava
      nixpkgs.fdupes
      nixpkgs.ffmpeg
      nixpkgs.figlet
      nixpkgs.findutils
      nixpkgs.flock
      nixpkgs.gnumake
      nixpkgs.gnupatch
      nixpkgs.gnused
      nixpkgs.gnutar
      nixpkgs.htop
      nixpkgs.iftop
      nixpkgs.imagemagickBig
      nixpkgs.ipcalc
      nixpkgs.jq
      nixpkgs.less
      nixpkgs.libarchive  # bsdtar
      nixpkgs.lzma  # xz, unxz
      nixpkgs.meson
      nixpkgs.moreutils  # vidir
      nixpkgs.mtr
      nixpkgs.ncat
      nixpkgs.ncurses
      nixpkgs.ncurses.dev
      nixpkgs.ninja
      nixpkgs.nix
      nixpkgs.nmap
      nixpkgs.openssh
      nixpkgs.p7zip
      nixpkgs.pandoc
      nixpkgs.pkgconfig
      nixpkgs.powerline-fonts
      nixpkgs.pwgen

      nixpkgs.texlive.combined.scheme-full
      nixpkgs.tree
      nixpkgs.vale
      nixpkgs.watch
      nixpkgs.wget
      nixpkgs.which
      nixpkgs.xorriso
      nixpkgs.ycmd

      #nixpkgs.pahole  # not supported on Darwin
    ];

in
  if nixpkgs.lib.inNixShell then
    nixpkgs.mkShell {
      buildInputs = homies;
      shellHook = ''$(homies-bashrc)'';
    }
  else
    homies
