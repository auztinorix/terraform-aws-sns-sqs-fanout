################################################################
# Amazon SNS Topic Variables
################################################################
variable "topic_name" {
  description = "The name of the SNS topic."
  type        = string
}

variable "fifo_topic" {
  description = "Is the SNS topic FIFO?"
  type        = bool
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO topics"
  type        = bool

  validation {
    condition     = !var.fifo_topic || var.content_based_deduplication != null
    error_message = "Content-based deduplication must be specified when fifo_topic is true."
  }
}

variable "kms_master_key_id" {
  description = "KMS key ID for SNS topic encryption"
  type        = string
}

variable "tracing_config" {
  description = "Tracing configuration for SNS topic"
  type        = string
  validation {
    condition     = contains(["PassThrough", "Active"], var.tracing_config)
    error_message = "Tracing config must be either 'PassThrough' or 'Active'."
  }
}

variable "fifo_throughput_scope" {
  description = "Throughput scope for FIFO topics"
  type        = string

  validation {
    condition     = !var.fifo_topic || contains(["MessageGroup", "Topic"], var.fifo_throughput_scope)
    error_message = "FIFO throughput scope must be either 'MessageGroup' or 'Topic' when fifo_topic is true."
  }
}
