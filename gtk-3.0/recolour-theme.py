#!/usr/bin/env python3
"""Recolour a stock GTK stylesheet into the Tokyo Night palette.

GTK's own Adwaita/Default stylesheets are built from SASS with every colour
baked in, so `@define-color` overrides alone only reach a fraction of the
widgets.  This script reads a stock stylesheet, keeps *only* the declarations
that carry a colour, maps each colour into the Tokyo Night palette, and writes
an override stylesheet that gtk.css imports at user priority.  Geometry,
spacing and icon assets are left entirely to the stock theme.

Regenerate:

  # GTK 3
  gresource extract /usr/lib/libgtk-3.so.0 \
      /org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css > /tmp/src.css
  ./recolour-theme.py /tmp/src.css tokyonight-adwaita.css

  # GTK 4
  gresource extract /usr/lib/libgtk-4.so.1 \
      /org/gtk/libgtk/theme/Default/Default-dark.css > /tmp/src.css
  ./recolour-theme.py --flatten /tmp/src.css ../gtk-4.0/tokyonight-default.css

--flatten replaces gradient background-images with `none`; use it for GTK 4 so
libadwaita's flat surfaces survive and the stock grey gradients cannot paint
over the recoloured background-color.

Palette must stay in sync with foot/foot.ini and mako/config.
"""
import colorsys
import re
import sys

# --- palette ---------------------------------------------------------------

# Adwaita's dark palette is noticeably lighter and greyer than Tokyo Night, so
# preserving a colour's lightness is not enough -- the colours GTK actually
# leans on are pinned explicitly. ANCHORS is the whole visual identity of the
# theme; the ramp and hue families below only catch the long tail.
ANCHORS = {
    # text
    "#eeeeec": "#c0caf5", "#ffffff": "#c0caf5", "#919190": "#787c99",
    "#8a8a89": "#787c99",
    # surfaces (Adwaita: bg #353535 > button #303030 > base #2d2d2d > border #1b1b1b)
    "#353535": "#1a1b26",   # window background
    "#303030": "#24283b",   # buttons and other raised surfaces
    "#2d2d2d": "#16161e",   # entries, text views, list backgrounds
    "#323232": "#1f2335",   # insensitive background
    "#313131": "#222436",
    "#282828": "#1b1d2b",
    "#262626": "#16161e",
    "#202020": "#16161e",
    "#1b1b1b": "#13141d",   # borders: kept darker than the background, as Adwaita has them
    "#141414": "#0d0f17",
    "#070707": "#0a0b10",
    "#030c17": "#0d0f17",
    "#020202": "#050609",
    "#000000": "#000000",   # shadows stay black
    "#5b5b5b": "#3b4261", "#5a5a5a": "#3b4261", "#3a3a39": "#292e42",
    # selection / accent
    "#15539e": "#8478de",   # selected background
    "#0f3b71": "#5a4fa8",   # its darker variant
    "#1b6acb": "#9d8cef",
    "#3584e4": "#9d8cef",
    # semantic
    "#cc0000": "#f7768e", "#e01b24": "#f7768e", "#b2161d": "#db5a70",
    "#f6d32d": "#e0af68", "#f5c211": "#e0af68", "#e5a50a": "#e0af68",
    "#4e9a06": "#7dcfff", "#26a269": "#7dcfff", "#33d17a": "#7dcfff",
    "#2ec27e": "#7dcfff",
}

# Fallback for unanchored greys, compressed into Tokyo Night's darker range.
GREY_RAMP = [
    (0.00, "#000000"), (0.03, "#0a0b10"), (0.08, "#0d0f17"), (0.12, "#15161e"),
    (0.17, "#1a1b26"), (0.22, "#1f2335"), (0.28, "#24283b"), (0.34, "#292e42"),
    (0.42, "#2f334d"), (0.52, "#3b4261"), (0.62, "#565f89"), (0.72, "#787c99"),
    (0.82, "#9aa5ce"), (0.90, "#a9b1d6"), (0.95, "#c0caf5"), (1.00, "#ffffff"),
]

