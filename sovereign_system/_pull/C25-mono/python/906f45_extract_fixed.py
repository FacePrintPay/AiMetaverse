import sys, re, html
from html.parser import HTMLParser

class Stripper(HTMLParser):
    def __init__(self):
        super().__init__()
        self.buf = []
    
    def handle_data(self, d):
        self.buf.append(d)
    
    def handle_entityref(self, name):
        self.buf.append(html.unescape('&%s;' % name))
    
    def handle_charref(self, name):
        self.buf.append(html.unescape('&#%s;' % name))
    
    def text(self):
        return re.sub(r'\s+', ' ', ''.join(self.buf)).strip()

for fn in sys.argv[1:]:
    try:
        with open(fn, errors="ignore") as f:
            s = Stripper()
            s.feed(f.read())
            txt = s.text()
        outfn = fn.replace("/", "_") + ".txt"
        with open(outfn, "w", errors="ignore") as out:
            out.write(txt)
        print(f"[OK] {fn} → {outfn}")
    except Exception as e:
        print(f"[FAIL] {fn} ({e})", file=sys.stderr)
