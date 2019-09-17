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

1. Output of `vim --version`

    ```bash
    # compiled with "huge" featureset
    ```

    This same bug is also reproducible with a much smaller featureset:

    ```bash
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

1. Python binary path seems correct:

    ```vim
    :echo g:ycm_python_binary_path
    /nix/store/vv33j9dqwlp8pk689q3d9xpgp4nacp4h-python3-3.7.4/bin/python
    ```

    This works fine:
    ```bash
    $ /nix/store/vv33j9dqwlp8pk689q3d9xpgp4nacp4h-python3-3.7.4/bin/python
    Python 3.7.4 (default, Sep  6 2019, 22:36:03)
    [Clang 7.1.0 (tags/RELEASE_710/final)] on darwin
    Type "help", "copyright", "credits" or "license" for more information.
    >>> quit()
    ```

1. Affects multiple versions of youcompleteme:
    - 5274b73fc26deb5704733e0efbb4b2d53dc6dc9c (current)
    - fa92f40d0209469a037196fdc3d949ae29d0c30a (2019-07-15)
    - d556a43c1af6a4e4075e875934e250f589df0dee (2019-06-29)

1. Affects macOS `10.14.6` and `10.12.6`
