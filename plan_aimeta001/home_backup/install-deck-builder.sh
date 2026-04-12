#!/data/data/com.termux/files/usr/bin/bash

echo "Installing deck builder..."

# Install Node.js if not present
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    pkg install nodejs -y
fi

# Create directory
mkdir -p ~/deck-builder
cd ~/deck-builder

# Create package.json
echo '{
  "name": "deck-builder",
  "version": "1.0.0",
  "type": "module",
  "dependencies": {
    "express": "^4.18.2"
  }
}' > package.json

# Install dependencies
npm install

# Create server.js
cat > server.js << 'SERVEREOF'
import express from "express";
import fs from "fs";
import path from "path";

const app = express();
app.use(express.json());

app.post("/build-deck", async (req, res) => {
  const brand = req.body.brand || "VideoCourts";
  const preparedFor = req.body.preparedFor || "Tyler Technologies";
  const title = req.body.title || "Strategic Acquisition";
  const sections = req.body.sections || [];
  
  const deckId = "deck_" + Date.now();
  const outDir = path.join(process.cwd(), "out");
  const outFile = path.join(outDir, deckId + ".html");

  if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
  }

  let htmlSections = "";
  for (const sec of sections) {
    const h = String(sec.heading || "").replace(/[<>]/g, "");
    const b = String(sec.body || "").replace(/[<>]/g, "");
    htmlSections += "<section class='card'><h2>" + h + "</h2><p>" + b + "</p></section>";
  }

  const html = "<!doctype html><html><head><meta charset='utf-8'/><title>" + brand + "</title><style>body{margin:0;font-family:system-ui;background:#0b0f17;color:#e9eef7}.wrap{max-width:1100px;margin:auto;padding:28px}.hero{border:1px solid #22304a;padding:22px;border-radius:18px}h1{font-size:34px}.card{border:1px solid #22304a;background:#111827;padding:18px;margin:14px 0;border-radius:16px}</style></head><body><div class='wrap'><div class='hero'><h1>" + brand + " - " + title + "</h1><p>Prepared for: " + preparedFor + "</p></div>" + htmlSections + "</div></body></html>";

  fs.writeFileSync(outFile, html, "utf8");
  res.json({ ok: true, deckId: deckId, file: outFile });
});

app.listen(3000, () => console.log("Deck builder on http://localhost:3000"));
SERVEREOF

echo ""
echo "✅ Installation complete!"
echo ""
echo "To start the server:"
echo "  cd ~/deck-builder"
echo "  node server.js"
echo ""
