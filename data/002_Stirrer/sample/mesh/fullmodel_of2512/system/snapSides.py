#!/usr/bin/env python3
# 基準セクター(θ=0〜60°)の points について、θ=60°面上の点座標を
# 「θ=0°面上の対応点を+60°回転した値」に厳密スナップして新規書き出しする。
# こうすると回転コピー後の隣接セクター界面の点が計算機精度で一致し、
# ESI版 stitchMesh -perfect (絶対許容~1e-7m) が通るようになる。
# 使い方: snapSides.py <src_points> <dst_points>
import sys, re, math, itertools

src, dst = sys.argv[1], sys.argv[2]
text = open(src, encoding="latin-1").read()

pat = re.compile(r"\(\s*(-?[\d.][-\d.eE+ ]*?)\s*\)")
pts = []
spans = []
for m in pat.finditer(text):
    v = m.group(1).split()
    if len(v) == 3:
        pts.append((float(v[0]), float(v[1]), float(v[2])))
        spans.append(m.span())

c60, s60 = math.cos(math.pi/3), math.sin(math.pi/3)
tol_ang = 1e-4
th60 = math.pi/3
G = 1e-7

def gkey(x, y, z):
    return (int(round(x / G)), int(round(y / G)), int(round(z / G)))

table = {}
for (x, y, z) in pts:
    if math.hypot(x, y) < 1e-9:
        continue
    if abs(math.atan2(y, x)) < tol_ang:
        q = (c60*x - s60*y, s60*x + c60*y, z)
        table.setdefault(gkey(*q), []).append(q)

NBR = list(itertools.product((-1, 0, 1), repeat=3))

def lookup(x, y, z):
    k = gkey(x, y, z)
    best, bestd = None, 1e30
    for d in NBR:
        for q in table.get((k[0]+d[0], k[1]+d[1], k[2]+d[2]), ()):
            dd = (q[0]-x)**2 + (q[1]-y)**2 + (q[2]-z)**2
            if dd < bestd:
                best, bestd = q, dd
    if best is not None and bestd < (5e-6)**2:
        return best
    return None

repl = []
snapped = missed = 0
for idx, (x, y, z) in enumerate(pts):
    if math.hypot(x, y) < 1e-9:
        continue
    if abs(math.atan2(y, x) - th60) < tol_ang:
        q = lookup(x, y, z)
        if q is None:
            missed += 1
            continue
        repl.append((spans[idx][0], spans[idx][1],
                     "(%.17g %.17g %.17g)" % q))
        snapped += 1

out = []
pos = 0
for s, e, rep in sorted(repl):
    out.append(text[pos:s]); out.append(rep); pos = e
out.append(text[pos:])

open(dst, "w", encoding="latin-1").write("".join(out))
print(f"snapped {snapped} points on theta=60 plane, missed {missed}")
if missed:
    sys.exit(1)
