locals {
  # Naming prefix: {env}-{project} (e.g. dev-shop)
  name_prefix = "${var.env}-${var.project}"

  event_names = {
    # SNS topic base name — .fifo suffix added by module
    topic = "${local.name_prefix}-${var.functionality}"

    # SQS queue names: {env}-{project}-{key}-{functionality}
    queues = {
      for key in keys(var.queues) :
      key => "${local.name_prefix}-${key}-${var.functionality}"
    }
  }

  common_tags = merge(var.tags, {
    Environment = var.env
    Project     = var.project
    ManagedBy   = "terraform"
  })
}
