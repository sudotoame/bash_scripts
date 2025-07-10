#!/bin/bash

# script run with 1 parametr,
# absolute or relative path to a directory
# The parametr must end with '/'

source functions.sh

main() {
# if '$#' not 1 to exit
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <param>"
        exit 1
    else
        if is_valid_dir "$1"; then
            result_print $1
        else
            exit 1
        fi
    fi
}
start=$(date +%s%3N)  # миллисекунды

main "$@"

end=$(date +%s%3N)
diff_ms=$(( end - start ))
diff_sec=$(echo "scale=1; $diff_ms / 1000" | bc)
echo
echo -e "Script execution time \033[0;41m$diff_sec\033[m"