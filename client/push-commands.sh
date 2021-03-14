#!/bin/bash

set -o pipefail

result=$(cat client/input.txt \
             | xargs -I {} curl -s http://localhost:4000/v1/number -H 'content-type: application/json' -d '{"command": "{}"}' \
             | jq -r '.data' \
             | xargs \
             | sed 's/[^0-9]*//g')

echo "checksum result: $result"
