#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# delete local branches that have been removed remotely

git fetch --all --prune

git branch -vv \
  | grep -v '\*' \
  | grep -v master \
  | grep -v main \
  | grep -v develop \
  | grep -v dev \
  | grep -v staging \
  | grep -v stg \
  | grep -v production \
  | grep -v prod \
  | grep -v release \
  | grep 'gone]' \
  | awk '{print $1}' \
  | xargs -r git branch -D
