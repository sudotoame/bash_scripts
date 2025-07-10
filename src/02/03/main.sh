#!/bin/bash

is_there_a_file() {
	local FILE="$1"
	if [[ ! -f "$FILE" ]]; then
		echo "Error: File '$FILE' not find"
		return 1
	else
		return 0
	fi
}

validate_date() {
	local DATE="$1"
	if ! date -d "$DATE" &>/dev/null; then
		echo "❌ Invalid date format: $DATE"
		return 1
	fi
	return 0
}

delete_by_mask() {
	local MASK='_[0-9]{6}$'
	local TARGET_DIR="/"
	local DELETECOUNT=0

	while IFS= read -r -d '' DIR; do
		local DIR_NAME=$(basename "$DIR")

		if [[ "$DIR_NAME" =~ $MASK ]]; then
			rm -rf "$DIR" && echo "Deleted directory: $DIR" >>delete_log.log && ((DELETECOUNT++))
		fi
	done < <(find "$TARGET_DIR" -type d -print0 2>/dev/null)
	echo "Done." && echo "Deleted directories: $DELETECOUNT" >>delete_log.log
}

delete_by_date() {
	local START="$1"
	local END="$2"
	local TARGET_DIR="/"
	local COUNTDELETE

	echo "🔍 Searching directories modified between $START and $END in $TARGET_DIR..."

	local START_TS=$(date -d "$START" +%s)
	local END_TS=$(date -d "$END" +%s)

	if ((START_TS > END_TS)); then
		echo "❌ Start time must be before end time"
		return 1
	fi

	local DATE_PATTERN='_[0-9]{6}$'

	while IFS= read -r -d '' DIR; do
		local DIR_NAME=$(basename "$DIR")

		if [[ "$DIR_NAME" =~ $DATE_PATTERN ]]; then
			rm -rf "$DIR" && echo "Deleted directory: $DIR" >>delete_log.log && ((DELETECOUNT++))
		fi
	done < <(find "$TARGET_DIR" -type d -newermt "$START" ! -newermt "$END" -print0 2>/dev/null)

	echo "Done." && echo "Delete directories: $DELETECOUNT" >>delete_log.log
}

delete_log() {
	local LFILE="$1"
	local COUNTDIR=0
	local COUNTFILE=0

	mapfile -t DIRECTORIES < <(
		awk '/Create directory:/ {print $6}' "$LFILE"
	)

	mapfile -t FILES < <(
		awk '/Create file:/ {print $6}' "$LFILE"
	)

	for FILE in "${FILES[@]}"; do
		if [[ -f "$FILE" ]]; then
			rm -f "$FILE" && echo "File delete: $FILE" >>delete_log.log && ((COUNTFILE++))
		fi
	done

	for DIR in "${DIRECTORIES[@]}"; do
		if [[ -d "$DIR" ]]; then
			rm -rf "$DIR" && echo "Directories delete: $DIR" >>delete_log.log && ((COUNTDIR++))
		fi
	done

	echo "Deleted directories: '$COUNTDIR'. Deleted files: '$COUNTFILE'" >>delete_log.log
}

main() {
	if [ $# -ne 1 ]; then
		echo "Usage: $0 <operating mode>"
		exit 1
	fi

	case "$1" in
	1)
		local LOG_FILE="../02/logging.log"
		if is_there_a_file $LOG_FILE; then
			delete_log $LOG_FILE
		fi
		;;
	2)
		local START=""
		local END=""

		read -p "Enter start time (YYYY-MM-DD HH:MM): " START
		read -p "Enter end time (YYYY-MM-DD HH:MM): " END

		validate_date "$START" || exit 1
		validate_date "$END" || exit 1

		delete_by_date "$START" "$END"
		;;
	3)
		delete_by_mask
		;;
	*)
		echo "unknown mode: Script work with 1, 2, 3 mode"
		exit 1
		;;
	esac
}

main "$@"
