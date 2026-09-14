#!/usr/bin/env bash
#
# Heaven Installer - shared core library.
# Sourced by the main entrypoint (heaven-installer.sh) - not meant to be
# run directly. Provides: colors, the spinner-based step runner, system
# scan functions, the banner and the scan warning/confirm prompt.

CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

LOG_DIR="$(mktemp -d /tmp/heaven-installer.XXXXXX)"
LAST_STEP_LOG=""

# --- step runner: spinner while a step runs in the background, then a
#     one-line [OK]/[SKIP]/[FAIL] result. Raw command output goes to a log
#     file instead of the screen, so the user isn't flooded with noise. ---
run_step() {
    local desc="$1"; shift
    local slug
    slug=$(echo "$desc" | tr -c 'a-zA-Z0-9' '_')
    local log="$LOG_DIR/${slug}.log"
    LAST_STEP_LOG="$log"

    "$@" >"$log" 2>&1 &
    local pid=$!
    local spin='|/-\'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % 4 ))
        printf "\r  ${CYAN}%s${RESET} %s   " "${spin:$i:1}" "$desc"
        sleep 0.1
    done

    wait "$pid"
    local status=$?
    if [ "$status" -eq 0 ]; then
        printf "\r  ${GREEN}[OK]${RESET}   %s   \n" "$desc"
    elif [ "$status" -eq 2 ]; then
        printf "\r  ${YELLOW}[SKIP]${RESET} %s   \n" "$desc"
    else
        printf "\r  ${RED}[FAIL]${RESET} %s   \n" "$desc"
        echo -e "    ${DIM}details: $log${RESET}"
    fi
    return "$status"
}

# --- scan functions: each prints KEY='value' lines that get sourced back
#     into the main shell after the step completes. ------------------------
scan_distro() {
    local id="unknown" name="unknown" like=""
    if [ -r /etc/os-release ]; then
        . /etc/os-release
        id="${ID:-unknown}"
        name="${PRETTY_NAME:-unknown}"
        like="${ID_LIKE:-}"
    fi
    echo "DISTRO_ID='$id'"
    echo "DISTRO_NAME='$name'"
    echo "DISTRO_LIKE='$like'"
}

scan_boot_mode() {
    if [ -d /sys/firmware/efi/efivars ]; then
        echo "BOOT_MODE='UEFI'"
    else
        echo "BOOT_MODE='BIOS'"
    fi
}

scan_hardware() {
    local cpu ram_mb disks
    cpu=$(grep -m1 '^model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ *//')
    ram_mb=$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo 2>/dev/null)
    disks=$(lsblk -dn -o NAME,SIZE,TYPE 2>/dev/null | awk '$3=="disk"{printf "%s(%s) ", $1, $2}')
    echo "CPU_MODEL='${cpu:-unknown}'"
    echo "RAM_MB='${ram_mb:-0}'"
    echo "DISKS='${disks:-none detected}'"
}

scan_network() {
    if curl -fsS --max-time 5 https://archlinux.org >/dev/null 2>&1; then
        echo "NET_OK='1'"
    else
        echo "NET_OK='0'"
    fi
}

# --- banner + scan orchestration -------------------------------------------
print_banner() {
    clear
    echo -e "${CYAN}"
    cat <<'BANNER'
 _  _ ___   ___   _____ _  _   ___ _  _ ___ _____ _   _    _    ___ ___
| || | __| /_\ \ / / __| \| | |_ _| \| / __|_   _/_\ | |  | |  | __| _ \
| __ | _| / _ \ V /| _|| .` |  | || .` \__ \ | |/ _ \| |__| |__| _||   /
|_||_|___/_/ \_\_/ |___|_|\_| |___|_|\_|___/ |_/_/ \_\____|____|___|_|_\
BANNER
    echo -e "${RESET}"
    echo
    echo -e "  ${BOLD}Hello to Heaven-Installer!${RESET}"
    echo -e "  ${DIM}Simple Linux installs for everyone.${RESET}"
    echo
}

warn_and_confirm_scan() {
    echo -e "  ${YELLOW}Before continuing, this script will scan your system:${RESET}"
    echo -e "  ${YELLOW}distro, boot mode, CPU/RAM/disks and internet connectivity.${RESET}"
    echo -e "  ${YELLOW}Nothing leaves this machine - it's only used to guide the install.${RESET}"
    echo
    read -rp "  Press Enter to continue, or Ctrl+C to abort... "
    echo
}

run_scans() {
    echo -e "  ${BOLD}Scanning system:${RESET}"
    run_step "Detecting distribution"        scan_distro
    [ -r "$LAST_STEP_LOG" ] && source "$LAST_STEP_LOG"
    run_step "Checking boot mode"            scan_boot_mode
    [ -r "$LAST_STEP_LOG" ] && source "$LAST_STEP_LOG"
    run_step "Reading hardware info"         scan_hardware
    [ -r "$LAST_STEP_LOG" ] && source "$LAST_STEP_LOG"
    run_step "Checking internet connection"  scan_network
    [ -r "$LAST_STEP_LOG" ] && source "$LAST_STEP_LOG"
}

print_summary() {
    echo
    echo -e "  ${BOLD}System summary:${RESET}"
    echo -e "    Distro     : ${DISTRO_NAME:-unknown}"
    echo -e "    Boot mode  : ${BOOT_MODE:-unknown}"
    echo -e "    CPU        : ${CPU_MODEL:-unknown}"
    echo -e "    RAM        : ${RAM_MB:-0} MB"
    echo -e "    Disks      : ${DISKS:-none detected}"
    echo -e "    Internet   : $([ "${NET_OK:-0}" = "1" ] && echo yes || echo no)"
    echo
}
