provider "aws" {
  region = "us-east-2"
}

# Package the Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# Create the Lambda function
resource "aws_lambda_function" "example_lambda" {
  function_name = "example-lambda"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  role             = aws_iam_role.lambda_role.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# Create the IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "example_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Create the API Gateway
resource "aws_apigatewayv2_api" "example_api" {
  name          = "example-api"
  protocol_type = "HTTP"
}

# Create a deployment for the API Gateway
resource "aws_apigatewayv2_deployment" "example_deployment" {
  api_id      = aws_apigatewayv2_api.example_api.id

  # Forces a new deployment when any of the Lambda resources or routes change
  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_integration.lambda_integration),
      jsonencode(aws_apigatewayv2_route.example_route),
    ])))
  }

  depends_on = [
    aws_apigatewayv2_integration.lambda_integration,
    aws_apigatewayv2_route.example_route,
  ]
}

# Create a default stage for the API Gateway
resource "aws_apigatewayv2_stage" "example_stage" {
  api_id     = aws_apigatewayv2_api.example_api.id
  name       = "$default"
  deployment_id = aws_apigatewayv2_deployment.example_deployment.id
}

# Integrate the Lambda function with the API Gateway
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.example_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.example_lambda.invoke_arn
}

# Create a route for the API
resource "aws_apigatewayv2_route" "example_route" {
  api_id    = aws_apigatewayv2_api.example_api.id
  route_key = "GET /greeting"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Grant permissions to the API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "apigw_lambda_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # Make sure to set the source_arn to the ARN of the API Gateway resource
  source_arn = "${aws_apigatewayv2_api.example_api.execution_arn}/*/*"
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.example_api.api_endpoint
}