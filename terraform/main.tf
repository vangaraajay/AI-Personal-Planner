resource "aws_dynamodb_table" "Tasks" {
    name = "Tasks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "user_id"
    range_key = "task_id"

    attribute {
        name = "user_id"
        type = "S"
    }
    attribute {
        name = "task_id"
        type = "S"
    }

    server_side_encryption {
      enabled = true
    }

    tags = {
        Environment = "Database"
        Project = "AI Powered Planner Chatbot"
    }
}

//Setting up Lambda IAM Role
resource "aws_iam_role" "lambda_role" {
    name = "lambda-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action    = "sts:AssumeRole"
            Effect    = "Allow"
            Principal = { 
                Service = "lambda.amazonaws.com" 
            }
        }]
    })
}

//Allowing DynamoDB Access for the role
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda-dynamodb-policy"
  description = "Allow Lambda to access the DB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.Tasks.arn
      }
    ]
  })
}

//Cloudwatch
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

//DynamoDB Access
resource "aws_iam_role_policy_attachment" "lambda_custom_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

//Bedrock Access
resource "aws_iam_role_policy_attachment" "lambda_bedrock" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
}

//Creating Lambda Function
resource "aws_lambda_function" "chatbot_lambda" {
  function_name = "Agent-Code"
  runtime       = "python3.11"  # Python runtime
  handler       = "lambda_function.lambda_handler"
  filename      = "lambda.zip"
  role          = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.tasks.name
    }
  }

    tags = {
        Environment = "Compute"
        Project = "AI Powered Planner Chatbot"
    }
}
