#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# output environment variables from terraform

ENV_FILE=".env"

cd ops/remote
OUTPUT_JSON="$(terraform output -json)"
cd -

mapfile -t KEYS < <(echo "${OUTPUT_JSON}" | jq -rc 'keys' | sed -e 's/\[//g' -e 's/\]//g' -e 's/\,/\n/g' -e 's/\"//g')
for KEY in "${KEYS[@]}"; do
  VALUE=$(echo "${OUTPUT_JSON}" | jq -r ".[\"${KEY}\"].value")
  echo "export ${KEY^^}=\"${VALUE}\"" >> "${ENV_FILE}"
done
