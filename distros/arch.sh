#!/usr/bin/env bash
#
# Heaven Installer - Arch Linux backend.
# Sourced by the main entrypoint once the distro scan says "arch".

install_this_distro() {
    if ! command -v archinstall >/dev/null 2>&1; then
        echo -e "  ${RED}archinstall not found on this system.${RESET}"
        return 1
    fi
    echo -e "  ${BOLD}$(t handoff) archinstall...${RESET}"
    echo
    exec archinstall
}
