config {
  # format = "checkstyle"
  format = "compact"
  plugin_dir = "~/.tflint.d/plugins"

  module = true
  force = false
  disabled_by_default = false

  ignore_module = {}

  varfile = []
  variables = []
}

plugin "aws" {
  enabled = true
  version = "0.17.0"
  deep_check = true
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}


plugin "terraform" {
  enabled = true
  version = "0.17.0"
  preset  = "all"
}
