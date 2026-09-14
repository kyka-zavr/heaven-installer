#!/usr/bin/env bash
#
# Heaven Installer - stage 1: welcome banner.
# Meant to be run from an Arch Linux live ISO. Next stage will drive
# archinstall to do the actual guided installation.

set -euo pipefail

clear

CYAN='\033[1;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

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

# TODO(next stage): launch archinstall with a simplified guided flow.
