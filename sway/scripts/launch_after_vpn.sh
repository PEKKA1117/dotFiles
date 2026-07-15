#!/usr/bin/env bash
# Wait until ProtonVPN is connected, then launch the given command.
# The official ProtonVPN app brings up a WireGuard device named proton0;
# also accept any active NetworkManager connection matching "proton".

vpn_connected() {
    ip link show up proton0 >/dev/null 2>&1 && return 0
    nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null | grep -qi proton
}

while ! vpn_connected; do
    sleep 3
done

exec "$@"
