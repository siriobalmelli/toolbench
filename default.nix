{
  nixpkgs ? import (builtins.fetchGit {
    url = "https://siriobalmelli@github.com/siriobalmelli-foss/nixpkgs.git";
    ref = "refs/tags/sirio-2022-03-18";
    }) { },
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

  # go ecosystem broken
  # ycmd = nixpkgs.ycmd.override { inherit gocode godef gotools; };

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
      file
      gomplate  # one templating tool to rule them all
      hyperfine  # preferrable to 'time'
      ripgrep  # replaces earlier 'grepd' alias
      pv  # monitor data progress through a pipe
      rename  # perl file rename
      watchexec  # execute on file changes
      xjobs  # xargs, but make it a job manager

      # version control
      git
      gitAndTools.delta  # TODO: evaluate 'git d | delta'
      gitAndTools.gitRemoteGcrypt
      gitAndTools.git-filter-repo
      git-extras  # eg git summary
      git-lfs
      git-quick-stats
      git-town
      mr

      # compilers and wrappers
      binutils-unwrapped
      clang
      clang-tools
      gcc
      gdb
      llvm
      poke
      protobuf
      #valgrind

      # go currently broken
      # # go ecosystem
      # go
      # gocode
      # godef
      # hugo

      #crypto
      certbot
      gnupg
      gopass
      paperkey
      pass  # TODO: replace with gopass entirely
      pinentry
      scrypt
      step-cli

      # cryptocurrencies
      bitcoind
      cointop
      keybase
      # openethereum  # 3.2.6 _and_ 3.3.[2-5] refuse to build
      go-ethereum

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
      qrencode
      visidata

      # network
      iftop
      inetutils  # contains telnet
      ipcalc
      mtr
      nmap  # contains ncat
      openssh
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
      gawk
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
      unzip  # convenient
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

      beancount
      beancount_docverif
      beancount_payeeverif
      fava

      black
      dateutil
      devtools
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

  # node
  ]) ++ (with nodePackages; [
      eslint
      prettier

  ]);

in
  if lib.inNixShell then
    mkShell {
      buildInputs = homies;
      shellHook = ''$(homies-bashrc)'';
    }
  else
    homies
