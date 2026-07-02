output "function_arn" {
  description = "ARN of the Lambda function."
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Name of the Lambda function."
  value       = aws_lambda_function.this.function_name
}

output "function_invoke_arn" {
  description = "Invoke ARN of the Lambda function."
  value       = aws_lambda_function.this.invoke_arn
}

output "function_qualified_arn" {
  description = "Qualified ARN of the Lambda function."
  value       = aws_lambda_function.this.qualified_arn
}

output "role_arn" {
  description = "ARN of the Lambda execution role."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  description = "Name of the Lambda execution role."
  value       = aws_iam_role.this.name
}

output "policy_arn" {
  description = "ARN of the execution policy."
  value       = aws_iam_policy.execution.arn
}

output "security_group_id" {
  description = "ID of the Lambda security group."
  value       = aws_security_group.this.id
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group."
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group."
  value       = aws_cloudwatch_log_group.this.arn
}
