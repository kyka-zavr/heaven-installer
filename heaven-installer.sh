#!/usr/bin/env bash
#
# Heaven Installer - universal entrypoint.
#
# Scans the running system, figures out which distro's live ISO you're on,
# and hands off to that distro's real installer (archinstall, setup-alpine,
# void-installer, ...). Meant to be run straight from a live ISO:
#
#   curl -fsSL https://raw.githubusercontent.com/kyka-zavr/heaven-installer/master/heaven-installer.sh | bash

set -uo pipefail

# When run as `curl | bash`, fd0 is the download stream, not the keyboard.
# Reattach stdin to the real terminal so `read` prompts and the TUI
# installer we hand off to (archinstall etc.) get real keyboard input.
exec < /dev/tty

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

fetch_and_source "$REPO_RAW/lib/common.sh" || exit 1

print_banner
warn_and_confirm_scan
run_scans
print_summary

if [ "${NET_OK:-0}" != "1" ]; then
    echo -e "  ${YELLOW}No internet connection - can't fetch the installer for ${DISTRO_NAME:-this distro}.${RESET}"
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
        echo -e "  ${YELLOW}${DISTRO_NAME:-This distro} isn't supported yet.${RESET}"
        echo -e "  ${DIM}Supported right now: Arch, Alpine, Void.${RESET}"
        exit 1
        ;;
esac

install_this_distro
