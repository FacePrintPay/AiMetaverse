#!/data/data/com.termux/files/usr/bin/bash

echo "Testing PaTHos API..."
echo ""

# Wait a moment for server to be ready
sleep 3

# Test basic connectivity
echo "1. Testing server connectivity..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:5000/)
if [ "$RESPONSE" = "404" ] || [ "$RESPONSE" = "200" ]; then
    echo "   ✓ Server is responding (HTTP $RESPONSE)"
else
    echo "   ✗ Server is not responding"
    echo "   Run './start_api.sh' first"
    exit 1
fi

# Test API endpoint
echo ""
echo "2. Testing /api/run endpoint..."
RESULT=$(curl -s -X POST http://127.0.0.1:5000/api/run \
  -H "Content-Type: application/json" \
  -d '{"function":"mercury_nlp_analysis","args":["Hello from PaTHos"]}')

if [ -n "$RESULT" ]; then
    echo "$RESULT" | python3 -m json.tool 2>/dev/null || echo "$RESULT"
else
    echo "   ✗ No response from API"
fi

echo ""
echo "Done!"
