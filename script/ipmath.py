#!/usr/bin/env python3
# arbitrary (and inefficient) math on an IP address

from ipaddress import ip_address
import sys

print(eval('ip_address("' + sys.argv[1] + '")' + ' '.join(sys.argv[2:])))
