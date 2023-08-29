#!/usr/bin/env python

import json, numpy as np, matplotlib.pyplot as plt

def color_int2tuple(colorint):
    # https://stackoverflow.com/a/2262152, License https://creativecommons.org/licenses/by-sa/2.5/
    return ((colorint >> 16) & 255, (colorint >> 8) & 255, colorint & 255)

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
    if len(argv) >= 3:
        rotate_method = argv[2]
    else:
        rotate_method = "0"
    match rotate_method:
        case "0" | "-0":
            pass
        case "+180" | "180" | "-180":
            plts = np.flip(plts,(0,1))
        case "+90" | "90" | "-270":
            plts = np.rot90(plts, axes = (0,1))
        case "-90" | "270" | "+270":
            plts = np.rot90(plts, k = -1, axes = (0,1))
    print(plts)
    plt.imshow(plts)
    plt.show()
    return 0

if __name__ == "__main__":
    from sys import argv, exit
    exit(main(argv))