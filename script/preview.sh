#!/bin/bash
echo "got $@"
exit 0
/usr/bin/qlmanage -p "$@" >/dev/null 2>&1 &
