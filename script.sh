#!/bin/bash

if [ "$#" -eq 1 ]; then
  TOKEN="$1"
else
  read -p "Please enter your GitHub API token: " TOKEN
fi

if [ -z "$TOKEN" ]; then
  echo "API token is required. Exiting."
  exit 1
fi

API_URL="https://api.github.com/user/starred"
OUTPUT_FILE="output.md"

RESPONSE=$(curl -s -w "%{http_code}" -H "Authorization: token $TOKEN" $API_URL -o response.json)

HTTP_STATUS="${RESPONSE: -3}"

if ! [[ "$HTTP_STATUS" =~ ^[0-9]+$ ]]; then
  echo "Failed to retrieve HTTP status code. Exiting."
  exit 1
fi

if [ "$HTTP_STATUS" -ne 200 ]; then
  echo "Error: Received HTTP status $HTTP_STATUS"
  case "$HTTP_STATUS" in
    401)
      echo "Unauthorized: Check your API token and its permissions."
      ;;
    403)
      echo "Forbidden: You might have exceeded rate limits or need different permissions."
      ;;
    404)
      echo "Not Found: The URL might be incorrect."
      ;;
    *)
      echo "An unknown error occurred."
      ;;
  esac
  exit 1
fi

sed '$ d' response.json > raw_data.json
URL=$(grep -e '"url".*repos*' raw_data.json | sed -e 's/ *"url": "https:\/\/api.github.com\/repos\/\(.*\)",/https:\/\/github.com\/\1/')
NAME=$(grep -e "full_name" raw_data.json | sed -e 's/ *"full_name": "\(.*\)",/\1/')
DESC=$(grep -e "description" raw_data.json | sed -e 's/ *"description": "\(.*\)",/\1/')

{
  paste <(echo "$NAME") <(echo "$URL") <(echo "$DESC") | while IFS=$'\t' read -r name url desc; do
    echo "* [$name]($url) $desc"
  done
} > $OUTPUT_FILE

echo "Data has been saved to $OUTPUT_FILE"
