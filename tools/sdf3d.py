"""Kucuk SDF ray-marching cizici (numpy): uc boyutlu, gercek golge / AO / bevel'li ikonlar icin.
Birim: sahne ~[-1.2, 1.2]. Kamera +z'den bakar. Kullanim: sdf3d.render(parts, size=512)"""
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# ---- SDF ilkelleri (p: (..., 3)) ------------------------------------------------
def rbox(p, c, b, r=0.03):
    q = np.abs(p - np.asarray(c)) - (np.asarray(b) - r)
    out = np.linalg.norm(np.maximum(q, 0), axis=-1) + np.minimum(np.max(q, axis=-1), 0) - r
    return out

def cyl(p, c, rad, hh, axis=1, r=0.02):
    q = p - np.asarray(c)
    axes = [0, 1, 2]
    axes.remove(axis)
    d = np.stack([np.hypot(q[..., axes[0]], q[..., axes[1]]) - (rad - r), np.abs(q[..., axis]) - (hh - r)], axis=-1)
    return np.minimum(np.max(d, axis=-1), 0) + np.linalg.norm(np.maximum(d, 0), axis=-1) - r

def capsule(p, a, b, rad):
    a = np.asarray(a, dtype='float64'); b = np.asarray(b, dtype='float64')
    pa = p - a; ba = b - a
    h = np.clip(np.sum(pa * ba, axis=-1) / np.dot(ba, ba), 0, 1)
    return np.linalg.norm(pa - ba * h[..., None], axis=-1) - rad

def sphere(p, c, rad):
    return np.linalg.norm(p - np.asarray(c), axis=-1) - rad

def smin(a, b, k):
    h = np.clip(0.5 + 0.5 * (b - a) / k, 0, 1)
    return b * (1 - h) + a * h - k * h * (1 - h)

def rot(p, ax=0.0, ay=0.0, az=0.0):
    cx, sx = np.cos(ax), np.sin(ax); cy, sy = np.cos(ay), np.sin(ay); cz, sz = np.cos(az), np.sin(az)
    Rx = np.array([[1, 0, 0], [0, cx, -sx], [0, sx, cx]])
    Ry = np.array([[cy, 0, sy], [0, 1, 0], [-sy, 0, cy]])
    Rz = np.array([[cz, -sz, 0], [sz, cz, 0], [0, 0, 1]])
    return p @ (Rz @ Ry @ Rx).T

# ---- doku yardimcilari ----------------------------------------------------------
def hash3(p, f=1.0):
    q = p * f
    return (np.sin(q[..., 0] * 127.1 + q[..., 1] * 311.7 + q[..., 2] * 74.7) * 43758.5453) % 1.0

def noise3(p, f=8.0):
    """Hafif deger gurultusu (trilinear degil, 2 oktav hash)."""
    return 0.65 * hash3(np.floor(p * f), 1.0) + 0.35 * hash3(np.floor(p * f * 2.3), 1.0)

def tex_from_image(img, u, v, wrap=False):
    """u,v in [0,1] -> (...,4) float"""
    a = np.asarray(img.convert('RGBA'), dtype='float32') / 255.0
    h, w = a.shape[:2]
    xi = np.clip((u * (w - 1)).astype(int), 0, w - 1)
    yi = np.clip(((1 - v) * (h - 1)).astype(int), 0, h - 1)
    return a[yi, xi]

def label_image(w, h, draw_fn, bg=(0, 0, 0, 0)):
    im = Image.new('RGBA', (w, h), bg)
    draw_fn(ImageDraw.Draw(im), w, h)
    return im

# ---- cizici ---------------------------------------------------------------------
class Part:
    def __init__(self, sdf, albedo, rough=0.6, spec=0.2, bump=0.0, bump_f=40.0, tint_fn=None, metal=0.0):
        self.sdf, self.albedo, self.rough, self.spec, self.bump, self.bump_f, self.tint_fn, self.metal = sdf, np.asarray(albedo, dtype='float32') / 255.0, rough, spec, bump, bump_f, tint_fn, metal

def scene_eval(parts, p):
    ds = np.stack([pt.sdf(p) for pt in parts], axis=0)
    idx = np.argmin(ds, axis=0)
    return np.min(ds, axis=0), idx

