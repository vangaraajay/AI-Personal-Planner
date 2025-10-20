resource "aws_dynamodb_table" "tasks" {
    name = "Tasks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "task_id"

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
        Resource = aws_dynamodb_table.tasks.arn
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
  handler       = "agent.lambda_handler"
  filename      = "lambda.zip"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 60
  memory_size   = 512

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

//API Gateway
resource "aws_api_gateway_rest_api" "chatbot_api" {
  name = "chatbot-api"
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatbot_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.chatbot_api.execution_arn}/*/*"
}

//Path to Agent
resource "aws_api_gateway_resource" "chat_resource" {
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  parent_id   = aws_api_gateway_rest_api.chatbot_api.root_resource_id
  path_part   = "chat"
}

resource "aws_api_gateway_method" "chat_method" {
  rest_api_id   = aws_api_gateway_rest_api.chatbot_api.id
  resource_id   = aws_api_gateway_resource.chat_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  resource_id = aws_api_gateway_resource.chat_resource.id
  http_method = aws_api_gateway_method.chat_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.chatbot_lambda.invoke_arn
}

//Tasks Path (To get the list of tasks)
resource "aws_api_gateway_resource" "tasks_resource" {
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  parent_id   = aws_api_gateway_rest_api.chatbot_api.root_resource_id
  path_part   = "tasks"
}

resource "aws_api_gateway_method" "tasks_method" {
  rest_api_id   = aws_api_gateway_rest_api.chatbot_api.id
  resource_id   = aws_api_gateway_resource.tasks_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "tasks_integration" {
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
  resource_id = aws_api_gateway_resource.tasks_resource.id
  http_method = aws_api_gateway_method.tasks_method.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.chatbot_lambda.invoke_arn
}

//API Gateway Deployment
resource "aws_api_gateway_deployment" "chatbot_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.tasks_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.chatbot_api.id
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.chatbot_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.chatbot_api.id
  stage_name    = "prod"
}
