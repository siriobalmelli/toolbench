#!/usr/bin/env python3
# arbitrary (and inefficient) math on an IP address

import ipaddress
import sys

print(eval('ipaddress.ip_address("' + sys.argv[1] + '")' + ' '.join(sys.argv[2:])))
