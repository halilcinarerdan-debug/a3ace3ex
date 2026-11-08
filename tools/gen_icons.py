#!/usr/bin/env python3
"""TAC envanter ikonlari v2 (256x256 PNG, seffaf zemin): gercekci / mat / soluk renkli, ince doku ve isik hesabi.
Kullanim: python3 tools/gen_icons.py   (Pillow + numpy gerekir)
Cikti: addons/main/data/icons/*_ca.png  (Arma icin .paa'ya cevrilmeli; bkz. README)
Silindirler Lambert + speküler ile, kutular uc yuzlu (on / ust / yan) isiklandirilir; naylon / metal gren dokusu eklenir."""
import math, os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

K = 3
N = 256 * K
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'addons', 'main', 'data', 'icons')
os.makedirs(OUT, exist_ok=True)
RNG = np.random.default_rng(11)
LIGHT = np.array([-0.55, -0.45, 0.70]); LIGHT = LIGHT / np.linalg.norm(LIGHT)

FONTS = ['/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf', '/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf']


def font(px):
    for f in FONTS:
        if os.path.exists(f):
            return ImageFont.truetype(f, int(px * K))
    return ImageFont.load_default()


def s(v):
    return int(round(v * K))


def canvas():
    return Image.new('RGBA', (N, N), (0, 0, 0, 0))


def shadow(img, box, blur=9, alpha=85):
    sh = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(sh).ellipse([s(box[0]), s(box[1]), s(box[2]), s(box[3])], fill=(0, 0, 0, alpha))
    img.alpha_composite(sh.filter(ImageFilter.GaussianBlur(s(blur))))


def grain(w, h, amp=14, scale=1.0):
    n = RNG.normal(0, 1, (h, w))
    im = Image.fromarray(np.clip(n * 40 + 128, 0, 255).astype('uint8')).filter(ImageFilter.GaussianBlur(scale * K * 0.5))
    a = np.asarray(im).astype('float32') - 128
    return a / max(1e-6, a.std()) * amp


def weave(w, h, amp=10, pitch=3):
    y, x = np.mgrid[0:h, 0:w]
    v = (np.sin(x / (pitch * K) * math.pi) * np.sin(y / (pitch * K) * math.pi))
    return v * amp


def shade_cyl(w, h, color, axis_vertical=True, spec=0.45, tex=10, rough=0.0):
    """Silindir yuzeyi: kenarlara dogru kararir, soldan ust isik, hafif speküler. Dondurur RGBA (h,w)."""
    if axis_vertical:
        u = (np.linspace(-1, 1, w))[None, :].repeat(h, 0)
    else:
        u = (np.linspace(-1, 1, h))[:, None].repeat(w, 1)
    nz = np.sqrt(np.clip(1 - u ** 2, 0, 1))
    if axis_vertical:
        nx, ny = u, np.zeros_like(u)
    else:
        nx, ny = np.zeros_like(u), u
    diff = np.clip(nx * LIGHT[0] + ny * LIGHT[1] + nz * LIGHT[2], 0, 1)
    h_vec = LIGHT + np.array([0, 0, 1]); h_vec = h_vec / np.linalg.norm(h_vec)
    sp = np.clip(nx * h_vec[0] + ny * h_vec[1] + nz * h_vec[2], 0, 1) ** (40 if rough == 0 else 14) * spec
    base = np.array(color[:3], dtype='float32')[None, None, :]
    rgb = base * (0.28 + 0.85 * diff[..., None]) + 255 * sp[..., None]
    rgb = rgb + grain(w, h, tex)[..., None]
    a = np.full((h, w, 1), 255, dtype='float32')
    return np.clip(np.concatenate([rgb, a], axis=2), 0, 255).astype('uint8')


def paste_arr(img, arr, x, y, mask=None):
    im = Image.fromarray(arr, 'RGBA')
    if mask is not None:
        im.putalpha(mask)
    img.alpha_composite(im, (x, y))


def rr_mask(w, h, r):
    m = Image.new('L', (w, h), 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, w - 1, h - 1], radius=r, fill=255)
    return m


