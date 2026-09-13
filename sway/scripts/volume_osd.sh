#!/bin/bash

# 音量 OSD —— 利用 mako 的 value hint 畫出進度條
# 用法: volume_osd.sh up | down | mute | show

case "$1" in
    up)   pamixer -ui 2 >/dev/null ;;
    down) pamixer -ud 2 >/dev/null ;;
    mute) pamixer --toggle-mute >/dev/null ;;
esac

vol=$(pamixer --get-volume)

# mako 的 value hint 只接受 0-100,將來若加了 --allow-boost 會超出範圍
(( vol > 100 )) && vol=100

if [[ "$(pamixer --get-mute)" == "true" ]]; then
    icon="audio-volume-muted"
    text="靜音"
    bar=0
else
    # 依音量高低換圖示,AdwaitaLegacy 提供 high/medium/low 三階
    if   (( vol >= 66 )); then icon="audio-volume-high"
    elif (( vol >= 33 )); then icon="audio-volume-medium"
    else                       icon="audio-volume-low"
    fi
    text="音量  ${vol}%"
    bar=$vol
fi

# 判斷是否有 Steam 遊戲在跑。reaper 是 Steam 的啟動包裝器,涵蓋整個遊戲場次。
# 必須用 -x 精確比對:核心執行緒 oom_reaper 會讓不加 -x 的 pgrep 永遠命中。
if pgrep -x reaper >/dev/null 2>&1; then
    category="game"      # 對應 mako 的 [app-name=volume-osd category=game],改送副螢幕
else
    category="desktop"
fi

# x-canonical-private-synchronous 讓連按音量鍵時原地取代,不會疊成一排通知
notify-send -a volume-osd "$text" \
    -i "$icon" \
    -c "$category" \
    -h string:x-canonical-private-synchronous:volume \
    -h int:value:"$bar" \
    -t 1200
