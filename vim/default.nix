# somehow passing 'neovim' instead of 'nixpkgs' gives infinite recursion?
{ nixpkgs, pyenv }:

with nixpkgs;
with vimPlugins;

# see https://github.com/teto/home/blob/master/config/nixpkgs/overlays/neovim.nix#L181
# for how to better/further override neovim
nixpkgs.neovim.override {

  # TODO: add copilot

  viAlias = true;
  vimAlias = true;
  withPython3 = true;
  # TODO: would be nice to pass neovim 'pyenv' but no luck so far
  extraPython3Packages = (ps: with ps; [
    black
    flake8
    jedi
    jedi-language-server
    markdown
    pyparsing
    yamllint
  ]);

  configure = {
    # TODO: replace with nvim-tree-lua or similar?
    # netrw expanded
    packages.vim-vinegar.start = [ vim-vinegar ];

    ## TODO: better C syntax highlighting with eg chromatica or color_coded?
    packages.YouCompleteMe.start = [ YouCompleteMe ];  # autocompletion
    packages.ale.start = [ ale ];  # linting

    packages.lightline-vim.start = [ lightline-vim ];  # minimalist status bar (cf vim-airline)
    packages.vim-gitbranch.start = [ vim-gitbranch ];  # git branch data for lightline

    packages.ultisnips.start = [ ultisnips ];  # snippets engine
    packages.vim-snippets.start = [ vim-snippets ];  # community snippets

    packages.autoload_cscope-vim.start = [ autoload_cscope-vim ];  # cscope!
    packages.nerdcommenter.start = [ nerdcommenter ];  # comment toggling
    packages.rainbow.start = [ rainbow ];  # parenthesis matching
    packages.surround.start = [ surround ];  # bracket and quote pairs
    packages.tabular.start = [ tabular ];  # table generation
    packages.vim-easymotion.start = [ vim-easymotion ];  # efficient search
    packages.vim-localvimrc.start = [ vim-localvimrc ];  # dir and subdir .lvimrc

    # language support
    packages.jdaddy-vim.start = [ jdaddy-vim ];
    packages.meson.start = [ meson ];
    packages.vim-beancount.start = [ vim-beancount ];
    packages.vim-markdown.start = [ vim-markdown ];
    packages.vim-nix.start = [ vim-nix ];
    packages.vim-toml.start = [ vim-toml ];
    packages.vim-css-color.start = [ vim-css-color ];  # colorize hex values in css

    # go ecosystem broken
    # packages.vim-go.start = [ vim-go ];

    customRC = (nixpkgs.lib.concatStringsSep "\n"
      [ (builtins.readFile ./vimrc)
        ''
        let g:ycm_python_binary_path = '${pyenv.interpreter}'
        let g:ycm_python_interpreter_path = '${pyenv.interpreter}'
        let g:ycm_python_sys_path = '${pyenv.sitePackages}'
        let g:UltiSnipsSnippetDirectories=['${./UltiSnips}', 'UltiSnips']
        ''
      ]
    );
  };
}
