#!/usr/bin/env bash
#
# Heaven Installer - universal entrypoint.
#
# Scans the running system, figures out which distro's live ISO you're on,
# and hands off to that distro's real installer (archinstall, setup-alpine,
# void-installer, ...). Meant to be run straight from a live ISO:
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/kyka-zavr/heaven-installer/master/heaven-installer.sh)
#
# Note: use `bash <(curl ...)`, NOT `curl ... | bash`. This script needs
# real keyboard input (a confirm prompt, then it hands off to a full TUI
# installer) - piping into bash replaces stdin with the download stream,
# which breaks both. Process substitution avoids that: bash reads the
# script as a file, so its own stdin stays attached to your terminal.

set -uo pipefail

REPO_RAW="https://raw.githubusercontent.com/kyka-zavr/heaven-installer/master"

fetch_and_source() {
    local url="$1" tmp
    tmp=$(mktemp /tmp/heaven-installer-src.XXXXXX.sh)
    if ! curl -fsSL "$url" -o "$tmp"; then
        echo "Failed to download $url" >&2
        rm -f "$tmp"
        return 1
    fi
    # shellcheck source=/dev/null
    source "$tmp"
    rm -f "$tmp"
}

fetch_and_source "$REPO_RAW/lib/i18n.sh" || exit 1
fetch_and_source "$REPO_RAW/lib/common.sh" || exit 1

print_banner
select_language
warn_and_confirm_scan
run_scans
print_summary

if [ "${NET_OK:-0}" != "1" ]; then
    echo -e "  ${YELLOW}$(t no_internet) ${DISTRO_NAME:-?}.${RESET}"
    exit 1
fi

case "${DISTRO_ID:-unknown}" in
    arch)
        fetch_and_source "$REPO_RAW/distros/arch.sh" || exit 1
        ;;
    alpine)
        fetch_and_source "$REPO_RAW/distros/alpine.sh" || exit 1
        ;;
    void)
        fetch_and_source "$REPO_RAW/distros/void.sh" || exit 1
        ;;
    *)
        echo -e "  ${YELLOW}${DISTRO_NAME:-?} $(t not_supported)${RESET}"
        echo -e "  ${DIM}$(t supported_list)${RESET}"
        exit 1
        ;;
esac

install_this_distro
