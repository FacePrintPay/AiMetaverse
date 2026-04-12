#!/data/data/com.termux/files/usr/bin/bash
# C25 AGENTS — Full phone clone
# Internal storage, downloads, documents, hidden files, everything

DEST="$HOME/phone_clone"
LOGDIR="$HOME/agent_logs"
mkdir -p "$DEST" "$LOGDIR"

echo "╔══════════════════════════════════════╗"
echo "║  C25 — FULL PHONE CLONE             ║"
echo "╚══════════════════════════════════════╝"

# All source paths on Android
SOURCES=(
  "/sdcard"
  "/sdcard/Download"
  "/sdcard/Documents"
  "/sdcard/Android"
  "/sdcard/DCIM"
  "/sdcard/Pictures"
  "/sdcard/Movies"
  "/sdcard/Music"
  "/sdcard/Obsidian"
  "/sdcard/obsidian"
  "/sdcard/Backups"
  "/sdcard/backup"
  "/sdcard/.termux"
  "/storage/emulated/0"
  "/storage/emulated/0/Download"
  "/storage/emulated/0/Documents"
  "/data/data/com.termux/files/home"
  "/data/data/com.termux/files/home/.termux"
  "/data/data/com.termux/files/usr/etc"
)

for SRC in "${SOURCES[@]}"; do
  [ ! -d "$SRC" ] && continue
  NAME=$(echo "$SRC" | tr '/' '_' | sed 's/^_//')
  DEST_DIR="$DEST/$NAME"
  mkdir -p "$DEST_DIR"
  echo "[Earth] Cloning: $SRC"
  
  # Copy everything including hidden files
  cp -r "$SRC/." "$DEST_DIR/" 2>/dev/null
  COUNT=$(find "$DEST_DIR" -type f 2>/dev/null | wc -l)
  echo "  ✓ $COUNT files cloned from $SRC"
done

# Hidden files specifically
echo ""
echo "[Moon] Cloning hidden files..."
find /sdcard /storage/emulated/0 \
  -name ".*" \
  -not -path "*/node_modules/*" \
  2>/dev/null | while read f; do
  mkdir -p "$DEST/hidden/$(dirname ${f#/})"
  cp -r "$f" "$DEST/hidden/$(dirname ${f#/})/" 2>/dev/null && \
    echo "  ✓ $f"
done

# Termux backup files
echo ""
echo "[Saturn] Cloning Termux backups..."
find /sdcard /storage/emulated/0 \
  -name "*.tar.gz" -o \
  -name "*.backup" -o \
  -name "*.bak" -o \
  -name "*termux*backup*" -o \
  -name "*backup*termux*" \
  2>/dev/null | while read f; do
  cp "$f" "$DEST/termux_backups/" 2>/dev/null && \
    echo "  ✓ $(basename $f)"
done

# Integrity files
echo ""
echo "[Mercury] Cloning integrity files..."
find /sdcard /storage/emulated/0 \
  -name "*.sha256" -o \
  -name "*.md5" -o \
  -name "*.integrity" -o \
  -name "*.checksum" \
  2>/dev/null | while read f; do
  cp "$f" "$DEST/integrity/" 2>/dev/null && \
    echo "  ✓ $(basename $f)"
done

# Xplorer app files specifically
echo ""
echo "[Venus] Finding Xplorer app files..."
find /sdcard /storage/emulated/0 \
  /data/data/com.termux/files/home \
  -iname "*xplorer*" \
  -o -iname "*explorer*" \
  2>/dev/null | while read f; do
  mkdir -p "$DEST/xplorer"
  cp -r "$f" "$DEST/xplorer/" 2>/dev/null && \
    echo "  ✓ $f"
done

# APK files
echo ""
echo "[Jupiter] Finding APK files..."
find /sdcard /storage/emulated/0 \
  -name "*.apk" \
  2>/dev/null | while read f; do
  cp "$f" "$DEST/apks/" 2>/dev/null && \
    echo "  ✓ $(basename $f)"
done

# Build manifest of everything cloned
echo ""
echo "[Saturn] Building clone manifest..."
find "$DEST" -type f 2>/dev/null | sort > "$LOGDIR/phone_clone_manifest.txt"
TOTAL=$(wc -l < "$LOGDIR/phone_clone_manifest.txt")

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  PHONE CLONE COMPLETE               ║"
echo "╚══════════════════════════════════════╝"
echo "  Total files cloned: $TOTAL"
echo "  Location: $DEST"
echo "  Manifest: $LOGDIR/phone_clone_manifest.txt"
echo ""
echo "  Check space:"
du -sh "$DEST"
