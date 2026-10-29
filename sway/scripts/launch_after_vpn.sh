#!/usr/bin/env bash
# Wait until Cloudflare WARP is connected, then launch the given command.
# The wgcf profile imported into NetworkManager brings up a WireGuard
# device named warp.

vpn_connected() {
    ip link show up warp >/dev/null 2>&1
}

while ! vpn_connected; do
    sleep 3
done

exec "$@"
