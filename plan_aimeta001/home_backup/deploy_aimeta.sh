#!/data/data/com.termux/files/usr/bin/bash
curl -X POST "https://api.vercel.com/v1/integrations/deploy/abc123xyz456" \
-H "Content-Type: application/json" \
-d "{\"project\":\"plan_aimeta001\"}"
