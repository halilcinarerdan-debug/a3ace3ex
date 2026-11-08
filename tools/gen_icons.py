#!/usr/bin/env python3
"""TAC envanter ikonlari v3: gercek 3 boyutlu cizim (SDF ray-marching, tools/sdf3d.py): bevel, yumusak golge, AO, dokulu malzeme.
Kullanim: python3 tools/gen_icons.py   (Pillow + numpy gerekir; ~1 dk)
Cikti: addons/main/data/icons/*_ca.png (256x256, seffaf zemin) -> Arma icin .paa'ya cevrilmeli (bkz. README)."""
import os, sys, math
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from sdf3d import *

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'addons', 'main', 'data', 'icons')
os.makedirs(OUT, exist_ok=True)
FONTS = ['/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf', '/usr/share/fonts/truetype/liberation/LiberationMono-Bold.ttf']
SIZE = 256


def font(px):
    for f in FONTS:
        if os.path.exists(f):
            return ImageFont.truetype(f, px)
    return ImageFont.load_default()


def decal(w, h, items, bg=(0, 0, 0, 0)):
    """items: [(kind, ...)] 'text',(x,y),txt,px,color  /  'rect',(x0,y0,x1,y1),color"""
    im = Image.new('RGBA', (w, h), bg)
    d = ImageDraw.Draw(im)
    for it in items:
        if it[0] == 'text':
            d.text(it[1], it[2], font=font(it[3]), fill=it[4], anchor='mm')
        elif it[0] == 'rect':
            d.rectangle(it[1], fill=it[2])
        elif it[0] == 'poly':
            d.polygon(it[1], fill=it[2])
    return im


def planar(img, cx, cy, w, h, normal_min=0.55, face_z=True):
    """Duz yuzey uzerine decal: Pr yerel koordinat, on yuz (+z)."""
    def fn(P, a, N):
        u = (P[:, 0] - cx) / w + 0.5
        v = (P[:, 1] - cy) / h + 0.5
        m = (u >= 0) & (u <= 1) & (v >= 0) & (v <= 1) & (N[:, 2] > normal_min)
        t = tex_from_image(img, np.clip(u, 0, 1), np.clip(v, 0, 1))
        al = (t[:, 3] * m)[:, None]
        return a * (1 - al) + t[:, :3] * al
    return fn


def wrap(img, cx, cz, y0, hgt, span=0.95):
    """Dikey silindire sarilmis decal (on yuz). u: aci, v: yukseklik."""
    def fn(P, a, N):
        th = np.arctan2(P[:, 0] - cx, P[:, 2] - cz)
        u = (th + span) / (2 * span)
        v = (P[:, 1] - y0) / hgt
        m = (np.abs(th) < span) & (v >= 0) & (v <= 1)
        t = tex_from_image(img, np.clip(u, 0, 1), np.clip(v, 0, 1))
        al = (t[:, 3] * m)[:, None]
        return a * (1 - al) + t[:, :3] * al
    return fn


def chain(*fns):
    def fn(P, a, N):
        for f in fns:
            a = f(P, a, N)
        return a
    return fn


def view(ax=0.42, ay=-0.5, az=0.0):
    return lambda p: rot(p, ax, ay, az)


def save(img, name):
    img.save(os.path.join(OUT, name + '_ca.png'))


