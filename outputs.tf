output "event_messaging_resources" {
  description = "Event-driven messaging infrastructure (SNS topic and SQS queues)"

  value = {
    topic = {
      name = module.events_topic.name
      arn  = module.events_topic.arn
    }

    queues = {
      for key, value in module.event_queues : key => {
        name = value.name
        arn  = value.arn
        url  = value.url
      }
    }

    context = {
      environment = var.env
      project     = var.project
    }
  }
}
