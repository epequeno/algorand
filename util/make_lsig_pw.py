#!/usr/bin/env python3
import hashlib
import base64
import sys
print(base64.b64encode(hashlib.sha256(str(sys.argv[1]).encode('utf-8')).digest()).decode('utf-8'))