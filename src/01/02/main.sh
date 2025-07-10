#!/bin/bash

# main.sh

source config.sh

echo "HOSTNAME: $HOSTNAME"
echo "TIMEZONE: $TIMEZONE UTC$UTC_OFFSET_HOURS"
echo "USER: $USER"
echo "OS: $OS"
echo "DATE: $DATE"
echo "UPTIME: $UPTIME"
echo "UPTIME SEC: $UPTIME_SEC"
echo "IP: $IP"
echo "MASK: $OCT1.$OCT2.$OCT3.$OCT4"
echo "Default Gateway: $GATEWAY"
echo "RAM_TOTAL = $RAM_TOTAL ГБ"
echo "RAM_USED = $RAM_USED ГБ"
echo "RAM_FREE = $RAM_FREE ГБ"
echo "SPACE_ROOT = $SPACE_ROOT МБ"
echo "SPACE_ROOT_USED = $SPACE_ROOT_USED МБ"
echo "SPACE_ROOT_FREE = $SPACE_ROOT_FREE МБ"

read -p "Сохранить данные в файл? (Y/N): " ANSWER

if [[ "$ANSWER" == "Y" || "$ANSWER" == "y" ]]; then
    TIMESTAMP=$(date +"%d_%m_%y_%H_%M_%S")
    FILENAME="$TIMESTAMP.status"

    cat <<EOL > "$FILENAME"
HOSTNAME: $HOSTNAME
TIMEZONE: $TIMEZONE UTC$UTC_OFFSET_HOURS
USER: $USER
OS: $OS
DATE: $DATE
UPTIME: $UPTIME
UPTIME SEC: $UPTIME_SEC
IP: $IP
MASK: $OCT1.$OCT2.$OCT3.$OCT4
Default Gateway: $GATEWAY
RAM_TOTAL = $RAM_TOTAL ГБ
RAM_USED = $RAM_USED ГБ
RAM_FREE = $RAM_FREE ГБ
SPACE_ROOT = $SPACE_ROOT МБ
SPACE_ROOT_USED = $SPACE_ROOT_USED МБ
SPACE_ROOT_FREE = $SPACE_ROOT_FREE МБ
EOL

    echo "Данные успешно сохранены в файл: $FILENAME"
else
    echo "Сохранение данных отменено."
fi