provider "aws" {
  shared_config_files      = ["~/.aws/config"]
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = var.aws_profile

  default_tags {
    tags = local.common_tags
  }
}
