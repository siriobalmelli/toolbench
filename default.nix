# The main homies file, where homies are defined. See the README.md for
# instructions.
let

  # The (pinned) Nixpkgs where the original packages are sourced from
  nixpkgs = import ./nixpkgs {};

  # The list of packages to be installed
  homies = with nixpkgs;
    [
      # Customized packages
      bashrc
      git
      tmux
      vim

      # standard packages - query with `nix-env -qaP`
      nixpkgs.avrbinutils
      nixpkgs.beancount
      nixpkgs.binutils-unwrapped
      nixpkgs.clang_6
      nixpkgs.cscope
      nixpkgs.curl
      nixpkgs.dos2unix
      nixpkgs.emacs
      nixpkgs.fava
      nixpkgs.fdupes
      nixpkgs.ffmpeg
      nixpkgs.figlet
      nixpkgs.gitAndTools.gitAnnex
      nixpkgs.gnused
      nixpkgs.gnutar
      nixpkgs.htop
      nixpkgs.imagemagickBig
      nixpkgs.jq
      nixpkgs.less
      nixpkgs.llvm_6
      nixpkgs.meson
      nixpkgs.ncat
      nixpkgs.ninja
      nixpkgs.nix
      nixpkgs.nmap
      nixpkgs.pandoc
      nixpkgs.pass
      nixpkgs.pkgconfig
      nixpkgs.pwgen
      nixpkgs.python36Full
      nixpkgs.python36Packages.cycler
      nixpkgs.python36Packages.dateutil
      nixpkgs.python36Packages.jsonschema
      nixpkgs.python36Packages.matplotlib
      nixpkgs.python36Packages.numpy
      nixpkgs.python36Packages.ply
      nixpkgs.python36Packages.pyparsing
      nixpkgs.python36Packages.requests
      nixpkgs.python36Packages.ruamel_yaml
      nixpkgs.python36Packages.six
      nixpkgs.python36Packages.tabulate
      nixpkgs.source-code-pro
      nixpkgs.texlive.combined.scheme-full
      nixpkgs.tree
      nixpkgs.watch
      nixpkgs.wget
      nixpkgs.which
      nixpkgs.xclip
      nixpkgs.xorriso
    ];

  # A custom '.bashrc' (see bashrc/default.nix for details)
  bashrc = nixpkgs.callPackage ./bashrc {};

  # Git with config baked in
  git = import ./git (
    { inherit (nixpkgs) makeWrapper symlinkJoin;
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
  vim = import ./vim (with nixpkgs;
    {inherit
        symlinkJoin
        makeWrapper
        vim_configurable
        vimUtils
        vimPlugins;
    });

in
  if nixpkgs.lib.inNixShell
  then nixpkgs.mkShell
    { buildInputs = homies;
      shellHook = ''
        $(bashrc)
        '';
    }
  else homies
