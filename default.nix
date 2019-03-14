# The main homies file, where homies are defined. See the README.md for
# instructions.
let

  # The (pinned) Nixpkgs where the original packages are sourced from
  nixpkgs = import ./nixpkgs {};

  # single knob for python version everywhere
  # ... there is also the wrapped 'python35.withPackages' approach (see <https://nixos.org/nixpkgs/manual/#python>)
  # which would obviate having to set PYTHONPATH in bashrc,
  # but would require explicitly reinstalling the wrapped python at every change,
  # as opposed to quickly and painlessly testing things with 'nix-env --install'
  python = nixpkgs.python37Full;

  # The list of packages to be installed
  homies = [
      # Customized packages
      bashrc
      git
      replacement
      tmux
      vim

      python
      python.pkgs.beancount
      python.pkgs.cycler
      python.pkgs.dateutil
      python.pkgs.flake8
      python.pkgs.jsonschema
      python.pkgs.markdown
      python.pkgs.matplotlib
      python.pkgs.mypy
      python.pkgs.numpy
      python.pkgs.pip
      python.pkgs.ply
      #python.pkgs.pylint  # pyenchant build issue?
      python.pkgs.pyparsing
      python.pkgs.requests
      python.pkgs.ruamel_yaml
      python.pkgs.setuptools
      python.pkgs.six
      python.pkgs.tabulate
      python.pkgs.twine
      python.pkgs.wheel
      python.pkgs.yamllint

      # compilers and wrappers
      gcc
      clang
      nixpkgs.valgrind
      nixpkgs.gdb
      nixpkgs.llvm
      nixpkgs.binutils-unwrapped

      # standard packages - query with `nix-env -qaP`
      nixpkgs.altcoins.go-ethereum
      nixpkgs.cacert
      nixpkgs.cloc
      nixpkgs.cointop
      nixpkgs.coreutils
      nixpkgs.cscope
      nixpkgs.curl
      nixpkgs.dos2unix
      nixpkgs.entr
      nixpkgs.fava
      nixpkgs.fdupes
      nixpkgs.ffmpeg
      nixpkgs.figlet
      nixpkgs.findutils
      #nixpkgs.gitAndTools.gitAnnex  # build fails on Darwin
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
      nixpkgs.ninja
      nixpkgs.nix
      nixpkgs.nmap
      nixpkgs.p7zip
      nixpkgs.pandoc
      nixpkgs.pass
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

      #nixpkgs.pahole  # not supported on Darwin
    ];


  gcc = nixpkgs.gcc.overrideAttrs ( oldAttrs: rec { meta.priority = 5; });
  clang = nixpkgs.clang.overrideAttrs ( oldAttrs: rec { meta.priority = 6; });

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = nixpkgs.callPackage ./bashrc {};

  # TODO: integrate this with a branch of our own nixpkgs
  replacement = nixpkgs.callPackage ./replacement { inherit nixpkgs python; };

  # Git with config baked in
  git = import ./git (
    { inherit (nixpkgs) makeWrapper symlinkJoin writeScriptBin;
      git = nixpkgs.git;
    });

  # Tmux with a custom tmux.conf baked in
  tmux = import ./tmux (with nixpkgs;
    { inherit
        symlinkJoin
        makeWrapper
        writeText
        ;
      tmux = nixpkgs.tmux;
    });

  snack = (import ./snack).snack-exe;

  # Vim with a custom vimrc and set of packages
  vim = import ./vim { inherit nixpkgs python; };

in
  if nixpkgs.lib.inNixShell
  then nixpkgs.mkShell
    { buildInputs = homies;
      shellHook = ''
        $(homies-bashrc)
        '';
    }
  else homies
