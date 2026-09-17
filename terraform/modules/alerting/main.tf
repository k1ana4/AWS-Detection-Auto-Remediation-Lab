resource "aws_sns_topic" "alerts" {
  name = "lab-security-alerts"
}

variable "alert_emails" {
  type = list(string)
}

resource "aws_sns_topic_subscription" "email" {
  for_each  = toset(var.alert_emails)
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_sns_topic_policy" "alerts" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sns:Publish"
      Resource  = aws_sns_topic.alerts.arn
    }]
  })
}

resource "aws_cloudwatch_event_rule" "guardduty" {
  name        = "lab-guardduty-findings"
  description = "Route GuardDuty findings to SNS"

  event_pattern = jsonencode({
    source      = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.guardduty.name
  target_id = "send-to-sns"
  arn       = aws_sns_topic.alerts.arn

  input_transformer {
    input_paths = {
      severity    = "$.detail.severity"
      type        = "$.detail.type"
      description = "$.detail.description"
      account     = "$.detail.accountId"
      region      = "$.detail.region"
    }
    input_template = <<EOF
"GuardDuty finding in <account> (<region>)
Severity: <severity>
Type: <type>

<description>"
EOF
  }
}
