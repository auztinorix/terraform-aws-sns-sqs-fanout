################################################################
# Global Context
################################################################
variable "aws_profile" {
  description = "AWS CLI profile name from ~/.aws/credentials used to authenticate with AWS"
  type        = string

  validation {
    condition     = length(var.aws_profile) > 0
    error_message = "AWS profile must not be empty."
  }
}

variable "env" {
  description = "Deployment environment identifier (dev, qas, stg, prd). Used as prefix in resource naming."
  type        = string

  validation {
    condition     = can(regex("^(dev|qas|stg|prd)$", var.env))
    error_message = "Environment must be one of: dev, qas, stg, prd."
  }
}

variable "project" {
  description = "Project identifier (exactly 4 lowercase alphanumeric characters). Used as prefix in resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{3}$", var.project))
    error_message = "Project name must be exactly 4 characters, starting with a letter, lowercase alphanumeric only."
  }
}

variable "functionality" {
  description = "Functionality or domain name for the messaging resources (e.g. 'orders', 'notifications'). Used in resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,49}$", var.functionality))
    error_message = "Functionality name must be 2-50 characters, start with a letter, lowercase letters, numbers and hyphens only."
  }
}

variable "tags" {
  description = "Global tags to apply to all resources. Merged with auto-generated tags (Environment, Project, ManagedBy)."
  type        = map(string)
  default     = {}
}

################################################################
# SNS Topic
################################################################
variable "fifo_topic" {
  description = "Whether to create a FIFO SNS topic. FIFO guarantees message ordering and exactly-once delivery."
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "KMS key ID or alias ARN for SNS topic server-side encryption (e.g. 'alias/aws/sns' for AWS-managed key)"
  type        = string
  default     = "alias/aws/sns"

  validation {
    condition     = length(var.kms_master_key_id) > 0
    error_message = "KMS master key ID must not be empty."
  }
}

variable "fifo_throughput_scope" {
  description = "Scope for FIFO throughput quota. 'MessageGroup' allows 300 msg/s per group; 'Topic' applies the limit globally."
  type        = string
  default     = "MessageGroup"

  validation {
    condition     = !var.fifo_topic || contains(["MessageGroup", "Topic"], var.fifo_throughput_scope)
    error_message = "FIFO throughput scope must be either 'MessageGroup' or 'Topic' when fifo_topic is true."
  }
}

variable "tracing_config" {
  description = "AWS X-Ray tracing mode for the SNS topic. 'Active' enables tracing; 'PassThrough' only propagates trace headers."
  type        = string
  default     = "PassThrough"

  validation {
    condition     = contains(["PassThrough", "Active"], var.tracing_config)
    error_message = "Tracing config must be either 'PassThrough' or 'Active'."
  }
}

variable "content_based_deduplication" {
  description = "Enable automatic content-based deduplication for FIFO topics. When true, message body is used for deduplication instead of requiring an explicit DeduplicationId."
  type        = bool
  default     = false

  validation {
    condition     = !var.fifo_topic || var.content_based_deduplication != null
    error_message = "Content-based deduplication must be specified when fifo_topic is true."
  }
}

################################################################
# SQS Queues
################################################################
variable "queues" {
  description = <<-EOT
    Map of SQS queue configurations to subscribe to the SNS topic.
    Each key becomes part of the queue name and must follow naming conventions.

    Attributes:
      visibility_timeout_seconds  - Invisibility window after read (0-43200s). Default: 30
      message_retention_seconds   - Retention period (60-1209600s). Default: 345600 (4 days)
      max_message_size            - Max message size in bytes (1024-262144). Default: 262144 (256KB)
      delay_seconds               - Delivery delay (0-900s). Default: 0
      receive_wait_time_seconds   - Long polling wait (0-20s). Default: 0
      fifo_queue                  - Enable FIFO ordering. Default: false
      content_based_deduplication - Auto-dedup by message body (FIFO only). Default: false
      deduplication_scope         - 'queue' or 'messageGroup' (FIFO only). Default: queue
      filter_policy_scope         - 'MessageAttributes' or 'MessageBody'. Default: MessageBody
      filter_policy               - SNS subscription filter rules. Default: {}
      raw_message_delivery        - Deliver raw SNS message without metadata. Default: false
  EOT
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

  # At least one queue must be defined
  validation {
    condition     = length(var.queues) > 0
    error_message = "At least one queue must be defined."
  }

  # Queue keys must follow naming conventions
  validation {
    condition = alltrue([
      for key in keys(var.queues) :
      can(regex("^[a-z][a-z0-9-]{0,49}$", key))
    ])
    error_message = "Queue keys must start with a letter, contain only lowercase letters, numbers and hyphens, and be 1-50 characters."
  }

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
