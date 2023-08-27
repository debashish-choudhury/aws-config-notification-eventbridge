resource "aws_sns_topic" "notify_config_change" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  for_each   = toset(var.email_list)
  depends_on = [aws_sns_topic.notify_config_change]
  topic_arn  = aws_sns_topic.notify_config_change.arn
  protocol   = "email"
  endpoint   = each.value
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.notify_config_change.arn
  policy = data.aws_iam_policy_document.event_policy.json
}