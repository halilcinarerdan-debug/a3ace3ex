#!/usr/bin/env python3
"""TAC envanter ikonlari (256x256 PNG, seffaf zemin). Kullanim: python3 tools/gen_icons.py
Cikti: addons/main/data/icons/*_ca.png  (Arma icin .paa'ya cevrilmeli: pboProject otomatik cevirir / TexView2)
4x ust ornekleme ile cizilir, yumusatilarak 256'ya indirilir."""
import math, os
from PIL import Image, ImageDraw, ImageFilter

K = 4                      # ust ornekleme
N = 256 * K
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'addons', 'main', 'data', 'icons')
os.makedirs(OUT, exist_ok=True)


def s(v):
    return int(round(v * K))


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(len(a)))


def new():
    return Image.new('RGBA', (N, N), (0, 0, 0, 0))


def shadow(img, box, blur=10, alpha=110):
    sh = Image.new('RGBA', img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(sh)
    d.ellipse([s(box[0]), s(box[1]), s(box[2]), s(box[3])], fill=(0, 0, 0, alpha))
    sh = sh.filter(ImageFilter.GaussianBlur(s(blur)))
    img.alpha_composite(sh)


def grad_rrect(img, box, r, c1, c2, horizontal=False, outline=None, ow=2):
    x0, y0, x1, y1 = [s(v) for v in box]
    w, h = x1 - x0, y1 - y0
    g = Image.new('RGBA', (w, h))
    gd = ImageDraw.Draw(g)
    steps = w if horizontal else h
    for i in range(steps):
        c = lerp(c1, c2, i / max(1, steps - 1))
        if horizontal:
            gd.line([(i, 0), (i, h)], fill=c)
        else:
            gd.line([(0, i), (w, i)], fill=c)
    mask = Image.new('L', (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w - 1, h - 1], radius=s(r), fill=255)
    img.paste(g, (x0, y0), mask)
    if outline:
        ImageDraw.Draw(img).rounded_rectangle([x0, y0, x1 - 1, y1 - 1], radius=s(r), outline=outline, width=s(ow))


def shine(img, box, r, alpha=70):
    """Ust kenarda yumusak parlak serit."""
    x0, y0, x1, y1 = box
    ov = Image.new('RGBA', img.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    d.rounded_rectangle([s(x0 + 3), s(y0 + 3), s(x1 - 3), s(y0 + (y1 - y0) * 0.38)], radius=s(r), fill=(255, 255, 255, alpha))
    ov = ov.filter(ImageFilter.GaussianBlur(s(2)))
    img.alpha_composite(ov)


def text_plus(d, cx, cy, size, color):
    d.rectangle([s(cx - size), s(cy - size / 4), s(cx + size), s(cy + size / 4)], fill=color)
    d.rectangle([s(cx - size / 4), s(cy - size), s(cx + size / 4), s(cy + size)], fill=color)


def finish(img, name):
    out = img.resize((256, 256), Image.LANCZOS)
    out.save(os.path.join(OUT, name + '_ca.png'))


def cell(img, cx, top, w, h, body1, body2, band, cap):
    d = ImageDraw.Draw(img)
    x0, x1 = cx - w / 2, cx + w / 2
    # pozitif kapak
    grad_rrect(img, (cx - w * 0.22, top - 7, cx + w * 0.22, top + 10), 3, (230, 230, 230, 255), (150, 150, 150, 255))
    grad_rrect(img, (x0, top, x1, top + h), 8, body1, body2, horizontal=True, outline=(20, 20, 20, 255), ow=1.5)
    # ust ve alt bant
    grad_rrect(img, (x0, top + 12, x1, top + 34), 3, cap, lerp(cap, (0, 0, 0, 255), 0.35), horizontal=True)
    grad_rrect(img, (x0, top + h * 0.45, x1, top + h * 0.45 + 20), 2, band, lerp(band, (0, 0, 0, 255), 0.3), horizontal=True)
    text_plus(d, cx, top + h * 0.45 + 10, 5, (255, 255, 255, 235))
    # yan parlama
    ov = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(ov).rounded_rectangle([s(x0 + 5), s(top + 4), s(x0 + 11), s(top + h - 6)], radius=s(3), fill=(255, 255, 255, 85))
    img.alpha_composite(ov.filter(ImageFilter.GaussianBlur(s(1))))


def charge_bar(img, frac, y=205):
    d = ImageDraw.Draw(img)
    grad_rrect(img, (62, y, 194, y + 26), 5, (25, 25, 25, 255), (45, 45, 45, 255), outline=(10, 10, 10, 255), ow=1.5)
    segs = 4
    lit = 0 if frac <= 0 else max(1, math.ceil(frac * segs - 1e-6))
    col = (90, 200, 90, 255) if frac > 0.5 else ((230, 190, 50, 255) if frac > 0.2 else (225, 70, 55, 255))
    for i in range(segs):
        x = 68 + i * 31
        c = col if i < lit else (70, 70, 70, 255)
        d.rounded_rectangle([s(x), s(y + 5), s(x + 27), s(y + 21)], radius=s(3), fill=c)


def battery_icon(name, lithium, frac, dead=False):
    img = new()
    shadow(img, (40, 190, 216, 222), 7)
    if dead:
        b1, b2, band, cap = (110, 110, 110, 255), (70, 70, 70, 255), (90, 90, 90, 255), (80, 80, 80, 255)
    elif lithium:
        b1, b2, band, cap = (215, 218, 230, 255), (130, 135, 160, 255), (115, 70, 190, 255), (150, 105, 215, 255)
    else:
        b1, b2, band, cap = (50, 50, 52, 255), (18, 18, 20, 255), (205, 130, 40, 255), (210, 135, 45, 255)
    cell(img, 94, 36, 58, 150, b1, b2, band, cap)
    cell(img, 162, 52, 58, 150, b1, b2, band, cap)
    charge_bar(img, 0 if dead else frac)
    if dead:
        d = ImageDraw.Draw(img)
        d.line([s(78), s(70), s(178), s(170)], fill=(215, 45, 40, 255), width=s(11))
        d.line([s(178), s(70), s(78), s(170)], fill=(215, 45, 40, 255), width=s(11))
    finish(img, name)


def lens_cloth():
    img = new()
    shadow(img, (30, 190, 226, 226), 8)
    d = ImageDraw.Draw(img)
    # katlanmis bez: iki ust uste dikdortgen
    grad_rrect(img, (36, 70, 210, 190), 10, (110, 165, 215, 255), (60, 105, 165, 255), outline=(35, 70, 115, 255))
    grad_rrect(img, (50, 52, 224, 172), 10, (140, 190, 235, 255), (85, 135, 195, 255), outline=(45, 85, 135, 255))
    # dikis
    for i in range(0, 160, 14):
        d.line([s(60 + i), s(62), s(68 + i), s(62)], fill=(235, 245, 255, 220), width=s(2))
        d.line([s(60 + i), s(162), s(68 + i), s(162)], fill=(235, 245, 255, 220), width=s(2))
    # kat izi
    d.line([s(136), s(56), s(136), s(168)], fill=(60, 105, 160, 90), width=s(3))
    # lens parlamasi
    d.ellipse([s(112), s(88), s(162), s(138)], outline=(240, 250, 255, 255), width=s(5))
    d.ellipse([s(120), s(96), s(154), s(130)], fill=(255, 255, 255, 60))
    d.arc([s(118), s(94), s(156), s(132)], 200, 270, fill=(255, 255, 255, 255), width=s(4))
    shine(img, (50, 52, 224, 172), 10, 55)
    finish(img, 'lens_cloth')


def cleaning_kit():
    img = new()
    shadow(img, (28, 196, 228, 228), 8)
    d = ImageDraw.Draw(img)
    # temizleme cubugu + firca (cantadan cikiyor)
    d.rectangle([s(150), s(24), s(158), s(120)], fill=(170, 170, 175, 255))
    d.rectangle([s(150), s(24), s(153), s(120)], fill=(225, 225, 230, 255))
    for i in range(7):
        y = 24 + i * 4
        d.line([s(140), s(y), s(168), s(y + 2)], fill=(190, 140, 40, 255), width=s(2))
    # canta govdesi
    grad_rrect(img, (30, 92, 226, 206), 14, (110, 125, 75, 255), (65, 78, 42, 255), outline=(35, 45, 22, 255), ow=2)
    grad_rrect(img, (30, 92, 226, 130), 14, (125, 140, 88, 255), (88, 102, 58, 255), outline=(35, 45, 22, 255), ow=2)
    # fermuar
    d.line([s(44), s(130), s(212), s(130)], fill=(35, 40, 25, 255), width=s(3))
    for x in range(48, 210, 8):
        d.line([s(x), s(127), s(x), s(133)], fill=(200, 200, 190, 255), width=s(1.5))
    # kapak ve namlu fircasi amblemi
    grad_rrect(img, (96, 146, 160, 190), 8, (225, 225, 220, 255), (190, 190, 185, 255), outline=(40, 40, 40, 255), ow=1.5)
    d.rectangle([s(104), s(166), s(152), s(171)], fill=(90, 90, 95, 255))
    d.rounded_rectangle([s(124), s(156), s(150), s(181)], radius=s(3), fill=(190, 140, 40, 255), outline=(80, 55, 10, 255), width=s(1.5))
    for i in range(5):
        d.line([s(128 + i * 5), s(156), s(128 + i * 5), s(181)], fill=(110, 75, 15, 255), width=s(1.2))
    # fitil ruloları
    for i in range(3):
        cx = 52 + i * 22
        d.ellipse([s(cx - 8), s(150), s(cx + 8), s(166)], fill=(235, 235, 225, 255), outline=(120, 120, 110, 255), width=s(1.5))
    shine(img, (30, 92, 226, 206), 14, 45)
    finish(img, 'cleaning_kit')


def oil():
    img = new()
    shadow(img, (60, 206, 196, 232), 7)
    d = ImageDraw.Draw(img)
    # sise govdesi (kehribar cam)
    grad_rrect(img, (78, 96, 178, 218), 20, (240, 170, 40, 255), (150, 85, 10, 255), horizontal=True, outline=(70, 40, 5, 255), ow=2)
    # omuz ve boyun
    grad_rrect(img, (102, 66, 154, 106), 10, (230, 160, 35, 255), (150, 85, 10, 255), horizontal=True, outline=(70, 40, 5, 255), ow=2)
    # kapak + memeli uc
    grad_rrect(img, (108, 36, 148, 72), 7, (60, 60, 64, 255), (22, 22, 24, 255), horizontal=True, outline=(8, 8, 8, 255), ow=1.5)
    d.polygon([(s(120), s(36)), (s(136), s(36)), (s(131), s(14)), (s(125), s(14))], fill=(40, 40, 44, 255))
    d.ellipse([s(124), s(8), s(132), s(18)], fill=(30, 30, 32, 255))
    # etiket
    grad_rrect(img, (86, 128, 170, 190), 6, (245, 240, 225, 255), (215, 205, 180, 255), outline=(90, 70, 40, 255), ow=1.5)
    # damla
    d.polygon([(s(128), s(138)), (s(114), s(164)), (s(142), s(164))], fill=(205, 120, 20, 255))
    d.ellipse([s(113), s(152), s(143), s(178)], fill=(205, 120, 20, 255))
    d.ellipse([s(120), s(158), s(128), s(166)], fill=(255, 220, 140, 255))
    d.rectangle([s(94), s(180), s(162), s(184)], fill=(70, 70, 70, 255))
    # cam parlamasi
    ov = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(ov).rounded_rectangle([s(84), s(106), s(94), s(206)], radius=s(5), fill=(255, 255, 255, 110))
    img.alpha_composite(ov.filter(ImageFilter.GaussianBlur(s(1.2))))
    finish(img, 'oil')


def gear(d, cx, cy, r_out, r_in, teeth, fill, hole=None):
    pts = []
    for i in range(teeth * 2):
        a = math.pi * i / teeth
        r = r_out if i % 2 == 0 else r_in
        pts.append((s(cx + r * math.cos(a)), s(cy + r * math.sin(a))))
        a2 = math.pi * (i + 0.5) / teeth
        pts.append((s(cx + r * math.cos(a2)), s(cy + r * math.sin(a2))))
    d.polygon(pts, fill=fill, outline=(40, 40, 40, 255))
    if hole:
        d.ellipse([s(cx - hole), s(cy - hole), s(cx + hole), s(cy + hole)], fill=(0, 0, 0, 0))


def spare_parts():
    img = new()
    shadow(img, (24, 198, 232, 230), 8)
    d = ImageDraw.Draw(img)
    # cantanin arkasi
    grad_rrect(img, (28, 70, 228, 210), 16, (125, 115, 85, 255), (80, 72, 50, 255), outline=(40, 34, 20, 255), ow=2)
    grad_rrect(img, (28, 70, 228, 112), 16, (140, 130, 98, 255), (100, 92, 66, 255), outline=(40, 34, 20, 255), ow=2)
    d.line([s(40), s(112), s(216), s(112)], fill=(40, 34, 20, 255), width=s(3))
    for x in range(44, 214, 10):
        d.line([s(x), s(109), s(x), s(115)], fill=(215, 205, 175, 255), width=s(1.5))
    # tisli
    gear(d, 82, 60, 34, 27, 9, (190, 192, 198, 255), hole=9)
    d.ellipse([s(70), s(48), s(94), s(72)], outline=(70, 70, 75, 255), width=s(2))
    gear(d, 132, 76, 22, 17, 8, (205, 175, 80, 255), hole=6)
    # yay
    for i in range(7):
        x = 156 + i * 9
        d.arc([s(x), s(34), s(x + 20), s(66)], 90, 270, fill=(170, 175, 185, 255), width=s(4))
        d.arc([s(x + 4), s(34), s(x + 24), s(66)], 270, 450, fill=(120, 125, 135, 255), width=s(4))
    # cep + saplama
    d.rounded_rectangle([s(60), s(130), s(150), s(150)], radius=s(5), fill=(160, 165, 172, 255), outline=(50, 50, 55, 255), width=s(2))
    d.rectangle([s(66), s(135), s(144), s(139)], fill=(225, 228, 235, 255))
    d.ellipse([s(160), s(128), s(188), s(156)], fill=(150, 155, 162, 255), outline=(50, 50, 55, 255), width=s(2))
    d.ellipse([s(168), s(136), s(180), s(148)], fill=(60, 60, 64, 255))
    d.rounded_rectangle([s(60), s(166), s(120), s(182)], radius=s(4), fill=(205, 175, 80, 255), outline=(80, 60, 20, 255), width=s(2))
    d.rectangle([s(130), s(168), s(190), s(180)], fill=(180, 184, 190, 255), outline=(50, 50, 55, 255), width=s(2))
    shine(img, (28, 70, 228, 210), 16, 35)
    finish(img, 'spare_parts')


def heat_glove():
    img = new()
    shadow(img, (46, 206, 214, 232), 8)
    d = ImageDraw.Draw(img)
    # eldiven govde: avuc + parmaklar + basparmak (tek blok)
    palm = [(70, 120), (70, 70), (82, 44), (112, 38), (122, 28), (152, 28), (162, 40), (176, 48), (186, 80), (186, 120), (170, 170), (150, 188), (100, 188), (80, 170)]
    thumb = [(70, 112), (40, 96), (26, 108), (34, 140), (76, 156)]
    for poly, c1, c2 in [(thumb, (150, 125, 90), (105, 82, 55)), (palm, (170, 140, 100), (110, 85, 55))]:
        pts = [(s(x), s(y)) for x, y in poly]
        mask = Image.new('L', img.size, 0)
        ImageDraw.Draw(mask).polygon(pts, fill=255)
        g = Image.new('RGBA', img.size)
        gd = ImageDraw.Draw(g)
        ys = [p[1] for p in poly]
        for y in range(s(min(ys)), s(max(ys))):
            t = (y - s(min(ys))) / max(1, s(max(ys)) - s(min(ys)))
            gd.line([(0, y), (N, y)], fill=lerp(c1 + (255,), c2 + (255,), t))
        img.paste(g, (0, 0), mask)
        d.line(pts + [pts[0]], fill=(50, 38, 22, 255), width=s(3), joint='curve')
    # parmak ayirma izleri
    for x in (112, 142, 166):
        d.line([s(x), s(50), s(x), s(110)], fill=(70, 52, 30, 140), width=s(2))
    # dikis
    for y in range(52, 150, 12):
        d.line([s(98), s(y), s(104), s(y + 4)], fill=(235, 220, 180, 220), width=s(2))
    # kolluk
    grad_rrect(img, (84, 176, 168, 214), 7, (95, 100, 105, 255), (55, 58, 62, 255), outline=(25, 26, 28, 255), ow=2)
    d.line([s(90), s(188), s(162), s(188)], fill=(150, 155, 160, 200), width=s(2))
    # isi isareti (alev)
    d.polygon([(s(128), s(86)), (s(116), s(112)), (s(122), s(124)), (s(134), s(124)), (s(142), s(108)), (s(136), s(98)), (s(132), s(104))], fill=(235, 120, 40, 255))
    d.polygon([(s(128), s(104)), (s(122), s(116)), (s(128), s(122)), (s(136), s(114))], fill=(255, 215, 90, 255))
    finish(img, 'heat_glove')


def missile_battery():
    img = new()
    shadow(img, (30, 196, 226, 228), 8)
    d = ImageDraw.Draw(img)
    # baglanti uclari
    for x in (88, 108, 148, 168):
        d.rectangle([s(x - 4), s(26), s(x + 4), s(62)], fill=(205, 175, 80, 255), outline=(80, 60, 20, 255), width=s(1.5))
    grad_rrect(img, (72, 56, 184, 84), 6, (70, 72, 78, 255), (30, 32, 36, 255), outline=(10, 10, 10, 255), ow=1.5)
    # govde
    grad_rrect(img, (34, 78, 222, 204), 14, (96, 104, 82, 255), (52, 58, 42, 255), outline=(26, 30, 20, 255), ow=2)
    # yan kaburgalar
    for x in (44, 56):
        d.line([s(x), s(92), s(x), s(190)], fill=(30, 34, 24, 120), width=s(3))
    for x in (200, 212):
        d.line([s(x), s(92), s(x), s(190)], fill=(30, 34, 24, 120), width=s(3))
    # uyari seritleri
    grad_rrect(img, (70, 94, 186, 120), 4, (240, 200, 40, 255), (240, 200, 40, 255))
    for i in range(10):
        x = 70 + i * 14
        d.polygon([(s(x), s(120)), (s(x + 8), s(94)), (s(x + 16), s(94)), (s(x + 8), s(120))], fill=(25, 25, 25, 255))
    # etiket + simsek
    grad_rrect(img, (70, 130, 186, 184), 5, (225, 228, 220, 255), (190, 194, 184, 255), outline=(30, 30, 30, 255), ow=1.5)
    d.polygon([(s(132), s(136)), (s(112), s(164)), (s(126), s(164)), (s(118), s(180)), (s(148), s(150)), (s(133), s(150)), (s(140), s(136))], fill=(35, 35, 35, 255))
    d.rectangle([s(76), s(168), s(106), s(178)], fill=(60, 60, 60, 255))
    d.rectangle([s(150), s(168), s(180), s(178)], fill=(60, 60, 60, 255))
    # LED
    d.ellipse([s(46), s(72), s(60), s(86)], fill=(80, 215, 90, 255), outline=(10, 10, 10, 255), width=s(1.5))
    shine(img, (34, 78, 222, 204), 14, 40)
    finish(img, 'missile_battery')


def barrel(name, heavy):
    img = new()
    shadow(img, (20, 150, 236, 182), 8)
    d = ImageDraw.Draw(img)
    thick = 46 if heavy else 30
    y0 = 128 - thick / 2
    # ana namlu govdesi
    grad_rrect(img, (30, y0, 226, y0 + thick), 8, (205, 208, 214, 255), (92, 96, 104, 255), outline=(30, 32, 36, 255), ow=2)
    # tasima kulpu halkasi (agir) / hafif icin tutamak
    if heavy:
        for x in range(60, 190, 18):
            d.rectangle([s(x), s(y0 - 6), s(x + 8), s(y0 + thick + 6)], fill=(120, 124, 132, 255), outline=(35, 37, 42, 255), width=s(1.5))
        grad_rrect(img, (30, y0 - 4, 62, y0 + thick + 4), 5, (170, 174, 182, 255), (80, 84, 92, 255), outline=(30, 32, 36, 255), ow=2)
    else:
        for x in range(80, 168, 22):
            d.ellipse([s(x), s(y0 + 7), s(x + 12), s(y0 + 19)], fill=(35, 37, 42, 255))
        d.rounded_rectangle([s(34), s(y0 - 3), s(60), s(y0 + thick + 3)], radius=s(5), fill=(150, 154, 162, 255), outline=(30, 32, 36, 255), width=s(2))
    # gaz blogu
    grad_rrect(img, (186, y0 - 12, 214, y0 + thick + 12), 4, (110, 114, 122, 255), (50, 52, 58, 255), outline=(20, 22, 26, 255), ow=2)
    # alev sondurucu uc
    d.rounded_rectangle([s(214), s(y0 + 2), s(238), s(y0 + thick - 2)], radius=s(4), fill=(55, 57, 63, 255), outline=(15, 16, 18, 255), width=s(2))
    for i in range(3):
        d.line([s(220 + i * 5), s(y0 + 4), s(220 + i * 5), s(y0 + thick - 4)], fill=(15, 16, 18, 255), width=s(2))
    # sicak bolge isareti (kamera: yedek namlu etiketi)
    d.rectangle([s(70), s(y0 + thick + 12), s(110), s(y0 + thick + 18)], fill=(225, 190, 50, 255))
    # parlama
    ov = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(ov).rounded_rectangle([s(40), s(y0 + 3), s(220), s(y0 + 8)], radius=s(3), fill=(255, 255, 255, 120))
    img.alpha_composite(ov.filter(ImageFilter.GaussianBlur(s(1))))
    finish(img, name)


for tag, lith in (('nvg_aa', False), ('nvg_li', True)):
    for p in (100, 75, 50, 25, 10):
        battery_icon('%s_%d' % (tag, p), lith, p / 100.0)
battery_icon('nvg_dead', False, 0, dead=True)
lens_cloth()
cleaning_kit()
oil()
spare_parts()
heat_glove()
missile_battery()
barrel('barrel_light', False)
barrel('barrel_heavy', True)
print(len(os.listdir(OUT)), 'ikon yazildi:', os.path.normpath(OUT))
