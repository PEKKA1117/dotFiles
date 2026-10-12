#!/usr/bin/env bash
# gamemode 離開時執行:把背景程式的 CPU 親和性還原成全部核心
# 遊戲結束後沒有理由再把 Discord/瀏覽器關在慢核心上

set -uo pipefail
source "$(dirname "$0")/gamemode-cpu-topology.sh"

LOG=/home/df/.local/share/gamemode-cpu.log
detect_topology

[[ -n "${ALL_CORES:-}" ]] || ALL_CORES="0-$(( $(nproc --all) - 1 ))"

restored=0
for name in "${BG_PROCS[@]}"; do
    while read -r pid; do
        [[ -n "$pid" ]] || continue
        taskset -acp "$ALL_CORES" "$pid" &>/dev/null && (( restored++ ))
    done < <(pgrep -x "$name" 2>/dev/null)
done

# 編譯中的 ecore 行程樹也一併放回全核心,順便回收已結束的登記檔
builds=$(retask_ecore_trees "$ALL_CORES")

echo "$(date '+%F %T') [end] 已還原 $restored 個行程至 $ALL_CORES(其中編譯樹 $builds 個)" >> "$LOG"

# 離座省電狀態:gamemode 離開時會把 governor 還原成「進入當下」的值,
# 若遊戲途中切過 away/back 就會錯位,這裡依 power-mode 狀態重設
# (進入時不需處理,gamemode 本身已依 desiredgov 切到 performance)
"$(dirname "$0")/power-mode" reapply &>/dev/null
