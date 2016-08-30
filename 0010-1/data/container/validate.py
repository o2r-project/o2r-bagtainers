#!/usr/bin/env python3
import sys
import bagit
bag = bagit.Bag(sys.argv[1])
print("[validate.py] Is bag valid?", bag.validate())
if bag.validate():
    sys.exit(0)
else:
    sys.exit("[validate.py] Bag is not valid!")