# Saturated colours with no anchor adopt a Tokyo Night hue from their family.
FAMILIES = [
    #  hue range (inclusive lo, exclusive hi)  ->  palette colour supplying hue+saturation
    ((170, 260), "#8478de"),   # blue           -> accent purple
    ((260, 330), "#bb9af7"),   # purple         -> light purple
    ((330, 361), "#f7768e"),   # pink/red       -> red
    ((0,    20), "#f7768e"),   # red            -> red
    ((20,   70), "#e0af68"),   # orange/yellow  -> yellow
    ((70,  170), "#7dcfff"),   # green/cyan     -> cyan (this palette has no green)
]

NAMED = {
    "white": "#ffffff", "black": "#000000", "gray": "#808080", "grey": "#808080",
    "red": "#ff0000", "green": "#008000", "blue": "#0000ff", "silver": "#c0c0c0",
}

# Declarations worth carrying over; everything else is left to the stock theme.
COLOUR_PROPS = re.compile(
    r"^(color|background|background-color|background-image|border|border-color"
    r"|border-top-color|border-right-color|border-bottom-color|border-left-color"
    r"|outline|outline-color|box-shadow|text-shadow|-gtk-icon-shadow|caret-color"
    r"|-gtk-secondary-caret-color|text-decoration-color|fill|stroke)$")

# Values we must not touch: they pull in image assets from the stock theme.
OPAQUE_VALUE = re.compile(r"url\(|-gtk-recolor|-gtk-icontheme|-gtk-scaled|image\(")

COLOUR_TOKEN = re.compile(
    r"#[0-9a-fA-F]{8}\b|#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b"
    r"|rgba?\((?:[^()]|\([^()]*\))*\)"
    r"|\b(?:" + "|".join(NAMED) + r")\b")


def hex_to_rgb(h):
    h = h.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def ramp(lum):
    for i in range(len(GREY_RAMP) - 1):
        l0, c0 = GREY_RAMP[i]
        l1, c1 = GREY_RAMP[i + 1]
        if l0 <= lum <= l1:
            t = 0 if l1 == l0 else (lum - l0) / (l1 - l0)
            a, b = hex_to_rgb(c0), hex_to_rgb(c1)
            return tuple(round(x + (y - x) * t) for x, y in zip(a, b))
    return hex_to_rgb(GREY_RAMP[-1][1])


def map_rgb(r, g, b):
    """Map one sRGB triple into the Tokyo Night palette."""
    anchor = ANCHORS.get("#%02x%02x%02x" % (r, g, b))
    if anchor:
        return hex_to_rgb(anchor)
    h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
    if s <= 0.10:                       # grey: place it on the ramp by luminance
        lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255
        return ramp(lum)
    deg = h * 360
    for (lo, hi), base in FAMILIES:
        if lo <= deg < hi:
            bh, bl, bs = colorsys.rgb_to_hls(*[c / 255 for c in hex_to_rgb(base)])
            # pull the lightness most of the way to the palette's own tone,
            # keeping just enough of the source to preserve ordering between
            # a colour and its hover/active variants
            nl = min(max(0.35 * l + 0.65 * bl, 0.18), 0.88)
            nr, ng, nb = colorsys.hls_to_rgb(bh, nl, bs)
            return tuple(round(c * 255) for c in (nr, ng, nb))
    return (r, g, b)


