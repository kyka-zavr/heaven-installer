#!/usr/bin/env bash
#
# Heaven Installer - i18n helpers + string table.
# Sourced by the entrypoint before any UI function runs. HEAVEN_LANG is
# either "en" or "ru"; select_language() sets it via a Stage 0 prompt.

HEAVEN_LANG="${HEAVEN_LANG:-en}"

t() {
    local key="$1"
    case "${HEAVEN_LANG}:${key}" in
        en:hello)          echo "Hello to Heaven-Installer!" ;;
        ru:hello)          echo "Добро пожаловать в Heaven-Installer!" ;;
        en:tagline)        echo "Simple Linux installs for everyone." ;;
        ru:tagline)        echo "Простая установка Linux - для всех." ;;

        en:cyrillic_check) echo "Checking Cyrillic console support" ;;
        ru:cyrillic_check) echo "Checking Cyrillic console support" ;;
        en:lang_prompt)    echo "Select language / Выберите язык:" ;;
        ru:lang_prompt)    echo "Select language / Выберите язык:" ;;
        en:lang_fallback)  echo "Cyrillic isn't supported on this console - continuing in English." ;;
        ru:lang_fallback)  echo "Cyrillic isn't supported on this console - continuing in English." ;;

        en:scan_warn1)     echo "Before continuing, this script will scan your system:" ;;
        ru:scan_warn1)     echo "Перед продолжением скрипт просканирует систему:" ;;
        en:scan_warn2)     echo "distro, boot mode, CPU/RAM/disks and internet connectivity." ;;
        ru:scan_warn2)     echo "дистрибутив, режим загрузки, CPU/RAM/диски и интернет." ;;
        en:scan_warn3)     echo "Nothing leaves this machine - it's only used to guide the install." ;;
        ru:scan_warn3)     echo "Ничего никуда не уходит - используется только для установки." ;;
        en:press_enter)    echo "Press Enter to continue, or Ctrl+C to abort... " ;;
        ru:press_enter)    echo "Нажмите Enter, чтобы продолжить, или Ctrl+C для отмены... " ;;

        en:scanning)       echo "Scanning system:" ;;
        ru:scanning)       echo "Сканирование системы:" ;;
        en:step_distro)    echo "Detecting distribution" ;;
        ru:step_distro)    echo "Определение дистрибутива" ;;
        en:step_boot)      echo "Checking boot mode" ;;
        ru:step_boot)      echo "Проверка режима загрузки" ;;
        en:step_hw)        echo "Reading hardware info" ;;
        ru:step_hw)        echo "Чтение информации о железе" ;;
        en:step_net)       echo "Checking internet connection" ;;
        ru:step_net)       echo "Проверка интернет-соединения" ;;

        en:summary)        echo "System summary:" ;;
        ru:summary)        echo "Сводка по системе:" ;;
        en:l_distro)       echo "Distro" ;;
        ru:l_distro)       echo "Дистрибутив" ;;
        en:l_boot)         echo "Boot mode" ;;
        ru:l_boot)         echo "Режим загрузки" ;;
        en:l_cpu)          echo "CPU" ;;
        ru:l_cpu)          echo "Процессор" ;;
        en:l_ram)          echo "RAM" ;;
        ru:l_ram)          echo "Память" ;;
        en:l_disks)        echo "Disks" ;;
        ru:l_disks)        echo "Диски" ;;
        en:l_internet)     echo "Internet" ;;
        ru:l_internet)     echo "Интернет" ;;
        en:yes)            echo "yes" ;;
        ru:yes)            echo "да" ;;
        en:no)             echo "no" ;;
        ru:no)             echo "нет" ;;

        en:no_internet)    echo "No internet connection - can't fetch the installer for" ;;
        ru:no_internet)    echo "Нет интернета - не получится скачать установщик для" ;;
        en:not_supported)  echo "isn't supported yet." ;;
        ru:not_supported)  echo "пока не поддерживается." ;;
        en:supported_list) echo "Supported right now: Arch, Alpine, Void." ;;
        ru:supported_list) echo "Сейчас поддерживаются: Arch, Alpine, Void." ;;
        en:handoff)        echo "Handing off to" ;;
        ru:handoff)        echo "Передаю управление" ;;

        *) echo "$key" ;;
    esac
}