# ---------------------------------------------------------------- piller
def cell_parts(cx, base_y, body, bandc, label, dead, lithium):
    rad, hh = 0.22, 0.62
    cy = base_y
    img = decal(256, 512, [
        ('rect', (0, 190, 256, 300), bandc + (255,)),
        ('text', (128, 245), label, 56, (240, 238, 228, 255)),
        ('text', (128, 360), '1.5V', 40, (215, 215, 205, 200)),
        ('text', (128, 120), 'AA' if not lithium else 'Li-FeS2', 34, (215, 215, 205, 190)),
    ])
    body_tint = wrap(img, cx, 0.0, cy - hh, 2 * hh, 0.95)
    if dead:
        def corr(P, a, N):
            n = noise3(P, 22.0)
            m = (n > 0.80) | ((P[:, 1] > cy + hh - 0.10) & (n > 0.55))
            a = a.copy()
            a[m] = a[m] * 0.55 + np.array([0.60, 0.66, 0.52]) * 0.45
            return a
        body_tint = chain(body_tint, corr)
    parts = [
        Part(lambda p: cyl(p, (cx, cy, 0), rad, hh, 1, 0.045), body, rough=0.35 if not dead else 0.8, spec=0.6 if not dead else 0.1,
             bump=0.01 if not dead else 0.05, bump_f=60, tint_fn=body_tint, metal=0.3),
        Part(lambda p: cyl(p, (cx, cy + hh + 0.035, 0), 0.075, 0.04, 1, 0.02), (205, 205, 200), rough=0.2, spec=0.9, metal=0.9),
        Part(lambda p: cyl(p, (cx, cy + hh - 0.1, 0), rad + 0.004, 0.035, 1, 0.01), (175, 176, 175), rough=0.25, spec=0.8, metal=0.8),
        Part(lambda p: cyl(p, (cx, cy - hh + 0.06, 0), rad + 0.004, 0.035, 1, 0.01), (165, 165, 163), rough=0.25, spec=0.8, metal=0.8),
    ]
    return parts


def battery(name, lithium, pct, dead=False):
    if dead:
        body, bnd, lab = (78, 80, 76), (70, 70, 66), 'AA'
    elif lithium:
        body, bnd, lab = (185, 190, 196), (36, 60, 112), '%d%%' % pct
    else:
        body, bnd, lab = (34, 36, 38), (150, 98, 40), '%d%%' % pct
    parts = cell_parts(-0.27, -0.12, body, bnd, lab, dead, lithium) + cell_parts(0.27, -0.28, body, bnd, lab, dead, lithium)
    img = render(parts, size=SIZE, ss=2, rot_fn=view(0.30, -0.45), extent=1.15)
    save(img, name)


# ---------------------------------------------------------------- sise / torba
def oil():
    lab = decal(256, 256, [('rect', (0, 0, 256, 256), (226, 222, 204, 255)), ('text', (128, 70), 'GUN OIL', 42, (34, 34, 30, 255)),
                           ('text', (128, 125), 'CLP', 40, (34, 34, 30, 255)), ('rect', (30, 160, 226, 168), (34, 34, 30, 255)),
                           ('text', (128, 200), '118 ml', 30, (34, 34, 30, 255))])
    parts = [
        Part(lambda p: cyl(p, (0, -0.42, 0), 0.5, 0.52, 1, 0.14), (96, 54, 18), rough=0.12, spec=1.0,
             tint_fn=wrap(lab, 0, 0, -0.78, 0.78, 0.9)),
        Part(lambda p: cyl(p, (0, 0.2, 0), 0.24, 0.22, 1, 0.07), (92, 50, 17), rough=0.12, spec=1.0),
        Part(lambda p: cyl(p, (0, 0.52, 0), 0.19, 0.17, 1, 0.04), (24, 26, 26), rough=0.45, spec=0.5, bump=0.02, bump_f=70),
        Part(lambda p: cyl(p, (0, 0.82, 0), 0.075, 0.2, 1, 0.03), (32, 34, 34), rough=0.35, spec=0.7),
    ]
    img = render(parts, size=SIZE, ss=2, rot_fn=view(0.22, -0.5), extent=1.2)
    save(img, 'oil')


