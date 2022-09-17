#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# install binaries required for development

REQUIREMENTS=(
  checkmake
  checkov
  dotenv-linter
  editorconfig-checker
  fd
  gibo
  gitleaks
  go
  hadolint
  jq
  markdownlint-cli
  node
  pgcli
  pre-commit
  sd
  shellcheck
  shfmt
  sops
  sqlfluff
  terraform
  terrascan
  tflint
  yamllint
  yq
)

UPDATES=(
  bash
  coreutils
  curl
  findutils
  git
  gnu-sed
  grep
  make
  postgresql
)

for UPDATE in "${UPDATES[@]}"; do
  brew install "${UPDATE}"
done

for REQUIREMENT in "${REQUIREMENTS[@]}"; do
  which "${REQUIREMENT}" &> /dev/null || brew install "${REQUIREMENT}"
done

# rg
which rg &> /dev/null || brew install ripgrep

# awscli
which aws &> /dev/null || brew install awscli

# jsonlint
which jsonlint &> /dev/null || npm install -g @prantlf/jsonlint

# spectral
which spectral &> /dev/null || npm install -g @stoplight/spectral-cli

# go-commitlinter
which go-commitlinter &> /dev/null || go install github.com/masahiro331/go-commitlinter@0.1.0

# gci
which gci &> /dev/null || go install github.com/daixiang0/gci@v0.6.0

# gofumpt
which gofumpt &> /dev/null || go install mvdan.cc/gofumpt@latest

# golines
which golines &> /dev/null || go install github.com/segmentio/golines@v0.11.0

# prettier
npm install

make init/.gitignore
make init/pre-commit
make init/go-commitlinter