def render(parts, size=256, ss=2, cam_dist=4.2, fov_scale=1.0, light=(-0.6, 0.7, 0.8), ao_strength=1.0, bg_alpha=0, rot_fn=None, extent=1.25):
    W = size * ss
    ys, xs = np.mgrid[0:W, 0:W]
    u = (xs + 0.5) / W * 2 - 1
    v = 1 - (ys + 0.5) / W * 2
    origin = np.stack([u * extent, v * extent, np.full_like(u, cam_dist, dtype='float64')], axis=-1).reshape(-1, 3)
    dirv = np.array([0, 0, -1.0])  # ortografik: iki boyutlu ikonlar icin temiz
    n = origin.shape[0]
    t = np.zeros(n)
    hit = np.zeros(n, dtype=bool)
    active = np.ones(n, dtype=bool)
    p = origin.copy()
    for _ in range(90):
        if not active.any():
            break
        idxs = np.where(active)[0]
        pp = origin[idxs] + dirv * t[idxs][:, None]
        d, _m = scene_eval(parts, rot_fn(pp) if rot_fn else pp)
        t[idxs] += d * 0.9
        h = d < 0.0015
        hit[idxs[h]] = True
        active[idxs[h]] = False
        out = t[idxs] > cam_dist * 2
        active[idxs[out]] = False
    pos = origin + dirv * t[:, None]
    P = pos[hit]
    Pr = rot_fn(P) if rot_fn else P
    eps = 0.003
    def f(q):
        return scene_eval(parts, q)[0]
    nx = f(Pr + [eps, 0, 0]) - f(Pr - [eps, 0, 0])
    ny = f(Pr + [0, eps, 0]) - f(Pr - [0, eps, 0])
    nz = f(Pr + [0, 0, eps]) - f(Pr - [0, 0, eps])
    N = np.stack([nx, ny, nz], axis=-1)
    N = N / np.maximum(np.linalg.norm(N, axis=-1, keepdims=True), 1e-9)
    _, mid = scene_eval(parts, Pr)
    albedo = np.zeros((P.shape[0], 3), dtype='float32'); rough = np.zeros(P.shape[0]); spec = np.zeros(P.shape[0]); metal = np.zeros(P.shape[0])
    for i, pt in enumerate(parts):
        m = mid == i
        if not m.any():
            continue
        a = np.tile(pt.albedo, (m.sum(), 1))
        if pt.tint_fn is not None:
            a = pt.tint_fn(Pr[m], a, N[m])
        if pt.bump > 0:
            nz_ = noise3(Pr[m], pt.bump_f)
            a = a * (1 + (nz_ - 0.5)[:, None] * pt.bump * 2)
            # normali hafif bozma
            jitter = np.stack([hash3(Pr[m], 91.0), hash3(Pr[m], 53.0), hash3(Pr[m], 17.0)], axis=-1) - 0.5
            N[m] = N[m] + jitter * pt.bump * 0.7
        albedo[m] = a; rough[m] = pt.rough; spec[m] = pt.spec; metal[m] = pt.metal
    N = N / np.maximum(np.linalg.norm(N, axis=-1, keepdims=True), 1e-9)
    L = np.asarray(light, dtype='float64'); L = L / np.linalg.norm(L)
    Rm = rot_fn(np.eye(3)).T if rot_fn else np.eye(3)
    Ncam = N @ Rm            # kamera uzayi normali (isik kamera uzayinda tanimli)
    Lobj = rot_fn(L[None, :])[0] if rot_fn else L
    # golge (yumusak): isiga dogru 28 adim
    sh = np.ones(P.shape[0])
    tt = np.full(P.shape[0], 0.03)
    for _ in range(26):
        q = Pr + Lobj * tt[:, None] + N * 0.004
        d = scene_eval(parts, q)[0]
        sh = np.minimum(sh, np.clip(8.0 * d / tt, 0, 1))
        tt += np.clip(d, 0.015, 0.15)
    # AO
    ao = np.ones(P.shape[0])
    for k in range(1, 6):
        hd = 0.05 * k
        d = scene_eval(parts, Pr + N * hd)[0]
        ao -= (hd - d) * 0.5 / (2 ** k) * 4 * ao_strength
    ao = np.clip(ao, 0.25, 1)
    diff = np.clip(Ncam @ L, 0, 1)
    fill = np.clip(Ncam @ np.array([0.6, -0.2, 0.5]) / 0.8, 0, 1) * 0.22
    sky = (0.5 + 0.5 * Ncam[..., 1]) * 0.20
    Hh = (L + np.array([0, 0, 1.0])); Hh = Hh / np.linalg.norm(Hh)
    shin = 12 + (1 - rough) * 90
    sp = np.clip(Ncam @ Hh, 0, 1) ** shin * spec * (0.4 + 0.6 * sh)
    light_t = ((0.10 + diff * sh * 0.95 + fill + sky) * ao)[:, None]
    rgb = albedo * light_t * (1 - 0.3 * metal[:, None]) + sp[:, None] * (1 + metal[:, None] * 0.6) * (albedo * 0.7 + 0.3)
    rgb = np.clip(rgb, 0, 1)
    rgb = rgb ** (1 / 1.05)
    img = np.zeros((n, 4), dtype='float32')
    img[hit, :3] = rgb
    img[hit, 3] = 1
    img = img.reshape(W, W, 4)
    # zemin golgesi (yumusak elips) arka planda
    out = Image.fromarray((img * 255).astype('uint8'), 'RGBA')
    return out.resize((size, size), Image.LANCZOS)