def pouch(label, col, name, hh=0.46, with_rod=False, with_parts=False):
    lab = decal(512, 128, [('rect', (0, 0, 512, 128), (58, 62, 50, 255)), ('text', (256, 64), label, 54, (214, 212, 192, 255))])
    zip_fn = lambda P, a, N: np.where(((np.abs(P[:, 1] - 0.12) < 0.016) & (N[:, 2] > 0.4))[:, None], np.array([0.06, 0.06, 0.055]), a)
    stitch = lambda P, a, N: np.where((((np.abs(P[:, 0]) > 0.62) & (np.abs(P[:, 0]) < 0.635)) | ((np.abs(P[:, 1] + 0.30) < 0.008) & (np.abs(P[:, 0]) < 0.62)))[:, None] & (N[:, 2] > 0.4)[:, None], a * 0.55 + 0.35, a)
    tint = chain(stitch, zip_fn, planar(lab, 0, -0.13, 0.62, 0.155))
    parts = [Part(lambda p: rbox(p, (0, -0.05, 0), (0.78, hh, 0.26), 0.09), col, rough=0.85, spec=0.08, bump=0.07, bump_f=90, tint_fn=tint),
             Part(lambda p: rbox(p, (0.56, 0.12, 0.27), (0.07, 0.04, 0.012), 0.008), (30, 30, 28), rough=0.4, spec=0.7)]
    if with_rod:
        parts += [Part(lambda p: capsule(p, (0.3, 0.3, 0), (0.3, 1.05, 0), 0.025), (190, 192, 196), rough=0.2, spec=0.9, metal=0.9),
                  Part(lambda p: cyl(p, (0.3, 0.98, 0), 0.075, 0.1, 1, 0.03), (150, 110, 42), rough=0.9, spec=0.1, bump=0.15, bump_f=120),
                  Part(lambda p: cyl(p, (0.3, 0.3, 0), 0.06, 0.07, 1, 0.02), (30, 30, 28), rough=0.5, spec=0.4)]
    if with_parts:
        parts += [Part(lambda p: capsule(p, (-0.45, 0.28, 0), (-0.45, 0.85, 0), 0.03), (176, 178, 180), rough=0.2, spec=0.9, metal=0.9),
                  Part(lambda p: cyl(p, (-0.45, 0.3, 0), 0.07, 0.04, 1, 0.02), (110, 112, 114), rough=0.3, spec=0.8, metal=0.8),
                  Part(lambda p: capsule(p, (0.15, 0.28, 0.0), (0.15, 0.7, 0.0), 0.018), (170, 136, 80), rough=0.3, spec=0.8, metal=0.7)]
    img = render(parts, size=SIZE, ss=2, rot_fn=view(0.5, -0.42), extent=1.28)
    save(img, name)


def lens_cloth():
    lab = decal(256, 64, [('rect', (0, 0, 256, 64), (58, 62, 60, 255)), ('text', (128, 32), 'LENS', 36, (205, 208, 196, 255))])
    parts = [
        Part(lambda p: rbox(rot(p - np.array([0.03, -0.1, 0.0]), 0, 0, -0.06), (0, 0, 0), (0.62, 0.025, 0.46), 0.02), (84, 98, 110), rough=0.92, spec=0.05, bump=0.1, bump_f=130),
        Part(lambda p: rbox(rot(p - np.array([-0.04, 0.05, 0.02]), 0, 0, 0.03), (0, 0, 0), (0.62, 0.03, 0.46), 0.02), (112, 128, 140), rough=0.92, spec=0.05, bump=0.1, bump_f=130,
             tint_fn=lambda P, a, N: np.where(((np.abs(P[:, 0] - 0.30) < 0.14) & (np.abs(P[:, 2]) < 0.26) & (N[:, 1] > 0.5))[:, None], np.array([0.24, 0.26, 0.24]), a)),
        Part(lambda p: rbox(p, (-0.02, 0.095, 0.02), (0.012, 0.012, 0.44), 0.01), (70, 82, 92), rough=0.95, spec=0.03),
    ]
    img = render(parts, size=SIZE, ss=2, rot_fn=view(0.85, -0.35, 0.0), extent=1.15)
    save(img, 'lens_cloth')


