# Homies

![homies](./homies.png)

The portable toolshed ... aka:
reproducible set of dotfiles and packages for Linux and macOS

---

Forked from <https://github.com/nmattia/homies> and then customized,
many thanks to [Mr. Mattia](https://github.com/nmattia).

To set up a new machine (or update an existing machine),
run [script/install.sh](script/install.sh).

The homies will be available in all subsequent shells, including the
customizations (vim with my favorite plugins, tmux with my customized
configuration, etc). See the [introduction blog post][post] for an overview.

[post]: http://nmattia.com/posts/2018-03-21-nix-reproducible-setup-linux-macos.html

## How-To

Trying out the package set:

``` shell
nix-shell --pure
```

Installing the package set:

``` shell
nix-env -f default.nix -i --remove-all
```

Listing the currently installed packages:

``` shell
nix-env -q
```

Listing the previous and current configurations:

``` shell
nix-env --list-generations
```

Rolling back to the previous configuration:

``` shell
nix-env --rollback
```

Deleting old configurations:

``` shell
nix-env --delete-generations [3 4 9 | old | 30d]
```
