#!/bin/bash

# Цвета по умолчанию
DEFAULT_COLUMN1_BG=1  
DEFAULT_COLUMN1_FG=2  
DEFAULT_COLUMN2_BG=3  
DEFAULT_COLUMN2_FG=4  

if [ $# -eq 1 ]; then
    echo "Скрипт запускается без параметров!"
    exit 1
else
    CONFIG_FILE="param.txt"
    
    # Устанавливаем дефолтные значения
    bg_name_param="$DEFAULT_COLUMN1_BG"
    fg_name_param="$DEFAULT_COLUMN1_FG"
    bg_value_param="$DEFAULT_COLUMN2_BG"
    fg_value_param="$DEFAULT_COLUMN2_FG"

    # Если файл существует, обновляем значения из него
    if [ -f "$CONFIG_FILE" ]; then
    # IFS= предотвращает обрезание пробелов в начале\конце строки
    # -r предотвращает интерпретацию обратных слешей как escape-символы
        while IFS= read -r line; do
        # grep -v '^#' - исключает комментарии, строки, начинающиеся с #
            line=$(echo "$line" | grep -v '^#' | xargs) # xargs - убирает лишние пробелы в начале и конце строки
            if [[ "$line" =~ ^column1_background= ]]; then
                # удаляет все до первого знака =
                bg_name_param="${line#*=}"
            elif [[ "$line" =~ ^column1_font_color= ]]; then
                fg_name_param="${line#*=}"
            elif [[ "$line" =~ ^column2_background= ]]; then
                bg_value_param="${line#*=}"
            elif [[ "$line" =~ ^column2_font_color= ]]; then
                fg_value_param="${line#*=}"
            fi
        done < "$CONFIG_FILE"
    fi
fi

for param in "$bg_name_param" "$fg_name_param" "$bg_value_param" "$fg_value_param"; do
    if ! [[ "$param" =~ ^[1-6]$ ]]; then
        echo "Ошибка: Все параметры должны быть числами от 1 до 6."
        exit 1
    fi
done

source colors.sh || { echo "Ошибка: Не найден файл colors.sh"; exit 1; }
source data.sh || { echo "Ошибка: Не найден файл data.sh"; exit 1; }
source output.sh || { echo "Ошибка: Не найден файл output.sh"; exit 1; }

validate_colors "$bg_name_param" "$fg_name_param" "$bg_value_param" "$fg_value_param"

bg_name=$(get_color_codes "$bg_name_param" | awk '{print $1}')
fg_name=$(get_color_codes "$fg_name_param" | awk '{print $2}')
bg_value=$(get_color_codes "$bg_value_param" | awk '{print $1}')
fg_value=$(get_color_codes "$fg_value_param" | awk '{print $2}')

collect_system_data

print_all_data "$bg_name" "$fg_name" "$bg_value" "$fg_value"

print_color_scheme "$bg_name_param" "$fg_name_param" "$bg_value_param" "$fg_value_param" \
                  "$DEFAULT_COLUMN1_BG" "$DEFAULT_COLUMN1_FG" \
                  "$DEFAULT_COLUMN2_BG" "$DEFAULT_COLUMN2_FG"
