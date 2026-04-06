output "name" {
  description = "Full name of the SQS queue, including the '.fifo' suffix if applicable."
  value       = aws_sqs_queue.this.name
}

output "arn" {
  description = "Amazon Resource Name (ARN) of the SQS queue. Use this for IAM policies or event source mappings."
  value       = aws_sqs_queue.this.arn
}

output "url" {
  description = "HTTPS endpoint URL of the SQS queue. Required for SendMessage and ReceiveMessage API calls."
  value       = aws_sqs_queue.this.url
}
