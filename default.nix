{
  nixpkgs ? import (builtins.fetchGit {
    url = "https://siriobalmelli@github.com/siriobalmelli-foss/nixpkgs.git";
    ref = "refs/tags/sirio-2023-03-02";
    }) { },
}:

with nixpkgs;

# TODO: install patched hosts file (for when this migrates to HomeManager):
# https://github.com/StevenBlack/hosts#nixos

# TODO: set 'PreserveJobHistory Off' in /etc/cups/cupsd.conf
# and then run 'cancel -a -x' to remove all previous print jobs.

let
  gcc = nixpkgs.gcc.overrideAttrs ( oldAttrs: rec { meta.priority = 5; });
  clang = llvmPackages.clang.overrideAttrs ( oldAttrs: rec { meta.priority = 6; });
  clang-unwrapped = llvmPackages.clang-unwrapped.overrideAttrs ( oldAttrs: rec { meta.priority = 7; });
  binutils-unwrapped = nixpkgs.binutils-unwrapped.overrideAttrs ( oldAttrs: rec { meta.priority = 8; });

  ##
  # python
  ##
  pyenv = python3.withPackages (p: with p; [
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
  ]);

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = callPackage ./bashrc { };

  # Git with config baked in
  git = import ./git { inherit nixpkgs symlinkJoin makeWrapper writeScriptBin ; };

  tbh = import ./script { inherit writeShellScriptBin syncthing; };

  # Tmux with a custom tmux.conf baked in
  tmux = import ./tmux { inherit nixpkgs symlinkJoin makeWrapper writeText; };

  # Vim with a custom vimrc and set of packages
  vim = import ./vim { inherit nixpkgs pyenv; };

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
      obsidian
      tbh
      tmux
      vim
      wezterm  # finally, a performant cross-platform terminal

      nushell  # the future?

      cmatrix  # why not

      # text formatting and alternatives to basic utilities
      bandwhich  # diagnose network usage
      bat
      bc
      bottom  # 'btm' replaces 'top'
      eza  # replace 'ls'
      fd  # replaces earlier 'findd' alias
      file
      gomplate  # one templating tool to rule them all
      hyperfine  # preferrable to 'time'
      procs  # replace 'ps'
      pv  # monitor data progress through a pipe
      ripgrep  # replaces earlier 'grepd' alias
      rename  # perl file rename
      sd  # replacement for sed
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
      tig

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
      gopass
      paperkey
      pass  # TODO: replace with gopass entirely
      pinentry
      scrypt
      step-cli

      gnupg
      pinentry_mac
      # TODO: add this default so we don't get prompted for keychain save on pinentry
      # defaults write org.gpgtools.common UseKeychain NO

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
      pkg-config

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
      d2  # diagrams
      imagemagickBig  # 'convert' utility
      # mscgen  # not used
      qrencode
      visidata


      ##
      # network
      ##
      ipcalc
      iperf3
      mtr
      netdiscover
      nmap  # contains ncat

      ##
      # inet protocols
      ##
      curl
      httpie
      inetutils  # contains telnet
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
      less
      libarchive  # bsdtar
      librsvg
      lzip  # .lz files
      lzma  # xz, unxz
      moreutils  # vidir
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

      jq
      yq

      ##
      # Clouds
      ##
      # awscli2
      # google-cloud-sdk
      # kubectl
      # openstackclient

      ##
      # nix
      ##
      alejandra  # nix formatting
      nixpkgs-review

      pyenv

      ## TODO: tiling WM
      # amethyst

  ##
  # packages that don't build on Darwin
  ##
  ] ++ lib.optionals (!stdenv.isDarwin) [
    pahole
    valgrind

    pinentry

  ##
  # node, JSON
  ##
  ] ++ (with nodePackages; [
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
