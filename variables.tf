################################################################
# Global Context Variables
################################################################
variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "own-aws-environment"
}

variable "env" {
  description = "Environment's name"
  type        = string

  validation {
    condition     = can(regex("^(dev|qas|stg|prd)$", var.env))
    error_message = "Environment must be one of: dev, qas, stg, prd."
  }
}

variable "project" {
  description = "Project's name (exactly 4 characters, organizational standard)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{4}$", var.project))
    error_message = "Project name must be 4 characters, lowercase letters, numbers and hyphens only."
  }
}

variable "functionality" {
  description = "Functionality's name"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,50}$", var.functionality))
    error_message = "Functionality name must be 2-50 characters, lowercase letters, numbers and hyphens only."
  }
}

################################################################
# Amazon SNS – Topic Configuration
################################################################
variable "fifo_topic" {
  description = "Is the SNS topic FIFO?"
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "KMS Master Key ID for the SNS topic"
  type        = string
  default     = "alias/aws/sns"
}

variable "fifo_throughput_scope" {
  description = "FIFO throughput scope for the SNS topic"
  type        = string
  default     = "MessageGroup"

  validation {
    condition     = !var.fifo_topic || contains(["MessageGroup", "Topic"], var.fifo_throughput_scope)
    error_message = "FIFO throughput scope must be either 'MessageGroup' or 'Topic' when fifo_topic is true."
  }
}

variable "tracing_config" {
  description = "Tracing configuration for the SNS topic"
  type        = string
  default     = "PassThrough"

  validation {
    condition     = contains(["PassThrough", "Active"], var.tracing_config)
    error_message = "Tracing config must be either 'PassThrough' or 'Active'."
  }
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO topics"
  type        = bool
  default     = false

  validation {
    condition     = !var.fifo_topic || var.content_based_deduplication != null
    error_message = "Content-based deduplication must be specified when fifo_topic is true."
  }
}

################################################################
# Amazon SQS – Queue Subscriptions Configuration
################################################################
variable "queues" {
  description = "Map of SQS queues configurations"
  type = map(object({
    visibility_timeout_seconds  = optional(number, 30)
    message_retention_seconds   = optional(number, 345600)
    max_message_size            = optional(number, 262144)
    delay_seconds               = optional(number, 0)
    receive_wait_time_seconds   = optional(number, 0)
    fifo_queue                  = optional(bool, false)
    content_based_deduplication = optional(bool, false)
    deduplication_scope         = optional(string, "queue")
    filter_policy_scope         = optional(string, "MessageBody")
    filter_policy               = optional(map(list(string)), {})
    raw_message_delivery        = optional(bool, false)
  }))

  validation {
    condition = alltrue([
      for config in var.queues :
      !config.fifo_queue || contains(["queue", "messageGroup"], config.deduplication_scope)
    ])
    error_message = "Deduplication scope must be either 'queue' or 'messageGroup' when fifo_queue is true."
  }

  validation {
    condition = alltrue([
      for config in var.queues :
      !config.fifo_queue || config.content_based_deduplication != null
    ])
    error_message = "Content based deduplication must be specified when fifo_queue is true."
  }

  validation {
    condition = alltrue([
      for config in var.queues :
      config.visibility_timeout_seconds >= 0 && config.visibility_timeout_seconds <= 43200
    ])
    error_message = "Visibility timeout must be between 0 and 43200 seconds (12 hours)."
  }

  validation {
    condition = alltrue([
      for config in var.queues :
      config.message_retention_seconds >= 60 && config.message_retention_seconds <= 1209600
    ])
    error_message = "Message retention must be between 60 seconds and 1209600 seconds (14 days)."
  }

  validation {
    condition = alltrue([
      for config in var.queues :
      contains(["MessageAttributes", "MessageBody"], config.filter_policy_scope)
    ])
    error_message = "Filter policy scope must be either 'MessageAttributes' or 'MessageBody'."
  }

  validation {
    condition = alltrue([
      for config in var.queues :
      length(config.filter_policy) == 0 || alltrue([
        for key, values in config.filter_policy :
        length(values) > 0
      ])
    ])
    error_message = "Filter policy attributes must not have empty value lists."
  }

  validation {
    condition = alltrue([
      for config in var.queues :
      config.max_message_size >= 1024 && config.max_message_size <= 262144
    ])
    error_message = "Max message size must be between 1024 and 262144 bytes (256 KB)."
  }

  validation {
    condition = alltrue([
      for config in var.queues :
      config.delay_seconds >= 0 && config.delay_seconds <= 900
    ])
    error_message = "Delay seconds must be between 0 and 900 seconds (15 minutes)."
  }

  validation {
    condition = alltrue([
      for config in var.queues :
      config.receive_wait_time_seconds >= 0 && config.receive_wait_time_seconds <= 20
    ])
    error_message = "Receive wait time must be between 0 and 20 seconds."
  }
}
