#!/usr/bin/env python3
"""Generate the Sudoku app icon assets from code (no external design tool).

Produces, from one vector-ish drawing routine rendered at high resolution:
  assets/icon/icon.png             1024x1024 full-bleed (launcher source / iOS / Play)
  assets/icon/icon_foreground.png  1024x1024 transparent, grid centred in the
                                   adaptive-icon safe zone (~66%)
  _screenshots/app_icon_512.png    512x512 full-bleed, for the Play Console upload

Design: playful indigo gradient, a clean white 3x3 mini-sudoku card, a few cells
filled with bold rounded numerals in the app's accent colours (an X pattern),
the rest left empty for the "puzzle" feel. Matches lib/ui/colors.dart.
"""
from PIL import Image, ImageDraw, ImageFont

# Palette (from lib/ui/colors.dart)
INDIGO = (108, 92, 231)
INDIGO_LIGHT = (138, 124, 240)
INDIGO_DARK = (86, 71, 196)
CORAL = (255, 107, 107)
SUN = (255, 197, 61)
MINT = (50, 210, 150)
WHITE = (255, 255, 255)
GRID_SOFT = (218, 215, 242)

FONT_PATH = "/System/Library/Fonts/SFNSRounded.ttf"

# Supersample factor for crisp anti-aliasing.
SS = 4


def _rounded_mask(size, radius):
    m = Image.new("L", (size, size), 0)
    d = ImageDraw.Draw(m)
    d.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=255)
    return m


def _diagonal_gradient(size, top_left, bottom_right):
    base = Image.new("RGB", (size, size))
    px = base.load()
    for y in range(size):
        for x in range(size):
            t = (x + y) / (2 * (size - 1))
            px[x, y] = tuple(
                int(top_left[i] + (bottom_right[i] - top_left[i]) * t) for i in range(3)
            )
    return base


def draw_grid(img, cx, cy, board_size, filled):
    """Draw a 3x3 sudoku card centred at (cx, cy) with the given board size.

    `filled` maps (row, col) -> (digit, colour).
    """
    d = ImageDraw.Draw(img)
    half = board_size / 2
    x0, y0 = cx - half, cy - half
    cell = board_size / 3
    card_pad = int(cell * 0.14)
    radius = int(cell * 0.36)

    # White card with a soft drop shadow.
    shadow = int(board_size * 0.045)
    d.rounded_rectangle(
        [x0 - card_pad, y0 - card_pad + shadow,
         x0 + board_size + card_pad, y0 + board_size + card_pad + shadow],
        radius=radius + card_pad, fill=(70, 55, 160, 70),
    )
    d.rounded_rectangle(
        [x0 - card_pad, y0 - card_pad,
         x0 + board_size + card_pad, y0 + board_size + card_pad],
        radius=radius + card_pad, fill=WHITE,
    )

    # Soft inner grid lines.
    lw = max(2, int(board_size * 0.012))
    for i in (1, 2):
        gx = x0 + cell * i
        d.line([gx, y0 + cell * 0.06, gx, y0 + board_size - cell * 0.06],
               fill=GRID_SOFT, width=lw)
        gy = y0 + cell * i
        d.line([x0 + cell * 0.06, gy, x0 + board_size - cell * 0.06, gy],
               fill=GRID_SOFT, width=lw)

    # Numerals.
    font = ImageFont.truetype(FONT_PATH, int(cell * 0.62))
    for (r, c), (digit, colour) in filled.items():
        bx = x0 + cell * c + cell / 2
        by = y0 + cell * r + cell / 2
        d.text((bx, by), str(digit), font=font, fill=colour, anchor="mm")


# Balanced X-pattern fill (5 of 9 cells).
FILLED = {
    (0, 0): (5, MINT),
    (0, 2): (3, CORAL),
    (1, 1): (9, INDIGO),
    (2, 0): (1, SUN),
    (2, 2): (7, MINT),
}


def render_full(out_size):
    size = out_size * SS
    grad = _diagonal_gradient(size, INDIGO_LIGHT, INDIGO_DARK)
    grad = grad.convert("RGBA")
    draw_grid(grad, size / 2, size / 2, size * 0.60, FILLED)
    # Full-bleed square: no rounded mask (store / launcher apply their own).
    return grad.resize((out_size, out_size), Image.LANCZOS)


def render_foreground(out_size):
    size = out_size * SS
    layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    # Adaptive safe zone ~66%; keep the card comfortably inside it.
    draw_grid(layer, size / 2, size / 2, size * 0.44, FILLED)
    return layer.resize((out_size, out_size), Image.LANCZOS)


if __name__ == "__main__":
    import os

    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    icon_dir = os.path.join(root, "assets", "icon")
    shots_dir = os.path.join(root, "_screenshots")
    os.makedirs(icon_dir, exist_ok=True)
    os.makedirs(shots_dir, exist_ok=True)

    full_1024 = render_full(1024)
    full_1024.save(os.path.join(icon_dir, "icon.png"))
    render_foreground(1024).save(os.path.join(icon_dir, "icon_foreground.png"))
    render_full(512).save(os.path.join(shots_dir, "app_icon_512.png"))
    print("wrote assets/icon/icon.png, icon_foreground.png, _screenshots/app_icon_512.png")
