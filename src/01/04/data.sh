#!/bin/bash

# Сбор информации о системе
function collect_system_data() {
    # HOSTNAME
    declare -g HOSTNAME=$(hostname)

    # TIMEZONE с UTC-смещением
    declare -g TIMEZONE=$(timedatectl | grep 'Time zone' | awk '{print $3}')
    declare -g UTC_OFFSET=$(date +%z)
    declare -g UTC_OFFSET_HOURS="${UTC_OFFSET:0:3}"

    # USER
    declare -g USER=$(whoami)

    # OS
    declare -g OS=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')

    # DATE
    declare -g DATE=$(date +"%d %B %Y г. %H:%M:%S")

    # UPTIME
    declare -g UPTIME=$(uptime -p | sed 's/up //')
    declare -g UPTIME_SEC=$(awk '{print int($1)}' /proc/uptime)

    # IP и MASK
    INTERFACE=$(ip route show default 2>/dev/null | awk '{print $5}')
    if [ -n "$INTERFACE" ]; then
        IP_INFO=$(ip -4 addr show "$INTERFACE" | grep 'inet ' | awk '{print $2}')
        if [ -n "$IP_INFO" ]; then
            declare -g IP=$(echo "$IP_INFO" | cut -d'/' -f1)
            MASK_BITS=$(echo "$IP_INFO" | cut -d'/' -f2)
            MASK=$(( (0xffffffff << (32 - MASK_BITS)) & 0xffffffff ))
            OCT1=$(( (MASK >> 24) & 0xff ))
            OCT2=$(( (MASK >> 16) & 0xff ))
            OCT3=$(( (MASK >> 8)  & 0xff ))
            OCT4=$((  MASK        & 0xff ))
            declare -g MASK="$OCT1.$OCT2.$OCT3.$OCT4"
        else
            declare -g IP="N/A"
            declare -g MASK="N/A"
        fi
    else
        declare -g IP="N/A"
        declare -g MASK="N/A"
    fi

    # GATEWAY
    declare -g GATEWAY=$(ip route show default 2>/dev/null | awk '{print $3}')

    # RAM
    RAM_INFO=$(awk '
    /^[Mm]emTotal/ { total = $2 }
    /^[Mm]emFree/  { free  = $2 }
    /^[Bb]uffers/  { buffers = $2 }
    /^[Cc]ached/   { cached = $2 }
    END {
        ram_total = total / (1024 * 1024)
        ram_free = free / (1024 * 1024)
        ram_used = (total - free - buffers - cached) / (1024 * 1024)
        printf "RAM_TOTAL=%.3f\nRAM_FREE=%.3f\nRAM_USED=%.3f\n", ram_total, ram_free, ram_used
    }' /proc/meminfo)
    eval "$RAM_INFO"

    # Корневой раздел
    declare -g SPACE_ROOT=$(df -m --output=size / 2>/dev/null | awk 'NR==2 { printf("%.2f", $1) }')
    declare -g SPACE_ROOT_USED=$(df -m --output=used / 2>/dev/null | awk 'NR==2 { printf("%.2f", $1) }')
    declare -g SPACE_ROOT_FREE=$(df -m --output=avail / 2>/dev/null | awk 'NR==2 { printf("%.2f", $1) }')
}