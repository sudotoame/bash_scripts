#!/bin/bash

if [ $# -ne 4 ]; then
    echo "Usage: $0 <param1> <param2> <param3> <param4>"
    exit 1
fi

for params in "$1" "$2" "$3" "$4"; do
    if ! [[ "$params" =~ ^[1-6]$ ]]; then
        echo "Error: All parameters must be numbers (1-6)"
        exit 1
    fi
done

source colors.sh || { echo "Ошибка: Не найден файл colors.sh"; exit 1; }
source data.sh || { echo "Ошибка: Не найден файл data.sh"; exit 1; }
source output.sh || { echo "Ошибка: Не найден файл output.sh"; exit 1; }

validate_colors "$1" "$2" "$3" "$4"

bg_name=$(get_color_codes "$1" | awk '{print $1}')
fg_name=$(get_color_codes "$2" | awk '{print $2}')
bg_value=$(get_color_codes "$3" | awk '{print $1}')
fg_value=$(get_color_codes "$4" | awk '{print $2}')

collect_system_data

print_all_data "$bg_name" "$fg_name" "$bg_value" "$fg_value"