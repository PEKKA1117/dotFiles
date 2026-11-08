#!/usr/bin/env bash
# 等 VPN 隧道起來再啟動指定的程式。
# vpn-switch 管的兩條 NM WireGuard 連線,介面名固定是 proton(Proton)或 warp(wgcf)。
# 注意:vpn-switch off 的狀態下開機,這裡會一直等,程式不會啟動。

vpn_connected() {
    ip link show up proton >/dev/null 2>&1 || ip link show up warp >/dev/null 2>&1
}

while ! vpn_connected; do
    sleep 3
done

exec "$@"
