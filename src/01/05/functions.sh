#!/bin/bash


total_dir() {
    # "type -d" only directories
    # has a problem with space in directory name
    # NUM_OF_FOLDERS=$(find $1 -type d | wc -l) # -l count the number of lines passed from find

    # '-print0' its '\x0' NULL byte 
    # prints each found directory name followed by a null byte (\0) instead of a newline
    # example: ./dir1\0./my dir\0./test/another dir\0
    # grep -cz: 
    # `-c` count how many lines match(here we are dealing with null bytes, not lines). 
    # `-z` treat input as null-terminated, matching the output format of `-print0`. 
    # `.` a regular expression that matched any charachter (it will match every null-terminated entry)
    NUM_OF_FOLDERS=$(find "$1" -type d -print0 | grep -cz .)
    echo "Total number of folders (including all nested ones) = $NUM_OF_FOLDERS"
}

top_five() {
    echo "TOP 5 folders of maximum size arranged in descending order (path and size):"

    # `du` disk usage
    # `-h` makes the output human-readable
    # `--max-depth=10` directory at the 10 level of '$1'
    # `sort -hr`
    # `-h` sort human-readable sizes correctly
    # `-r` revers the order to show largest first
    # `head -n 5` limits output to the top 5 results
    # `awk '{print NR ". "$0}'` prints each line with a prefix number indicating its rank (1 - 5)
    du -h $1 --max-depth=10 | sort -hr | head -n 5 | awk '{print NR ". "$0}'
}

total_files() {
    # `-type f` limits results to regular files only
    # count the number of lines, which corresponds to the number of files.
    # for hidden files: find "$1" -type f -o -name '.*' | wc -l
    echo "Total number of files = $(find "$1" -type f | wc -l)"
}

types_files() {
    # configuration files: .conf
    # text files: .txt
    # exectubale: files
    # log files: .log
    # archives: .tar, .zip, .gz, .rar 
    # symbolic links
    DIR_PATH=$1

    num_conf=$(find "$DIR_PATH" -type f \
     -name "*.conf" -o -name "*.cfg" -o -name "*.ini" \
     -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" \
     -o -name "*.toml" | wc -l)

    num_txt=$(find "$DIR_PATH" -type f -name "*.txt" | wc -l)

    num_exec=$(find "$DIR_PATH" -type f -executable | wc -l)

    num_log=$(find "$DIR_PATH" -type f -name "*.log" | wc -l)

    num_archive=$(find "$DIR_PATH" -type f \
     -name "*.tar" -o -name "*.zip" -o -name "*.gz" \
      -o -name "*.bz2" -o -name "*.xz" -o -name "*.rar" \
       -o -name "*.7z" -o -name "*.iso" -o -name "*.jar" | wc -l)

    num_symlinks=$(find "$DIR_PATH" -type l | wc -l)

    echo "Configuration files (with the .conf extension) = $num_conf"
    echo "Text files = $num_txt"
    echo "Executable files = $num_exec"
    echo "Log files (with the extension .log) = $num_log"
    echo "Archive files = $num_archive"
    echo "Symbolic links = $num_symlinks"
}

largest_file() {
    echo "TOP 10 files of maximum size arranged in descending order (path, size and type):"
    local search_path="${1:-.}"
    # %s output size in bytes
    # %s output full path
    # `sort -nr` sort in descending order
    find "$search_path" -type f -printf "%s %p\n" | sort -nr | head -n 10 | awk '
    {
        size_bytes = $1;
        $1 = "";
        path = $0;
        sub(/^ /, "", path);

        split(path, parts, "/");
        filename = parts[length(parts)];

        if (match(filename, /\.[^\.]*$/)) {
            type = substr(filename, RSTART + 1);
        } else {
            type = "noext";
        }

        if (size_bytes >= 1073741824) {
            size = size_bytes / 1073741824;
            unit = "GB";
        } else if (size_bytes >= 1048576) {
            size = size_bytes / 1048576;
            unit = "MB";
        } else if (size_bytes >= 1024) {
            size = size_bytes / 1024;
            unit = "KB";
        } else {
            size = size_bytes;
            unit = "B";
        }

        size = sprintf("%.1f", size);

        printf("%d - %s, %s %s, %s\n", NR, path, size, unit, type);
    }'
    # awk script
}

largest_executable_file() {
    echo "TOP 10 executable files of the maximum size arranged in descending order (path, size and MD5 hash of file):"
    local search_path="${1:-.}"
    
    find "$search_path" -type f -executable -printf "%s %p\n" | sort -nr | head -n 10 | awk '
    {
        size_bytes = $1;
        $1 = "";
        path = $0;
        sub(/^ /, "", path);
        
        # Экранируем путь к файлу для безопасного использования в shell-командах
        gsub(/"/, "\\\"", path);
        escaped_path = "\"" path "\"";
        
        # Вычисляем MD5-хеш с использованием md5sum
        cmd = "md5sum " escaped_path " 2>/dev/null | awk '\''{print $1}'\''";
        if ((cmd | getline md5_hash) <= 0) {
            md5_hash = "error calculating MD5";
        }
        close(cmd);
        
        # Преобразуем размер в удобочитаемый формат
        if (size_bytes >= 1073741824) {
            size = size_bytes / 1073741824;
            unit = "GB";
        } else if (size_bytes >= 1048576) {
            size = size_bytes / 1048576;
            unit = "MB";
        } else if (size_bytes >= 1024) {
            size = size_bytes / 1024;
            unit = "KB";
        } else {
            size = size_bytes;
            unit = "B";
        }
        
        size = sprintf("%.1f", size);
        
        printf("%d - %s, %s %s, %s\n", NR, path, size, unit, md5_hash);
    }'
}

is_valid_dir() {
    if [[ ! -d "$1" ]]; then
        echo "Error: '$1' is not a valid directory."
        return 1
    fi
}

result_print() {
    echo
    total_dir $1
    echo
    top_five $1
    echo
    total_files $1
    echo
    types_files $1
    echo
    largest_file $1
    echo
    largest_executable_file $1
}
