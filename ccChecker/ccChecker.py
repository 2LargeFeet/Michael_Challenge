#!/usr/bin/env python3

# The challenge is wrong. When you run the code, it expects a single character to be valid.
# I'm not an expert on credit cards, however I'm reasonably certain a single "6" should be
# considered "Invalid"

import re
import sys
 
for numbers in sys.stdin:
    lines = numbers.splitlines()
    for number in lines:
        unspecial = re.sub("[^0-9]", "", number)
        first = int(unspecial[0])
        print(unspecial)
        if (bool(re.search(r'(\d)\1{3}', unspecial))):
            print ("Invalid")
            continue
        if not(bool(re.search("^[\d\-\/]+$", number))):
            print ("Invalid")
            continue
        if (first < 4 or first > 6):
            print ("Invalid")
            continue
        if (len(unspecial) != 16):
            print ("Invalid")
            continue
        if ("-" in number)and not (bool(re.search("^(?:\w{4}-){3}\w{4}$", number))):
            print ("Invalid")
        else:
            print ("Valid")