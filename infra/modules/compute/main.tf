# IAM Role for Lambda Functions
resource "aws_iam_role" "lambda_role" {
  name = "pranav-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = { Service = "lambda.amazonaws.com" },
      Effect   = "Allow"
    }]
  })
}

# Attach AWS Managed Policies (S3 + DynamoDB + Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Lambda Function: List Files
resource "aws_lambda_function" "list_files" {
  function_name = "pranav-list-files"
  role          = aws_iam_role.lambda_role.arn
  handler       = "list_files.handler"
  runtime       = "python3.11"

  filename         = "${path.module}/list_files.zip"
  source_code_hash = filebase64sha256("${path.module}/list_files.zip")

  environment {
    variables = {
      FILES_TABLE  = var.files_table
      FILES_BUCKET = var.files_bucket
    }
  }
}

# Lambda Function: Upload File
resource "aws_lambda_function" "upload_file" {
  function_name = "pranav-upload-file"
  role          = aws_iam_role.lambda_role.arn
  handler       = "upload_file.handler"
  runtime       = "python3.11"

  filename         = "${path.module}/upload_file.zip"
  source_code_hash = filebase64sha256("${path.module}/upload_file.zip")

  environment {
    variables = {
      FILES_BUCKET = var.files_bucket
    }
  }
}

# Lambda Function: Download File
resource "aws_lambda_function" "download_file" {
  function_name = "pranav-download-file"
  role          = aws_iam_role.lambda_role.arn
  handler       = "download_file.handler"
  runtime       = "python3.11"

  filename         = "${path.module}/download_file.zip"
  source_code_hash = filebase64sha256("${path.module}/download_file.zip")

  environment {
    variables = {
      FILES_BUCKET = var.files_bucket
    }
  }
}

# API Gateway (HTTP API)
resource "aws_apigatewayv2_api" "api" {
  name          = "pranav-api"
  protocol_type = "HTTP"
}

# Integrations (Connect API → Lambda)
resource "aws_apigatewayv2_integration" "list_files_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.list_files.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "upload_file_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.upload_file.arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "download_file_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.download_file.arn
  payload_format_version = "2.0"
}

# Routes (Endpoints)
resource "aws_apigatewayv2_route" "list_files_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /files"
  target    = "integrations/${aws_apigatewayv2_integration.list_files_integration.id}"
}

resource "aws_apigatewayv2_route" "upload_file_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /upload"
  target    = "integrations/${aws_apigatewayv2_integration.upload_file_integration.id}"
}

resource "aws_apigatewayv2_route" "download_file_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /download"
  target    = "integrations/${aws_apigatewayv2_integration.download_file_integration.id}"
}

# Stage (for Live Deployment)
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

# Lambda Permissions for API Gateway
resource "aws_lambda_permission" "list_files_invoke" {
  statement_id  = "AllowAPIGatewayInvokeList"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.list_files.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "upload_file_invoke" {
  statement_id  = "AllowAPIGatewayInvokeUpload"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_file.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "download_file_invoke" {
  statement_id  = "AllowAPIGatewayInvokeDownload"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.download_file.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# Outputs
output "api_endpoint" {
  description = "Base URL for your API Gateway endpoints"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

# Lambda Function: Delete File
resource "aws_lambda_function" "delete_file" {
  function_name = "pranav-delete-file"
  role          = aws_iam_role.lambda_role.arn
  handler       = "delete_file.handler"
  runtime       = "python3.11"

  filename         = "${path.module}/delete_file.zip"
  source_code_hash = filebase64sha256("${path.module}/delete_file.zip")

  environment {
    variables = {
      FILES_BUCKET = var.files_bucket
    }
  }
}

# Integration: Delete File
resource "aws_apigatewayv2_integration" "delete_file_integration" {
  api_id                 = aws_apigatewayv2_api.api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.delete_file.arn
  payload_format_version = "2.0"
}

# Route: /delete
resource "aws_apigatewayv2_route" "delete_file_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "ANY /delete"
  target    = "integrations/${aws_apigatewayv2_integration.delete_file_integration.id}"
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "delete_file_invoke" {
  statement_id  = "AllowAPIGatewayInvokeDelete"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_file.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