def convert(token):
    t = token.strip()
    low = t.lower()
    if low in NAMED:
        r, g, b = hex_to_rgb(NAMED[low])
        nr, ng, nb = map_rgb(r, g, b)
        return "#%02x%02x%02x" % (nr, ng, nb)
    if t.startswith("#"):
        body = t[1:]
        alpha = ""
        if len(body) == 8:
            alpha, body = body[6:], body[:6]
        r, g, b = hex_to_rgb("#" + body)
        nr, ng, nb = map_rgb(r, g, b)
        return "#%02x%02x%02x%s" % (nr, ng, nb, alpha)
    m = re.match(r"rgba?\((?:[^()]|\([^()]*\))*\)", t, re.I)
    if not m:
        return t
    inner = t[t.index("(") + 1:t.rindex(")")]
    if inner.lstrip().lower().startswith("from"):
        # relative colour syntax: only the base colour needs remapping
        return t[:t.index("(") + 1] + re.sub(
            r"#[0-9a-fA-F]{3,8}\b", lambda mm: convert(mm.group(0)), inner
        ) + ")"
    m = re.match(r"rgba?\(\s*([^)]*)\)", t, re.I)
    if not m:
        return t
    parts = [p.strip() for p in re.split(r"[,\s/]+", m.group(1)) if p.strip()]
    try:
        nums = [float(p.rstrip("%")) for p in parts[:3]]
        if any(p.endswith("%") for p in parts[:3]):
            nums = [n * 2.55 for n in nums]
        nr, ng, nb = map_rgb(*[int(round(n)) for n in nums])
    except (ValueError, TypeError):
        return t
    if len(parts) > 3:
        return "rgba(%d, %d, %d, %s)" % (nr, ng, nb, parts[3])
    return "rgb(%d, %d, %d)" % (nr, ng, nb)


def recolour(value):
    return COLOUR_TOKEN.sub(lambda m: convert(m.group(0)), value)


def split_decls(body):
    """Split a declaration block, respecting parentheses."""
    out, depth, cur = [], 0, ""
    for ch in body:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == ";" and depth == 0:
            out.append(cur); cur = ""
        else:
            cur += ch
    if cur.strip():
        out.append(cur)
    return out


def keep(decl, flatten=False):
    if ":" not in decl:
        return None
    prop, _, value = decl.partition(":")
    prop, value = prop.strip(), value.strip()
    if not COLOUR_PROPS.match(prop):
        return None
    if OPAQUE_VALUE.search(value):
        return None
    if not COLOUR_TOKEN.search(value):
        return None
    if flatten and prop == "background-image" and "gradient(" in value:
        # GTK4: libadwaita draws flat surfaces, so drop the stock theme's
        # gradients instead of recolouring them -- a gradient would paint over
        # our background-color and reintroduce the grey we are replacing.
        return "background-image: none"
    return f"{prop}: {recolour(value)}"


def parse(css):
    """Yield (selector, body) pairs, keeping @keyframes blocks whole."""
    css = re.sub(r"/\*.*?\*/", "", css, flags=re.S)
    i, n = 0, len(css)
    while i < n:
        brace = css.find("{", i)
        if brace == -1:
            break
        selector = css[i:brace].strip()
        depth, j = 1, brace + 1
        while j < n and depth:
            if css[j] == "{":
                depth += 1
            elif css[j] == "}":
                depth -= 1
            j += 1
        yield selector, css[brace + 1:j - 1]
        i = j


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    flatten = "--flatten" in sys.argv
    src, dst = args[0], args[1]
    css = open(src).read()
    out = [
        "/* Generated by recolour-theme.py - do not edit by hand.",
        f" * Source: {src}",
        " * Only colour-bearing declarations are kept; geometry and icon assets",
        " * still come from the stock theme underneath.",
        " */",
        "",
    ]
    rules = dropped = 0
    for selector, body in parse(css):
        if selector.startswith("@keyframes"):
            inner = []
            for step, sbody in parse(body):
                decls = [d for d in (keep(x, flatten) for x in split_decls(sbody)) if d]
                if decls:
                    inner.append("  %s { %s; }" % (step, "; ".join(decls)))
            if inner:
                out.append("%s {\n%s\n}" % (selector, "\n".join(inner)))
                rules += 1
            continue
        if selector.startswith("@"):
            continue
        decls = [d for d in (keep(x, flatten) for x in split_decls(body)) if d]
        if decls:
            out.append("%s { %s; }" % (selector, "; ".join(decls)))
            rules += 1
        else:
            dropped += 1
    open(dst, "w").write("\n".join(out) + "\n")
    print(f"{dst}: {rules} rules written, {dropped} colourless rules skipped")


if __name__ == "__main__":
    main()