def cylinder(img, x0, y0, x1, y1, color, vertical=True, r=0, **kw):
    w, h = s(x1 - x0), s(y1 - y0)
    arr = shade_cyl(w, h, color, vertical, **kw)
    paste_arr(img, arr, s(x0), s(y0), rr_mask(w, h, s(r)))


def band(img, x0, y0, x1, y1, color, vertical=True, **kw):
    cylinder(img, x0, y0, x1, y1, color, vertical, **kw)


def print_text(img, xy, txt, px, color=(225, 225, 215, 255), anchor='mm', alpha=215):
    d = ImageDraw.Draw(img)
    c = color[:3] + (alpha,)
    d.text((s(xy[0]), s(xy[1])), txt, font=font(px), fill=c, anchor=anchor)


def scuffs(img, box, count=30, light=True):
    d = ImageDraw.Draw(img, 'RGBA')
    for _ in range(count):
        x = RNG.uniform(box[0], box[2]); y = RNG.uniform(box[1], box[3])
        l = RNG.uniform(2, 7); a = RNG.uniform(0, math.pi)
        c = (225, 225, 220, 55) if light else (10, 10, 10, 70)
        d.line([s(x), s(y), s(x + l * math.cos(a)), s(y + l * math.sin(a))], fill=c, width=s(0.6))


def finish(img, name):
    out = img.resize((256, 256), Image.LANCZOS)
    out.save(os.path.join(OUT, name + '_ca.png'))


# --- yardimci: kutu (pouch / BCU) ------------------------------------------------
def box3(img, x0, y0, w, h, depth, front, top, side, r=8, tex=8, nylon=False):
    """On yuz + ust yuz (paralelogram) + sag yan yuz (paralelogram); on yuz isiklandirmali gradyan."""
    fw, fh = s(w), s(h)
    yy = np.linspace(0, 1, fh)[:, None, None]
    xx = np.linspace(0, 1, fw)[None, :, None]
    base = np.array(front[:3], dtype='float32')[None, None, :]
    rgb = base * (1.08 - 0.28 * yy - 0.10 * xx) + grain(fw, fh, tex)[..., None]
    if nylon:
        rgb = rgb + weave(fw, fh, 7)[..., None]
    arr = np.clip(np.concatenate([rgb, np.full((fh, fw, 1), 255, dtype='float32')], axis=2), 0, 255).astype('uint8')
    dx, dy = depth * 0.8, -depth * 0.55
    # ust yuz
    d = ImageDraw.Draw(img)
    d.polygon([(s(x0 + 6), s(y0)), (s(x0 + w), s(y0)), (s(x0 + w + dx), s(y0 + dy)), (s(x0 + 6 + dx), s(y0 + dy))], fill=top[:3] + (255,))
    # sag yan yuz
    d.polygon([(s(x0 + w), s(y0)), (s(x0 + w + dx), s(y0 + dy)), (s(x0 + w + dx), s(y0 + dy + h - 8)), (s(x0 + w), s(y0 + h))], fill=side[:3] + (255,))
    paste_arr(img, arr, s(x0), s(y0), rr_mask(fw, fh, s(r)))
    # kenar vurgusu
    d.line([s(x0 + 6), s(y0 + 1), s(x0 + w - 4), s(y0 + 1)], fill=(255, 255, 255, 60), width=s(1))
    d.rounded_rectangle([s(x0), s(y0), s(x0 + w) - 1, s(y0 + h) - 1], radius=s(r), outline=(0, 0, 0, 120), width=s(1.2))


def stitches(img, pts, color=(215, 205, 170, 170), step=5.0, dash=2.6):
    d = ImageDraw.Draw(img, 'RGBA')
    for (xa, ya), (xb, yb) in zip(pts[:-1], pts[1:]):
        L = math.hypot(xb - xa, yb - ya)
        n = int(L / step)
        for i in range(n):
            t0 = i / max(1, n); t1 = min(1, t0 + dash / max(1, L))
            d.line([s(xa + (xb - xa) * t0), s(ya + (yb - ya) * t0), s(xa + (xb - xa) * t1), s(ya + (yb - ya) * t1)], fill=color, width=s(0.9))


