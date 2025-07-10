#!/bin/bash

current_date=$(date +%d%m%y)
LOG_FILE="file_generator.log"

log() {
	local level="$1"
	local message="$2"
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >>$LOG_FILE
}

is_directory() {
	full_path="$1"
	parent_dir=$(dirname "$full_path")

	if [[ ! -d "$parent_dir" ]]; then
		echo "Error: '$parent_dir' invalid directory"
		exit 1
	fi
}

is_digit() {
	if [[ ! "$1" =~ ^[1-9][0-9]*$ ]]; then
		echo "Error: $1 is not postive number"
		exit 1
	fi
}

is_letters() {
	param="$1"

	if [[ ! "$param" =~ ^[A-Za-z]+$ ]]; then
		echo "Error: $param is not english letters"
		exit 1
	else
		len=${#param}
		if ((len > 7)); then
			echo "Error: $param parameter must contain 7 letters"
			exit 1
		fi
	fi
}

file_size() {
	local filesize="$1"

	if [[ ! "$filesize" =~ ^[0-9]+kb$ ]]; then
		echo "Error: The file size must be a number followed by 'kb' (e.g. 50kb)"
		exit 1
	fi

	num="${filesize%kb}"

	if ((num < 1 || num > 100)); then
		echo "Error: File size must be between 1kb and 100kb"
		exit 1
	fi
}

free_space() {
	min_free_space=1048576
	available_space=$(df -k / | awk 'NR==2 {print $4}')

	if [ "$available_space" -lt "$min_free_space" ]; then
		echo "Error: Not enough free space on the root partition. At least 1 GB required" >&2
		exit 1
	fi
}

checking_parameter() {
	is_directory $1
	is_digit $2
	is_letters $3
	is_digit $4
	# is_letters $5
	file_size $6
}

create_df() {
	local dir_path=$1
	local dir_name=$2
	local dir_nums=$3
	local file_name=$4
	local file_ext=$5
	local file_nums=$6
	local file_size=$7

	while [ ${#dir_name} -lt 4 ]; do
		dir_name+="${dir_name: -1:1}"
	done
	while [ ${#file_name} -lt 4 ]; do
		file_name+="${file_name: -1:1}"
	done

	local last_char_dir="${dir_name: -1:1}"
	local last_char_file="${file_name: -1:1}"
	# echo "$last_char_dir"

	local current_dirname="$dir_name"
	# echo "$current_dirname"
	local current_filename="$file_name"

	for ((i = 1; i <= "$dir_nums"; i++)); do
		avail_size=$(df -k / | awk 'NR==2 {print $4}')
		if [ "$avail_size" -le 1048576 ]; then
			echo "Error: Not enough memory"
			log "ERROR" "Not enough free space on root partition"
			exit 1
		fi

		local full_path="$dir_path/${current_dirname}_$current_date"
		mkdir -p "$full_path"
		log "INFO" "Create folders: $full_path"
		# echo "$i"

		for ((j = 1; j <= file_nums; j++)); do
			avail_size=$(df -k / | awk 'NR==2 {print $4}')
			if [ "$avail_size" -le 1048576 ]; then
				echo "Error: Not enough memory"
				log "ERROR" "Not enough free space on root partition"
				exit 1
			fi

			local full_filepath="$full_path/${current_filename}_${current_date}.${file_ext}"
			truncate -s "${file_size}K" "$full_filepath"
			log "INFO" "Create file: $full_filepath"
			current_filename+="$last_char_file"
		done

		current_dirname+="$last_char_dir"
	done
}

directory_create() {
	path="$1"

	if [ ! -d "$path" ]; then
		mkdir -p "$path"
		echo "Directory $path created"
	else
		echo "The directory $path already exist"
	fi
}
