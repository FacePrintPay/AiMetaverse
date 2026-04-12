import math

def rotate(poly, angle):
    cx = sum(p[0] for p in poly) / len(poly)
    cy = sum(p[1] for p in poly) / len(poly)

    a = math.radians(angle)
    ca, sa = math.cos(a), math.sin(a)

    out = []
    for x, y in poly:
        x -= cx
        y -= cy
        out.append((
            x * ca - y * sa + cx,
            x * sa + y * ca + cy
        ))
    return out

def translate(poly, dx, dy):
    return [(x + dx, y + dy) for x, y in poly]

def bbox(poly):
    xs = [p[0] for p in poly]
    ys = [p[1] for p in poly]
    return min(xs), min(ys), max(xs), max(ys)

def overlap(a, b):
    ax1, ay1, ax2, ay2 = bbox(a)
    bx1, by1, bx2, by2 = bbox(b)
    return not (
        ax2 < bx1 or ax1 > bx2 or
        ay2 < by1 or ay1 > by2
    )
