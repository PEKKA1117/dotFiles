#!/usr/bin/env bash
# Overwatch 效能監控 — 記憶體 + P/E core 爭用 + GPU
#
# 原版只記錄記憶體,能證明「不是記憶體問題」但無法指認真兇。
# 加上 P-core/E-core 分開統計後,可直接對照 MangoHud 幀時間:
# P-core 使用率尖峰與 frametime 尖峰對齊 = 排程爭用;GPU 釘在 95%+ 才是顯卡瓶頸。
#
# 用法: ow-monitor.sh [輸出檔] [取樣秒數]
#   預設 ~/ow-memlog.csv,每 30 秒一筆

set -uo pipefail
source "$HOME/.config/gamemode/gamemodeScripts/gamemode-cpu-topology.sh"

OUT=${1:-/home/df/ow-memlog.csv}
INTERVAL=${2:-30}

detect_topology
IFS=',' read -ra P_LIST <<< "${P_CORES:-}"
IFS=',' read -ra E_LIST <<< "${E_CORES:-}"

# 讀取每顆核心的累計 busy/total jiffies
declare -A PREV_BUSY PREV_TOTAL
read_cpu_stat() {
    local -n busy_ref=$1 total_ref=$2
    local line id user nice sys idle iowait irq softirq steal
    while read -r line; do
        [[ $line =~ ^cpu[0-9] ]] || continue
        read -r id user nice sys idle iowait irq softirq steal _ <<< "$line"
        id=${id#cpu}
        busy_ref[$id]=$(( user + nice + sys + irq + softirq + steal ))
        total_ref[$id]=$(( user + nice + sys + idle + iowait + irq + softirq + steal ))
    done < /proc/stat
}

# 回傳指定核心群組自上次取樣以來的平均使用率
group_usage() {
    local -n cores=$1
    local -n cur_busy=$2 cur_total=$3
    local sum=0 n=0 id db dt
    for id in "${cores[@]}"; do
        [[ -n "${PREV_TOTAL[$id]:-}" ]] || continue
        db=$(( cur_busy[$id] - PREV_BUSY[$id] ))
        dt=$(( cur_total[$id] - PREV_TOTAL[$id] ))
        (( dt > 0 )) || continue
        sum=$(( sum + db * 1000 / dt )); n=$(( n + 1 ))
    done
    (( n > 0 )) && printf '%.1f' "$(( sum / n ))e-1" || echo "0.0"
}

field_mb() { # 從 /proc/PID/status 取欄位並轉 MB
    local v; v=$(grep -m1 "^$2:" "/proc/$1/status" 2>/dev/null | awk '{print $2}')
    echo $(( ${v:-0} / 1024 ))
}

if [[ ! -f $OUT ]]; then
    echo "time,ow_pid,ow_uptime_s,ow_rss_mb,ow_swap_mb,proton_swap_mb,sys_used_mb,sys_avail_mb,swap_used_mb,zram_data_mb,psi_mem_avg60,psi_mem_full_avg60,pswpin,pswpout,pcore_pct,ecore_pct,psi_cpu_avg60,gpu_pct,gpu_mem_mb,ow_vram_mb,gpu_power_w" > "$OUT"
fi

echo "監控中 → $OUT  (P-core: ${P_CORES:-無}  E-core: ${E_CORES:-無}  間隔 ${INTERVAL}s)" >&2
declare -A CUR_BUSY CUR_TOTAL
read_cpu_stat CUR_BUSY CUR_TOTAL
for id in "${!CUR_BUSY[@]}"; do PREV_BUSY[$id]=${CUR_BUSY[$id]}; PREV_TOTAL[$id]=${CUR_TOTAL[$id]}; done

while :; do
    sleep "$INTERVAL"

    read_cpu_stat CUR_BUSY CUR_TOTAL
    pcore=$(group_usage P_LIST CUR_BUSY CUR_TOTAL)
    ecore=$(group_usage E_LIST CUR_BUSY CUR_TOTAL)
    for id in "${!CUR_BUSY[@]}"; do PREV_BUSY[$id]=${CUR_BUSY[$id]}; PREV_TOTAL[$id]=${CUR_TOTAL[$id]}; done

    ow_pid=$(pgrep -x Overwatch.exe 2>/dev/null | head -1)
    if [[ -n ${ow_pid:-} ]]; then
        ow_rss=$(field_mb "$ow_pid" VmRSS)
        ow_swap=$(field_mb "$ow_pid" VmSwap)
        # etimes 直接給經過秒數;lstart 會受 locale 影響(中文環境下 date -d 無法解析)
        uptime_s=$(ps -o etimes= -p "$ow_pid" 2>/dev/null | tr -d ' ')
        wpid=$(pgrep -x wineserver 2>/dev/null | head -1)
        proton_swap=$([[ -n ${wpid:-} ]] && field_mb "$wpid" VmSwap || echo 0)
        # 遊戲屬 graphics 行程,--query-compute-apps 抓不到,得解析 nvidia-smi 的行程表
        ow_vram=$(nvidia-smi 2>/dev/null | awk -v p="$ow_pid" \
            '$1=="|" && $5==p {v=$(NF-1); gsub(/MiB/,"",v); print v; exit}')
    else
        ow_pid=0 ow_rss=0 ow_swap=0 uptime_s=0 proton_swap=0 ow_vram=0
    fi

    read -r used avail < <(free -m | awk '/^Mem:/{print $3, $7}')
    swap_used=$(free -m | awk '/^Swap:/{print $3}')
    zram_data=$(zramctl --noheadings --bytes 2>/dev/null | awk '{s+=$4} END{print int(s/1048576)}')
    psi_mem=$(awk '/^some/{for(i=1;i<=NF;i++)if($i~/^avg60=/){sub("avg60=","",$i);print $i}}' /proc/pressure/memory)
    psi_mem_full=$(awk '/^full/{for(i=1;i<=NF;i++)if($i~/^avg60=/){sub("avg60=","",$i);print $i}}' /proc/pressure/memory)
    psi_cpu=$(awk '/^some/{for(i=1;i<=NF;i++)if($i~/^avg60=/){sub("avg60=","",$i);print $i}}' /proc/pressure/cpu)
    read -r pswpin pswpout < <(awk '/^pswpin/{i=$2} /^pswpout/{o=$2} END{print i, o}' /proc/vmstat)
    read -r gpu_pct gpu_mem gpu_pw < <(nvidia-smi --query-gpu=utilization.gpu,memory.used,power.draw \
        --format=csv,noheader,nounits 2>/dev/null | tr -d ' ' | tr ',' ' ')

    printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' \
        "$(date '+%F %T')" "$ow_pid" "$uptime_s" "$ow_rss" "$ow_swap" "$proton_swap" \
        "$used" "$avail" "$swap_used" "${zram_data:-0}" "$psi_mem" "$psi_mem_full" \
        "$pswpin" "$pswpout" "$pcore" "$ecore" "$psi_cpu" "${gpu_pct:-0}" "${gpu_mem:-0}" \
        "${ow_vram:-0}" "${gpu_pw:-0}" >> "$OUT"
done
