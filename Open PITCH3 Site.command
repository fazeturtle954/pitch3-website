#!/bin/bash
# Double-click this file to open the PITCH3 website in your browser.
# It starts a local web server if one isn't already running.

SITE_DIR="/Users/michaelkass/pitch3-redesign"
PORT=8000

cd "$SITE_DIR" || { echo "PITCH3 folder not found at $SITE_DIR"; exit 1; }

# Start server only if nothing is already listening on $PORT
if ! lsof -iTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Starting local web server on port $PORT..."
  nohup python3 -m http.server $PORT >/tmp/pitch3-server.log 2>&1 &
  disown
  sleep 1
else
  echo "Server already running on port $PORT."
fi

# Open default browser
open "http://localhost:$PORT/"

# Auto-close this Terminal window after a moment
(sleep 1 && osascript -e 'tell application "Terminal" to close (every window whose name contains "Open PITCH3")' >/dev/null 2>&1) &
exit 0
