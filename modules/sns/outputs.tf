output "name" {
  description = "Full name of the SNS topic, including the '.fifo' suffix if applicable."
  value       = aws_sns_topic.this.name
}

output "arn" {
  description = "Amazon Resource Name (ARN) of the SNS topic. Use this to configure subscriptions or IAM policies."
  value       = aws_sns_topic.this.arn
}
