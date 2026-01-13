locals {
  # Naming convention: {env}-{project}-{functionality}
  # Example: dev-shop-orders
  name_prefix = "${var.env}-${var.project}"

  # Generate consistent names for all resources
  event_names = {
    # SNS topic name without suffix (added in module)
    topic = "${local.name_prefix}-${var.functionality}"

    # SQS queue names mapped from input keys
    queues = {
      for key in keys(var.queues) :
      key => "${local.name_prefix}-${key}-${var.functionality}"
    }
  }
}
