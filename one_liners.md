# personal reference of useful one-liners

1. re-apply all pending branches on top of own nixpkgs build:

        git b | sed -Ee '/(sirio|master)/ d' -ne 's/. (.*)/\1/p' | xargs -I{} git merge --no-ff {}

1. Clean up "dangling pointer asterisks" in C, eg `int * p_not_well_formatted;`

        sed -E 's/(\w)(\s+)(\*\)?)\s+([a-zA-Z_])/\1\2\3\4/g'

1. Converting Python `.format()` strings into f-strings:

        sed -E 's/(.*)\(.(.*)\{[0-9]?\}(.*).\.format\((.*)\)\)/\1(f"\2{\4}\3")/g'
