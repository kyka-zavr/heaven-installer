#!/usr/bin/env bash
#
# Heaven Installer - Alpine Linux backend.
# Sourced by the main entrypoint once the distro scan says "alpine".

install_this_distro() {
    if ! command -v setup-alpine >/dev/null 2>&1; then
        echo -e "  ${RED}setup-alpine not found on this system.${RESET}"
        return 1
    fi
    echo -e "  ${BOLD}Handing off to setup-alpine...${RESET}"
    echo
    exec setup-alpine
}
