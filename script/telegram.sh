#!/usr/bin/env bash
# shellcheck disable=SC1003


telegram_send() {

telegram_bot_token="$telegram_token"
telegram_chat_id="$telegram_chatid"
telegram_broker_url="$telegram_broker"
telegram_broker_token="$telegram_brokertoken"

echo $telegram_bot_token
echo $telegram_chat_id
echo $telegram_broker_url
echo $telegram_broker_token

if [ $telegram_broker_url ]; then
echo "send to telegram broker"

curl \
-H X-TG-TOKEN:"${telegram_bot_token}" \
-H BROKER-TOKEN:"$telegram_broker_token" \
-d parse_mode="HTML" \
-d chat_id="${telegram_chat_id}" \
-d text="${1}" \
-d method="sendMessage" \
$telegram_broker_url

else
echo "send to telegram api"

curl \
-d parse_mode="HTML" \
-d chat_id="$telegram_chat_id" \
-d text="$1" \
https://api.telegram.org/bot$telegram_bot_token/sendMessage

fi

}
