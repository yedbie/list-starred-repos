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
PAGE=1
PER_PAGE=100

handle_error() {
  local status_code=$1
  if [ "$status_code" -ne 200 ]; then
    echo "Error: Received HTTP status $status_code"
    case "$status_code" in
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
}
echo "" > $OUTPUT_FILE

while true; do
  RESPONSE=$(curl -s -w "%{http_code}" -H "Authorization: token $TOKEN" "$API_URL?page=$PAGE&per_page=$PER_PAGE" -o response.json)
  HTTP_STATUS="${RESPONSE: -3}"
  handle_error "$HTTP_STATUS"
  
  URL=$(grep -e '"url".*repos*' response.json | sed -e 's/ *"url": "https:\/\/api.github.com\/repos\/\(.*\)",/https:\/\/github.com\/\1/')
  NAME=$(grep -e "full_name" response.json | sed -e 's/ *"full_name": "\(.*\)",/\1/')
  DESC=$(grep -e "description" response.json | sed -e 's/ *"description": "\(.*\)",/\1/')

  paste <(echo "$NAME") <(echo "$URL") <(echo "$DESC") | while IFS=$'\t' read -r name url desc; do
    echo "* [$name]($url) $desc"
  done >> $OUTPUT_FILE

  if [ $(grep -c '"url"' response.json) -lt $PER_PAGE ]; then
    echo "Success... Data has been saved to $OUTPUT_FILE"
    break
  fi
  PAGE=$((PAGE + 1))
done

rm -f response.json
