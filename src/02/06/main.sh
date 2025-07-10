#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "USage: $1 <1-2>"
	exit 1
else
	case $1 in
	1)
		LC_ALL="en_US.UTF-8" goaccess ../04/nginx_access-*.log \
			--log-format='%h %^[%d:%t %^] "%r" %s %b "%R" "%u"' \
			--date-format=%d/%b/%Y \
			--time-format=%H:%M:%S
		;;
	2)
		LC_ALL="en_US.UTF-8" goaccess ../04/nginx_access-*.log \
			--log-format='%h %^[%d:%t %^] "%r" %s %b "%R" "%u"' \
			--date-format=%d/%b/%Y \
			--time-format=%H:%M:%S \
			-o report.html
		;;
	esac
fi
