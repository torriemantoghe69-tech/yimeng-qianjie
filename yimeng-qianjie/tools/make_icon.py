from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "icon.ico"
SIZE = 1024
img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
d = ImageDraw.Draw(img, "RGBA")

# 宣纸底与朱砂边框
d.rounded_rectangle((18, 18, SIZE - 18, SIZE - 18), radius=128, fill=(238, 228, 208, 255))
d.rounded_rectangle((52, 52, SIZE - 52, SIZE - 52), radius=100, outline=(126, 100, 60, 90), width=5)

# 月/日
for r, a in [(230, 16), (150, 28), (112, 120)]:
    d.ellipse((700 - r, 290 - r, 700 + r, 290 + r), fill=(171, 70, 50, a))
d.ellipse((700 - 98, 290 - 98, 700 + 98, 290 + 98), fill=(190, 83, 58, 235))

# 远山
d.polygon([(0, 690), (150, 570), (260, 650), (410, 500), (620, 680), (810, 560), (1024, 720), (1024, 1024), (0, 1024)], fill=(82, 106, 94, 150))
d.polygon([(0, 810), (180, 690), (330, 770), (500, 620), (680, 790), (880, 700), (1024, 800), (1024, 1024), (0, 1024)], fill=(45, 65, 57, 235))
d.polygon([(0, 920), (170, 830), (330, 900), (520, 790), (720, 920), (910, 850), (1024, 930), (1024, 1024), (0, 1024)], fill=(30, 46, 41, 255))

# 朱砂印「梦」
d.rounded_rectangle((120, 120, 370, 370), radius=18, fill=(162, 58, 42, 255))
try:
    font = ImageFont.truetype(r"C:\Windows\Fonts\simkai.ttf", 205)
except OSError:
    font = ImageFont.truetype(r"C:\Windows\Fonts\msyh.ttc", 190)
text = "梦"
bbox = d.textbbox((0, 0), text, font=font)
tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
d.text((245 - tw / 2 - bbox[0], 245 - th / 2 - bbox[1]), text, font=font, fill=(250, 243, 227, 255))

# 内框
d.rounded_rectangle((28, 28, SIZE - 28, SIZE - 28), radius=120, outline=(255, 250, 238, 90), width=4)

OUT.parent.mkdir(parents=True, exist_ok=True)
img.save(OUT, format="ICO", sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
print(OUT)
