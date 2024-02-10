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

resource "aws_lambda_function" "test_lambda" {

  filename      = "${path.module}/../lambda_function_payload.zip"
  function_name = local.lambda_function_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.lambda_handler"

  runtime = "python3.9"

  environment {
    variables = {
      foo = "bar"
    }
  }
}