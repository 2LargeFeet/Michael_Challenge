#!/usr/bin/env python3

import re
import sys
import string

with open ('ccNumbers.txt') as numbers:
    lines = numbers.read().splitlines()
    for number in lines:
        first = int(number[0])
        unspecial = re.sub("[^0-9]", "", number)
        if (bool(re.search(r'(\d)\1{3}', unspecial))):
            print ("Invalid")
            continue
        if (first < 4 or first > 6):
            print(f"Invalid")
            continue
        if (len(unspecial) != 16):
            print ("Invalid")
            continue
        if not(bool(re.search("^[0-9\-\/]+$", number))):
            print ("Invalid")
            continue
        if ("-" in number)and not (bool(re.search("^(?:\w{4}-){3}\w{4}$", number))):
            print ("Invalid")
        else:
            print ("Valid")