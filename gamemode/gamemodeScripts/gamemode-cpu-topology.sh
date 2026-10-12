#!/usr/bin/env bash
# CPU 拓撲偵測 — 供 gamemode start/end 與監控腳本共用
# 依 cpufreq 最高頻率區分 P-core(高頻)與 E-core(低頻),不寫死核心編號

detect_topology() {
    local cpu freq maxfreq=0
    declare -gA CPU_FREQ

    for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
        [[ -r "$cpu/cpufreq/cpuinfo_max_freq" ]] || continue
        freq=$(<"$cpu/cpufreq/cpuinfo_max_freq")
        CPU_FREQ[${cpu##*/cpu}]=$freq
        (( freq > maxfreq )) && maxfreq=$freq
    done

    # 一律用 nproc --all:nproc 回傳的是「當前行程可用核心數」,會被自身
    # 的 CPU 親和性限制,在被 taskset 過的環境下會嚴重低估
    ALL_CORES="0-$(( $(nproc --all) - 1 ))"

    # 沒有 cpufreq(如虛擬機)則視為同質,全部當 P-core
    if (( maxfreq == 0 )); then
        P_CORES="$ALL_CORES"
        E_CORES=""
        return
    fi

    # 低於最高頻 90% 者判定為 E-core
    local threshold=$(( maxfreq * 9 / 10 ))
    local -a p=() e=()
    for id in "${!CPU_FREQ[@]}"; do
        if (( CPU_FREQ[$id] >= threshold )); then p+=("$id"); else e+=("$id"); fi
    done

    P_CORES=$(printf '%s\n' "${p[@]}" | sort -n | paste -sd,)
    E_CORES=$(printf '%s\n' "${e[@]}" | sort -n | paste -sd,)
}

# 要趕出 P-core 的背景程式。刻意不含 sway(合成器需低延遲)
# 與 gamescope/wine/Overwatch(遊戲本身,由 gamemode pin_cores 管理)
BG_PROCS=(vesktop discord vivaldi-bin chromium spotify claude obs steamwebhelper code Discord)

# ── ecore 行程樹追蹤 ────────────────────────────────────────────────
# ~/.local/bin/ecore 啟動編譯時會在此目錄登記自己的 pid,好讓遊戲開始/結束時
# 能把「已經在跑」的編譯整棵樹重新調整親和性。用 pgrep -x 的名字清單抓不到
# 編譯器(gcc/cc1plus/rustc 是上百個短命行程),所以改用行程樹遍歷。
ECORE_STATE_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ecore"

# gamemode 是否有客戶端註冊中。注意不能用 *active* 比對 —— "inactive" 也會中
gamemode_active() {
    command -v gamemoded &>/dev/null || return 1
    [[ "$(gamemoded -s 2>/dev/null)" == "gamemode is active" ]]
}

# 列出一棵行程樹的所有 pid(含根),遞迴向下
proc_tree() {
    local pid=$1 child
    [[ -d /proc/$pid ]] || return 0
    echo "$pid"
    for child in $(pgrep -P "$pid" 2>/dev/null); do
        proc_tree "$child"
    done
}

# 對所有登記中的 ecore 行程樹套用親和性,順手清掉已結束的登記檔。
# ecore 用 exec 取代自身以保留互動性(sudo 密碼、PKGBUILD 編輯),
# 代價是 trap 不會執行、登記檔得由這裡回收。
# 回傳:實際調整的行程數(印到 stdout)
retask_ecore_trees() {
    local cores=$1 f pid p n=0
    [[ -d "$ECORE_STATE_DIR" ]] || { echo 0; return 0; }
    for f in "$ECORE_STATE_DIR"/*; do
        [[ -e "$f" ]] || continue
        pid=${f##*/}
        if [[ ! -d /proc/$pid ]]; then rm -f "$f"; continue; fi
        while read -r p; do
            [[ -n "$p" ]] || continue
            # -a 套用到所有執行緒,少了它只會改主執行緒
            taskset -acp "$cores" "$p" &>/dev/null && (( n++ ))
        done < <(proc_tree "$pid")
    done
    echo "$n"
}
