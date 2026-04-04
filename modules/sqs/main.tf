locals {
  queue_name = var.fifo_queue ? format("%s.fifo", var.queue_name) : var.queue_name
}

resource "aws_sqs_queue" "this" {
  name                        = local.queue_name
  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  max_message_size            = var.max_message_size
  delay_seconds               = var.delay_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null
  deduplication_scope         = var.fifo_queue ? var.deduplication_scope : null
  kms_master_key_id           = var.kms_master_key_id

  tags = merge(var.tags, {
    Name = local.queue_name
  })
}

################################################################
# SQS Queue Policy - Allow SNS Publish
################################################################
data "aws_iam_policy_document" "this" {
  count = length(var.allowed_publishers) > 0 ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.this.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = var.allowed_publishers
    }
  }
}

################################################################
# Apply SNS Publish Policy to SQS Queues
################################################################
resource "aws_sqs_queue_policy" "this" {
  count = length(var.allowed_publishers) > 0 ? 1 : 0

  queue_url = aws_sqs_queue.this.url
  policy    = data.aws_iam_policy_document.this[0].json
}
