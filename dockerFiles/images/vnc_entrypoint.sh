#!/bin/bash

set -e

# --- 1. Set Standard Display (Port 5900) ---
export DISPLAY=:0
export XAUTHORITY=/root/.Xauthority

# --- 2. Start Screen (Silent) ---
# Redirecting > /dev/null 2>&1 hides the logs
echo "Starting Xvfb (Display :0)..."
Xvfb :0 -screen 0 1280x1024x24 > /dev/null 2>&1 &
sleep 2  # Give it a moment to initialize

# --- 3. Start Window Manager (Silent) ---
echo "Starting Fluxbox..."
fluxbox > /dev/null 2>&1 &
sleep 1

# --- 4. Start VNC Server (Silent & Background) ---
# -bg: Runs in background automatically
# -q: Quiet mode
# -rfbport 5900: Explicitly force port 5900
echo "Starting VNC Server on port 5900..."
x11vnc -display :0 -forever -passwd odoo -bg -q -rfbport 5900 > /dev/null 2>&1

# --- 5. Debug info (Optional, helps confirm it's ready) ---
echo "---------------------------------------------------"
echo "✅ VNC Ready: connect to localhost:5900 (pass: odoo)"
echo "🚀 Starting Odoo..."
echo "---------------------------------------------------"

# --- 6. Hand over control to Odoo ---
exec "$@"
