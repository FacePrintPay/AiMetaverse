#!/data/data/com.termux/files/usr/bin/bash
set -e
echo "🔥 CYGEL.WHITE — PACKAGING SOVEREIGN PORTFOLIO FOR \$1,000,000"
echo "⏳ Scanning for assets..."
# --- CONFIGURATION ---
PORTFOLIO="/sdcard/SOVEREIGN_PORTFOLIO_1M"
ARCHIVE="/sdcard/SOVEREIGN_PORTFOLIO_CYGEL_WHITE_1M.tar.gz"
rm -rf "$PORTFOLIO" "$ARCHIVE" 2>/dev/null || true
mkdir -p "$PORTFOLIO/repos" "$PORTFOLIO/forensics" "$PORTFOLIO/domains"
# --- SCAN AND COPY REPOS ---
echo ""
echo "📦 Scanning repositories..."
find_and_copy() {
    local name="$1"
    local search_paths=(
        "$HOME/$name"
        "$HOME/github/FacePrintPay/$name"
        "$HOME/sovereign-gtp/src/$name"
        "$HOME/agentik/$name"
    )
    for path in "${search_paths[@]}"; do
        if [ -d "$path" ]; then
            echo "  ✓ Found: $name → $path"
            cp -r "$path" "$PORTFOLIO/repos/$name" 2>/dev/null && return 0
        fi
    done
    echo "  ⚠️  Not found: $name"
    return 1
}
# Core repos to include
find_and_copy "Agentik"
find_and_copy "agentik"
find_and_copy "SovereignGTP"
find_and_copy "FacePrintPay"
find_and_copy "VideoCourts"
find_and_copy "AiKre8tive-Stargate"
find_and_copy "sovereign-parasol"
find_and_copy "TheKre8tive"
# --- FORENSIC EVIDENCE ---
echo ""
echo "🔐 Collecting forensic evidence..."
forensic_files=(
    "CYGEL_WHITE_FULL_COMMIT_HISTORY_20260124.txt"
    "TERMUX_ALL_FILES_20260120T122440.log"
    "sovereign-gtp/vault/manifests/*.txt"
)
for pattern in "${forensic_files[@]}"; do
    for file in $HOME/$pattern; do
        if [ -f "$file" ]; then
            basename_file=$(basename "$file")
            cp "$file" "$PORTFOLIO/forensics/$basename_file"
            echo "  ✓ Included: $basename_file"
        fi
    done
