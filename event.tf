locals {
  event_rules = {
    group_resources = {
      name                      = var.group_eventbridge_rule_name,
      resource_types            = var.group_resource_type_filter,
      configuration_item_status = var.group_eventbridge_configuration_item_status_filter
    },
    security_resources = {
      name                      = var.security_eventbridge_rule_name,
      resource_types            = var.security_resource_type_filter,
      configuration_item_status = var.security_eventbridge_configuration_item_status_filter
    }
  }
}

# Create a eventbridge rule for config messages
resource "aws_cloudwatch_event_rule" "config_messages" {
  for_each    = local.event_rules
  name        = each.value.name
  description = "Config message Notification"

  # filter config messages based on -> "Config Configuration Item Change"
  event_pattern = jsonencode({
    source      = ["aws.config"],
    detail-type = ["Config Configuration Item Change"],
    detail = {
      messageType = ["ConfigurationItemChangeNotification"],
      configurationItem = {
        resourceType            = each.value.resource_types,
        configurationItemStatus = each.value.configuration_item_status # Filter messages based on configuration status. Valid Values: OK | ResourceDiscovered | ResourceNotRecorded | ResourceDeleted | ResourceDeletedNotRecorded
      }
    }
  })
}

# Target for eventbridge rule
resource "aws_cloudwatch_event_target" "sns" {
  for_each = local.event_rules
  rule      = aws_cloudwatch_event_rule.config_messages[each.key].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.notify_config_change.arn

  # Custom message based on our requirements
  input_transformer {
    input_paths = {
      "awsAccountId" : "$.detail.configurationItem.awsAccountId",
      "awsRegion" : "$.detail.configurationItem.awsRegion",
      "configurationItemCaptureTime" : "$.detail.configurationItem.configurationItemCaptureTime",
      "resource_ID" : "$.detail.configurationItem.resourceId",
      "resource_type" : "$.detail.configurationItem.resourceType"
    }
    input_template = <<EOF
{
  "message": "On <configurationItemCaptureTime> AWS Config service recorded an update of an <resource_type> with Id <resource_ID> in the account <awsAccountId> region <awsRegion>. For more details open the AWS Config console at https://console.aws.amazon.com/config/home?region=<awsRegion>#/timeline/<resource_type>/<resource_ID>/configuration",
  "ruleArn": <aws.events.rule-arn>, 
  "ruleName": <aws.events.rule-name>,
  "originalEvent": <aws.events.event.json>
}
EOF
  }
}
