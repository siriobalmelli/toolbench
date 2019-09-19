# nix(vim_configurable, youcompleteme, Darwin) == coredump;

This is as much data as I can gather about this bug.
Unfortunately

1. reproduce:

    ```bash
    # stipped-down version of vim_configurable with youcompleteme *only*
    nix-env -i -f ycmd_bug/reproduce.nix
    # don't even have to open a file, just Vim itself
    vim


    # OR, alternate way to reproduce:
    nix-build ycmd_bug/reproduce.nix && result/bin/vim
    ```

    This gives the following error in Vim:
    ```config
    The ycmd server SHUT DOWN (restart with ':YcmRestartServer').
    Unexpected exit code -11.
    Type ':YcmToggleLogs ycmd_60549_stderr_md18f3jl.log' to check the logs.
    ```

    The logs contain only:
    ```config
    2019-09-15 23:47:36,203 - DEBUG - No global extra conf, not calling method YcmCorePreload
    ```

    It also dumps core:
    ```bash
    $ file /cores/core.29150
    /cores/core.29150: Mach-O 64-bit core x86_64

    # ... but coredump file seems to be useless?!
    $ gdb -c /cores/core.29150
    GNU gdb (GDB) 8.3
    "python3.7-88112-501.core": no core file handler recognizes format
    (gdb) quit
    ```

1. Contents of `:YcmDebugInfo`:

    ```config
    -- Client logfile: /var/folders/kj/tzv099zx2yzgnkjtdhqbxbjh0000gn/T/ycm_gta4ow9z.log
    -- Server errored, no debug info from server
    -- Server running at: http://127.0.0.1:61097
    -- Server process ID: 24908
    -- Server logfiles:
    --   /var/folders/kj/tzv099zx2yzgnkjtdhqbxbjh0000gn/T/ycmd_61097_stdout_49_e8mqz.log
    --   /var/folders/kj/tzv099zx2yzgnkjtdhqbxbjh0000gn/T/ycmd_61097_stderr_1ciebbf0.log
    ```

    The Client logfile is a long list of entries like:
    ```config
    2019-09-15 23:50:05,369 - ERROR - HTTPConnectionPool(host='127.0.0.1', port=61097): Max retries exceeded with url: /debug_info (Caused by NewConnectionError('<urllib3.connection.HTTPConnection object at 0x109d6d490>: Failed to establish a new connection: [Errno 61] Connection refused'))
    ```

