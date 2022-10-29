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

red_echo_eval() {
  local CMD="${1-""}"
  red_echo "${CMD}"
  eval "${CMD}"
}

# variables
SOURCE_DIR="${HOME}/.repositoryfiles"
TARGET_DIR="$(pwd)/tmp"
EXCLUDE_PATTERNS=(
  scripts/copy-repositoryfiles-to-dir.sh
  README.md
)
FD_EXCLUDE_PATTERN=".git"

usage() {
  echo "copy-repositoryfiles-to-dir [-h] [-t --target-dir TARGET_DIR] [-e --exclude-patterns EXCLUDE_PATTERNS]"
  echo ""
  echo "copy all targeted files in the .repositoryfiles to target directory"
  echo ""
  echo "  -h | --help: display this help and exit"
  echo "  --sudo-symlink-to-bin: create symbolic links to /usr/local/bin/repositoryfiles"
  echo "  -s | --source-dir=\"SOURCE_DIR\": source directory (default: \"~/.repositoryfiles\""
  echo "  -d | --target-dir=\"TARGET_DIR\": target directory (default: \"./tmp\""
  echo "  -e | --exclude-patterns: exclude patterns"
  echo "  (default: [\"scripts/copy-repositoryfiles-to-dir.sh\", \"README.md\"])"
}

# parse arguments
ARGS=("$@")
#if [[ ${#ARGS[@]} -eq 0 ]]; then
#  usage
#  exit 0
#fi
INDEX_TO_SKIP=""
for i in "${!ARGS[@]}"; do
  FLAG="${ARGS["${i}"]}"
  if [[ "${i}" == "${INDEX_TO_SKIP}" ]]; then
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
    --source-dir=*)
      SOURCE_DIR="${FLAG#*=}"
      ;;
    -s)
      INDEX_TO_SKIP="$((i + 1))"
      ARGS_LENGTH="${#ARGS[@]}"
      if [[ "${INDEX_TO_SKIP}" -lt "${ARGS_LENGTH}" ]]; then
        NEXT_ARG="${ARGS["${INDEX_TO_SKIP}"]}"
        SOURCE_DIR="${NEXT_ARG}"
      fi
      ;;
    --target-dir=*)
      TARGET_DIR="${FLAG#*=}"
      ;;
    -d)
      INDEX_TO_SKIP="$((i + 1))"
      ARGS_LENGTH="${#ARGS[@]}"
      if [[ "${INDEX_TO_SKIP}" -lt "${ARGS_LENGTH}" ]]; then
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
      if [[ "${INDEX_TO_SKIP}" -lt "${ARGS_LENGTH}" ]]; then
        NEXT_ARG="${ARGS["${INDEX_TO_SKIP}"]}"
        EXCLUDE_PATTERNS+=("${NEXT_ARG}")
      fi
      ;;
  esac
done

# check if the directory exists
if [[ ! -d "${SOURCE_DIR}" ]]; then
  red_echo "no source dir found."
  read -rp "clone repo to default location? [y/N]"$'\n> ' UserInput
  if [[ "${UserInput}" == "y" ]]; then
    red_echo_eval "https://github.com/kazuki0924/.repositoryfiles ~/.repositoryfiles"
  fi
  read -rp "overwrite ${TARGET_DIR}/${FILE}? [y/N]"$'\n> ' UserInput
fi

if [[ ! -d "${TARGET_DIR}" ]]; then
  red_echo "target directory does not exist: ${TARGET_DIR}"

  read -rp "create ${TARGET_DIR}? [y/N]"$'\n> ' UserInput
  if [[ "${UserInput}" == "y" ]]; then
    cyan_echo_eval "mkdir -p ${TARGET_DIR}"
  else
    exit 1
  fi
fi

if [[ "${SOURCE_DIR}" == "." ]]; then
  SOURCE_DIR="$(pwd)"
fi

if [[ "${TARGET_DIR}" == "." ]]; then
  TARGET_DIR="$(pwd)"
fi

# find files
echo "Updating files in ${SOURCE_DIR}..."
cyan_echo_eval "cd ${SOURCE_DIR}"
cyan_echo_eval "git pull origin main"
mapfile -t REPOSITORY_FILES < <(fd --hidden --type file --strip-cwd-prefix --exclude "${FD_EXCLUDE_PATTERN}" .)

# copy files
for FILE in "${REPOSITORY_FILES[@]}"; do
  echo "Copying ${FILE}..."
  for PATTERN in "${EXCLUDE_PATTERNS[@]}"; do
    if [[ "${FILE}" =~ ${PATTERN} ]]; then
      red_echo "skipping ${FILE}"
      continue 2
    fi
  done
  # if the file exists, append to it and if not, copy it
  # if the directory does not exist, create it
  if [[ -f "${TARGET_DIR}/${FILE}" ]]; then
    read -rp "file exists. Append to ${TARGET_DIR}/${FILE}? [y/N]"$'\n> ' UserInput
    if [[ "${UserInput}" == "y" ]]; then
      red_echo_eval "cat ${FILE} >> ${TARGET_DIR}/${FILE}"
    fi
    read -rp "overwrite ${TARGET_DIR}/${FILE}? [y/N]"$'\n> ' UserInput
    if [[ "${UserInput}" == "y" ]]; then
      red_echo_eval "cat ${FILE} > ${TARGET_DIR}/${FILE}"
    fi
  else
    cyan_echo_eval "mkdir -p \"$(dirname "${TARGET_DIR}/${FILE}")\""
    cyan_echo_eval "cp ${FILE} ${TARGET_DIR}/${FILE}"
  fi
done
