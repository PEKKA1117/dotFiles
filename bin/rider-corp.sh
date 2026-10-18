#!/bin/bash
# Rider with corporate VPN proxy (SOCKS5 -> HTTP conversion)

SOCKS_PROXY="127.0.0.1:1080"
HTTP_PORT="8118"

# Start gost in background (SOCKS5 to HTTP proxy)
gost -L "http://:${HTTP_PORT}" -F "socks5://${SOCKS_PROXY}" &
GOST_PID=$!

# Wait for gost to be ready
sleep 0.5

# Launch Rider
"/home/df/.local/share/JetBrains/Toolbox/apps/rider/bin/rider" "$@"

# Cleanup: kill gost when Rider exits
kill $GOST_PID 2>/dev/null