done
# --- CREATE OFFER PAGE ---
echo ""
echo "🎨 Creating offer page..."
cat > "$PORTFOLIO/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>SOVEREIGN PORTFOLIO — $1,000,000</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { 
      background: linear-gradient(135deg, #000 0%, #1a1a2e 50%, #000 100%);
      color: #0f0; 
      font-family: 'Courier New', monospace; 
      padding: 20px; 
      min-height: 100vh;
    }
    .container { 
      max-width: 900px; 
      margin: auto; 
      border: 2px solid #0f0; 
      padding: 40px; 
      background: rgba(0,0,0,0.8);
      box-shadow: 0 0 30px rgba(0,255,0,0.3);
    }
    h1 { 
      color: #ff0; 
      text-align: center; 
      font-size: 2.5em;
      margin-bottom: 10px;
      text-shadow: 0 0 10px #ff0;
    }
    .subtitle {
      text-align: center;
      color: #0f0;
      margin-bottom: 30px;
      font-size: 1.2em;
    }
    .price { 
      font-size: 3em; 
      text-align: center; 
      margin: 30px 0; 
      color: #0f0; 
      font-weight: bold;
      text-shadow: 0 0 20px #0f0;
      animation: pulse 2s infinite;
    }
    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.7; }
    }
    .section {
      margin: 30px 0;
      padding: 20px;
      border-left: 3px solid #0f0;
      background: rgba(0,255,0,0.05);
    }
    .section h2 {
      color: #0ff;
      margin-bottom: 15px;
    }
    ul { padding-left: 30px; line-height: 1.8; }
    li { margin: 10px 0; }
    .btn { 
      display: block; 
      width: fit-content; 
      margin: 40px auto; 
      padding: 20px 50px; 
      background: linear-gradient(135deg, #0f0, #0c0);
      color: #000; 
      text-decoration: none; 
      font-weight: bold; 
      border-radius: 8px;
      font-size: 1.3em;
      text-align: center;
      transition: all 0.3s ease;
      box-shadow: 0 5px 20px rgba(0,255,0,0.5);
    }
    .btn:hover {
      transform: translateY(-3px);
      box-shadow: 0 8px 30px rgba(0,255,0,0.8);
    }
    .contact-box {
      background: rgba(0,255,255,0.1);
      border: 2px solid #0ff;
      padding: 25px;
      margin: 30px 0;
      border-radius: 8px;
      text-align: center;
    }
    .contact-box h3 {
      color: #0ff;
      margin-bottom: 15px;
      font-size: 1.5em;
    }
    .contact-item {
      margin: 10px 0;
      font-size: 1.1em;
    }
    .contact-item a {
      color: #0f0;
      text-decoration: none;
      font-weight: bold;
    }
    .highlight { color: #ff0; font-weight: bold; }
    .stats {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
      gap: 20px;
      margin: 30px 0;
    }
    .stat {
      text-align: center;
      padding: 20px;
      background: rgba(0,255,0,0.1);
      border: 1px solid #0f0;
      border-radius: 8px;
    }
    .stat-value { font-size: 2em; color: #0ff; font-weight: bold; }
    .stat-label { color: #0f0; margin-top: 10px; }
    .footer { 
      font-size: 0.9em; 
      color: #666; 
      margin-top: 50px; 
      text-align: center; 
      padding-top: 20px;
      border-top: 1px solid #333;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>🚨 FULL SOVEREIGN AI PORTFOLIO</h1>
    <div class="subtitle">Built by Cygel Sampson White</div>
    <div class="price">$1,000,000 USD</div>
    <div class="stats">
      <div class="stat">
        <div class="stat-value">7+</div>
        <div class="stat-label">Core Repositories</div>
      </div>
      <div class="stat">
        <div class="stat-value">3</div>
        <div class="stat-label">Premium Domains</div>
      </div>
      <div class="stat">
        <div class="stat-value">41.8GB</div>
        <div class="stat-label">Forensic Vault</div>
      </div>
      <div class="stat">
        <div class="stat-value">287</div>
        <div class="stat-label">Hashed Artifacts</div>
      </div>
    </div>
    <div class="section">
      <h2>🤖 Core AI Systems</h2>
      <ul>
        <li><span class="highlight">Agentik</span> — Autonomous agent framework</li>
        <li><span class="highlight">SovereignGTP</span> — On-device LLM stack</li>
        <li><span class="highlight">FacePrintPay</span> — Biometric payment gateway</li>
        <li><span class="highlight">AiKre8tive-Stargate</span> — Multi-repo orchestration</li>
      </ul>
    </div>
    <div class="section">
      <h2>🌐 Premium Domains</h2>
      <ul>
        <li><span class="highlight">videocourts.com</span> — Legal platform</li>
        <li><span class="highlight">kre8tive.space</span> — Portfolio site</li>
        <li><span class="highlight">mybuyo.com</span> — E-commerce</li>
      </ul>
    </div>
    <a href="https://cash.app/$thacyg?amount=1000000&note=Sovereign+Portfolio" class="btn">
      💸 PAY $1,000,000 VIA CASH APP
    </a>
    <div class="contact-box">
      <h3>📞 Contact</h3>
      <div class="contact-item">💰 Cash App: <a href="https://cash.app/$thacyg">$thacyg</a></div>
      <div class="contact-item">📧 Email: <a href="mailto:kre8tivekonceptz@gmail.com">kre8tivekonceptz@gmail.com</a></div>
    </div>
    <div class="footer">
      <p><strong>Built on Termux • No Cloud • Pure Sovereignty</strong></p>
      <p>© 2026 Cygel.Co — Greensboro, NC</p>
      <p style="margin-top: 15px; color: #0f0;">#SovereignAI #LiquidityEvent</p>
    </div>
  </div>
</body>
</html>
HTMLEOF
# --- COMPRESS ---
echo ""
echo "📦 Compressing..."
cd /sdcard
tar -czf "$ARCHIVE" -C "$PORTFOLIO" . 2>/dev/null || echo "⚠️ Compression skipped"
# --- OUTPUT ---
echo ""
echo "✅ DONE!"
echo "📁 $PORTFOLIO/index.html"
echo "💸 https://cash.app/\$thacyg?amount=1000000"
echo "📧 kre8tivekonceptz@gmail.com"
echo ""
# Open in browser
command -v termux-open-url &> /dev/null && termux-open-url "file://$PORTFOLIO/index.html"
