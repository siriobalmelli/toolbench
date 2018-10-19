'''.ycm_extra_conf.py
Generic YouCompleteMe file for clang/gcc C projects using a Nix toolchain.

Install this file as '.ycm_extra_conf.py' at the toplevel of your directory,
next to 'default.nix' and 'meson.build'.

Many, many thanks to Val Marcovic for YouCompleteMe (https://github.com/Valloric/YouCompleteMe)
and for the original prototype for this script.

(c) 2018 Sirio Balmelli
'''
from subprocess import check_output
import os
import ycm_core  # pylint: disable=import-error

# These are the compilation flags that will be used
#+  IN ADDITION TO any flags from the compilation database.
# If you need to add some flags and don't know where,
#+  PUT THEM HERE (aka: THESE ARE THE DROIDS YOU ARE LOOKING FOR).
FLAGS = [
    # NOTE: the flag and the value are two *separate* list elements
    '-I', 'include'  # assume all projects have a toplevel 'include' dir
]


# absolute path for dir of this script (aka: TLD for the project)
DIR = os.path.dirname(os.path.abspath(__file__))

def get_nix_flags():
    '''get_nix_flags()
    Try to run the preprocessor for both clang and gcc inside a nix-shell,
        where they are properly wrapped to see includes for all build inputs.
    Return a list of flags, which may be empty if nix-shell won't run, etc
    '''
    # Run clang (or gcc if no clang) preprocessor with nothing,
    #+ just to see where it might look for header files.
    cmd = r'''\
        cd {0} && \
        nix-shell --command \
            'clang -E -Wp,-v - </dev/null 2>&1 || gcc -E -Wp,-v - </dev/null 2>&1' \
            2>/dev/null \
        | sed -nE 's|\s*(/.*include)$|\1|p'
    '''.format(DIR)
    try:
        lst = [p.strip() for p in
               check_output(cmd, shell=True).split('\n')
              ]
        # prepend an '-isystem' to each path, discarding empty paths
        # NOTE that '-isystem' means these includes will be used last
        # (after flags and compilation db)
        return [flat for p in lst for flat in ['-isystem', p] if p]
    except Exception:  #pylint: disable=broad-except
        return []

def get_compile_db():
    '''get_compile_db()
    Search subdirectories for a compile db (aka: 'compile_commands.json').
    Have ycm_core parse the first db found (if any).
    Return an opaque 'database' object.
    '''
    cmd = r'''\
        find {0} -name compile_commands.json \
            | sort | head -n 1 | xargs dirname 2>/dev/null
    '''.format(DIR)
    try:
        folder = check_output(cmd, shell=True).strip()
        return ycm_core.CompilationDatabase(folder)
    except Exception:  #pylint: disable=broad-except
        return None

def MakeRelativePathsInFlagsAbsolute(flags, working_directory):  # pylint: disable=invalid-name
    '''MakeRelativePathsInFlagsAbsolute()
    Unsure what this does exactly:
        lifted directly from Valloric's original file,
        then cleaned it up so it will lint.
    '''
    if not working_directory:
        return list(flags)
    new_flags = []

    make_next_absolute = False
    remove_next = False
    remove_this = False
    path_flags = ['-isystem', '-I', '-iquote', '--sysroot=']
    for flag in flags:
        new_flag = flag

        if remove_next:
            remove_next = False
            remove_this = True

        if make_next_absolute:
            make_next_absolute = False
            if not flag.startswith('/'):
                new_flag = os.path.join(working_directory, flag)

        for path_flag in path_flags:
            if flag == path_flag:
                make_next_absolute = True
                break

            if flag.startswith(path_flag):
                path = flag[len(path_flag):]
                new_flag = path_flag + os.path.join(working_directory, path)
                break

            # Remove the -c compiler directive (necessary to get header files compiling...)
            # YouCompleteMe seems to remove this directive correctly for the cpp files,
            # but not the header files.
            if flag == '-c':
                remove_next = True
                break

        if new_flag and not remove_next and not remove_this:
            new_flags.append(new_flag)

        if remove_this:
            remove_this = False
    return new_flags


def FlagsForFile(filename):  # pylint: disable=invalid-name
    '''FlagsForFile()
    This seems to be the entry point for ycm_core to call into this script.
    '''
    database = get_compile_db()
    if database:
        # Swap .h and .cpp files
        # Check to see if given file is a .h file, if so, swap .h and .cpp then
        # perform the lookup. This is because .h files are not included in the
        # compilation database. See: https://github.com/Valloric/YouCompleteMe/issues/174.
        # We should also resort to a minimum set of flags that work inside the
        # standard library if we can't find the compilation database entry.
        base_filename, file_extension = os.path.splitext(filename)
        if file_extension == '.h':
            filename = base_filename + '.c'

        # Bear in mind that compilation_info.compiler_flags_ does NOT return a
        # python list, but a "list-like" StringVec object
        compilation_info = database.GetCompilationInfoForFile(filename)
        final_flags = MakeRelativePathsInFlagsAbsolute(
            compilation_info.compiler_flags_,
            compilation_info.compiler_working_dir_)
    else:
        final_flags = []

    final_flags += get_nix_flags()
    final_flags += MakeRelativePathsInFlagsAbsolute(FLAGS, DIR)
    final_flags += [
        # This -x option is necessary in order to compile header files (as C files).
        '-x', 'c',
        # On macOS, I need this in order to find the system libraries.
        # See: https://github.com/Valloric/YouCompleteMe/issues/303
        '-isystem', '/usr/lib/c++/v1'
        ]

    return {
        'flags': final_flags,
        'do_cache': True
    }
