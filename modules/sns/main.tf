resource "aws_sns_topic" "this" {
  name                        = var.fifo_topic ? format("%s.fifo", var.topic_name) : var.topic_name
  kms_master_key_id           = var.kms_master_key_id
  tracing_config              = var.tracing_config
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.fifo_topic ? var.content_based_deduplication : null
  fifo_throughput_scope       = var.fifo_topic ? var.fifo_throughput_scope : null
}
