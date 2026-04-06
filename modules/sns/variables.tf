variable "topic_name" {
  description = "Name of the SNS topic. The '.fifo' suffix is appended automatically when 'fifo_topic' is true."
  type        = string
}

variable "fifo_topic" {
  description = "Whether the topic is FIFO. Enables strict message ordering and deduplication."
  type        = bool
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication. Only applies when 'fifo_topic' is true."
  type        = bool

  validation {
    condition     = !var.fifo_topic || var.content_based_deduplication != null
    error_message = "Content-based deduplication must be specified when fifo_topic is true."
  }
}

variable "kms_master_key_id" {
  description = "KMS key ID for topic encryption. Use 'alias/aws/sns' for the AWS managed key."
  type        = string
}

variable "tracing_config" {
  description = "X-Ray tracing mode. 'PassThrough' propagates existing traces, 'Active' creates new ones."
  type        = string

  validation {
    condition     = contains(["PassThrough", "Active"], var.tracing_config)
    error_message = "Tracing config must be either 'PassThrough' or 'Active'."
  }
}

variable "fifo_throughput_scope" {
  description = "Throughput scope for FIFO topics. 'MessageGroup' limits per group, 'Topic' applies to the entire topic."
  type        = string

  validation {
    condition     = !var.fifo_topic || contains(["MessageGroup", "Topic"], var.fifo_throughput_scope)
    error_message = "FIFO throughput scope must be either 'MessageGroup' or 'Topic' when fifo_topic is true."
  }
}

variable "tags" {
  description = "Additional tags for the SNS topic. Merged with common project tags."
  type        = map(string)
  default     = {}
}
