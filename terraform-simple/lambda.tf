terraform {
  required_version = ">= 0.12"
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda-role-terraform" {
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_role_policy" "lambda-add-policy" {

  role   = aws_iam_role.lambda-role-terraform.id
  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogStream",
            "logs:PutLogEvents"
         ],
         "Resource":"arn:aws:logs:*:*"
      }
   ]
}
EOF
}

# Used in combination with source_code_hash to only update lamda if
# the zip file changes

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "source"
  output_path = "main.zip"
}

resource "aws_lambda_function" "add" {
  filename         = "main.zip"
  function_name    = var.lambda_function_name
  role             = aws_iam_role.lambda-role-terraform.arn
  handler          = "main.add"
  runtime          = "python3.7"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}
