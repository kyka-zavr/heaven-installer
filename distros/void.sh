#!/usr/bin/env bash
#
# Heaven Installer - Void Linux backend.
# Sourced by the main entrypoint once the distro scan says "void".

install_this_distro() {
    if ! command -v void-installer >/dev/null 2>&1; then
        echo -e "  ${RED}void-installer not found on this system.${RESET}"
        return 1
    fi
    echo -e "  ${BOLD}Handing off to void-installer...${RESET}"
    echo
    exec void-installer
}
