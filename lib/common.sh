#!/usr/bin/env bash
#
# Heaven Installer - shared core library.
# Sourced by the main entrypoint (heaven-installer.sh) - not meant to be
# run directly. Provides: colors, the spinner-based step runner, system
# scan functions, the banner, Stage 0 (language select) and the scan
# warning/confirm prompt. Needs lib/i18n.sh's t() already sourced.

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
    local log
    log=$(mktemp "$LOG_DIR/step.XXXXXX.log")
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

# --- Stage 0: Cyrillic console support + language select -------------------
# Raw Linux tty consoles often load a font with no Cyrillic glyphs, so we
# verify (and load) a Unicode/Cyrillic-capable font *before* offering
# Russian - if none is available we silently stay on English instead of
# showing garbled text.
check_cyrillic() {
    for font in UniCyr_8x16 ter-116n ter-v16n Cyr_a8x16 cyr-sun16; do
        if command -v setfont >/dev/null 2>&1 && setfont "$font" 2>/dev/null; then
            echo "CYRILLIC_OK='1'"
            echo "CYRILLIC_FONT='$font'"
            return 0
        fi
    done
    echo "CYRILLIC_OK='0'"
}

select_language() {
    run_step "$(t cyrillic_check)" check_cyrillic
    [ -r "$LAST_STEP_LOG" ] && source "$LAST_STEP_LOG"

    if [ "${CYRILLIC_OK:-0}" = "1" ]; then
        echo
        echo "  $(t lang_prompt)"
        echo "    [1] English"
        echo "    [2] Русский"
        echo
        local choice
        read -rp "  > " choice
        case "$choice" in
            2) HEAVEN_LANG="ru" ;;
            *) HEAVEN_LANG="en" ;;
        esac
    else
        HEAVEN_LANG="en"
        echo
        echo -e "  ${DIM}$(t lang_fallback)${RESET}"
    fi
    export HEAVEN_LANG
    echo "$HEAVEN_LANG" > /tmp/heaven-installer-lang 2>/dev/null || true
    echo
}

# Right-pads a label out to a fixed column so values line up in the summary
# regardless of language (Russian labels run longer than English ones, so
# the column width itself is picked per language, not shared).
pad() {
    local label="$1" width=11
    [ "$HEAVEN_LANG" = "ru" ] && width=16
    local n=$(( width - ${#label} ))
    [ "$n" -lt 1 ] && n=1
    printf '%*s' "$n" ""
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
    echo -e "  ${BOLD}$(t hello)${RESET}"
    echo -e "  ${DIM}$(t tagline)${RESET}"
    echo
}

warn_and_confirm_scan() {
    echo -e "  ${YELLOW}$(t scan_warn1)${RESET}"
    echo -e "  ${YELLOW}$(t scan_warn2)${RESET}"
    echo -e "  ${YELLOW}$(t scan_warn3)${RESET}"
    echo
    read -rp "  $(t press_enter)" _
    echo
}

run_scans() {
    echo -e "  ${BOLD}$(t scanning)${RESET}"
    run_step "$(t step_distro)" scan_distro
    [ -r "$LAST_STEP_LOG" ] && source "$LAST_STEP_LOG"
    run_step "$(t step_boot)"   scan_boot_mode
    [ -r "$LAST_STEP_LOG" ] && source "$LAST_STEP_LOG"
    run_step "$(t step_hw)"     scan_hardware
    [ -r "$LAST_STEP_LOG" ] && source "$LAST_STEP_LOG"
    run_step "$(t step_net)"    scan_network
    [ -r "$LAST_STEP_LOG" ] && source "$LAST_STEP_LOG"
}

print_summary() {
    echo
    echo -e "  ${BOLD}$(t summary)${RESET}"
    echo -e "    $(t l_distro)$(pad "$(t l_distro)"): ${DISTRO_NAME:-unknown}"
    echo -e "    $(t l_boot)$(pad "$(t l_boot)"): ${BOOT_MODE:-unknown}"
    echo -e "    $(t l_cpu)$(pad "$(t l_cpu)"): ${CPU_MODEL:-unknown}"
    echo -e "    $(t l_ram)$(pad "$(t l_ram)"): ${RAM_MB:-0} MB"
    echo -e "    $(t l_disks)$(pad "$(t l_disks)"): ${DISKS:-none detected}"
    echo -e "    $(t l_internet)$(pad "$(t l_internet)"): $([ "${NET_OK:-0}" = "1" ] && t yes || t no)"
    echo
}
