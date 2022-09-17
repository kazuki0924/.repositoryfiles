SHELL := bash
.ONESHELL:
.DELETE_ON_ERROR:
.SHELLFLAGS := -euo pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

all: setup

.PHONY: all

setup:
	@ ./scripts/setup-local.sh

.PHONY: setup

init/.gitignore:
	which gibo &>/dev/null || brew install gibo
	gibo dump Go Node Terraform macOS JetBrains VisualStudioCode >> .gitignore

.PHONY: init/.gitignore

init/pre-commit:
	which pre-commit &>/dev/null || brew install pre-commit
	pre-commit install

.PHONY: init/pre-commit

init/go-commitlinter:
	which commitlint &>/dev/null || go install github.com/masahiro331/go-commitlinter@0.1.0
	echo "go-commitlinter -rule .go-commitlinter.yml" >> .git/hooks/commit-msg
	chmod 755 .git/hooks/commit-msg

lint:
	pre-commit run --all-files

.PHONY: lint

local:
	docker compose --env-file .env --file ./ops/docker/compose/docker-compose.local.yml up --detach --build

.PHONY: local

local/build:
	docker compose --env-file .env --file ./ops/docker/compose/docker-compose.local.yml build --no-cache

.PHONY: local/build

local/down:
	docker compose --env-file .env --file ./ops/docker/compose/docker-compose.local.yml down --remove-orphans
	docker volume prune --force

.PHONY: local/down

remote:
	@./scripts/setup-remote.sh

.PHONY: remote

remote/down:
	cd ops/remote
	terraform destroy -auto-approve

.PHONY: remote/down

seed:
	@./scripts/seed.sh

.PHONY: seed

clean:
	rm -f /tmp/*

.PHONY: clean

test:
	go test ./...

.PHONY: test

test/cover:
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	open coverage.html

.PHONY: test/cover

clean/git-branch:
	@./scripts/cleanup-git-local-branch.sh

.PHONY: clean/git-branch

chmod/scripts:
	@./scripts/chmod-755-all-files-in-dir.sh ./scripts

.PHONY: chmod/scripts

ecr/login:
	aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $$(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-northeast-1.amazonaws.com

.PHONY: ecr/login

#ecr/push:
#	@./scripts/ecr-push.sh
#
#.PHONY: ecr/push
#
#sops/encrypt:
#	@./scripts/sops-encrypt.sh
#
#.PHONY: sops/encrypt
#
#sops/decrypt:
#	@./scripts/sops-decrypt.sh
#
#.PHONY: sops/decrypt
