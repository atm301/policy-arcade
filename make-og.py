"""OG image (1200x630) — 8-bit pixel-art arcade style"""
from PIL import Image, ImageDraw, ImageFont
import os

W, H = 1200, 630
# 8-bit 像素拱廊配色
BG_DARK = (26, 24, 48)            # #1a1830
BG_PANEL = (45, 42, 74)           # #2d2a4a
PINK = (237, 73, 120)             # #ed4978
GREEN = (76, 228, 111)            # #4ce46f
BLUE = (92, 198, 245)             # #5cc6f5
YELLOW = (249, 198, 111)          # #f9c66f
CORAL = (249, 151, 97)            # #f99761
WHITE = (245, 243, 255)
PURPLE = (165, 130, 255)

img = Image.new("RGB", (W, H), BG_DARK)
draw = ImageDraw.Draw(img)

# 上下緣斑馬條紋（紅黃像素塊）
stripe = 24
for x in range(0, W, stripe * 2):
    draw.rectangle([x, 0, x + stripe, 24], fill=PINK)
    draw.rectangle([x + stripe, 0, x + stripe * 2, 24], fill=YELLOW)
    draw.rectangle([x, H - 24, x + stripe, H], fill=PINK)
    draw.rectangle([x + stripe, H - 24, x + stripe * 2, H], fill=YELLOW)

# 中央粉紅綠色橫條（呼應簡報）
draw.rectangle([0, 90, W, 105], fill=PINK)
draw.rectangle([0, H - 100, W, H - 85], fill=GREEN)

# 字型
font_paths = [
    r"C:\Windows\Fonts\msjhbd.ttc",
    r"C:\Windows\Fonts\msjh.ttc",
]
font_path = next((p for p in font_paths if os.path.exists(p)), None)

if font_path:
    f_eyebrow = ImageFont.truetype(font_path, 28)
    f_title = ImageFont.truetype(font_path, 96)
    f_sub = ImageFont.truetype(font_path, 38)
    f_meta = ImageFont.truetype(font_path, 26)
    f_pixel = ImageFont.truetype(font_path, 20)
else:
    f_eyebrow = f_title = f_sub = f_meta = f_pixel = ImageFont.load_default()

# Eyebrow 「◆ GAME START ◆」
eyebrow_y = 145
draw.polygon([(420, eyebrow_y + 14), (440, eyebrow_y), (460, eyebrow_y + 14), (440, eyebrow_y + 28)], fill=YELLOW)
draw.text((480, eyebrow_y - 4), "GAME START", fill=YELLOW, font=f_eyebrow)
draw.polygon([(720, eyebrow_y + 14), (740, eyebrow_y), (760, eyebrow_y + 14), (740, eyebrow_y + 28)], fill=YELLOW)

# Main title
title = "POLICY ARCADE"
bbox = draw.textbbox((0, 0), title, font=f_title)
title_w = bbox[2] - bbox[0]
draw.text(((W - title_w) // 2, 195), title, fill=WHITE, font=f_title)

# 中文副標
subtitle = "用有趣有效的方式  推動嚴肅的政策"
bbox = draw.textbbox((0, 0), subtitle, font=f_sub)
sub_w = bbox[2] - bbox[0]
draw.text(((W - sub_w) // 2, 320), subtitle, fill=YELLOW, font=f_sub)

# >> 遊戲化 × AI × 公共政策 <<
caption = ">>  遊戲化 × AI × 公共政策  <<"
bbox = draw.textbbox((0, 0), caption, font=f_meta)
cap_w = bbox[2] - bbox[0]
draw.text(((W - cap_w) // 2, 380), caption, fill=PINK, font=f_meta)

# 像素角色（左下/右下）
def pixel_creature(x0, y0, color, scale=8):
    # 簡單 8-bit 太空入侵者像素圖
    pattern = [
        "  X    X  ",
        "   X  X   ",
        "  XXXXXX  ",
        " XX XX XX ",
        "XXXXXXXXXX",
        "X XXXXXX X",
        "X X    X X",
        "   XX XX  ",
    ]
    for ry, row in enumerate(pattern):
        for rx, ch in enumerate(row):
            if ch == "X":
                draw.rectangle([x0 + rx * scale, y0 + ry * scale,
                                x0 + (rx + 1) * scale, y0 + (ry + 1) * scale], fill=color)

pixel_creature(80, 470, GREEN, 7)
pixel_creature(1040, 470, CORAL, 7)

# 金幣 row
def coin(cx, cy, r=22):
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=YELLOW, outline=(180, 130, 40), width=3)
    draw.text((cx - 8, cy - 14), "$", fill=BG_DARK, font=f_pixel)

coins_y = 540
for i, cx in enumerate([520, 580, 640, 700]):
    coin(cx, coins_y)

# 底部 meta
draw.text((W // 2 - 280, H - 65), "公共行政暨政策學系  ・  2026.05.07", fill=GREEN, font=f_meta)

img.save("c:/myclaude/policy-arcade/og.png", "PNG", optimize=True)
print("OG saved:", os.path.getsize("c:/myclaude/policy-arcade/og.png"), "bytes")
