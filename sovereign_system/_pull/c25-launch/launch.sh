#!/bin/bash
echo "--- System Security Check ---"
echo "Please scan your fingerprint to launch..."
# Trigger biometric auth
AUTH=$(termux-fingerprint | jq -r '.auth_result')
if [ "$AUTH" == "AUTH_RESULT_SUCCESS" ]; then
    echo "✅ Identity Verified."
    echo "Launching your system..."
    sleep 1
    # REPLACE THE LINE BELOW with the command you use to start your system
    # e.g., ./start-ubuntu.sh or python main.py
    bash ./your_actual_launch_command.sh
else
    echo "❌ Authentication Failed. Access Denied."
    exit 1
fi
