#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# helper functions
red_echo() {
  echo -e "\e[31m${1-""}\e[0m"
}

cyan_echo() {
  echo -e "\e[36m${1-""}\e[0m"
}

cyan_echo_eval() {
  local CMD="${1-""}"
  cyan_echo "${CMD}"
  eval "${CMD}"
}

# variables
TARGET_DIR="./tmp"
EXCLUDE_PATTERNS=("scripts/copy-repositoryfiles-to-dir.sh")
FD_EXCLUDE_PATTERN=".git"

usage() {
  echo "copy-repositoryfiles-to-dir [-h] [-t --target-dir TARGET_DIR] [-e --exclude-patterns EXCLUDE_PATTERNS]"
  echo "copy all targeted files in the .repositoryfiles to target directory"
  echo "  -h | --help: display this help and exit"
  echo "  --sudo-symlink-to-bin: create symbolic links to /usr/local/bin/repositoryfiles"
  echo "  -t | --target-dir=\"TARGET_DIR\": target directory (default: \"./tmp\""
  echo "  -e | --exclude-patterns: exclude patterns (default: [\"scripts/copy-repositoryfiles-to-dir.sh\"])"
}

# parse arguments
ARGS=("$@")
if [ ${#ARGS[@]} -eq 0 ]; then
  usage
  exit 0
fi
INDEX_TO_SKIP=""
for i in "${!ARGS[@]}"; do
  FLAG="${ARGS["${i}"]}"
  if [ "${i}" == "${INDEX_TO_SKIP}" ]; then
    continue
  fi
  case "${FLAG}" in
    -h | --help)
      usage
      exit 0
      ;;
    --sudo-symlink-to-bin)
      sudo ln -sfnv "$(realpath "${BASH_SOURCE[*]}")" /usr/local/bin/repositoryfiles
      ;;
    --target-dir=*)
      TARGET_DIR="${FLAG#*=}"
      ;;
    -t)
      INDEX_TO_SKIP="$((i + 1))"
      ARGS_LENGTH="${#ARGS[@]}"
      if [ "${INDEX_TO_SKIP}" -lt "${ARGS_LENGTH}" ]; then
        NEXT_ARG="${ARGS["${INDEX_TO_SKIP}"]}"
        TARGET_DIR="${NEXT_ARG}"
      fi
      ;;
    --exclude-patterns=*)
      EXCLUDE_PATTERNS+=("${FLAG#*=}")
      ;;
    -e)
      INDEX_TO_SKIP="$((i + 1))"
      ARGS_LENGTH="${#ARGS[@]}"
      if [ "${INDEX_TO_SKIP}" -lt "${ARGS_LENGTH}" ]; then
        NEXT_ARG="${ARGS["${INDEX_TO_SKIP}"]}"
        EXCLUDE_PATTERNS+=("${NEXT_ARG}")
      fi
      ;;
  esac
done

# find files
mapfile -t REPOSITORY_FILES < <(fd --hidden --type file --strip-cwd-prefix --exclude "${FD_EXCLUDE_PATTERN}" .)

# check if the directory exists
if [[ ! -d "${TARGET_DIR}" ]]; then
  red_echo "target directory does not exist: ${TARGET_DIR}"
  exit 1
fi

# copy files
for FILE in "${REPOSITORY_FILES[@]}"; do
  for PATTERN in "${EXCLUDE_PATTERNS[@]}"; do
    if [[ "${FILE}" =~ ${PATTERN} ]]; then
      red_echo "skipping ${FILE}"
      continue 2
    fi
  done
  # if the file exists, append to it and if not, copy it
  # if the directory does not exist, create it
  if [[ -f "${TARGET_DIR}/${FILE}" ]]; then
    cyan_echo_eval "cat ${FILE} >> ${TARGET_DIR}/${FILE}"
  else
    cyan_echo_eval "mkdir -p \"$(dirname "${TARGET_DIR}/${FILE}")\""
    cyan_echo_eval "cp ${FILE} ${TARGET_DIR}/${FILE}"
  fi
done
