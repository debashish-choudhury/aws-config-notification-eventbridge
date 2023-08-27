# AWS Config recorder
resource "aws_config_configuration_recorder" "resource_change" {
  name     = var.config_recorder_name
  role_arn = aws_iam_service_linked_role.config_role.arn
  recording_group {
    all_supported  = false
    resource_types = var.config_resource_type_filter
    recording_strategy {
      use_only = "INCLUSION_BY_RESOURCE_TYPES"
    }
  }
}

# config status
resource "aws_config_configuration_recorder_status" "aws_config" {
  name       = aws_config_configuration_recorder.resource_change.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.resource_updates]
}


# Service linked role
resource "aws_iam_service_linked_role" "config_role" {
  aws_service_name = "config.amazonaws.com"
}

# Delivery channel
resource "aws_config_delivery_channel" "resource_updates" {
  name           = var.config_channel_name
  s3_bucket_name = aws_s3_bucket.aws_config.bucket
  # sns_topic_arn  = aws_sns_topic.notify_config_change.arn
  depends_on = [aws_config_configuration_recorder.resource_change, aws_s3_bucket.aws_config]
}

# S3 bucket for aws config
resource "aws_s3_bucket" "aws_config" {
  bucket        = var.config_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_access_to_config" {
  bucket = aws_s3_bucket.aws_config.id
  policy = data.aws_iam_policy_document.allow_access_to_config.json
}
