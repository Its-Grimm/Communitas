#!/bin/bash

FILE="$1"
INSTANCE="https://mastodon.social"
TOKEN=$API_TOKEN

CONTENT=$(cat "$FILE")

curl -s -X POST "$INSTANCE/api/v1/statuses" \
  -H "Authorization: Bearer $TOKEN" \
  -d "status=$CONTENT"
