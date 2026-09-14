#!/bin/bash
# ~/.config/sway/scripts/switch-audio-sink.sh
# 音效輸出切換（綁在 $mod+F3 / $mod+F4 / $mod+F10）
# 用法: switch-audio-sink.sh {c20|arctis|moonriver}

# ── 裝置對應表：要改就改這裡 ──────────────────────────────
# C20 走主機板光纖輸出,PCI 路徑固定不會變,直接寫死。
# USB 裝置會熱插拔,節點名可能隨韌體或插的埠改變,所以用關鍵字比對
# 當下的 sink 清單,而不是寫死全名。找不到時通知會列出現有 sink,
# 方便對照後回來改這兩個 pattern。
C20_SINK="alsa_output.pci-0000_00_1f.3.iec958-stereo"
ARCTIS_PATTERN="arctis"
MOONRIVER_PATTERN="moonriver"

# sway 的 exec 不會 source .zshrc,拿不到 ~/.cargo/bin,必須用絕對路徑
AUDIOPRO="$HOME/.cargo/bin/audiopro"

# ── OSD：沿用 volume_osd.sh 的慣例 ────────────────────────
# x-canonical-private-synchronous 讓連按時原地取代,不會疊成一排通知。
# reaper 是 Steam 的啟動包裝器,遊戲中改送 game category(mako 會轉到副螢幕)。
# 必須用 -x 精確比對:核心執行緒 oom_reaper 會讓不加 -x 的 pgrep 永遠命中。
# 用法: osd <標題> [圖示] [內文]
# 內文可以是多行,mako 會照實呈現;標題保持單行短句。
osd() {
    local text="$1" icon="${2:-audio-card}" body="$3" category="desktop"
    pgrep -x reaper >/dev/null 2>&1 && category="game"
    local args=(-a audio-sink "$text")
    [[ -n "$body" ]] && args+=("$body")
    notify-send "${args[@]}" \
        -i "$icon" \
        -c "$category" \
        -h string:x-canonical-private-synchronous:audio-sink \
        -t 1500
}

# 依關鍵字找出當下在線的 sink,找不到回傳空字串
find_sink() {
    pactl list short sinks 2>/dev/null \
        | awk -v pat="$1" 'tolower($2) ~ tolower(pat) { print $2; exit }'
}

# 裝置不在線時,把現有 sink 列進通知,當作 pattern 對不上的除錯線索
report_missing() {
    local label="$1" available
    # awk 本來就一行一個,直接當多行內文用。
    # (別用 paste -sd', ':-d 吃的是字元列表,會拿 "," 和 " " 交替當分隔符)
    available=$(pactl list short sinks 2>/dev/null | awk '{print "  • "$2}')
    osd "${label}未連線" audio-volume-muted "目前可用:
${available:-  (無)}"
}

# 切換預設 sink,並把既有串流一起搬過去
switch_to() {
    local sink="$1" label="$2" prev
    prev=$(pactl get-default-sink 2>/dev/null)

    if ! pactl set-default-sink "$sink" 2>/dev/null; then
        osd "切換失敗: $label" audio-volume-muted
        return 1
    fi

    # set-default-sink 只影響之後新開的串流,正在播的要逐一搬,
    # 否則按下熱鍵後聲音還是留在舊裝置上。
    local id
    while read -r id _; do
        [[ -n "$id" ]] && pactl move-sink-input "$id" "$sink" 2>/dev/null
    done < <(pactl list short sink-inputs 2>/dev/null)

    # 從光纖切走時讓 C20 停下來。audiopro 走網路(172.16.0.103:443),
    # 喇叭離線時會卡住,一律包 timeout 免得腳本吊死。
    if [[ "$prev" == "$C20_SINK" && "$sink" != "$C20_SINK" ]]; then
        timeout 3 "$AUDIOPRO" stop >/dev/null 2>&1
    fi
    return 0
}

# 切到 USB 裝置的共同流程
switch_usb() {
    local pattern="$1" label="$2" sink
    sink=$(find_sink "$pattern")
    if [[ -z "$sink" ]]; then
        report_missing "$label"
        exit 1
    fi
    switch_to "$sink" "$label" && osd "$label"
}

case "$1" in
    c20)
        # C20 要先把喇叭本身切到光纖輸入,這步會有網路延遲,先發通知讓人知道在等
        osd "切換到 C20…(喇叭換源中)"
        if ! timeout 5 "$AUDIOPRO" source optical >/dev/null 2>&1; then
            osd "C20 無回應(喇叭離線?)" audio-volume-muted
            exit 1
        fi
        switch_to "$C20_SINK" "C20 光纖" || exit 1
        # 韌體已修掉換源延遲,不必再等就能直接 play
        timeout 3 "$AUDIOPRO" play >/dev/null 2>&1
        osd "C20 光纖"
        ;;
    arctis)
        switch_usb "$ARCTIS_PATTERN" "Arctis Nova 7"
        ;;
    moonriver)
        switch_usb "$MOONRIVER_PATTERN" "Moonriver 3"
        ;;
    *)
        # 從熱鍵觸發時 stderr 沒人看得到,所以也發 OSD。
        # 最可能的成因是 sway 的 $audioDevice_n 沒展開(variables 沒載入
        # 或拼錯),那樣這裡收到的會是字面上的 "$audioDevice_1"。
        echo "用法: $(basename "$0") {c20|arctis|moonriver}" >&2
        osd "未知的音效裝置: ${1:-（沒帶參數）}" audio-volume-muted
        exit 1
        ;;
esac
