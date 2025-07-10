#!/bin/bash

# Получение названия цвета по числу
function get_color_name() {
    local color_number=$1
    case $color_number in
        1) echo "white" ;;
        2) echo "red" ;;
        3) echo "green" ;;
        4) echo "blue" ;;
        5) echo "purple" ;;
        6) echo "black" ;;
        *) echo "unknown" ;;
    esac
}

# Вывод строки с цветами
function print_colored_line() {
    local bg_name=$1
    local fg_name=$2
    local bg_value=$3
    local fg_value=$4
    local name=$5
    local value=$6
    # ANSI escape-символ для вывода цветного текста в терминал
    # -e флаг для того чтобы echo интерпритировал escape-символы
    # \e[0m сбрасывает все стили
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

# Вывод цветовой схемы
function print_color_scheme() {
    local bg_name_param=$1
    local fg_name_param=$2
    local bg_value_param=$3
    local fg_value_param=$4
    local default_bg_name=$5
    local default_fg_name=$6
    local default_bg_value=$7
    local default_fg_value=$8

    echo  # Пустая строка перед выводом

    # Column 1 background
    if [ "$bg_name_param" -eq "$default_bg_name" ]; then
        echo "Column 1 background = default ($(get_color_name "$default_bg_name"))"
    else
        echo "Column 1 background = $bg_name_param ($(get_color_name "$bg_name_param"))"
    fi

    # Column 1 font color
    if [ "$fg_name_param" -eq "$default_fg_name" ]; then
        echo "Column 1 font color = default ($(get_color_name "$default_fg_name"))"
    else
        echo "Column 1 font color = $fg_name_param ($(get_color_name "$fg_name_param"))"
    fi

    # Column 2 background
    if [ "$bg_value_param" -eq "$default_bg_value" ]; then
        echo "Column 2 background = default ($(get_color_name "$default_bg_value"))"
    else
        echo "Column 2 background = $bg_value_param ($(get_color_name "$bg_value_param"))"
    fi

    # Column 2 font color
    if [ "$fg_value_param" -eq "$default_fg_value" ]; then
        echo "Column 2 font color = default ($(get_color_name "$default_fg_value"))"
    else
        echo "Column 2 font color = $fg_value_param ($(get_color_name "$fg_value_param"))"
    fi
}
