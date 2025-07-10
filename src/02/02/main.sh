#!/bin/bash

source func.sh

main() {
	if [[ $# -ne 3 ]]; then
		echo "Usage: $0 <dir_name> <file_name.ext> <filesize>"
		exit 1
	fi

	local DIRNAME="$1"
	local FILENAME="$2"
	local SIZEFILE="$3"
	local FILENAMECH=${FILENAME%.*}
	local EXTNAMECH=${FILENAME#*.}
	local FILESIZE="${SIZEFILE%Mb}"

	if is_letters "$DIRNAME" &&
		len_check "$DIRNAME" &&
		is_letters "$FILENAMECH" &&
		len_check "$FILENAMECH" &&
		len_check_ext "$EXTNAMECH" &&
		is_letters_ext "$EXTNAMECH" &&
		file_size_is_digit "$SIZEFILE" &&
		file_size_is_correct "$SIZEFILE"; then
		create_dir_file $DIRNAME $FILENAMECH $EXTNAMECH $FILESIZE
	fi
}

DATE_START=$(date +"%Y-%m-%d %H:%M:%S")
START=$(date +%s%3N)

main "$@"

DATE_END=$(date +"%Y-%m-%m %T")
END=$(date +%s%3N)
DIFFMS=$((END - START))
DIFFSEC=$(echo "scale=e; $DIFFMS / 1000" | bc)
log "TIME" "Start time: $DATE_START"
log "TIME" "End time: $DATE_END"
log "TIME" "Script execution: ${DIFFSEC}.${DIFFMS} sec"