def bcu():
    plate = decal(512, 384, [('rect', (0, 0, 512, 384), (198, 200, 190, 255)),
                             ('rect', (20, 20, 492, 80), (176, 150, 52, 255))] +
                  [('poly', [(20 + i * 44, 80), (20 + i * 44 + 24, 20), (20 + i * 44 + 44, 20), (20 + i * 44 + 20, 80)], (22, 22, 20, 255)) for i in range(11)] +
                  [('text', (256, 130), 'BCU  BA-4B', 54, (30, 32, 28, 255)), ('rect', (30, 190, 360, 200), (60, 62, 56, 255)),
                   ('rect', (30, 225, 300, 235), (60, 62, 56, 255)), ('rect', (30, 260, 240, 270), (60, 62, 56, 255)),
                   ('rect', (395, 190, 470, 330), (40, 42, 36, 255)), ('text', (256, 340), '28V DC  4.2Ah', 30, (30, 32, 28, 255))])
    parts = [
        Part(lambda p: rbox(p, (0, -0.1, 0), (0.78, 0.55, 0.34), 0.07), (78, 86, 64), rough=0.8, spec=0.1, bump=0.06, bump_f=80,
             tint_fn=planar(plate, 0, -0.14, 1.0, 0.62)),
        Part(lambda p: rbox(p, (0, 0.55, 0), (0.42, 0.08, 0.16), 0.03), (38, 40, 42), rough=0.6, spec=0.3),
    ]
    for x in (-0.24, -0.08, 0.08, 0.24):
        parts.append(Part((lambda x: lambda p: capsule(p, (x, 0.58, 0), (x, 0.92, 0), 0.035))(x), (186, 156, 68), rough=0.25, spec=0.9, metal=0.9))
    for x in (-0.55, -0.40, 0.40, 0.55):
        parts.append(Part((lambda x: lambda p: rbox(p, (x, -0.1, 0.34), (0.018, 0.48, 0.02), 0.01))(x), (52, 58, 42), rough=0.85, spec=0.05))
    parts.append(Part(lambda p: sphere(p, (-0.62, 0.34, 0.34), 0.035), (70, 160, 76), rough=0.2, spec=0.9))
    img = render(parts, size=SIZE, ss=2, rot_fn=view(0.35, -0.5), extent=1.25)
    save(img, 'missile_battery')


def glove():
    leather = (116, 92, 62)
    cloth = (62, 60, 56)
    def fingers(p):
        d = capsule(p, (-0.42, 0.18, 0), (-0.46, 0.78, 0), 0.115)
        d = smin(d, capsule(p, (-0.15, 0.2, 0), (-0.16, 0.92, 0), 0.115), 0.04)
        d = smin(d, capsule(p, (0.12, 0.2, 0), (0.13, 0.9, 0), 0.115), 0.04)
        d = smin(d, capsule(p, (0.38, 0.15, 0), (0.43, 0.7, 0), 0.105), 0.04)
        return d
    def palm(p):
        return rbox(p, (0, -0.15, 0), (0.58, 0.42, 0.16), 0.14)
    def thumb(p):
        return capsule(p, (0.5, -0.2, 0.0), (0.9, 0.22, 0.02), 0.13)
    def glove_all(p):
        return smin(smin(fingers(p), palm(p), 0.12), thumb(p), 0.1)
    stitch = lambda P, a, N: np.where((((np.abs(np.hypot(P[:, 0] - 0.02, P[:, 1] + 0.05) - 0.34) < 0.008)) & (N[:, 2] > 0.4))[:, None], a * 0.5 + 0.4, a)
    pad = decal(64, 64, [('rect', (0, 0, 64, 64), (255, 255, 255, 255))])
    def patch(P, a, N):
        m = (np.abs(P[:, 0] - 0.0) < 0.38) & (P[:, 1] > -0.46) & (P[:, 1] < 0.34) & (N[:, 2] > 0.35)
        m = m & (np.hypot((P[:, 0]) / 0.42, (P[:, 1] + 0.05) / 0.44) < 1)
        n = noise3(P, 40.0)[:, None] * 0.25
        return np.where(m[:, None], (np.array(leather, dtype='float32') / 255.0) * (0.85 + n), a)
    cuff = lambda p: cyl(p, (0, -0.72, 0), 0.5, 0.2, 1, 0.07)
    tag = decal(128, 48, [('rect', (0, 0, 128, 48), (176, 112, 38, 255)), ('text', (64, 24), '250C', 30, (30, 22, 10, 255))])
    parts = [
        Part(glove_all, cloth, rough=0.9, spec=0.05, bump=0.11, bump_f=110, tint_fn=chain(patch, stitch)),
        Part(cuff, (46, 48, 50), rough=0.8, spec=0.1, bump=0.08, bump_f=100,
             tint_fn=lambda P, a, N: np.where(((np.sin(P[:, 1] * 90) > 0.6) & (N[:, 2] > 0.3))[:, None], a * 0.6, a)),
        Part(lambda p: rbox(p, (0.0, -0.7, 0.505), (0.17, 0.065, 0.012), 0.005), (176, 112, 38), rough=0.6, spec=0.2,
             tint_fn=planar(tag, 0.0, -0.7, 0.34, 0.13)),
    ]
    img = render(parts, size=SIZE, ss=2, rot_fn=view(0.12, -0.2), extent=1.3)
    save(img, 'heat_glove')