def patch(img, box, label, px=9, bg=(205, 200, 180, 255), fg=(40, 42, 36, 255)):
    x0, y0, x1, y1 = box
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([s(x0), s(y0), s(x1), s(y1)], radius=s(2.5), fill=bg, outline=(30, 30, 25, 200), width=s(1))
    arr = np.zeros((s(y1 - y0), s(x1 - x0)), dtype='float32')
    g = grain(s(x1 - x0), s(y1 - y0), 6)
    ov = Image.fromarray(np.clip(128 + g * 3, 0, 255).astype('uint8')).convert('RGBA')
    ov.putalpha(35)
    img.alpha_composite(ov, (s(x0), s(y0)))
    print_text(img, ((x0 + x1) / 2, (y0 + y1) / 2), label, px, fg, alpha=235)


# --- esyalar -----------------------------------------------------------------------
def cell(img, cx, top, w, h, body, bandc, label, dead=False):
    x0, x1 = cx - w / 2, cx + w / 2
    cylinder(img, cx - w * 0.2, top - 6, cx + w * 0.2, top + 8, (200, 200, 195), True, r=3, spec=0.8, tex=4)
    cylinder(img, x0, top, x1, top + h, body, True, r=7, spec=0.55 if not dead else 0.1, tex=3.5 if not dead else 9)
    # ust ve alt metal halka
    cylinder(img, x0, top + 6, x1, top + 18, (170, 172, 172), True, r=2, spec=0.7, tex=5)
    cylinder(img, x0, top + h - 14, x1, top + h - 4, (160, 160, 158), True, r=2, spec=0.7, tex=5)
    # bant
    band(img, x0, top + h * 0.40, x1, top + h * 0.40 + 22, bandc, True, spec=0.3, tex=6)
    print_text(img, (cx, top + h * 0.40 + 11), label, 7.5, (240, 240, 232, 255), alpha=235)
    print_text(img, (cx, top + h * 0.78), '1.5V', 7, (225, 225, 215, 255), alpha=170)
    # soldan parlama
    ov = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(ov).rounded_rectangle([s(x0 + 5), s(top + 20), s(x0 + 9), s(top + h - 18)], radius=s(2), fill=(255, 255, 255, 60 if not dead else 22))
    img.alpha_composite(ov.filter(ImageFilter.GaussianBlur(s(1.2))))


def gauge(img, frac, y=214):
    """Sade, tek renkli sarj gostergesi (trafik isigi yok): 5 ince cizgi."""
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([s(70), s(y), s(186), s(y + 11)], radius=s(3), fill=(18, 20, 18, 235), outline=(0, 0, 0, 200), width=s(1))
    n = 5
    lit = int(round(frac * n))
    for i in range(n):
        x = 75 + i * 22
        c = (190, 196, 180, 255) if i < lit else (60, 64, 58, 255)
        d.rectangle([s(x), s(y + 3), s(x + 18), s(y + 8)], fill=c)


def battery(name, lithium, frac, dead=False):
    img = canvas()
    shadow(img, (40, 196, 220, 222), 7)
    if dead:
        body, bnd, lab = (88, 90, 86), (74, 74, 70), 'AA'
    elif lithium:
        body, bnd, lab = (190, 196, 202), (38, 62, 112), 'Li'
    else:
        body, bnd, lab = (44, 46, 48), (142, 94, 38), 'AA'
    cell(img, 98, 46, 56, 148, body, bnd, lab, dead)
    cell(img, 160, 58, 56, 148, body, bnd, lab, dead)
    if dead:
        d = ImageDraw.Draw(img, 'RGBA')
        for (px, py, r) in ((160, 56, 9), (166, 60, 6), (154, 58, 5), (98, 44, 7)):
            d.ellipse([s(px - r), s(py - r * 0.5), s(px + r), s(py + r * 0.5)], fill=(168, 178, 150, 190))
        d.ellipse([s(150), s(66), s(172), s(82)], fill=(150, 160, 128, 120))
        scuffs(img, (72, 50, 190, 200), 55, True)
    else:
        scuffs(img, (72, 50, 190, 200), 8, True)
    gauge(img, 0 if dead else frac)
    finish(img, name)


