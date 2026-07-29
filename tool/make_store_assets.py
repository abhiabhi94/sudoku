#!/usr/bin/env python3
"""Turn raw emulator captures into upload-ready Play Store assets.

Inputs : _screenshots/raw/*.png  (raw 1080x2400 device captures)
Outputs: _screenshots/phone_*.png       framed 1080x1920 (9:16) phone screenshots
         _screenshots/feature_graphic.png  1024x500 store banner

The raw captures are 9:20 (too tall for the Play 9:16 limit), so each is
scaled onto a branded 1080x1920 canvas with a short caption — the standard
store-listing treatment, which also reads as more polished than a bare grab.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
RAW = os.path.join(ROOT, "_screenshots", "raw")
OUT = os.path.join(ROOT, "_screenshots")
sys.path.insert(0, HERE)
import make_icon as ic  # noqa: E402  (palette + grid drawing)

FONT = "/System/Library/Fonts/SFNSRounded.ttf"

# One cohesive indigo backdrop for every frame; white text pops on it.
BG_TOP = (124, 107, 240)
BG_BOTTOM = (86, 71, 196)
WHITE = (255, 255, 255)

# (raw file, caption) — order is the listing order.
SHOTS = [
    ("01_home.png", "Numbers, but make it fun"),
    ("02_play.png", "A board built for thumbs"),
    ("03_riddle.png", "Crack a riddle, earn a hint"),
    ("04_lockout.png", "Forgiving, not frustrating"),
    ("05_victory.png", "Celebrate every solve"),
    ("06_tiers.png", "3 tiers, 30 levels, endless boards"),
]


def vertical_gradient(w, h, top, bottom):
    base = Image.new("RGB", (w, h))
    px = base.load()
    for y in range(h):
        t = y / (h - 1)
        row = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        for x in range(w):
            px[x, y] = row
    return base


def wrap(draw, text, font, max_w):
    words = text.split()
    lines, cur = [], ""
    for w in words:
        trial = (cur + " " + w).strip()
        if draw.textlength(trial, font=font) <= max_w:
            cur = trial
        else:
            lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def rounded(img, radius):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, img.width - 1, img.height - 1], radius=radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def soft_circles(canvas):
    """Two faint translucent circles for depth."""
    overlay = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    d.ellipse([-220, -160, 380, 440], fill=(255, 255, 255, 16))
    d.ellipse([760, 1480, 1360, 2080], fill=(255, 255, 255, 14))
    return Image.alpha_composite(canvas.convert("RGBA"), overlay)


def frame_shot(raw_path, caption, out_path):
    W, H = 1080, 1920
    canvas = vertical_gradient(W, H, BG_TOP, BG_BOTTOM)
    canvas = soft_circles(canvas)
    draw = ImageDraw.Draw(canvas)

    # Caption.
    font = ImageFont.truetype(FONT, 62)
    lines = wrap(draw, caption, font, 940)
    y = 118
    for line in lines:
        tw = draw.textlength(line, font=font)
        draw.text(((W - tw) / 2, y), line, font=font, fill=WHITE)
        y += 78

    # Screenshot, scaled to fit the area under the caption.
    top = 300 if len(lines) == 1 else 360
    avail_h = H - top - 70
    raw = Image.open(raw_path).convert("RGBA")
    scale = avail_h / raw.height
    sw, sh = int(raw.width * scale), int(raw.height * scale)
    shot = raw.resize((sw, sh), Image.LANCZOS)
    shot = rounded(shot, 46)

    x = (W - sw) // 2
    # Drop shadow.
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [x, top + 12, x + sw, top + 12 + sh], radius=46, fill=(20, 12, 60, 120))
    shadow = shadow.filter(ImageFilter.GaussianBlur(18))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow)
    canvas.paste(shot, (x, top), shot)
    canvas.convert("RGB").save(out_path)


def feature_graphic(out_path):
    W, H = 1024, 500
    ss = 2
    canvas = vertical_gradient(W * ss, H * ss, BG_TOP, BG_BOTTOM).convert("RGBA")
    over = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(over).ellipse(
        [-160 * ss, -120 * ss, 220 * ss, 260 * ss], fill=(255, 255, 255, 16))
    canvas = Image.alpha_composite(canvas, over)
    d = ImageDraw.Draw(canvas)

    # Mini sudoku card on the right.
    ic.draw_grid(canvas, W * ss * 0.78, H * ss * 0.5, H * ss * 0.62, ic.FILLED)

    # Wordmark + tagline on the left.
    title = ImageFont.truetype(FONT, 132 * ss)
    tag = ImageFont.truetype(FONT, 48 * ss)
    d.text((70 * ss, 150 * ss), "Sudoku", font=title, fill=WHITE)
    d.text((76 * ss, 300 * ss), "Numbers, but make it fun",
           font=tag, fill=(230, 226, 255))

    canvas.resize((W, H), Image.LANCZOS).convert("RGB").save(out_path)


if __name__ == "__main__":
    for i, (raw_name, caption) in enumerate(SHOTS, start=1):
        out = os.path.join(OUT, f"phone_{i}_{raw_name.split('_', 1)[1]}")
        frame_shot(os.path.join(RAW, raw_name), caption, out)
        print("wrote", os.path.relpath(out, ROOT))
    fg = os.path.join(OUT, "feature_graphic.png")
    feature_graphic(fg)
    print("wrote", os.path.relpath(fg, ROOT))
