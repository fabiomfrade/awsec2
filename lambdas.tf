###################
#  Create Roles   #
###################

resource "aws_iam_policy" "lambda_policy" {
  name        = "PolicyLambda"
  description = "Enable Lambda Functions"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": [
              "ec2:Stop*",
              "ec2:Start*",
              "ec2:DescribeInstances"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "xray:PutTraceSegments",
            "xray:PutTelemetryRecords",
            "xray:GetSamplingRules",
            "xray:GetSamplingTargets",
            "xray:GetSamplingStatisticSummaries"
          ],
          "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "lambda_role" {
  name               = "LambdaRole"
  description        = "Lambda Role for Start/Stop"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement":
    [
        {
          "Sid": "",
          "Effect": "Allow",
          "Principal": {
              "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_start_stop" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

###################
#  Create Files   #
###################

data "archive_file" "python_pack_start" {
  type        = "zip"
  source_file = "${path.module}/files/start_ec2.py"
  output_path = "startec2.zip"
}

data "archive_file" "python_pack_stop" {
  type        = "zip"
  source_file = "${path.module}/files/stop_ec2.py"
  output_path = "stopec2.zip"
}

###################
#  Create Lambda  #
###################

resource "aws_lambda_function" "startec2" {
  filename      = "startec2.zip"
  function_name = "startec2"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.9"
  handler       = "start_ec2.lambda_handler"
  layers        = ["arn:aws:lambda:us-east-1:901920570463:layer:aws-otel-python-amd64-ver-1-17-0:1"]
  timeout       = "60"
  environment {
    variables = {
      AWS_LAMBDA_EXEC_WRAPPER = "/opt/otel-instrument"
    }
  }
  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_function" "stopec2" {
  filename      = "stopec2.zip"
  function_name = "stopec2"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.9"
  handler       = "stop_ec2.lambda_handler"
  layers        = ["arn:aws:lambda:us-east-1:901920570463:layer:aws-otel-python-amd64-ver-1-17-0:1"]
  timeout       = "60"
  environment {
    variables = {
      AWS_LAMBDA_EXEC_WRAPPER = "/opt/otel-instrument"
    }
  }
  tracing_config {
    mode = "Active"
  }
}
