###################
#    Start EC2    #
###################

resource "aws_cloudwatch_event_rule" "start_ec2" {
  name                = "StartEC2"
  description         = "Daily start EC2"
  schedule_expression = "cron(0 20 * * ? *)"
}

resource "aws_cloudwatch_event_target" "start_ec2_target" {
  rule      = aws_cloudwatch_event_rule.start_ec2.name
  target_id = "StartEC2"
  arn       = aws_lambda_function.startec2.arn
}

###################
#    Stop  EC2    #
###################

resource "aws_cloudwatch_event_rule" "stop_ec2" {
  name                = "StopEC2"
  description         = "Daily Stop EC2"
  schedule_expression = "cron(30 23 * * ? *)"
}

resource "aws_cloudwatch_event_target" "stop_ec2_target" {
  rule      = aws_cloudwatch_event_rule.stop_ec2.name
  target_id = "StopEC2"
  arn       = aws_lambda_function.stopec2.arn
}

###################
#   Permissions   #
###################

resource "aws_lambda_permission" "allow_startec2" {
  statement_id  = "AllowExecutionFromEventBridgeStartEC2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.startec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.start_ec2.arn
}

resource "aws_lambda_permission" "allow_stopec2" {
  statement_id  = "AllowExecutionFromEventBridgeStopEC2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stopec2.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.stop_ec2.arn
}