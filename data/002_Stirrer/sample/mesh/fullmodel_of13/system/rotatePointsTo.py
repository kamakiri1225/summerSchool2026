#!/usr/bin/env python3
# 基準セクターの points を z 軸まわりに回転し、別ファイルとして「新規」書き出す。
# drvfs(/mnt/f) では cp -r でコピーした points が読み取り専用になり、その場
# 上書き（transformPoints も含む）が失敗する。そこで既存ファイルを触らず、
# 回転後の points を新規ファイルとして作る（新規作成は書ける）。
# 使い方: rotatePointsTo.py <src_points> <dst_points> <angle_deg>
import sys, re, math

src, dst, ang = sys.argv[1], sys.argv[2], math.radians(float(sys.argv[3]))
c, s = math.cos(ang), math.sin(ang)

with open(src, encoding="latin-1") as f:
    text = f.read()

def rot(m):
    x, y, z = (float(v) for v in m.group(1).split())
    return "(%.10g %.10g %.10g)" % (c * x - s * y, s * x + c * y, z)

new = re.sub(r"\(\s*(-?[\d.][-\d.eE+ ]*?)\s*\)", rot, text)

with open(dst, "w", encoding="latin-1") as f:
    f.write(new)