def gear_sdf(p, c, rad, n=11, hh=0.05):
    q = p - np.asarray(c)
    th = np.arctan2(q[..., 2], q[..., 0])
    r = np.hypot(q[..., 0], q[..., 2]) - rad * (1 + 0.1 * np.tanh(4 * np.sin(n * th)))
    return np.maximum(r, np.abs(q[..., 1]) - hh)


def barrel(name, heavy):
    rad = 0.30 if heavy else 0.20
    parts = []
    body = lambda p: cyl(p, (-0.1, 0, 0), rad, 0.9, 0, 0.04)
    if heavy:
        def fins(p):
            q = p.copy()
            q[..., 0] = ((p[..., 0] + 0.55) % 0.17) - 0.085
            return cyl(q, (0, 0, 0), rad + 0.07, 0.04, 0, 0.012)
        def heavy_body(p):
            d = body(p)
            f = fins(p)
            f = np.maximum(f, np.abs(p[..., 0] - 0.05) - 0.55)
            return np.minimum(d, f)
        parts.append(Part(heavy_body, (96, 100, 106), rough=0.35, spec=0.7, bump=0.02, bump_f=70, metal=0.8,
                          tint_fn=lambda P, a, N: np.where((P[:, 0] < -0.55)[:, None], a * 0.55 + np.array([0.18, 0.16, 0.26]) * 0.45, a)))
    else:
        def light_body(p):
            d = body(p)
            for x in np.arange(-0.4, 0.5, 0.17):
                for sgn in (1, -1):
                    hole = capsule(p, (x, sgn * 0.0, -0.4), (x, sgn * 0.0, 0.4), 0.035) if False else 1e3
            # koruyucu delikleri: iki sira (on / arka), z yonunde
            hs = np.full(p.shape[:-1], 1e3)
            for x in np.arange(-0.38, 0.5, 0.15):
                hs = np.minimum(hs, np.hypot(p[..., 0] - x, p[..., 1] - 0.0) - 0.04)
            hs = np.where(np.abs(p[..., 2]) > 0.05, hs, 1e3)
            return np.maximum(d, -hs)
        parts.append(Part(light_body, (92, 96, 102), rough=0.4, spec=0.7, bump=0.02, bump_f=70, metal=0.8,
                          tint_fn=lambda P, a, N: np.where((P[:, 0] < -0.55)[:, None], a * 0.6 + np.array([0.18, 0.16, 0.26]) * 0.4, a)))
    parts += [
        Part(lambda p: cyl(p, (0.62, 0, 0), rad + 0.07, 0.07, 0, 0.02), (58, 60, 66), rough=0.4, spec=0.7, metal=0.8),
        Part(lambda p: np.maximum(cyl(p, (0.95, 0, 0), rad * 0.9, 0.2, 0, 0.03), -(np.abs(((p[..., 0] - 0.78) % 0.09) - 0.045) - 0.012) * 0 - 1e3 * 0), (40, 42, 46), rough=0.5, spec=0.6, metal=0.7),
    ]
    img = render(parts, size=SIZE, ss=2, rot_fn=view(0.35, 0.0, 0.18), extent=1.3)
    save(img, name)


if __name__ == '__main__':
    for tag, lith in (('nvg_aa', False), ('nvg_li', True)):
        for pc in (100, 75, 50, 25, 10):
            battery('%s_%d' % (tag, pc), lith, pc)
    battery('nvg_dead', False, 0, dead=True)
    lens_cloth()
    oil()
    pouch('CLEANING KIT', (84, 94, 62), 'cleaning_kit', with_rod=True)
    pouch('SPARE PARTS', (120, 102, 74), 'spare_parts', with_parts=True)
    glove()
    bcu()
    barrel('barrel_light', False)
    barrel('barrel_heavy', True)
    print(len(os.listdir(OUT)), 'ikon yazildi:', os.path.normpath(OUT))
