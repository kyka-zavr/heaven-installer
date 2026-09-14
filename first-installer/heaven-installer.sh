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
  #...#  #####  .###.  #...#  #####  #...#
  #...#  #....  #...#  #...#  #....  ##..#
  #####  ###..  #####  #...#  ###..  #.#.#
  #...#  #....  #...#  .#.#.  #....  #..##
  #...#  #####  #...#  ..#..  #####  #...#
BANNER
echo -e "${RESET}"

echo -e "${BOLD}                     I N S T A L L E R${RESET}"
echo
echo -e "  ${BOLD}Hello to Heaven-Installer!${RESET}"
echo -e "  ${DIM}Simple Linux installs for everyone.${RESET}"
echo

# TODO(next stage): launch archinstall with a simplified guided flow.
