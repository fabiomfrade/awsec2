###################
#    Start EC2    #
###################

resource "aws_cloudwatch_event_rule" "start_ec2" {
    name = "StartEC2"
    description = "Daily start EC2"
    schedule_expression = "0 20 * * ? *"
}

resource "aws_cloudwatch_event_target" "start_ec2_target" {
    rule = "${aws_cloudwatch_event_rule.start_ec2.name}"
    target_id = "StartEC2"
    arn = "${aws_lambda_function.startec2.arn}"
}

###################
#    Stop  EC2    #
###################

resource "aws_cloudwatch_event_rule" "stop_ec2" {
    name = "StopEC2"
    description = "Daily Stop EC2"
    schedule_expression = "30 23 * * ? *"
}

resource "aws_cloudwatch_event_target" "stop_ec2_target" {
    rule = "${aws_cloudwatch_event_rule.stop_ec2.name}"
    target_id = "StopEC2"
    arn = "${aws_lambda_function.stopec2.arn}"
}