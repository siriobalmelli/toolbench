# Toolbench

![tool](./tool.gif)

The portable toolshed: a reproducible specification for:

- packages (tools, utilities)
- dotfiles (configuration of tools)

... that works across any Linux or macOS and has a single-step, set-up/update procedure:

  ``` bash
  script/install.sh
  ```

---

NOTE: this is my personal toolchain:
I recommend you fork unless you want my workflow preferences overriding yours.

## Why

1. Homogenizes tool availability and behavior across systems,
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

1. Makes workflow tweaks rewarding: fix it once and it's fixed everywhere;
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

- As [Nix](https://nixos.org/) continues growing, this approach will work
  seamlessly on other POSIX systems, with no reconfiguration or fussing.
- Your worst-case scenario for moving to a new kernel+ABI is having to contribute
  to the so-called [stdnev](https://nixos.org/nixos/nix-pills/fundamentals-of-stdenv.html)
  port for that configuration.
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

1. Tweaking/searching installed packages:

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

### A note on YouCompleteMe

I am big fan of [YCM](https://github.com/Valloric/YouCompleteMe) for Vim;
getting it working with Nix required writing a new [.ycm_extra_conf.py][conf]
to use `nix-shell` as a way to descry the includes seen by clang/gcc
at compile-time.

YCM is already compiled into this toolchain, but you will need to manually
copy [.ycm_extra_conf.py][conf] to the toplevel directory of your project:

```bash
# note that YCM expects '.ycm_extra_conf.py' but we maintain it as
# 'ycm_extra_conf.py' so that it's visible in our repo ;)
cp vim/ycm_extra_conf.py /path/to/my/project/.ycm_extra_conf.py
```

[conf]: vim/ycm_extra_conf.py

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
