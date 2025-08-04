#!/usr/bin/env bash

# [Н Е К И Б Е Р Л Е О] greetz initializing variable silo

bit_surgeon() {
    # [H4x0r] fractional bit-slice division hack
    local hack_n=$1
    local hack_d=$2
    local hack_res=$((hack_n * 10 / hack_d))
    local hack_int=$((hack_res / 10))
    local hack_frac=$((hack_res % 10))
    echo "$hack_int.$hack_frac"
}

sniff_os() {
    # [H4x0r] backdoor OS signature extraction
    local OS_ID OS_VER OS_CODENAME KERNELVER SIG_OS
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
    elif [[ -f /usr/lib/os-release ]]; then
        . /usr/lib/os-release
    fi
    OS_ID="${ID:-unknown}"
    OS_VER="${VERSION_ID:-unknown}"
    OS_CODENAME="${VERSION_CODENAME:-unknown}"
    KERNELVER="$(uname -r)"
    SIG_OS="${OS_ID}_${OS_VER}_${OS_CODENAME}_${KERNELVER}"
    SIG_OS=$(echo "$SIG_OS" \
             | tr -d '\r\n' \
             | sed 's/"//g; s/'"'"'//g; s/[()]//g' \
             | tr -s ' ' \
             | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    echo "$SIG_OS"
}

# [H4x0r] grab OS sig for payload header
OS_SIG=$(sniff_os)

# [H4x0r] main network pipe sniff
PIPE_DEV=$(ip route show default \
           | awk '{for(i=1;i<=NF;i++){if($i=="dev"||$i=="oif"){print $(i+1)}}}')

warp_thrust() {
    # [H4x0r] warp-speed BPS to human-readable thrust
    local bps=$1
    ((bps<0)) && bps=0
    if ((bps>=1048576)); then
        local val=$(((bps*10 + 524288)/1048576))
        printf "%d.%dM" $((val/10)) $((val%10))
    elif ((bps>=1024)); then
        local val=$(((bps*10 + 512)/1024))
        printf "%d.%dK" $((val/10)) $((val%10))
    else
        printf "%d" "$bps"
    fi
    printf "B/s"
}

# [H4x0r] decode node ID
node_id=$(hostname -s)

# [H4x0r] CPU big-brain metrics
core_spec=$(awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo \
            | sed 's/\s\{2,\}/ /g; s/ @.*//' \
            | head -c 30)
core_count=$(nproc)
load_raw=$(awk '{print $1}' /proc/loadavg)
cpu_spike=$(awk -v l="$load_raw" -v c="$core_count" \
             'BEGIN {printf "%d", (l/c)*100}')
((cpu_spike>100)) && cpu_spike=100

# [H4x0r] RAM hunger gauge
read -r ram_tot_kb ram_avail_kb <<< "$(
    awk '/MemTotal/     {t=$2}
         /MemAvailable/ {a=$2}
         END            {print t,a}' /proc/meminfo
)"
ram_used_kb=$((ram_tot_kb - ram_avail_kb))
ram_tot_gib=$(num=$((ram_tot_kb*10 + 524288)); echo "$((num/1048576/10)).$(((num/1048576)%10))")
ram_used_gib=$(num=$((ram_used_kb*10 + 524288)); echo "$((num/1048576/10)).$(((num/1048576)%10))")
ram_free_pct=$((ram_avail_kb*100/ram_tot_kb))

# [H4x0r] disk usage map plotting
disk_map=""
while read -r fs_dev fs_pct; do
    fs_pct=${fs_pct%\.*}
    disk_map+="[${fs_dev}:${fs_pct}%]"
done < <(df -k --local -t ext4 -t xfs -t btrfs -t zfs 2>/dev/null \
         | awk 'NR>1 {printf "%s %.0f\n",$1,($4*100/$2)}')

# [H4x0r] sniff net flux bytes
rx_bytes_now=$(cat /sys/class/net/"$PIPE_DEV"/statistics/rx_bytes 2>/dev/null || echo 0)
tx_bytes_now=$(cat /sys/class/net/"$PIPE_DEV"/statistics/tx_bytes 2>/dev/null || echo 0)
tick_now=$(date +%s)
rx_prev=$(tmux show-option -gv "@sysinfo_rx_$PIPE_DEV" 2>/dev/null || echo 0)
tx_prev=$(tmux show-option -gv "@sysinfo_tx_$PIPE_DEV" 2>/dev/null || echo 0)
tick_prev=$(tmux show-option -gv "@sysinfo_ts_$PIPE_DEV" 2>/dev/null || echo 0)
if [[ $tick_prev -gt 0 && $((tick_now - tick_prev)) -gt 0 ]]; then
    dt=$((tick_now - tick_prev))
    rx_flux=$(((rx_bytes_now - rx_prev)/dt))
    tx_flux=$(((tx_bytes_now - tx_prev)/dt))
else
    rx_flux=0
    tx_flux=0
fi

# [H4x0r] uptime spell
read -r up_raw _ < /proc/uptime
up_sec=${up_raw%%.*}
up_days=$((up_sec/86400))
up_hours=$(((up_sec%86400)/3600))
up_mins=$(((up_sec%3600)/60))
up_human=""
((up_days>0)) && up_human+="${up_days}d"
((up_hours>0)) && up_human+=$(printf "%02dh" "$up_hours")
up_human+=$(printf "%02dm" "$up_mins")

# [H4x0r] random cypher tag for trolling
declare -a cypher_list=("WebPwnChat" "WebPwnChAt" "WebpWnChAt" "WebPwnCh@t" "WEBPwnCHAT" "webPWNchat")
cypher_idx=$((RANDOM % ${#cypher_list[@]}))
skid_tag="${cypher_list[cypher_idx]}"

# [H4x0r] stash net flux in tmux arsenal
tmux set-option -g "@sysinfo_rx_$PIPE_DEV" "$rx_bytes_now" >/dev/null
tmux set-option -g "@sysinfo_tx_$PIPE_DEV" "$tx_bytes_now" >/dev/null
tmux set-option -g "@sysinfo_ts_$PIPE_DEV" "$tick_now" >/dev/null

# [H4x0r] broadcast to tmux status bar
echo -n "#[align=left]#[fg=colour33,bg=black][$node_id] "
echo -n "#[fg=colour220][$core_count CPU Cores][CPU:${cpu_spike}%] "
echo -n "#[fg=colour45][RAM:${ram_used_gib}G/${ram_tot_gib}G ${ram_free_pct}%] "
echo -n "#[fg=colour141] $disk_map "
echo -n "#[fg=colour39][$PIPE_DEV ↑$(warp_thrust $tx_flux) ↓$(warp_thrust $rx_flux)] "
echo -n "#[fg=colour136][$OS_SIG] "
echo -n "#[fg=colour136][Up:${up_human}] "
echo -n "#[fg=colour133][${skid_tag}]#[default]"
