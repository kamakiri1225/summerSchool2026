#!/usr/bin/env python3
import sys, re, math
src, dst, ang = sys.argv[1], sys.argv[2], math.radians(float(sys.argv[3]))
c, s = math.cos(ang), math.sin(ang)
text = open(src, encoding="latin-1").read()
def rot(m):
    x, y, z = (float(v) for v in m.group(1).split())
    return "(%.17g %.17g %.17g)" % (c * x - s * y, s * x + c * y, z)
new = re.sub(r"\(\s*(-?[\d.][-\d.eE+ ]*?)\s*\)", rot, text)
open(dst, "w", encoding="latin-1").write(new)
