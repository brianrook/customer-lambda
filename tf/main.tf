provider "aws" {
  region     = "${var.aws_region}"
  shared_credentials_file = "/Users/brianrook/.aws/credentials"
}
terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "awstraining-terraform-up-and-running-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    # Replace this with your DynamoDB table name!
    dynamodb_table = "awstraining_terraform-up-and-running-locks"
    encrypt        = true
  }
}
data "aws_caller_identity" "current" { }

#Allow access to the S3 bucket where the lambda code is stored.
resource "aws_iam_policy" "helloWorld-iam_policy" {
  name = "lambda_access-policy"
  description = "IAM Policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket}",
                "arn:aws:s3:::${var.s3_bucket}/*"
            ]
        },
        {
          "Action": [
            "autoscaling:Describe*",
            "cloudwatch:*",
            "logs:*",
            "sns:*"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
  ]
}
  EOF
}

#Assume the role needed to create the lambda
resource "aws_iam_role" "iam_for_helloWorld_lambda" {
  name = "iam_for_helloWorld_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#attach the policy (for the S3 bucket access) to the role we're using
resource "aws_iam_role_policy_attachment" "iam-policy-attach" {
  role       = "${aws_iam_role.iam_for_helloWorld_lambda.name}"
  policy_arn = "${aws_iam_policy.helloWorld-iam_policy.arn}"
}

#create teh lambda from the code in the s3 bucket.  Make sure that all of the policies are in place before
#we attempt to create this
resource "aws_lambda_function" "tf-helloWorld" {
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key
  function_name = "helloWorld"
  role          = aws_iam_role.iam_for_helloWorld_lambda.arn
  handler       = "org.springframework.cloud.function.adapter.aws.SpringBootApiGatewayRequestHandler::handleRequest"
  memory_size   = 512
  timeout       = 15

  runtime = "java11"

  depends_on = [
    aws_iam_role_policy_attachment.iam-policy-attach,
    aws_iam_role_policy_attachment.helloWorld-log-attach,
    aws_cloudwatch_log_group.helloWorld-logs,
  ]

  environment {
    variables = {
      FUNCTION_NAME="apiFunction"
    }
  }
}

#create a log group for the lambda
resource "aws_cloudwatch_log_group" "helloWorld-logs" {
  name = "/aws/lambda/${var.app-name}"

  retention_in_days = 30
}

#create a policy to be able to write the logs
resource "aws_iam_policy" "helloWorld-logs" {
  name        = "helloWorld_lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

#associate the log policy privileges to the lambda iam
resource "aws_iam_role_policy_attachment" "helloWorld-log-attach" {
  role       = aws_iam_role.iam_for_helloWorld_lambda.name
  policy_arn = aws_iam_policy.helloWorld-logs.arn
}

# Now, we need an API to expose those functions publicly
resource "aws_apigatewayv2_api" "helloWorld-api" {
  name = "Hello API"
  protocol_type = "HTTP"
  target        = aws_lambda_function.tf-helloWorld.invoke_arn
}

resource "aws_lambda_permission" "helloWorld-permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tf-helloWorld.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.helloWorld-api.execution_arn}/*/*"
}