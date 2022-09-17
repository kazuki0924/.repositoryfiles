#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# chmod 755 all files in a directory

TARGET_DIR="${1:-scripts}"

chmod +x "${TARGET_DIR}"/*.sh
