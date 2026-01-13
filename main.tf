################################################################
# SNS Topic - Event Backbone
################################################################
module "events_topic" {
  source = "./modules/sns"

  topic_name                  = "${local.event_names.topic}-sns"
  kms_master_key_id           = var.kms_master_key_id
  fifo_throughput_scope       = var.fifo_throughput_scope
  tracing_config              = var.tracing_config
  content_based_deduplication = var.content_based_deduplication
  fifo_topic                  = var.fifo_topic
}

################################################################
# SQS Queues - Event Consumers
################################################################
module "event_queues" {
  source   = "./modules/sqs"
  for_each = var.queues

  queue_name                  = "${local.event_names.queues[each.key]}-sqs"
  visibility_timeout_seconds  = each.value.visibility_timeout_seconds
  message_retention_seconds   = each.value.message_retention_seconds
  max_message_size            = each.value.max_message_size
  delay_seconds               = each.value.delay_seconds
  receive_wait_time_seconds   = each.value.receive_wait_time_seconds
  fifo_queue                  = each.value.fifo_queue
  content_based_deduplication = each.value.content_based_deduplication
  deduplication_scope         = each.value.deduplication_scope
  allowed_publishers          = [module.events_topic.arn]
}

################################################################
# SNS Subscriptions - Fan-out Configuration
################################################################
resource "aws_sns_topic_subscription" "event_consumers" {
  for_each = var.queues

  topic_arn = module.events_topic.arn
  protocol  = "sqs"
  endpoint  = module.event_queues[each.key].arn

  filter_policy        = jsonencode(each.value.filter_policy)
  filter_policy_scope  = each.value.filter_policy_scope
  raw_message_delivery = each.value.raw_message_delivery
}
