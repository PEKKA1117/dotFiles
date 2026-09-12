#!/usr/bin/env python3
"""Recolour the KvArcDark Kvantum SVG into the Tokyo Night palette used by foot/mako.

Regenerate KvTokyoNight.svg after an upstream KvArcDark update:

    ./recolour-from-arc.py /usr/share/Kvantum/KvArcDark/KvArcDark.svg KvTokyoNight.svg

If upstream introduces a colour that is not in MAP the script says so and falls
back to the luminance ramp; add an explicit entry for anything structural.
The matching [GeneralColors] block lives in KvTokyoNight.kvconfig and is
maintained by hand.
"""
import re, sys

# Arc -> Tokyo Night. Accents first, then the structural blue-grey ramp.
MAP = {
    # accents
    "#5294e2": "#8478de",  # Arc blue -> main accent purple
    "#4693e6": "#7aa2f7",
    "#3176bf": "#6a8ad4",
    "#0582ff": "#7aa2f7",
    "#58acff": "#9d8cef",
    "#b74aff": "#bb9af7",
    "#f04a50": "#f7768e",
    # surfaces
    "#383c4a": "#1a1b26", "#404552": "#24283b", "#3c404e": "#222436",
    "#22252e": "#16161e", "#2d303b": "#1a1b26", "#2f343f": "#1b1d2b",
    "#343844": "#1f2335", "#363c48": "#20222f", "#474d5d": "#2f334d", "#505666": "#3b4261",
    "#4d5367": "#394260", "#444a58": "#2a2f45", "#111217": "#0d0f17",
    "#262933": "#16161e", "#2d323d": "#1a1b26", "#2b2e39": "#191a24",
    "#5a616e": "#3b4261", "#474d5b": "#2f334d", "#323542": "#1d1f2e",
    "#31353f": "#1c1e2b", "#22242e": "#16161e", "#222224": "#15161e",
    "#1e1e1e": "#131420", "#141414": "#0f1017", "#000000": "#000000",
    # greys / text
    "#92959d": "#787c99", "#d7d7d7": "#c0caf5", "#b4b4b4": "#a9b1d6",
    "#5a5a5a": "#414868", "#444448": "#292e42", "#969696": "#9aa5ce",
    "#7b7b7b": "#565f89", "#767b87": "#565f89", "#505050": "#3b4261",
    "#d2d2d2": "#bcc4e8", "#c3c3c3": "#a9b1d6", "#acb1bc": "#9aa5ce",
    "#a0a0a0": "#9aa5ce", "#787878": "#565f89",
    # 3-digit shorthands
    "#000": "#000", "#fff": "#c0caf5", "#666": "#565f89", "#39f": "#7aa2f7",
}

# Luminance ramp, used only if the SVG gains a colour we have not mapped.
RAMP = [(0.00, "#0d0f17"), (0.06, "#16161e"), (0.10, "#1a1b26"), (0.16, "#24283b"),
        (0.22, "#2f334d"), (0.30, "#3b4261"), (0.38, "#414868"), (0.50, "#565f89"),
        (0.62, "#787c99"), (0.74, "#9aa5ce"), (0.84, "#a9b1d6"), (0.92, "#c0caf5"),
        (1.00, "#ffffff")]

def rgb(h):
    h = h.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))

def ramp(h):
    r, g, b = rgb(h)
    lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0
    for i in range(len(RAMP) - 1):
        l0, c0 = RAMP[i]
        l1, c1 = RAMP[i + 1]
        if l0 <= lum <= l1:
            t = (lum - l0) / (l1 - l0)
            return "#%02x%02x%02x" % tuple(
                round(a + (b2 - a) * t) for a, b2 in zip(rgb(c0), rgb(c1)))
    return RAMP[-1][1]

unmapped = set()

def sub(m):
    key = m.group(0).lower()
    if key in MAP:
        return MAP[key]
    unmapped.add(key)
    return ramp(key)

src, dst = sys.argv[1], sys.argv[2]
with open(src) as f:
    svg = f.read()
out = re.sub(r"#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b", sub, svg)
with open(dst, "w") as f:
    f.write(out)

print(f"wrote {dst}")
print("unmapped (fell back to luminance ramp):", sorted(unmapped) or "none")
