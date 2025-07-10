#!/bin/bash

# config.sh

HOSTNAME=$(hostname)

# TIMEZONE
TIMEZONE=$(timedatectl | grep 'Time zone' | awk '{print $3}')
UTC_OFFSET=$(date +%z)
UTC_OFFSET_HOURS=${UTC_OFFSET:0:3}

USER=$(whoami)
OS=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
DATE=$(date +"%d %B %Y г. %H:%M:%S")
UPTIME=$(uptime -p | sed 's/up //')
UPTIME_SEC=$(cat /proc/uptime | awk '{print int($1)}')

# IP и MASK (для первого активного интерфейса)
IP_INFO=$(ip -4 addr show $(ip route show default | awk '{print $5}') | grep 'inet ' | awk '{print $2}')
IP=$(echo $IP_INFO | cut -d'/' -f1)
MASK_BITS=$(echo $IP_INFO | cut -d'/' -f2)
MASK=$(( (0xffffffff << (32 - MASK_BITS)) & 0xffffffff ))
OCT1=$(( (MASK >> 24) & 0xff ))
OCT2=$(( (MASK >> 16) & 0xff ))
OCT3=$(( (MASK >> 8)  & 0xff ))
OCT4=$((  MASK        & 0xff ))
GATEWAY=$(ip route show default | awk '{print $3}')

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

# Присваиваем значения переменным окружения
eval "$RAM_INFO"

# Корневой раздел в МБ с точностью до 2 знаков
SPACE_ROOT=$(df -m --output=size / | awk 'NR==2 { printf("%.2f", $1) }')
SPACE_ROOT_USED=$(df -m --output=used / | awk 'NR==2 { printf("%.2f", $1) }')
SPACE_ROOT_FREE=$(df -m --output=avail / | awk 'NR==2 { printf("%.2f", $1) }')