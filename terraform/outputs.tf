# DynamoDB Table Outputs
output "dynamodb_table_name" {
  description = "The name of the DynamoDB table used by the chatbot."
  value       = aws_dynamodb_table.tasks.name
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table."
  value       = aws_dynamodb_table.tasks.arn
}

# IAM Role Outputs
output "lambda_role_name" {
  description = "The name of the IAM role assigned to the Lambda function."
  value       = aws_iam_role.lambda_role.name
}

output "lambda_role_arn" {
  description = "The ARN of the Lambda IAM role."
  value       = aws_iam_role.lambda_role.arn
}

# Lambda Function Outputs
output "lambda_function_name" {
  description = "The name of the deployed Lambda function."
  value       = aws_lambda_function.chatbot_lambda.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the deployed Lambda function."
  value       = aws_lambda_function.chatbot_lambda.arn
}

output "lambda_invoke_arn" {
  description = "The ARN used to invoke the Lambda function."
  value       = aws_lambda_function.chatbot_lambda.invoke_arn
}

# API Gateway Outputs
output "api_gateway_url" {
  description = "The base URL of the API Gateway."
  value       = aws_api_gateway_stage.prod.invoke_url
}

# Frontend Hosting Outputs
output "frontend_url" {
  description = "The CloudFront URL for the frontend"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

output "s3_bucket_name" {
  description = "The S3 bucket name for uploading files"
  value       = aws_s3_bucket.frontend.bucket
}

# API Key Output
output "api_key" {
  description = "The API key for accessing the endpoints"
  value       = aws_api_gateway_api_key.chatbot_key.value
  sensitive   = true
}

# Useful Project Metadata
output "project_name" {
  description = "Project identifier tag."
  value       = "AI Powered Planner Chatbot"
}
