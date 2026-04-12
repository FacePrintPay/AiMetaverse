#!/data/data/com.termux/files/usr/bin/bash

# === PATHS ===
APP_DIR="$HOME/AiKre8tiveGenesis/platform/logs"
FILE="$APP_DIR/aikre8tive_log_dialog.html"

# === CREATE DIR IF NOT EXIST ===
mkdir -p "$APP_DIR"

# === WRITE HTML INTERFACE ===
cat > "$FILE" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>AiKre8tive Log Dialog Viewer</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
  <style>
    body { font-family: monospace; }
    .matrix-glow { animation: flicker 1.5s infinite alternate; }
    @keyframes flicker {
      0% { text-shadow: 0 0 5px #00ff00; }
      100% { text-shadow: 0 0 20px #00ff00; }
    }
  </style>
</head>
<body class="bg-black text-green-400 p-8">
  <div class="max-w-5xl mx-auto text-center">
    <h1 class="text-3xl font-bold text-green-300 mb-6 matrix-glow">🧠 AiKre8tive Log Dialog Viewer</h1>
    <div class="bg-gray-900 border border-green-600 rounded-xl p-6 shadow-xl mb-10 max-h-[60vh] overflow-y-auto whitespace-pre-wrap text-left">
      <p class="text-blue-400 mb-3">🧠 Welcome to the AiKre8tive Build Interface.</p>
      <p class="text-yellow-400 mb-3">⚙️ Click the terminal or deployment agent to initiate your build.</p>
      <p class="text-green-400 mb-3">🚀 This terminal log will auto-populate with WhisperSync and Planetary Agent output.</p>
      <p class="text-pink-400">🔁 Run <code class="bg-gray-800 text-white px-2 py-1 rounded">bash rebuild_percellify.sh</code> to refresh logs.</p>
    </div>
    <div class="flex flex-col items-center space-y-4">
      <select id="platform" class="bg-gray-800 text-green-300 border border-green-500 rounded px-4 py-2">
        <option value="https://www.blackbox.ai?via=MrGGTP">Blackbox AI</option>
        <option value="https://replit.com">Replit</option>
        <option value="https://codeium.com">Codeium</option>
        <option value="https://huggingface.co">Hugging Face</option>
      </select>
      <button onclick="logAndRedirect(document.getElementById('platform').value)"
        class="animate-pulse bg-green-600 hover:bg-green-400 text-black font-bold py-3 px-6 rounded-xl shadow-lg border border-lime-400 transition duration-300 ease-in-out">
        🚀 Launch Selected IDE
      </button>
    </div>
    <div class="mt-10">
      <img src="https://api.qrserver.com/v1/create-qr-code/?data=https://www.blackbox.ai?via=MrGGTP&size=180x180&logo=https://avatars.githubusercontent.com/u/1398147" alt="Affiliate QR" class="mx-auto rounded-lg border-2 border-green-500" />
      <p class="text-sm text-gray-500 mt-2">📲 Scan to launch Blackbox with affiliate tracking</p>
    </div>
    <img src="https://www.blackbox.ai/track/pixel?ref=MrGGTP" alt="tracking" width="1" height="1" />
    <div class="mt-8 text-center text-gray-400 text-xs">Generated: <span id="timestamp"></span></div>
  </div>
  <script>
    document.getElementById('timestamp').textContent = new Date().toLocaleString();
    function logAndRedirect(url) {
      fetch('/log_click.php?url=' + encodeURIComponent(url))
        .then(() => window.open(url, '_blank'));
    }
  </script>
</body>
</html>
EOF

echo "✅ HTML file created: $FILE"

# === GIT + DEPLOY SETUP ===
cd "$APP_DIR"
if [ ! -d ".git" ]; then
  git init
  git remote add origin https://github.com/TheKre8tive/AiKre8tive-Logs.git 2>/dev/null || true
fi

echo '{ "rewrites": [{ "source": "/(.*)", "destination": "/aikre8tive_log_dialog.html" }] }' > vercel.json
echo -e "# AiKre8tive Logs\nAuto-generated log interface. Built by #MrGGTP" > README.md

git add .
git commit -m "🧠 Initial AiKre8tive Log Dialog push"
vercel deploy --prod --confirm --token=$VERCEL_TOKEN
