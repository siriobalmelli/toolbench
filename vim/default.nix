# somehow passing 'neovim' instead of 'nixpkgs' gives infinite recursion?
{ nixpkgs, python }:

with nixpkgs;
with vimPlugins;

nixpkgs.neovim.override {

  vimAlias = true;

  configure = {
    packages.ale.start = [ ale ];
    packages.autoload_cscope-vim.start = [ autoload_cscope-vim ];
    packages.jdaddy-vim.start = [ jdaddy-vim ];
    packages.meson.start = [ meson ];
    packages.nerdcommenter.start = [ nerdcommenter ];
    packages.plantuml-syntax.start = [ plantuml-syntax ];
    packages.rainbow.start = [ rainbow ];
    packages.surround.start = [ surround ];
    packages.tabular.start = [ tabular ];
    packages.ultisnips.start = [ ultisnips ];
    packages.vim-beancount.start = [ vim-beancount ];
    packages.vim-easymotion.start = [ vim-easymotion ];
    packages.vim-go.start = [ vim-go ];
    packages.vim-indent-guides.start = [ vim-indent-guides ];
    packages.vim-localvimrc.start = [ vim-localvimrc ];
    packages.vim-markdown.start = [ vim-markdown ];
    packages.vim-nix.start = [ vim-nix ];
    packages.vim-pager.start = [ vim-pager ];
    packages.vim-snippets.start = [ vim-snippets ];
    packages.vim-toml.start = [ vim-toml ];
    packages.youcompleteme.start = [ youcompleteme ];
    # TODO: these packages *seem* like a good idea; audition and learn them
    #ctrlp # grep -Er from inside Vim
    #fugitive  # frob Git from inside Vim
    #tmux-navigator
    #nerdtree  # file browser from inside Vim
    #vim-airline  # status bar

    # NOTE: intriguing packages which I'm still not sure are a good idea
    #vim-trailing-whitespace
    #vimproc

    customRC =
      (nixpkgs.lib.concatStringsSep "\n"
      [ (builtins.readFile ./vimrc)
        ''
        let g:ycm_python_binary_path = '${python}/bin/python'
        let g:UltiSnipsSnippetDirectories=['${./UltiSnips}', 'UltiSnips']
        let g:ycm_python_binary_path = '${python}/bin/python'
        ''
      ]
      );
  };
}
