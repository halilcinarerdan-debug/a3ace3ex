#!/usr/bin/env python3
"""TAC envanter ikonlari v4: 2D yukseklik haritasi + isik (telsiz referansi gibi), eskitilmis / milsim.
Her ikon: yukseklik haritasi (bevel, cukur, kabartma) + boya katmani + yazi; normal -> isik, AO, kenar asinmasi,
cizik, gren, kir, yumusak golge. Kullanim: python3 tools/gen_icons.py (Pillow + numpy; ~20 sn)
Cikti: addons/main/data/icons/*_ca.png (256x256, seffaf zemin) -> Arma icin .paa'ya cevrilmeli (bkz. README)."""
import os, math
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'addons', 'main', 'data', 'icons')
os.makedirs(OUT, exist_ok=True)
S = 2                    # cizim olcegi (256 tasarim -> 512 cizim -> 256 cikti)
W = 256 * S
FB = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
FM = '/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf'


def font(px, f=FB):
    return ImageFont.truetype(f, int(px * S)) if os.path.exists(f) else ImageFont.load_default()


def blur_im(im, r):
    return np.asarray(im.filter(ImageFilter.GaussianBlur(r * S)), dtype='float32') / 255.0


class Icon:
    def __init__(self, seed=1):
        self.rng = np.random.default_rng(seed)
        self.h = np.zeros((W, W), dtype='float32')
        self.alb = np.zeros((W, W, 3), dtype='float32')
        self.obj = np.zeros((W, W), dtype='float32')       # nesne maskesi (alfa)
        self.shade_mul = np.ones((W, W), dtype='float32')
        self.txt = Image.new('RGBA', (W, W), (0, 0, 0, 0))
        self.wear_mul = np.zeros((W, W), dtype='float32')  # bolge bazli asinma miktari

    # --- maskeler ---
    def mask(self, fn):
        im = Image.new('L', (W, W), 0)
        fn(ImageDraw.Draw(im))
        return im

    def rrect(self, x0, y0, x1, y1, r=3):
        return self.mask(lambda d: d.rounded_rectangle([x0 * S, y0 * S, x1 * S, y1 * S], radius=r * S, fill=255))

    def ell(self, x0, y0, x1, y1):
        return self.mask(lambda d: d.ellipse([x0 * S, y0 * S, x1 * S, y1 * S], fill=255))

    def poly(self, pts):
        return self.mask(lambda d: d.polygon([(x * S, y * S) for x, y in pts], fill=255))

    # --- katmanlar ---
    def paint(self, m, color, a=1.0, wear=None):
        mm = (np.asarray(m, dtype='float32') / 255.0 * a)
        self.alb = self.alb * (1 - mm[..., None]) + np.array(color, dtype='float32') * mm[..., None]
        if wear is not None:
            self.wear_mul = self.wear_mul * (1 - mm) + wear * mm

    def part(self, m, color, hgt=0.5, bev=1.5, wear=0.6, a=1.0, obj=True):
        """Kabartili parca: yukseklik (bulaniklastirilmis maske) + boya + nesne maskesi."""
        self.h += blur_im(m, bev) * hgt
        self.paint(m, color, a, wear)
        if obj:
            self.obj = np.maximum(self.obj, np.asarray(m, dtype='float32') / 255.0)

    def cyl(self, x0, y0, x1, y1, color, amp=0.9, vertical=True, r=3, wear=0.5):
        """Silindirik parca: kesit profili sqrt(1-u^2) (yukseklik haritasi), kenarlara dogru kararir."""
        m = self.rrect(x0, y0, x1, y1, r)
        ma = np.asarray(m, dtype='float32') / 255.0
        yy, xx = np.mgrid[0:W, 0:W].astype('float32')
        if vertical:
            u = (xx / S - (x0 + x1) / 2) / max(1e-3, (x1 - x0) / 2)
        else:
            u = (yy / S - (y0 + y1) / 2) / max(1e-3, (y1 - y0) / 2)
        prof = np.sqrt(np.clip(1 - np.clip(u, -1, 1) ** 2, 0, 1))
        self.h = np.maximum(self.h, ma * prof * amp)
        self.paint(m, color, 1.0, wear)
        self.obj = np.maximum(self.obj, ma)

    def recess(self, m, depth=0.3, bev=1.0):
        self.h -= blur_im(m, bev) * depth

    def text(self, xy, s, px, color=(150, 150, 144, 255), f=FB, anchor='mm', spacing=0):
        d = ImageDraw.Draw(self.txt)
        if spacing:
            x = xy[0]
            for ch in s:
                d.text((x * S, xy[1] * S), ch, font=font(px, f), fill=color, anchor=anchor)
                x += spacing
        else:
            d.text((xy[0] * S, xy[1] * S), s, font=font(px, f), fill=color, anchor=anchor)

    def screw(self, x, y, r=3.2, color=(78, 78, 74)):
        self.part(self.ell(x - r, y - r, x + r, y + r), color, 0.25, 0.8, 0.4)
        self.recess(self.mask(lambda d: d.line([(x - r * .6) * S, (y - r * .6) * S, (x + r * .6) * S, (y + r * .6) * S], fill=255, width=max(1, int(0.9 * S)))), 0.22, 0.4)

    def stitch(self, pts, color=(206, 198, 168), step=4.2, dash=2.2, closed=False, a=0.7):
        d = ImageDraw.Draw(self.txt)
        seq = pts + ([pts[0]] if closed else [])
        for (xa, ya), (xb, yb) in zip(seq[:-1], seq[1:]):
            L = math.hypot(xb - xa, yb - ya)
            n = max(1, int(L / step))
            for i in range(n):
                t0 = i / n; t1 = min(1, t0 + dash / L)
                d.line([(xa + (xb - xa) * t0) * S, (ya + (yb - ya) * t0) * S, (xa + (xb - xa) * t1) * S, (ya + (yb - ya) * t1) * S], fill=color + (int(255 * a),), width=max(1, int(0.8 * S)))

    # --- son isleme ---
    def finish(self, name, wear=1.0, grain_amp=2.2, shadow=True):
        rng = self.rng
        # yazi katmanini boyaya isle
        t = np.asarray(self.txt, dtype='float32') / 255.0
        self.alb = self.alb * (1 - t[..., 3:4]) + t[..., :3] * 255 * t[..., 3:4]
        self.h += blur_im(Image.fromarray((t[..., 3] * 255).astype('uint8')), 0.4) * 0.05
        # gren + yumusak lekeler
        g = rng.normal(0, 1, (W, W)).astype('float32')
        gr = np.asarray(Image.fromarray(np.clip(g * 40 + 128, 0, 255).astype('uint8')).filter(ImageFilter.GaussianBlur(0.7 * S * 0.5)), dtype='float32') - 128
        gr = gr / max(1e-6, gr.std())
        self.alb += (gr * grain_amp)[..., None]
        self.h += gr * 0.0015
        bl = np.asarray(Image.fromarray(np.clip(rng.normal(128, 40, (W // 8, W // 8)), 0, 255).astype('uint8')).resize((W, W), Image.BICUBIC).filter(ImageFilter.GaussianBlur(6 * S)), dtype='float32') - 128
        self.alb *= (1 + bl[..., None] / 128 * 0.26)
        # cizikler
        sc = Image.new('L', (W, W), 0)
        sd = ImageDraw.Draw(sc)
        ys, xs = np.where(self.obj > 0.5)
        if len(xs):
            for _ in range(int(40 * wear)):
                i = rng.integers(0, len(xs))
                x0, y0 = xs[i] / S, ys[i] / S
                a = rng.uniform(-0.6, 0.6) + (math.pi / 2 if rng.random() < 0.4 else 0)
                l = rng.uniform(4, 22)
                sd.line([x0 * S, y0 * S, (x0 + l * math.cos(a)) * S, (y0 + l * math.sin(a)) * S], fill=int(rng.uniform(70, 150)), width=1)
        scn = np.asarray(sc.filter(ImageFilter.GaussianBlur(0.4)), dtype='float32') / 255.0
        self.alb += (scn * 42 * (0.3 + self.wear_mul))[..., None]
        # normal -> isik
        K = 4.2
        gy, gx = np.gradient(self.h * 14)
        nz = 1.0 / np.sqrt(1 + (gx * K) ** 2 + (gy * K) ** 2)
        nx, ny = -gx * K * nz, -gy * K * nz
        L = np.array([-0.45, -0.55, 0.70]); L /= np.linalg.norm(L)
        diff = np.clip(nx * L[0] + ny * L[1] + nz * L[2], 0, 1)
        hv = L + np.array([0, 0, 1.0]); hv /= np.linalg.norm(hv)
        sp = np.clip(nx * hv[0] + ny * hv[1] + nz * hv[2], 0, 1) ** 20 * 0.16
        hb = np.asarray(Image.fromarray(np.clip(self.h * 120, 0, 255).astype('uint8')).filter(ImageFilter.GaussianBlur(5 * S * 0.5)), dtype='float32') / 120
        ao = np.clip(1 - np.clip(hb - self.h, 0, 1) * 1.6, 0.45, 1)
        shade = (0.22 + 0.95 * diff) * ao * self.shade_mul
        edge = np.clip((np.hypot(gx, gy) * 14 - 0.45) * 0.9, 0, 1)
        wr = edge * np.clip(0.35 + gr * 0.35, 0, 1) * 0.8 * wear * self.wear_mul
        col = self.alb * shade[..., None] + (wr * 34)[..., None] * (shade[..., None] * 0.8 + 0.2)
        col += (sp * 255)[..., None] * (0.5 + 0.5 * (self.alb.mean(axis=2, keepdims=True) / 100))
        rgb = Image.fromarray(np.clip(col, 0, 255).astype('uint8'), 'RGB').filter(ImageFilter.GaussianBlur(0.4 * S * 0.5))
        a = Image.fromarray((np.clip(self.obj, 0, 1) * 255).astype('uint8'), 'L').filter(ImageFilter.GaussianBlur(0.35 * S))
        out = Image.new('RGBA', (W, W), (0, 0, 0, 0))
        if shadow:
            sh = Image.fromarray((np.clip(self.obj, 0, 1) * 255).astype('uint8'), 'L').filter(ImageFilter.GaussianBlur(5 * S))
            shadow_im = Image.new('RGBA', (W, W), (0, 0, 0, 0))
            shadow_im.putalpha(sh.point(lambda v: int(v * 0.42)))
            out.alpha_composite(shadow_im, (3 * S, 6 * S))
        obj = rgb.convert('RGBA')
        obj.putalpha(a)
        out.alpha_composite(obj)
        out = out.resize((256, 256), Image.LANCZOS)
        out.save(os.path.join(OUT, name + '_ca.png'))


# ================================================================ esyalar
def battery(name, lithium, pct, dead=False):
    ic = Icon(seed=hash(name) % 9999)
    if dead:
        body, bnd = (72, 74, 70), (64, 64, 60)
    elif lithium:
        body, bnd = (176, 182, 188), (40, 64, 118)
    else:
        body, bnd = (40, 42, 44), (150, 100, 42)
    for cx, top in ((88, 50), (156, 66)):
        w, h = 58, 148
        ic.cyl(cx - 4, top - 8, cx + 4, top + 4, (196, 196, 190), 0.5, True, 1.5, 0.4)             # + kapagi
        ic.cyl(cx - w / 2, top, cx + w / 2, top + h, body, 1.0, True, 5, 0.7 if not dead else 0.3)
        ic.cyl(cx - w / 2, top + 5, cx + w / 2, top + 17, (168, 170, 168), 1.05, True, 2, 0.8)       # ust halka
        ic.cyl(cx - w / 2, top + h - 13, cx + w / 2, top + h - 3, (150, 150, 148), 1.05, True, 2, 0.8)
        ic.cyl(cx - w / 2, top + h * 0.42, cx + w / 2, top + h * 0.42 + 24, bnd, 1.02, True, 1, 0.8)  # renk bandi
        lab = 'AA' if dead else '%d%%' % pct
        ic.text((cx, top + h * 0.42 + 12), lab, 12 if not dead else 11, (236, 232, 220, 255), FM)
        ic.text((cx, top + h * 0.80), '1.5V', 9, (210, 210, 200, 190), FM)
        if dead:
            for (px, py, r) in ((cx + 2, top - 6, 7), (cx - 8, top + 3, 5), (cx + 11, top + 5, 4)):
                m = ic.ell(px - r, py - r * .5, px + r, py + r * .5)
                ic.part(m, (150, 160, 128), 0.12, 0.8, 0.0)
    ic.finish(name, wear=0.9 if not dead else 1.2)


def pouch(ic, x0, y0, x1, y1, color, label, zip_y):
    ic.part(ic.rrect(x0, y0, x1, y1, 9), color, 0.9, 2.5, 0.8)
    ic.recess(ic.mask(lambda d: d.line([(x0 + 8) * S, zip_y * S, (x1 - 8) * S, zip_y * S], fill=255, width=int(3 * S))), 0.35, 0.5)
    ic.paint(ic.mask(lambda d: d.line([(x0 + 8) * S, zip_y * S, (x1 - 8) * S, zip_y * S], fill=255, width=int(2 * S))), (20, 20, 18), 1.0)
    for x in np.arange(x0 + 12, x1 - 10, 3.4):
        ic.txt_dash = None
    ic.part(ic.rrect(x1 - 26, zip_y - 4, x1 - 12, zip_y + 7, 2), (30, 30, 28), 0.5, 0.8, 0.6)    # fermuar cekici
    ic.stitch([(x0 + 8, y0 + 8), (x1 - 8, y0 + 8), (x1 - 8, y1 - 8), (x0 + 8, y1 - 8)], closed=True)
    px0, px1 = (x0 + x1) / 2 - 42, (x0 + x1) / 2 + 42
    py0 = zip_y + (y1 - zip_y) * 0.28
    ic.part(ic.rrect(px0, py0, px1, py0 + 24, 2), (54, 58, 46), 0.18, 0.8, 0.5)
    ic.text(((px0 + px1) / 2, py0 + 12), label, 10, (210, 208, 188, 255), FM)


def cleaning_kit():
    ic = Icon(2)
    ic.cyl(122, 22, 130, 118, (190, 192, 196), 0.9, True, 2, 0.6)       # cubuk
    ic.cyl(114, 22, 138, 52, (176, 130, 50), 0.8, True, 4, 0.3)          # firca
    for y in range(26, 50, 4):
        ic.recess(ic.mask(lambda d, y=y: d.line([114 * S, y * S, 138 * S, y * S], fill=255, width=S)), 0.18, 0.3)
    ic.cyl(112, 110, 140, 122, (34, 34, 32), 0.9, True, 3, 0.6)          # tutamak
    pouch(ic, 30, 96, 226, 210, (82, 94, 62), 'CLEANING KIT', 128)
    ic.finish('cleaning_kit', wear=1.0)


def spare_parts():
    ic = Icon(3)
    ic.cyl(50, 56, 60, 130, (176, 178, 180), 0.9, True, 2, 0.6)
    ic.cyl(44, 52, 66, 66, (110, 112, 114), 0.9, True, 3, 0.6)
    for i in range(8):                                                   # yay
        y = 44 + i * 6
        ic.part(ic.rrect(86, y, 116, y + 4, 2), (156, 160, 166), 0.5, 0.8, 0.5)
    ic.cyl(142, 62, 148, 130, (166, 140, 86), 0.9, True, 2, 0.6)
    pouch(ic, 30, 108, 226, 212, (118, 100, 72), 'SPARE PARTS', 138)
    ic.finish('spare_parts', wear=1.0)


def lens_cloth():
    ic = Icon(4)
    ic.part(ic.rrect(36, 82, 214, 194, 7), (88, 100, 110), 0.7, 2.5, 0.8)
    ic.part(ic.rrect(50, 66, 226, 176, 7), (112, 126, 136), 0.8, 2.5, 0.8)
    # kat izi ve kivrimlar
    ic.recess(ic.mask(lambda d: d.line([138 * S, 70 * S, 138 * S, 172 * S], fill=255, width=int(3 * S))), 0.3, 1.5)
    for (x0, y0, x1, y1) in ((60, 100, 130, 108), (150, 126, 218, 136), (70, 150, 120, 158)):
        ic.recess(ic.mask(lambda d, a=(x0, y0, x1, y1): d.line([a[0] * S, a[1] * S, a[2] * S, a[3] * S], fill=255, width=int(2 * S))), 0.14, 2.0)
    ic.stitch([(58, 74), (218, 74), (218, 168), (58, 168)], color=(196, 206, 214), closed=True, a=0.6)
    ic.part(ic.rrect(156, 140, 206, 158, 2), (56, 62, 58), 0.15, 0.8, 0.5)
    ic.text((181, 149), 'LENS', 10, (204, 208, 196, 255), FM)
    ic.finish('lens_cloth', wear=0.7)


def oil():
    ic = Icon(5)
    ic.cyl(76, 108, 180, 226, (104, 56, 18), 1.0, True, 12, 0.3)         # govde (kehribar cam)
    ic.cyl(104, 78, 152, 116, (100, 54, 18), 0.95, True, 8, 0.3)         # omuz / boyun
    ic.cyl(106, 48, 150, 84, (26, 28, 28), 0.95, True, 4, 0.5)           # kapak
    for y in (52, 60, 68):
        ic.recess(ic.mask(lambda d, y=y: d.line([106 * S, y * S, 150 * S, y * S], fill=255, width=S)), 0.18, 0.3)
    ic.cyl(120, 18, 136, 52, (34, 36, 36), 0.9, True, 3, 0.4)            # uc
    ic.part(ic.rrect(84, 138, 172, 200, 3), (222, 218, 200), 0.2, 1.0, 0.6)  # etiket
    ic.text((128, 154), 'GUN OIL', 12, (34, 34, 30, 255), FM)
    ic.text((128, 170), 'CLP', 10, (34, 34, 30, 255), FM)
    ic.paint(ic.mask(lambda d: d.rectangle([94 * S, 180 * S, 162 * S, 183 * S], fill=255)), (36, 36, 32))
    ic.text((128, 192), '118 ml', 8, (34, 34, 30, 255), FM)
    # cam parlamasi
    ic.paint(ic.rrect(82, 118, 90, 216, 3), (255, 235, 205), 0.28)
    ic.finish('oil', wear=0.5)


def heat_glove():
    ic = Icon(6)
    cloth = (66, 64, 58)
    # avuc + parmaklar + basparmak
    palm = ic.rrect(70, 94, 186, 190, 18)
    fingers = [ic.rrect(72, 40, 96, 110, 10), ic.rrect(98, 28, 122, 110, 10), ic.rrect(124, 24, 148, 110, 10), ic.rrect(150, 36, 176, 110, 10)]
    thumb = ic.mask(lambda d: d.polygon([(70 * S, 130 * S), (40 * S, 98 * S), (24 * S, 112 * S), (36 * S, 150 * S), (74 * S, 168 * S)], fill=255))
    for m in fingers + [palm, thumb]:
        ic.part(m, cloth, 0.7, 2.2, 0.7)
    # parmak ayrimlari
    for x in (97, 123, 149):
        ic.recess(ic.mask(lambda d, x=x: d.line([x * S, 52 * S, x * S, 108 * S], fill=255, width=int(2 * S))), 0.4, 1.0)
    # deri avuc yamasi
    patch = ic.mask(lambda d: d.ellipse([88 * S, 100 * S, 168 * S, 176 * S], fill=255))
    ic.part(patch, (118, 94, 64), 0.25, 1.6, 0.6)
    ic.stitch([(128 + 38 * math.cos(a), 138 + 36 * math.sin(a)) for a in np.linspace(0, 2 * math.pi, 18, endpoint=False)], closed=True, a=0.6)
    # kolluk
    ic.part(ic.rrect(76, 184, 180, 228, 6), (46, 48, 50), 0.9, 2.0, 0.8)
    for y in range(190, 226, 5):
        ic.recess(ic.mask(lambda d, y=y: d.line([78 * S, y * S, 178 * S, y * S], fill=255, width=S)), 0.18, 0.4)
    ic.part(ic.rrect(112, 200, 144, 214, 2), (176, 112, 38), 0.2, 0.8, 0.5)
    ic.text((128, 207), '250C', 9, (34, 24, 10, 255), FM)
    ic.finish('heat_glove', wear=1.0)


def missile_battery():
    ic = Icon(7)
    for x in (88, 108, 128, 148):                                        # baglanti uclari
        ic.cyl(x - 3, 24, x + 3, 66, (186, 156, 70), 0.9, True, 2, 0.5)
    ic.part(ic.rrect(70, 58, 186, 84, 4), (36, 38, 40), 0.5, 1.5, 0.6)
    ic.part(ic.rrect(34, 78, 222, 206, 7), (78, 86, 64), 1.0, 3.0, 0.9)
    for x in (46, 58, 198, 210):                                         # yan kaburgalar
        ic.recess(ic.mask(lambda d, x=x: d.line([x * S, 92 * S, x * S, 192 * S], fill=255, width=int(3 * S))), 0.35, 0.7)
    # uyari seridi
    ic.paint(ic.mask(lambda d: d.rectangle([72 * S, 92 * S, 172 * S, 110 * S], fill=255)), (172, 148, 54))
    for i in range(10):
        x = 72 + i * 11.5
        ic.paint(ic.poly([(x, 110), (x + 7, 92), (x + 14, 92), (x + 7, 110)]), (22, 22, 20))
    ic.part(ic.rrect(68, 118, 176, 188, 2), (198, 200, 190), 0.15, 0.8, 0.6)
    ic.text((122, 132), 'BCU  BA-4B', 12, (30, 32, 28, 255), FM)
    for i, w in enumerate((70, 58, 44)):
        ic.paint(ic.mask(lambda d, i=i, w=w: d.rectangle([76 * S, (148 + i * 9) * S, (76 + w) * S, (151 + i * 9) * S], fill=255)), (60, 62, 56))
    ic.paint(ic.mask(lambda d: d.rectangle([152 * S, 146 * S, 168 * S, 180 * S], outline=255, width=int(1.2 * S))), (40, 42, 36))
    ic.text((124, 180), '28V DC  4.2Ah', 8, (30, 32, 28, 255), FM)
    ic.part(ic.ell(44, 84, 54, 94), (70, 156, 74), 0.35, 0.8, 0.0)
    for sx, sy in ((42, 86), (214, 86), (42, 198), (214, 198)):
        ic.screw(sx, sy)
    ic.finish('missile_battery', wear=1.3)


def barrel(name, heavy):
    ic = Icon(8 if heavy else 9)
    th = 56 if heavy else 38
    y0 = 128 - th / 2
    steel = (92, 96, 102)
    ic.cyl(26, y0, 206, y0 + th, steel, 1.0, False, 4, 0.9)
    ic.paint(ic.rrect(26, y0, 70, y0 + th, 4), (110, 98, 120), 0.3)       # isi renklenmesi
    if heavy:
        for x in range(76, 190, 12):                                     # sogutma kanatcigi
            ic.cyl(x, y0 - 8, x + 6, y0 + th + 8, (118, 122, 128), 1.0, False, 2, 0.9)
        ic.cyl(26, y0 - 8, 66, y0 + th + 8, (78, 82, 88), 1.0, False, 4, 0.9)
    else:
        ic.cyl(60, y0 - 4, 180, y0 + th + 4, (78, 82, 88), 1.0, False, 4, 0.9)
        for x in np.arange(70, 172, 14):
            for yy in (y0 + 9, y0 + th - 15):
                ic.recess(ic.ell(x, yy, x + 7, yy + 6), 0.5, 0.5)
                ic.paint(ic.ell(x, yy, x + 7, yy + 6), (8, 8, 8))
    ic.cyl(180, y0 - 12, 200, y0 + th + 12, (62, 64, 70), 1.0, False, 3, 0.9)
    ic.cyl(200, y0 + 3, 238, y0 + th - 3, (44, 46, 50), 1.0, False, 4, 0.9)
    for i in range(4):
        ic.recess(ic.mask(lambda d, i=i: d.line([(208 + i * 7) * S, (y0 + 6) * S, (208 + i * 7) * S, (y0 + th - 6) * S], fill=255, width=int(2 * S))), 0.4, 0.5)
    ic.paint(ic.rrect(74, y0 + th + 14, 112, y0 + th + 20, 1), (172, 148, 54))
    ic.text((150, y0 + th + 17), '7.62' if heavy else '5.56', 9, (210, 212, 200, 220), FM)
    ic.finish(name, wear=1.2)


if __name__ == '__main__':
    for tag, lith in (('nvg_aa', False), ('nvg_li', True)):
        for pc in (100, 75, 50, 25, 10):
            battery('%s_%d' % (tag, pc), lith, pc)
    battery('nvg_dead', False, 0, dead=True)
    lens_cloth()
    oil()
    cleaning_kit()
    spare_parts()
    heat_glove()
    missile_battery()
    barrel('barrel_light', False)
    barrel('barrel_heavy', True)
    print(len(os.listdir(OUT)), 'ikon yazildi:', os.path.normpath(OUT))
