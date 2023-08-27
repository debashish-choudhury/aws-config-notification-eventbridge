data "aws_iam_policy_document" "event_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.notify_config_change.arn]
  }
}

# S3 Bucket policy
data "aws_iam_policy_document" "allow_access_to_config" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*"
    ]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    resources = [
      aws_s3_bucket.aws_config.arn,
      "${aws_s3_bucket.aws_config.arn}/*",
    ]
  }
}
