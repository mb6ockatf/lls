#!/usr/bin/env python3
from sys import argv, exit


try:
    file = argv[1]
    pattern = argv[2]
except IndexError:
    print("Usage: ./main.py <filename> <string>")
    exit(1)
with open(file, "r") as filestream:
    for line in filestream.readlines():
        if pattern in line:
            print(line)
