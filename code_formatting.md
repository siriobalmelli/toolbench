# Code Cleanup and Formatting Tricks

## C

1. Clean up "dangling pointer asterisks" eg `int * p_not_well_formatted;`

        sed -E 's/(\w)(\s+)(\*\)?)\s+([a-zA-Z_])/\1\2\3\4/g'

## Python

1. Converting Python `.format()` strings into f-strings:

        sed -E 's/(.*)\(.(.*)\{[0-9]?\}(.*).\.format\((.*)\)\)/\1(f"\2{\4}\3")/g'
