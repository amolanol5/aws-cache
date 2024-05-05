data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "policy_lamda" {
  name = "test_policy"
  role = aws_iam_role.iam_for_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "test_lambda" {

  filename      = "${path.module}/../lambda_function_payload.zip"
  function_name = local.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.lambda_handler"

  runtime = "python3.9"

  vpc_config {
    subnet_ids         = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]
    security_group_ids = [aws_security_group.db.id]
  }

  environment {
    variables = {
      DB_HOST = aws_db_instance.this.address
      DB_USER = var.credential_rds_db.username
      DB_NAME = var.credential_rds_db.name
      DB_PASS = var.credential_rds_db.password
      # REDIS_URL = 
    }
  }
}

## function url
resource "aws_lambda_function_url" "url_latest" {
  function_name      = aws_lambda_function.test_lambda.function_name
  authorization_type = "NONE"
}