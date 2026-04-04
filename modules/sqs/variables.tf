################################################################
# Amazon SQS Queue Variables
################################################################
variable "queue_name" {
  description = "The name of the SQS queue."
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for the SQS queue in seconds"
  type        = number

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "Visibility timeout must be between 0 and 43200 seconds (12 hours)."
  }
}

variable "message_retention_seconds" {
  description = "Number of seconds Amazon SQS retains a message"
  type        = number

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "Message retention must be between 60 seconds and 1209600 seconds (14 days)."
  }
}

variable "max_message_size" {
  description = "Limit of how many bytes a message can contain before Amazon SQS rejects it"
  type        = number
}

variable "delay_seconds" {
  description = "Time in seconds that the delivery of all messages in the queue will be delayed"
  type        = number
}

variable "receive_wait_time_seconds" {
  description = "Time for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning"
  type        = number
}

variable "fifo_queue" {
  description = "Is the SQS queue FIFO?"
  type        = bool
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO queues"
  type        = bool

  validation {
    condition     = !var.fifo_queue || var.content_based_deduplication != null
    error_message = "Content-based deduplication must be specified when fifo_queue is true."
  }
}

variable "deduplication_scope" {
  description = "Specifies whether message deduplication occurs at the message group or queue level"
  type        = string

  validation {
    condition     = !var.fifo_queue || contains(["messageGroup", "queue"], var.deduplication_scope)
    error_message = "Deduplication scope must be either 'messageGroup' or 'queue' when fifo_queue is true."
  }
}

variable "kms_master_key_id" {
  description = "KMS key ID for SQS queue server-side encryption. Leave empty to use SQS-managed encryption (SSE-SQS)."
  type        = string
  default     = null
}

variable "allowed_publishers" {
  description = "List of SNS topic ARNs allowed to publish to this queue"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags specific to this resource"
  type        = map(string)
  default     = {}
}
