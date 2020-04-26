{
  nixpkgs ? import (builtins.fetchGit {
    url = "https://siriobalmelli@github.com/siriobalmelli-foss/nixpkgs.git";
    ref = "master";
    }) {}
}:

with nixpkgs;

let
  # TODO: get accepted upstream
  replacement = nixpkgs.replacement or import (builtins.fetchGit {
    url = "https://siriobalmelli@github.com/siriobalmelli/replacement.git";
    ref = "master";
    }) {};
  nonlibc = nixpkgs.nonlibc or import (builtins.fetchGit {
    url = "https://siriobalmelli@github.com/siriobalmelli/nonlibc.git";
    ref = "master";
    }) {};

  # single knob for python version everywhere
  # ... there is also the wrapped 'python35.withPackages' approach (see <https://nixos.org/nixpkgs/manual/#python>)
  # which would obviate having to set PYTHONPATH in bashrc,
  # but would require explicitly reinstalling the wrapped python at every change,
  # as opposed to quickly and painlessly testing things with 'nix-env --install'
  python = python38Full;

  gcc = nixpkgs.gcc.overrideAttrs ( oldAttrs: rec { meta.priority = 5; });
  clang = nixpkgs.clang.overrideAttrs ( oldAttrs: rec { meta.priority = 6; });

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = callPackage ./bashrc {};

  # Git with config baked in
  git = import ./git { inherit nixpkgs symlinkJoin makeWrapper writeScriptBin ; };

  tbh = import ./script { inherit writeShellScriptBin; };

  # Tmux with a custom tmux.conf baked in
  tmux = import ./tmux { inherit nixpkgs symlinkJoin makeWrapper writeText; };

  # Vim with a custom vimrc and set of packages
  vim = import ./vim { inherit nixpkgs python; };

  # some tests fail on Darwin
  git-annex = haskell.lib.dontCheck gitAndTools.gitAnnex;

  ycmd = nixpkgs.ycmd.override { inherit gocode godef gotools; };

  # The list of packages to be installed
  homies = [
      # dogfood
      replacement
      nonlibc

      # terminals editors and hacks
      tmux
      vim
      ycmd
      bash
      bashrc
      tbh

      # version control
      git
      git-annex
      gitAndTools.gitRemoteGcrypt
      gitAndTools.git-filter-repo
      git-lfs
      mr

      # python
      python
      python.pkgs.beancount
      python.pkgs.cycler
      python.pkgs.dateutil
      python.pkgs.flake8
      python.pkgs.howdoi
      python.pkgs.ipython
      python.pkgs.jsonschema
      python.pkgs.markdown
      # python.pkgs.matplotlib
      # python.pkgs.numpy
      python.pkgs.pexpect
      python.pkgs.pip
      python.pkgs.ply
      python.pkgs.prompt_toolkit
      python.pkgs.ptyprocess
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
      binutils-unwrapped
      clang
      gcc
      gdb
      llvm
      valgrind
      #pahole  # not supported on Darwin

      # go ecosystem
      go
      gocode
      godef
      hugo

      #crypto
      gnupg
      go-ethereum
      keybase
      paperkey
      pass
      gopass
      scrypt
      cointop

      # build systems
      cmake  # TODO: ninja back-end for cmake
      gnumake
      ninja
      pkgconfig

      # data transfer
      borgbackup
      rsync

      # visual
      imagemagickBig
      mscgen

      # standard packages - query with `nix-env -qaP`
      cacert
      cht-sh  # cheat sheet
      cloc
      colordiff
      coreutils
      cscope
      curl
      dos2unix
      dosfstools  # mkdosfs
      entr
      fava
      fdupes
      ffmpeg-full
      figlet
      findutils
      flock
      gnupatch
      gnused
      gnutar
      htop
      iftop
      ipcalc
      jq
      less
      libarchive  # bsdtar
      lzip  # .lz files
      lzma  # xz, unxz
      meson
      moreutils  # vidir
      mtr
      ncat
      ncdu
      ncurses
      ncurses.dev
      nix
      nmap
      openssh
      p7zip
      pandoc
      plantuml
      powerline-fonts
      pwgen
      speedtest-cli
      telnet
      texlive.combined.scheme-full
      tree
      vale
      watch
      wget
      which
      xorriso

      # AWS
      awscli
      kubectl

    # packages that don't build on Darwin
    ] ++ lib.optionals (!stdenv.isDarwin) [
      pinentry
    ];

in
  if lib.inNixShell then
    mkShell {
      buildInputs = homies;
      shellHook = ''$(homies-bashrc)'';
    }
  else
    homies
