#!/bin/bash

# Вывод строки с цветами
function print_colored_line() {
    local bg_name=$1
    local fg_name=$2
    local bg_value=$3
    local fg_value=$4
    local name=$5
    local value=$6
    
    echo -e "\e[${bg_name}m\e[${fg_name}m$name\e[0m =\e[0m \e[${bg_value}m\e[${fg_value}m$value\e[0m"
}

# Вывод всех данных
function print_all_data() {
    local bg_name=$1
    local fg_name=$2
    local bg_value=$3
    local fg_value=$4

    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "HOSTNAME" "$HOSTNAME"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "TIMEZONE" "$TIMEZONE (UTC$UTC_OFFSET_HOURS)"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "USER" "$USER"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "OS" "$OS"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "DATE" "$DATE"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "UPTIME" "$UPTIME"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "UPTIME_SEC" "$UPTIME_SEC сек"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "IP" "$IP"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "MASK" "$MASK"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "GATEWAY" "$GATEWAY"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "RAM_TOTAL" "${RAM_TOTAL} GB"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "RAM_USED" "${RAM_USED} GB"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "RAM_FREE" "${RAM_FREE} GB"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "SPACE_ROOT" "${SPACE_ROOT} MB"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "SPACE_ROOT_USED" "${SPACE_ROOT_USED} MB"
    print_colored_line "$bg_name" "$fg_name" "$bg_value" "$fg_value" "SPACE_ROOT_FREE" "${SPACE_ROOT_FREE} MB"
}
