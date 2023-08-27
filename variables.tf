variable "awsRegion" {
  type    = string
  default = "us-east-1"
}

variable "config_recorder_name" {
  type    = string
  default = "rca-awsconfig-default-recorder"
}

variable "config_role_name" {
  type    = string
  default = "awsconfig-role"
}

variable "config_channel_name" {
  type    = string
  default = "rca-awsconfig-default-channel"
}

variable "config_bucket_name" {
  type    = string
  default = "rca-resource-update-awsconfig"
}

variable "config_policy_name" {
  type    = string
  default = "awsconfig-s3-sns-full-access"
}

variable "sns_topic_name" {
  type    = string
  default = "management-updates"
}

variable "group_eventbridge_rule_name" {
  type    = string
  default = "config-msg-filter"
}

variable "group_resource_type_filter" {
  type = list(string)
  default = [
    "AWS::EC2::RouteTable",
    "AWS::IAM::User",
    "AWS::IAM::Group",
    "AWS::IAM::Policy",
    "AWS::IAM::Role"
  ]
}

variable "config_resource_type_filter" {
  type = list(string)
  default = [
    "AWS::EC2::SecurityGroup",
    "AWS::EC2::RouteTable",
    "AWS::IAM::User",
    "AWS::IAM::Group",
    "AWS::IAM::Policy",
    "AWS::IAM::Role"
  ]
}

variable "group_eventbridge_configuration_item_status_filter" {
  type    = list(string)
  default = ["ResourceDiscovered", "ResourceDeleted", "OK"]
}

variable "security_eventbridge_rule_name" {
  type    = string
  default = "security-msg-filter"
}

variable "security_resource_type_filter" {
  type = list(string)
  default = [
    "AWS::EC2::SecurityGroup"
  ]
}

variable "security_eventbridge_configuration_item_status_filter" {
  type    = list(string)
  default = ["AWS::EC2::SecurityGroup"]
}

variable "email_list" {
  type        = list(string)
  description = "List of emails who will receive the notification based on cloudwatch alarm"
  default     = ["test@test.com"]
}
