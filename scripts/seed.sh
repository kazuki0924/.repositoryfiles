#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# data seeding to postgres for development

SEED_FILE_DIR="ops/docker/postgres/seed"

echo "${DB_HOST}:${DB_PORT}:${DB_NAME}:${DB_USER}:${DB_PASSWORD}" > ~/.pgpass
chmod 0600 ~/.pgpass
for FILE in $(find "${SEED_FILE_DIR}" -type f -name '*.sql' | sort -n); do
  psql -h "${DB_HOST}" -w -U "${DB_USER}" -d "${DB_NAME}" -a -f "${FILE}"
done
