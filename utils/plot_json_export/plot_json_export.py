#!/usr/bin/env python
# r_place/utils/plot_json_export/plot_json_export.py
# Generate png from exported JSON
"""
    Copyright (C) 2023  1F616EMO

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
    USA
"""

import orjson, numpy as np, matplotlib.pyplot as plt

def color_int2tuple(colorint):
    # https://stackoverflow.com/a/2262152, License https://creativecommons.org/licenses/by-sa/2.5/
    return ((colorint >> 16) & 255, (colorint >> 8) & 255, colorint & 255)

def main(argv):
    if len(argv) < 2:
        print("Please supply JSON filename in command line.")
        return 1
    filename = argv[1]
    try:
        file = open(filename, "rb")
    except IOError:
        print("Error opening file.")
        raise
    else:
        with file:
            data = orjson.loads(file.read())
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
    plt.figure(facecolor=(0, 0, 0))
    plt.imshow(plts)
    plt.axis('off')
    plt.savefig('out.png', bbox_inches='tight')
    print("Image saved at out.png.")
    return 0

if __name__ == "__main__":
    from sys import argv, exit
    exit(main(argv))