#!/bin/bash
# ~/.config/sway/scripts/switch-monitor-mode.sh
# DP-3 顯示模式切換（綁在 $mod+F1 / $mod+F2）
case "$1" in
  "4k")
    swaymsg output DP-3 mode 3840x2160@160Hz
    ;;
  "highrefresh")
    swaymsg output DP-3 mode 1920x1080@320Hz
    ;;
  *)
    echo "用法: $(basename "$0") {4k|highrefresh}" >&2
    exit 1
    ;;
esac
