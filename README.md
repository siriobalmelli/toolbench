# Toolbench

![tool](./tool.gif)

The portable toolshed, a reproducible specification for:

- packages (tools, utilities)
- dotfiles (configuration of tools)

... that works across any Linux or macOS and has a single-step, set-up/update procedure:

  ``` bash
  script/install.sh
  ```

NOTE: the packages built here are available in
[this cachix cache](https://app.cachix.org/cache/siriobalmelli-nixpkgs).

---

NOTE: this is my personal toolchain:
I recommend you fork unless you want my workflow preferences overriding yours.

## Why

1. Homogenize tool availability and behavior across systems,
    normalize the entire work environment (or set up a blank machine) in one shot.
    No more:
    - checking what variant of `sed` you're running (GNU extensions?)
    - moving files around to certain systems because *x* tool is *only* installed
      on that machine.
    - sticking with e.g. an old Ubuntu 14.04 machine because it took you hours
      to get the set-up just right.

1. No more dealing with distro-specific package managers:
    - Remembering *what* was that package called in
      [apt-get](https://help.ubuntu.com/community/AptGet/Howto)
      or [yum](https://wiki.centos.org/PackageManagement/Yum)
      or [pacman](https://wiki.archlinux.org/index.php/Pacman)
      or [zypper](https://en.opensuse.org/Portal:Zypper)
      or [portage](https://wiki.gentoo.org/wiki/Portage)
    - installing [MacPorts](https://www.macports.org/) or [Homebrew](https://brew.sh/)
      on macOS.

1. Make workflow tweaks rewarding: fix it once and it's fixed everywhere;
    rice your [vimrc](http://learnvimscriptthehardway.stevelosh.com/chapters/07.html)
    only once.
    No more:
    - separately tracking packages and versions for
      [pip](https://pip.pypa.io/en/stable/installing/)
      and [bundler](https://bundler.io/)
      and [cabal](https://www.haskell.org/cabal/)
      and [npm](https://www.npmjs.com/)
      etc ... on each machine
    - complex "toolchain set-up" shell scripts that break on every new OS release

1. Reasonably future-proof:
    - As [Nix](https://nixos.org/) continues growing, this will work
      seamlessly on other POSIX systems, with no reconfiguration or fussing.
    - Worst-case scenario for moving to a new kernel+ABI is having to contribute
      to the so-called [stdnev](https://nixos.org/nixos/nix-pills/fundamentals-of-stdenv.html)
      port.
    - The GNU people are on board, with [guix](https://www.gnu.org/software/guix/).

## How-To

1. One-shot set-up:

    ``` bash
    # requires 'curl' at the very least
    script/install.sh
    ```

1. Try out the environment (requires [Nix](https://nixos.org/nix/) installation)
  without changing what you have currently:

    ``` bash
    nix-shell --pure
    ```

1. Tweaking/searching/installing packages:

    ``` bash
    # get currently installed packages
    $ nix-env -q
    imagemagick-6.9.9-34
    jq-1.5
    less-530
    llvm-7.0.0
    # ...
    ```

    ``` bash
    # uninstall a package
    nix-env --uninstall jq-1.5
    ```

    ``` bash
    # get a list of available packages:
    $ nix-env -qaP
    nixpkgs._2048-in-terminal    2048-in-terminal-2017-11-29
    nixpkgs._20kly               20kly-1.4
    nixpkgs._2bwm                2bwm-0.2
    nixpkgs.go-2fa               2fa-1.1.0
    nixpkgs._389-ds-base         389-ds-base-1.3.5.19
    nixpkgs.pong3d               3dpong-0.5
    nixpkgs.all-cabal-hashes     70f02ad82349a18e1eff41eea4949be532486f7b.tar.gz
    nixpkgs.tiny8086
    # ...

    # for convenience, `script/install.sh` dumps this list to 'nix_env_avail.txt':
    $ grep gcc nix_env_avail.txt
    # ...
    nixpkgs.avrgcc               avr-gcc-8.2.0
    nixpkgs.gcc7                 gcc-wrapper-7.3.0
    nixpkgs.gcc8                 gcc-wrapper-8.2.0
    # ...
    ```

    ``` bash
    # install a package
    nix-env --install nixpkgs.gcc8
    ```

1. Deal with configuration iterations/generations:

    ``` bash
    # Listing the previous and current configurations:
    nix-env --list-generations
    ```

    ``` bash
    # Rolling back to the previous configuration:
    nix-env --rollback
    ```

    ``` bash
    # Deleting old configurations:
    nix-env --delete-generations [3 4 9 | old | 30d]
    ```

### A note on YouCompleteMe, Nix and "wrappers"

I am big fan of [YCM](https://github.com/Valloric/YouCompleteMe) for Vim.

Getting it working with Nix required writing a new [.ycm_extra_conf.py][conf]
to use `nix-shell` as a way to descry the includes seen by clang/gcc
at compile-time.

To use, you will need to manually copy [.ycm_extra_conf.py][conf]
to the toplevel directory of your project:

```bash
# note that YCM expects '.ycm_extra_conf.py' but we maintain it as
# 'ycm_extra_conf.py' so that it's visible in our repo ;)
cp vim/ycm_extra_conf.py /path/to/my/project/.ycm_extra_conf.py
```

To better understand what's happening, keep in mind that the Nix people use
the term *wrapping* a lot, without giving a straightforward definition.
In a practical context, *wrapping* means
"creating a runtime environment for something".

We can see the "runtime environment" for a compiler by running the preprocessor
verbosely with some null input: `clang -E -Wp,-v - </dev/null`.
This will print the list (and sequence) of locations where `clang` will look
for header files:

1. From my environment:

    ```bash
    $ clang -E -Wp,-v - </dev/null
    #include "..." search starts here:
    #include <...> search starts here:
      /nix/store/fs62wczaxm8svvhwqsyv9nz4cca44lxa-clang-wrapper-7.0.0/resource-root/include
      /nix/store/kvdxajnlyisifi506ppbdpfycmcmsp6d-glibc-2.27-dev/include
    End of search list.
    ```

1. From inside `nix-shell` in some random project:

    ```bash
    $ nix-shell
    [nix-shell]$ clang -E -Wp,-v - </dev/null
    #include "..." search starts here:
    #include <...> search starts here:
      /nix/store/6j3xhdki32ni2admf1dhzvb2dgz0hl4c-dpkg-1.19.0.5/include
      /nix/store/8wg1n5bbhsv81wpyixcvxp547hz3q60x-libarchive-3.3.2-dev/include
      /nix/store/i6a6g9iph5sh5nd5vqf0r6yg1gaxv5g8-libbfd-2.30-dev/include
      /nix/store/dqr18y0x894fsrabwrlbrlhi870bnifc-elfutils-0.173/include
      /nix/store/0hvbn69zcavh8810kzqs1phv1l5f0lnh-liburcu-0.10.1/include
      /nix/store/n5qf4zfs6msxihh2xr8ndc7g9j8kc06v-compiler-rt-5.0.2-dev/include
      /nix/store/sjai00nfvq786fhwi5i0fw5b3qlrx572-clang-wrapper-5.0.2/resource-root/include
      /nix/store/kvdxajnlyisifi506ppbdpfycmcmsp6d-glibc-2.27-dev/include
    End of search list.
    ```

As you can see, the `clang` running inside `nix-shell` is not the same `clang`:
it has been *wrapped* with the project dependencies.
This is exactly the list we get by running `nix-shell` inside [.ycm_extra_conf.py][conf].

[conf]: vim/ycm_extra_conf.py

## Pinned nixpkgs workflow

1. nixpkgs is pinned to a known working state (for both macOS and Linux) in
    <https://github.com/siriobalmelli-foss/nixpkgs/tree/sirio> (my fork).

1. Fork branches are organized as follows:
    - `upstream/master` : track nixpkgs
    - `master` : current stable version (reference this in Nix derivations)
    - *development for upstream* -(commit)-> `fix/per-feature`
    - `fix/per-feature` -(pull requests)-> `upstream/master`
    - `fix/per-feture` -(cherry-pick)-> `sirio`
    - *unmergeable: `vim-plugins/update.py` etc* -(commit)-> `sirio`
    - *working config on Linux and macOS* -(tag sirio_stable_YYYY_MM_DD)-> `master`

## Thanks

1. Originally forked from <https://github.com/nmattia/homies> and then customized,
  many thanks to [Mr. Mattia](https://github.com/nmattia).
  See his [introduction blog post](http://nmattia.com/posts/2018-03-21-nix-reproducible-setup-linux-macos.html)
  for an overview.

1. Many thanks to the [Nix project](https://nixos.org/) and their
  [community on IRC](https://nixos.org/nixos/community.html).
  Also the very helpful advice of [jtojnar](https://github.com/jtojnar)
  in [this issue](https://github.com/NixOS/nixpkgs/issues/44515) which helped
  me grok Nix a bit better.

1. The various Nix resources on the net:
  - [nix pills](https://nixos.org/nixos/nix-pills/index.html)
  - [gentle nix introduction](https://ebzzry.io/en/nix/)
  - [nix cheatsheet](https://learnxinyminutes.com/docs/nix/)

## TODO

There are a couple painpoints:

1. App selection and config file differences:
    - graphical app configs (eg Alacritty) will be different between Linux and Darwin
    - choice of window manager will be different based on OS
    - some systems should *not* have to install the full panoply of packages
        (eg no graphical apps, no heavy LaTeX stuff on a console-only linux VM)

    Explore how others are doing this:

    - [Hugo Reeves](https://hugoreeves.com/posts/2019/nix-home/):
        https://github.com/HugoReeves/nix-home/

1. Homogenization of dependencies:
    Need a way to force a single version of a dependency for all packages, eg
    - clang
    - gcc
    - python = python3 = python3.8

1. Remove boilerplate in config file generation, eg:
    - https://github.com/balsoft/nixos-config/blob/master/modules/workspace/i3blocks/scripts/battery.nix
