# Vim, with a set of extra packages (extraPackages) and a custom vimrc
# (./vimrc). The final vimrc file is generated by vimUtils.vimrcFile and
# bundles all the packages with the custom vimrc.
#{ symlinkJoin, makeWrapper, vim_configurable, vimUtils, vimPlugins }:
{ nixpkgs, python }:
with nixpkgs;
let
  vim_config = vim_configurable.override {
    inherit python;
  };
  extraPackages = with vimPlugins;
    [
      autoload_cscope-vim
      ultisnips

      # TODO: SimplylFold (python folding for vim)
      nerdcommenter  # comment manipulation
      surround  # delimiter (quote, brace, etc) manipulation
      rainbow  # paren colorizer
      ale  # better linting
      tabular  # format tables
      vim-easymotion  # upgraded search
      vim-indent-guides  # show indents visually
      youcompleteme  # completion is life

      # language support (and linting) packages:
      jdaddy-vim  # crappy previous alternative is vim-json
      vim-markdown
      vim-nix
      meson
      vim-beancount

      # TODO: these packages *seem* like a good idea; audition and learn them
      #ctrlp # grep -Er from inside Vim
      #fugitive  # frob Git from inside Vim
      #tmux-navigator
      #nerdtree  # file browser from inside Vim
      #vim-airline  # status bar

      # NOTE: intriguing packages which I'm still not sure are a good idea
      #vim-trailing-whitespace
      #vimproc
    ];
  vimrc = writeText "vimrc"
    (lib.concatStringsSep "\n"
    [ (builtins.readFile ./vimrc)
      ''
      let g:UltiSnipsSnippetDirectories=['${./UltiSnips}']
      ''
    ]
    );
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
      cp -r ${./UltiSnips} $out/share/vim/UltiSnips
  '';
  paths = [vim_config];
}
