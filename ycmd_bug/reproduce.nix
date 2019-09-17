{ system ? builtins.currentSystem }:

with import (builtins.fetchGit {
  url = "https://github.com/NixOS/nixpkgs.git";
  ref = "master";
  }) {};

let
  # NOTE: bug is the same with either python2 or python3
  #python = python2Full;
  python = python3Full;

  # huge Vim build - bug is evident here
  vim_config = vim_configurable.override {
    inherit python;
    darwinSupport = stdenv.isDarwin;
    guiSupport="";  # work around build issue looking for a gtk3 header
  };

  ## smallest Vim build - bug is evident here also
  #vim_config = vim_configurable.override {
  #  inherit python;
  #  darwinSupport = stdenv.isDarwin;
  #  guiSupport="";

  #  features = "normal";  # python does not work with "tiny" or "small"
  #  ftNixSupport=false;  # use vim-nix plugin instead
  #  luaSupport = false;
  #  rubySupport = false;
  #  cscopeSupport = false;
  #  netbeansSupport = false;
  #};

  extraPackages = with vimPlugins; [ youcompleteme ];

  vimrc = writeText "vimrc"
    (lib.concatStringsSep "\n"
    [ 
      ''
      let g:ycm_server_keep_logfiles = 1
      let g:ycm_server_log_level = 'debug'
      let g:ycm_python_binary_path = '${python}/bin/python'
      ''
    ]);

  customRC = vimUtils.vimrcFile
    { customRC = builtins.readFile vimrc;
      packages.mvc.start = extraPackages;
    };

in
symlinkJoin {
  name = "vim";
  buildInputs = [makeWrapper];
  postBuild = ''
      wrapProgram "$out/bin/vim" --add-flags "-u ${customRC}"
  '';
  paths = [vim_config];
}
