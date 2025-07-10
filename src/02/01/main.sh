#!/bin/bash

a_path="$1"
depth_dir="$2"
name_dir="$3"
nums_files="$4"
extensions_name="$5"
size_file="$6"

source functions.sh

main() {
	if [[ $# -ne 6 ]]; then
		echo "Usage: $0 <param1> <param2> <param3> <param4> <param5> <param6>"
		exit 1
	else
		if checking_parameter $a_path $depth_dir $name_dir $nums_files $extensions_name $size_file; then
			if free_space; then
				ch_name_file=${extensions_name%.*}
				ch_ext_name=${extensions_name#*.}
				if [ ${#ch_name_file} -gt 7 ]; then
					echo "Error: $ch_name_file should be 7 or less characters"
					exit 1
				else
					is_letters $ch_name_file
				fi

				if [ ${#ch_ext_name} -gt 3 ]; then
					echo "Error $ch_ext_name should be 3 or less characters"
					exit 1
				else
					is_letters $ch_ext_name
				fi
				# create_folders $a_path $name_dir $depth_dir $nums_files $ch_name_file $ch_ext_name $num
				create_df $a_path $name_dir $depth_dir $ch_name_file $ch_ext_name $nums_files $num
			fi
		fi
	fi
}

main "$@"