def lens_cloth():
    img = canvas()
    shadow(img, (28, 196, 228, 228), 9)
    d = ImageDraw.Draw(img)
    # alt kat
    box3(img, 40, 96, 150, 88, 22, (92, 106, 118), (118, 132, 144), (66, 78, 90), r=6, tex=5, nylon=True)
    # ust kat (katlanmis)
    box3(img, 56, 78, 150, 88, 22, (118, 134, 146), (146, 160, 170), (84, 98, 110), r=6, tex=5, nylon=True)
    # kat gölgesi
    ov = Image.new('RGBA', img.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(ov)
    od.rectangle([s(128), s(80), s(134), s(164)], fill=(0, 0, 0, 60))
    od.polygon([(s(56), s(84)), (s(206), s(78)), (s(206), s(84)), (s(56), s(90))], fill=(255, 255, 255, 40))
    img.alpha_composite(ov.filter(ImageFilter.GaussianBlur(s(2.2))))
    # kenar dikisi
    stitches(img, [(64, 87), (198, 87), (198, 158), (64, 158), (64, 87)], (200, 210, 218, 150), 5.5, 2.6)
    # etiket
    patch(img, (150, 138, 192, 152), 'LENS', 7.5, (60, 66, 62, 255), (205, 208, 195, 255))
    finish(img, 'lens_cloth')


def pouch(img, x0, y0, w, h, color, top, side, label, zip_y, nylon=True):
    box3(img, x0, y0, w, h, 20, color, top, side, r=9, tex=7, nylon=nylon)
    d = ImageDraw.Draw(img, 'RGBA')
    # fermuar
    d.line([s(x0 + 8), s(zip_y), s(x0 + w - 8), s(zip_y)], fill=(18, 18, 16, 235), width=s(3))
    for x in np.arange(x0 + 10, x0 + w - 8, 3.2):
        d.line([s(x), s(zip_y - 1.8), s(x), s(zip_y + 1.8)], fill=(170, 172, 168, 200), width=s(0.9))
    d.rounded_rectangle([s(x0 + w - 24), s(zip_y - 4), s(x0 + w - 12), s(zip_y + 7)], radius=s(2), fill=(28, 28, 26, 255), outline=(120, 122, 118, 255), width=s(1))
    # dikis ve MOLLE sirasi
    stitches(img, [(x0 + 8, y0 + 8), (x0 + w - 8, y0 + 8), (x0 + w - 8, y0 + h - 8), (x0 + 8, y0 + h - 8), (x0 + 8, y0 + 8)], (225, 218, 190, 120), 5, 2.4)
    patch(img, (x0 + w / 2 - 38, y0 + h * 0.58, x0 + w / 2 + 38, y0 + h * 0.58 + 22), label, 8.5, (60, 64, 52, 255), (212, 210, 190, 255))
    scuffs(img, (x0 + 8, y0 + 8, x0 + w - 8, y0 + h - 8), 26, True)


def cleaning_kit():
    img = canvas()
    shadow(img, (26, 198, 230, 230), 9)
    # cubuk (arkada)
    cylinder(img, 156, 22, 164, 118, (190, 192, 196), True, r=2, spec=0.8, tex=5)
    cylinder(img, 150, 22, 170, 44, (176, 132, 52), True, r=3, spec=0.3, tex=14)
    cylinder(img, 148, 112, 172, 124, (30, 30, 28), True, r=3, spec=0.2, tex=5)
    pouch(img, 34, 100, 168, 100, (88, 98, 66), (110, 120, 86), (60, 68, 46), 'CLEANING KIT', 132)
    finish(img, 'cleaning_kit')


def oil():
    img = canvas()
    shadow(img, (62, 208, 198, 234), 7)
    # govde (koyu kehribar sise, parlak)
    cylinder(img, 82, 100, 174, 222, (112, 62, 22), True, r=14, spec=1.0, tex=6)
    cylinder(img, 106, 74, 150, 112, (108, 60, 22), True, r=9, spec=1.0, tex=6)
    cylinder(img, 108, 44, 148, 80, (26, 28, 28), True, r=6, spec=0.6, tex=5)
    for y in (50, 58, 66):
        cylinder(img, 108, y, 148, y + 2.2, (60, 62, 62), True, r=1, spec=0.5, tex=3)
    cylinder(img, 120, 18, 136, 50, (36, 38, 38), True, r=3, spec=0.8, tex=4)
    d = ImageDraw.Draw(img, 'RGBA')
    d.ellipse([s(124), s(12), s(132), s(22)], fill=(20, 20, 20, 255))
    # etiket (govdeyi saran, kenarlara dogru kararir)
    lab = shade_cyl(s(84), s(60), (222, 218, 200), True, spec=0.1, tex=4)
    paste_arr(img, lab, s(86), s(132), rr_mask(s(84), s(60), s(3)))
    print_text(img, (128, 147), 'GUN OIL', 10, (36, 36, 32, 255), alpha=240)
    print_text(img, (128, 162), 'CLP', 8, (36, 36, 32, 255), alpha=220)
    d.rectangle([s(94), s(172), s(162), s(175)], fill=(36, 36, 32, 210))
    print_text(img, (128, 184), '118 ml', 6.5, (36, 36, 32, 255), alpha=200)
    # cam parlamasi
    ov = Image.new('RGBA', img.size, (0, 0, 0, 0))
    ImageDraw.Draw(ov).rounded_rectangle([s(90), s(108), s(98), s(214)], radius=s(4), fill=(255, 240, 215, 70))
    img.alpha_composite(ov.filter(ImageFilter.GaussianBlur(s(1.5))))
    finish(img, 'oil')


def spare_parts():
    img = canvas()
    shadow(img, (24, 200, 232, 232), 9)
    d = ImageDraw.Draw(img, 'RGBA')
    # ceptan tasan metal parcalar: piston, yay, pim
    cylinder(img, 62, 54, 72, 132, (176, 178, 180), True, r=3, spec=0.9, tex=5)
    cylinder(img, 56, 50, 78, 66, (110, 112, 114), True, r=4, spec=0.7, tex=6)
    for i in range(9):
        y = 40 + i * 6
        d.arc([s(96), s(y), s(126), s(y + 12)], 180, 360, fill=(150, 154, 158, 255), width=s(2.6))
        d.arc([s(96), s(y + 3), s(126), s(y + 15)], 0, 180, fill=(86, 90, 94, 255), width=s(2.6))
    cylinder(img, 150, 62, 156, 130, (160, 140, 90), True, r=2, spec=0.7, tex=6)
    cylinder(img, 146, 56, 160, 66, (100, 84, 50), True, r=3, spec=0.5, tex=6)
    pouch(img, 30, 112, 176, 92, (126, 108, 78), (148, 130, 98), (92, 78, 54), 'SPARE PARTS', 140)
    finish(img, 'spare_parts')


def heat_glove():
    img = canvas()
    shadow(img, (44, 208, 214, 234), 8)
    d = ImageDraw.Draw(img, 'RGBA')

    def fill_poly(poly, c1, c2, tex=9):
        pts = [(s(x), s(y)) for x, y in poly]
        ys = [p[1] for p in poly]
        xs = [p[0] for p in poly]
        x0, x1, y0, y1 = s(min(xs)), s(max(xs)), s(min(ys)), s(max(ys))
        w, h = x1 - x0, y1 - y0
        yy = np.linspace(0, 1, h)[:, None, None]
        xx = np.linspace(0, 1, w)[None, :, None]
        base = np.array(c1, dtype='float32')[None, None, :] * (1 - yy) + np.array(c2, dtype='float32')[None, None, :] * yy
        rgb = base * (1.05 - 0.2 * xx) + grain(w, h, tex)[..., None] + weave(w, h, 4)[..., None]
        arr = np.clip(np.concatenate([rgb, np.full((h, w, 1), 255, dtype='float32')], axis=2), 0, 255).astype('uint8')
        m = Image.new('L', img.size, 0)
        ImageDraw.Draw(m).polygon(pts, fill=255)
        m = m.crop((x0, y0, x1, y1))
        paste_arr(img, arr, x0, y0, m)
        d.line(pts + [pts[0]], fill=(10, 10, 10, 210), width=s(2), joint='curve')

    thumb = [(74, 116), (46, 100), (30, 112), (36, 146), (80, 160)]
    fill_poly(thumb, (96, 86, 70), (66, 58, 46))
    palm = [(72, 124), (72, 74), (82, 46), (110, 40), (120, 30), (152, 30), (164, 42), (178, 50), (188, 82), (188, 122), (172, 172), (152, 190), (100, 190), (82, 172)]
    fill_poly(palm, (88, 84, 76), (52, 50, 46))
    # parmak ayrimlari
    for x in (112, 142, 166):
        d.line([s(x), s(52), s(x), s(112)], fill=(10, 10, 10, 170), width=s(1.6))
    # avuc ici deri yama (isiya dayanikli)
    fill_poly([(92, 118), (92, 82), (116, 70), (168, 76), (176, 118), (164, 160), (110, 164)], (118, 98, 68), (80, 64, 42), tex=11)
    stitches(img, [(92, 118), (92, 82), (116, 70), (168, 76), (176, 118), (164, 160), (110, 164), (92, 118)], (225, 215, 180, 150), 5, 2.4)
    # kolluk (orgulu)
    cuff = [(82, 182), (172, 182), (176, 218), (78, 218)]
    fill_poly(cuff, (58, 60, 62), (30, 32, 34), tex=6)
    for y in range(188, 216, 5):
        d.line([s(84), s(y), s(172), s(y)], fill=(0, 0, 0, 110), width=s(1.2))
    # ince uyari etiketi
    patch(img, (112, 196, 148, 210), '250C', 7, (190, 120, 40, 255), (30, 22, 10, 255))
    scuffs(img, (74, 40, 186, 190), 24, True)
    finish(img, 'heat_glove')


def missile_battery():
    img = canvas()
    shadow(img, (28, 198, 230, 232), 9)
    d = ImageDraw.Draw(img, 'RGBA')
    # baglanti ucu (ust)
    box3(img, 84, 52, 88, 22, 10, (40, 42, 44), (60, 62, 64), (24, 26, 28), r=3, tex=5)
    for x in (96, 112, 128, 144):
        cylinder(img, x, 28, x + 6, 56, (190, 160, 70), True, r=2, spec=0.9, tex=5)
    # govde
    box3(img, 34, 72, 176, 128, 24, (84, 92, 70), (106, 114, 90), (58, 64, 48), r=8, tex=9)
    # yan kaburgalar
    for x in (44, 54, 190, 200):
        d.line([s(x), s(86), s(x), s(186)], fill=(0, 0, 0, 95), width=s(2.4))
        d.line([s(x + 1.5), s(86), s(x + 1.5), s(186)], fill=(255, 255, 255, 25), width=s(1))
    # uyari etiketi (soluk sari / siyah)
    d.rectangle([s(72), s(86), s(172), s(104)], fill=(176, 150, 52, 255))
    for i in range(9):
        x = 72 + i * 12
        d.polygon([(s(x), s(104)), (s(x + 7), s(86)), (s(x + 14), s(86)), (s(x + 7), s(104))], fill=(22, 22, 20, 255))
    # veri plakasi
    d.rounded_rectangle([s(68), s(112), s(176), s(184)], radius=s(3), fill=(198, 200, 190, 255), outline=(20, 20, 18, 230), width=s(1.2))
    print_text(img, (122, 124), 'BCU  BA-4B', 10, (30, 32, 28, 255), alpha=240)
    for i in range(4):
        d.rectangle([s(76), s(136 + i * 9), s(76 + 70 - i * 9), s(139 + i * 9)], fill=(60, 62, 56, 170))
    d.rectangle([s(152), s(138), s(168), s(172)], outline=(40, 42, 36, 230), width=s(1.2))
    d.polygon([(s(160), s(142)), (s(154), s(158)), (s(160), s(158)), (s(157), s(170)), (s(167), s(152)), (s(161), s(152)), (s(164), s(142))], fill=(40, 42, 36, 230))
    # LED
    d.ellipse([s(46), s(78), s(56), s(88)], fill=(70, 150, 74, 255), outline=(10, 10, 10, 255), width=s(1.2))
    d.ellipse([s(48), s(80), s(52), s(84)], fill=(190, 235, 190, 220))
    scuffs(img, (38, 76, 206, 196), 40, True)
    finish(img, 'missile_battery')


def barrel(name, heavy):
    img = canvas()
    shadow(img, (22, 156, 238, 190), 9)
    th = 44 if heavy else 28
    y0 = 128 - th / 2
    steel = (96, 100, 106)
    # ana gövde (yatay silindir)
    cylinder(img, 30, y0, 214, y0 + th, steel, False, r=5, spec=0.9, tex=7)
    # isi renklenmesi (haznede mavi-kahve)
    ov = Image.new('RGBA', img.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(ov)
    for i in range(40):
        a = int(70 * (1 - i / 40))
        od.rectangle([s(30 + i * 1.2), s(y0), s(31 + i * 1.2), s(y0 + th)], fill=(90, 70, 120, a))
    img.alpha_composite(ov)
    if heavy:
        # sogutma oluklari: tekrar eden halkalar
        for x in range(72, 196, 11):
            cylinder(img, x, y0 - 5, x + 5.5, y0 + th + 5, (120, 124, 130), False, r=2, spec=0.9, tex=5)
            cylinder(img, x + 5.5, y0 - 1, x + 11, y0 + th + 1, (60, 62, 68), False, r=1, spec=0.4, tex=5)
        cylinder(img, 30, y0 - 7, 66, y0 + th + 7, (84, 88, 94), False, r=4, spec=0.8, tex=7)
        for x in (36, 46, 56):
            cylinder(img, x, y0 - 7, x + 3, y0 + th + 7, (40, 42, 46), False, r=1, spec=0.3, tex=4)
    else:
        # delikli koruyucu
        cylinder(img, 56, y0 - 3, 178, y0 + th + 3, (80, 84, 90), False, r=4, spec=0.8, tex=7)
        d = ImageDraw.Draw(img, 'RGBA')
        for x in np.arange(66, 172, 12):
            for yy in (y0 + 7, y0 + th - 11):
                d.ellipse([s(x), s(yy), s(x + 6), s(yy + 4.5)], fill=(8, 8, 8, 235))
        cylinder(img, 30, y0 - 4, 56, y0 + th + 4, (70, 74, 80), False, r=3, spec=0.8, tex=7)
    # gaz blogu ve uc
    cylinder(img, 176, y0 - 10, 196, y0 + th + 10, (62, 64, 70), False, r=3, spec=0.8, tex=6)
    cylinder(img, 206, y0 + 2, 238, y0 + th - 2, (44, 46, 50), False, r=4, spec=0.7, tex=6)
    d = ImageDraw.Draw(img, 'RGBA')
    for i in range(4):
        d.line([s(212 + i * 6), s(y0 + 4), s(212 + i * 6), s(y0 + th - 4)], fill=(4, 4, 4, 240), width=s(2))
    # tel etiket (sari cizgi, soluk) ve isimlendirme
    d.rectangle([s(74), s(y0 + th + 12), s(112), s(y0 + th + 18)], fill=(176, 150, 52, 235))
    print_text(img, (150, y0 + th + 15), '7.62' if heavy else '5.56', 8, (210, 212, 200, 255), alpha=200)
    scuffs(img, (34, y0, 214, y0 + th), 30, True)
    finish(img, name)


for tag, lith in (('nvg_aa', False), ('nvg_li', True)):
    for p in (100, 75, 50, 25, 10):
        battery('%s_%d' % (tag, p), lith, p / 100.0)
battery('nvg_dead', False, 0, dead=True)
lens_cloth()
cleaning_kit()
oil()
spare_parts()
heat_glove()
missile_battery()
barrel('barrel_light', False)
barrel('barrel_heavy', True)
print(len(os.listdir(OUT)), 'ikon yazildi:', os.path.normpath(OUT))
