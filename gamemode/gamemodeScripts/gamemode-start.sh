#!/usr/bin/env bash
# gamemode 進入時執行:把背景程式趕到 E-core,把 P-core 完整讓給遊戲
#
# 背景:gamemode 的 pin_cores 已經把遊戲釘在 P-core,但不會限制其他程式。
# Linux 排程器偏好把忙碌任務放 P-core,於是背景程式擠進遊戲唯一能用的核心
# 搶佔渲染主執行緒 → GPU 使用率忽高忽低、1% low 崩壞。此腳本補上這一半。

set -uo pipefail
source "$(dirname "$0")/gamemode-cpu-topology.sh"

LOG=/home/df/.local/share/gamemode-cpu.log
detect_topology

# 沒有 E-core(同質 CPU)就沒必要做核心隔離
if [[ -z "${E_CORES:-}" ]]; then
    echo "$(date '+%F %T') [start] 未偵測到 E-core,跳過" >> "$LOG"
    exit 0
fi

moved=0
for name in "${BG_PROCS[@]}"; do
    while read -r pid; do
        [[ -n "$pid" ]] || continue
        # -a 套用到該行程的所有執行緒,少了它只會改主執行緒
        taskset -acp "$E_CORES" "$pid" &>/dev/null && (( moved++ ))
    done < <(pgrep -x "$name" 2>/dev/null)
done

# 編譯中的 ecore 行程樹:pgrep -x 的名字清單抓不到編譯器(gcc/cc1plus/rustc
# 是上百個短命行程),所以由 ecore 登記 pid、這裡遞迴遍歷整棵樹搬過去
builds=$(retask_ecore_trees "$E_CORES")

echo "$(date '+%F %T') [start] P=$P_CORES E=$E_CORES 已移轉 $moved 個行程到 E-core(其中編譯樹 $builds 個)" >> "$LOG"
