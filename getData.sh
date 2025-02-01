#!/bin/bash

key="your key goes here"
secret="your secret key goes here"

if [[ "$key" = "your key goes here" ]]; then
	echo "You need to edit this script and add your key and secret key"
	exit 1
fi

if [[ "$secret" = "your secret key goes here" ]]; then
	echo "You need to edit this script and your key and secret key"
	exit 1
fi

curl --request GET \
     --url "https://data.alpaca.markets/v2/stocks/bars?symbols=$1&timeframe=1D&start=2024-01-01&limit=1000&adjustment=raw&feed=sip&sort=asc" \
     --header "APCA-API-KEY-ID: $key" \
     --header "APCA-API-SECRET-KEY: $secret" \
     --header 'accept: application/json'
