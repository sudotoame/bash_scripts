#!/bin/bash

# Объяснение кодов ответа:
# 200 OK: Запрос успешно обработан.
# 201 Created: Ресурс успешно создан.
# 400 Bad Request: Неверный формат запроса.
# 401 Unauthorized: Требуется аутентификация.
# 403 Forbidden: Доступ запрещен.
# 404 Not Found: Ресурс не найден.
# 500 Internal Server Error: Внутренняя ошибка сервера.
# 501 Not Implemented: Метод не поддерживается.
# 502 Bad Gateway: Неверный ответ от upstream сервера.
# 503 Service Unavailable: Сервис временно недоступен.

export LC_TIME=en_US.utf8

# Массивы для генерации
status_codes=(200 201 400 401 403 404 500 501 502 503)
methods=(GET POST PUT PATCH DELETE)
user_agents=("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36"
	"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36"
	"Mozilla/5.0 (X11; Linux x86_64; rv:10.0) Gecko/20100101 Firefox/10.0"
	"Opera/9.80 (Windows NT 6.2; Win64; x64) Presto/2.12.388 Version/12.15"
	"Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko"
	"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.18363"
	"Googlebot/2.1 (+http://www.google.com/bot.html)"
	"curl/7.64.1"
	"Python-urllib/3.6")
urls=("/index.html" "/about" "/contact" "/api/v1/data" "/user/profile" "/login" "/logout" "/admin" "/error" "/search" "/home" "/products" "/services" "/blog" "/faq" "/terms" "/privacy")

generate_dates() {
	local start_date=$1
	local num_days=$2
	dates=()

	# Создание и сохранение 5 дат в массив `dates`
	for ((i = 0; i < num_days; i++)); do
		dates+=("$(date -d "$start_date + $i days" "+%Y-%m-%d")") # Добавляет +1 из `i` к %d
	done
}

generate_sorted_times() {
	local count=$1 # Принимает от 100 до 1000
	local times=()

	for ((i = 0; i < count; i++)); do
		sec=$(shuf -i 0-86399 -n 1) # генерация случайного число от 0 до 86399 (количество секунд в одном дне)
		times+=("$sec")
	done
	# IFS=$'\n' Временное раздление массива на новые строки для корректной сортировки
	IFS=$'\n' sorted_times=($(sort -n <<<"${times[*]}")) # Сортировка массива по возрастанию, от самой ранней секунды до самой поздней
	unset IFS                                            # Убираем разделение после сортировки
	echo "${sorted_times[@]}"                            # Возвращает отсортированный массив
}

generate_ip() {
	echo "$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1)"
}

generate_log_entry() {
	local timestamp=$1
	local date_str=$2

	local ip=$(generate_ip)
	local method=${methods[$((RANDOM % ${#methods[@]}))]}
	local url=${urls[$((RANDOM % ${#urls[@]}))]}
	local status=${status_codes[$((RANDOM % ${#status_codes[@]}))]}
	local size=$((RANDOM % 10240))
	local referer="-"
	local user_agent=${user_agents[$((RANDOM % ${#user_agents[@]}))]}

	echo "$ip - - $timestamp \"$method $url HTTP/1.1\" $status $size \"$referer\" \"$user_agent\""
}

generate_log_file() {
	local date_str=$1
	local count=$((RANDOM % 901 + 100)) # 100-1000 записей

	echo "Generating $count records for $date_str"

	# Обратно принимает отсортированный массив
	local times=($(generate_sorted_times $count)) # Передача от 100 до 1000

	# Используем тот же счетчик для корректной генерации дат по полученному отсортированному массиву
	for ((i = 0; i < count; i++)); do
		sec=${times[i]}
		# Получаем из секунд итоговое время в формате HH:MM:SS
		full_date=$(date -d "$date_str + $sec seconds" "+%d/%b/%Y:%T %z")
		# `%d` День
		# `%b` Месяц
		# `%Y` Год
		# `%T` Время
		# `%z` Временная зона
		# Все значение берется из $date_str
		full_date="[${full_date}]"

		generate_log_entry "$full_date" "$date_str"
	done >"nginx_access-$date_str.log"
}

main() {
	local start_date=$(date +"%Y-%m-%d")
	local num_files=5

	generate_dates "$start_date" "$num_files"

	for day in "${dates[@]}"; do
		generate_log_file "$day"
	done
}

main "$@"
