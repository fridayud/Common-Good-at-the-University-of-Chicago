provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "lambda_code" {
  bucket = "my-lambda-code-bucket"
}

resource "aws_s3_bucket_object" "lambda_code_object" {
  bucket = aws_s3_bucket.lambda_code.bucket
  key    = "lambda_function.zip"
  source = "path/to/your/lambda_function.zip" # Update this path
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*",
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_lambda_function" "example_lambda" {
  function_name = "MyExampleFunction"

  s3_bucket = aws_s3_bucket.lambda_code.bucket
  s3_key    = aws_s3_bucket_object.lambda_code_object.key

  handler = "lambda_function.lambda_handler"
  runtime = "python3.8"
  role    = aws_iam_role.lambda_execution_role.arn

  source_code_hash = filebase64sha256("path/to/your/lambda_function.zip") # Update this path
}

resource "aws_cloudwatch_event_rule" "lambda_trigger" {
  name                = "every-five-minutes"
  schedule_expression = "cron(*/5 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.lambda_trigger.name
  target_id = "TargetFunction"
  arn       = aws_lambda_function.example_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_trigger.arn
}

