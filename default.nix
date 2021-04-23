{
  nixpkgs ? import (builtins.fetchGit {
    url = "https://siriobalmelli@github.com/siriobalmelli-foss/nixpkgs.git";
    ref = "master";
    }) {}
}:

with nixpkgs;

let
  # single knob for python version everywhere
  # ... there is also the wrapped 'python35.withPackages' approach (see <https://nixos.org/nixpkgs/manual/#python>)
  # which would obviate having to set PYTHONPATH in bashrc,
  # but would require explicitly reinstalling the wrapped python at every change,
  # as opposed to quickly and painlessly testing things with 'nix-env --install'
  python = python3;

  gcc = nixpkgs.gcc.overrideAttrs ( oldAttrs: rec { meta.priority = 5; });
  clang = nixpkgs.clang.overrideAttrs ( oldAttrs: rec { meta.priority = 6; });

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = callPackage ./bashrc {};

  # Git with config baked in
  git = import ./git { inherit nixpkgs symlinkJoin makeWrapper writeScriptBin ; };

  tbh = import ./script { inherit writeShellScriptBin syncthing; };

  # Tmux with a custom tmux.conf baked in
  tmux = import ./tmux { inherit nixpkgs symlinkJoin makeWrapper writeText; };

  # Vim with a custom vimrc and set of packages
  vim = import ./vim { inherit nixpkgs python; };

  # some tests fail on Darwin
  git-annex = haskell.lib.dontCheck gitAndTools.gitAnnex;

  ycmd = nixpkgs.ycmd.override { inherit gocode godef gotools; rustracerd = null; };

  # The list of packages to be installed
  homies = [
      nix
      cachix

      replacement  # dogfood

      # terminals editors and hacks
      bash
      shellcheck
      bashrc
      irssi  # irc!
      tbh
      tmux
      vim
      ycmd

      # text formatting and alternatives to basic utilities
      bat
      bc
      fd  # replaces earlier 'findd' alias
      hyperfine  # preferrable to 'time'
      ripgrep  # replaces earlier 'grepd' alias
      pv  # monitor data progress through a pipe
      watchexec  # execute on file changes

      # version control
      git
      git-annex
      nixpkgs.gitAndTools.delta  # TODO: evaluate 'git d | delta'
      gitAndTools.gitRemoteGcrypt
      gitAndTools.git-filter-repo
      git-lfs
      mr

      # compilers and wrappers
      binutils-unwrapped
      clang
      clang-tools
      gcc
      gdb
      llvm
      protobuf
      #valgrind

      # go ecosystem
      go
      gocode
      godef
      hugo

      #crypto
      gnupg
      gopass
      paperkey
      pass  # TODO: replace with gopass entirely
      pinentry
      scrypt

      # cryptocurrencies
      bitcoin
      cointop
      go-ethereum
      keybase

      # build systems
      cmake
      gnumake
      meson
      ninja
      pkgconfig

      # data transfer
      borgbackup
      rclone
      rsync
      syncthing

      # visual
      imagemagickBig  # 'convert' utility
      mscgen
      visidata

      # network
      iftop
      ipcalc
      mtr
      ncat
      nmap
      openssh
      telnet
      wget

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
      fdupes
      ffmpeg  # ffmpeg-full doesn't build on BigSur, also see https://github.com/NixOS/nixpkgs/issues/15930
      figlet
      findutils
      flock
      gnupatch
      gnused
      gnutar
      htop
      jq
      less
      libarchive  # bsdtar
      lzip  # .lz files
      lzma  # xz, unxz
      moreutils  # vidir
      ncdu
      ncurses
      ncurses.dev
      neofetch
      pandoc
      pwgen
      speedtest-cli
      texlive.combined.scheme-full
      tree
      vale  # command line linter for prose
      watch
      which
      xorriso

      ## Clouds
      #awscli
      google-cloud-sdk
      #kubectl

      ## graphical packages, require better config management than currently
      #alacritty

      # nix
      nixpkgs-review

    # packages that don't build on Darwin
    ] ++ lib.optionals (!stdenv.isDarwin) [
      pahole
      pinentry

    # python
    ] ++ (with python.pkgs; [
      python

      # REPLs
      ipython
      ptpython

      #beancount
      #fava

      dateutil
      flake8
      jinja2
      jsonschema
      markdown
      numpy
      pexpect
      pip
      ply
      pyparsing
      requests
      ruamel_yaml
      setuptools
      sh
      six
      tabulate
      twine
      wheel
      yamllint
    ]);

in
  if lib.inNixShell then
    mkShell {
      buildInputs = homies;
      shellHook = ''$(homies-bashrc)'';
    }
  else
    homies
