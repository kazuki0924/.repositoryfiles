#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# deploy remote dev environment to aws with terraform

cd ops/remote

terraform init
terraform plan -out terraform_aws.tfplan
terraform apply terraform_aws.tfplan
