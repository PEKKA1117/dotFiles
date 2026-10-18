#!/bin/bash
# 爐石戰記卡牌揭露直播：自動開啟 Twitch 並於30分鐘後關機

export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# 若 systemd 未傳入 WAYLAND_DISPLAY，嘗試 wayland-1
if [ -z "$WAYLAND_DISPLAY" ]; then
    export WAYLAND_DISPLAY=wayland-1
fi

# 在背景開啟 Vivaldi 直播頁面
vivaldi-snapshot "https://www.twitch.tv/playhearthstone" &


# 等待30分鐘後關機
sleep 1800
systemctl poweroff
