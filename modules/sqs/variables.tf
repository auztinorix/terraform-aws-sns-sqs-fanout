variable "queue_name" {
  description = "Name of the SQS queue. The '.fifo' suffix is appended automatically when 'fifo_queue' is true."
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "Time in seconds a message stays invisible after being read. Range: 0-43200 (12h). Should exceed your consumer function timeout."
  type        = number

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "Visibility timeout must be between 0 and 43200 seconds (12 hours)."
  }
}

variable "message_retention_seconds" {
  description = "How long SQS retains undeleted messages in seconds. Range: 60-1209600 (14 days). AWS default: 345600 (4 days)."
  type        = number

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "Message retention must be between 60 seconds and 1209600 seconds (14 days)."
  }
}

variable "max_message_size" {
  description = "Maximum message size in bytes. Range: 1024-262144 (1KB-256KB)."
  type        = number
}

variable "delay_seconds" {
  description = "Initial delay in seconds before messages become visible in the queue. Range: 0-900 (15 min)."
  type        = number
}

variable "receive_wait_time_seconds" {
  description = "Seconds ReceiveMessage waits for messages (long polling). Range: 0-20. Values >0 reduce polling costs."
  type        = number
}

variable "fifo_queue" {
  description = "Whether the queue is FIFO. Guarantees strict ordering and exactly-once delivery."
  type        = bool
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication. Only applies when 'fifo_queue' is true."
  type        = bool

  validation {
    condition     = !var.fifo_queue || var.content_based_deduplication != null
    error_message = "Content-based deduplication must be specified when fifo_queue is true."
  }
}

variable "deduplication_scope" {
  description = "Deduplication level: 'messageGroup' (per group) or 'queue' (entire queue). Only applies when 'fifo_queue' is true."
  type        = string

  validation {
    condition     = !var.fifo_queue || contains(["messageGroup", "queue"], var.deduplication_scope)
    error_message = "Deduplication scope must be either 'messageGroup' or 'queue' when fifo_queue is true."
  }
}

variable "kms_master_key_id" {
  description = "KMS key ID for server-side encryption. Set to null to use SQS-managed encryption (SSE-SQS)."
  type        = string
  default     = null
}

variable "allowed_publishers" {
  description = "List of SNS topic ARNs allowed to publish to this queue. Used to generate the queue access policy."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for the SQS queue. Merged with common project tags."
  type        = map(string)
  default     = {}
}
