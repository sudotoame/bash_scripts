#!/bin/bash

is_letters() {
	local param="$1"

	if [[ ! "$param" =~ ^[A-Za-z]+$ ]]; then
		echo "Error: $param is not english letters"
		return 1
	else
		return 0
	fi
}

len_check() {
	local param="$1"
	local len=${#param}

	if ((len > 7)); then
		echo "Error: $param parameter must contain 7 letters or less"
		return 1
	else
		return 0
	fi
}

is_letters_ext() {
	local param="$1"

	if [[ ! "$param" =~ ^[A-Za-z]+$ ]]; then
		echo "Error: $param is not english letters"
		return 1
	else
		return 0
	fi
}

len_check_ext() {
	local param="$1"
	local len=${#param}

	if ((len > 3)); then
		echo "Error: $param parameter must contain 3 letters or less"
		return 1
	else
		return 0
	fi
}

log() {
	local level="$1"
	local message="$2"
	local filesize="$3"
	local LOG_FILE="logging.log"
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message $filesize" >>$LOG_FILE
}

file_size_is_digit() {
	local filesize="$1"

	if [[ ! "$filesize" =~ ^[0-9]+Mb$ ]]; then
		echo "Error: The file size must be a number followed by 'Mb' (e.g. 50Mb)"
		return 1
	else
		return 0
	fi
}

file_size_is_correct() {
	local filesize="$1"
	local num="${filesize%Mb}"

	if ((num < 1 || num > 100)); then
		echo "Error: File size must be between 1Mb and 100Mb"
		return 1
	else
		return 0
	fi
}

has_enough_free_space() {
	local mount_point="/"
	local require_gb=1

	local avail size unit free_gb

	avail=$(df -h "$mount_point" | awk 'NR==2 {print $4}')

	size=$(echo "$avail" | grep -Eo '[0-9.]+')
	unit=$(echo "$avail" | tr '[:lower:]' '[:upper:]' | grep -Eo '[KMGT]')

	free_gb=0
	case "$unit" in
	G)
		free_gb="$size"
		;;
	M)
		free_gb=$(echo "scale=3; $size / 1024" | bc)
		;;
	K)
		free_gb=$(echo "scale=6; $size / 1024 / 1024" | bc)
		;;
	T)
		free_gb=$(echo "$size * 1024" | bc)
		;;
	*)
		echo "Неизвестная единица: $unit"
		return 2
		;;
	esac

	if (($(echo "$free_gb < $require_gb" | bc -l))); then
		return 1
	else
		return 0
	fi
}

create_dir_file() {
	local dirname="$1"
	local numdirs=$((RANDOM % 100 + 1))
	# local numdirs=5
	local filename="$2"
	# local numfiles=2
	local fileext="$3"
	local filesize="$4"
	local current_date=$(date +%d%m%y)

	while [ ${#dirname} -lt 4 ]; do
		dirname+="${dirname: -1:1}"
	done
	while [ ${#filename} -lt 4 ]; do
		filename+="${filename: -1:1}"
	done

	local last_ch_dirname="${dirname: -1:1}"
	local current_dirname="$dirname"

	local last_ch_filename="${filename: -1:1}"
	local current_filename="$filename"

	local rand_index base_dir folder_name file_name full_path

	mapfile -t allowed_dirs < <(
		find / -maxdepth 3 -type d -writable \
			! -path "*/bin/*" \
			! -path "*/sbin/*" \
			2>/dev/null
	)

	if [ "${#allowed_dirs[@]}" -eq 0 ]; then
		echo "Не найдено подходящих директорий для записи."
		exit 1
	fi

	local file_counter=0
	local folder_counter=0

	for ((i = 1; i <= numdirs; i++)); do
		has_enough_free_space
		local numfiles=$((RANDOM % 100 + 1))
		rand_index=$((RANDOM % ${#allowed_dirs[@]}))
		base_dir="${allowed_dirs[$rand_index]}"

		folder_name="${current_dirname}_$current_date"
		full_path="$base_dir/$folder_name"

		mkdir -p "$full_path" && ((folder_counter++)) || continue
		log "INFO" "Create directory: $full_path"

		local base_filename="$current_filename"

		for ((j = 1; j <= numfiles; j++)); do
			has_enough_free_space
			file_name="$full_path/${base_filename}_$current_date.${fileext}"
			truncate -s "${filesize}M" "$file_name" && ((file_counter++)) || continue
			log "INFO" "Create file: $file_name ${filesize}Mb"

			base_filename+="$last_ch_filename"
		done

		current_dirname+="$last_ch_dirname"
	done
	log "INFO" "Directories: $folder_counter, Files: $file_counter"
}
