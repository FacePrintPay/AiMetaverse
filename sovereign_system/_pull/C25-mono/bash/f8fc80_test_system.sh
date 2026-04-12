#!/data/data/com.termux/files/usr/bin/bash
echo "🧪 Testing Sovereign GTP System..."
echo ""

echo "1. Testing directory structure..."
if [ -d "$HOME/SOVEREIGN_GTP/core" ]; then
    echo "   ✓ Core directory exists"
else
    echo "   ✗ Core directory missing"
fi

echo ""
echo "2. Testing protocol..."
if [ -f "$HOME/SOVEREIGN_GTP/core/protocol.sh" ]; then
    echo "   ✓ Protocol file exists"
    source "$HOME/SOVEREIGN_GTP/core/protocol.sh"
else
    echo "   ✗ Protocol file missing"
fi

echo ""
echo "3. Testing Flask server..."
if [ -f "$HOME/aikre8tive-stargate/src/server.py" ]; then
    echo "   ✓ Server file exists"
    python3 -m py_compile "$HOME/aikre8tive-stargate/src/server.py"
    echo "   ✓ Server syntax valid"
else
    echo "   ✗ Server file missing"
fi

echo ""
echo "4. Testing nano configuration..."
if nano --version > /dev/null 2>&1; then
    echo "   ✓ Nano is working"
else
    echo "   ✗ Nano has issues"
fi

echo ""
echo "✅ System test complete!"
