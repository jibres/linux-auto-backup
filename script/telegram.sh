#!/usr/bin/env bash
# shellcheck disable=SC1003


telegram_send() {

if [ $telegram_token ]; then

if [ $telegram_broker ]; then
echo "send to telegram broker"

curl \
-H X-TG-TOKEN:"$telegram_token" \
-H BROKER-TOKEN:"$telegram_brokertoken" \
-d parse_mode="HTML" \
-d chat_id="$telegram_chatid" \
-d text="$1" \
-d method="sendMessage" \
$telegram_broker

else
echo "send to telegram api"

curl \
-d parse_mode="HTML" \
-d chat_id="$telegram_chatid" \
-d text="$1" \
https://api.telegram.org/bot$telegram_token/sendMessage

fi

fi
}
