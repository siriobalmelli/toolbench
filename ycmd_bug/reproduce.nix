{
  system ? builtins.currentSystem,
  nixpkgs ? import (builtins.fetchGit {
    url = "https://github.com/siriobalmelli-foss/nixpkgs.git";
    ref = "ac4ef4cd327244a205ec742beb235804c79e1512";
    }) {}
}:

with nixpkgs;
let
  python = python3Full;

  vim_config = vim_configurable.override {
    inherit python;
    guiSupport="";  # work around build issue looking for a gtk3 header
    ftNixSupport=false;  # use vim-nix plugin instead
    rubySupport = false;  # because *why*??
  };

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