1. This bug is present with both python 2.7 and 3.7, on multiple Vim versions:

    - python3.7 with `huge` version:
        ```bash
        $ result/bin/vim --version
        VIM - Vi IMproved 8.1 (2018 May 18, compiled Sep 17 2019 15:48:38)
        macOS version
        Included patches: 1-1967
        Compiled by siriobalmelli
        Huge version without GUI.  Features included (+) or not (-):
        +acl               -farsi             -mouse_sysmouse    -tag_any_white
        +arabic            +file_in_path      +mouse_urxvt       -tcl
        +autocmd           +find_in_path      +mouse_xterm       +termguicolors
        +autochdir         +float             +multi_byte        +terminal
        -autoservername    +folding           +multi_lang        +terminfo
        -balloon_eval      -footer            -mzscheme          +termresponse
        +balloon_eval_term +fork()            +netbeans_intg     +textobjects
        -browse            +gettext           +num64             +textprop
        ++builtin_terms    -hangul_input      +packages          +timers
        +byte_offset       +iconv             +path_extra        +title
        +channel           +insert_expand     -perl              -toolbar
        +cindent           +job               +persistent_undo   +user_commands
        -clientserver      +jumplist          +postscript        +vartabs
        +clipboard         +keymap            +printer           +vertsplit
        +cmdline_compl     +lambda            +profile           +virtualedit
        +cmdline_hist      +langmap           -python            +visual
        +cmdline_info      +libcall           +python3           +visualextra
        +comments          +linebreak         +quickfix          +viminfo
        +conceal           +lispindent        +reltime           +vreplace
        +cryptv            +listcmds          +rightleft         +wildignore
        +cscope            +localmap          +ruby              +wildmenu
        +cursorbind        +lua               +scrollbind        +windows
        +cursorshape       +menu              +signs             +writebackup
        +dialog_con        +mksession         +smartindent       -X11
        +diff              +modify_fname      -sound             -xfontset
        +digraphs          +mouse             +spell             -xim
        -dnd               -mouseshape        +startuptime       -xpm
        -ebcdic            +mouse_dec         +statusline        -xsmp
        +emacs_tags        -mouse_gpm         -sun_workshop      -xterm_clipboard
        +eval              -mouse_jsbterm     +syntax            -xterm_save
        +ex_extra          +mouse_netterm     +tag_binary        
        +extra_search      +mouse_sgr         -tag_old_static    
           system vimrc file: "$VIM/vimrc"
             user vimrc file: "$HOME/.vimrc"
         2nd user vimrc file: "~/.vim/vimrc"
              user exrc file: "$HOME/.exrc"
               defaults file: "$VIMRUNTIME/defaults.vim"
          fall-back for $VIM: "
        /nix/store/v7m2vgz50kj9hkw5q0gsndra5fg6b3m0-vim_configurable-8.1.1967/share/vim
        "
        Compilation: see nix-store --read-log /nix/store/v7m2vgz50kj9hkw5q0gsndra5fg6b3m0-vim_configurable-8.1.1967
        Linking: see nix-store --read-log /nix/store/v7m2vgz50kj9hkw5q0gsndra5fg6b3m0-vim_configurable-8.1.1967
        ```
        ```vim
        :echo g:ycm_python_binary_path
        /nix/store/vv33j9dqwlp8pk689q3d9xpgp4nacp4h-python3-3.7.4/bin/python
        ```
        ```bash
        $ /nix/store/vv33j9dqwlp8pk689q3d9xpgp4nacp4h-python3-3.7.4/bin/python
        Python 3.7.4 (default, Sep  6 2019, 22:36:03)
        [Clang 7.1.0 (tags/RELEASE_710/final)] on darwin
        >>> quit()
        ```

    - python2.7 with `huge` version:
        ```bash
        $ result/bin/vim --version
        VIM - Vi IMproved 8.1 (2018 May 18, compiled Sep 17 2019 21:51:33)
        macOS version
        Included patches: 1-1967
        Compiled by siriobalmelli
        Huge version without GUI.  Features included (+) or not (-):
        +acl               -farsi             -mouse_sysmouse    -tag_any_white
        +arabic            +file_in_path      +mouse_urxvt       -tcl
        +autocmd           +find_in_path      +mouse_xterm       +termguicolors
        +autochdir         +float             +multi_byte        +terminal
        -autoservername    +folding           +multi_lang        +terminfo
        -balloon_eval      -footer            -mzscheme          +termresponse
        +balloon_eval_term +fork()            +netbeans_intg     +textobjects
        -browse            +gettext           +num64             +textprop
        ++builtin_terms    -hangul_input      +packages          +timers
        +byte_offset       +iconv             +path_extra        +title
        +channel           +insert_expand     -perl              -toolbar
        +cindent           +job               +persistent_undo   +user_commands
        -clientserver      +jumplist          +postscript        +vartabs
        +clipboard         +keymap            +printer           +vertsplit
        +cmdline_compl     +lambda            +profile           +virtualedit
        +cmdline_hist      +langmap           +python            +visual
        +cmdline_info      +libcall           -python3           +visualextra
        +comments          +linebreak         +quickfix          +viminfo
        +conceal           +lispindent        +reltime           +vreplace
        +cryptv            +listcmds          +rightleft         +wildignore
        +cscope            +localmap          +ruby              +wildmenu
        +cursorbind        +lua               +scrollbind        +windows
        +cursorshape       +menu              +signs             +writebackup
        +dialog_con        +mksession         +smartindent       -X11
        +diff              +modify_fname      -sound             -xfontset
        +digraphs          +mouse             +spell             -xim
        -dnd               -mouseshape        +startuptime       -xpm
        -ebcdic            +mouse_dec         +statusline        -xsmp
        +emacs_tags        -mouse_gpm         -sun_workshop      -xterm_clipboard
        +eval              -mouse_jsbterm     +syntax            -xterm_save
        +ex_extra          +mouse_netterm     +tag_binary        
        +extra_search      +mouse_sgr         -tag_old_static    
           system vimrc file: "$VIM/vimrc"
             user vimrc file: "$HOME/.vimrc"
         2nd user vimrc file: "~/.vim/vimrc"
              user exrc file: "$HOME/.exrc"
               defaults file: "$VIMRUNTIME/defaults.vim"
          fall-back for $VIM: "
        /nix/store/yrj1l7skyzcgyghhwsm7547dad0xk71m-vim_configurable-8.1.1967/share/vim
        "
        Compilation: see nix-store --read-log /nix/store/yrj1l7skyzcgyghhwsm7547dad0xk71m-vim_configurable-8.1.1967
        Linking: see nix-store --read-log /nix/store/yrj1l7skyzcgyghhwsm7547dad0xk71m-vim_configurable-8.1.1967
        ```
        ```vim
        :echo g:ycm_python_binary_path
        /nix/store/zrmi2pskr5b2h7nmhcamlq9qy4i2zdi7-python-2.7.16/bin/python
        ```
        ```bash
        $ /nix/store/zrmi2pskr5b2h7nmhcamlq9qy4i2zdi7-python-2.7.16/bin/python
        Python 2.7.16 (default, Sep  6 2019, 22:46:49)
        [GCC 4.2.1 Compatible Clang 7.1.0 (tags/RELEASE_710/final)] on darwin
        >>> quit()
        ```

    - python3.7 with `normal` version:
        ```bash
        $ result/bin/vim --version
        VIM - Vi IMproved 8.1 (2018 May 18, compiled Sep 17 2019 14:52:33)
        macOS version
        Included patches: 1-1967
        Compiled by siriobalmelli
        Normal version without GUI.  Features included (+) or not (-):
        +acl               -farsi             -mouse_sysmouse    -tag_any_white
        -arabic            +file_in_path      -mouse_urxvt       -tcl
        +autocmd           +find_in_path      +mouse_xterm       -termguicolors
        +autochdir         +float             +multi_byte        -terminal
        -autoservername    +folding           +multi_lang        +terminfo
        -balloon_eval      -footer            -mzscheme          +termresponse
        -balloon_eval_term +fork()            +netbeans_intg     +textobjects
        -browse            +gettext           +num64             +textprop
        +builtin_terms     -hangul_input      +packages          +timers
        +byte_offset       +iconv             +path_extra        +title
        +channel           +insert_expand     -perl              -toolbar
        +cindent           +job               +persistent_undo   +user_commands
        -clientserver      +jumplist          +postscript        -vartabs
        +clipboard         -keymap            +printer           +vertsplit
        +cmdline_compl     +lambda            -profile           +virtualedit
        +cmdline_hist      -langmap           -python            +visual
        +cmdline_info      +libcall           +python3           +visualextra
        +comments          +linebreak         +quickfix          +viminfo
        -conceal           +lispindent        +reltime           +vreplace
        +cryptv            +listcmds          -rightleft         +wildignore
        -cscope            +localmap          -ruby              +wildmenu
        +cursorbind        -lua               +scrollbind        +windows
        +cursorshape       +menu              +signs             +writebackup
        +dialog_con        +mksession         +smartindent       -X11
        +diff              +modify_fname      -sound             -xfontset
        +digraphs          +mouse             +spell             -xim
        -dnd               -mouseshape        +startuptime       -xpm
        -ebcdic            -mouse_dec         +statusline        -xsmp
        -emacs_tags        -mouse_gpm         -sun_workshop      -xterm_clipboard
        +eval              -mouse_jsbterm     +syntax            -xterm_save
        +ex_extra          -mouse_netterm     +tag_binary        
        +extra_search      +mouse_sgr         -tag_old_static    
           system vimrc file: "$VIM/vimrc"
             user vimrc file: "$HOME/.vimrc"
         2nd user vimrc file: "~/.vim/vimrc"
              user exrc file: "$HOME/.exrc"
               defaults file: "$VIMRUNTIME/defaults.vim"
          fall-back for $VIM: "
        /nix/store/zrd98c8wyzjb41jnrkdaj9id5yxmgzhj-vim_configurable-8.1.1967/share/vim
        "
        Compilation: see nix-store --read-log /nix/store/zrd98c8wyzjb41jnrkdaj9id5yxmgzhj-vim_configurable-8.1.1967
        Linking: see nix-store --read-log /nix/store/zrd98c8wyzjb41jnrkdaj9id5yxmgzhj-vim_configurable-8.1.1967
        ```
        ```vim
        :echo g:ycm_python_binary_path
        /nix/store/vv33j9dqwlp8pk689q3d9xpgp4nacp4h-python3-3.7.4/bin/python
        ```
        ```bash
        $ /nix/store/vv33j9dqwlp8pk689q3d9xpgp4nacp4h-python3-3.7.4/bin/python
        Python 3.7.4 (default, Sep  6 2019, 22:36:03)
        [Clang 7.1.0 (tags/RELEASE_710/final)] on darwin
        >>> quit()
        ```

    - python2.7 with `normal` version:
        ```bash
        $ result/bin/vim --version
        VIM - Vi IMproved 8.1 (2018 May 18, compiled Sep 18 2019 17:25:30)
        macOS version
        Included patches: 1-1967
        Compiled by siriobalmelli
        Normal version without GUI.  Features included (+) or not (-):
        +acl               -farsi             -mouse_sysmouse    -tag_any_white
        -arabic            +file_in_path      -mouse_urxvt       -tcl
        +autocmd           +find_in_path      +mouse_xterm       -termguicolors
        +autochdir         +float             +multi_byte        -terminal
        -autoservername    +folding           +multi_lang        +terminfo
        -balloon_eval      -footer            -mzscheme          +termresponse
        -balloon_eval_term +fork()            +netbeans_intg     +textobjects
        -browse            +gettext           +num64             +textprop
        +builtin_terms     -hangul_input      +packages          +timers
        +byte_offset       +iconv             +path_extra        +title
        +channel           +insert_expand     -perl              -toolbar
        +cindent           +job               +persistent_undo   +user_commands
        -clientserver      +jumplist          +postscript        -vartabs
        +clipboard         -keymap            +printer           +vertsplit
        +cmdline_compl     +lambda            -profile           +virtualedit
        +cmdline_hist      -langmap           +python            +visual
        +cmdline_info      +libcall           -python3           +visualextra
        +comments          +linebreak         +quickfix          +viminfo
        -conceal           +lispindent        +reltime           +vreplace
        +cryptv            +listcmds          -rightleft         +wildignore
        -cscope            +localmap          -ruby              +wildmenu
        +cursorbind        -lua               +scrollbind        +windows
        +cursorshape       +menu              +signs             +writebackup
        +dialog_con        +mksession         +smartindent       -X11
        +diff              +modify_fname      -sound             -xfontset
        +digraphs          +mouse             +spell             -xim
        -dnd               -mouseshape        +startuptime       -xpm
        -ebcdic            -mouse_dec         +statusline        -xsmp
        -emacs_tags        -mouse_gpm         -sun_workshop      -xterm_clipboard
        +eval              -mouse_jsbterm     +syntax            -xterm_save
        +ex_extra          -mouse_netterm     +tag_binary        
        +extra_search      +mouse_sgr         -tag_old_static    
           system vimrc file: "$VIM/vimrc"
             user vimrc file: "$HOME/.vimrc"
         2nd user vimrc file: "~/.vim/vimrc"
              user exrc file: "$HOME/.exrc"
               defaults file: "$VIMRUNTIME/defaults.vim"
          fall-back for $VIM: "
        /nix/store/jic25spjd5rl7ydcp84aib8gsasciqnd-vim_configurable-8.1.1967/share/vim
        "
        Compilation: see nix-store --read-log /nix/store/jic25spjd5rl7ydcp84aib8gsasciqnd-vim_configurable-8.1.1967
        Linking: see nix-store --read-log /nix/store/jic25spjd5rl7ydcp84aib8gsasciqnd-vim_configurable-8.1.1967
        ```
        ```vim
        :echo g:ycm_python_binary_path
        /nix/store/zrmi2pskr5b2h7nmhcamlq9qy4i2zdi7-python-2.7.16/bin/python
        ```
        ```bash
        $ /nix/store/zrmi2pskr5b2h7nmhcamlq9qy4i2zdi7-python-2.7.16/bin/python
        Python 2.7.16 (default, Sep  6 2019, 22:46:49)
        [GCC 4.2.1 Compatible Clang 7.1.0 (tags/RELEASE_710/final)] on darwin
        >>> quit()
        ```

1. Issue persists with multiple versions of youcompleteme
(all against Vim 8.1.1967, "huge" build, python3.7):
    - 5274b73fc26deb5704733e0efbb4b2d53dc6dc9c (2019-08-31)
    - fa92f40d0209469a037196fdc3d949ae29d0c30a (2019-07-15)
    - d556a43c1af6a4e4075e875934e250f589df0dee (2019-06-29)
    - 032281307dddeabdb0173b5fcd54b283e950d4ce (2019-02-16)

1. Affects multiple versions of Vim:
(all against youcompleteme `2019-08-31`; vim "huge" build, python3.7):
    - 8.1.1967

1. Affects multiple versions of Darwin.

    ```bash
    # bug present on macOS Sierra
    nix-shell -p nix-info --run "nix-info -m"
     - system: `"x86_64-darwin"`
     - host os: `Darwin 16.7.0, macOS 10.12.6`
     - multi-user?: `no`
     - sandbox: `no`
     - version: `nix-env (Nix) 2.3`
     - channels(siriobalmelli): `"nixpkgs"`
     - nixpkgs: `/Users/siriobalmelli/.nix-defexpr/channels/nixpkgs`
    ```

    ```bash
    # TODO: Mojave also
    ```
