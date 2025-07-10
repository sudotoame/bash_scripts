#!/bin/bash

# main.sh

source ./config.sh
source ./functions.sh
# '-lt == < | '-gt' == >
if [ $# -lt 1 ] || [ $# -gt 1 ]; then
    echo "$USAGE_MSG"
else
    a="$1"
    if is_alphabetic "$a"; then
        echo "$a"
    else
        echo "$ERROR_NOT_STRING"
    fi
fi
# '=~' оператор соответсвтия регулярному выражению
# '^-?[0-9]+$' регулярное выражение для чисел
# '^[a-zA-Z]+$' регулярное выражение для строки
