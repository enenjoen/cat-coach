from pathlib import Path

from PIL import Image, ImageDraw


OUTPUT_DIR = Path(__file__).parent / "AppIcon.iconset"
OUTPUT_DIR.mkdir(exist_ok=True)

SIZES = {
    "icon_16x16.png": 16,
    "icon_16x16@2x.png": 32,
    "icon_32x32.png": 32,
    "icon_32x32@2x.png": 64,
    "icon_128x128.png": 128,
    "icon_128x128@2x.png": 256,
    "icon_256x256.png": 256,
    "icon_256x256@2x.png": 512,
    "icon_512x512.png": 512,
    "icon_512x512@2x.png": 1024,
}


def draw_icon(size):
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    s = size

    background = (255, 235, 241, 255)
    blush = (247, 167, 185, 255)
    fur = (255, 218, 228, 255)
    ink = (98, 39, 62, 255)
    white = (255, 250, 252, 255)

    draw.ellipse((s * 0.04, s * 0.04, s * 0.96, s * 0.96), fill=background)
    draw.ellipse((s * 0.10, s * 0.10, s * 0.90, s * 0.90), fill=white)
    draw.polygon([(s * 0.27, s * 0.31), (s * 0.38, s * 0.10), (s * 0.47, s * 0.36)], fill=fur)
    draw.polygon([(s * 0.53, s * 0.36), (s * 0.62, s * 0.10), (s * 0.73, s * 0.31)], fill=fur)
    draw.polygon([(s * 0.31, s * 0.29), (s * 0.38, s * 0.17), (s * 0.43, s * 0.34)], fill=blush)
    draw.polygon([(s * 0.57, s * 0.34), (s * 0.62, s * 0.17), (s * 0.69, s * 0.29)], fill=blush)
    draw.ellipse((s * 0.22, s * 0.25, s * 0.78, s * 0.78), fill=fur)
    draw.ellipse((s * 0.34, s * 0.45, s * 0.40, s * 0.51), fill=ink)
    draw.ellipse((s * 0.60, s * 0.45, s * 0.66, s * 0.51), fill=ink)
    draw.ellipse((s * 0.485, s * 0.54, s * 0.515, s * 0.57), fill=ink)

    line_width = max(1, int(s * 0.018))
    whisker_width = max(1, int(s * 0.012))
    draw.arc((s * 0.43, s * 0.54, s * 0.50, s * 0.64), 0, 80, fill=ink, width=line_width)
    draw.arc((s * 0.50, s * 0.54, s * 0.57, s * 0.64), 100, 180, fill=ink, width=line_width)
    draw.arc((s * 0.27, s * 0.49, s * 0.45, s * 0.61), 190, 340, fill=blush, width=whisker_width)
    draw.arc((s * 0.55, s * 0.49, s * 0.73, s * 0.61), 200, 350, fill=blush, width=whisker_width)

    return image


for filename, size in SIZES.items():
    draw_icon(size).save(OUTPUT_DIR / filename)
