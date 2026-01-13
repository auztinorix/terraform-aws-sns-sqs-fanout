output "name" {
  description = "Name of the SQS queue"
  value       = aws_sqs_queue.this.name
}

output "arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.this.arn
}

output "url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.this.url
}
