#!/usr/bin/env python

import json, numpy as np, matplotlib.pyplot as plt

def color_int2tuple(colorint):
    # https://stackoverflow.com/a/2262152, License https://creativecommons.org/licenses/by-sa/2.5/
    return (colorint & 255, (colorint >> 8) & 255, (colorint >> 16) & 255)

def main(argv):
    if len(argv) < 2:
        print("Please supply JSON filename in command line.")
        return 1
    filename = argv[1]
    try:
        file = open(filename, "r")
    except IOError:
        print("Error opening file.")
        raise
    else:
        with file:
            data = json.load(file)
    assert "map" in data, "Invalid JSON savefile format"
    plts = np.array(tuple(tuple(color_int2tuple(int(c)) for c in r) for r in data["map"]), dtype=np.uint8)
    plt.imshow(plts)
    plt.show()
    return 0

if __name__ == "__main__":
    from sys import argv, exit
    exit(main(argv))