{
  nixpkgs ? import (builtins.fetchGit {
    url = "https://siriobalmelli@github.com/siriobalmelli-foss/nixpkgs.git";
    ref = "refs/tags/sirio-2022-08-16";
    }) { },
}:

with nixpkgs;

let
  # single knob for python version everywhere
  # ... there is also the wrapped 'python3.withPackages' approach (see <https://nixos.org/nixpkgs/manual/#python>)
  # which would obviate having to set PYTHONPATH in bashrc,
  # but would require explicitly reinstalling the wrapped python at every change,
  # as opposed to quickly and painlessly testing things with 'nix-env --install'
  python = python3;

  gcc = nixpkgs.gcc.overrideAttrs ( oldAttrs: rec { meta.priority = 5; });
  clang = llvmPackages.clang.overrideAttrs ( oldAttrs: rec { meta.priority = 6; });
  clang-unwrapped = llvmPackages.clang-unwrapped.overrideAttrs ( oldAttrs: rec { meta.priority = 7; });
  binutils-unwrapped = nixpkgs.binutils-unwrapped.overrideAttrs ( oldAttrs: rec { meta.priority = 8; });

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = callPackage ./bashrc {};

  # Git with config baked in
  git = import ./git { inherit nixpkgs symlinkJoin makeWrapper writeScriptBin ; };

  tbh = import ./script { inherit writeShellScriptBin syncthing; };

  # Tmux with a custom tmux.conf baked in
  tmux = import ./tmux { inherit nixpkgs symlinkJoin makeWrapper writeText; };

  # Vim with a custom vimrc and set of packages
  vim = import ./vim { inherit nixpkgs python; };

  # The list of packages to be installed
  homies = [
      nix
      cachix

      replacement  # dogfood

      # terminals editors and hacks
      bash
      shellcheck
      bashrc
      # irssi  # irc!
      tbh
      tmux
      vim
      wezterm  # finally, a performant cross-platform terminal

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
      gitAndTools.git-filter-repo
      git-extras  # eg git summary
      git-lfs
      git-quick-stats
      # git-town  # seems interesting, doesn't build right now
      mr  # TODO: deprecate

      # compilers and wrappers
      binutils-unwrapped  # strings
      llvm.all
      clang.all  # wrapped, with headers etc
      clang-unwrapped.all  # clang-format in path
      gcc
      gdb
      poke

      ##
      # crypto
      ##
      certbot
      gnupg
      gopass
      paperkey
      pass  # TODO: replace with gopass entirely
      pinentry
      scrypt
      step-cli

      ##
      # cryptocurrencies
      ##
      bitcoind
      cointop
      # keybase  # DoA

      ##
      # build systems
      ##
      cmake
      gnumake
      meson
      ninja
      pkgconfig

      ##
      # data transfer
      ##
      borgbackup
      rclone
      rsync
      syncthing

      ##
      # visual
      ##
      imagemagickBig  # 'convert' utility
      # mscgen  # not used
      qrencode
      visidata

      ##
      # network
      ##
      inetutils  # contains telnet
      ipcalc
      mtr
      nmap  # contains ncat
      openssh
      wget

      ##
      # standard packages
      ##
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
      ffmpeg-full
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

      ##
      # Clouds
      ##
      # awscli
      # google-cloud-sdk
      # kubectl

      ##
      # nix
      ##
      nixpkgs-review

    ##
    # packages that don't build on Darwin
    ##
    ] ++ lib.optionals (!stdenv.isDarwin) [
      pahole
      valgrind

      pinentry

    ##
    # python
    ##
    ] ++ (with python.pkgs; [
      python

      ##
      # REPLs
      ##
      ipython
      # ptpython

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
      pdfminer-six
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

  ##
  # node, JSON
  ##
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
